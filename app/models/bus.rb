class Bus < ActiveRecord::Base
  has_many :photos, :as => :photo_data, :dependent => :destroy
  belongs_to :title_photo, :class_name => 'Photo'
  belongs_to :company
  has_many :telephones, :as => :tel_number
  has_many :bus_reserved_dates
  after_initialize :init_seats

  def init_seats
    if new_record?
      self.seats ||= 57
      self.seats_per_row ||= 4
      self.passengeway ||= 2
    end
  end
end
