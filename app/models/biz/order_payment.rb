module Biz
  class OrderPayment
    attr_reader :errors

    def pay(order, a_pay, operator)
      @errors = []
      check_for_pay(order, a_pay, operator)
      return unless @errors.blank?

      payment = set_payment_data(order, a_pay, operator)
      ActiveRecord::Base.transaction do
        set_receive_account(payment)      
        payment.save!
        payment.account.save!
        order.pay(payment)
        if a_pay.is_a? PayVoucher
          a_pay.voucher.status = 0
          a_pay.voucher.save!
        end
      end
    end
    def check_for_pay(order, a_pay, operator)
      @errors = []
      unless operator.is_a? EmployeeInfo
        @errors << "Please Login befor payment"
        return
      end
      unless order.ready_to_payment?
        @errors << "Order is not ready to payment."
        return
      end
      unless a_pay.amount > 0
        @errors << "Please input pay amount."
        return
      end
      unless a_pay.valid?
        @errors << a_pay.errors.full_messages.to_sentence
        return
      end
      if (a_pay.is_a? PayCash) || (a_pay.is_a? PayCheck)
        unless a_pay.received_by
          @errors << "Please select received by"
          return
        end
        a_pay.account = get_employee_account(a_pay.received_by, a_pay.class.name)
      elsif (a_pay.is_a? PayCompany)
        a_pay.account_receivable = a_pay.amount - a_pay.company_discount - a_pay.additional_discount
        a_pay.account = get_company_account(a_pay.company, 'PayCompany')
      else
        a_pay.account = get_company_account(operator.company, a_pay.class.name)
      end
      @errors << "Account not found" unless a_pay.account
    end

    def set_payment_data(order, a_pay, operator)
      p = a_pay.build_payment
      p.payment_data = order
      p.pay_method = a_pay
      p.account = a_pay.account
      p.operator = operator
      p.amount = a_pay.amount
      p.pay_from = order.order_detail.user_info
      a_pay.payment = p
      a_pay.status = 1
      p
    end
    def set_receive_account(payment)
      account = payment.account
      acc_hist = account.account_histories.build
      acc_hist.add_balance(account.balance, payment.amount)
      account.balance = acc_hist.balance_after
      acc_hist.payment = payment
    end

    def refund(order, refund, operator)
      check_for_refund(order, refund, operator)
      return unless @errors.blank?

      payment = set_payment_data(order, refund, operator)
      ActiveRecord::Base.transaction do
        set_receive_account(payment)
        payment.save!
        payment.account.save!
        order.pay(refund)
      end
    end

    def check_for_refund(order, refund, operator)
      @errors = []
      unless operator.is_a? EmployeeInfo
        @errors << "Please Login befor refund"
        return
      end
      unless order.status && order.status > 1 && order.order_price && order.order_price.balance_amount < order.order_price.actual_amount
        @errors << "Order is not ready to refund."
        return
      end
      unless refund.amount < 0
        @errors << "Please input pay amount."
        return
      end
      unless refund.valid?
        @errors << refund.errors.full_messages.to_sentence
        return
      end
      if refund.is_a? PayCash
        unless refund.received_by
          @errors << "Please select refund from"
          return
        end
        refund.account = get_employee_account(refund.received_by, 'PayCash')
      end
      @errors << "Account not found" unless refund.account
    end

    def cancle_to_voucher(voucher, operator)
      check_for_voucher(voucher, operator)
      return unless @errors.blank?

      order = voucher.order
      p = voucher.build_payment
      p.payment_data = order
      p.amount = 0 - voucher.amount - voucher.refund_fee
      p.account = get_company_account(operator.company, 'Voucher')
      p.pay_method = voucher
      p.operator_id = operator.id
      voucher.payment = p
      unless p.account
        errors << "Account not found"
        return
      end

      ActiveRecord::Base.transaction do
        order_hist = order.account_histories.build
        order_hist.sub_balance(order.order_price.balance_amount, p.amount)
        order.order_price.balance_amount = order_hist.balance_after
        order_hist.payment = p

        account = p.account
        acc_hist = account.account_histories.build
        acc_hist.add_balance(account.balance, p.amount)
        account.balance = acc_hist.balance_after
        acc_hist.payment = p

        unless p.save
          errors << p.errors.full_messages.to_sentence
          break
        end
        unless account.save
          errors << account.errors.full_messages.to_sentence
          break
        end
        order.status = 7
        unless order.save
          errors << order.errors.full_messages.to_sentence
          break
        end
      end
    end
    def check_for_voucher(voucher, operator)
      @errors = []
      unless operator.is_a? EmployeeInfo
        @errors << "Please Login befor refund"
        return
      end
      unless operator.company
        @errors << "Operator have no company"
        return
      end
      unless voucher.order
        @errors << "Cannot cancle without order"
        return
      end
      order = voucher.order
      unless order.status && order.status > 1 && order.order_price && order.order_price.balance_amount <= order.order_price.actual_amount
        @errors << "Order is not ready to refund."
        return
      end
      unless voucher.amount > 0
        @errors << "Please input amount."
        return
      end
      unless voucher.valid?
        @errors << voucher.errors.full_messages.to_sentence
        return
      end
      if voucher.amount + voucher.refund_fee != order.order_price.actual_amount - order.order_price.balance_amount
        @errors << "Voucher amount not match order amount"
        return
      end
    end
    def withdraw(a_pay, operator)
      check_for_withdraw(a_pay, operator)
      return unless @errors.blank?
      withdraw_pay = a_pay.dup
      withdraw_pay.amount = 0 - a_pay.amount
      withdraw_pay.status = 0
      withdraw_pay.account = a_pay.account
      p = withdraw_pay.build_payment
      order = a_pay.payment.payment_data
      p.payment_data = order
      p.amount = withdraw_pay.amount
      p.pay_from = order.order_detail.user_info
      p.account = withdraw_pay.account
      p.pay_method = withdraw_pay
      p.operator = operator
      withdraw_pay.payment = p

      ActiveRecord::Base.transaction do
        set_order_and_history(order, p, withdraw_pay)
        set_receive_account(p)
        a_pay.status = 0
        a_pay.save
        unless withdraw_pay.save
          @errors << withdraw_pay.errors.full_messages.to_sentence
          break
        end
        unless p.save
          @errors << p.errors.full_messages.to_sentence
          break
        end
        unless p.account.save
          @errors << p.account.errors.full_messages.to_sentence
          break
        end
        order.pay(p)
        if a_pay.is_a? PayVoucher
          a_pay.voucher.status = 1
          a_pay.voucher.save
        end
        p
      end
    end
    def check_for_withdraw(a_pay, operator)
      @errors = []
      unless operator.is_a? EmployeeInfo
        errors << "Please Login"
        return
      end
      unless (a_pay.is_a? PayCreditCard) || (a_pay.is_a? PayCheck) || (a_pay.is_a? PayVoucher)
        errors << "Only credit card and check and voucher can withdraw"
        return
      end
      unless a_pay.status == 1
        errors << "This item cannot withdraw."
        return
      end
      order = a_pay.payment.payment_data
      unless order.status && order.status > 0 && order.status != 7
        errors << "Order cannot withdraw."
        return
      end
      unless a_pay.amount > 0
        errors << "Cannot withdraw amount 0."
        return
      end
      if a_pay.new_record?
        errors << "cannot withdraw this item."
        return
      end
      unless a_pay.account
        errors << "Account not found"
        return
      end
    end

    def get_employee_account(employee_info, pay_method)
      acc = employee_info.accounts.where(:account_type => pay_method).first
      unless acc
        acc = employee_info.accounts.build(:account_type => pay_method, :balance => 0)
        acc.save
      end
      acc
    end
    def get_company_account(company, account_type)
      return nil unless company
      acc = company.accounts.where(:account_type => account_type).first
      unless acc
        acc = company.accounts.build(:account_type => account_type, :balance => 0)
        acc.save
      end
      acc
    end

  end
end
