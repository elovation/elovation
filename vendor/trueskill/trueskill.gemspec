# -*- encoding: utf-8 -*-

pkg_files = ['README.md','HISTORY.md','Rakefile','LICENSE' ]
pkg_files += Dir['lib/**/*.rb']
pkg_files += Dir['spec/**/*.rb']

Gem::Specification.new do |s|
  s.name                      = "trueskill"
  s.version                   = "1.0.0"
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to?(:required_rubygems_version=)
  s.authors                   = ["Lars Kuhnt"]
  s.date                      = "2011-01-19"
  s.description               = "A ruby library for the trueskill rating system"
  s.email                     = "lars@sauspiel.de"
  s.files                     = pkg_files
  s.homepage                  = "http://github.com/saulabs/trueskill"
  s.require_paths             = ["lib"]
  s.rubygems_version          = "1.3.6"
  s.summary                   = "A ruby library for the trueskill rating system"
  s.description               = ""
  s.test_files                = Dir['spec/**/*.{rb,yml,opts}']
end

