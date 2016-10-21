require 'rails_helper'

describe DigitalObjectType, :type => :model do
  describe '#as_json' do
    let(:object) { described_class.new }
    subject { object.as_json }
    [:string_key, :display_label, :id].each do |key|
      it { is_expected.to be_key(key) }
    end
  end
  describe '.get_model_for_string_key' do
    ['Asset', 'FileSystem', 'Group', 'Item', 'PublishTarget'].each do |name|
      it do
        expect(described_class.get_model_for_string_key(name.underscore)).to be DigitalObject.const_get(name)
      end
    end
    it { expect { described_class.get_model_for_string_key("Missing")}.to raise_error(Hyacinth::Exceptions::InvalidDigitalObjectTypeError) }
  end
end