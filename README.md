# ExifFixr

Exif-Fixr tries to fix your EXIF (JPG) DateTimeOriginal and GPS information. Especially useful, when you have a bunch of scanned photos or received photos via Social Media where such info is often stripped.

## Installation

(Note: currently this Gem is in development and not released on Ruby gems yet, you might want to check out:)

    git clone https://github.com/zealot128/exif_fixr.git
    cd exif_fixr
    bundle install
    rake install

After released:


    $ gem install exif_fixr

## Usage

```
exif-fixr help
exif-fixr help fix
exif-fixr hlpe
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/zealot128/exif_fixr.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
