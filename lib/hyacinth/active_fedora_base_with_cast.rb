module Hyacinth::ActiveFedoraBaseWithCast
  def self.get_relationship_values(obj, predicate)
    properties = obj.relationships(predicate)
    return [] unless properties.present?
    properties.map { |property| (property.kind_of? RDF::Literal) ? property.value : property }
  end

  # determine whether an object asserts any of the specified cmodels
  # matches_any_cmodel?(obj, ["info:fedora/ldpd:GenericResource"])
  # @param [ActiveFedora::Base] obj
  # @param [Array<String>] cmodels
  def self.matches_any_cmodel?(obj, cmodels)
    assertions = get_relationship_values(obj, :has_model).map { |rdf_prop| rdf_prop.to_s }
    (assertions & Array(cmodels)).present?
  end

  def self.find(pid)
    obj = ActiveFedora::Base.find(pid)
    if obj.class == ActiveFedora::Base
      if matches_any_cmodel?(obj, 'info:fedora/ldpd:Resource')
        obj.add_relationship(:has_model, 'info:fedora/ldpd:GenericResource')
        return obj.adapt_to(GenericResource)
      end
      if matches_any_cmodel?(obj, 'info:fedora/ldpd:BagAggregator')
        obj.add_relationship(:has_model, 'info:fedora/ldpd:Collection')
        return obj.adapt_to(Collection)
      end
    end
    obj
  end
end
