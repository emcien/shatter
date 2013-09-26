Gem::Specification.new do |s|
  s.name        = "shatter"
  s.version     = '0.1.0'
  s.date        = '2013-02-27'
  s.summary     = 'Shatter your DB!'
  s.description = "Database tools for sharding dynamically and at-will"
  s.authors     = ['Eric Mueller']
  s.email       = 'emueller@emcien.com'
  s.files       = [
    "README.md",
    "lib/shatter.rb",
    "lib/shatter/connection_handler.rb",
    "lib/shatter/ar_extensions.rb"
  ]
  s.homepage    = 'http://github.com/emcien/shatter'

  s.required_rubygems_version = Gem::Requirement.new(">= 1")
  s.add_dependency("activerecord", ["~> 4.0.0"])
end

