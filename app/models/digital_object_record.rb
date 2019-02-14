class DigitalObjectRecord < ApplicationRecord
  validates_presence_of :uid, :metadata_location_uri, :optimistic_lock_token
end
