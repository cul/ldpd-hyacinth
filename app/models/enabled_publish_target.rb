class EnabledPublishTarget < ActiveRecord::Base

  belongs_to :project
  belongs_to :publish_target

  validates :project, :publish_target, presence: true

  def as_json(options={})
    return {
      publish_target_pid: self.publish_target.pid,
      publish_target_title: self.publish_target.get_title,
    }
  end

end
