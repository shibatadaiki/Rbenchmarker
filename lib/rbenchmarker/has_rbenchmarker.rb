require 'benchmark'

module Rbenchmarker
  module HasRbenchmarker
    def foo
      origin_return_value = nil
      Benchmark.bm 50 do |r|
        r.report "report def #{self} //" do
          origin_return_value = super
        end
      end

      origin_return_value
    end
  end
end
