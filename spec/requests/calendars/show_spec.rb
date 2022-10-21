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
require "lesli_request_helper"

RSpec.describe "Tests for Lesli 3", :unless => defined?(DeutscheLeibrenten) do
    describe "GET:/calendars/default", type: :request do
        include_context "request user authentication"

        it "is expected to get the default calendar only for that user" do
            @user = FactoryBot.create(:user)

            # We create 1 event each month
            (1..12).each do |month|
                event_date = Date.new(DateTime.now.year, month, 1)

                event = FactoryBot.create(
                    :cloud_driver_event,
                    users_id: @user.id,
                    user_main_id: @user.id,
                    cloud_driver_accounts_id: @user.account.id,
                    detail_attributes: {
                        event_date: event_date,
                        time_start: event_date,
                        public: true,
                        time_end: event_date,
                        title: Faker::Sports::Football.competition
                    }
                )

                LC::Debug.msg month, event, event.detail
            end

            start_date = LC::Date.now.beginning_of_year
            end_date = LC::Date.now.end_of_year

            get("/driver/calendars/default.json?filters[start_date]=#{start_date}&filters[end_date]=#{end_date}")

            # shared examples
            expect_response_with_successful

            # custom examples
            expect(response_body).to have_key("driver_events")
            expect(response_body).to have_key("help_tickets")
            expect(response_body).to have_key("focus_tasks")
            expect(response_body["driver_events"].length).to be >= 12
        end


        it "is expected to get the default calendar only for that user on a certain date range" do
            @user = FactoryBot.create(:user)

            # We create 1 event each month
            (1..12).each do |month|
                event_date = Date.new(DateTime.now.year, month, 1)

                event = FactoryBot.create(
                    :cloud_driver_event,
                    users_id: @user.id,
                    cloud_driver_accounts_id: @user.account.id,
                    detail_attributes: {
                        event_date: event_date,
                        time_start: event_date,
                        time_end: event_date,
                        title: Faker::Sports::Football.competition
                    }
                )
            end

            current_time = LC::Date.now

            get("/driver/calendars/default.json?f[start_date]=#{current_time.beginning_of_month}&f[end_date]=#{current_time.end_of_month}")

            # shared examples
            expect_response_with_successful

            # custom examples
            expect(response_body).to have_key("driver_events")

            response_body["driver_events"].each do |event|
                event_date = LC::Date.datetime(event["date"].to_datetime)

                expect(event_date.month).to eq(current_time.month)
            end
        end
    end
end
