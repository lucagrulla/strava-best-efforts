require 'json'
require 'strava/api/v3'

module StravaBestEfforts
  module Fetcher
    class StravaApiClient

      def initialize(access_token)
        @api_client = Strava::Api::V3::Client.new(:access_token => access_token, :logger => $logger)
      end

      def is_activity_run_and_with_achievements?(activity)
        activity['type'] == 'Run' and activity['achievement_count'] > 0
      end

      # Get ids of all activities that have achievement items.
      def get_all_best_effort_activity_ids

        # Call Strava API to list all athlete activities,
        # then parse out all activity ids.

        # For all activity ids, choose running activities only,
        # and filter out those without achievement items.

        activity_ids = list_all_athlete_activities.reduce([]) do |acc, act|
          activity = JSON.parse(act.to_json)
          if is_activity_run_and_with_achievements?(activity)
            $logger.debug("StravaClient - Activity #{activity['id']} has achievement items.")
            acc << activity['id']
          end
          acc
        end
        $logger.info("StravaClient - Total number of #{activity_ids.count} activity ids retrieved.")
        activity_ids
      end

      def get_current_ahtlete_info
        [@api_client.retrieve_current_athlete]
      end

      def retrieve_an_activity(activity_id)
        $logger.info("StravaClient - Retrieving activity #{activity_id}.")
        raw_activity = @api_client.retrieve_an_activity(activity_id)
        JSON.parse(raw_activity.to_json)
      end

      def list_all_athlete_activities
        $logger.info("StravaClient - Getting ids for activities with achievement items.")

        athlete_activities = (1..100).reduce([]) do |acc, i|
          page = @api_client.list_athlete_activities({:per_page => 200, :page => i})
          acc << page unless page.empty?
          acc
        end
        athlete_activities.flatten
      end

      private :list_all_athlete_activities
    end
  end
end
