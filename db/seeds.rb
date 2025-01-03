=begin

Copyright (c) 2023, all rights reserved.

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


L2.msg("LesliCalendar", "Version: #{LesliCalendar::VERSION}", "Build: #{LesliCalendar::BUILD}")


# · load specific environment seeds
if Rails.env.development? || Lesli.config.demo 
    load LesliCalendar::Engine.root.join("db", "seed", "events.rb")
end
