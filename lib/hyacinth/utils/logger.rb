class Hyacinth::Utils::Logger
  def debug(message)
    write(:debug, message)
  end

  def info(message)
    write(:info, message)
  end

  def warn(message)
    write(:warn, message)
  end

  def error(message)
    write(:error, message)
  end

  def fatal(message)
    write(:fatal, message)
  end

  def write(level, message)
    puts "#{level.to_s.capitalize}: #{message}"
  end

  module Behavior
    def logger
      @logger ||= begin
        if defined?(Rails.logger)
          Rails.logger
        else
          Hyacinth::Utils::Logger.new
        end
      end
    end
  end

  extend Behavior
end
