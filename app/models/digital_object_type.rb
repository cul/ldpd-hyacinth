class DigitalObjectType < ActiveRecord::Base

  default_scope { order('sort_order') }

  def get_associated_model
    case self.string_key
    when 'item'
      return DigitalObject::Item
    when 'group'
      return DigitalObject::Group
    when 'asset'
      return DigitalObject::Asset
    else
      return nil
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
