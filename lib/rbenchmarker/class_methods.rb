module Rbenchmarker
  module ClassMethods
    # TODO : このメソッドくっつけても本番で実行されないようにしたい...
    def rbenchmarker(only: [], except: [], label_width: 50)
      self_class = self

      # TODO : 対象の全メソッド取得
      method_names = []

      method_names.each do |method_name|
        alias_method "__#{method_name}__".to_sym, method_name.to_sym

      end
    end
  end
end

