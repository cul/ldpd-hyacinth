# frozen_string_literal: true

module Mutations
  module ResourceRequest
    class UpdateResourceRequest < Mutations::BaseMutation
      argument :id, ID, required: true
      argument :status, String, required: false
      argument :processing_errors, [String], required: false

      field :resource_request, Types::ResourceRequestType, null: true

      def resolve(id:, **attributes)
        resource_request = ::ResourceRequest.find(id)
        ability.authorize! :update, resource_request

        resource_request.update!(**attributes)

        { resource_request: resource_request }
      end
    end
  end
end
