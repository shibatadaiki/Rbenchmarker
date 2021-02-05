# Rbenchmarker

Rbenchmarker is a gem that allows you to automatically benchmark the execution time of a method defined in a Ruby class and module.
Benchmark module (https://docs.ruby-lang.org/ja/latest/class/Benchmark.html) is used inside Rbenchmarker, and bm method is automatically applied to all target methods.

However, ｍethod itself to which Rbenchmarker is applied remains unchanged, takes the same arguments as before, and returns the same return value as before.

So you don't have to change the methods yourself, and you don't have to benchmark the methods one by one.
Just launch the application as before and will automatically benchmark all targeted methods!

## Installation

Add this line to your application's Gemfile:

```ruby
# Gemfile

gem 'rbenchmarker'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install rbenchmarker

## Add the launch process to your Ruby project

Create the following file and add to your Ruby project.

```ruby
# rbenchmarker_setup.rb

# Note that you need to do Rbenchmarker.setup after reading all the files.
Rbenchmarker.setup switch: 'on',
                   output_log_path: nil,
                   except_classes: [],
                   except_modules: []
```

Or run it directly from console

```
irb(main):001:0> Rbenchmarker.setup switch: 'on', output_log_path: nil, except_classes: [], except_modules: []
=> true
```

 The `setup` method executes the process of adding the benchmark function to all the methods in the specified class and module.

Note that you need to do `Rbenchmarker.setup` after reading all the files.

[Details of setup options](https://github.com/shibatadaiki/Rbenchmarker#about-setup-options)

### For Ruby on Rails projects, add the following settings to your `config`

```ruby
# config/environments/development.rb

config.eager_load = true # Please note that this setting is mandatory!

config.after_initialize do
  Rbenchmarker.setup switch: 'on', output_log_path: nil, except_classes: [], except_modules: []
end
```

Please note that when using the Rbenchmark feature, the server will need to be restarted for the file changes to take effect.

[Details of config.after_initialize and config.eager_load](https://guides.rubyonrails.org/configuring.html#rails-general-configuration)

## Add rbenchmarker to your Class

```ruby
# app/models/sample_class.rb

class SampleClass
  rbenchmarker all: __FILE__
end
```

Your Class is now a benchmarker!

When the method in the class in which rbenchmarker is set is executed, the following log will be output.

Logs are placed directly under the './log' directory if './log' directory exists, or directly under the current directory if does not exist.

`rbenchmarker.log`

```log
# Logfile created on 2020-12-22 16:24:06 +0900 by logger.rb/v1.4.2
I, [2020-12-22T16:24:06.327445 #54558]  INFO -- : == Start recording Rbenchmarker == 

I, [2020-12-22T16:24:12.848277 #54558]  INFO -- : 
report def test_method1 class method: current time
user: 0.00000900, system: 0.00000700, total: 0.00001600, real: 0.00000700
report def test_method1 class method: 1 times called
user: 0.00000900, system: 0.00000700, total: 0.00001600, real: 0.00000700
report def test_method1 class method: avarage time
user: 0.00000900, system: 0.00000700, total: 0.00001600, real: 0.00000700

I, [2020-12-22T16:24:14.009972 #54558]  INFO -- : 
report def test_method1 class method: current time
user: 0.00000500, system: 0.00000200, total: 0.00000700, real: 0.00000400
report def test_method1 class method: 2 times called
user: 0.00001400, system: 0.00000900, total: 0.00002300, real: 0.00001100
report def test_method1 class method: avarage time
user: 0.00000700, system: 0.00000450, total: 0.00001150, real: 0.00000550

I, [2020-12-22T16:24:29.969068 #54558]  INFO -- : 
report def test_method2 instance method: current time
user: 0.00000600, system: 0.00000200, total: 0.00000800, real: 0.00000500
report def test_method2 instance method: 1 times called
user: 0.00000600, system: 0.00000200, total: 0.00000800, real: 0.00000500
report def test_method2 instance method: avarage time
user: 0.00000600, system: 0.00000200, total: 0.00000800, real: 0.00000500

I, [2020-12-22T16:24:30.545224 #54558]  INFO -- : 
report def test_method2 instance method: current time
user: 0.00000600, system: 0.00000200, total: 0.00000800, real: 0.00000500
report def test_method2 instance method: 2 times called
user: 0.00001200, system: 0.00000400, total: 0.00001600, real: 0.00001000
report def test_method2 instance method: avarage time
user: 0.00000600, system: 0.00000200, total: 0.00000800, real: 0.00000500

I, [2020-12-22T16:24:31.185216 #54558]  INFO -- : 
report def test_method2 instance method: current time
user: 0.00000600, system: 0.00000200, total: 0.00000800, real: 0.00000400
report def test_method2 instance method: 3 times called
user: 0.00001800, system: 0.00000600, total: 0.00002400, real: 0.00001400
report def test_method2 instance method: avarage time
user: 0.00000600, system: 0.00000200, total: 0.00000800, real: 0.00000467
```

If repeat the same method, the total execution time and the average execution time of the number of executions will be output to the log.

## Add rbenchmarker to your Module

Can do the same with class as with module, but with module, additional work is required.

```ruby
# lib/sample_module.rb

module SampleModule
  extend Rbenchmarker::ClassMethods # for module, add this sentence before launching rbenchmarker
  rbenchmarker all: __FILE__
end
```

Then add the following options in the class that is using that module.

```ruby
# app/models/class_include_module.rb

class ClassIncludeModule
  include SampleModule
  rbenchmarker all: __FILE__, include: [SampleModule] # In the `include` option, specify all included modules in array format
end
```

```ruby
# app/models/class_extend_module.rb

class ClassExtendModule
  extend SampleModule
  rbenchmarker all: __FILE__, extend: [SampleModule] # In the `extend` option, specify all extended modules in array format
end
```

```ruby
# app/models/class_prepend_module.rb

class ClassPrependModule
  prepend SampleModule
  rbenchmarker all: __FILE__, prepend: [SampleModule] # In the `prepend` option, specify all prepended modules in array format
end
```

The same is true for modules that use modules.

```ruby
# lib/module_include_module.rb

module DoIncludeModule
  include SampleModule
  extend Rbenchmarker::ClassMethods
  rbenchmarker all: __FILE__, include: [SampleModule]
end
```

```ruby
# lib/module_extend_module.rb

module DoExtendModule
  extend SampleModule
  extend Rbenchmarker::ClassMethods
  rbenchmarker all: __FILE__, extend: [SampleModule]
end
```

```ruby
# lib/module_prepend_module.rb

module DoPrependModule
  prepend SampleModule
  extend Rbenchmarker::ClassMethods
  rbenchmarker all: __FILE__, prepend: [SampleModule]
end
```

Your Module is now a benchmarker!

## About `rbenchmarker` options

List of all possible options

| Options | Description | Exsample |
| ------------- | ------------- | ------------- |
| `all`  | `all` option performs static analysis to identify the target method, so put `__FILE__` in the argument. Setting this option will measure all methods listed in the file. normally, set this option. | `rbenchmarker all: __FILE__` |
| `only` | method specified in `only` only will be benchmarked. | `rbenchmarker only: [:sample_method1, :sample_method2]` |
| `except` | method specified in `except` will not be benchmarked. | `rbenchmarker except: [:sample_method1, :sample_method2]` |
| `added` | method specified by `added` is added to the benchmark after the `only` and `except` method filtering is done. | `rbenchmarker added: [:sample_method1, :sample_method2]` |
| `label_width` | `label_width` specifies the width of the benchmark label. | `rbenchmarker label_width: 25` |
| `times` | benchmark is measured by repeatedly executing the benchmarked method for the number of times specified by `times`. (Keep in mind that code such as SQL queries will also be executed repeatedly.) | `rbenchmarker times: 5` |
| `require_hidden_method` | If `require_hidden_method` option is set to true, methods dynamically created by metaprogramming, methods added to another file, etc. are also included. | `rbenchmarker require_hidden_method: true` |
| `include` | in the `include` option, specify the module that you are including. Arrange the option array in the loading order of the modules to be included. | `rbenchmarker include: [SampleModule1, SampleModule2]` |
| `extend` | in the `extend` option, specify the module that you are extending. Arrange the option array in the loading order of the modules to be extended. | `rbenchmarker extend: [SampleModule1, SampleModule2]` |
| `prepend` | in the `prepend` option, specify the module that you are prepending. Arrange the option array in the loading order of the modules to be prepended. | `rbenchmarker prepend: [SampleModule1, SampleModule2]` |

Can set multiple options as follows.

```ruby
# app/models/sample_class.rb

class SampleClass
   rbenchmarker all: __FILE__, only: [:sample_method1, :sample_method2], label_width: 25
end
```

Of course, also possible with modules.

```ruby
# lib/sample_module.rb

module SampleModule
  extend Rbenchmarker::ClassMethods
  rbenchmarker all: __FILE__, only: [:sample_method1, :sample_method2], label_width: 25
end
```

## About `require_hidden_method` option

Maybe, `require_hidden_method` option may often be used in Ruby on Rails projects.

For example, in the case of the following Ruby on Rails code

```ruby
# app/models/sample_class.rb

class SampleClass
  rbenchmarker all: __FILE__

  belongs_to :sample_parent
  has_many :sample_children, dependent: :destroy
  scope :has_sample_parent, -> { where.not(sample_parent_id: nil) }

  def my_name_length
    name.length
  end
end
```

Ruby on Rails adds methods to the class with various options, but usually it's not written in a file.
However, the `all: __FILE__` option can only track methods defined directly in the file. (In this case, only `my_name_length` is tracked)

In such cases, use the `require_hidden_method` option to track invisible methods.

```ruby
# app/models/sample_class.rb

class SampleClass
  rbenchmarker require_hidden_method: true # the `all` option is not required when using the `require_hidden_method` option

  belongs_to :sample_parent
  has_many :sample_children, dependent: :destroy
  scope :has_sample_parent, -> { where.not(sample_parent_id: nil) }

  def my_name_length
    name.length
  end
end
```

The same applies in the following cases.

```ruby
# lib/module_include_module.rb

module IncludedModule
  extend ActiveSupport::Concern
  included do
    def sample_module_method
     puts 'sample_module_method!'
    end
  end
end

# app/models/sample_class.rb

class SampleClass
  include IncludedModule
  rbenchmarker require_hidden_method: true # Requires the `require_hidden_method` option to track the IncludedModule methods
end
```

Set of `extend ActiveSupport::Concern` and `included do ~`, which is often seen when using Ruby on Rails modules, adds a method to the class itself by internally executing `class_eval` to the target class
(Rather than using module methods).
Therefore, want Rbenchmarker to track the methods added in this way, need the `require_hidden_method` option.

However, `require_hidden_method` option can be annoying as it keeps track of all hidden methods. In that case, adjust using options such as `only`, `except`, and `added`.

## About `setup` options

| Options | Description | Exsample |
| ------------- | ------------- | ------------- |
| `switch`  | In case of `off` or `OFF`, the processing of rbenchmarker will not be executed. | `Rbenchmarker.setup switch: 'off'` |
| `output_log_path` | Specify the output destination of the measurement result log output by rbenchmark. |  `Rbenchmarker.setup output_log_path: '/Users/daiki.shibata/xxx/workspace'` |
| `except_classes` | Specify the class that does not give rbenchmark processing. | `Rbenchmarker.setup except_classes: [Class1, Class2, Class3]` |
| `except_modules` | Specify the module that does not give rbenchmark processing. | `Rbenchmarker.setup except_modules: [Module1, Module2, Module3]` |

Can set multiple options as follows.

```ruby
# rbenchmarker_setup.rb

Rbenchmarker.setup switch: 'on',
                   output_log_path: '/Users/daiki.shibata/xxx/workspace',
                   except_classes: [Class1, Class2, Class3],
                   except_modules: [Module1, Module2, Module3]
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Rbenchmarker project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/rbenchmarker/blob/master/CODE_OF_CONDUCT.md).

## Contributing

Everyone is encouraged to help improve this project. Here are a few ways you can help:

- [Report bugs](https://github.com/shibatadaiki/Rbenchmarker/issues)
- Fix bugs and [submit pull requests](https://github.com/shibatadaiki/Rbenchmarker/pulls)
- Write, clarify, or fix documentation
- Suggest or add new features

To get started with development:

```sh
git clone https://github.com/shibatadaiki/Rbenchmarker.git
cd Rbenchmarker
bundle install
bundle exec rake test
```