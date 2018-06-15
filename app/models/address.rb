class Address < ApplicationRecord
  second_level_cache expires_in: 1.week
  belongs_to :country
  belongs_to :postcode
  belongs_to :state
  belongs_to :owner, polymorphic: true

  geocoded_by :full_address   # can also be an IP address
  after_validation :geocode, if: ->(obj){ obj.street1.present? and obj.street1_changed? } # auto-fetch coordinates
  reverse_geocoded_by :latitude, :longitude do |obj,results|
    if geo = results.first
      obj.street1   = geo.street_address
      obj.suburb   = geo.city
      obj.postcode = Postcode.find_by_code(geo.postal_code)
      obj.country = Country.find_by_name(geo.country)
      obj.state = State.find_by_name(geo.state_code)
    end
  end
  after_validation :reverse_geocode, if: ->(obj){ obj.latitude.present? and obj.latitude_changed? }  # auto-fetch address
  after_validation :update_timezone, if: ->(obj){ obj.latitude.present? and obj.latitude_changed? }

  def full_address
    return nil if self.street1.nil?
    result = self.street1
    result += ", #{self.street2}" if !self.street2.nil? && self.street2.length > 0
    result += ", #{self.suburb}"
    result += " #{self.state.name}" if !self.state.blank? 
    result += " #{self.postcode.code}" if !self.postcode.blank?
    result += ", #{self.country.name}" if !self.country.blank?
    result
  end

  def address= address
    byebug
  end

  def update_timezone
    self.timezone = Timezone.lookup(self.latitude, self.longitude)
  end
end
