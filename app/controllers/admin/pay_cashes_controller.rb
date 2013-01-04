module Admin
  class PayCashesController < ResourceController
    def create
      order = Order.find(params[:order_id])
      if order && order.order_price && (!order.status || order.status < 3)
        @object = PayCash.new(params[:pay_cash])
        p = Payment.new
        p.payment_data = order
        p.balance_before = order.order_price.balance_amount
        p.amount = @object.amount
        p.current_balance = p.balance_before - p.amount
        p.pay_from = order.order_detail.user_info
        p.account_id = @object.account_id
        p.pay_method = @object
        p.operator_id = current_employee.employee_info.id
        if p.save
          if @object.save
            order.order_price.balance_amount = p.current_balance
            if order.order_price.balance_amount <= 0
              order.status = 3
            elsif order.order_price.balance_amount == order.order_price.actual_amount
             order.status = 1
            else 
              order.status = 2
            end
            order.save
          else
            flash[:error] = @object.errors.full_messages.to_sentence
          end
        else
          flash[:error] = p.errors.full_messages.to_sentence
        end
      end
    end
  end
end

