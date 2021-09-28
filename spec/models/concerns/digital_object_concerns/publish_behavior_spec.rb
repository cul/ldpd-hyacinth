# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DigitalObjectConcerns::PublishBehavior do
  include_context 'with stubbed search adapters'
  let(:publishing_user) { FactoryBot.create(:user) }
  let(:project) { FactoryBot.create(:project) }
  let(:publish_target_1) do
    FactoryBot.create(:publish_target)
  end
  let(:publish_target_2) do
    FactoryBot.create(:publish_target)
  end

  let(:digital_object_without_publish_entries) { FactoryBot.create(:digital_object_test_subclass) }
  let(:digital_object_with_publish_entries) do
    obj = FactoryBot.create(:digital_object_test_subclass)
    obj.send(
      :publish_entries=,
      [
        PublishEntry.new(publish_target: publish_target_1, published_at: Time.current, published_by: publishing_user),
        PublishEntry.new(publish_target: publish_target_2, published_at: Time.current, published_by: publishing_user)
      ]
    )
    obj
  end

  describe "#perform_publish_changes" do
    context 'to a publish target that is an allowed DOI target' do
      let(:publish_target) { FactoryBot.create(:publish_target, doi_priority: 1, is_allowed_doi_target: true) }
      let(:object) { FactoryBot.create(:digital_object_test_subclass, doi: doi) }
      let(:doi) { '10.abcd/4569' }
      let(:location_uri) { "http://example.org/objects/#{object.uid}" }
      let(:publish_entry) { PublishEntry.new(publish_target: publish_target, citation_location: location_uri) }
      let(:publish_promise) do
        Concurrent::Promise.new { publish_entry }.execute
      end

      it "calls #update on external identifier adapter" do
        expect(object).to receive(:async_publish).and_return(publish_promise)
        expect(Hyacinth::Config.external_identifier_adapter).to receive(:update).with(doi, digital_object: object, location_uri: location_uri)
        object.perform_publish_changes(publish_to: [publish_target])
      end
    end
  end

  describe "#unpublish_from_all" do
    it "calls unpublish_from for all current publish_entries" do
      expect(digital_object_with_publish_entries).to receive(:unpublish_from).with(targets: digital_object_with_publish_entries.publish_targets)
      digital_object_with_publish_entries.unpublish_from_all
    end

    it "doesn't call publish internally when an object has no publish entries" do
      expect(digital_object_without_publish_entries).not_to receive(:unpublish_from)
      digital_object_without_publish_entries.unpublish_from_all
    end
  end
end
