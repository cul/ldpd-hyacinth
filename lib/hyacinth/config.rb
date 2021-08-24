# frozen_string_literal: true

module Hyacinth
  # Provides app-wide configuration information for Hyacinth and caches
  # information in non-dev environments.

  module Config
    module_function

    def digital_object_types
      @digital_object_types ||= Hyacinth::DigitalObject::Types.new(
        'item' => ::DigitalObject::Item,
        'asset' => ::DigitalObject::Asset,
        'site' => ::DigitalObject::Site
      )
    end

    def derivativo
      @derivativo ||= Derivativo::Client.new(HYACINTH[:derivativo])
    end

    def self.metadata_storage
      @metadata_storage ||= Hyacinth::Storage::MetadataStorage.new(HYACINTH[:metadata_storage])
    end

    def self.resource_storage
      @resource_storage ||= Hyacinth::Storage::ResourceStorage.new(HYACINTH[:resource_storage])
    end

    def self.batch_import_storage
      @batch_import_storage ||= Hyacinth::Storage::BatchImportStorage.new(HYACINTH[:batch_import_storage])
    end

    def self.batch_export_storage
      @batch_export_storage ||= Hyacinth::Storage::BatchExportStorage.new(HYACINTH[:batch_export_storage])
    end

    def self.preservation_persistence
      @preservation_persistence ||= Hyacinth::Preservation::PreservationPersistence.new(HYACINTH[:preservation_persistence])
    end

    def self.digital_object_search_adapter
      @digital_object_search_adapter ||= Hyacinth::Adapters.create_from_config('Hyacinth::Adapters::DigitalObjectSearchAdapter', HYACINTH[:digital_object_search_adapter])
    end

    def self.lock_adapter
      @lock_adapter ||= Hyacinth::Adapters.create_from_config('Hyacinth::Adapters::LockAdapter', HYACINTH[:lock_adapter])
    end

    def self.publication_adapter
      @publication_adapter ||= Hyacinth::Adapters.create_from_config('Hyacinth::Adapters::PublicationAdapter', HYACINTH[:publication_adapter])
    end

    def self.external_identifier_adapter
      @external_identifier_adapter ||= Hyacinth::Adapters.create_from_config('Hyacinth::Adapters::ExternalIdentifierAdapter', HYACINTH[:external_identifier_adapter])
    end

    def self.term_search_adapter
      @term_search_adapter ||= Hyacinth::Adapters.create_from_config('Hyacinth::Adapters::TermSearchAdapter', HYACINTH[:term_search_adapter])
    end

    def self.default_lang_value
      @default_lang_value ||= ::Language::Tag.for(LANG[:default_lang_value])
    end

    def self.allowed_lang_value?(tag_value)
      ::Language::Tag.for(tag_value)
    rescue
      false
    end

    def self.load_default_subtags!
      Rails.application.config_for(:lang).fetch(:default_lang_subtags, {}).each do |subtag, attributes|
        subtag_atts = attributes.merge(subtag: subtag).map { |k, v| [k, Array[v]] }.to_h.with_indifferent_access
        Hyacinth::Language::SubtagLoader.new(nil).load_resolved_attributes(subtag_atts)
      end
    end
  end
end
