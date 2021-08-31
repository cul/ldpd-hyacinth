# frozen_string_literal: true

# TODO: when finished, run `rake generate_cops_documentation` to update the docs
module RuboCop
  module Cop
    module CUL
      # Do not commit specs that call `page.save_screenshot`
      class CapybaraScreenshots < RuboCop::Cop::Cop
        MSG = 'Remove debugging/instrumentation such as `page#save_screenshot` before committing.'
        # This cop uses a node matcher for matching node pattern.
        # See https://github.com/rubocop/rubocop-ast/blob/master/docs/modules/ROOT/pages/node_pattern.adoc
        #
        # For example
        def_node_matcher :called_forbidden_method?, <<-PATTERN
          (send (send nil? :page) :save_screenshot)
        PATTERN

        def on_send(node)
          return unless called_forbidden_method?(node)
          add_offense(node, location: :expression, message: MSG)
        end
      end
    end
  end
end
