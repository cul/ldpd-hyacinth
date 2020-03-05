# frozen_string_literal: true

class Mutations::BatchImport::CreateBatchImport < Mutations::BaseMutation
  argument :priority, Enums::BatchImportPriorityEnum, required: false

  field :batch_import, Types::BatchImportType, null: false

  def resolve(**attributes)
    ability.authorize! :create, BatchImport
    attributes[:user] = context[:current_user]
    batch_import = BatchImport.create!(**attributes)

    { batch_import: batch_import }
  end
end
