module Assignments::Enums
  extend ActiveSupport::Concern

  included do
    enum task: { annotate: 0, describe: 1, sequence: 2, transcribe: 3 }
    enum status: { unassigned: 0, assigned: 1, in_progress: 2, ready_for_review: 3, in_review: 4, accepted: 5 }
  end
end
