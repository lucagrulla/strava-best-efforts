module StravaBestEfforts

  module Fetcher

    class BestEffortParser

      def self.parse(activity_json, maximum_pr_rank)

        if activity_json['best_efforts'].nil?
          $logger.debug("This activity doesn't contain any best effort items.")
          return
        end  

        activity_json['best_efforts'].reduce([]) do |acc, best_effort|
          pr_rank = best_effort['pr_rank']
          if pr_rank.nil?
            $logger.debug("This activity doesn't contain best effort for '#{best_effort['name']}'.")
          else
            if pr_rank > maximum_pr_rank
              $logger.info("Ignoring best effort item found. PR Rank: #{pr_rank}, Maximum Allowed Rank: #{maximum_pr_rank}.")
            else
              activity_id = activity_json['id']
              activity_name = activity_json['name']
              $logger.info("Best effort found. PR Rank: #{pr_rank} - Activity: #{activity_id} - '#{activity_name}'.")

              best_effort_model = Hash.new

              best_effort_model['pr_rank'] = pr_rank
              best_effort_model['activity_id'] = activity_id
              best_effort_model['activity_name'] = activity_name
              best_effort_model['distance'] = activity_json['distance']
              best_effort_model['moving_time'] = activity_json['moving_time']
              best_effort_model['elapsed_time'] = activity_json['elapsed_time']
              best_effort_model['total_elevation_gain'] = activity_json['total_elevation_gain']
              best_effort_model['start_date'] = activity_json['start_date']
              best_effort_model['start_date_local'] = activity_json['start_date_local']
              best_effort_model['start_latitude'] = activity_json['start_latitude']
              best_effort_model['start_longitude'] = activity_json['start_longitude']
              best_effort_model['athlete_count'] = activity_json['athlete_count']
              best_effort_model['trainer'] = activity_json['trainer']
              best_effort_model['commute'] = activity_json['commute']
              best_effort_model['manual'] = activity_json['manual']
              best_effort_model['private'] = activity_json['private']
              best_effort_model['average_speed'] = activity_json['average_speed']
              best_effort_model['max_speed'] = activity_json['max_speed']
              best_effort_model['has_heartrate'] = activity_json['has_heartrate']
              best_effort_model['elev_high'] = activity_json['elev_high']
              best_effort_model['elev_low'] = activity_json['elev_low']
              best_effort_model['workout_type'] = activity_json['workout_type']
              best_effort_model['description'] = activity_json['description']
              best_effort_model['calories'] = activity_json['calories']
              best_effort_model['device_name'] = activity_json['device_name']
              best_effort_model['location_country'] = activity_json['location_country']
              best_effort_model['average_heartrate'] = activity_json['average_heartrate']
              best_effort_model['max_heartrate'] = activity_json['max_heartrate']

              best_effort_model['gear_name'] = activity_json['gear_id'] ? activity_json['gear']['name'] : ''

              best_effort_model['name'] = best_effort['name']
              best_effort_model['elapsed_time'] = best_effort['elapsed_time']
              best_effort_model['start_date'] = best_effort['start_date_local']

              acc << best_effort_model
            end
          end
          acc
        end
      end

    end
  end
end
