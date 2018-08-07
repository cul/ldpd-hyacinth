class Hyacinth::Utils::JsonUtils
  def self.valid_json?(json_string)
    JSON.parse(json_string)
    true
  rescue
    false
  end
end
