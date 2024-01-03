class DigitalObjectType < ApplicationRecord
  has_many :enabled_dynamic_fields, dependent: :destroy

  # default_scope { order('sort_order') }
  self.implicit_order_column = 'sort_order'

  def self.get_model_for_string_key(string_key)
    case string_key
    when 'item'
      DigitalObject::Item
    when 'group'
      DigitalObject::Group
    when 'file_system'
      DigitalObject::FileSystem
    when 'asset'
      DigitalObject::Asset
    when 'publish_target'
      DigitalObject::PublishTarget
    else
      raise Hyacinth::Exceptions::InvalidDigitalObjectTypeError, "Invalid DigitalObjectType string key: #{string_key}"
    end
  end

  def as_json(_options = {})
    {
      id: id,
      display_label: display_label,
      string_key: string_key
    }
  end
end
