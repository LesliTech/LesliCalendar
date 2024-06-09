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

current_user = ::Lesli::User.first
calendar = LesliCalendar::Calendar.first

10.times do |index|
    LesliCalendar::Event.create!({
        title: "Birthday party number: #{ index }", 
        description: "Join us to celebrate John's milestone 30th birthday! We'll have a fun-filled evening with music, games, delicious food, and great company. Don't miss out on the birthday cake and the chance to make unforgettable memories. Please RSVP by [RSVP Date] to let us know if you can make it. Looking forward to seeing you there!",
        date: index.day.from_now,
        start: index.day.from_now,
        end: index.day.from_now,
        url: "",
        location: "Guatemala",
        status: "",
        public: true,
        calendar: calendar,
        #user: current_user
    })
end
