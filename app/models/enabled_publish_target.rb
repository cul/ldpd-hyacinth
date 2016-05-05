class EnabledPublishTarget < ActiveRecord::Base
  belongs_to :project
  belongs_to :publish_target

  validates :project, :publish_target, presence: true

  def as_json(_options = {})
    {
      publish_target_pid: publish_target.pid,
      publish_target_title: publish_target.get_title
    }
  end
end
