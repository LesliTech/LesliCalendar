$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "cloud_driver/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|

    spec.name        = "cloud_driver"
    spec.version     = CloudDriver::VERSION
    spec.authors     = ["LesliTech"]
    spec.email       = ["hello@lesli.tech"]
    spec.homepage    = "https://lesli.cloud"
    spec.summary     = "Smart business assitant"
    spec.description = "chatbot"
    spec.license     = "All rights reserved"

    spec.files = Dir["{app,config,db,lib}/**/*", "license", "Rakefile", "readme.md"]

    spec.add_dependency "rails", "~> 6.0.0"

    spec.add_development_dependency "sqlite3"

end
