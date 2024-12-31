=begin

Lesli

Copyright (c) 2023, Lesli Technologies, S. A.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see http://www.gnu.org/licenses/.

Lesli · Ruby on Rails SaaS Development Framework.

Made with ♥ by https://www.lesli.tech
Building a better future, one line of code at a time.

@contact  hello@lesli.tech
@website  https://www.lesli.tech
@license  GPLv3 http://www.gnu.org/licenses/gpl-3.0.en.html

// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
// · 
=end

# ·
require "rails_helper"
require Lesli::Engine.root.join("lib/rspec/testers/request")

# ·
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
