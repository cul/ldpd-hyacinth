module Hyacinth::ActiveFedoraBaseWithCast
  def self.find(pid)
    obj = ActiveFedora::Base.find(pid)
    obj = obj.adapt_to(GenericResource) if obj.is_a?(Resource)
    obj
  end
end
