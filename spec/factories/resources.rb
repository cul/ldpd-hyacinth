# frozen_string_literal: true

FactoryBot.define do
  factory :resource, class: Hyacinth::DigitalObject::Resource do
    initialize_with do
      new(
        checksum: 'sha256:asdf',
        file_size: 1234,
        location: 'tracked-disk:///some/file.txt',
        original_file_path: '/original/path/to/file.txt',
        media_type: 'text/plain'
      )
    end

    trait :image do
      after(:build) do |resource|
        resource.location = 'tracked-disk:///some/file.png'
        resource.original_file_path = 'file.png'
        resource.media_type = 'image/png'
      end
    end

    trait :video do
      after(:build) do |resource|
        resource.location = 'tracked-disk:///some/file.mp4'
        resource.original_file_path = 'file.mp4'
        resource.media_type = 'video/mp4'
      end
    end

    trait :audio do
      after(:build) do |resource|
        resource.location = 'tracked-disk:///some/file.m4a'
        resource.original_file_path = 'file.m4a'
        resource.media_type = 'audio/m4a'
      end
    end

    trait :pdf do
      after(:build) do |resource|
        resource.location = 'tracked-disk:///some/file.pdf'
        resource.original_file_path = 'file.pdf'
        resource.media_type = 'application/pdf'
      end
    end

    trait :text do
      # default resource is a text document, so no need to do anything for this trait
    end

    trait :office_document do
      after(:build) do |resource|
        resource.location = 'tracked-disk:///some/file.doc'
        resource.original_file_path = 'file.doc'
        resource.media_type = 'application/msword'
      end
    end
  end
end
