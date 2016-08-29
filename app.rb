require 'fileutils'
require 'optparse'
require './lib/app_logger'
require './lib/config_reader'
require './lib/fetcher/best_effort_parser'
require './lib/fetcher/json_writer'
require './lib/fetcher/strava_api_client'
require './lib/helper'

# Create a configuration reader.
@config = StravaBestEfforts::ConfigReader.new

# Setup log file and logger.
$logger = StravaBestEfforts::AppLogger.new(@config.log_level).get

# Setup options parser.
ARGV << '-h' if ARGV.empty?
options = OpenStruct.new
option_parser = OptionParser.new do |opts|
  opts.banner = 'Usage: app.rb [-f or -s]'

  opts.on('-f', '--fetch', 'Connects to Strava and fetches all best running efforts.') do |fetch|
    options[:fetch] = fetch
  end
  opts.on('-s', '--serve', 'Serves the visualizer if data JSON file exists.') do |serve|
    options[:serve] = serve
  end
  opts.on_tail('-h', '--help', 'Show this message.') do
    puts opts
    exit
  end
end

# Parse options.
begin
  option_parser.parse!(ARGV)
rescue OptionParser::InvalidOption => e
  puts e
  puts option_parser
  exit 1
end

# Fetching best efforts activities.
if options[:fetch]

  @api_client = StravaBestEfforts::Fetcher::StravaApiClient.new(@config.access_token)

  # Setup the result directory and create athlete JSON writers.
  @athlete_file = StravaBestEfforts::Helper.get_athlete_file(@config.dir_result)
  @athlete_writer = StravaBestEfforts::Fetcher::JsonWriter.new(@athlete_file)

  # Setup the result directory and create best efforts JSON writers.
  @best_efforts_file = StravaBestEfforts::Helper.get_best_efforts_file(@config.dir_result)
  @best_efforts_writer = StravaBestEfforts::Fetcher::JsonWriter.new(@best_efforts_file)

  begin
    # Fetch athlete information.
    athlete_info = @api_client.get_current_ahtlete_info
    @athlete_writer.append_results(athlete_info)

    # For each activity id, retrieve activity json, then parse it.
    # If it has valid best effort items, append them to the result file.
    @activity_ids = @api_client.get_all_best_effort_activity_ids
    @activity_ids.sort.each do |activity_id|

      activity_json = @api_client.retrieve_an_activity(activity_id)
      results = StravaBestEfforts::Fetcher::BestEffortParser.parse(activity_json, @config.maximum_pr_rank)
      @best_efforts_writer.append_results(results)
    end

  rescue Exception => e
    $logger.error e.message
    $logger.error "Backtrace:\n\t#{e.backtrace.join("\n\t")}"
    raise
    exit 1
  ensure
    @athlete_writer.close
    @best_efforts_writer.close

    # Copy created data JSON files to designated location.
    FileUtils.cp_r(@athlete_file, './athlete.json', :remove_destination => true) if File.exists?(@athlete_file)
    FileUtils.cp_r(@best_efforts_file, './best-efforts.json', :remove_destination => true) if File.exists?(@best_efforts_file)

    $logger.close
  end
end

# Start web server.
if options[:serve]
  StravaBestEfforts::Helper.check_essential_file_exists('./athlete.json')
  StravaBestEfforts::Helper.check_essential_file_exists('./best-efforts.json')
  system 'ruby -run -e httpd . -p 5050'
end
