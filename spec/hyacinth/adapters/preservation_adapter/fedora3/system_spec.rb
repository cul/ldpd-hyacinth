# frozen_string_literal: true

require 'rails_helper'

describe Hyacinth::Adapters::PreservationAdapter::Fedora3, fedora: true do
  let(:object_pid) { "test:1" }
  let(:location_uri) { "fedora3://" + object_pid }
  let(:pid_generator) { instance_double(PidGenerator) }
  let(:resource_dsid_overrides) { { 'master' => 'content', 'main' => 'content' } }
  let(:rubydora_config) { Rails.application.config_for(:fedora) }
  let(:adapter_args) { rubydora_config.merge(pid_generator: pid_generator, resource_dsid_overrides: resource_dsid_overrides) }

  let(:adapter) do
    described_class.new(adapter_args)
  end
  let(:dc_xml_src) { file_fixture("fedora3/update-dc.xml").read }

  before :all do
    Rubydora.repository = Rubydora.connect(Rails.application.config_for(:fedora))
  end

  before do
    # create the test object
    Rubydora::DigitalObject.create(object_pid)
  end
  after do
    # destroy the test object
    Rubydora::DigitalObject.new(object_pid).delete
  end

  describe "#location_uri_to_fedora3_pid" do
    subject { adapter.location_uri_to_fedora3_pid(location_uri) }
    it { is_expected.to eql(object_pid) }
  end

  describe "#exists?" do
    context "an object exists" do
      it { expect(adapter.exists?(location_uri)).to be true }
    end

    context "an object does not exist" do
      let(:location_uri) { "fedora3://" + object_pid + 'doesnotexist' }
      it { expect(adapter.exists?(location_uri)).to be false }
    end
  end
  describe "#generate_new_location_uri" do
    subject { adapter.generate_new_location_uri }
    before do
      allow(pid_generator).to receive(:next_pid).and_return(*([1, 2].map { |x| "test:#{x}" }))
    end
    it "returns the first new location URI" do
      is_expected.to eql("fedora3://test:2")
    end
  end
  describe "#persist_impl" do
    let(:rubydora_object) { Rubydora::DigitalObject.new(object_pid, Rubydora.repository) }
    let(:hyacinth_object) { FactoryBot.build(:item) }
    context "core data" do
      it "persists core data to Fedora3" do
        adapter.persist_impl("fedora3://#{object_pid}", hyacinth_object)
        actual_json = JSON.parse(rubydora_object.datastreams[described_class::HYACINTH_CORE_DATASTREAM_NAME].content)
        expect(actual_json['metadata']).to have_key("descriptive_metadata")
      end
    end
    context "field exports" do
      let(:digital_object_title) { "Assigned Label" }
      before do
        FactoryBot.create(:export_rule) # creates descMetadata
      end
      it "persists templated field exports to datastreams" do
        hyacinth_object.descriptive_metadata['name'] = [{ 'role' => "Farmer" }]
        adapter.persist_impl("fedora3://#{object_pid}", hyacinth_object)
        actual_xml = rubydora_object.datastreams["descMetadata"].content
        actual_xml.sub!(/^<\?.+\?>/, '') # remove XML declaration
        actual_xml.gsub!('mods:', '') # remove ns
        actual_xml.gsub!(/\s/, '') # remove whitespace
        expect(actual_xml).to eql("<mods><name>Farmer</name></mods>")
      end
      it "makes core object property assignments" do
        # object label is pulled from title data
        hyacinth_object.descriptive_metadata['title'] = [{ 'sort_portion' => digital_object_title }]
        adapter.persist_impl("fedora3://#{object_pid}", hyacinth_object)
        expect(rubydora_object.label).to eql(digital_object_title)
        # state should be assigned automatically
        expect(rubydora_object.state).to eql('A')
      end
      it "assigns a state property to inactive if deleted" do
        hyacinth_object.state = 'deleted'
        adapter.persist_impl("fedora3://#{object_pid}", hyacinth_object)
        expect(rubydora_object.state).to eql('I')
      end
    end
    context "basic rels-ext properties" do
      let(:digital_object_title) { "Assigned Label" }
      let(:project_property) do
        {
          isLiteral: true,
          object: hyacinth_object.primary_project.string_key,
          pid: object_pid,
          predicate: "http://dbpedia.org/ontology/project"
        }
      end
      let(:model_property) do
        {
          predicate: "info:fedora/fedora-system:def/model#hasModel",
          object: "info:fedora/ldpd:ContentAggregator",
          pid: object_pid
        }
      end
      let(:rdftype_property) do
        {
          predicate: "http://www.w3.org/1999/02/22-rdf-syntax-ns#type",
          object: "http://purl.oclc.org/NET/CUL/Aggregator",
          pid: object_pid
        }
      end
      let(:restriction_property) do
        {
          predicate: "http://www.loc.gov/premis/rdf/v1#hasRestriction",
          object: "onsite restriction",
          pid: object_pid,
          isLiteral: true
        }
      end

      it "persists content model and RDF type properties" do
        adapter.persist_impl("fedora3://#{object_pid}", hyacinth_object)
        actual_xml = rubydora_object.datastreams["RELS-EXT"].content.body
        actual_xml.sub!(/^<\?.+\?>/, '') # remove XML declaration
        actual_xml.gsub!(/ns\d:/, '') # remove ns
        actual_xml.gsub!(/xmlns=\"[^\"]*\"/, '') # remove ns
        actual_xml.gsub!(/\s+/, ' ') # collapse whitespace
        expect(actual_xml).to include("<hasModel rdf:resource=\"info:fedora/ldpd:ContentAggregator\">")
        expect(actual_xml).to include("<rdf:type rdf:resource=\"http://purl.oclc.org/NET/CUL/Aggregator\">")
      end
    end
    context "DC properties" do
      # do not need to fetch profiles for DC and RELS-EXT

      it "persists model properties" do
        hyacinth_object.identifiers << 'keep'
        adapter.persist_impl("fedora3://#{object_pid}", hyacinth_object)
        expect(rubydora_object.datastreams['DC'].content).to include("<dc:identifier>keep</dc:identifier>")
        expect(rubydora_object.datastreams['DC'].content).not_to include("<dc:identifier>remove</dc:identifier>")
      end
    end
    context "Struct properties" do
      let(:child_object_title) { "Assigned Label" }
      let(:child_hyacinth_object) do
        obj = FactoryBot.build(:item)
        obj.descriptive_metadata['title'] = [{ 'sort_portion' => child_object_title }]
        DynamicFieldsHelper.enable_dynamic_fields(obj.digital_object_type, obj.primary_project)
        obj.save
        obj
      end
      let(:child_uid) { child_hyacinth_object.uid }

      before do
        load_title_fields! # Need to defined the fields that are being used in descriptive metadata.
        hyacinth_object.children_to_add << child_hyacinth_object
        hyacinth_object.save
      end

      it "persists model properties" do
        adapter.persist_impl("fedora3://#{object_pid}", hyacinth_object)
        expect(rubydora_object.datastreams['structMetadata'].content).to include("<mets:div LABEL=\"#{child_object_title}\" ORDER=\"1\" CONTENTIDS=\"#{child_uid}\"/>")
      end
    end
    context "RelsInt properties for resources" do
      let(:hyacinth_object) { FactoryBot.build(:asset) }
      let(:resource_args) { { original_file_path: '/old/path/to/file.doc', location: 'tracked-disk:///path/to/file.doc', checksum: 'sha256:asdf', file_size: 'asdf' } }
      let(:resource_name) { hyacinth_object.main_resource_name }
      before do
        hyacinth_object.resources[resource_name] = Hyacinth::DigitalObject::Resource.new(resource_args)
      end
      it "persists model properties" do
        adapter.persist_impl("fedora3://#{object_pid}", hyacinth_object)
        rels_int = rubydora_object.datastreams['RELS-INT'].content
        ng_xml = Nokogiri::XML(rels_int)
        ng_xml.remove_namespaces!
        css_node = ng_xml.at_css("RDF > Description[about=\"info:fedora/test:1/content\"] > extent")
        expect(css_node.text).to eql('asdf')
        css_node = ng_xml.at_css("RDF > Description[about=\"info:fedora/test:1/content\"] > hasMessageDigest")
        expect(css_node['resource']).to eql('urn:sha256:asdf')
      end
    end
    context "Fulltext resources marked as preservable" do
      let(:hyacinth_object) { FactoryBot.build(:asset, :with_main_resource, :with_fulltext_resource) }
      it "persists fulltext resource" do
        adapter.persist_impl("fedora3://#{object_pid}", hyacinth_object)
        expect(rubydora_object.datastreams['fulltext'].content).to include("What a great test file!")
      end
    end
  end
end
