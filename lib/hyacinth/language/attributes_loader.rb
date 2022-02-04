# frozen_string_literal: true

class Hyacinth::Language::AttributesLoader
  def initialize(path)
    @path = path
  end

  # Type: language
  # Type: region
  # Type: script
  # Type: variant
  def each_subtag
    each_with(subtag: :*, &block)
  end

  # Type: redundant (use Preferred-Value or cache with subtag refs)
  # Type: grandfathered
  def each_tag
    each_with(tag: :*, &block)
  end

  def each_with(atts)
    records.each do |record_fields|
      yield record_fields if atts.inject(true) do |memo, entry|
        if memo
          (entry[1] == :* && record_fields[entry[0]].present?) ||
          (record_fields[entry[0]] == entry[1]) ||
          (record_fields[entry[0]] & Array(entry[1])).present?
        else
          false
        end
      end
    end
  end

  def records
    load
  end

  def reload!
    @records = nil
    load
  end

  def add_value(record, field, value)
    return unless record && field && value
    (record[field] ||= []) << value
  end

  def load
    @records ||= begin
      records = []
      open(@path) do |blob|
        self.class.load(blob, records)
      end
      records
    end
  end

  # from a line data buffer, load a list of attribute hashes
  def self.load(io, record_buffer = [])
    record_fields = Hyacinth::Language::FieldsBuffer.new
    io.each do |line|
      if line.match?(/^%%/)
        record_buffer << record_fields.flush if record_fields.present?
        next
      elsif line.match?(/^[A-Z][a-z]+(\-[A-z][a-z]+)*\:\s/)
        field, value = line.split(/\:\s/, 2)
        record_fields.field(field.downcase, value.strip)
      else
        record_fields.append_field_value(line.rstrip)
      end
    end
    record_buffer << record_fields.flush if record_fields.present?
    record_buffer
  end
end
