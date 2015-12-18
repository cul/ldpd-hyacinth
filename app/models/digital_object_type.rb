class DigitalObjectType < ActiveRecord::Base

  default_scope { order('sort_order') }

  def self.get_model_for_string_key(string_key)
    case string_key
    when 'item'
      return DigitalObject::Item
    when 'group'
      return DigitalObject::Group
    when 'file_system'
      return DigitalObject::FileSystem
    when 'asset'
      return DigitalObject::Asset
    else
      raise Hyacinth::Exceptions::InvalidDigitalObjectTypeError, 'Invalid DigitalObjectType string key: ' + string_key.to_s
    end
  end

  def as_json(options={})
    return {
      id: self.id,
      display_label: self.display_label,
      string_key: self.string_key
    }
  end

end
