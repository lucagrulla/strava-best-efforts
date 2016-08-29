require 'yaml'

module StravaBestEfforts

  class ConfigReader

    attr_accessor :access_token, :dir_result, :log_level, :maximum_pr_rank

    def initialize
      config = YAML.load_file('config.yml')
      @access_token = config['access_token']
      @dir_result = config['dir_result']
      @log_level = config['log_level']
      @maximum_pr_rank = config['maximum_pr_rank']
    end

  end
end
