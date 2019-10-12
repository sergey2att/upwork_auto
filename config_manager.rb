# frozen_string_literal: true

require 'logger'

#
# Config util class
#
class ConfigManager

  @@config_path = 'config.properties'
  @@test_data_path = 'test_data/input_data.csv'

  def initialize
    @logger = SimpleLog.new
    @logger.progname = 'Auto: Configuration'
  end

  def self.base_config_path
    @@config_path
  end

  def self.test_data_path
    @@test_data_path
  end

  @@shared = ConfigManager.new

  def self.shared
    @@shared
  end

  private_class_method :new

  def read(path, param)
    begin
    result = read0(path)
    rescue => e
    @logger.error("Can't read config file #{path}")
    @logger.error e
    @logger.error e.backtrace.join("\n")
    raise e
    end
    result = result.select { |v| v.first == param }
    Asserts.assert_true("Find param #{param} in #{result}") { result.count == 1 }
    result = result.first.last
    if result.nil?
      @logger.error("#{param} was not set")
      raise StandardError, "#{param} was not set"
    end
    result
  end


  private

  def read0(path, separator = '=')
    result = []
    File.open(path, 'r') do |f|
      f.each_line do |line|
        result.append(Pair.new(line.split(separator).map {|v| v.strip }))
      end
    end
    result
  end
end
