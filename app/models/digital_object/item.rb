# frozen_string_literal: true

class DigitalObject::Item < DigitalObject
  def can_have_children?
    true
  end

  def can_have_rights?
    true
  end
end
