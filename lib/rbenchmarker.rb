# frozen_string_literal: true

require_relative 'rbenchmarker/version'
require_relative 'rbenchmarker/class_methods'
require_relative 'rbenchmarker/prepend_modules'
require_relative 'rbenchmarker/rbenchmarker_log'
require_relative 'rbenchmarker/exceptions'

module Rbenchmarker
  LOG_DIRECTORY = 'log'
  LOG_FILE_NAME = 'rbenchmark.log'

  @setup_executed = false
  @rbench_classes = []
  @rbench_modules = []
  @object_with_has_modules = []
  @module_with_has_methods_lists = {}
  @bm_reports = {}
  @rbenchmarker_log_file_path = if Dir.exist? "#{Dir.pwd}/#{LOG_DIRECTORY}"
                                  "#{Dir.pwd}/#{LOG_DIRECTORY}/#{LOG_FILE_NAME}"
                                else
                                  "#{Dir.pwd}/#{LOG_FILE_NAME}"
                                end

  def self.setup_executed?
    @setup_executed
  end

  def self.setup_executed!
    @setup_executed = true
  end

  def self.setup_no_executed!
    @setup_executed = false
  end

  def self.tracking_classes
    @rbench_classes
  end

  def self.add_class(value)
    @rbench_classes << value
  end

  def self.init_tracking_classes
    @rbench_classes = []
  end

  def self.tracking_modules
    @rbench_modules
  end

  def self.add_module(value)
    @rbench_modules << value
  end

  def self.init_tracking_modules
    @rbench_modules = []
  end

  def self.object_with_has_modules
    @object_with_has_modules
  end

  def self.add_object_with_modules(value)
    @object_with_has_modules << value
  end

  def self.init_object_with_has_modules
    @object_with_has_modules = []
  end

  def self.module_with_has_methods_lists
    @module_with_has_methods_lists
  end

  def self.add_module_with_has_methods_list(key, value)
    @module_with_has_methods_lists[key] = value
  end

  def self.init_module_with_has_methods_lists
    @module_with_has_methods_lists = {}
  end

  def self.tracking_reports
    @bm_reports
  end

  def self.add_report(key, value)
    @bm_reports[key] = value
    callbacks_self_add_report(key, value)
  end

  def self.init_tracking_reports
    @bm_reports = {}
  end

  def self.output_log_file_path
    @rbenchmarker_log_file_path
  end

  def self.change_output_log_file_path(path_text)
    @rbenchmarker_log_file_path = path_text
  end

  def self.init_log_file_path
    @rbenchmarker_log_file_path = if Dir.exist? "#{Dir.pwd}/#{LOG_DIRECTORY}"
                                    "#{Dir.pwd}/#{LOG_DIRECTORY}/#{LOG_FILE_NAME}"
                                  else
                                    "#{Dir.pwd}/#{LOG_FILE_NAME}"
                                  end
  end

  # This method must read (execute) after reading all files except this configuration file.
  def self.setup(switch: 'on', output_log_path: nil, except_classes: [], except_modules: [])
    return if %w[off OFF].include?(switch)
    return puts 'setup has already been executed.' if setup_executed?

    setup_validation_check(except_classes, except_modules, output_log_path)

    change_output_log_file_path "#{output_log_path}/#{LOG_FILE_NAME}" if output_log_path

    tracking_classes.each do |benchmark_target_class, options|
      next if except_classes.include?(benchmark_target_class)

      benchmark_target_class.call_register_rbenchmarker_methods(options)
    end

    tracking_modules.each do |benchmark_target_module, options|
      next if except_modules.include?(benchmark_target_module)

      benchmark_target_module.call_register_rbenchmarker_methods(options)
    end

    Rbenchmarker::PrependModules.register_rbenchmarker_methods_to_module(
      object_with_has_modules, module_with_has_methods_lists, except_modules
    )

    Rbenchmarker::RbenchmarkerLog.init_log
    setup_executed!
  end

  # private

  def self.setup_validation_check(except_classes, except_modules, output_log_path)
    raise ExceptClassDesignationError unless except_classes.is_a?(Array)
    raise ExceptClassDesignationError unless except_classes.all? { |obj| obj.class.to_s == 'Class' }
    raise ExceptModuleDesignationError unless except_modules.is_a?(Array)
    raise ExceptModuleDesignationError unless except_modules.all? { |obj| obj.class.to_s == 'Module' }
    raise TargetDirPathError if output_log_path && !Dir.exist?(output_log_path)
  end

  def self.callbacks_self_add_report(key, value)
    Rbenchmarker::RbenchmarkerLog.puts_log(key, value)
  end

  private_class_method :setup_validation_check
  private_class_method :callbacks_self_add_report
end
