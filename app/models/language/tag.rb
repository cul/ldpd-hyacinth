# frozen_string_literal: true

class Language::Tag < ApplicationRecord
  has_and_belongs_to_many :subtags
  belongs_to :preferred_value, class_name: 'Language::Tag', optional: true

  before_validation :set_tag_from_subtags!, :set_preferred_value_from_subtags!

  validates :tag, presence: true, uniqueness: true
  validates_with Language::Validators::SubtagsTypeValidator
  validates_with Language::Validators::ExtLangValidator

  def first_subtag_of_type(type)
    TagValue.first_subtag_of_type(subtags, type)
  end

  def lang
    first_subtag_of_type('language')
  end

  def suppressed_script
    first_subtag_of_type('language').suppress_script
  end

  def script
    script = first_subtag_of_type('script')
    script unless script == suppressed_script
  end

  def region
    first_subtag_of_type('region')
  end

  def extlang
    first_subtag_of_type('extlang')
  end

  def tag_value(use_preferred = false)
    TagValue.for_subtags(subtags, use_preferred)
  rescue SubtagError => ex
    self.errors.add :subtags, ex.message
  end

  def use_value
    preferred_value || self
  end

  # accepts a BCP-47 tag and returns the corresponding canonicalized or preferred tag
  # raises SubtagError if tags are invalid
  def self.for(tag_value, use_preferred = true)
    tag = ::Language::Tag.find_by(tag: tag_value) || compose_tag_for(tag_value)
    (use_preferred && tag.preferred_value) || tag
  rescue ActiveRecord::RecordInvalid => ex
    raise SubtagError, ex.message.sub('Validation failed: ', '')
  end

  def self.compose_tag_for(tag_value)
    subtags = subtags_for(tag_value.split('-'))
    tag_value = TagValue.for_subtags(subtags)
    candidate = ::Language::Tag.find_by(tag: tag_value) || ::Language::Tag.new(added: Time.new.getlocal, subtags: subtags)
    candidate.send :set_tag_from_subtags!
    tag = ::Language::Tag.find_by(tag: candidate.tag) || candidate
    tag.save! unless tag.persisted?
    tag
  end

  def self.subtags_for(subtag_values)
    subtags = ::Language::Subtag.where(subtag: subtag_values).to_a
    extlang = subtags.detect { |st| st.subtag_type.eql?('extlang') }
    # if a macrolanguage-extlang combination has a preferred form,
    # there may be a duplicate language tag for the extlang
    if extlang
      other_language = subtags.detect { |st| !st.subtag.eql?(extlang.subtag) && st.subtag_type.eql?('language') }
      duplicate = subtags.detect { |st| st.subtag.eql?(extlang.subtag) && st.subtag_type.eql?('language') }
      if duplicate
        if other_language
          subtags.delete(duplicate)
        else
          subtags.delete(extlang)
        end
      end
    end
    subtags
  end
  class SubtagError < RuntimeError; end

  module TagValue
    # language is required
    # extlang if available, and assign preferred
    # script if given and not suppressed
    # region if given
    def self.for_subtags(subtags, use_preferred = false)
      language, extlang, script, region = first_subtags_of_types(subtags, 'language', 'extlang', 'script', 'region')
      value = preferred_primary_value(language, extlang, use_preferred)
      value << "-#{extlang.subtag}" if extlang && !use_preferred
      value << "-#{script.subtag}" if append_script_tag?(language, script, use_preferred)
      value << "-#{region.subtag}" if region
      variants = subtags.select { |t| t.subtag_type == 'variant' }
      with_variants_suffix(value, variants)
    end

    def self.preferred_primary_value(language, extlang, use_preferred)
      return language.subtag.dup unless use_preferred
      return extlang.preferred_value.subtag.dup if extlang&.preferred_value
      (language.preferred_value&.subtag || language.subtag).dup
    end

    def self.append_script_tag?(language, script, use_preferred)
      return false if script.nil? || (use_preferred && script == language.suppress_script)
      true
    end

    def self.first_subtag_of_type(subtags, type)
      first_subtags_of_types(subtags, type).first
    end

    def self.first_subtags_of_types(subtags, *types)
      types.map { |type| subtags.detect { |st| st.subtag_type == type } }
    end

    def self.validate_variant_for_prefix(prefix, variant)
      return if variant.prefixes.blank? # blank prefixes can be used everywhere
      return if variant.prefixes.detect { |p| prefix.include?(p) }
      raise SubtagError, "variant #{variant.subtag} cannot be used in the context of #{prefix}"
    end

    def self.with_variants_suffix(prefix, variants)
      return prefix if variants.blank?
      variants = variants.dup
      variants.each { |variant| validate_variant_for_prefix(prefix, variant) }
      variants = sort_variants_by_available_prefixes(prefix, variants)
      "#{prefix}-#{variants.map(&:subtag).join('-')}"
    end

    def self.sort_variants_by_available_prefixes(tag_prefix, variants)
      prefix_filter = proc { |p| tag_prefix.include?(p) }
      prefix_sort = method(:compare_prefixes)
      variants.sort do |a, b|
        a_shortest = a.prefixes.select(&prefix_filter).sort(&prefix_sort).first
        b_shortest = b.prefixes.select(&prefix_filter).sort(&prefix_sort).first

        compare = compare_prefixes(a_shortest, b_shortest)
        if compare.zero?
          compare_tiebreak(a, b)
        else
          compare
        end
      end
    end

    def self.compare_prefixes(a, b)
      a.to_s.split('-').length <=> b.to_s.split('-').length
    end

    def self.compare_tiebreak(a, b)
      if a.prefixes.detect { |p| p.include?(b.subtag) }
        1
      elsif b.prefixes.detect { |p| p.include?(a.subtag) }
        -1
      else
        a.subtag <=> b.subtag
      end
    end
  end

  private

    def set_tag_from_subtags!
      return if tag_type == 'grandfathered'
      self.tag = tag_value
    end

    def set_preferred_value_from_subtags!
      return if preferred_value || tag_type.eql?('grandfathered')
      language = first_subtag_of_type('language')
      script = first_subtag_of_type('script')
      extlang = first_subtag_of_type('extlang')
      has_preferred = language.preferred_value
      has_preferred ||= script && (language.suppress_script == script)
      has_preferred ||= extlang&.preferred_value
      return unless has_preferred
      self.preferred_value = ::Language::Tag.for(TagValue.for_subtags(subtags, true))
    end
end
