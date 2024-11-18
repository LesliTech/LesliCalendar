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

require "rails_helper"
require Lesli::Engine.root.join("lib/rspec/testers/request")

RSpec.describe "GET:#{LESLI_CALENDAR_ENGINE_MOUNTED_PATH}/calendar.json", type: :request do

    include_context "request user authentication"

    it "is expected to get the default calendar and personal calendar of that user" do

        get("#{LESLI_CALENDAR_ENGINE_MOUNTED_PATH}/calendar.json")

        # shared examples
        expect_response_with_successful

        # custom examples
        expect(response_body).to have_key("id")
        expect(response_body["id"]).to be_a(Numeric)
        expect(response_body["id"]).to be > 0

        expect(response_body).to have_key("name")
        expect(response_body["name"]).to be_a(String)
        expect(response_body["name"]).to eql("default")

        expect(response_body).to have_key("user_id")

        expect(response_body).to have_key("events")
        expect(response_body["events"]).to be_a(Array)

        expect(response_body).to have_key("events_support")
        expect(response_body["events_support"]).to be_a(Array)
    end
end
