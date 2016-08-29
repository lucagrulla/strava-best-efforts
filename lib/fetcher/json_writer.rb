module StravaBestEfforts

  module Fetcher

    class JsonWriter

      def initialize(file_name)
        @file = File.new(file_name, "w")
      end

      def append_results(results)
        unless results.nil? or results.empty?
          results.each do |result|
            File.open(@file, 'a') do |f|
              f.puts("#{result.to_json},")
            end
          end
        end
      end

      def close
        # Read out the current content.
        content = File.open(@file, "rb") do |f|
          f.read
        end
        # Remove the trailing line endings and comma.
        if content.length > 2
          content.chomp!.chomp!(',')
        end
        # Put everything together and save to file.
        File.open(@file, 'w') do |f|
          f.puts("[\n#{content}\n]")
        end
      end

    end
  end
end
