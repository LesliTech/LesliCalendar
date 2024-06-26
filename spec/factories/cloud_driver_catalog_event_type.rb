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


FactoryBot.define do
    factory :cloud_driver_catalog_event_type, class: "LesliCalendar::Catalog::EventType" do
        cloud_driver_accounts_id { Account.first.driver.id }
        name { Faker::FunnyName.two_word_name }
    end
end
