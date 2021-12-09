# frozen_string_literal: true

FactoryBot.define do
  factory :resource_request do
    status { 'pending' }
    job_type { 'access_for_image' }
    digital_object_uid { '3f5e6977-26f5-4d8f-968c-a4015b10e50f' }
    src_file_location { 'file:///fake/path/to/file.png' }
    options { { rotation: '0' } }
  end
end
