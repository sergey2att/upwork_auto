# frozen_string_literal: true

require 'selenium-webdriver'
require_relative '../config_manager'
require_relative '../utils/logger'

#
# Let's log main driver actions here
#
class DriverListener < Selenium::WebDriver::Support::AbstractEventListener
  def initialize
    @logger = SimpleLog.new
    @logger.progname = 'UI_Auto: Driver'
  end

  def after_navigate_to(url, _driver)
    @logger.info("Navigated to #{url}")
  end

  def before_find(_by, what, _driver)
    @logger.info("Finding element #{what}")
  end

  def after_find(_by, what, _driver)
    @logger.info("Found element(s) #{what}")
  end

  def before_click(element, driver)
    @logger.info("Clicking on #{element.text}")
    @pre_click_url = driver.current_url
  end

  def after_click(_element, driver)
    unless @pre_click_url == driver.current_url
      @logger.info("URL changed to #{driver.current_url}")
    end
  end
end
