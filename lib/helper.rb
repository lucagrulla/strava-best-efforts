require 'fileutils'

module StravaBestEfforts

  class Helper

    def self.check_essential_file_exists(file_name)
      unless File.file?(file_name)
        $logger.error "File '#{file_name}' cannot be found. Please use 'ruby app.rb -f' to create one first."
        exit 1
      end
    end

    def self.get_athlete_file(dir_result)
      unless File.directory?(dir_result)
        FileUtils.mkdir_p(dir_result)
      end
      return "#{dir_result}/athlete-#{Time.now.strftime("%Y-%m-%d-%H-%M-%S")}.json"
    end

    def self.get_best_efforts_file(dir_result)
      unless File.directory?(dir_result)
        FileUtils.mkdir_p(dir_result)
      end
      return "#{dir_result}/best-efforts-#{Time.now.strftime("%Y-%m-%d-%H-%M-%S")}.json"
    end
  end
end
