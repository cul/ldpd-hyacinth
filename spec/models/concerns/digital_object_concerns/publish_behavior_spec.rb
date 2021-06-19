# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DigitalObjectConcerns::PublishBehavior, solr: true do
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

  context "#unpublish_from_all" do
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
