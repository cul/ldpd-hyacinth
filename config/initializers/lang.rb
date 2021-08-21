# frozen_string_literal: true

LANG = Rails.application.config_for(:lang)

Hyacinth::Config.load_default_subtags! if ActiveRecord::Base.connection.table_exists? :language_subtags
