# frozen_string_literal: true

require_relative "lib/exif_fixr/version"

Gem::Specification.new do |spec|
  spec.name = "exif_fixr"
  spec.version = ExifFixr::VERSION
  spec.authors = ["Stefan Wienert"]
  spec.email = ["info@stefanwienert.de"]

  spec.summary = "Mass-Fix EXIF date + GPS tags of your old photos"
  spec.description = "Mass-Fix EXIF date + GPS tags of your old photos"
  spec.homepage = "https://github.com/zealot128/exif_fixr"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage + "/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'activesupport', ">= 6.0.0"
  spec.add_dependency 'geocoder'
  spec.add_dependency 'mini_exiftool', ">= 2.10.0"
  spec.add_dependency 'thor'

  spec.add_development_dependency 'pry'
end
