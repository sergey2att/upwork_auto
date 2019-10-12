# frozen_string_literal: true

require_relative 'utils/csv_reader'
require_relative 'utils/logger'
require_relative 'lib/statistic'
require_relative 'lib/browser'
require_relative 'config_manager'
require_relative 'lib/driver_listener'
Dir[File.join(File.dirname(__FILE__), '/tests/*.rb')].each { |f| require f }

#
# Create tests class instance and run available tests. All tests execution logic here
#
class Executor

  def initialize(args)
    @args = args
    @statistic = StatCollector.new
    @logger = SimpleLog.new
    @logger.progname = 'UI_Auto: Executor'
    Selenium::WebDriver.logger.level = ConfigManager.shared.read(ConfigManager.base_config_path, 'log_level')
  end

  # tests execution logic
  def execute(obj, method, method_args = nil)
    begin
    if obj.respond_to? method
      @logger.info("Test '#{obj.class.name}##{method}' starts successfully")
      # before each test action
      obj.setup
      if method_args.nil?
        obj.public_send(method)
      else
        obj.public_send(method, method_args)
      end
      # after each test action
      obj.teardown
      @statistic.passed += 1
      @logger.info("Test '#{obj.class.name}##{method}' passed")
    else
      @statistic.skipped += 1
      @logger.info("Test '#{obj.class.name}##{method}' skipped")
    end
    rescue => e
    @logger.info("Test '#{obj.class.name}##{method}' failed")
    @logger.error e
    @logger.error e.backtrace.join("\n")
    @statistic.failed += 1
    end
  end

  # entry point method
  def run
    @args.each do |a|
      constant = Object.const_get(a.first)
      # Per class driver instance will use in current implementation
      obj = constant.new(prepare_driver)
      # takes all instance method stars from 'test_' prefix
      result = constant.instance_methods(false).grep(/^test_.*/)
      # if we set particular test, let's find it
      result = result.select { |x| a.last.split(',').map(&:to_sym).include? x } unless a.last.nil?
      result.each do |method_name|
        # parse test data for test. Just one method argument supports there,
        # but this logic can be easily extended by adding string splitter
        test_data = prepare_test_data(constant.to_s + '#' + method_name.to_s)
        if test_data.size.positive?
          test_data.each { |data| execute(obj, method_name, data) }
        else
          execute(obj, method_name, nil)
        end
      end
      @logger.info("Result: passed - #{@statistic.passed}, " \
                   "failed - #{@statistic.failed}, " \
                   "skipped - #{@statistic.skipped}")
      # after class action
      obj.after_class
    end
  end

  private

  def prepare_driver
    browser = ConfigManager.shared.read(ConfigManager.base_config_path, 'driver.browser')
    driver_path = ConfigManager.shared.read(ConfigManager.base_config_path, 'driver.path')
    Browser.new(browser, [], DriverListener.new, driver_path).driver
  end

  def prepare_test_data(test_case)
    CSVReader.new.read(ConfigManager.test_data_path)
       .filter { |a| a['id'] == test_case }
       .map { |v| v['args'] }
  end

end
