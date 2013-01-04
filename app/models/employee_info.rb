class EmployeeInfo < ActiveRecord::Base
  belongs_to :employee
  belongs_to :company
  has_many :emails, :as => :email_data
  has_many :addresses, :as => :address_data
  has_many :telephones, :as => :tel_number
  has_one :account, :as => :owner

  accepts_nested_attributes_for :telephones, :allow_destroy => true, :reject_if => proc {att| att['tel'].blank? }
  accepts_nested_attributes_for :emails, :allow_destroy => true, :reject_if => proc { |att| att['email_address'].blank? }
  accepts_nested_attributes_for :addresses, :allow_destroy => true, :reject_if => proc {|att| att['address1'].blank? || att['city_id'] <= 0 }

  def default_telephone
    if self.telephones.empty?
      ''
    else
      self.telephones.order('updated_at desc').first.tel
    end
  end
  def default_email
    if self.emails.empty?
      ''
    else
      self.emails.order('updated_at desc').first.email_address
    end
  end
  def default_address
    if self.addresses.empty?
      nil
    else
      self.addresses.order('update_at desc').first
    end
  end
end
