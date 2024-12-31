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
const storeEvent = useEvents()


// · 
const translations = {
    events: i18n.t("lesli_calendar.events"),
    lesli: i18n.t("lesli.shared"),
    core: I18n.t('core.shared'),
}


// · 
const submitEvent = () => {
    if (storeCalendar.event.id) {
        storeCalendar.putEvent()
    }
    else {
        storeCalendar.postEvent()
    }
}
</script>
<template>
    <lesli-form @submit="submitEvent" class="p-4" flat>

        <lesli-input
            required
            v-model="storeCalendar.event.title"
            :label="translations.events.column_title"
        />

        <lesli-field :label="translations.events.column_start">
            <lesli-calendar v-model="storeCalendar.event.start" mode="dateTime">
            </lesli-calendar>
        </lesli-field>

        <lesli-field :label="translations.events.column_end">
            <lesli-calendar v-model="storeCalendar.event.end" mode="dateTime">
            </lesli-calendar>
        </lesli-field>

        <lesli-field :label="translations.events.column_description">
            <textarea v-model="storeCalendar.event.description" class="textarea" name="description"></textarea>
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
            <input type="checkbox" name="public" v-model="storeCalendar.event.public">
            {{ translations.events.view_event_public }}
        </lesli-field>

        <lesli-field>
            <lesli-button type="submit" icon="save">{{ translations.lesli.button_save }}</lesli-button>  
        </lesli-field>


        <!--
        <br><br>

        <div class="columns">
            <div class="column">
                <div label="column_user_main_id">
                    <p>{{ translations.events.column_user_main_id }}</p>
                    <input class="input is-default" type="text" name="organizer_name"
                        v-model="storeCalendar.event.organizer_name" readonly />
                </div>
                <div>
                    <p>{{ translations.events.column_title }}</p>
                    <input class="input is-default" type="text" name="title" v-model="storeCalendar.event.title"
                        required />
                </div>
                <div>
                    <p>{{ translations.events.column_time_start }}</p>
                    <lesli-calendar v-model="storeCalendar.event.time_start" mode="dateTime">
                    </lesli-calendar>
                </div>
                <div>
                    <p>{{ translations.events.column_budget }}
                        ({{ storeCalendar.lesli.settings.currency.symbol }})</p>
                    <input class="input is-default" type="number" name="budget" min="0" step="0.01"
                        v-model="storeCalendar.event.budget" />
                </div>
                <div>
                    <p>{{ translations.events.column_showed_up_count }}</p>
                    <input class="input is-default" type="number" name="showed_up_count" min="0" step="1"
                        v-model="storeCalendar.event.showed_up_count" />
                </div>
            </div>
            <div class="column">
                <div>
                    <p>{{ translations.events.column_cloud_driver_catalog_event_types_id }}</p>
                    <lesli-select v-model="storeCalendar.event.cloud_driver_catalog_event_types_id" icon="public"
                        :options="storeEvent.options.event_types">
                    </lesli-select>
                </div>
                <div>
                    <p>{{ translations.events.column_location }}</p>
                    <input class="input is-default" type="text" name="address"
                        v-model="storeCalendar.event.location" />
                </div>
                <div>
                    <p>{{ translations.events.column_time_end }}</p>
                    <lesli-calendar v-model="storeCalendar.event.time_end" mode="dateTime">
                    </lesli-calendar>
                </div>
                <div>
                    <p>{{ translations.events.column_real_cost }}
                        ({{ storeCalendar.lesli.settings.currency.symbol }})</p>
                    <input class="input is-default" type="number" name="real_cost" min="0" step="0.01"
                        v-model="storeCalendar.event.real_cost" />
                </div>
                <div>
                    <p>{{ translations.events.column_signed_up_count }}</p>
                    <input class="input is-default" type="number" name="signed_up_count" min="0" step="1"
                        v-model="storeCalendar.event.signed_up_count" />
                </div>
            </div>
        </div>
        <div class="columns">
            <div class="column">
                <div>
                    <p>{{ translations.events.column_description }}</p>
                    <div class="control">
                        <textarea v-model="storeCalendar.event.description" class="textarea"
                            name="description"></textarea>
                    </div>
                </div>
            </div>
        </div>
        <div class="columns">
            <div class="column">
                <div>
                    <label class="checkbox">
                        {{ translations.events.view_text_mark_as_public }}
                        <input type="checkbox" name="public" v-model="storeCalendar.event.public">
                    </label>
                </div>
            </div>
            <div class="column">
                <div>
                    <label class="checkbox">
                        {{ "Is proposal?" }}
                        <input type="checkbox" name="is_proposal" v-model="storeCalendar.event.is_proposal">
                    </label>
                </div>
                <div v-show="storeCalendar.event.is_proposal">
                    <p>{{ translations.events.column_estimated_duration }}</p>
                    <input class="input is-default" type="number" name="estimated_mins_durations" min="10" step="10"
                        v-model="storeCalendar.event.estimated_mins_durations" />
                </div>
            </div>
        </div>
        <lesli-button type="submit" icon="save">{{ translations.core.view_btn_save }}</lesli-button>  
        -->
    </lesli-form>
</template>
