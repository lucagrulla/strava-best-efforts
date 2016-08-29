require 'fileutils'
require 'logger'

module StravaBestEfforts

  class AppLogger

    LOG_DIRECTORY = 'log'

    def initialize(log_level)

      unless File.directory?(LOG_DIRECTORY)
        FileUtils.mkdir_p(LOG_DIRECTORY)
      end

      log_filename = "#{LOG_DIRECTORY}/application-#{Time.now.strftime("%Y-%m-%d")}.log"
      @log_file = File.new(log_filename, 'a')
      @logger = Logger.new(StravaBestEfforts::MultiLoggerDelegator.delegate(:write, :close).to(STDOUT, @log_file))

      case log_level.upcase
      when 'FATAL'
        @logger.level = Logger::FATAL
      when 'ERROR'
        @logger.level = Logger::ERROR
      when 'WARN'
        @logger.level = Logger::WARN
      when 'INFO'
        @logger.level = Logger::INFO
      when 'DEBUG'
        @logger.level = Logger::DEBUG
      end
    end

    def get
      return @logger
    end

    def close
      @log_file.close
    end
  end

  # http://stackoverflow.com/questions/6407141/
  # How can I have ruby logger log output to stdout as well as file?
  class MultiLoggerDelegator
    def initialize(*targets)
      @targets = targets
    end

    def self.delegate(*methods)
      methods.each do |m|
        define_method(m) do |*args|
          @targets.map { |t| t.send(m, *args) }
        end
      end
      self
    end

    class <<self
      alias to new
    end
  end

end
