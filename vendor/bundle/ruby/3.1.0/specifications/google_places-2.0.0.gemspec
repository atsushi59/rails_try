# -*- encoding: utf-8 -*-
# stub: google_places 2.0.0 ruby lib

Gem::Specification.new do |s|
  s.name = "google_places".freeze
  s.version = "2.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Marcel de Graaf".freeze]
  s.date = "2019-08-25"
  s.description = "This gem provides a Ruby wrapper around the Google Places API for use in your own project. Please note that this gem does not provide OAuth authentication.".freeze
  s.email = ["mail@marceldegraaf.net".freeze]
  s.homepage = "https://github.com/marceldegraaf/google_places".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.3.3".freeze
  s.summary = "A Ruby wrapper around the Google Places API.".freeze

  s.installed_by_version = "3.3.3" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<httparty>.freeze, [">= 0.13.1"])
    s.add_development_dependency(%q<rspec>.freeze, ["~> 3.0"])
    s.add_development_dependency(%q<addressable>.freeze, ["~> 2.4.0"])
    s.add_development_dependency(%q<webmock>.freeze, ["~> 1.18"])
    s.add_development_dependency(%q<vcr>.freeze, ["~> 2.9"])
  else
    s.add_dependency(%q<httparty>.freeze, [">= 0.13.1"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.0"])
    s.add_dependency(%q<addressable>.freeze, ["~> 2.4.0"])
    s.add_dependency(%q<webmock>.freeze, ["~> 1.18"])
    s.add_dependency(%q<vcr>.freeze, ["~> 2.9"])
  end
end
