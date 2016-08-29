require 'json'
require 'strava/api/v3'

module StravaBestEfforts

  module Fetcher

    class StravaApiClient

      def initialize(access_token)
        @api_client = Strava::Api::V3::Client.new(:access_token => access_token, :logger => $logger)
      end

      # Get ids of all activities that have achievement items.
      def get_all_best_effort_activity_ids
        $logger.info("StravaClient - Getting ids for activities with achievement items.")

        # Call Strava API to list all athlete activities,
        # then parse out all activity ids.
        athlete_activities = list_all_athlete_activities

        # For all activity ids, choose running activities only,
        # and filter out those without achievement items.
        activity_ids = []
        athlete_activities.each do |page|
          page.each do |activity|
            activity_json = JSON.parse(activity.to_json)
            if activity_json['type'] == 'Run' and activity_json['achievement_count'] > 0
              activity_ids << activity_json['id']
              $logger.debug("StravaClient - Activity #{activity_json['id']} has achievement items.")
            end
          end
        end

        $logger.info("StravaClient - Total number of #{activity_ids.count} activity ids retrieved.")
        return activity_ids
      end

      def get_current_ahtlete_info
        athlete_info = []
        $logger.info("StravaClient - Getting current athlete information.")
        athlete_info << @api_client.retrieve_current_athlete
        return athlete_info
      end

      def retrieve_an_activity(activity_id)
        $logger.info("StravaClient - Retrieving activity #{activity_id}.")

        raw_activity = @api_client.retrieve_an_activity(activity_id)
        activity = JSON.parse(raw_activity.to_json)
        return activity
      end

      def list_all_athlete_activities
        # In the format of [ [{},{},{}], [{},{},{}], [{},{},{}] ].
        athlete_activities = []
        for i in 1..100 # 100 pages, which can hold up to 20000 activities.
          new_page = @api_client.list_athlete_activities({:per_page => 200, :page => i})
          if new_page.empty?
            break
          else
            athlete_activities << new_page
          end
        end
        return athlete_activities
      end

      private :list_all_athlete_activities
    end
  end
end
