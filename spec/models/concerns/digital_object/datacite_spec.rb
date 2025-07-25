require 'rails_helper'
require 'equivalent-xml'

describe DigitalObject::Datacite do

  let(:test_class) do
    _c = Class.new
    _c.send :include, DigitalObject::Datacite
  end

  let(:digital_object) do
    test_do = test_class.new 
    data = JSON.parse( fixture('lib/hyacinth/ezid/ezid_item.json').read )
    expect(data).to have_key('dynamic_field_data')
    data['identifiers'] = ['item.' + SecureRandom.uuid] # random identifer to avoid collisions
    test_do.instance_variable_set(:@digital_object_data, data)
    allow(test_do).to receive(:as_json).and_return(data)
    test_do.instance_variable_set(:@fedora_object,
                              ContentAggregator.new(pid: 'test:existingobject'))
    test_do
  end

  context "#mint_and_store_doi:" do
    it "mint_and_store_doi" do
      # stub out method wrapping API call to DataCite server, stub return Doi instance
      allow_any_instance_of(Hyacinth::Datacite::ApiSession).to receive(:mint_identifier) do
        Hyacinth::Datacite::Doi.new('10.33555/5x55-t644')
      end
      DATACITE[:user] = DATACITE[:datacite_test_user]
      DATACITE[:password] = DATACITE[:datacite_test_password]
      DATACITE[:prefix] = DATACITE[:test_prefix]
      actual_datacite_doi = digital_object.mint_and_store_doi(Hyacinth::Datacite::Doi::IDENTIFIER_STATUS[:draft],
                                                              'http://www.columbia.edu')
      expect(actual_datacite_doi).to eq('10.33555/5x55-t644')
      end
  end

  context "#mint_and_store_doi:" do
    it "raise exception if @doi already exists" do
      DATACITE[:user] = DATACITE[:datacite_test_user]
      DATACITE[:password] = DATACITE[:datacite_test_password]
      DATACITE[:prefix] = DATACITE[:test_prefix]
      digital_object.instance_variable_set(:@doi,
                                           '10.33555/5x55-t644')
      expect do
        digital_object.mint_and_store_doi(Hyacinth::Datacite::Doi::IDENTIFIER_STATUS[:draft],
                                          'http://www.columbia.edu')
      end.to raise_error(/DOI already exists, minting aborted/)
    end
  end

  context "change_doi_status_to_unavailable:" do
    it "raise exception if @doi does not exists" do
      DATACITE[:user] = DATACITE[:datacite_test_user]
      DATACITE[:password] = DATACITE[:datacite_test_password]
      DATACITE[:prefix] = DATACITE[:test_prefix]
      expect do
        digital_object.change_doi_status_to_unavailable
      end.to raise_error(/doi is not present on digital object/)
    end
  end

  context "update_doi_metadata:" do
    it "raise exception if @doi does not exists" do
      DATACITE[:user] = DATACITE[:datacite_test_user]
      DATACITE[:password] = DATACITE[:datacite_test_password]
      DATACITE[:prefix] = DATACITE[:test_prefix]
      expect do
        digital_object.update_doi_metadata
      end.to raise_error(/doi is not present on digital object/)
    end
  end

  context "update_doi_target_url:" do
    it "raise exception if @doi does not exists" do
      DATACITE[:user] = DATACITE[:datacite_test_user]
      DATACITE[:password] = DATACITE[:datacite_test_password]
      DATACITE[:prefix] = DATACITE[:test_prefix]
      expect do
        digital_object.update_doi_target_url 'http://www.columbia.edu'
      end.to raise_error(/doi is not present on digital object/)
    end
  end

  context "#change_doi_status_to_unavailable:" do
    it "change_doi_status_to_unavailable" do
      # stub out method wrapping API call to DataCite server, stub returns true (success)
      allow_any_instance_of(Hyacinth::Datacite::ApiSession).to receive(:modify_identifier) { true }
      DATACITE[:user] = DATACITE[:datacite_test_user]
      DATACITE[:password] = DATACITE[:datacite_test_password]
      DATACITE[:prefix] = DATACITE[:test_prefix]
      digital_object.instance_variable_set(:@doi,
                                           'doi:10.5072/FK2F47P06D')
      actual_return_value = digital_object.change_doi_status_to_unavailable
      expect(actual_return_value).to eq(true)
    end
  end

  context "#update_doi_metadata:" do
    it "updates the metadata" do
      # stub out method wrapping API call to DataCite server, stub returns true (success)
      allow_any_instance_of(Hyacinth::Datacite::ApiSession).to receive(:modify_identifier) { true }
      DATACITE[:user] = DATACITE[:datacite_test_user]
      DATACITE[:password] = DATACITE[:datacite_test_password]
      DATACITE[:prefix] = DATACITE[:test_prefix]
      digital_object.instance_variable_set(:@doi,
                                           '10.33555/5x55-t644')
      actual_return_value = digital_object.update_doi_metadata
      expect(actual_return_value).to eq(true)
    end
  end

  context "#update_doi_target_url:" do
    it "updates the target url" do
      # stub out method wrapping API call to DataCite server, stub returns true (success)
      allow_any_instance_of(Hyacinth::Datacite::ApiSession).to receive(:modify_identifier) { true }
      DATACITE[:user] = DATACITE[:datacite_test_user]
      DATACITE[:password] = DATACITE[:datacite_test_password]
      DATACITE[:prefix] = DATACITE[:test_prefix]
      digital_object.instance_variable_set(:@doi,
                                           '10.33555/5x55-t644')
      actual_return_value = digital_object.update_doi_target_url('http://www.columbia.edu')
      expect(actual_return_value).to eq(true)
    end
  end
end
