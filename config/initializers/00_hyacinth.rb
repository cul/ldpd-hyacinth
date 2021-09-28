# frozen_string_literal: true

# Load config from hyacinth.yml
HYACINTH = Rails.application.config_for(:hyacinth).deep_symbolize_keys
