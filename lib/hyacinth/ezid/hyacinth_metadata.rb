# Following module contains functionality to retrieve metadata
# from the dynamic_field_data hash (which is an instance variable
# of DigitalObject)
module Hyacinth::Ezid
  class HyacinthMetadata
    # access filtered name and topic values
    # @see #process_names
    # @see #process_subjects_topic
    # @return [Array<String>]
    # @api public
    attr_reader :creators, :editors, :moderators, :contributors, :subjects_topic

    # parse metadata from Hyacinth Digital Objects Data
    # @param digital_object_data_arg [Hash]
    # @api public
    def initialize(digital_object_data_arg)
      # dod is shorthand for digital_object_data
      @dod = HashWithIndifferentAccess.new(digital_object_data_arg)
      # dfd is shorthand for dynamic_field_data
      @dfd = @dod['dynamic_field_data']
      @creators = []
      @editors = []
      @moderators = []
      @contributors = []
      @subjects_topic = []
      process_names
      process_subjects_topic
    end

    # the title of an item
    # @api public
    # @return [String, nil]
    # @note only returns the first title value
    def title
      return nil unless @dfd.key? 'title'
      # concatenates the non sort portion with the sort portion
      non_sort_portion = @dfd['title'][0]['title_non_sort_portion'] if @dfd['title'][0].key? 'title_non_sort_portion'
      sort_portion = @dfd['title'][0]['title_sort_portion'] if @dfd['title'][0].key? 'title_sort_portion'
      "#{non_sort_portion} #{sort_portion}"
    end

    # the abstract of an item
    # @api public
    # @return [String, nil]
    # @note only returns the first abstract value
    def abstract
      @dfd['abstract'][0]['abstract_value'] if @dfd.key? 'abstract'
    end

    # the type of resource for an item
    # @api public
    # @return [String, nil]
    def type_of_resource
      @dfd['type_of_resource'][0]['type_of_resource_value'] if @dfd.key? 'type_of_resource'
    end

    # starting year of the w3cdtf-encoded Date Issued field (first 4 characters)
    # @api public
    # @return [String, nil]
    def date_issued_start_year
      @dfd['date_issued'][0]['date_issued_start_value'][0..3] if @dfd.key? 'date_issued'
    end

    # date of the w3cdtf-encoded created Timestamp field (first 10 characters)
    # @api public
    # @return [String]
    def date_created
      @dod['created'][0..9]
    end

    # date of the w3cdtf-encoded modified Timestamp field (first 10 characters)
    # @api public
    # @return [String]
    def date_modified
      @dod['modified'][0..9]
    end

    # ISSN of the parent publication
    # @api public
    # @return [String, nil]
    def parent_publication_issn
      @dfd['parent_publication'][0]['parent_publication_issn'] if @dfd.key? 'parent_publication'
    end

    # ISBN of the parent publication
    # @api public
    # @return [String, nil]
    def parent_publication_isbn
      @dfd['parent_publication'][0]['parent_publication_isbn'] if @dfd.key? 'parent_publication'
    end

    # DOI of the parent publication
    # @api public
    # @return [String, nil]
    def parent_publication_doi
      @dfd['parent_publication'][0]['parent_publication_doi'] if @dfd.key? 'parent_publication'
    end

    # DOI identifier value
    # @api public
    # @return [String, nil]
    def doi_identifier
      @dfd['doi_identifier'][0]['doi_identifier_value'] if @dfd.key? 'doi_identifier'
    end

    # handle indentifier value
    # @api public
    # @return [String, nil]
    def handle_net_identifier
      @dfd['cnri_handle_identifier'][0]['cnri_handle_identifier_value'] if @dfd.key? 'cnri_handle_identifier'
    end

    # retrieve name terms by role from [@dfd]
    # @api private
    # @return [void]
    def process_names
      return unless @dfd.key? 'name'
      @dfd['name'].each do |name|
        name['name_role'].each do |role|
          role_value = role['name_role_term']['value'].downcase
          case role_value
          when 'author' then @creators << name['name_term']['value']
          when 'editor' then @editors << name['name_term']['value']
          when 'moderator' then @moderators << name['name_term']['value']
          when 'contributor' then @contributors << name['name_term']['value']
          end
        end
      end
    end

    # retrieve subject topics from [@dfd]
    # @api private
    # @return [void]
    def process_subjects_topic
      return unless @dfd.key? 'subject_topic'
      @dfd['subject_topic'].each do |topic|
        @subjects_topic << topic['subject_topic_term']['value']
      end
    end
  end
end
