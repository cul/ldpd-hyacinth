# frozen_string_literal: true

class Term < ApplicationRecord
  TEMPORARY_URI_BASE = 'temp:'
  LOCAL     = 'local'
  TEMPORARY = 'temporary'
  EXTERNAL  = 'external'

  TERM_TYPES = [LOCAL, EXTERNAL, TEMPORARY].freeze

  belongs_to :vocabulary

  before_validation :set_uid, :set_uri, :set_uri_hash, on: :create
  before_save :cast_custom_fields
  after_commit :update_solr # Is triggered after successful save/update/destroy.

  validates :vocabulary, :pref_label, :uri, :uri_hash, :uid, :term_type, presence: true
  validates :term_type, inclusion: { in: TERM_TYPES, message: 'is not valid: %{value}' }, allow_nil: true
  validates :uri,  format: { with: /\A#{URI.regexp}\z/ },
                   if: proc { |t| t.uri? && (t.term_type == LOCAL || t.term_type == EXTERNAL) }
  validates :uri_hash, uniqueness: { scope: :vocabulary, message: 'unique check failed. This uri already exists in this vocabulary.' }
  validates :uid, format: { with: /\A\h{8}-\h{4}-4\h{3}-[89ab]\h{3}-\h{12}\z/ }, allow_nil: true
  validates :alt_labels, absence: { message: 'is not allowed for temporary terms' }, if: proc { |t| t.term_type == TEMPORARY }
  validate  :uid_uri_and_term_type_unchanged, :pref_label_unchanged_for_temp_term, :validate_custom_fields

  store :custom_fields, coder: JSON

  serialize :alt_labels, Array

  def to_solr
    {
      'uid'           => uid,
      'uri'           => uri,
      'pref_label'    => pref_label,
      'alt_labels'    => alt_labels,
      'term_type'     => term_type,
      'vocabulary'    => vocabulary.string_key,
      'authority'     => authority,
      'custom_fields' => custom_fields.to_json
    }.tap do |doc|
      vocabulary.custom_fields.each do |k, v|
        doc["#{k}#{Solr::Utils.suffix(v[:data_type])}"] = custom_fields[k]
      end
    end
  end

  def set_custom_field(field, value)
    custom_fields[field] = value
  end

  def self.local_uri_prefix
    host = HYACINTH[:local_uri_prefix]

    raise 'Missing local_uri_prefix in config/hyacinth.yml' unless host
    host.ends_with?('/') ? host : "#{host}/"
  end

  private

    def cast_custom_fields
      custom_fields.each do |k, v|
        next if v.nil?
        raise "custom_field #{k} is not a valid custom field" unless vocabulary.custom_fields.keys.include?(k)

        data_type = vocabulary.custom_fields[k][:data_type]

        # check data type valid
        raise "custom_field #{k} must be a valid #{data_type}. Could not cast \"#{v}\" to a valid #{data_type}" unless send("valid_#{data_type}?", v)

        # skip, if not string value
        next unless v.is_a?(String)

        # cast string values
        case data_type
        when 'integer'
          custom_fields[k] = v.to_i
        when 'boolean'
          custom_fields[k] = v == 'true'
        end
      end
    end

    def validate_custom_fields
      custom_fields.each do |k, v|
        next if v.nil?

        if vocabulary.custom_fields.keys.include?(k)
          data_type = vocabulary.custom_fields[k][:data_type]
          errors.add(:custom_field, "#{k} must be a valid #{data_type}") unless send("valid_#{data_type}?", v)
        else
          errors.add(:custom_field, "#{k} is not a valid custom field.")
        end
      end
    end

    def valid_string?(v)
      v.is_a?(String)
    end

    def valid_integer?(v)
      v.is_a?(Integer) || (v.is_a?(String) && /\A[+-]?[1-9]\d*\z/.match(v))
    end

    def valid_boolean?(v)
      (!!v == v) || (v.is_a?(String) && /\A(true|false)\z/.match(v))
    end

    def set_uid
      raise StandardError, 'Cannot set uid if record has already been persisted.' unless new_record?

      self.uid = SecureRandom.uuid unless uid
    end

    def set_uri
      case term_type
      when LOCAL
        self.uri = "#{Term.local_uri_prefix}term/#{uid}"
      when TEMPORARY
        self.uri = URI(TEMPORARY_URI_BASE + Digest::SHA256.hexdigest(vocabulary.string_key + pref_label)).to_s
      end
    end

    def set_uri_hash
      self.uri_hash = Digest::SHA256.hexdigest(uri) if uri
    end

    # Check that uid, uri and term_type were not changed.
    def uid_uri_and_term_type_unchanged
      return unless persisted? # skip if object is new or is deleted

      errors.add(:uid, 'Change of uid not allowed!') if uid_changed?
      errors.add(:uri, 'Change of uri not allowed!') if uri_changed?
      errors.add(:term_type, 'Change of term_type not allowed!') if term_type_changed?
    end

    # Check that pref_label has not been changed if temporary term
    def pref_label_unchanged_for_temp_term
      return unless persisted? && term_type == TEMPORARY # skip if object is new or is deleted

      errors.add(:pref_label, 'cannot be updated for temp terms') if pref_label_changed?
    end

    def update_solr # If this is unsuccessful the solr core will be out of sync
      if destroyed?
        Hyacinth.config.term_search_adapter.delete(uid)
      elsif persisted?
        Hyacinth.config.term_search_adapter.add(to_solr)
      end
    end
end
