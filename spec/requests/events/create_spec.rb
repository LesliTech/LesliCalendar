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


# include helpers, configuration & initializers for request tests
require "lesli_request_helper"


RSpec.describe "POST:/driver/events", type: :request do
    
    include_context "request user authentication"

    it "is expected to create an event with all the data" do

        event = {
            "title": Faker::Sports::Football.competition,
            "description": Faker::Lorem.sentence(word_count: 10, supplemental: true),
            "event_date": Time.current,
            "time_start": Time.current,
            "time_end": Time.current + 30.hours,
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


    it "is expected to create an event with the minimum data" do

        event = {
            "title": Faker::Sports::Football.competition,
            "event_date": Time.current
        }

        post("/driver/events.json", params: { "event": { "detail_attributes": event }})

        expect_json_response_successful

        expect(response_data["organizer_name"]).to eq(@current_user.full_name)
        expect(response_data["detail_attributes"]["title"]).to eq(event[:title])

    end


    it "is expected to respond with error if event is empty" do

        event = { }

        post("/driver/events.json", params: { "event": { "detail_attributes": event }})

        expect_json_response_error

        expect(response_error["message"]).to eq("Missing event data")

    end

    it "is expected to respond with error if event title is empty" do

        event = {
            "event_date": Time.current
         }

        post("/driver/events.json", params: { "event": { "detail_attributes": event }})

        expect_json_response_error

        expect(response_error["message"]).to eq("Missing event data")

    end

    it "is expected to respond with error if event date is empty" do

        event = {
            "title": Faker::Sports::Football.competition,
         }

        post("/driver/events.json", params: { "event": { "detail_attributes": event }})

        expect_json_response_error

        expect(response_error["message"]).to eq("Missing event data")

    end

end
