# frozen_string_literal: true

LANG = Rails.application.config_for(:lang)

Rails.application.config.after_initialize do
  Hyacinth::Language.load_default_subtags! if ActiveRecord::Base.connection.table_exists? :language_subtags
end
