=begin

Copyright (c) 2021, all rights reserved.

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


require 'lesli_request_helper'

RSpec.describe "POST:/driver/events with valid data", type: :request do
    
    include_context "request user authentication"

    it "is expected that the response comes with the correct values" do

        event = {
            "title": Faker::Sports::Football.competition,
            "description": Faker::Lorem.sentence(word_count: 10, supplemental: true),
            "event_type": 3,
            "event_date": Time.current,
            "time_start": Time.current,
            "time_end": Time.current + 2.hours,
            "location": Faker::Address.full_address,
            "budget":"3000"
        }

        post("/driver/events.json", params: { "event": { "detail_attributes": event }})

        expect_json_response_successful

        expect(response_data["organizer_name"]).to eq(@current_user.full_name)
        expect(response_data["detail_attributes"]["title"]).to eq(event[:title])
        expect(response_data["detail_attributes"]["description"]).to eq(event[:description])
        expect(response_data["detail_attributes"]["location"]).to eq(event[:location])
        expect(response_data["detail_attributes"]["budget"]).to eq(event[:budget])

    end

end
