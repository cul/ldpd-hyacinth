# frozen_string_literal: true

class Vocabulary < ApplicationRecord
  ALPHANUMERIC_UNDERSCORE_KEY_REGEX = /\A[a-z]+[a-z0-9_]*\z/.freeze
  RESERVED_FIELD_NAMES = %w[
    pref_label alt_labels uri uri_hash vocabulary vocabulary_id
    locked authority term_type custom_fields uuid created_at updated_at
  ].freeze
  DATA_TYPES = %w[string integer boolean].freeze

  has_many :terms, dependent: :destroy

  validates :string_key, presence: true, uniqueness: true, string_key: true
  validates :label,      presence: true
  validate :validate_custom_fields

  store :custom_fields, coder: JSON

  def add_custom_field(options = {})
    field_key = options[:field_key]

    raise 'field_key cannot be blank' if field_key.blank?
    raise 'field_key cannot be added because it\'s already a custom field' if custom_fields[field_key].present?

    custom_fields[field_key] = { data_type: options[:data_type], label: options[:label] }
  end

  def update_custom_field(options = {})
    field_key = options[:field_key]

    raise 'field_key cannot be blank' if field_key.blank?
    raise 'field_key must be present in order to update custom field' if custom_fields[field_key].blank?

    # if new label given, update label
    custom_fields[field_key][:label] = options[:label] if options.key?(:label)
  end

  def delete_custom_field(field_key)
    raise 'Cannot delete a custom field that doesn\'t exist' unless custom_fields.key?(field_key)

    custom_fields.delete(field_key)
  end

  def locked?
    locked
  end

  private

    def validate_custom_fields
      custom_fields.each do |field_key, info|
        errors.add(:custom_fields, "#{field_key} is a reserved field name and cannot be used") if RESERVED_FIELD_NAMES.include? field_key

        unless ALPHANUMERIC_UNDERSCORE_KEY_REGEX.match? field_key
          errors.add(
            :custom_fields,
            'field_key can only contain lowercase alphanumeric characters and underscores and must start with a lowercase letter'
          )
        end

        errors.add(:custom_fields, 'each custom_field must have a label and data_type defined') if info[:label].blank? || info[:data_type].blank?

        errors.add(:custom_fields, 'data_type must be one of string, integer or boolean') unless DATA_TYPES.include? info[:data_type]
      end
    end
end
