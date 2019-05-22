module Hyacinth
  class PublishEntry
    attr_accessor :published_at, :published_by, :cited_at

    def initialize(attributes = {})
      attributes.each do |attribute_name, attribute_value|
        self.send("#{attribute_name}=", attribute_value)
      end
    end
  end
end
