# frozen_string_literal: true

#
# Simple class for collecting test statistics
#
class StatCollector
  attr_accessor :passed, :failed, :skipped

  def initialize
    @passed = 0
    @failed = 0
    @skipped = 0
  end

  def total
    passed + failed + skipped
  end

end
