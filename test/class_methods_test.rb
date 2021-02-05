# frozen_string_literal: true

require_relative 'test_helper'

module TestRbenchmarkerPrependModule; end
module TestRbenchmarkerIncludeModule; end
module TestRbenchmarkerExtendModule; end

class TestRbenchmarkerClass
  prepend TestRbenchmarkerPrependModule
  include TestRbenchmarkerIncludeModule
  extend TestRbenchmarkerExtendModule
end

module TestRbenchmarkerModule
  prepend TestRbenchmarkerPrependModule
  include TestRbenchmarkerIncludeModule
  extend TestRbenchmarkerExtendModule
  extend Rbenchmarker::ClassMethods
end

class ClassForTestingErrorClasses; end

class ClassMethodsTest < Minitest::Test
  def teardown
    Rbenchmarker.init_tracking_classes
    Rbenchmarker.init_tracking_modules
    Rbenchmarker.init_object_with_has_modules
    Rbenchmarker.setup_no_executed!
  end

  def test_rbenchmarker_has_all_options_for_class
    TestRbenchmarkerClass.rbenchmarker all: __FILE__,
                                       only: ['method1'],
                                       except: [:method2],
                                       added: ['method3'],
                                       label_width: 25,
                                       times: 10,
                                       require_hidden_method: true,
                                       prepend: [TestRbenchmarkerPrependModule],
                                       include: [TestRbenchmarkerIncludeModule],
                                       extend: [TestRbenchmarkerExtendModule]

    assert_equal Rbenchmarker.tracking_classes,
                 [
                   [
                     TestRbenchmarkerClass,
                     {
                       all: __FILE__,
                       only: [:method1],
                       except: [:method2],
                       added: [:method3],
                       label_width: 25,
                       times: 10,
                       require_hidden_method: true,
                       object_type: 'Class'
                     }
                   ]
                 ]
    assert_equal Rbenchmarker.object_with_has_modules,
                 [
                   [
                     TestRbenchmarkerClass,
                     {
                       prepend: [TestRbenchmarkerPrependModule],
                       include: [TestRbenchmarkerIncludeModule],
                       extend: [TestRbenchmarkerExtendModule]
                     }
                   ]
                 ]
  end

  def test_rbenchmarker_has_no_option_for_class
    TestRbenchmarkerClass.rbenchmarker
    assert_equal Rbenchmarker.tracking_classes, [[TestRbenchmarkerClass, { object_type: 'Class' }]]
    assert_equal Rbenchmarker.object_with_has_modules, [[TestRbenchmarkerClass, {}]]
  end

  def test_rbenchmarker_has_all_options_for_module
    TestRbenchmarkerModule.rbenchmarker all: __FILE__,
                                        only: [:method1],
                                        except: ['method2'],
                                        added: [:method3],
                                        label_width: 5,
                                        times: 5,
                                        require_hidden_method: false,
                                        prepend: [TestRbenchmarkerPrependModule],
                                        include: [TestRbenchmarkerIncludeModule],
                                        extend: [TestRbenchmarkerExtendModule]

    assert_equal Rbenchmarker.tracking_modules,
                 [
                   [
                     TestRbenchmarkerModule,
                     {
                       all: __FILE__,
                       only: [:method1],
                       except: [:method2],
                       added: [:method3],
                       label_width: 5,
                       times: 5,
                       require_hidden_method: false,
                       object_type: 'Module'
                     }
                   ]
                 ]
    assert_equal Rbenchmarker.object_with_has_modules, [
      [
        TestRbenchmarkerModule,
        {
          prepend: [TestRbenchmarkerPrependModule],
          include: [TestRbenchmarkerIncludeModule],
          extend: [TestRbenchmarkerExtendModule]
        }
      ]
    ]
  end

  def test_rbenchmarker_has_no_option_for_module
    TestRbenchmarkerModule.rbenchmarker
    assert_equal Rbenchmarker.tracking_modules,
                 [[TestRbenchmarkerModule, { object_type: 'Module' }]]
    assert_equal Rbenchmarker.object_with_has_modules, [[TestRbenchmarkerModule, {}]]
  end

  def test_rbenchmarker_validation_check_TargetFilePathError
    e = assert_raises Rbenchmarker::TargetFilePathError do
      ClassForTestingErrorClasses.rbenchmarker all: 0
    end
    assert_equal e.message, 'Must be specify an existing file path. Unless there is a special reason, specify the return value of the "__FILE__" method in the all argument.'

    e = assert_raises Rbenchmarker::TargetFilePathError do
      ClassForTestingErrorClasses.rbenchmarker all: 'not__FILE__'
    end
    assert_equal e.message, 'Must be specify an existing file path. Unless there is a special reason, specify the return value of the "__FILE__" method in the all argument.'
  end

  def test_rbenchmarker_validation_check_OnlyMethodDesignationError
    e = assert_raises Rbenchmarker::OnlyMethodDesignationError do
      ClassForTestingErrorClasses.rbenchmarker only: 'not_array'
    end
    assert_equal e.message, '"Only" option must be an array containing only "String" or "Symbol".'

    e = assert_raises Rbenchmarker::OnlyMethodDesignationError do
      ClassForTestingErrorClasses.rbenchmarker only: [0]
    end
    assert_equal e.message, '"Only" option must be an array containing only "String" or "Symbol".'
  end

  def test_rbenchmarker_validation_check_ExceptMethodDesignationError
    e = assert_raises Rbenchmarker::ExceptMethodDesignationError do
      ClassForTestingErrorClasses.rbenchmarker except: 'not_array'
    end
    assert_equal e.message, '"Except" option must be an array containing only "String" or "Symbol".'

    e = assert_raises Rbenchmarker::ExceptMethodDesignationError do
      ClassForTestingErrorClasses.rbenchmarker except: [0]
    end
    assert_equal e.message, '"Except" option must be an array containing only "String" or "Symbol".'
  end

  def test_rbenchmarker_validation_check_AddedMethodDesignationError
    e = assert_raises Rbenchmarker::AddedMethodDesignationError do
      ClassForTestingErrorClasses.rbenchmarker added: 'not_array'
    end
    assert_equal e.message, '"Added" option must be an array containing only "String" or "Symbol".'

    e = assert_raises Rbenchmarker::AddedMethodDesignationError do
      ClassForTestingErrorClasses.rbenchmarker added: [0]
    end
    assert_equal e.message, '"Added" option must be an array containing only "String" or "Symbol".'
  end

  def test_rbenchmarker_validation_check_PrependModuleDesignationError
    e = assert_raises Rbenchmarker::PrependModuleDesignationError do
      ClassForTestingErrorClasses.rbenchmarker prepend: 'not_array'
    end
    assert_equal e.message, '"prepend" option must be an array containing only the defined "Module".'

    e = assert_raises Rbenchmarker::PrependModuleDesignationError do
      ClassForTestingErrorClasses.rbenchmarker prepend: [0]
    end
    assert_equal e.message, '"prepend" option must be an array containing only the defined "Module".'
  end

  def test_rbenchmarker_validation_check_IncludeModuleDesignationError
    e = assert_raises Rbenchmarker::IncludeModuleDesignationError do
      ClassForTestingErrorClasses.rbenchmarker include: 'not_array'
    end
    assert_equal e.message, '"include" option must be an array containing only the defined "Module".'

    e = assert_raises Rbenchmarker::IncludeModuleDesignationError do
      ClassForTestingErrorClasses.rbenchmarker include: [0]
    end
    assert_equal e.message, '"include" option must be an array containing only the defined "Module".'
  end

  def test_rbenchmarker_validation_check_ExtendModuleDesignationError
    e = assert_raises Rbenchmarker::ExtendModuleDesignationError do
      ClassForTestingErrorClasses.rbenchmarker extend: 'not_array'
    end
    assert_equal e.message, '"extend" option must be an array containing only the defined "Module".'

    e = assert_raises Rbenchmarker::ExtendModuleDesignationError do
      ClassForTestingErrorClasses.rbenchmarker extend: [0]
    end
    assert_equal e.message, '"extend" option must be an array containing only the defined "Module".'
  end
end
