module CloudDriver
    module Catalog
        def self.table_name_prefix
            'cloud_driver_catalog_'
        end

        def self.initialize_data(account)
            # Initializing Event Types
            account.event_types.create!(name: "Internal Meeting")
            account.event_types.create!(name: "Meeting with Clients")
            account.event_types.create!(name: "Meeting with Providers")
            account.event_types.create!(name: "Video Call")
            account.event_types.create!(name: "Other")
        end
    end
end
