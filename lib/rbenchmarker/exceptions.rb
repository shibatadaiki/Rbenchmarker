# frozen_string_literal: true

module Rbenchmarker
  class ExceptClassDesignationError < ArgumentError
    def initialize
      super('"except_classes" option must be an array containing only "Class".')
    end
  end

  class ExceptModuleDesignationError < ArgumentError
    def initialize
      super('"except_modules" option must be an array containing only the defined "Module".')
    end
  end

  class TargetDirPathError < ArgumentError
    def initialize
      super('In the argument of "output_log_file_path", specify the path of the directory where you want to place the log.')
    end
  end

  class OnlyMethodDesignationError < ArgumentError
    def initialize
      super('"Only" option must be an array containing only "String" or "Symbol".')
    end
  end

  class ExceptMethodDesignationError < ArgumentError
    def initialize
      super('"Except" option must be an array containing only "String" or "Symbol".')
    end
  end

  class AddedMethodDesignationError < ArgumentError
    def initialize
      super('"Added" option must be an array containing only "String" or "Symbol".')
    end
  end

  class PrependModuleDesignationError < ArgumentError
    def initialize
      super('"prepend" option must be an array containing only the defined "Module".')
    end
  end

  class IncludeModuleDesignationError < ArgumentError
    def initialize
      super('"include" option must be an array containing only the defined "Module".')
    end
  end

  class ExtendModuleDesignationError < ArgumentError
    def initialize
      super('"extend" option must be an array containing only the defined "Module".')
    end
  end

  class TargetFilePathError < ArgumentError
    def initialize
      super('Must be specify an existing file path. Unless there is a special reason, specify the return value of the "__FILE__" method in the all argument.')
    end
  end
end
