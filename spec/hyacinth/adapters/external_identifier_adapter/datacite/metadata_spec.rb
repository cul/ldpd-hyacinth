# -*- coding: utf-8 -*-
# frozen_string_literal: true

require 'rails_helper'

describe Hyacinth::Adapters::ExternalIdentifierAdapter::Datacite::Metadata do
  let(:dod) do
    data = JSON.parse(file_fixture('files/datacite/ezid_item.json').read)
    data['identifiers'] = ['item.' + SecureRandom.uuid] # random identifier to avoid collisions
    data
  end

  let(:dod_empty_dfd) do
    data = JSON.parse(file_fixture('files/datacite/ezid_item_empty_descriptive_metadata.json').read)
    data['identifiers'] = ['item.' + SecureRandom.uuid] # random identifier to avoid collisions
    data
  end

  let(:dod_names_without_roles) do
    data = JSON.parse(file_fixture('files/datacite/ezid_item_names_without_roles.json').read)
    data['identifiers'] = ['item.' + SecureRandom.uuid] # random identifier to avoid collisions
    data
  end

  context "empty descriptive metadata:" do
    it "title handles empty descriptive metadata" do
      local_metadata_retrieval = described_class.new dod_empty_dfd
      expected_full_title = nil
      actual_full_title = local_metadata_retrieval.title
      expect(actual_full_title).to eq(expected_full_title)
    end

    it "abstract handles empty descriptive metadata" do
      local_metadata_retrieval = described_class.new dod_empty_dfd
      expected_abstract = nil
      actual_abstract = local_metadata_retrieval.abstract
      expect(actual_abstract).to eq(expected_abstract)
    end

    it "type_of_resource handles empty descriptive metadata" do
      local_metadata_retrieval = described_class.new dod_empty_dfd
      expected_type_of_resource = nil
      actual_type_of_resource = local_metadata_retrieval.type_of_resource
      expect(actual_type_of_resource).to eq(expected_type_of_resource)
    end

    it "genre_uri handles empty descriptive metadata" do
      local_metadata_retrieval = described_class.new dod_empty_dfd
      expected_genre_uri = nil
      actual_genre_uri = local_metadata_retrieval.genre_uri
      expect(actual_genre_uri).to eq(expected_genre_uri)
    end

    it "date_issued_start_year handles empty descriptive metadata" do
      local_metadata_retrieval = described_class.new dod_empty_dfd
      expected_date = nil
      actual_date = local_metadata_retrieval.date_issued_start_year
      expect(actual_date).to eq(expected_date)
    end

    it "parent_publication_issn handles empty descriptive metadata" do
      local_metadata_retrieval = described_class.new dod_empty_dfd
      expected_issn = nil
      actual_issn = local_metadata_retrieval.parent_publication_issn
      expect(actual_issn).to eq(expected_issn)
    end

    it "parent_publication_isbn handles empty descriptive metadata" do
      local_metadata_retrieval = described_class.new dod_empty_dfd
      expected_isbn = nil
      actual_isbn = local_metadata_retrieval.parent_publication_isbn
      expect(actual_isbn).to eq(expected_isbn)
    end

    it "parent_publication_doi handles empty descriptive metadata" do
      local_metadata_retrieval = described_class.new dod_empty_dfd
      expected_doi = nil
      actual_doi = local_metadata_retrieval.parent_publication_doi
      expect(actual_doi).to eq(expected_doi)
    end

    it "doi handles empty descriptive metadata" do
      local_metadata_retrieval = described_class.new dod_empty_dfd
      expected_doi = nil
      actual_doi = local_metadata_retrieval.doi
      expect(actual_doi).to eq(expected_doi)
    end

    it "handle_net_identifier handles empty descriptive metadata" do
      local_metadata_retrieval = described_class.new dod_empty_dfd
      expected_handle_net_identifier = nil
      actual_handle_net_identifier = local_metadata_retrieval.handle_net_identifier
      expect(actual_handle_net_identifier).to eq(expected_handle_net_identifier)
    end

    it "subjects_topic handles empty descriptive metadata" do
      local_metadata_retrieval = described_class.new dod_empty_dfd
      expected_subjects_topic = []
      actual_subjects_topic = local_metadata_retrieval.subject_topics
      expect(actual_subjects_topic).to eq(expected_subjects_topic)
    end

    it "date_created handles empty descriptive metadata" do
      local_metadata_retrieval = described_class.new dod_empty_dfd
      expected_date_created = '2015-02-04'
      actual_date_created = local_metadata_retrieval.date_created
      expect(actual_date_created).to eq(expected_date_created)
    end

    it "date_modified handles empty descriptive metadata" do
      local_metadata_retrieval = described_class.new dod_empty_dfd
      expected_date_modified = '2016-03-31'
      actual_date_modified = local_metadata_retrieval.date_modified
      expect(actual_date_modified).to eq(expected_date_modified)
    end

    it "creators handles empty descriptive metadata" do
      local_metadata_retrieval = described_class.new dod_empty_dfd
      expected_creators = []
      expect(local_metadata_retrieval.creators).to eq(expected_creators)
    end

    it "editors handles empty descriptive metadata" do
      local_metadata_retrieval = described_class.new dod_empty_dfd
      expected_editors = []
      expect(local_metadata_retrieval.editors).to eq(expected_editors)
    end
  end

  context "#title:" do
    it "get title" do
      local_metadata_retrieval = described_class.new dod
      expected_full_title = 'The Catcher in the Rye'
      actual_full_title = local_metadata_retrieval.title
      expect(actual_full_title).to eq(expected_full_title)
    end
  end

  context "#abstract:" do
    it "abstract" do
      local_metadata_retrieval = described_class.new dod
      expected_abstract = 'This is an abstract; yes, a very nice abstract'
      actual_abstract = local_metadata_retrieval.abstract
      expect(actual_abstract).to eq(expected_abstract)
    end
  end

  context "#type_of_resource:" do
    it "type_of_resource" do
      local_metadata_retrieval = described_class.new dod
      expected_type_of_resource = 'Image'
      actual_type_of_resource = local_metadata_retrieval.type_of_resource
      expect(actual_type_of_resource).to eq(expected_type_of_resource)
    end
  end

  context "#genre_uri:" do
    it "genre_uri" do
      local_metadata_retrieval = described_class.new dod
      expected_genre_uri = 'http://vocab.getty.edu/aat/300048715'
      actual_genre_uri = local_metadata_retrieval.genre_uri
      expect(actual_genre_uri).to eq(expected_genre_uri)
    end
  end

  context "#date_issued_start_year:" do
    it "date_issued_start_year" do
      local_metadata_retrieval = described_class.new dod
      expected_date = '1951'
      actual_date = local_metadata_retrieval.date_issued_start_year
      expect(actual_date).to eq(expected_date)
    end
  end

  context "#parent_publication_issn:" do
    it "parent_publication_issn" do
      local_metadata_retrieval = described_class.new dod
      expected_issn = '1932-6203'
      actual_issn = local_metadata_retrieval.parent_publication_issn
      expect(actual_issn).to eq(expected_issn)
    end
  end

  context "#parent_publication_isbn:" do
    it "parent_publication_isbn" do
      local_metadata_retrieval = described_class.new dod
      expected_isbn = '0670734608'
      actual_isbn = local_metadata_retrieval.parent_publication_isbn
      expect(actual_isbn).to eq(expected_isbn)
    end
  end

  context "#parent_publication_doi:" do
    it "parent_publication_doi" do
      local_metadata_retrieval = described_class.new dod
      expected_doi = '10.1371/journal.pone.0119638'
      actual_doi = local_metadata_retrieval.parent_publication_doi
      expect(actual_doi).to eq(expected_doi)
    end
  end

  context "#doi" do
    let(:expected) { '10.1371/article.pone.0119638' }
    it "doi" do
      local_metadata_retrieval = described_class.new dod
      actual = local_metadata_retrieval.doi
      expect(actual).to eq(expected)
    end
  end

  context "#handle_net_identifier" do
    let(:expected) { 'http://hdl.handle.net/10022/AC:P:29183' }
    it "handle_net_identifier" do
      local_metadata_retrieval = described_class.new dod
      actual = local_metadata_retrieval.handle_net_identifier
      expect(actual).to eq(expected)
    end
  end

  context "#subject_topics:" do
    let(:expected) do
      ['Educational attainment', 'Parental influences', 'Mother and child--Psychological aspects']
    end
    it "subject_topics" do
      local_metadata_retrieval = described_class.new dod
      actual = local_metadata_retrieval.subject_topics
      expect(actual).to eq(expected)
    end
  end

  context "#date_created:" do
    let(:expected) { '2015-02-04' }
    it "date_created" do
      local_metadata_retrieval = described_class.new dod
      actual = local_metadata_retrieval.date_created
      expect(actual).to eq(expected)
    end
  end

  context "#date_modified:" do
    let(:expected) { '2016-03-31' }
    it "date_modified" do
      local_metadata_retrieval = described_class.new dod
      actual = local_metadata_retrieval.date_modified
      expect(actual).to eq(expected)
    end
  end

  context "#process_names works:" do
    it "creators set" do
      local_metadata_retrieval = described_class.new dod
      expected_creators = ['Salinger, J. D.', 'Lincoln, Abraham']
      expect(local_metadata_retrieval.creators).to eq(expected_creators)
    end

    it "editors set" do
      local_metadata_retrieval = described_class.new dod
      expected_editors = ['Lincoln, Abraham']
      expect(local_metadata_retrieval.editors).to eq(expected_editors)
    end

    it "moderator set" do
      local_metadata_retrieval = described_class.new dod
      expected_moderators = ['Christie, Agatha']
      expect(local_metadata_retrieval.moderators).to eq(expected_moderators)
    end

    it "contributors set" do
      local_metadata_retrieval = described_class.new dod
      expected_contributors = ['Burton, Tim']
      expect(local_metadata_retrieval.contributors).to eq(expected_contributors)
    end

    context "names without roles" do
      it "contributors set when name has no role" do
        local_metadata_retrieval = described_class.new dod_names_without_roles
        expected_contributors = ['Salinger, J. D.', 'Lincoln, Abraham']
        expect(local_metadata_retrieval.contributors).to eq(expected_contributors)
      end
    end
  end
end
