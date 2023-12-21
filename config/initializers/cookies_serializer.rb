# Be sure to restart your server when you modify this file.

# Specify a serializer for the signed and encrypted cookie jars.
# Valid options are :json, :marshal, and :hybrid.

# TODO: Change the value below to :json once all login sessions from the Rails 4 version have been invalidated
Rails.application.config.action_dispatch.cookies_serializer = :hybrid

