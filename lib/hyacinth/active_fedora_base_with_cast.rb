module Hyacinth::ActiveFedoraBaseWithCast
  def self.find(pid)
    obj = ActiveFedora::Base.find(pid)
    obj = obj.adapt_to(GenericResource) if obj.is_a?(Resource) && obj.relationships(:has_model).include?('info:fedora/ldpd:GenericResource')
    obj = obj.adapt_to(Collection) if obj.is_a?(BagAggregator) && obj.relationships(:has_model).include?('info:fedora/ldpd:Collection')
    obj
  end
end
