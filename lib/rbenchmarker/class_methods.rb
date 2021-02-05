# frozen_string_literal: true

require_relative 'exceptions'
require_relative 'register_rbenchmarker_methods'

module Rbenchmarker
  def self.included(klass)
    klass.extend ClassMethods
  end

  module ClassMethods
    def rbenchmarker(**options)
      rbenchmarker_validation_check(options)

      options[:only] = options[:only].map(&:to_sym) if options[:only]
      options[:except] = options[:except].map(&:to_sym) if options[:except]
      options[:added] = options[:added].map(&:to_sym) if options[:added]

      granted_modules = {}
      granted_modules[:prepend] = options.delete(:prepend) if options[:prepend]
      granted_modules[:include] = options.delete(:include) if options[:include]
      granted_modules[:extend] = options.delete(:extend) if options[:extend]

      if instance_of?(Module)
        options[:object_type] = 'Module'
        Rbenchmarker.add_module [self, options]
      else
        options[:object_type] = 'Class'
        Rbenchmarker.add_class [self, options]
      end

      Rbenchmarker.add_object_with_modules([self, granted_modules])
    end

    def call_register_rbenchmarker_methods(options)
      options[:target_obj] = self
      Rbenchmarker::RegisterRbenchmarkerMethods.register_rbenchmarker_methods(**options)
    end

    private # not strictly concealed because can be called from unspecified object.

    def rbenchmarker_validation_check(options)
      raise Rbenchmarker::TargetFilePathError if options[:all] && !options[:all].is_a?(String)
      raise Rbenchmarker::TargetFilePathError if options[:all] && !File.file?(options[:all])
      raise Rbenchmarker::OnlyMethodDesignationError if options[:only] && !options[:only].is_a?(Array)
      raise Rbenchmarker::OnlyMethodDesignationError if options[:only] && !options[:only].all? do |method_name|
        method_name.is_a?(String) || method_name.is_a?(Symbol)
      end
      raise Rbenchmarker::ExceptMethodDesignationError if options[:except] && !options[:except].is_a?(Array)
      raise Rbenchmarker::ExceptMethodDesignationError if options[:except] && !options[:except].all? do |method_name|
        method_name.is_a?(String) || method_name.is_a?(Symbol)
      end
      raise Rbenchmarker::AddedMethodDesignationError if options[:added] && !options[:added].is_a?(Array)
      raise Rbenchmarker::AddedMethodDesignationError if options[:added] && !options[:added].all? do |method_name|
        method_name.is_a?(String) || method_name.is_a?(Symbol)
      end
      raise Rbenchmarker::PrependModuleDesignationError if options[:prepend] && !options[:prepend].is_a?(Array)
      raise Rbenchmarker::PrependModuleDesignationError if options[:prepend] && !options[:prepend].all? do |obj|
        obj.class.to_s == 'Module'
      end
      raise Rbenchmarker::IncludeModuleDesignationError if options[:include] && !options[:include].is_a?(Array)
      raise Rbenchmarker::IncludeModuleDesignationError if options[:include] && !options[:include].all? do |obj|
        obj.class.to_s == 'Module'
      end
      raise Rbenchmarker::ExtendModuleDesignationError if options[:extend] && !options[:extend].is_a?(Array)
      raise Rbenchmarker::ExtendModuleDesignationError if options[:extend] && !options[:extend].all? do |obj|
        obj.class.to_s == 'Module'
      end
    end
  end
end

Object.send :include, Rbenchmarker::ClassMethods
