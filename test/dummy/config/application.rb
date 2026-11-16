require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module Dummy
    class Application < Rails::Application
        config.load_defaults Rails::VERSION::STRING.to_f
        config.action_controller.include_all_helpers = false
        config.autoload_lib(ignore: %w[assets tasks])

        initializer :load_core_migrations do |app|
            app.config.paths["db/migrate"] << Lesli::Engine.root.join("db/migrate").to_s
            # Schema loading must see the same migrations as db:migrate and the tests.
            ActiveRecord::Migrator.migrations_paths = (app.config.paths["db/migrate"].expanded +
                [LesliCalendar::Engine.root.join("db/migrate").to_s]).uniq
        end
    end
end
