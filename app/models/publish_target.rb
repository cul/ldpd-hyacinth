class PublishTarget < ApplicationRecord
  has_and_belongs_to_many :projects
  has_and_belongs_to_many :digital_object_records

  validates :string_key, presence: true, uniqueness: true, format: {
    with: /\A[a-z0-9_]+\z/,
    message: 'only allows lowercase letters, numbers and underscores'
  }
  validates :display_label, presence: true
  validates :publish_url, presence: true
  validates :api_key, presence: true
  # Lower number = higher priority
  validates :doi_priority, allow_nil: true, numericality: { only_integer: true }, uniqueness: {
    message: 'is already used by another publish target'
  }

  def publish_digital_object(digital_object_pid)
    puts "Making a request to: #{"#{publish_url}/#{digital_object_pid}"}, authorization header is #{authorization_header}"
    RestClient.put("#{publish_url}/#{digital_object_pid}", {}, authorization_header)
  end

  def unpublish_digital_object(digital_object_pid)
    RestClient.delete("#{publish_url}/#{digital_object_pid}", authorization_header)
  end

  private

    def authorization_header
      { Authorization: "Token token=#{api_key}" }
    end
end
