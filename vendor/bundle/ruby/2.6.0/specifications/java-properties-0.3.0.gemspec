# -*- encoding: utf-8 -*-
# stub: java-properties 0.3.0 ruby lib

Gem::Specification.new do |s|
  s.name = "java-properties".freeze
  s.version = "0.3.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.5".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Jonas Thiel".freeze]
  s.date = "2021-02-26"
  s.description = "Tool for loading and writing Java properties files".freeze
  s.email = ["jonas@thiel.io".freeze]
  s.homepage = "https://github.com/jnbt/java-properties".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.0.0".freeze)
  s.rubygems_version = "3.0.3".freeze
  s.summary = "Loader and writer for *.properties files".freeze

  s.installed_by_version = "3.0.3" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rake>.freeze, ["~> 13.0"])
      s.add_development_dependency(%q<inch>.freeze, ["~> 0.8"])
      s.add_development_dependency(%q<minitest>.freeze, ["~> 5.14"])
      s.add_development_dependency(%q<coveralls>.freeze, ["~> 0.8"])
    else
      s.add_dependency(%q<rake>.freeze, ["~> 13.0"])
      s.add_dependency(%q<inch>.freeze, ["~> 0.8"])
      s.add_dependency(%q<minitest>.freeze, ["~> 5.14"])
      s.add_dependency(%q<coveralls>.freeze, ["~> 0.8"])
    end
  else
    s.add_dependency(%q<rake>.freeze, ["~> 13.0"])
    s.add_dependency(%q<inch>.freeze, ["~> 0.8"])
    s.add_dependency(%q<minitest>.freeze, ["~> 5.14"])
    s.add_dependency(%q<coveralls>.freeze, ["~> 0.8"])
  end
end
