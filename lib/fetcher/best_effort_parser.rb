module StravaBestEfforts
  module Fetcher
    class BestEffortParser
      def self.parse(best_effort)

        gear_name = best_effort['gear_id'] ? best_effort['gear']['name'] : ''
        extra = {'activity_id' => best_effort['id'],'activity_name' => best_effort['name'], 'gear_name' => gear_name}

        best_effort.merge(extra)
      end

    end
  end
end
