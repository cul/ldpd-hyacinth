class Hyacinth::Utils::JsonUtils

  def self.is_valid_json?(json_string)

    begin
      JSON.parse(json_string)
      return true
    rescue
      return false
    end

  end

end
