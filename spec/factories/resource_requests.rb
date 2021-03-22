# frozen_string_literal: true

FactoryBot.define do
  factory :resource_request do
    status { 'pending' }
    job_type { 'access_for_image' }
    digital_object_uid { 'abc-123' }
    src_file_location { 'file:///fake/path/to/file.png' }
    options { { rotation: '0' } }
  end
end
