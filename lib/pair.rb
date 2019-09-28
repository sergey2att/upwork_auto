# frozen_string_literal: true

#  Simple pair structure
class Pair
  attr_accessor :first, :last

  def initialize(*values)
    values.flatten.tap do |arguments|
      raise ArgumentError, 'Max two elements possible' if more_than_two_args?(arguments)

      @first = arguments[0]
      @last = arguments[1]
    end
  end

  private

  def more_than_two_args?(arguments)
    arguments.length > 2
  end
end
