# frozen_string_literal: true

require_relative 'executor'
require_relative 'lib/pair'

#
# Start application here
#
class Runner

  def self.parse_args
    raw_pairs = []
    combined_pairs = []
    if ARGV.empty?
      puts 'Mast be set at least one tests case'
      puts 'Example: ruby runner.rb TestClassName#test_testcase_id'
      exit(0)
    else
      ARGV.each { |item| raw_pairs.append(Pair.new(item.split('#'))) }
      # Put pairs without methods to separate array and remove from raw array
      raw_pairs.clone.filter { |v| v.last.nil? }.uniq.each do |s|
        combined_pairs.append(Pair.new(s.first, nil))
        raw_pairs.delete(s)
      end
      compare_same_class_test(raw_pairs, combined_pairs)
      combined_pairs
    end
  end

  # Any custom executor may be set here
  def self.run
    Executor.new(parse_args).run
  end

  #
  # Takes params like Pair(Class1,method1), Pair(Class1,method2)
  # And transform to Pair(Class1, method1,method2)
  #
  def self.compare_same_class_test(current_array, result)

    return result if current_array.empty?

    methods = []
    first_param = current_array[0].first
    current_array.filter { |v| v.first == current_array[0].first }.each do |v|
      methods.append(v.last)
      current_array.delete(v)
    end
    result.append(Pair.new(first_param, methods.join(',')))
    # Recursion here
    compare_same_class_test(current_array, result)
  end
end

Runner.run
