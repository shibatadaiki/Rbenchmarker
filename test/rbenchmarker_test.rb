# frozen_string_literal: true

require_relative 'test_helper'

module RbenchmarkerTestModule
  extend Rbenchmarker::ClassMethods
  def self.class_test_method_for_module; end
  def instance_test_method_for_module; end
end

class RbenchmarkerTestClass
  def self.class_test_method_for_class; end
  def instance_test_method_for_class; end
end

class RbenchmarkerTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Rbenchmarker::VERSION
  end

  def setup
    @test_module = RbenchmarkerTestModule.clone
    @test_class = RbenchmarkerTestClass.clone
  end

  def teardown
    Rbenchmarker.init_tracking_classes
    Rbenchmarker.init_tracking_modules
    Rbenchmarker.init_object_with_has_modules
    Rbenchmarker.init_module_with_has_methods_lists
    Rbenchmarker.init_tracking_reports
    Rbenchmarker.init_log_file_path
    Rbenchmarker.setup_no_executed!
    File.delete('./rbenchmark.log') if File.exist?('./rbenchmark.log')
    $stdout = STDOUT
  end

  def test_initial_value_of_setup_executed
    assert_equal Rbenchmarker.setup_executed?, false
  end

  def test_if_can_change_value_of_setup_executed
    Rbenchmarker.setup_executed!
    assert_equal Rbenchmarker.setup_executed?, true
    Rbenchmarker.setup_no_executed!
    assert_equal Rbenchmarker.setup_executed?, false
  end

  def test_initial_value_of_rbench_classes_instance_variable
    assert_equal Rbenchmarker.tracking_classes, []
  end

  def test_if_can_change_value_of_rbench_classes_instance_variable
    Rbenchmarker.add_class('rbench_target_class')
    assert_equal Rbenchmarker.tracking_classes, ['rbench_target_class']
    Rbenchmarker.init_tracking_classes
    assert_equal Rbenchmarker.tracking_classes, []
  end

  def test_initial_value_of_rbench_modules_instance_variable
    assert_equal Rbenchmarker.tracking_modules, []
  end

  def test_if_can_change_value_of_rbench_modules_instance_variable
    Rbenchmarker.add_module('rbench_target_module')
    assert_equal Rbenchmarker.tracking_modules, ['rbench_target_module']
    Rbenchmarker.init_tracking_modules
    assert_equal Rbenchmarker.tracking_modules, []
  end

  def test_initial_value_of_object_with_has_modules_instance_variable
    assert_equal Rbenchmarker.object_with_has_modules, []
  end

  def test_if_can_change_value_of_object_with_has_modules_instance_variable
    granted_modules = { prepend: [Module.new], include: [Module.new], extend: [Module.new] }
    Rbenchmarker.add_object_with_modules([Object, granted_modules])
    assert_equal Rbenchmarker.object_with_has_modules, [[Object, granted_modules]]
    Rbenchmarker.init_object_with_has_modules
    assert_equal Rbenchmarker.object_with_has_modules, []
  end

  def test_initial_value_of_module_with_has_methods_lists_instance_variable
    assert_equal Rbenchmarker.module_with_has_methods_lists, {}
  end

  def test_if_can_change_value_of_module_with_has_methods_lists_instance_variable
    module_obj = Module.new
    Rbenchmarker.add_module_with_has_methods_list(:module, module_obj)
    assert_equal Rbenchmarker.module_with_has_methods_lists, { module: module_obj }
    Rbenchmarker.init_module_with_has_methods_lists
    assert_equal Rbenchmarker.module_with_has_methods_lists, {}
  end

  def test_initial_value_of_bm_reports_instance_variable
    assert_equal Rbenchmarker.tracking_reports, {}
  end

  def test_if_can_change_value_of_bm_reports_instance_variable
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
    assert_equal Rbenchmarker.tracking_reports,
                 {
                   sample_method_time:
                     {
                       utime: [0.0001],
                       stime: [0.0002],
                       total: [0.0003],
                       real: [0.0004],
                       number_of_executions: 1
                     }
                 }
    Rbenchmarker.init_tracking_reports
    assert_equal Rbenchmarker.tracking_reports, {}
  end

  def test_initial_value_of_rbenchmarker_log_file_path_instance_variable
    if Dir.exist? "#{Dir.pwd}/log"
      assert_equal Rbenchmarker.output_log_file_path, "#{Dir.pwd}/log/rbenchmark.log"
    else
      assert_equal Rbenchmarker.output_log_file_path, "#{Dir.pwd}/rbenchmark.log"
    end
  end

  def test_if_can_change_value_of_log_file_path_instance_variable
    old_log_file_path = Rbenchmarker.output_log_file_path
    Rbenchmarker.change_output_log_file_path('/test_tmp/rbenchmark.log')
    assert_equal Rbenchmarker.output_log_file_path, '/test_tmp/rbenchmark.log'
    Rbenchmarker.init_log_file_path
    assert_equal Rbenchmarker.output_log_file_path, old_log_file_path
  end

  def test_setup_option_switch_off
    assert_nil Rbenchmarker.setup(switch: 'off')
  end

  def test_setup_executed?
    $stdout = StringIO.new
    Rbenchmarker.setup output_log_path: '.'
    assert_nil Rbenchmarker.setup output_log_path: '.'

    result = $stdout.string
    assert_equal result, "setup has already been executed.\n"
  end

  def before_test_setup_option_switch_on(except_classes: [], except_modules: [])
    $stdout = StringIO.new

    @test_module.class_test_method_for_module
    @test_class.class_test_method_for_class
    @test_class.new.instance_test_method_for_class

    @test_module.rbenchmarker all: __FILE__
    @test_class.include @test_module
    @test_class.extend @test_module
    @test_class.rbenchmarker all: __FILE__, include: [@test_module], extend: [@test_module]

    assert_equal Rbenchmarker.setup(
      output_log_path: '.', except_classes: except_classes, except_modules: except_modules
    ), true

    @test_module.class_test_method_for_module
    @test_class.class_test_method_for_class
    @test_class.instance_test_method_for_module
    @test_class.new.instance_test_method_for_class
    @test_class.new.instance_test_method_for_module

    logs = []
    File.open('./rbenchmark.log', 'rt') { |f| f.each_line { |line| logs << line } }

    logs
  end

  def test_setup_option_switch_on
    logs = before_test_setup_option_switch_on(except_classes: [], except_modules: [])

    assert_equal logs[4], "report def class_test_method_for_module module method: current time\n"
    assert_equal logs[12], "report def class_test_method_for_class class method: current time\n"
    assert_equal logs[20], "report def instance_test_method_for_module module method: current time\n"
    assert_equal logs[28], "report def instance_test_method_for_class instance method: current time\n"
    assert_equal logs[36], "report def instance_test_method_for_module module method: current time\n"

    assert_equal logs[6], "report def class_test_method_for_module module method: total time for 1 times called\n"
    assert_equal logs[14], "report def class_test_method_for_class class method: total time for 1 times called\n"
    assert_equal logs[22], "report def instance_test_method_for_module module method: total time for 1 times called\n"
    assert_equal logs[30], "report def instance_test_method_for_class instance method: total time for 1 times called\n"
    assert_equal logs[38], "report def instance_test_method_for_module module method: total time for 2 times called\n"

    assert_equal File.delete('./rbenchmark.log'), 1
  end

  def test_setup_option_except_classes
    logs = before_test_setup_option_switch_on(except_classes: [@test_class], except_modules: [])

    assert_equal logs[4], "report def class_test_method_for_module module method: current time\n"
    assert_equal logs[12], "report def instance_test_method_for_module module method: current time\n"
    assert_equal logs[20], "report def instance_test_method_for_module module method: current time\n"
    assert_nil logs[28]
    assert_nil logs[36]

    assert_equal logs[6], "report def class_test_method_for_module module method: total time for 1 times called\n"
    assert_equal logs[14], "report def instance_test_method_for_module module method: total time for 1 times called\n"
    assert_equal logs[22], "report def instance_test_method_for_module module method: total time for 2 times called\n"
    assert_nil logs[30]
    assert_nil logs[38]

    assert_equal File.delete('./rbenchmark.log'), 1
  end

  def test_setup_option_except_modules
    logs = before_test_setup_option_switch_on(except_classes: [], except_modules: [@test_module])

    assert_equal logs[4], "report def class_test_method_for_class class method: current time\n"
    assert_equal logs[12], "report def instance_test_method_for_class instance method: current time\n"
    assert_nil logs[20]
    assert_nil logs[28]
    assert_nil logs[36]

    assert_equal logs[6], "report def class_test_method_for_class class method: total time for 1 times called\n"
    assert_equal logs[14], "report def instance_test_method_for_class instance method: total time for 1 times called\n"
    assert_nil logs[22]
    assert_nil logs[30]
    assert_nil logs[38]

    assert_equal File.delete('./rbenchmark.log'), 1
  end

  def test_setup_validation_TargetDirPathError
    e = assert_raises Rbenchmarker::TargetDirPathError do
      Rbenchmarker.setup(output_log_path: '/not_exist_dir/')
    end
    assert_equal e.message, 'In the argument of "output_log_file_path", specify the path of the directory where you want to place the log.'
  end

  def test_setup_validation_ExceptClassDesignationError
    e = assert_raises Rbenchmarker::ExceptClassDesignationError do
      Rbenchmarker.setup(except_classes: 'not_array')
    end
    assert_equal e.message, '"except_classes" option must be an array containing only "Class".'

    e = assert_raises Rbenchmarker::ExceptClassDesignationError do
      Rbenchmarker.setup(except_classes: ['not_class'])
    end
    assert_equal e.message, '"except_classes" option must be an array containing only "Class".'
  end

  def test_setup_validation_ExceptModuleDesignationError
    e = assert_raises Rbenchmarker::ExceptModuleDesignationError do
      Rbenchmarker.setup(except_modules: 'not_array')
    end
    assert_equal e.message, '"except_modules" option must be an array containing only the defined "Module".'

    e = assert_raises Rbenchmarker::ExceptModuleDesignationError do
      Rbenchmarker.setup(except_modules: ['not_module'])
    end
    assert_equal e.message, '"except_modules" option must be an array containing only the defined "Module".'
  end
end
