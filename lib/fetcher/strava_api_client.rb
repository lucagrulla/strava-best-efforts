require 'json'
require 'strava/api/v3'

module StravaBestEfforts
  module Fetcher
    class StravaApiClient

      def initialize(access_token)
        @api_client = Strava::Api::V3::Client.new(:access_token => access_token, :logger => $logger)
      end

      def get_current_ahtlete_info
        [@api_client.retrieve_current_athlete]
      end

      def get_all_activities
        get_all_best_effort_activity_ids.sort.map{|id| @api_client.retrieve_an_activity(id)}
      end

      private
        def is_activity_run_and_with_achievements?(activity)
          activity['type'] == 'Run' and activity['achievement_count'] > 0
        end

        def get_all_best_effort_activity_ids
          activity_ids = list_all_athlete_activities
            .map{|a| JSON.parse(a.to_json)}
            .select{|a| is_activity_run_and_with_achievements?(a)}
            .map{|a| a['id']}
        
          $logger.info("StravaClient - Total number of #{activity_ids.count} activity ids retrieved.")
          activity_ids
        end

        def retrieve_an_activity(activity_id)
          raw_activity = @api_client.retrieve_an_activity(activity_id)
          JSON.parse(raw_activity.to_json)
        end

        def list_all_athlete_activities
          $logger.info("StravaClient - Getting ids for activities with achievement items...")

          athlete_activities = (1..100).reduce([]) do |acc, i|
            page = @api_client.list_athlete_activities({:per_page => 200, :page => i})
            acc << page unless page.empty?
            acc
          end
          athlete_activities.flatten
        end
    end
  end
end
