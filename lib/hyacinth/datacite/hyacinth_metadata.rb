# Following module contains functionality to retrieve metadata
# from the dynamic_field_data hash (which is an instance variable
# of DigitalObject)
module Hyacinth::Datacite
  class HyacinthMetadata
    # access filtered name and topic values
    # @see #process_names
    # @see #process_subjects_topic
    # @return [Array<String>]
    # @api public
    attr_reader :creators, :editors, :moderators, :contributors, :subjects_topic

    ControlledVocabEntry = Struct.new(:uri, :value, :type, :authority)

    # parse metadata from Hyacinth Digital Objects Data
    # @param digital_object_data_arg [Hash]
    # @api public
    def initialize(digital_object_data_arg)
      # dod is shorthand for digital_object_data
      @dod = HashWithIndifferentAccess.new(digital_object_data_arg).freeze
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

    def source
      @dod
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

    # existence of related item
    # @api public
    # @return [true, false]
    def related_item?
      @dfd.key? 'related_item'
    end

    # existence of related item
    # @api public
    # @return [integer]
    def num_related_items
      (@dfd.key? 'related_item') ? @dfd['related_item'].count : 0
    end

    # the related item title for an item (if related item present)
    # @api public
    # @return [String, nil]
    # @note It is assumed that the related_item? method will be called first
    def related_item_title(index)
      return nil unless @dfd['related_item'][index].key? 'related_item_title'
      @dfd['related_item'][index]['related_item_title']
    end

    # the related item type for an item (if related item present)
    # @api public
    # @return [Struct, nil]
    # @note It is assumed that the related_item? method will be called first
    def related_item_type_of_resource(index)
      return nil unless @dfd['related_item'][index].key? 'related_item_type_of_resource'
      related_item_res_type = ControlledVocabEntry.new
      related_item_res_type.uri = @dfd['related_item'][index]['related_item_type_of_resource']['uri']
      related_item_res_type.value = @dfd['related_item'][index]['related_item_type_of_resource']['value']
      related_item_res_type.type = @dfd['related_item'][index]['related_item_type_of_resource']['type']
      related_item_res_type.authority = @dfd['related_item'][index]['related_item_type_of_resource']['authority']
      related_item_res_type
    end

    # the related item relation type for an item (if related item present)
    # @api public
    # @return [Struct, nil]
    # @note It is assumed that the related_item? method will be called first
    def related_item_relation_type(index)
      # Note: string key for this field is misnamed. The field contains the
      # relation type, and uses the relation_type vocabulary
      return nil unless @dfd['related_item'][index].key? 'related_item_type'
      relation_type = ControlledVocabEntry.new
      relation_type.uri = @dfd['related_item'][index]['related_item_type']['uri']
      relation_type.value = @dfd['related_item'][index]['related_item_type']['value']
      relation_type.type = @dfd['related_item'][index]['related_item_type']['type']
      relation_type.authority = @dfd['related_item'][index]['related_item_type']['authority']
      relation_type
    end

    # the related item doi identifier for an item (if related item present)
    # @api public
    # @return [string, nil]
    def related_item_identifier_doi(index)
      return nil unless @dfd['related_item'][index].key? 'related_item_identifier'
      ids = @dfd['related_item'][index]['related_item_identifier']
      for id in ids
        if id['related_item_identifier_type'] == 'doi'
          return id['related_item_identifier_value']
        end
      end
      nil
    end

    # the related item url identifier for an item (if related item present)
    # @api public
    # @return [string, nil]
    def related_item_identifier_url(index)
      return nil unless @dfd['related_item'][index].key? 'related_item_identifier'
      ids = @dfd['related_item'][index]['related_item_identifier']
      for id in ids
        if id['related_item_identifier_type'] == 'url'
          return id['related_item_identifier_value']
        end
      end
      nil
    end

    # the related item url identifier for an item (if related item present)
    # @api public
    # @return [[string,string], nil]
    def related_item_identifier_first(index)
      return nil unless @dfd['related_item'][index].key? 'related_item_identifier'
      id = @dfd['related_item'][index]['related_item_identifier'].first
      [id['related_item_identifier_type'], id['related_item_identifier_value']]
    end

    # the related item identifier for an item (if related item present)
    # @api public
    # @return [(x,y), nil]
    # @note It is assumed that the related_item? method will be called first
    def related_item_identifiers(index)
      return nil unless @dfd['related_item'][index].key? 'related_item_identifier'
      identifiers = []
      ids = @dfd['related_item'][index]['related_item_identifier']
      for identifier in ids
        identifier_type = identifier['related_item_identifier_type']
        identifier_value = identifier['related_item_identifier_value']
        identifiers.append [identifier_type, identifier_value]
      end
      identifiers
    end

    # the license for an item
    # @api public
    # @return [ControlledVocabEntry, empty array]
    def license
      return nil unless @dfd.key? 'license'
      hy_license = @dfd['license'].first
      license = ControlledVocabEntry.new
      license.uri = hy_license['license_term']['uri']
      license.value = hy_license['license_term']['value']
      license.type = hy_license['license_term']['type']
      license.authority = hy_license['license_term']['authority']
      license
    end

    # the license for an item
    # @api public
    # @return [array of ControlledVocabEntry, empty array]
    def license_info
      license_info = []
      if @dfd.key? 'license'
        for a_license in @dfd['license']
          license = ControlledVocabEntry.new
          license.uri = a_license['license_term']['uri']
          license.value = a_license['license_term']['value']
          license.type = a_license['license_term']['type']
          license.authority = a_license['license_term']['authority']
          license_info.append license
        end
      end
      license_info
    end

    # the use and reproduction for an item
    # @api public
    # @return [ControlledVocabEntry, empty array]
    def use_and_reproduction
      return nil unless @dfd.key? 'use_and_reproduction'
      hy_use_repro = @dfd['use_and_reproduction'].first
      use_and_reproduction = ControlledVocabEntry.new
      use_and_reproduction.uri =
        hy_use_repro['use_and_reproduction_term']['uri']
      use_and_reproduction.value =
        hy_use_repro['use_and_reproduction_term']['value']
      use_and_reproduction.type =
        hy_use_repro['use_and_reproduction_term']['type']
      use_and_reproduction.authority =
        hy_use_repro['use_and_reproduction_term']['authority']
      use_and_reproduction
    end

    # the use and reproduction for an item
    # @api public
    # @return [array of ControlledVocabEntry, empty array]
    def use_and_reproduction_info
      use_and_reproduction_info = []
      if @dfd.key? 'use_and_reproduction'
        for a_use_reprod in @dfd['use_and_reproduction']
          use_and_reproduction = ControlledVocabEntry.new
          use_and_reproduction.uri =
            a_use_reprod['use_and_reproduction_term']['uri']
          use_and_reproduction.value =
            a_use_reprod['use_and_reproduction_term']['value']
          use_and_reproduction.type =
            a_use_reprod['use_and_reproduction_term']['type']
          use_and_reproduction.authority =
            a_use_reprod['use_and_reproduction_term']['authority']
          use_and_reproduction_info.append use_and_reproduction
        end
      end
      use_and_reproduction_info
    end

    # the genre of an item
    # @api public
    # @return [String, nil]
    # @note only returns the first genre value
    def genre_uri
      @dfd['genre'][0]['genre_term']['uri'] if @dfd.key?('genre') && @dfd['genre'][0].key?('genre_term')
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
      return @dod['doi'] if @dod['doi']
      # legacy behavior if top level field is absent
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
        process_name(name)
      end
    end

    # adds given name to correct name-related instance variable (@creators, @editors, etc.)
    # @api private
    # @return [void]
    def process_name(name)
      # If name has no explicitly declared role, add name to @contributors
      if name['name_role'].blank?
        @contributors << name['name_term']['value']
        return
      end

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
