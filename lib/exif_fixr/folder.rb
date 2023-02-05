module ExifFixr
  class Folder
    attr_reader :segment

    def initialize(full_path, geolocation_service)
      @full_path = full_path
      @geolocation_service = geolocation_service
      @geolocation = nil
      @segment = full_path.split("/").find { |i| i.match(ExifFixr.folder_format) }
    end

    def skip?
      @segment.nil?
    end

    def date
      @date ||=
        begin
          if match[:year] && match[:month] && match[:day]
            Date.new(match[:year].to_i, match[:month].to_i, match[:day].to_i)
          elsif match[:year] && match[:month]
            Date.new(match[:year].to_i, match[:month].to_i, 1)
          elsif match[:year]
            Date.new(match[:year].to_i, 1, 1)
          else
            $stderr.puts "Could not parse date from #{@segment}"
            nil
          end
        end
    end

    def geolocation
      return nil if match[:geo].nil?
      return @geolocation if @geolocation

      @geolocation = Geocoder.search(match[:geo]).first.coordinates
    end

    def match
      @match ||= @segment.match(ExifFixr.folder_format)
    end
  end
end
