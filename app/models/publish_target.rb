class PublishTarget < ApplicationRecord
  belongs_to :project

  validates :string_key, presence: true, uniqueness: true, string_key: true
  validates :display_label, :publish_url, :api_key, presence: true
  validates :doi_priority, numericality: {
    only_integer: true, allow_nil: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 100
  }

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
    hash = JSON.parse(json)
    project_string_key = include_root ? hash.values.first.delete('project') : hash.delete('project')
    super(hash.to_json, include_root)
    self.project = Project.find_by(string_key: project_string_key) if project_string_key
    self
  end

  def valid_doi_location?
    is_allowed_doi_target
  end
end
