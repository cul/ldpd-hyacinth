# frozen_string_literal: true

class Hyacinth::Language::SubtagLoader
  attr_accessor :attributes_loader
  def initialize(data)
    data = Hyacinth::Language::AttributesLoader.new(data) unless data.is_a? Hyacinth::Language::AttributesLoader
    self.attributes_loader = data
  end

  def load_attributes
    attributes_loader.load
  end

  def find_or_initialize(atts)
    ::Language::Subtag.find_by(subtag: atts['subtag']) || ::Language::Subtag.new(subtag: atts['subtag'])
  end

  def iana_date_to_time(date)
    return unless date
    date = date.split('-')
    Time.new(date[0], date[1], date[2], nil, nil, nil, 0)
  end

  def resolve_subtag_attributes(atts)
    atts = atts.dup
    single_value_fields = ['subtag', 'type', 'scope']
    single_value_fields.each { |svf| atts[svf] = atts.delete(svf)&.first }
    atts['subtag_type'] = atts.delete('type')
    associated_tags = { 'preferred_value' => atts.delete('preferred-value') }
    associated_tags['suppress_script'] = atts.delete('suppress-script')
    associated_tags['macrolanguage'] = atts.delete('macrolanguage')
    associated_tags.each { |prop, subtags| atts[prop] = ::Language::Subtag.find_by!(subtag: subtags.first) if subtags.present? }
    atts['descriptions'] = atts.delete('description')
    atts['prefixes'] = atts.delete('prefix')
    atts['added'] = iana_date_to_time(atts.delete('added').first)
    atts['deprecated'] = iana_date_to_time(atts.delete('deprecated')&.first)
    atts
  end

  def resolve_tag_attributes(atts)
    atts = atts.dup
    atts['tag'] = atts['tag'].first
    atts['tag_type'] = atts.delete('type').first
    preferred_value = atts.delete('preferred-value')
    atts['preferred_value'] = ::Language::Tag.for(preferred_value.first) if preferred_value
    atts['descriptions'] = atts.delete('description')
    atts['added'] = iana_date_to_time(atts.delete('added').first)
    atts['deprecated'] = iana_date_to_time(atts.delete('deprecated')&.first)
    atts
  end

  def tag_for_atts(atts)
    return ::Language::Tag.for(atts['tag']) if atts['tag_type'].eql?('redundant')
    ::Language::Tag.find_by(tag: atts['tag']) || ::Language::Tag.new(tag: atts['tag'])
  end

  def load_resolved_attributes(atts)
    if atts['subtag']
      atts = resolve_subtag_attributes(atts)
      subtag = ::Language::Subtag.find_by(subtag: atts['subtag'], subtag_type: atts['subtag_type']) || ::Language::Subtag.new(subtag: atts['subtag'])
      subtag.assign_attributes(atts)
      subtag.save!
    elsif atts['tag']
      atts = resolve_tag_attributes(atts)
      tag = tag_for_atts(atts)
      tag.assign_attributes(atts)
      tag.save!
    end
  end

  def load
    # parse the provided IANA data
    load_attributes
    # load scripts
    load_subtags_with(type: 'script')

    load_language_subtags

    load_non_language_subtags

    # load grandfathered tags
    load_subtags_with(type: 'grandfathered')
  end

  def load_subtags_with(filters)
    attributes_loader.each_with(filters) do |atts|
      load_resolved_attributes(atts)
    end
  end

  # load language subtags in order ensuring valid dependencies will exist
  def load_language_subtags
    load_subtags_with(type: 'language', scope: :*, subtag: :*)
    load_subtags_with(type: 'language', macrolanguage: :*, subtag: :*, 'preferred-value'.to_sym => nil)
    load_subtags_with(type: 'language', macrolanguage: :*, subtag: :*, 'preferred-value'.to_sym => :*)
    load_subtags_with(type: 'language', scope: nil, macrolanguage: nil, subtag: :*, 'preferred-value'.to_sym => nil)
    load_subtags_with(type: 'language', scope: nil, macrolanguage: nil, subtag: :*, 'preferred-value'.to_sym => :*)
  end

  def load_non_language_subtags
    # load subtags with a scope that is not private use
    attributes_loader.each_with(scope: :*) do |atts|
      next if atts['scope'].include? 'private-use'
      next if atts['type'].include? 'language' # done earlier
      load_resolved_attributes(atts)
    end
    # load subtags without a preferred value
    attributes_loader.each_with('preferred-value'.to_sym => nil) do |atts|
      next if atts['type'].include? 'language' # done earlier
      load_resolved_attributes(atts)
    end
    # load subtags with a preferred value
    attributes_loader.each_with('preferred-value'.to_sym => :*) do |atts|
      next if atts['type'].include? 'language' # done earlier
      load_resolved_attributes(atts)
    end
  end
end
