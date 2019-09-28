# frozen_string_literal: true

require 'yaml'
require 'logger'

#
# Config util class
#
class ConfigManager

  @@config_path = 'config.yml'
  @@test_data_path = 'test_data/input_data.csv'

  def self.config_path
    @@config_path
  end

  def self.test_data_path
    @@test_data_path
  end

  def self.read(config_path, param_names)
    logger = Logger.new(STDOUT)
    logger.progname = 'Auto: Configuration'
    apply_default_logger_format logger
    begin
    result = YAML.load_file(config_path)
    rescue => e
    logger.error { "Can't read config file #{config_path}" }
    logger.error e
    logger.error e.backtrace.join("\n")
    raise e
    end
    param_names.each do |param|
      result = result[param]
      if result.nil?
        logger.error { "#{param} was not set" }
        raise StandardError, "#{param} was not set"
      end
    end
    result
  end

  def self.apply_default_logger_format(logger)
    logger.formatter = proc do |severity, datetime, progname, msg|
      date_format = datetime.strftime("%Y-%m-%d %H:%M:%S")
      "#{date_format} #{severity} #{progname}: #{msg}\n"
    end
  end


end
