# frozen_string_literal: true

class PublishEntry < ApplicationRecord
  belongs_to :digital_object
  belongs_to :publish_target
  belongs_to :published_by, required: false, class_name: 'User'

  validates :digital_object, :publish_target, presence: true
end
