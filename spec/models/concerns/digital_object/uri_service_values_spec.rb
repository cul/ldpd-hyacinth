require 'rails_helper'
require 'equivalent-xml'

describe DigitalObject::UriServiceValues do

  let(:test_class) do
    Class.new { include DigitalObject::UriServiceValues }
  end

  let(:digital_object) do
    test_class.new
  end

  describe "#create_term" do
    let(:controlled_vocabulary_string_key) { "uri_service_values_spec" }
    let(:controlled_vocabulary_display_label) { "Uri Service Values Spec" }
    let(:controlled_vocabulary) { FactoryBot.create(:controlled_vocabulary, string_key: controlled_vocabulary_string_key) }
    let(:created_term) { digital_object.create_term(term_type, term_data) }
    let(:term_value) { "Test Term Value" }
    let(:uri_service_client) { double(UriService::Client) }
    let(:uri_service_props) { { display_label: controlled_vocabulary_display_label } }

    before do
      allow(UriService).to receive(:client).and_return(uri_service_client)
      allow(uri_service_client).to receive(:create_term)
      allow(uri_service_client).to receive(:find_vocabulary).with(controlled_vocabulary_string_key).and_return(uri_service_props)
    end

    context "when receives data for a temp term" do
      let(:term_data) { { value: term_value, vocabulary_string_key: controlled_vocabulary_string_key } }
      let(:term_type) { UriService::TermType::TEMPORARY }

      it "requests the URI service client to create the term" do
        allow(uri_service_client).to receive(:find_vocabulary).with(controlled_vocabulary_string_key)
        expect(uri_service_client).to receive(:create_term)
        digital_object.create_term(term_type, term_data)
      end

      context "and vocabulary prohibits temp terms" do
        let(:controlled_vocabulary_string_key) { "uri_service_values_spec_no_temp" }
        let(:controlled_vocabulary) { FactoryBot.create(:controlled_vocabulary, :prohibit_temp_terms, string_key: controlled_vocabulary_string_key) }

        it "raises an error and does not create term" do
          expect(controlled_vocabulary.prohibit_temp_terms).to be true
          expect(uri_service_client).not_to receive(:create_term)
          expect { digital_object.create_term(term_type, term_data) }.to raise_error(/vocabulary does not allow temp terms/)
        end
      end
    end
  end
end
