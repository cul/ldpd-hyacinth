module DigitalObject::XmlDatastreamRendering
  extend ActiveSupport::Concern

  def render_xml_datastream(xml_datastream)

    ng_xml = Nokogiri::Xml(xml_datastream)

    return '<?xml version="1.0" encoding="UTF-8"?><error>XML view is not available.</error>'
  end

end
