module FieldExport
  module TranslationLogic
    extend ActiveSupport::Concern

    included do
      before_save :prettify_json
      validates :translation_logic, presence: true, valid_json: true
    end

    private

      def prettify_json
        self.translation_logic = JSON.pretty_generate(JSON(translation_logic))
      end
  end
end
