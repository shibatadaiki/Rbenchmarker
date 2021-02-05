# frozen_string_literal: true

require 'logger'

module Rbenchmarker
  module RbenchmarkerLog
    def self.init_log
      @logger = Logger.new(Rbenchmarker.output_log_file_path)
      @logger.info("== Start recording Rbenchmarker == \n")
    end

    def self.puts_log(label, report, number_of_digits: 8)
      return unless defined? @logger

      log_text = "\n"
      log_text += "#{label}: current time\n"
      log_text += "user: #{format("%.#{number_of_digits}f", report[:utime][-1])}, "
      log_text += "system: #{format("%.#{number_of_digits}f", report[:stime][-1])}, "
      log_text += "total: #{format("%.#{number_of_digits}f", report[:total][-1])}, "
      log_text += "real: #{format("%.#{number_of_digits}f", report[:real][-1])}\n"

      log_text += "#{label}: total time for #{report[:number_of_executions]} times called\n"
      log_text += "user: #{format("%.#{number_of_digits}f", report[:utime].sum)}, "
      log_text += "system: #{format("%.#{number_of_digits}f", report[:stime].sum)}, "
      log_text += "total: #{format("%.#{number_of_digits}f", report[:total].sum)}, "
      log_text += "real: #{format("%.#{number_of_digits}f", report[:real].sum)}\n"

      log_text += "#{label}: avarage time\n"
      log_text += "user: #{format("%.#{number_of_digits}f", (report[:utime].sum / report[:number_of_executions]))}, "
      log_text += "system: #{format("%.#{number_of_digits}f", (report[:stime].sum / report[:number_of_executions]))}, "
      log_text += "total: #{format("%.#{number_of_digits}f", (report[:total].sum / report[:number_of_executions]))}, "
      log_text += "real: #{format("%.#{number_of_digits}f", (report[:real].sum / report[:number_of_executions]))}\n"

      @logger.info(log_text)
    end
  end
end
