# frozen_string_literal: true

require 'rails_helper'

describe Hyacinth::Adapters::ExternalIdentifierAdapter::Memory do
  let(:adapter_configuration) do
    {
      default_target_url_template: default_target_url_template
    }
  end
  let(:adapter) do
    described_class.new(adapter_configuration)
  end
  let(:digital_object_uid) { SecureRandom.uuid }
  let(:digital_object_attributes) do
    data = JSON.parse(file_fixture('files/datacite/item.json').read)
    data['identifiers'] = ['item.' + digital_object_uid]
    data
  end

  let(:digital_object) do
    obj = DigitalObject::Item.new
    obj.uid = digital_object_uid
    obj.assign_attributes(digital_object_attributes)
    obj
  end

  describe '#mint' do
    let(:doi) { adapter.mint(digital_object: digital_object) }
    let(:doi_info) { adapter.identifiers[doi] }
    context "configured with a default url template" do
      let(:default_target_url_template) { "http://expected/%{uid}" }
      it "sets a default target_url" do
        expect(doi_info[:target_url]).to eql format(default_target_url_template, uid: digital_object.uid)
      end
    end
    context "configured with no present default url template" do
      let(:default_target_url_template) { nil }
      it "sets a default target_url" do
        expect(doi_info[:target_url]).to be_nil
      end
    end
  end
end
