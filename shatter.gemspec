Gem::Specification.new do |s|
  s.name        = "shatter"
  s.version     = '0.0.0'
  s.date        = '2013-02-27'
  s.summary     = 'Shatter your DB!'
  s.description = "Database tools for sharding dynamically and at-will"
  s.authors     = ['Eric Mueller']
  s.email       = 'emueller@emcien.com'
  s.files       = [
    "lib/shatter.rb"
  ]
  s.homepage    = 'http://github.com/emcien/shatter'

  s.required_rubygems_version = Gem::Requirement.new(">= 1")
  s.add_dependency("activerecord", ["~> 3.2"])
end

