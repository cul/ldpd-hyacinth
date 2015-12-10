class Hyacinth::Utils::JsonUtils
  def self.valid_json?(json_string)
    JSON.parse(json_string)
    return true
  rescue
    return false
  end
end
