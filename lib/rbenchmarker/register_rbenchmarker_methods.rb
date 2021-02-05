# frozen_string_literal: true

require 'benchmark'

module Rbenchmarker
  module RegisterRbenchmarkerMethods
    DEFAULT_REPORT_LENGTH = 30
    TIMES_THE_METHOD_WAS_CALLED = 1

    # "rbenchmarker" needs to start processing after all the methods of the target class(file) have been read,
    # Rbenchmarker uses the benchmark library (https://docs.ruby-lang.org/ja/latest/class/Benchmark.html) internally.
    #
    # "all" option performs static analysis to identify the target method, so put "__FILE__" in the argument. normally, set this option.
    #
    # method specified in "only" will not be benchmarked.
    # method specified in "except" will not be benchmarked.
    # method specified by "added" is added to the benchmark after the "only" and "except" method filtering is done.
    #
    # "label_width" specifies the width of the benchmark label.
    #
    # benchmark is measured by repeatedly executing the benchmarked method for the number of times specified by "times".
    # Keep in mind that code such as SQL queries will also be executed repeatedly.
    #
    # "require_hidden_method" option is set to true, methods created dynamically by metaprogramming will also be targeted.
    #
    # in the "include" option, specify the module that you are including. Arrange the option array in the loading order of the modules to be included.
    # in the "extend" option, specify the module that you are extending. Arrange the option array in the loading order of the modules to be extended.
    # in the "prepend" option, specify the module that you are prepending. Arrange the option array in the loading order of the modules to be prepended.
    def self.register_rbenchmarker_methods(
      all: nil,
      only: [],
      except: [],
      added: [],
      label_width: 0,
      times: 0,
      require_hidden_method: false,
      object_type: nil,
      target_obj: nil
    )
      # Collect the method names to be benchmarked.
      target_instance_method_names, target_class_method_names = collect_target_methods(
        target_obj, all, require_hidden_method, only, except, added
      )

      # Add benchmark function to the method to be benchmarked.
      instance_method_codes_with_benchmark_function = generate_benchmarking_codes(
        target_instance_method_names, label_width, times, (object_type == 'Module' ? 'module' : 'instance')
      )
      class_method_codes_with_benchmark_function = generate_benchmarking_codes(
        target_class_method_names, label_width, times, (object_type == 'Module' ? 'module' : 'class')
      )

      # Override the original method with the benchmark functionality.
      prepended_instance_methods = prepend_benchmarking_methods(instance_method_codes_with_benchmark_function)
      prepended_class_methods = prepend_benchmarking_methods(class_method_codes_with_benchmark_function)

      case object_type
      when 'Module'
        Rbenchmarker.add_module_with_has_methods_list(target_obj.to_s.to_sym, prepended_instance_methods)
      when 'Class'
        target_obj.prepend prepended_instance_methods
      end

      target_obj.singleton_class.prepend prepended_class_methods
    end

    # private

    def self.collect_target_methods(target_obj, target_file, require_hidden_method, only, except, added)
      if require_hidden_method
        instance_method_name_candidates = target_obj.instance_methods(false) + target_obj.private_instance_methods(false)
        class_method_name_candidates = target_obj.singleton_methods(false)
      elsif target_file
        instance_method_name_candidates, class_method_name_candidates =
          statically_analyze_and_extract_target_method_names(target_obj, target_file)
      else
        instance_method_name_candidates = []
        class_method_name_candidates = []
      end

      filtered_instance_method_names =
        filter_by_only_except_and_added(instance_method_name_candidates, only, except, added, target_obj, 'instance_method')
      filtered_class_method_names =
        filter_by_only_except_and_added(class_method_name_candidates, only, except, added, target_obj, 'class_method')

      [filtered_instance_method_names, filtered_class_method_names]
    end

    def self.statically_analyze_and_extract_target_method_names(target_obj, target_file)
      instance_method_name_candidates = []
      class_method_name_candidates = []
      words = []

      all_class_methods = target_obj.singleton_methods(false)
      all_instance_methods = target_obj.instance_methods(false) + target_obj.private_instance_methods(false)
      File.foreach(target_file) { |line| words << line[/def\ (.*?)[ ;|\(\n]/, 1] }
      user_described_all_method_names = words.compact.map { |word| word.match(/^self\./) ? word.gsub(/^self\./, '') : word }

      user_described_all_method_names.each do |def_name|
        class_method_name_candidates << def_name.to_sym if all_class_methods.include?(def_name.to_sym)
        instance_method_name_candidates << def_name.to_sym if all_instance_methods.include?(def_name.to_sym)
      end

      [instance_method_name_candidates.uniq, class_method_name_candidates.uniq]
    end

    def self.filter_by_only_except_and_added(method_names, only, except, added, target_obj, method_type)
      has_methods = case method_type
                    when 'instance_method'
                      target_obj.instance_methods(false) + target_obj.private_instance_methods(false)
                    when 'class_method'
                      target_obj.singleton_methods(false)
                    end

      added = added.select { |method_name| has_methods.include?(method_name) }

      if !only.empty?
        ((method_names & only) + added).uniq
      elsif !except.empty?
        (method_names - except + added).uniq
      else
        (method_names + added).uniq
      end
    end

    def self.generate_benchmarking_codes(method_names, width, times, class_type)
      method_names.map { |method_name| define_benchmarking_code(method_name, width, times, class_type) }
    end

    def self.define_benchmarking_code(method_name, width, times, class_type)
      times_to_i = times.to_i.nonzero?
      generate_report_function_code = generate_report_method_text('bm_result')

      <<-RUBY_EVAL
        def #{method_name}(*)
          origin_return_value = nil
          bm_result = # 'bm_result' is Arguments of 'generate_report_method_text'
            Benchmark.bm #{width.to_i.nonzero? || method_name.length + DEFAULT_REPORT_LENGTH} do |r|
              r.report "report def #{method_name}#{"(#{times_to_i}" if times_to_i}#{' loops)' if times_to_i} #{class_type} method" do
                #{times_to_i ? "#{times_to_i}.times{ origin_return_value = super }" : 'origin_return_value = super'}
              end
            end
          #{generate_report_function_code}
          origin_return_value
        end
      RUBY_EVAL
    end

    def self.generate_report_method_text(bm_report_name)
      <<-RUBY_EVAL
        new_report = #{bm_report_name}.first
        bm_reports = Rbenchmarker.tracking_reports
        if bm_reports[new_report.label.to_sym]
          previous_report = bm_reports[new_report.label.to_sym]
          key = new_report.label.to_sym
          value = {
            utime: previous_report[:utime] << new_report.utime,
            stime: previous_report[:stime] << new_report.stime,
            total: previous_report[:total] << new_report.total,
            real: previous_report[:real] << new_report.real,
            number_of_executions: previous_report[:number_of_executions] + 1
          }
          Rbenchmarker.add_report(key, value)
        else
          key = new_report.label.to_sym
          value = {
            utime: [new_report.utime],
            stime: [new_report.stime],
            total: [new_report.total],
            real: [new_report.real],
            number_of_executions: TIMES_THE_METHOD_WAS_CALLED
          }
          Rbenchmarker.add_report(key, value)
        end
      RUBY_EVAL
    end

    def self.prepend_benchmarking_methods(benchmarking_codes)
      Module.new do
        benchmarking_codes.each { |code| class_eval code, __FILE__, __LINE__ + 1 }
      end
    end

    private_class_method :collect_target_methods
    private_class_method :statically_analyze_and_extract_target_method_names
    private_class_method :filter_by_only_except_and_added
    private_class_method :generate_benchmarking_codes
    private_class_method :define_benchmarking_code
    private_class_method :generate_report_method_text
    private_class_method :prepend_benchmarking_methods
  end
end
