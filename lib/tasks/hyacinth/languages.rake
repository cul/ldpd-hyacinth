# frozen_string_literal: true

namespace :hyacinth do
  desc 'tasks parsing IANA data for BCP 47 tags and subtags, eg https://www.iana.org/assignments/language-subtag-registry'
  namespace :languages do
    desc 'Parse IANA data for schema'
    task schema: :environment do
      raise "No IANA data URI or path given" unless ENV['DATA']
      schema_fields = {}
      scopes = Set.new
      types = Set.new
      loader = Hyacinth::Language::AttributesLoader.new(ENV['DATA'])
      loader.records.each do |record_fields|
        scopes << record_fields['scope']&.first
        types << record_fields['type']&.first
        record_schema = record_fields.map { |k, v| Array(v).length > 1 ? [k, :multiple] : [k, :single] }.to_h
        record_schema.merge! schema_fields.select { |_k, v| v == :multiple }.to_h
        schema_fields.merge! record_schema
      end
      schema_fields[:scope] = scopes.to_a.compact
      schema_fields[:type] = types.to_a.compact
      puts schema_fields.inspect
    end
    task load: :environment do
      raise "No IANA data URI or path given" unless ENV['DATA']
      Hyacinth::Language::SubtagLoader.new(ENV['DATA']).load
    end
  end
end
