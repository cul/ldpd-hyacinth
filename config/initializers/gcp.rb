# frozen_string_literal: true

# rubocop:disable Metrics/MethodLength
# rubocop:disable Lint/MissingSuper

require 'google/cloud/storage'

GCP_CONFIG = Rails.application.config_for(:gcp).deep_symbolize_keys

def validate_gcp_config!
  # No validations at the moment
end

validate_gcp_config!

class GcpMockCredentials < Google::Auth::Credentials
  def initialize(config, options = {})
    # verify_keyfile_provided! config
    # inlining a check removed in googleauth 1.13.0
    raise "The keyfile passed to Google::Auth::Credentials.new was nil." if config.nil?
    options = symbolize_hash_keys options
    @project_id = options[:project_id] || options[:project]
    @quota_project_id = options[:quota_project_id]
    update_from_hash config, options
    @project_id ||= CredentialsLoader.load_gcloud_project_id
    @env_vars = nil
    @paths = nil
    @scope = nil
    @token_credential_uri = config[:token_uri]
    @client_email = config[:client_email]
  end

  def init_client(hash, options = {})
    options = update_client_options options
    io = StringIO.new JSON.generate hash
    options[:json_key_io] = io
    Google::Auth::ServiceAccountCredentials.new(
      token_credential_uri: @token_credential_uri,
      audience: @token_credential_uri,
      scope: @scope,
      enable_self_signed_jwt: false,
      target_audience: nil,
      issuer: @client_email,
      project_id: project_id,
      quota_project_id: quota_project_id,
      universe_domain: 'googleapis.com'
    )
  end
end

def credentials_from_config(gcp_config)
  gcp_config[:mock_credentials] ? GcpMockCredentials.new(gcp_config[:credentials]) : gcp_config[:credentials]
end

GCP_STORAGE_CLIENT = Google::Cloud::Storage.new(
  project_id: GCP_CONFIG[:project_id],
  credentials: credentials_from_config(GCP_CONFIG),
  retries: 3
)
