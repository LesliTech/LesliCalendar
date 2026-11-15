class CreateLesliCalendarEventInvitations < ActiveRecord::Migration[8.1]
    def change
        create_table :lesli_calendar_event_user_invitations do |t|
            t.references :event, null: false, foreign_key: { to_table: :lesli_calendar_events }, index: false
            t.references :user, null: false, foreign_key: { to_table: :lesli_users }
            t.timestamps
            t.index [:event_id, :user_id], unique: true, name: "index_calendar_event_user_invitations"
        end

        create_table :lesli_calendar_event_role_invitations do |t|
            t.references :event, null: false, foreign_key: { to_table: :lesli_calendar_events }, index: false
            t.references :role, null: false, foreign_key: { to_table: :lesli_roles }
            t.timestamps
            t.index [:event_id, :role_id], unique: true, name: "index_calendar_event_role_invitations"
        end
    end
end
