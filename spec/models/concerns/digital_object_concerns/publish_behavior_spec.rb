# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DigitalObjectConcerns::PublishBehavior do
  include_context 'with stubbed search adapters'

  describe "#perform_publish_changes" do
    let(:publish_target) { FactoryBot.create(:publish_target, doi_priority: 1, is_allowed_doi_target: true) }
    let(:object) { FactoryBot.create(:digital_object_test_subclass, doi: doi) }
    let(:doi) { '10.abcd/4569' }
    let(:target_url) { "http://example.org/objects/#{object.uid}" }
    let(:publish_entry) { PublishEntry.new(publish_target: publish_target, citation_location: target_url) }
    let(:publish_promise) do
      Concurrent::Promise.new { publish_entry }.execute
    end
    context 'to a publish target that is an allowed DOI target' do
      before do
        # pretend we were preserved 10 seconds ago
        object.preserved_at = DateTime.new.getlocal - 10
      end
      it "calls #update on external identifier adapter" do
        expect(object).to receive(:async_publish).and_return(publish_promise)
        expect(Hyacinth::Config.external_identifier_adapter).to receive(:update).with(doi, digital_object: object, target_url: target_url, state: :active)
        object.perform_publish_changes(publish_to: [publish_target])
      end
    end
    context 'when an object has not been preserved' do
      it "raises an exception without starting async processes" do
        expect(object).not_to receive(:async_publish)
        expect(Hyacinth::Config.external_identifier_adapter).not_to receive(:update).with(doi, digital_object: object, target_url: target_url, state: :active)
        expect { object.perform_publish_changes(publish_to: [publish_target]) }.to raise_error(Hyacinth::Exceptions::InvalidPublishConditions)
      end
    end
  end

  describe "#unpublish_from_all" do
    let(:publishing_user) { FactoryBot.create(:user) }
    let(:project) { FactoryBot.create(:project) }
    let(:publish_target_1) do
      FactoryBot.create(:publish_target)
    end
    let(:publish_target_2) do
      FactoryBot.create(:publish_target)
    end

    let(:doi) { '10.abcd/4569' }
    let(:digital_object_without_publish_entries) { FactoryBot.create(:digital_object_test_subclass, doi: doi) }
    let(:digital_object_with_publish_entries) do
      obj = FactoryBot.create(:digital_object_test_subclass, doi: doi)
      obj.send(
        :publish_entries=,
        [
          PublishEntry.new(publish_target: publish_target_1, published_at: Time.current, published_by: publishing_user),
          PublishEntry.new(publish_target: publish_target_2, published_at: Time.current, published_by: publishing_user)
        ]
      )
      obj
    end
    let(:unpublish_promise_1) do
      Concurrent::Promise.new { publish_target_1 }.execute
    end
    let(:unpublish_promise_2) do
      Concurrent::Promise.new { publish_target_2 }.execute
    end
    context "object has publish entries" do
      let(:object) { digital_object_with_publish_entries }
      before do
        # pretend we were preserved 10 seconds ago
        object.preserved_at = DateTime.new.getlocal - 10
      end
      it "calls unpublish_from for all current publish_entries" do
        expect(digital_object_with_publish_entries).to receive(:unpublish_from).with(targets: digital_object_with_publish_entries.publish_targets.to_a)
        object.unpublish_from_all
      end
      it "calls async_unpublish for all current publish_entries and deactivates doi" do
        expect(object).to receive(:async_unpublish).and_return(unpublish_promise_1, unpublish_promise_2)
        expect(Hyacinth::Config.external_identifier_adapter).to receive(:deactivate).with(doi)
        object.unpublish_from_all
      end
    end

    context "object has publish entries" do
      let(:object) { digital_object_without_publish_entries }
      it "doesn't call unpublish_from internally when an object has no publish entries" do
        expect(object).not_to receive(:unpublish_from)
        object.unpublish_from_all
      end
    end
  end
end
