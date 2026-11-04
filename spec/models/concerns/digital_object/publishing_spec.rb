require 'rails_helper'

describe DigitalObject::Publishing do
  let(:publish_target_attributes) { { publish_url: 'http://localhost/publish', api_key: 'test_api_key' } }
  let(:pubtarget_a) { PublishTarget.create!(publish_target_attributes.merge(string_key: 'publishing_spec_a', display_label: 'Publish Target A')) }
  let(:pubtarget_b) { PublishTarget.create!(publish_target_attributes.merge(string_key: 'publishing_spec_b', display_label: 'Publish Target B')) }
  let(:pubtarget_c) { PublishTarget.create!(publish_target_attributes.merge(string_key: 'publishing_spec_c', display_label: 'Publish Target C')) }

  let(:digital_object) {
    DigitalObject::Item.new.tap do |obj|
      obj.db_record.update!(pid: 'publishing_spec:1')
      allow(obj).to receive(:before_publish).and_return(true)
      allow(obj).to receive(:fedora_object).and_return(double(save: true))
      allow(obj).to receive(:update_index)
    end
  }

  # Tests don't run in transactions so we have to clean up any records created here
  after do
    DigitalObjectRecord.where(pid: 'publishing_spec:1').destroy_all
    PublishTarget.where('string_key LIKE ?', 'publishing_spec_%').destroy_all
  end

  def add_publication(publish_target, status)
    digital_object.db_record.publications.create!(publish_target: publish_target, status: status)
  end

  describe '#publish' do
    subject(:publish) { digital_object.publish }

    before do
      digital_object.publish_target_string_keys = [pubtarget_a.string_key]
    end

    it 'publishes to selected targets' do
      expect(digital_object).to receive(:execute_publish_action_for_target).with(:publish, pubtarget_a)
      publish
    end

    it 'unpublishes from deselected targets that may still be published' do
      add_publication(pubtarget_b, :published)
      add_publication(pubtarget_c, :unpublish_pending)
      expect(digital_object).to receive(:execute_publish_action_for_target).with(:unpublish, pubtarget_b)
      expect(digital_object).to receive(:execute_publish_action_for_target).with(:unpublish, pubtarget_c)
      expect(digital_object).to receive(:execute_publish_action_for_target).with(:publish, pubtarget_a)
      publish
    end

    it 'does not unpublish from deselected targets that are already unpublished' do
      add_publication(pubtarget_b, :unpublished)
      expect(digital_object).not_to receive(:execute_publish_action_for_target).with(:unpublish, pubtarget_b)
      expect(digital_object).to receive(:execute_publish_action_for_target).with(:publish, pubtarget_a)
      publish
    end

    it 'updates the DOI with the location returned by the selected target with the highest DOI priority' do
      pubtarget_a.update!(doi_priority: 2)
      pubtarget_b.update!(doi_priority: 1)
      digital_object.publish_target_string_keys = [pubtarget_a.string_key, pubtarget_b.string_key]
      allow(digital_object).to receive(:execute_publish_action_for_target).with(:publish, pubtarget_a).and_return(double(headers: { location: 'http://localhost/a/item' }))
      allow(digital_object).to receive(:execute_publish_action_for_target).with(:publish, pubtarget_b).and_return(double(headers: { location: 'http://localhost/b/item' }))
      expect(digital_object).to receive(:update_doi_metadata).with('http://localhost/b/item')
      publish
    end

    it 'makes the DOI unavailable after unpublishing from a DOI target when no other DOI target is selected' do
      pubtarget_b.update!(doi_priority: 1)
      add_publication(pubtarget_b, :published)
      digital_object.doi = 'doi:10.33555/abcd-1234'
      allow(digital_object).to receive(:execute_publish_action_for_target).with(:unpublish, pubtarget_b).and_return(double(code: 200))
      allow(digital_object).to receive(:execute_publish_action_for_target).with(:publish, pubtarget_a)
      expect(digital_object).to receive(:change_doi_status_to_unavailable)
      publish
    end
  end

  describe '#unpublish_all' do
    subject(:unpublish_all) { digital_object.unpublish_all }

    it 'unpublishes from all targets that the object may still be published to' do
      digital_object.publish_target_string_keys = [pubtarget_a.string_key, pubtarget_b.string_key]
      add_publication(pubtarget_a, :published)
      add_publication(pubtarget_b, :publish_pending)
      add_publication(pubtarget_c, :unpublished)
      expect(digital_object).to receive(:execute_publish_action_for_target).with(:unpublish, pubtarget_a)
      expect(digital_object).to receive(:execute_publish_action_for_target).with(:unpublish, pubtarget_b)
      expect(digital_object).not_to receive(:execute_publish_action_for_target).with(:unpublish, pubtarget_c)
      unpublish_all
      expect(digital_object.publish_target_string_keys).to be_blank
    end
  end

  describe '#execute_publish_action_for_target' do
    let(:success_response) { double(code: 200) }
    let(:publication) { digital_object.db_record.publications.find_by(publish_target: pubtarget_a) }

    context 'when publishing succeeds' do
      before do
        allow(pubtarget_a).to receive(:publish_digital_object).and_return(success_response)
      end

      it 'returns the response and marks the publication as published' do
        expect(digital_object.execute_publish_action_for_target(:publish, pubtarget_a)).to eq(success_response)
        expect(publication).to be_published
        expect(digital_object.errors).to be_empty
      end

      it 'clears the error message left by a previous failed attempt' do
        add_publication(pubtarget_a, :publish_pending).update!(error_message: 'Previous error')
        digital_object.execute_publish_action_for_target(:publish, pubtarget_a)
        expect(publication).to be_published
        expect(publication.error_message).to be_nil
      end
    end

    context 'when publishing fails' do
      before do
        allow(pubtarget_a).to receive(:publish_digital_object).and_raise(RestClient::InternalServerError)
      end

      it 'returns nil, leaves the publication pending and records the error' do
        expect(digital_object.execute_publish_action_for_target(:publish, pubtarget_a)).to be_nil
        expect(publication).to be_publish_pending
        expect(publication.error_message).to be_present
        expect(digital_object.errors[:publish_target]).to eq([publication.error_message])
      end
    end

    context 'when unpublishing succeeds' do
      before do
        allow(pubtarget_a).to receive(:unpublish_digital_object).and_return(success_response)
      end

      it 'returns the response and marks the publication as unpublished' do
        expect(digital_object.execute_publish_action_for_target(:unpublish, pubtarget_a)).to eq(success_response)
        expect(publication).to be_unpublished
        expect(digital_object.errors).to be_empty
      end
    end

    context 'when the publish target cannot be reached' do
      before do
        allow(pubtarget_a).to receive(:unpublish_digital_object).and_raise(Errno::ECONNREFUSED)
      end

      it 'returns nil, leaves the publication pending and records the error' do
        expect(digital_object.execute_publish_action_for_target(:unpublish, pubtarget_a)).to be_nil
        expect(publication).to be_unpublish_pending
        expect(publication.error_message).to include('Connection to server refused')
        expect(digital_object.errors[:publish_target]).to eq([publication.error_message])
      end
    end
  end
end
