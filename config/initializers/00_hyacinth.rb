# frozen_string_literal: true

# Load config from hyacinth.yml
HYACINTH = Rails.application.config_for(:hyacinth).deep_symbolize_keys
# TODO: move into adapter config
DATACITE = Rails.application.config_for(:datacite).deep_symbolize_keys
