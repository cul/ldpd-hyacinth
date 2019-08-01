class DynamicField < ActiveRecord::Base
  include DynamicFieldStructure::Sortable
  include DynamicFieldStructure::StringKey

  module Type
    STRING = 'string'.freeze
    TEXTAREA = 'textarea'.freeze
    INTEGER = 'integer'.freeze
    BOOLEAN = 'boolean'.freeze
    SELECT = 'select'.freeze
    DATE = 'date'.freeze
    CONTROLLED_TERM = 'controlled_term'.freeze
  end

  TYPES = [Type::STRING, Type::TEXTAREA, Type::INTEGER, Type::BOOLEAN, Type::SELECT, Type::DATE, Type::CONTROLLED_TERM].freeze

  has_many :enabled_dynamic_fields, dependent: :destroy

  belongs_to :dynamic_field_group
  belongs_to :created_by, class_name: 'User'
  belongs_to :updated_by, class_name: 'User'

  before_save :set_default_for_additional_data

  validates :display_label,         presence: true
  validates :field_type,            presence: true, inclusion: { in: TYPES }
  validates :controlled_vocabulary, presence: true, if: proc { |d| d.field_type == Type::CONTROLLED_TERM }
  validates :select_options,        presence: true, if: proc { |d| d.field_type == Type::SELECT }

  validates :additional_data_json, :select_options, valid_json: true

  def as_json(_options = {})
    {
      type: self.class.name,
      id: id,
      string_key: string_key,
      display_label: display_label,
      sort_order: sort_order,
      field_type: field_type,
      is_facetable: is_facetable,
      filter_label: filter_label,
      select_options: select_options,
      is_keyword_searchable: is_keyword_searchable,
      is_title_searchable: is_title_searchable,
      is_identifier_searchable: is_identifier_searchable,
      controlled_vocabulary: controlled_vocabulary
    }
  end

  def additional_data
    JSON(additional_data_json)
  end

  def siblings
    dynamic_field_group.respond_to?(:children) ? dynamic_field_group.children.reject { |c| c.eql?(self) } : []
  end

  private

    def set_default_for_additional_data
      self.additional_data_json = {}.to_json if additional_data_json.blank?
    end
end
