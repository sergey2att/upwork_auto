# frozen_string_literal: true

require_relative '../config_manager'

#
# Base page class
#
class BasePage
  attr_reader :driver

  def initialize(driver)
    @driver = driver
    @logger = Logger.new(STDOUT)
    @logger.progname = 'UI_Auto: Driver'
    ConfigManager.apply_default_logger_format @logger
  end

  def load(path)
    @driver.get(ConfigManager.read(ConfigManager.config_path, ['base_url']) + path)
  end

  def wait_until(seconds = 5)
    Selenium::WebDriver::Wait.new(timeout: seconds).until { yield }
  end

  def find_last(locator)
    wait_until { @driver.find_elements(locator) }.last
  end

  def title
    wait_until { @driver.title }
  end

  def scroll_to_element
    script_string = 'var viewPortHeight = Math.max(document.documentElement.clientHeight, window.innerHeight || 0);' \
                    'var elementTop = arguments[0].getBoundingClientRect().top;' \
                    'window.scrollBy(0, elementTop-(viewPortHeight/2));'
    @driver.execute_script(script_string, yield)
  end

  def scroll_and_click
    result = yield
    scroll_to_element { result }
    result.click
  end

  def find_element_or_nil
    yield
  rescue
    nil
  end

  def element_text_or_empty
    yield.text
  rescue
    ''
  end

  def find_elements_or_nil
    result = yield
    result.size.positive? ? result : nil
  end

  def displayed?(locator)
    find(locator).displayed?
  rescue Selenium::WebDriver::Error::TimeOutError
    false
  else
    true
  end

end
