# frozen_string_literal: true

module Language::Validators
  class ScopeValidator < ActiveModel::Validator
    class_attribute :valid_scopes, default: []
    class_attribute :field_name
    class_attribute :required, default: false
    def validate(record)
      field_name = self.class.field_name
      value = record.send(field_name)
      if value.nil?
        return unless self.class.required
        record.errors.add field_name, "required field #{field_name} was unassigned"
        return
      end
      return if self.class.valid_scopes.include?(value.scope)
      record.errors.add field_name, "Ineligible subtag assigned to #{field_name} in #{record.subtag}: #{value.inspect})"
    end
  end

  class MacrolanguageValidator < ScopeValidator
    self.valid_scopes = ['macrolanguage'].freeze
    self.field_name = :macrolanguage
  end

  class SuppressScriptValidator < ActiveModel::Validator
    def validate(record)
      value = record.suppress_script
      return if value.nil? || value.subtag_type.eql?('script')
      record.errors.add :subtags, "Ineligible subtag assigned to suppress_script: #{value.subtag}"
    end
  end

  class SubtagsTypeValidator < ActiveModel::Validator
    def validate(record)
      ['script', 'region', 'extlang'].each do |type|
        record.errors.add :subtags, "There must be no more than one subtag of type '#{type}'" if more_than_one_tag_of_type?(record.subtags, type)
      end
      return if count(record.subtags, 'language') == 1 || record.tag_type.eql?('grandfathered')
      record.errors.add :subtags, "There must be one and only one subtag of type 'language'"
    end

    def more_than_one_tag_of_type?(subtags, type)
      count(subtags, type) > 1
    end

    def count(subtags, type)
      subtags.inject(0) { |c, subtag| subtag.subtag_type.eql?(type) ? (c + 1) : c }
    end
  end

  class VariantValidator < ActiveModel::Validator
    def validate(record)
      variants = record.subtags.select { |t| t.subtag_type.eql?('variant') }.to_a
      return unless variants.present?
      nonvariants = record.subtags.to_a - variants
      prefix = ::Language::Tag.tag_value(nonvariants, true)
      variants.each do |variant|
        # blank prefixes are allowed anywhere
        next if variant.prefixes.blank? || variant.prefixes.detect { |variant_prefix| variant_prefix.start_with prefix }
        record.errors.add :subtags, "variant tag #{variant.subtag} is not valid with nonvariants prefix #{prefix}"
      end
    end
  end

  class ExtLangValidator < ActiveModel::Validator
    def validate(record)
      extlang = record.subtags.detect { |t| t.subtag_type == 'extlang' }
      return unless extlang
      language = record.subtags.detect { |t| t.subtag_type == 'language' }
      return if extlang.prefixes.include?(language.subtag)
      record.errors.add :subtags, "extlang tag #{extlang.subtag} is not valid with language tag #{language.subtag}"
    end
  end

  class PreferredValueValidator < ActiveModel::Validator
    def validate(record); end
  end
end
