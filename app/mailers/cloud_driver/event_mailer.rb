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
module CloudDriver
    class EventMailer < ApplicationLesliMailer

        def attendant
            user = params[:user]
            event = params[:event]

            self.build_data_from_params(params, {
                event_id: event.id,
                event_title: event.title,
                organizer_name: event.user_main_including_deleted.full_name,
                title: I18n.t("driver.events.mailer_event_attendant_subject"),
                link_information: I18n.t("driver.events.mailer_event_attendant_link_information"),
                link_text: I18n.t("driver.events.mailer_event_attendant_link_text"),
                user: {
                    full_name: user.full_name
                }
            })

            attachments[I18n.t("driver.events.mailer_event_filename")] = event.download

            mail(
                to: email_address_with_name(user.email, user.full_name),
                subject: I18n.t("driver.events.mailer_event_attendant_subject")
            )
        end
    end
end
