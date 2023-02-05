# frozen_string_literal: true

require_relative "exif_fixr/version"

module ExifFixr
  class << self
    attr_accessor :folder_format, :cache_dir
  end

  autoload :Cli, "exif_fixr/cli"
  autoload :Folder, "exif_fixr/folder"
  autoload :ImageFix, "exif_fixr/image_fix"

  self.folder_format = /(?<year>\d{4})-?(?<month>\d{2})-?(?<day>\d{2})?(?<geo>,.*)?/

  self.cache_dir = "#{ENV['HOME']}/.exif-geocache"

  class Error < StandardError; end
end
