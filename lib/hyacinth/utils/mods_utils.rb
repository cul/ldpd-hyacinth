class Hyacinth::Utils::ModsUtils
  def self.create_element_path_in_doc(xml_doc, arr_path_to_element)
    current_path = ''
    element_to_append_to = ''

    arr_path_to_element.each do |element_name|
      current_path += '/' + element_name
      logger.debug 'xpath: ' + current_path
      # Check if current_path exists
      current_path_xpath_result = xml_doc.xpath(current_path)
      if current_path_xpath_result.blank?
        logger.debug '-- xpath not found'
        # This path does not exist.  Create element.
        new_element = xml_doc.create_element(element_name)
        element_to_append_to.add_child(new_element)
        element_to_append_to = new_element
      else
        logger.debug '-- xpath found'
        element_to_append_to = current_path_xpath_result.first
      end
    end
  end

  def self.logger
    @logger ||= begin
      if defined?(Rails.logger)
        Rails.logger
      else
        Hyacinth::Utils::Logger.new
      end
    end
  end
end
