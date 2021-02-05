# frozen_string_literal: true

require_relative 'test_helper'

module IncludeTestModule
  extend Rbenchmarker::ClassMethods
  def include_test_method; end
end
module ExtendTestModule
  extend Rbenchmarker::ClassMethods
  def extend_test_method; end
end
module PrependTestModule
  extend Rbenchmarker::ClassMethods
  def prepend_test_method; end
end
module RegisterRbenchmarkerMethodsToModuleTestModule; extend Rbenchmarker::ClassMethods; end
class RegisterRbenchmarkerMethodsToModuleTestClass; end

class PrependModulesTest < Minitest::Test
  def setup
    @include_test_module = IncludeTestModule.clone
    @extend_test_module = ExtendTestModule.clone
    @prepend_test_module = PrependTestModule.clone
    @test_module = RegisterRbenchmarkerMethodsToModuleTestModule.clone
    @test_class = RegisterRbenchmarkerMethodsToModuleTestClass.clone

    @include_test_module.rbenchmarker all: __FILE__
    @extend_test_module.rbenchmarker all: __FILE__
    @prepend_test_module.rbenchmarker all: __FILE__

    @test_module.prepend @prepend_test_module
    @test_module.include @include_test_module
    @test_module.extend @extend_test_module
    @test_module.rbenchmarker all: __FILE__,
                              include: [@include_test_module],
                              extend: [@extend_test_module],
                              prepend: [@prepend_test_module]

    @test_class.prepend @prepend_test_module
    @test_class.include @include_test_module
    @test_class.extend @extend_test_module
    @test_class.rbenchmarker all: __FILE__,
                             include: [@include_test_module],
                             extend: [@extend_test_module],
                             prepend: [@prepend_test_module]
  end

  def teardown
    Rbenchmarker.init_tracking_classes
    Rbenchmarker.init_tracking_modules
    Rbenchmarker.init_object_with_has_modules
    Rbenchmarker.init_module_with_has_methods_lists
    Rbenchmarker.init_log_file_path
    Rbenchmarker.setup_no_executed!
    File.delete('./rbenchmark.log') if File.exist?('./rbenchmark.log')
  end

  def test_register_rbenchmarker_methods_to_module
    Rbenchmarker.setup output_log_path: './'

    assert_equal @test_module.ancestors[0].instance_methods(false), [:prepend_test_method]
    assert_equal @test_module.ancestors[1].instance_methods(false), [:prepend_test_method]
    assert_equal @test_module.ancestors[2].instance_methods(false), []
    assert_equal @test_module.ancestors[3].instance_methods(false), [:include_test_method]
    assert_equal @test_module.ancestors[4].instance_methods(false), [:include_test_method]
    assert_equal @test_module.singleton_class.ancestors[2].instance_methods(false), [:extend_test_method]
    assert_equal @test_module.singleton_class.ancestors[3].instance_methods(false), [:extend_test_method]

    assert_equal @test_class.ancestors[0].instance_methods(false), [:prepend_test_method]
    assert_equal @test_class.ancestors[1].instance_methods(false), []
    assert_equal @test_class.ancestors[2].instance_methods(false), [:prepend_test_method]
    assert_equal @test_class.ancestors[3].instance_methods(false), []
    assert_equal @test_class.ancestors[4].instance_methods(false), [:include_test_method]
    assert_equal @test_class.ancestors[5].instance_methods(false), [:include_test_method]
    assert_equal @test_class.singleton_class.ancestors[2].instance_methods(false), [:extend_test_method]
    assert_equal @test_class.singleton_class.ancestors[3].instance_methods(false), [:extend_test_method]
  end

  def test_except_modules_option
    Rbenchmarker.setup output_log_path: './', except_modules: [@prepend_test_module]

    assert_equal @test_module.ancestors[0].instance_methods(false), [:prepend_test_method]
    assert_equal @test_module.ancestors[1].instance_methods(false), []
    assert_equal @test_module.ancestors[2].instance_methods(false), [:include_test_method]
    assert_equal @test_module.ancestors[3].instance_methods(false), [:include_test_method]
    assert_equal @test_module.singleton_class.ancestors[2].instance_methods(false), [:extend_test_method]
    assert_equal @test_module.singleton_class.ancestors[3].instance_methods(false), [:extend_test_method]

    assert_equal @test_class.ancestors[0].instance_methods(false), []
    assert_equal @test_class.ancestors[1].instance_methods(false), [:prepend_test_method]
    assert_equal @test_class.ancestors[2].instance_methods(false), []
    assert_equal @test_class.ancestors[3].instance_methods(false), [:include_test_method]
    assert_equal @test_class.ancestors[4].instance_methods(false), [:include_test_method]
    assert_equal @test_class.singleton_class.ancestors[2].instance_methods(false), [:extend_test_method]
    assert_equal @test_class.singleton_class.ancestors[3].instance_methods(false), [:extend_test_method]
  end
end
