require 'thor'

module ExifFixr
  class Cli < Thor
    package_name "exiffix"

    desc "fix *FILES", "fix exif data of all files"
    method_option :start_from, aliases: "-s", desc: "Skip until this file (to resume after crashes or kills)"
    method_option :geolocation_service,
                  aliases: "-g",
                  default: "nominatim",
                  desc: "geolocation service to use (google, nominatim)" \
                        "\nIf you want to use GoogleMaps, you will need to provide an GEOCODING_API_KEY env variable"
    method_option :dry_run, aliases: "-n", type: :boolean, default: false,
                            desc: "dry run, don't actually change anything"

    def fix(*files)
      require 'geocoder'
      require 'active_support/all'

      if files.length == 0
        puts "No files given"
        exit 1
      end

      initialize_geocoder! geolocation_service: options[:geolocation_service]
      folders = {}
      color = Thor::Shell::Color.new
      find_files(files).each do |file|
        folder = Folder.new(file, options[:geolocation_service])
        next if folder.skip?

        folders[folder.segment] ||= folder.tap do |f|
          puts "Found new folder #{color.set_color(f.segment, :cyan)}" \
            "-> Date: #{color.set_color(f.date, :green)}," \
            "Location: #{color.set_color(f.geolocation, :blue)}"
        end

        ImageFix.new(file: file, dry_run: options[:dry_run], folder: folder).run
      end
    end

    private

    def find_files(files)
      todo = if options[:start_from]
               before_count = files.index(options[:start_from])
               unless before_count
                 warn "File #{options[:start_from]} not found in list"
                 exit 1
               end
               puts "Skipping #{before_count} files"
               files.drop_while { |i| i != options[:start_from] }
             else
               files
             end

      todo.flat_map do |file|
        if File.directory?(file)
          Dir["#{file}/**/*.{jpg,JPG,jpeg,JPEG}"]
        else
          file
        end
      end
    end

    def initialize_geocoder!(geolocation_service:)
      cache_store = Geocoder::CacheStore::Generic.new(ActiveSupport::Cache::FileStore.new(ExifFixr.cache_dir), {})
      Geocoder.configure(
        lookup: geolocation_service.to_sym,
        cache: cache_store,
        api_key: geocoding_api_key(geolocation_service)
      )
    end

    def geocoding_api_key(geolocation_service)
      return if geolocation_service == "nominatim"

      if ENV["GEOCODING_API_KEY"]
        ENV["GEOCODING_API_KEY"]
      else
        warn "No API key given for #{options[:geolocation_service]}, Performance of Geocoding might be limited"
        nil
      end
    end
  end
end
