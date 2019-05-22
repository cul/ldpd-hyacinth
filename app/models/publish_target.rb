class PublishTarget < ApplicationRecord
  belongs_to :project

  validates :string_key, presence: true, uniqueness: true, string_key: true
  validates :display_label, :publish_url, :api_key, presence: true

  def as_json(_options = {})
    {
      project: project.string_key,
      string_key: string_key,
      display_label: display_label,
      publish_url: publish_url,
      api_key: api_key,
      is_allowed_doi_target: is_allowed_doi_target,
      doi_priority: doi_priority
    }
  end

  def from_json(json, include_root = include_root_in_json)
    hash = ActiveSupport::JSON.decode(json)
    project_string_key = include_root ? hash.values.first.delete('project') : hash.delete('project')
    super(hash.to_json, include_root)
    self.project = Project.find_by(string_key: project_string_key) if project_string_key
    self
  end

  def valid_doi_location?
    is_allowed_doi_target
  end
end
