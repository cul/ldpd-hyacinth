module Hyacinth
  module DigitalObject
    module TypeDef
      class User < Hyacinth::DigitalObject::TypeDef::Base
        def to_serialized_form(user)
          return nil if user.nil?
          {
            'uid' => user.uid,
            # We don't actually need the email in the serialized form, but it
            # can be helpful to have when looking at a raw saved file, and
            # is helpful in tests.
            'email' => user.email
          }
        end

        def from_serialized_form(json_var)
          return nil if json_var.nil?
          User.find_by(uid: json_var['uid'])
        end
      end
    end
  end
end
