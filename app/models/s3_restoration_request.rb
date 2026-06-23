class S3RestorationRequest < ApplicationRecord
  validates :s3_uri, presence: true
  validates :object_size, presence: true
end
