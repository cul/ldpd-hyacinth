# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DigitalObjectConcerns::DestroyBehavior, solr: true do
  let(:digital_object_with_sample_data) { FactoryBot.create(:digital_object_test_subclass, :with_sample_data) }

  context "#destroy" do
    context "successful run" do
      let(:destroying_user) { FactoryBot.create(:user) }
      let(:destroyed_digital_object) do
        digital_object_with_sample_data.destroy(user: destroying_user)
        digital_object_with_sample_data
      end

      it "returns true" do
        expect(digital_object_with_sample_data.destroy(user: destroying_user)).to be true
      end

      it "updates the state to indicate deletion" do
        expect(destroyed_digital_object.state).to eq(Hyacinth::DigitalObject::State::DELETED)
      end

      it "updates the updated_by property" do
        expect(destroyed_digital_object.updated_by).to eq(destroying_user)
      end

      context "updates the updated_at property" do
        let!(:previous_updated_at_date_time) { digital_object_with_sample_data.updated_at }
        it do
          expect(destroyed_digital_object.updated_at).not_to eq(previous_updated_at_date_time)
        end
      end

      it "runs the expected on_destroy callbacks" do
        expect(digital_object_with_sample_data).to receive(:remove_all_parents)
        expect(digital_object_with_sample_data).to receive(:unpublish_from_all)
        expect(digital_object_with_sample_data).to receive(:index)
        digital_object_with_sample_data.destroy
      end
    end
  end

  context "#undestroy" do
    context "successful run" do
      let(:destroying_user) { FactoryBot.create(:user) }
      let(:destroyed_digital_object) do
        digital_object_with_sample_data.destroy(user: destroying_user)
        digital_object_with_sample_data
      end
      let(:undestroying_user) { FactoryBot.create(:user, :basic) }
      let(:undestroyed_digital_object) do
        destroyed_digital_object.undestroy(user: undestroying_user)
        destroyed_digital_object
      end

      it "returns true" do
        expect(destroyed_digital_object.undestroy(user: undestroying_user)).to be true
      end

      it "updates the state to be active" do
        expect(undestroyed_digital_object.state).to eq(Hyacinth::DigitalObject::State::ACTIVE)
      end

      it "updates the updated_by property" do
        expect(undestroyed_digital_object.updated_by).to eq(undestroying_user)
      end

      context "updates the updated_at property" do
        let!(:previous_updated_at_date_time) { digital_object_with_sample_data.updated_at }
        it do
          expect(undestroyed_digital_object.updated_at).not_to eq(previous_updated_at_date_time)
        end
      end

      it "runs the expected on_undestroy callbacks" do
        expect(destroyed_digital_object).to receive(:index)
        destroyed_digital_object.undestroy
      end
    end
  end
end
