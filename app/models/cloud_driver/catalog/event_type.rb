=begin
Copyright (c) 2022, all rights reserved.

All the information provided by this platform is protected by international laws related  to
industrial property, intellectual property, copyright and relative international laws.
All intellectual or industrial property rights of the code, texts, trade mark, design,
pictures and any other information belongs to the owner of this platform.

Without the written permission of the owner, any replication, modification,
transmission, publication is strictly forbidden.

For more information read the license file including with this software.

// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
// ·

=end
module CloudDriver
    class Catalog::EventType < ApplicationLesliRecord
        belongs_to  :account, class_name: "CloudDriver::Account", foreign_key: "cloud_driver_accounts_id"
        has_many    :events, class_name:  "CloudDriver::Event",   foreign_key: "cloud_driver_catalog_event_types_id"

        validates :name, presence: true

        def self.index(current_user, query)
            # Parsing filters
            filters = query[:filters]

            # Get order params from query
            unless query.dig(:order, :by).blank?
                order_by = query.dig(:order, :by)
                order_dir = query.dig(:order, :dir)
            end

            # get search string from query params
            search_string = query[:search].downcase.gsub(" ","%") unless query[:search].blank?

            # Executing the query
            event_types = current_user.account.driver.event_types

            # We filter by a text string written by the user
            unless search_string.blank?
                event_types = event_types.where(
                    "lower(name) SIMILAR TO :search_string",
                    search_string: "%#{sanitize_sql_like(search_string, " ")}%"
                )
            end

            # Adding order to the query
            event_types = event_types.order(order_by.concat(" ").concat(order_dir)) unless order_by.blank?

            # We format the response
            records = event_types.select("*", LC::Date2.new.db_column("created_at", "cloud_driver_catalog_event_types"))

            # Adding pagination
            records.page(query[:pagination][:page]).per(query[:pagination][:perPage])
        end

        def show
            self.attributes.merge({
                created_at: LC::Date2.new(self.created_at).date_time_words.to_s,
                updated_at: LC::Date2.new(self.updated_at).date_time_words.to_s,
            })
        end
    end
end
