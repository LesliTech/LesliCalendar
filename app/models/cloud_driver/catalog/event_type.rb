=begin
Copyright (c) 2020, all rights reserved.

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

        validates :name, presence: true, uniqueness: true

        def self.index(current_user, query)
            # Parsing filters
            filters = query[:filters]
            filters_query = []

            # We filter by a text string written by the user
            if filters["query"] && !filters["query"].empty?
                query_words = filters["query"].split(" ")
                query_words.each do |query_word|
                    query_word = query_word.strip.downcase

                    # first customer
                    filters_query.push("(lower(name) similar to '%#{query_word}%')")
                end
            end

            # Executing the query
            event_types = current_user.account.driver.event_types

            # We apply the previous filters in the main query
            unless filters_query.empty?
                event_types = event_types.where(filters_query.join(' and '))
            end

            # Adding pagination to event_types
            event_types = event_types
            .page(query[:pagination][:page])
            .per(query[:pagination][:perPage])
            .order("#{query[:pagination][:orderBy]} #{query[:pagination][:order]} NULLS LAST")

            # We format the response

            LC::Response.pagination(
                event_types.current_page,
                event_types.total_pages,
                event_types.total_count,
                event_types.length,
                event_types.map do |event_type|
                    event_type.attributes.merge({
                        "created_at_text" => LC::Date.to_string_datetime(event_type["created_at"])
                    })
                end
            )
        end

        def show
            data = attributes
            data["created_at"] = LC::Date.to_string_datetime(data["created_at"])
            data["updated_at"] = LC::Date.to_string_datetime(data["updated_at"])

            data
        end
    end
end
