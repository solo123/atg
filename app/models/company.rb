class Company < ActiveRecord::Base
	has_many :contacts, :dependent => :destroy
	has_many :accounts, :as => :owner, :dependent => :destroy
	has_many :remarks, :as => :notes, :dependent => :destroy
  has_many :photos, :as => :photo_data, :dependent => :destroy
  belongs_to :title_photo, :class_name => 'Photo'

	accepts_nested_attributes_for :contacts,
  	:reject_if => proc { |attributes| attributes['full_name'].blank? }

  def show_name
    short_name
  end
end
