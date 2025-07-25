# -*- coding: utf-8 -*-
require 'rails_helper'

describe Hyacinth::Datacite::HyacinthMetadata do

  let(:dod) {
    data = JSON.parse( fixture('lib/hyacinth/datacite/hyacinth_item.json').read )
    data['identifiers'] = ['item.' + SecureRandom.uuid] # random identifer to avoid collisions
    data
  }

  let(:dod_empty_dfd) {
    data = JSON.parse( fixture('lib/hyacinth/datacite/hyacinth_item_empty_dynamic_field_data.json').read )
    data['identifiers'] = ['item.' + SecureRandom.uuid] # random identifer to avoid collisions
    data
  }
  
  let(:dod_names_without_roles) {
    data = JSON.parse( fixture('lib/hyacinth/datacite/hyacinth_item_names_without_roles.json').read )
    data['identifiers'] = ['item.' + SecureRandom.uuid] # random identifer to avoid collisions
    data
  }

  context "empty dynamic field data:" do
    it "title handles empty dynamic field data" do
      local_metadata_retrieval = described_class.new dod_empty_dfd
      expected_full_title = nil
      actual_full_title = local_metadata_retrieval.title
      expect(actual_full_title).to eq(expected_full_title)
    end

    it "abstract handles empty dynamic field data" do
      local_metadata_retrieval = described_class.new dod_empty_dfd
      expected_abstract = nil
      actual_abstract = local_metadata_retrieval.abstract
      expect(actual_abstract).to eq(expected_abstract)
    end

    it "type_of_resource handles empty dynamic field data" do
      local_metadata_retrieval = described_class.new dod_empty_dfd
      expected_type_of_resource = nil
      actual_type_of_resource = local_metadata_retrieval.type_of_resource
      expect(actual_type_of_resource).to eq(expected_type_of_resource)
    end

    it "genre_uri handles empty dynamic field data" do
      local_metadata_retrieval = described_class.new dod_empty_dfd
      expected_genre_uri = nil
      actual_genre_uri = local_metadata_retrieval.genre_uri
      expect(actual_genre_uri).to eq(expected_genre_uri)
    end

    it "date_issued_start_year handles empty dynamic field data" do
      local_metadata_retrieval = described_class.new dod_empty_dfd
      expected_date = nil
      actual_date = local_metadata_retrieval.date_issued_start_year
      expect(actual_date).to eq(expected_date)
    end

    it "parent_publication_issn handles empty dynamic field data" do
      local_metadata_retrieval = described_class.new dod_empty_dfd
      expected_issn = nil
      actual_issn = local_metadata_retrieval.parent_publication_issn
      expect(actual_issn).to eq(expected_issn)
    end

    it "parent_publication_isbn handles empty dynamic field data" do
      local_metadata_retrieval = described_class.new dod_empty_dfd
      expected_isbn = nil
      actual_isbn = local_metadata_retrieval.parent_publication_isbn
      expect(actual_isbn).to eq(expected_isbn)
    end

    it "parent_publication_doi handles empty dynamic field data" do
      local_metadata_retrieval = described_class.new dod_empty_dfd
      expected_doi = nil
      actual_doi = local_metadata_retrieval.parent_publication_doi
      expect(actual_doi).to eq(expected_doi)
    end

    it "doi_identifier handles empty dynamic field data" do
      local_metadata_retrieval = described_class.new dod_empty_dfd
      expected_doi_identifier = nil
      actual_doi_identifier = local_metadata_retrieval.doi_identifier
      expect(actual_doi_identifier).to eq(expected_doi_identifier)
    end

    it "handle_net_identifier handles empty dynamic field data" do
      local_metadata_retrieval = described_class.new dod_empty_dfd
      expected_handle_net_identifier = nil
      actual_handle_net_identifier = local_metadata_retrieval.handle_net_identifier
      expect(actual_handle_net_identifier).to eq(expected_handle_net_identifier)
    end

    it "subjects_topic handles empty dynamic field data" do
      local_metadata_retrieval = described_class.new dod_empty_dfd
      expected_subjects_topic = []
      actual_subjects_topic = local_metadata_retrieval.subjects_topic
      expect(actual_subjects_topic).to eq(expected_subjects_topic)
    end

    it "date_created handles empty dynamic field data" do
      local_metadata_retrieval = described_class.new dod_empty_dfd
      expected_date_created = '2015-02-04'
      actual_date_created = local_metadata_retrieval.date_created
      expect(actual_date_created).to eq(expected_date_created)
    end

    it "date_modified handles empty dynamic field data" do
      local_metadata_retrieval = described_class.new dod_empty_dfd
      expected_date_modified = '2016-03-31'
      actual_date_modified = local_metadata_retrieval.date_modified
      expect(actual_date_modified).to eq(expected_date_modified)
    end

    it "creators handles empty dynamic field data" do
      local_metadata_retrieval = described_class.new dod_empty_dfd
      expected_creators = []
      expect(local_metadata_retrieval.creators).to eq(expected_creators)
    end

    it "editors handles empty dynamic field data" do
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

  context "#related_item?:" do
    it "returns true if related item present" do
      local_metadata_retrieval = described_class.new dod
      result = local_metadata_retrieval.related_item?
      expect(result).to be true
    end

    it "returns false if no related item present" do
      local_metadata_retrieval = described_class.new dod_names_without_roles
      result = local_metadata_retrieval.related_item?
      expect(result).to be false
    end
  end

  context "#num_related_items:" do
    it "returns 2 if 2 related item present" do
      local_metadata_retrieval = described_class.new dod
      result = local_metadata_retrieval.num_related_items
      expect(result).to eq(2)
    end

    it "returns 0 if no related item present" do
      local_metadata_retrieval = described_class.new dod_names_without_roles
      result = local_metadata_retrieval.num_related_items
      expect(result).to eq(0)
    end
  end

  context "#related_item_title:" do
    it "gets the title for the first related item" do
      local_metadata_retrieval = described_class.new dod
      expected_related_item_title = 'The Related Item Sample Title'
      actual_related_item_title = local_metadata_retrieval.related_item_title(0)
      expect(actual_related_item_title).to eq(expected_related_item_title)
    end

    it "gets the title for the second related item" do
      local_metadata_retrieval = described_class.new dod
      expected_related_item_title = 'Those Are the Terms'
      actual_related_item_title = local_metadata_retrieval.related_item_title(1)
      expect(actual_related_item_title).to eq(expected_related_item_title)
    end
  end

  context "#related_item_type_of_resource:" do
    it "gets the resource type for first related item (controlled vocabulary)" do
      local_metadata_retrieval = described_class.new dod
      actual_related_item_resource_type =
        local_metadata_retrieval.related_item_type_of_resource(0)
      expect(actual_related_item_resource_type).to have_attributes(
                                                     uri: "http://id.library.columbia.edu/term/f44c5847",
                                                     value: "Image",
                                                     type: "local",
                                                     authority: "datacite"
                                                   )
    end

    it "gets the resource type for the second related item (controlled vocabulary)" do
      local_metadata_retrieval = described_class.new dod
      actual_related_item_resource_type =
        local_metadata_retrieval.related_item_type_of_resource(1)
      expect(actual_related_item_resource_type).to have_attributes(
                                                     uri: "http://id.library.columbia.edu/term/201aa69a",
                                                     value: "Model",
                                                     type: "local",
                                                     authority: "datacite"
                                                   )
    end
  end

  context "#related_item_relation_type:" do
    it "gets the relation type for first related item (controlled vocabulary)" do
      local_metadata_retrieval = described_class.new dod
      actual_related_item_relation_type =
        local_metadata_retrieval.related_item_relation_type(0)
      expect(actual_related_item_relation_type).to have_attributes(
                                                     uri: "temp:0cd2d4169ded",
                                                     value: "IsCompiledBy",
                                                     type: "temporary",
                                                     authority: "datacite"
                                                   )
    end

    it "gets the relation type for the second related item (controlled vocabulary)" do
      local_metadata_retrieval = described_class.new dod
      actual_related_item_relation_type =
        local_metadata_retrieval.related_item_relation_type(1)
      expect(actual_related_item_relation_type).to have_attributes(
                                                     uri: "temp:a6621364715d73",
                                                     value: "isVersionOf",
                                                     type: "temporary",
                                                     authority: "datacite"
                                                   )
    end
  end

  context "#related_item_identifier_doi:" do
    it "gets the related item doi identifier for the related item" do
      local_metadata_retrieval = described_class.new dod
      actual_identifier_doi = local_metadata_retrieval.related_item_identifier_doi(0)
        expect(actual_identifier_doi).to eq("10.33555/4363-BZ18")
    end
  end

  context "#related_item_identifier_url" do
    it "gets the related item url identifier for the related item" do
      local_metadata_retrieval = described_class.new dod
      actual_identifier_url = local_metadata_retrieval.related_item_identifier_url(0)
        expect(actual_identifier_url).to eq("https://www.columbia.edu")
    end
  end

  context "#related_item_identifier_first" do
    it "gets the first related item identifier for the related item" do
      local_metadata_retrieval = described_class.new dod
      expected_first_identifier = ['isbn', '000-0-00-000000-0']
      actual_identifier_first = local_metadata_retrieval.related_item_identifier_first(0)
        expect(actual_identifier_first).to eq(expected_first_identifier)
    end
  end

  context "#related_item_identifiers:" do
    it "gets the related item identifiers for the first related item" do
      local_metadata_retrieval = described_class.new dod
      actual_identifiers =
        local_metadata_retrieval.related_item_identifiers(0)
      expect(actual_identifiers.first[0]).to eq("isbn")
      expect(actual_identifiers.first[1]).to eq("000-0-00-000000-0")
      expect(actual_identifiers.second[0]).to eq("issn")
      expect(actual_identifiers.second[1]).to eq("0000-0000")
      expect(actual_identifiers.third[0]).to eq("url")
      expect(actual_identifiers.third[1]).to eq("https://www.columbia.edu")
      expect(actual_identifiers.fourth[0]).to eq("doi")
      expect(actual_identifiers.fourth[1]).to eq("10.33555/4363-BZ18")
    end

    it "gets the related item identifiers for the second related item" do
      local_metadata_retrieval = described_class.new dod
      actual_identifiers =
        local_metadata_retrieval.related_item_identifiers(1)
      expect(actual_identifiers.first[0]).to eq("url")
      expect(actual_identifiers.first[1]).to eq("https://medhealthhum.com/those-are-the-terms/")
    end
  end

  context "#license:" do
    it "gets the license (controlled vocabulary)" do
      local_metadata_retrieval = described_class.new dod
      actual_license =
        local_metadata_retrieval.license
      expect(actual_license).to have_attributes(
                                  uri: "https://creativecommons.org/licenses/by-nc-sa/4.0/",
                                  value: "CC BY-NC-SA 4.0",
                                  type: "external",
                                  authority: "creativecommons"
                                )
    end
  end

  context "#license_info:" do
    it "gets the license info (controlled vocabulary) for 2 licenses" do
      local_metadata_retrieval = described_class.new dod
      actual_licenses =
        local_metadata_retrieval.license_info
      expect(actual_licenses.first).to have_attributes(
                                         uri: "https://creativecommons.org/licenses/by-nc-sa/4.0/",
                                         value: "CC BY-NC-SA 4.0",
                                         type: "external",
                                         authority: "creativecommons"
                                       )
      expect(actual_licenses.second).to have_attributes(
                                          uri: "https://creativecommons.org/publicdomain/zero/1.0/",
                                          value: "CC0 1.0",
                                          type: "external",
                                          authority: "creativecommons"
                                        )
    end
  end

  context "#use_and_reproduction:" do
    it "gets the use_and_reproduction (controlled vocabulary)" do
      local_metadata_retrieval = described_class.new dod
      actual_use_and_reprod =
        local_metadata_retrieval.use_and_reproduction
      expect(actual_use_and_reprod).to have_attributes(
                                         uri: "http://rightsstatements.org/vocab/NoC-US/1.0/",
                                         value: "No Copyright - United States",
                                         type: "external",
                                         authority: "rightsstatements"
                                       )
    end
  end

  context "#use_and_reproduction_info:" do
    it "gets the use_and_reproduction info (controlled vocabulary)" do
      local_metadata_retrieval = described_class.new dod
      actual_use_and_reprod_info =
        local_metadata_retrieval.use_and_reproduction_info
      expect(actual_use_and_reprod_info.first).to have_attributes(
                                                    uri: "http://rightsstatements.org/vocab/NoC-US/1.0/",
                                                    value: "No Copyright - United States",
                                                    type: "external",
                                                    authority: "rightsstatements"
                                                  )
      expect(actual_use_and_reprod_info.second).to have_attributes(
                                                     uri: "http://rightsstatements.org/vocab/NKC/1.0/",
                                                     value: "No Known Copyright",
                                                     type: "external",
                                                     authority: "rightsstatements"
                                                   )
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

  context "#doi_identifier" do
    let(:doi) { '10.1371/journal.pone.0119638' }
    it "doi_identifier" do
      obj = DigitalObject::Item.new
      obj.doi = doi
      local_metadata_retrieval = described_class.new obj.as_json
      actual_doi_identifier = local_metadata_retrieval.doi_identifier
      expect(actual_doi_identifier).to eq(doi)
    end
  end

  context "#handle_net_identifier" do
    it "handle_net_identifier" do
      local_metadata_retrieval = described_class.new dod
      expected_handle_net_identifier = 'http://hdl.handle.net/10022/AC:P:29183'
      actual_handle_net_identifier = local_metadata_retrieval.handle_net_identifier
      expect(actual_handle_net_identifier).to eq(expected_handle_net_identifier)
    end
  end

  context "#subject_topic:" do
    it "subject_topic" do
      local_metadata_retrieval = described_class.new dod
      expected_subjects_topic = ['Educational attainment','Parental influences','Mother and child--Psychological aspects']
      actual_subjects_topic = local_metadata_retrieval.subjects_topic
      expect(actual_subjects_topic).to eq(expected_subjects_topic)
    end
  end

  context "#date_created:" do
    it "date_created" do
      local_metadata_retrieval = described_class.new dod
      expected_date_created = '2015-02-04'
      actual_date_created = local_metadata_retrieval.date_created
      expect(actual_date_created).to eq(expected_date_created)
    end
  end

  context "#date_modified:" do
    it "date_modified" do
      local_metadata_retrieval = described_class.new dod
      expected_date_modified = '2016-03-31'
      actual_date_modified = local_metadata_retrieval.date_modified
      expect(actual_date_modified).to eq(expected_date_modified)
    end
  end

  context "#process_names works:" do
    it "creators set" do
      local_metadata_retrieval = described_class.new dod
      expected_creators = ['Salinger, J. D.','Lincoln, Abraham']
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
