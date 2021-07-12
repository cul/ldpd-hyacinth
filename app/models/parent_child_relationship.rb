# frozen_string_literal: true

class ParentChildRelationship < ApplicationRecord
  belongs_to :parent, class_name: 'DigitalObject'
  belongs_to :child, class_name: 'DigitalObject'
end
