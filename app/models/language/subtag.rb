# frozen_string_literal: true

class Language::Subtag < ApplicationRecord
  belongs_to :suppress_script, class_name: "Language::Subtag", optional: true
  belongs_to :macrolanguage, class_name: "Language::Subtag", optional: true
  belongs_to :preferred_value, class_name: "Language::Subtag", optional: true
  serialize :comments, Array
  serialize :prefixes, Array
  validates :subtag, format: { with: /[a-zA-Z0-9]+/,
    message: "subtags only allows letters and digits: %{value}" }
  validates_with Language::Validators::MacrolanguageValidator
  validates_with Language::Validators::SuppressScriptValidator
  validates_with Language::Validators::PreferredValueValidator
end
