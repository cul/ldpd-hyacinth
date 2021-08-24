# frozen_string_literal: true

require 'rails_helper'

describe Hyacinth::Language::FieldsBuffer do
  let(:buffer) { described_class.new }
  let(:field_name) { 'Field-Name' }
  let(:field_value) { 'Value' }
  let(:append_value) { ' Appended' }

  describe '#empty?' do
    it do
      expect(buffer).to be_empty
      buffer.field(field_name, field_value)
      expect(buffer).not_to be_empty
    end
  end
  describe '#flush' do
    before { buffer.field(field_name, field_value) }
    it do
      flushed = buffer.flush
      expect(flushed).to include(field_name => [field_value])
      expect(flushed).to be_a HashWithIndifferentAccess
      expect(buffer).to be_empty
    end
  end
  describe '#append_field_value' do
    before { buffer.field(field_name, field_value) }
    it do
      buffer.append_field_value(append_value)
      expect(buffer.flush).to include(field_name => [field_value + append_value])
      expect(buffer).to be_empty
    end
  end
end
