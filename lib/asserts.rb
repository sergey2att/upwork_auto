# frozen_string_literal: true

require_relative '../config_manager'

# Simple asserts.
# TODO: add logging
class Asserts

  def self.assert_true(message = '')
    unless yield
      raise AssertionError, "Expected 'true' but got 'false'. '#{message}'"
    end

    puts("Assertion: Expected 'true' and got 'true'. '#{message}'")
  end

  def self.assert_equal(first, second, message = '')
    unless first == second
      raise AssertionError, "Assertion error: '#{first}' is not equal to '#{second}'. '#{message}'"
    end

    puts("Assertion: '#{first}' is equal to '#{second}'. '#{message}'")
  end

  def self.assert_false(message = '')
    if yield
      raise AssertionError, "Expected 'false' but got 'true'. '#{message}'"
    end

    puts("Assertion : expected 'false' and got 'false'. '#{message}'")
  end

end

class AssertionError < RuntimeError

end
