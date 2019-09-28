# frozen_string_literal: true

require 'selenium-webdriver'

#
# Simple wrapper for driver. May be reworked via builder in future
#
class Browser
  attr_reader :driver

  def initialize(browser_name, options_args, listener, driver_path)
    case browser_name
    when 'firefox'
      @service = Selenium::WebDriver::Firefox::Service
      options = Selenium::WebDriver::Firefox::Options.new(args: options_args)
      @service.driver_path = driver_path
      @driver = Selenium::WebDriver.for(:firefox, options: options, listener: listener)
    when 'chrome'
      @service = Selenium::WebDriver::Chrome::Service
      options = Selenium::WebDriver::Chrome::Options.new(args: options_args)
      @service.driver_path = driver_path
      @driver = Selenium::WebDriver.for(:chrome, options: options, listener: listener)
    else
      @service = Selenium::WebDriver::Firefox::Service
      options = Selenium::WebDriver::Firefox::Options.new(args: options_args)
      @service.driver_path = driver_path
      @driver = Selenium::WebDriver.for(:firefox, options: options, listener: listener)
    end
    delete_cookies
  end

  def delete_cookies
    @driver.manage.delete_all_cookies
  end
end
