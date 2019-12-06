# frozen_string_literal: true

module Hyacinth
  module DigitalObject
    module TypeDef
      class Project < Hyacinth::DigitalObject::TypeDef::Base
        def to_serialized_form_impl(project)
          return nil if project.nil?
          {
            'string_key' => project.string_key
          }
        end

        def from_serialized_form_impl(json_var)
          return nil if json_var.nil?
          ::Project.find_by(string_key: json_var['string_key'])
        end
      end
    end
  end
end
