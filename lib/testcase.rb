# frozen_string_literal: true

require 'selenium-webdriver'
require_relative '../config_manager'
#
# Base class for test scenarios
#
class TestCase
  attr_accessor :driver

  def initialize(driver)
    @driver = driver
  end

  # Action before test execution
  def setup
    prepare_browser
    driver.manage.delete_all_cookies
    driver.manage.timeouts.implicit_wait =
      ConfigManager.shared.read(ConfigManager.base_config_path, 'driver.implicit_wait').to_i
  end

  # Action after test execution
  def teardown
    # Any action after test is completed
  end

  # After class action
  def after_class
    driver.quit
  end

  private

  # let's open new tab and close other before each test run
  def prepare_browser
    handles = driver.window_handles.map(&:to_s)
    driver.execute_script "window.open('','_blank');"
    sleep 3
    driver.window_handles.each do |handle|
      driver.switch_to.window(handle)
      sleep 1
      driver.close if handles.include? handle.to_s
    end
    driver.switch_to.window(driver.window_handles[0])
  end
end
