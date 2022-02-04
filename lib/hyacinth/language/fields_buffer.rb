# frozen_string_literal: true

class Hyacinth::Language::FieldsBuffer
  attr_accessor :current_field, :current_value, :record_fields

  def initialize(field_values = {})
    @record_fields = field_values.with_indifferent_access
    @current_field = nil
    @current_value = nil
  end

  # start a new field-value buffer
  def field(field_name, value)
    flush_field
    @current_field = field_name
    @current_value = value.dup
  end

  # append to current field value
  def append_field_value(value)
    return unless current_field && value
    current_value << value.gsub(/\s+/, ' ')
  end

  # returns record fields hash and reset
  def flush
    flush_field
    flushed_fields = record_fields
    initialize
    flushed_fields
  end

  def present?
    record_fields.present? || current_value.present?
  end

  def empty?
    !present? # rubocop:disable Rails/Blank
  end

  alias blank? empty?

  private

    # end current field buffer and append value to record buffer
    def flush_field
      (record_fields[current_field] ||= []) << current_value if current_field && current_value.to_s.match?(/[^\s]/)
      @current_field = nil
      @current_value = nil
    end
end
