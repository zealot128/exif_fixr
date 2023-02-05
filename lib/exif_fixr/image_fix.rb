require "mini_exiftool"

module ExifFixr
  class ImageFix
    attr_reader :file

    def initialize(file:, folder: nil, dry_run: false, geolocation_service: "google")
      @file = file
      @folder = folder
      @dry_run = dry_run
      @geolocation_service = geolocation_service
      @update_exif = {}
    end

    def run
      # check if file
      unless File.file?(file)
        log :error, "not a file"
        return
      end

      if date_diverged?
        update_date = Date.parse(should_be_date).to_datetime + 0.5
        @update_exif["datetimeoriginal"] = update_date
        @update_exif["createdate"] = update_date

        log :update, "update #{update_date} (was '#{@date_from_file}')"
      end
      if gps_updatable?
        lat, lng = @folder.geolocation
        @update_exif["gpslatitude"] = lat
        @update_exif["gpslongitude"] = lng
        @update_exif['gpslatituderef'] = lat < 0 ? 'S' : 'N'
        @update_exif['gpslongituderef'] = lng < 0 ? 'W' : 'E'
      end
      if @update_exif.any?
        save
      else
        log :info, "skip - no changes"
      end
    end

    private

    # ["gpsdatestamp", "gpsaltituderef", "gpslongituderef", "gpsimgdirection",
    # "gpsprocessingmethod", "gpslatituderef", "gpsimgdirectionref",
    # "gpstimestamp", "gpsaltitude", "gpsdatetime", "gpslatitude",
    # "gpslongitude", "gpsposition"]
    def gps_updatable?
      return false if (exif['gpslatitude'] && exif['gpslongitude']) || exif['gpsposition']

      @folder.geolocation.present?
    end

    def date_from_file
      return @date_from_file if @date_from_file

      @date_from_file = exif["datetimeoriginal"] || exif["createdate"]
      if @date_from_file.is_a?(String)
        fixup_broken_date(@date_from_file)
        @date_from_file = exif["datetimeoriginal"] || exif["createdate"]
      end
      @date_from_file
    end

    def date_diverged?
      return true if date_from_file.nil?
      return true if date_from_file.to_date + 1 <= @folder.date.to_date

      false
    end

    def save
      if @dry_run
        log :dry_run, @update_exif.to_json
        return
      end
      @update_exif.each do |key, value|
        exif[key] = value
      end
      exif.save
      log :update, @update_exif.to_json
    end

    def log(type, msg)
      prefix = self.class.format_prefix(type)
      puts "#{prefix} \"#{@file}\" #{msg}"
    end

    def fixup_broken_date(datetime)
      if datetime[/(\d\d\d\d):(\d?\d):(\d?\d)(.*)/]
        # use .rjust(2, "0") to pad with leading zeros
        new_dt = "#{$1}-#{$2.rjust(2, "0")}-#{$3.rjust(2, "0")}#{$4}"
        log :fix, "fixing legacy broken date format from '#{datetime}' to '#{new_dt}'"
        datetime = Time.parse(new_dt)
        @update_exif["datetimeoriginal"] = datetime
        @update_exif["createdate"] = datetime
        exif["datetimeoriginal"] = datetime
        exif["createdate"] = datetime
        datetime
      else
        log :warn, "could not fixup date '#{datetime}'"
      end
    end

    def exif
      @exif ||= MiniExiftool.new(file)
    end

    def should_be_date
      @should_be_date ||= @file.split('/').find { |i| i =~ ExifFixr.folder_format }
    end

    def self.format_prefix(type)
      prefix = "[#{type.to_s.upcase}]"
      @color ||= Thor::Shell::Color.new
      case type
      when :error
        @color.set_color(prefix, :red)
      when :update
        @color.set_color(prefix, :green)
      when :dry_run
        @color.set_color(prefix, :yellow)
      else
        prefix
      end
    end
  end
end
