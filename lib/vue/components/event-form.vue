<script setup>
/*
Lesli

Copyright (c) 2024, Lesli Technologies, S. A.

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

Made with ♥ by LesliTech
Building a better future, one line of code at a time.

@contact  hello@lesli.tech
@website  https://www.lesli.tech
@license  GPLv3 http://www.gnu.org/licenses/gpl-3.0.en.html

// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
// · 
*/


// · import lesli stores
import { useCalendar } from 'LesliCalendar/vue/stores/calendar'
import { useEvents } from 'LesliCalendar/vue/stores/events'


// · implement stores
const storeCalendar = useCalendar()
const storeEvents = useEvents()


// · 
const translations = {
    events: i18n.t("lesli_calendar.events"),
    lesli: i18n.t("lesli.shared"),
    core: I18n.t('core.shared'),
}


// · 
const submitEvent = () => {
    if (storeEvents.event.id) {
        storeEvents.put()
    }
    else {
        storeEvents.post()
    }
}
</script>
<template>
    <lesli-form @submit="submitEvent" class="p-4" flat>

        <lesli-input
            required
            v-model="storeEvents.event.title"
            :label="translations.events.column_title"
        />

        <lesli-field :label="translations.events.column_start">
            <lesli-calendar v-model="storeEvents.event.start" mode="dateTime">
            </lesli-calendar>
        </lesli-field>

        <lesli-field :label="translations.events.column_end">
            <lesli-calendar v-model="storeEvents.event.end" mode="dateTime">
            </lesli-calendar>
        </lesli-field>

        <lesli-field :label="translations.events.column_description">
            <textarea v-model="storeEvents.event.description" class="textarea" name="description"></textarea>
        </lesli-field>        

        <lesli-field :label="translations.events.column_status">
            <lesli-select
                icon="public"
                :options="[{
                    label: 'Draft',
                    value: 'draft'
                }, {
                    label: 'Proposal',
                    value: 'proposal'
                }, {
                    label: 'Approved',
                    value: 'approved'
                }]">
            </lesli-select>
        </lesli-field>

        <lesli-field>
            <input type="checkbox" name="public" v-model="storeEvents.event.public">
            {{ translations.events.view_event_public }}
        </lesli-field>

        <lesli-field>
            <lesli-button type="submit" icon="save">{{ translations.lesli.button_save }}</lesli-button>  
        </lesli-field>
    </lesli-form>
</template>
