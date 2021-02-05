# frozen_string_literal: true

require_relative 'test_helper'

class NumberOfExecutionsOptionTestClass
  def instance_method_for_times_option_test; end
  def self.class_method_for_times_option_test; end
end

class RbenchmarkerLogTest < Minitest::Test
  def teardown
    Rbenchmarker.init_tracking_classes
    Rbenchmarker.init_log_file_path
    Rbenchmarker.init_tracking_reports
    Rbenchmarker.init_object_with_has_modules
    Rbenchmarker.setup_no_executed!
    File.delete('./rbenchmark.log') if File.exist?('./rbenchmark.log')
    $stdout = STDOUT
  end

  def test_init_log
    assert_equal Rbenchmarker.setup(output_log_path: './'), true
    logs = []
    File.open('./rbenchmark.log', 'rt') { |f| f.each_line { |line| logs << line } }

    assert_equal logs[0].include?('by logger.rb'), true
    assert_equal logs[1].include?('== Start recording Rbenchmarker =='), true
  end

  def test_puts_log
    assert_equal Rbenchmarker.setup(output_log_path: './'), true
    Rbenchmarker.add_report(
      :sample_method_time,
      {
        utime: [0.0001],
        stime: [0.0002],
        total: [0.0003],
        real: [0.0004],
        number_of_executions: 1
      }
    )
    Rbenchmarker.add_report(
      :sample_method_time,
      {
        utime: [0.0002, 0.0003, 0.0004],
        stime: [0.0003, 0.0004, 0.0005],
        total: [0.0004, 0.0005, 0.0006],
        real: [0.0005, 0.0006, 0.0007],
        number_of_executions: 3
      }
    )

    logs = []
    File.open('./rbenchmark.log', 'rt') { |f| f.each_line { |line| logs << line } }

    assert_equal logs[4].include?('sample_method_time: current time'), true
    assert_equal logs[5].include?('user: 0.00010000, system: 0.00020000, total: 0.00030000, real: 0.00040000'), true
    assert_equal logs[6].include?('sample_method_time: total time for 1 times called'), true
    assert_equal logs[7].include?('user: 0.00010000, system: 0.00020000, total: 0.00030000, real: 0.00040000'), true
    assert_equal logs[8].include?('sample_method_time: avarage time'), true
    assert_equal logs[9].include?('user: 0.00010000, system: 0.00020000, total: 0.00030000, real: 0.00040000'), true

    assert_equal logs[12].include?('sample_method_time: current time'), true
    assert_equal logs[13].include?('user: 0.00040000, system: 0.00050000, total: 0.00060000, real: 0.00070000'), true
    assert_equal logs[14].include?('sample_method_time: total time for 3 times called'), true
    assert_equal logs[15].include?('user: 0.00090000, system: 0.00120000, total: 0.00150000, real: 0.00180000'), true
    assert_equal logs[16].include?('sample_method_time: avarage time'), true
    assert_equal logs[17].include?('user: 0.00030000, system: 0.00040000, total: 0.00050000, real: 0.00060000'), true
  end

  def test_number_of_executions_option_test
    $stdout = StringIO.new

    NumberOfExecutionsOptionTestClass.rbenchmarker all: __FILE__
    Rbenchmarker.setup output_log_path: './'
    3.times { NumberOfExecutionsOptionTestClass.class_method_for_times_option_test }
    3.times { NumberOfExecutionsOptionTestClass.new.instance_method_for_times_option_test }

    2.times do
      NumberOfExecutionsOptionTestClass.class_method_for_times_option_test
      NumberOfExecutionsOptionTestClass.new.instance_method_for_times_option_test
    end

    logs = []
    File.open('./rbenchmark.log', 'rt') { |f| f.each_line { |line| logs << line } }

    assert_equal logs[6], "report def class_method_for_times_option_test class method: total time for 1 times called\n"
    assert_equal logs[14], "report def class_method_for_times_option_test class method: total time for 2 times called\n"
    assert_equal logs[22], "report def class_method_for_times_option_test class method: total time for 3 times called\n"

    assert_equal logs[30], "report def instance_method_for_times_option_test instance method: total time for 1 times called\n"
    assert_equal logs[38], "report def instance_method_for_times_option_test instance method: total time for 2 times called\n"
    assert_equal logs[46], "report def instance_method_for_times_option_test instance method: total time for 3 times called\n"

    assert_equal logs[54], "report def class_method_for_times_option_test class method: total time for 4 times called\n"
    assert_equal logs[62], "report def instance_method_for_times_option_test instance method: total time for 4 times called\n"

    assert_equal logs[70], "report def class_method_for_times_option_test class method: total time for 5 times called\n"
    assert_equal logs[78], "report def instance_method_for_times_option_test instance method: total time for 5 times called\n"
  end
end
