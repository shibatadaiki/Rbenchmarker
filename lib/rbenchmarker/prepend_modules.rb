# frozen_string_literal: true

module Rbenchmarker
  module PrependModules
    def self.register_rbenchmarker_methods_to_module(object_with_has_modules, module_with_has_methods_lists, except_modules)
      object_with_has_modules.each do |obj, granted_modules|
        if granted_modules[:prepend].is_a?(Array)
          methods_setup(granted_modules, :prepend, obj, except_modules, module_with_has_methods_lists)
        end

        if granted_modules[:include].is_a?(Array)
          methods_setup(granted_modules, :include, obj, except_modules, module_with_has_methods_lists)
        end

        if granted_modules[:extend].is_a?(Array)
          methods_setup(granted_modules, :extend, obj, except_modules, module_with_has_methods_lists)
        end
      end
    end

    # private

    def self.methods_setup(granted_modules, include_type, obj, except_modules, module_with_has_methods_lists)
      granted_modules[include_type].each do |benchmark_module|
        next if except_modules.include?(benchmark_module)
        next unless module_with_has_methods_lists[benchmark_module.to_s.to_sym]

        case include_type
        when :prepend
          obj.prepend module_with_has_methods_lists[benchmark_module.to_s.to_sym]
        when :include
          obj.include module_with_has_methods_lists[benchmark_module.to_s.to_sym]
        when :extend
          obj.extend module_with_has_methods_lists[benchmark_module.to_s.to_sym]
        end
      end
    end

    private_class_method :methods_setup
  end
end
