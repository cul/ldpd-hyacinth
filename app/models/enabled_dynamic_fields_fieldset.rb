class EnabledDynamicFieldsFieldset < ApplicationRecord
  belongs_to :enabled_dynamic_field
  belongs_to :fieldset
end
