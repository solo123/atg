module Admin
  class PayCreditCardsController < PayMethodsController
    def create
      @object = PayCreditCard.new(params[:pay_credit_card])
      super
    end
    def destroy
      @object.PayCreditCard.find(params[:id])
      biz_payment = Biz::OrderPayment.new
    end
  end
end


