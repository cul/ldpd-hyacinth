class EnabledDynamicFieldsFieldset < ActiveRecord::Base
  belongs_to :enabled_dynamic_field
  belongs_to :fieldset
end
