module Admin
  class PayCreditCardsController < PayMethodsController
    def create
      @object = PayCreditCard.new(params[:pay_credit_card])
      super
    end
  end
end


