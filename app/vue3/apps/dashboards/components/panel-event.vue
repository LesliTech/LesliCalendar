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
import { onMounted, defineEmits } from 'vue'
import ComponentDiscussions from "LesliVue/cloud-objects/discussion.vue"
import ComponentFiles from "LesliVue/cloud-objects/file.vue"

// import assignments from './components/assignments.vue'

// · import lesli stores
import { usePanelEvent } from 'CloudDriver/stores/dashboard/panel-event'

// · implement stores
const storePanelEvent = usePanelEvent()

const emit = defineEmits(['close'])

function submitEvent(event) {
    if (event) event.preventDefault()
    if (storePanelEvent.event.id) storePanelEvent.putEvent()
    storePanelEvent.postEvent()
}

onMounted(() => {
    storePanelEvent.getOptions()
})

const translations = {
    main: I18n.t('social.posts'),
    sla: I18n.t('social.slas'),
    core: {
        shared: I18n.t('core.shared')
    },
    shared: I18n.t('social.shared')
}

</script>

<template>

    <lesli-panel v-model:open="storePanelEvent.showModal">
        <template #header>   
        </template>

        <template #default>
            <lesli-tabs v-model="tab">

                <lesli-tab-item :title="translations.core.shared.view_tab_title_general_information" icon="info">
                    <form @submit.prevent="submitEvent">
                        <fieldset>
                            <div class="columns">
                                <div class="column">
                                    <field label="column_user_main_id">
                                        <p>Organizer:</p>
                                        <input class="input is-default" type="text" name="organizer_name"
                                            v-model="storePanelEvent.event.organizer_name" readonly />
                                    </field>
                                    <field>
                                        <p>Title:</p>
                                        <input class="input is-default" type="text" name="organizer_name"
                                            v-model="storePanelEvent.event.detail_attributes.title" required />
                                    </field>
                                    <field>
                                        <p>Date start:</p>
                                        <lesli-calendar :v-model="storePanelEvent.event.detail_attributes.time_start"
                                            mode="dateTime">
                                        </lesli-calendar>
                                    </field>
                                    <field>
                                        <p>Budget:</p>
                                        <input class="input is-default" type="number" name="budget" min="0" step="0.01"
                                            v-model="storePanelEvent.event.detail_attributes.budget" />
                                    </field>
                                    <field>
                                        <p>Showed up count:</p>
                                        <input class="input is-default" type="number" name="showed_up_count" min="0"
                                            step="1"
                                            v-model="storePanelEvent.event.detail_attributes.showed_up_count" />
                                    </field>
                                </div>
                                <div class="column">
                                    <field>
                                        <p>Event type:</p>
                                        <lesli-select
                                            v-model="storePanelEvent.event.cloud_driver_catalog_event_types_id"
                                            icon="public" :options="storePanelEvent.options.event_types">
                                        </lesli-select>
                                    </field>
                                    <field>
                                        <p>Address:</p>
                                        <input class="input is-default" type="text" name="address"
                                            v-model="storePanelEvent.event.detail_attributes.location" />
                                    </field>
                                    <field>
                                        <p>Date end:</p>
                                        <lesli-calendar :v-model="storePanelEvent.event.detail_attributes.time_end"
                                            mode="dateTime">
                                        </lesli-calendar>
                                    </field>
                                    <field>
                                        <p>Real cost:</p>
                                        <input class="input is-default" type="number" name="real_cost" min="0"
                                            step="0.01" v-model="storePanelEvent.event.detail_attributes.real_cost" />
                                    </field>
                                    <field>
                                        <p>Duration (mins):</p>
                                        <input class="input is-default" type="number" name="estimated_mins_durations"
                                            min="10" step="10"
                                            v-model="storePanelEvent.event.estimated_mins_durations" />
                                    </field>

                                </div>
                            </div>
                            <div class="columns">
                                <div class="column">
                                    <field>
                                        <p>Description:</p>
                                        <div class="control">
                                            <textarea v-model="storePanelEvent.event.detail_attributes.description"
                                                class="textarea" name="description"></textarea>
                                        </div>
                                    </field>
                                </div>
                            </div>
                            <div class="columns">
                                <div class="column">
                                    <field>
                                        <label class="checkbox">
                                            {{ "View text mark as public?" }}
                                            <input type="checkbox" name="public" v-model="storePanelEvent.event.public">
                                        </label>
                                    </field>
                                </div>
                                <div class="column">
                                    <field>
                                        <label class="checkbox">
                                            {{ "Is proposal?" }}
                                            <input type="checkbox" name="is_proposal"
                                                v-model="storePanelEvent.event.is_proposal">
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

                <lesli-tab-item v-if="storePanelEvent.event.id" :title="translations.core.shared.view_btn_discussions"
                    icon="forum">
                    <ComponentDiscussions cloud-module="driver" cloud-object="events"
                        :cloud-object-id="storePanelEvent.event.id" :onlyDiscussions="true">
                    </ComponentDiscussions>
                </lesli-tab-item>

                <lesli-tab-item v-if="storePanelEvent.event.id" :title="translations.core.shared.view_btn_files"
                    icon="attach_file">
                    <ComponentFiles cloud-module="driver" cloud-object="events"
                        :cloud-object-id="storePanelEvent.event.id"
                        :accepted-files="['images', 'documents', 'plaintext']"></ComponentFiles>
                </lesli-tab-item>

                <lesli-tab-item v-if="storePanelEvent.event.id" :title="translations.main.view_tab_title_assignments" icon="group">
               
            </lesli-tab-item>

            </lesli-tabs>
        </template>
    </lesli-panel>

</template>