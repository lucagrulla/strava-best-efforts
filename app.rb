require 'fileutils'
require 'optparse'
require './lib/app_logger'
require './lib/fetcher/best_effort_parser'
require './lib/fetcher/strava_api_client'
require 'webrick'

@config = YAML.load_file('config.yml')
$logger = StravaBestEfforts::AppLogger.new(@config['log_level']).get

@dir = @config['dir_result']
FileUtils.mkdir_p(@dir) unless File.directory?(@dir)

def file_for(name)
  "#{@dir}/#{name}-#{Time.now.strftime("%Y-%m-%d-%H-%M-%S")}.json"
end       

def fetch_data
  api_client = StravaBestEfforts::Fetcher::StravaApiClient.new(@config['access_token'])

  athlete_file = file_for("athlete")
  best_efforts_file = file_for("best-efforts")
  raw = file_for("raw")
  
  begin
    athlete_info = api_client.get_current_ahtlete_info
    File.write(athlete_file, athlete_info.to_json) 

    detailed_activities = api_client.get_all_activities
    $logger.info("got all activities")
  
    File.write(raw, detailed_activities.to_json) 
    $logger.info("raw file done.")  

    best_efforts = detailed_activities.map{|a| a['best_efforts']}
                                            .flatten
                                            .reject{|a| a['pr_rank'].nil? || a['pr_rank'] > @config['maximum_pr_rank']}
                                            .map{|a| StravaBestEfforts::Fetcher::BestEffortParser.parse(a)}

    $logger.info("activites with pr:#{best_efforts.count}")

    $logger.info("best efforts found")
    File.write(best_efforts_file, best_efforts.to_json) 

  rescue Exception => e
    puts "error:#{e}"
    $logger.error e.message
    $logger.error "Backtrace:\n\t#{e.backtrace.join("\n\t")}"
    raise
  ensure
    FileUtils.cp_r(athlete_file, './athlete.json', :remove_destination => true) if File.exists?(athlete_file)
    FileUtils.cp_r(best_efforts_file, './best-efforts.json', :remove_destination => true) if File.exists?(best_efforts_file)
    FileUtils.cp_r(raw, './raw.json', :remove_destination => true) if File.exists?(raw)

    $logger.close
  end
end

def serve_data
  server = WEBrick::HTTPServer.new(:Port => 5050, :DocumentRoot => File.expand_path('.'))
  server.start
end

ARGV << '-h' if ARGV.empty?
options = OpenStruct.new
option_parser = OptionParser.new do |opts|
  opts.banner = 'Usage: app.rb [-f or -s]'

  opts.on('-f', '--fetch [ORIGIN]', 'Connects to Strava and fetches all best running efforts.') do |fetch|
    options[:cmd] = :fetch_data
  end
  opts.on('-s', '--serve', 'Serves the visualizer if data JSON file exists.') do |serve|
    options[:cmd] = :serve_data 
  end

  opts.on_tail('-h', '--help', 'Show this message.') do
    puts opts
    exit
  end
end

begin
  option_parser.parse(ARGV)
  self.send(options[:cmd])
rescue OptionParser::InvalidOption => e
  puts e
  puts option_parser
  exit 1
end