<script setup>
/*
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
*/

// · Import components, libraries and tools
import { onMounted } from 'vue'
import ComponentDiscussions from "LesliVue/cloud-objects/discussion.vue"
import ComponentFiles from "LesliVue/cloud-objects/file.vue"
import ComponentGuests from './guests.vue'

// · import lesli stores
import { useEvent } from 'CloudDriver/stores/event'
import { useCalendar } from 'CloudDriver/stores/calendar'

// · implement stores
const storeEvent = useEvent()
const storeCalendar = useCalendar()

onMounted(() => {
    storeEvent.getOptions()
})

const translations = {
    events: I18n.t('driver.events'),
    core: I18n.t('core.shared'),
}

const submitEvent = () => {
    if (storeCalendar.event.id) {
        storeCalendar.putEvent()
    }
    else {
        storeCalendar.postEvent()
    }
}

const deleteEvent = async () => {
    await storeCalendar.deleteEvent()
}

</script>

<template>

    <lesli-panel v-model:open="storeEvent.showModal">
        <template #header>
        </template>

        <template #default>
            <lesli-tabs v-model="tab">
                
                <lesli-tab-item :title="translations.core.view_tab_title_general_information" icon="info">
                    <form @submit.prevent="submitEvent">
                        <fieldset>
                            <div class="columns">
                                <div class="column">
                                    <field label="column_user_main_id">
                                        <p>{{ translations.events.column_user_main_id }}</p>
                                        <input class="input is-default" type="text" name="organizer_name"
                                            v-model="storeCalendar.event.organizer_name" readonly />
                                    </field>
                                    <field>
                                        <p>{{ translations.events.column_title }}</p>
                                        <input class="input is-default" type="text" name="organizer_name"
                                            v-model="storeCalendar.event.detail_attributes.title" required />
                                    </field>
                                    <field>
                                        <p>{{ translations.events.column_time_start }}</p>
                                        <lesli-calendar v-model="storeCalendar.event.detail_attributes.time_start" mode="dateTime">
                                        </lesli-calendar>
                                    </field>
                                    <field>
                                        <p>{{ translations.events.column_budget }}
                                            ({{ storeCalendar.lesli.settings.currency.symbol }})</p>
                                        <input class="input is-default" type="number" name="budget" min="0" step="0.01"
                                            v-model="storeCalendar.event.detail_attributes.budget" />
                                    </field>
                                    <field>
                                        <p>{{ translations.events.column_showed_up_count }}</p>
                                        <input class="input is-default" type="number" name="showed_up_count" min="0"
                                            step="1" v-model="storeCalendar.event.detail_attributes.showed_up_count" />
                                    </field>
                                    <field>
                                        <p>Estimated duration (mins)</p>
                                        <input class="input is-default" type="number" name="estimated_mins_durations"
                                            min="10" step="10"
                                            v-model="storeCalendar.event.estimated_mins_durations" />
                                    </field>
                                </div>
                                <div class="column">
                                    <field>
                                        <p>{{ translations.events.column_cloud_driver_catalog_event_types_id }}</p>
                                        <lesli-select
                                            v-model="storeCalendar.event.cloud_driver_catalog_event_types_id"
                                            icon="public" :options="storeEvent.options.event_types">
                                        </lesli-select>
                                    </field>
                                    <field>
                                        <p>{{ translations.events.column_location }}</p>
                                        <input class="input is-default" type="text" name="address"
                                            v-model="storeCalendar.event.detail_attributes.location" />
                                    </field>
                                    <field>
                                        <p>{{ translations.events.column_time_end }}</p>
                                        <lesli-calendar v-model="storeCalendar.event.detail_attributes.time_end" mode="dateTime">
                                        </lesli-calendar>
                                    </field>
                                    <field>
                                        <p>{{ translations.events.column_real_cost }}
                                            ({{ storeCalendar.lesli.settings.currency.symbol }})</p>
                                        <input class="input is-default" type="number" name="real_cost" min="0"
                                            step="0.01" v-model="storeCalendar.event.detail_attributes.real_cost" />
                                    </field>
                                    <field>
                                        <p>{{ translations.events.column_signed_up_count }}</p>
                                        <input class="input is-default" type="number" name="signed_up_count" min="0"
                                            step="1" v-model="storeCalendar.event.detail_attributes.signed_up_count" />
                                    </field>
                                </div>
                            </div>
                            <div class="columns">
                                <div class="column">
                                    <field>
                                        <p>{{ translations.events.column_description }}</p>
                                        <div class="control">
                                            <textarea v-model="storeCalendar.event.detail_attributes.description" class="textarea"
                                                name="description"></textarea>
                                        </div>
                                    </field>
                                </div>
                            </div>
                            <div class="columns">
                                <div class="column">
                                    <field>
                                        <label class="checkbox">
                                            {{ "View text mark as public?" }}
                                            <input type="checkbox" name="public" v-model="storeCalendar.event.detail_attributes.public">
                                        </label>
                                    </field>
                                </div>
                                <div class="column">
                                    <field>
                                        <label class="checkbox">
                                            {{ "Is proposal?" }}
                                            <input type="checkbox" name="is_proposal"
                                                v-model="storeCalendar.event.detail_attributes.is_proposal">
                                        </label>
                                    </field>
                                </div>
                            </div>

                            <div class="buttons">
                                <button name="btn-save" type="submit" class="button is-primary is-fullwidth">
                                    <span><span class="icon is-small"><i class="fas fa-save"></i></span>&nbsp;</span>
                                </button>
                            </div>
                        </fieldset>
                    </form>
                </lesli-tab-item>

                <lesli-tab-item :title="translations.core.view_btn_discussions" icon="forum">
                    <ComponentDiscussions v-if="storeCalendar.event_id" cloud-module="driver" cloud-object="events"
                        :cloud-object-id="storeCalendar.event.id" :onlyDiscussions="true">
                    </ComponentDiscussions>
                </lesli-tab-item>

                <lesli-tab-item :title="translations.core.view_btn_files" icon="attach_file">
                    <ComponentFiles 
                        v-if="storeCalendar.event_id" 
                        cloud-module="driver" 
                        cloud-object="events"
                        :cloud-object-id="storeCalendar.event.id"
                        :accepted-files="['images', 'documents', 'plaintext']">
                    </ComponentFiles>
                </lesli-tab-item>

                <lesli-tab-item :title="translations.events.view_tab_title_assignments" icon="group">
                    <ComponentGuests v-if="storeCalendar.event_id"/>
                </lesli-tab-item>

                <lesli-tab-item :title="translations.events.view_tab_title_delete_section" icon="delete">
                    <div v-if="storeCalendar.event_id" class="buttons">
                        <button type="is-danger" @click="deleteEvent()" class="button is-danger submit-button" :disabled="storeEvent.submit.delete">
                            <span v-if="storeEvent.submit.delete">
                                <i class="fas fa-spin fa-circle-notch"></i> {{translations.core.view_btn_deleting}}
                            </span>
                            <span v-else>
                                <i class="fas fa-trash-alt"></i> {{translations.core.view_btn_delete}}
                            </span>
                        </button>
                    </div>
                </lesli-tab-item>

            </lesli-tabs>
        </template>
    </lesli-panel>

</template>