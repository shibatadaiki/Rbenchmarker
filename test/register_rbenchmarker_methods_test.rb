# frozen_string_literal: true

require_relative 'test_helper'

module OptionsTestModule
  extend Rbenchmarker::ClassMethods
  def instance_method_for_module; end
  def self.class_method_for_module; end
  define_method(:dynamic_instance_method_for_module, -> {})
  define_singleton_method(:dynamic_class_method_for_module, -> {})
end

class OptionsTestClass
  def instance_method_for_class; end
  def self.class_method_for_class; end
  define_method(:dynamic_instance_method_for_class, -> {})
  define_singleton_method(:dynamic_class_method_for_class, -> {})
end

class TimesOptionTestClass
  def instance_method_for_times_option_test; p 'return_value_of_instance_method'; end
  def self.class_method_for_times_option_test; p 'return_value_of_class_method'; end
end

class RegisterRbenchmarkerMethodsTest < Minitest::Test
  def setup
    @options_test_module = OptionsTestModule.clone
    @options_test_class = OptionsTestClass.clone
    @times_options_test_class = TimesOptionTestClass.clone
  end

  def teardown
    Rbenchmarker.init_tracking_classes
    Rbenchmarker.init_object_with_has_modules
    Rbenchmarker.init_module_with_has_methods_lists
    Rbenchmarker.init_tracking_reports
    Rbenchmarker.init_log_file_path
    Rbenchmarker.setup_no_executed!
    File.delete('./rbenchmark.log') if File.exist?('./rbenchmark.log')
    $stdout = STDOUT
  end

  def test_all_option_from_class
    @options_test_class.call_register_rbenchmarker_methods({ all: __FILE__, object_type: 'Class' })
    # OptionsTestClass.ancestors.first => module_instance_with_rbenchmarker_function
    assert_equal @options_test_class.ancestors.first.instance_methods(false),
                 %I[instance_method_for_class]
    assert_equal @options_test_class.singleton_class.ancestors.first.instance_methods(false),
                 %I[class_method_for_class]
  end

  def test_all_option_from_module
    @options_test_module.call_register_rbenchmarker_methods({ all: __FILE__, object_type: 'Module' })
    assert_equal Rbenchmarker.module_with_has_methods_lists.keys.first,
                 @options_test_module.to_s.to_sym
    assert_equal Rbenchmarker.module_with_has_methods_lists.values.first.instance_methods(false),
                 %I[instance_method_for_module]
    assert_equal @options_test_module.singleton_class.ancestors.first.instance_methods(false),
                 %I[class_method_for_module]
  end

  def test_require_hidden_method_option_from_class
    @options_test_class.call_register_rbenchmarker_methods(
      { all: __FILE__, require_hidden_method: true, object_type: 'Class' }
    )
    assert_equal @options_test_class.ancestors.first.instance_methods(false).sort,
                 %I[dynamic_instance_method_for_class instance_method_for_class]
    assert_equal @options_test_class.singleton_class.ancestors.first.instance_methods(false).sort,
                 %I[class_method_for_class dynamic_class_method_for_class]
  end

  def test_require_hidden_method_option_from_module
    @options_test_module.call_register_rbenchmarker_methods(
      { all: __FILE__, require_hidden_method: true, object_type: 'Module' }
    )
    assert_equal Rbenchmarker.module_with_has_methods_lists.keys.first,
                 @options_test_module.to_s.to_sym
    assert_equal Rbenchmarker.module_with_has_methods_lists.values.first.instance_methods(false).sort,
                 %I[dynamic_instance_method_for_module instance_method_for_module]
    assert_equal @options_test_module.singleton_class.ancestors.first.instance_methods(false).sort,
                 %I[class_method_for_module dynamic_class_method_for_module]
  end

  def test_only_option
    @options_test_class.call_register_rbenchmarker_methods(
      {
        all: __FILE__,
        require_hidden_method: true,
        only: %I[dynamic_class_method_for_class instance_method_for_class],
        object_type: 'Class'
      }
    )

    assert_equal @options_test_class.ancestors.first.instance_methods(false),
                 %I[instance_method_for_class]
    assert_equal @options_test_class.singleton_class.ancestors.first.instance_methods(false),
                 %I[dynamic_class_method_for_class]
  end

  def test_except_option
    @options_test_class.call_register_rbenchmarker_methods(
      {
        all: __FILE__,
        require_hidden_method: true,
        except: %I[dynamic_class_method_for_class instance_method_for_class],
        object_type: 'Class'
      }
    )

    assert_equal @options_test_class.ancestors.first.instance_methods(false),
                 %I[dynamic_instance_method_for_class]
    assert_equal @options_test_class.singleton_class.ancestors.first.instance_methods(false),
                 %I[class_method_for_class]
  end

  def test_added_option
    @options_test_class.call_register_rbenchmarker_methods(
      {
        all: __FILE__,
        added: %I[dynamic_class_method_for_class dynamic_instance_method_for_class],
        object_type: 'Class'
      }
    )

    assert_equal @options_test_class.ancestors.first.instance_methods(false).sort,
                 %I[dynamic_instance_method_for_class instance_method_for_class]
    assert_equal @options_test_class.singleton_class.ancestors.first.instance_methods(false).sort,
                 %I[class_method_for_class dynamic_class_method_for_class]
  end

  def test_only_and_except_option
    @options_test_class.call_register_rbenchmarker_methods(
      {
        all: __FILE__,
        require_hidden_method: true,
        only: %I[dynamic_class_method_for_class instance_method_for_class],
        except: %I[dynamic_class_method_for_class instance_method_for_class],
        object_type: 'Class'
      }
    )

    # only_option > except_option
    assert_equal @options_test_class.ancestors.first.instance_methods(false),
                 %I[instance_method_for_class]
    assert_equal @options_test_class.singleton_class.ancestors.first.instance_methods(false),
                 %I[dynamic_class_method_for_class]
  end

  def test_only_and_added_option
    @options_test_class.call_register_rbenchmarker_methods(
      {
        all: __FILE__,
        require_hidden_method: true,
        only: %I[instance_method_for_class],
        added: %I[dynamic_class_method_for_class],
        object_type: 'Class'
      }
    )

    # only_option + added_option
    assert_equal @options_test_class.ancestors.first.instance_methods(false).sort,
                 %I[instance_method_for_class]
    assert_equal @options_test_class.singleton_class.ancestors.first.instance_methods(false),
                 %I[dynamic_class_method_for_class]
  end

  def test_except_and_added_option
    @options_test_class.call_register_rbenchmarker_methods(
      {
        all: __FILE__,
        require_hidden_method: true,
        except: %I[instance_method_for_class dynamic_class_method_for_class],
        added: %I[dynamic_class_method_for_class],
        object_type: 'Class'
      }
    )

    # except_option + added_option
    assert_equal @options_test_class.ancestors.first.instance_methods(false).sort,
                 %I[dynamic_instance_method_for_class]
    assert_equal @options_test_class.singleton_class.ancestors.first.instance_methods(false).sort,
                 %I[class_method_for_class dynamic_class_method_for_class]
  end

  def test_only_except_and_added_option
    @options_test_class.call_register_rbenchmarker_methods(
      {
        all: __FILE__,
        require_hidden_method: true,
        only: %I[dynamic_class_method_for_class instance_method_for_class],
        except: %I[dynamic_class_method_for_class instance_method_for_class],
        added: %I[dynamic_instance_method_for_class],
        object_type: 'Class'
      }
    )

    # only_option > except_option
    assert_equal @options_test_class.ancestors.first.instance_methods(false).sort,
                 %I[dynamic_instance_method_for_class instance_method_for_class]
    assert_equal @options_test_class.singleton_class.ancestors.first.instance_methods(false).sort,
                 %I[dynamic_class_method_for_class]
  end

  def test_label_width_option
    $stdout = StringIO.new
    @options_test_class.rbenchmarker all: __FILE__, label_width: 10
    Rbenchmarker.setup output_log_path: './'
    @options_test_class.class_method_for_class

    logs = []
    File.open('./rbenchmark.log', 'rt') { |f| f.each_line { |line| logs << line } }
    # Since get 7 default character widths, the total character width is 17.
    assert_equal $stdout.string[/^(.*)user/, 1].length, 17
  end

  def test_add_times_option
    $stdout = StringIO.new
    @times_options_test_class.rbenchmarker all: __FILE__, times: 3
    Rbenchmarker.setup output_log_path: './'
    return_value_of_class_method = @times_options_test_class.class_method_for_times_option_test
    return_value_of_instance_method = @times_options_test_class.new.instance_method_for_times_option_test

    result = $stdout.string
    assert_equal return_value_of_class_method, 'return_value_of_class_method'
    assert_equal result.scan('return_value_of_class_method').length, 3
    assert_equal result.scan('class_method_for_times_option_test(3 loops) class method').length, 1

    assert_equal return_value_of_instance_method, 'return_value_of_instance_method'
    assert_equal result.scan('return_value_of_instance_method').length, 3
    assert_equal result.scan('instance_method_for_times_option_test(3 loops) instance method').length, 1
  end

  def test_no_times_option
    $stdout = StringIO.new
    @times_options_test_class.rbenchmarker all: __FILE__
    Rbenchmarker.setup output_log_path: './'
    return_value_of_class_method = @times_options_test_class.class_method_for_times_option_test
    return_value_of_instance_method = @times_options_test_class.new.instance_method_for_times_option_test

    result = $stdout.string
    assert_equal return_value_of_class_method, 'return_value_of_class_method'
    assert_equal result.scan('return_value_of_class_method').length, 1
    assert_equal result.scan('class_method_for_times_option_test class method').length, 1

    assert_equal return_value_of_instance_method, 'return_value_of_instance_method'
    assert_equal result.scan('return_value_of_instance_method').length, 1
    assert_equal result.scan('instance_method_for_times_option_test instance method').length, 1
  end
end
