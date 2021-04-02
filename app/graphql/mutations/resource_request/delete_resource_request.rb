# frozen_string_literal: true

module Mutations
  module ResourceRequest
    class DeleteResourceRequest < Mutations::BaseMutation
      argument :id, ID, required: true

      field :resource_request, Types::ResourceRequestType, null: true

      def resolve(id:)
        resource_request = ::ResourceRequest.find(id)
        ability.authorize! :delete, resource_request
        resource_request.destroy!
        { resource_request: resource_request }
      end
    end
  end
end
