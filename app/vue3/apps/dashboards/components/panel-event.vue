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

// · import lesli stores
import { usePanelEvent } from 'CloudDriver/stores/dashboard/panel-event'
import { useCalendar } from 'CloudDriver/stores/dashboard/calendar'

// · implement stores
const storePanelEvent = usePanelEvent()
const storeCalendar = useCalendar()

const emit = defineEmits(['close'])

function submitEvent(event) {
    if (event) event.preventDefault()
    if (storePanelEvent.event.id) storePanelEvent.putEvent()
    storePanelEvent.postEvent()
}

onMounted(() => {
    storePanelEvent.getOptions()
})

</script>

<template>
    <div class="backdrop" @click.self="emit('close')">
        <div class="modal">
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
                                <input class="input is-default" type="number" name="showed_up_count" min="0" step="1"
                                    v-model="storePanelEvent.event.detail_attributes.showed_up_count" />
                            </field>
                        </div>
                        <div class="column">
                            <field>
                                <p>Event type:</p>
                                <lesli-select v-model="storePanelEvent.event.cloud_driver_catalog_event_types_id"
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
                                <input class="input is-default" type="number" name="real_cost" min="0" step="0.01"
                                    v-model="storePanelEvent.event.detail_attributes.real_cost" />
                            </field>
                            <field>
                                <p>Duration (mins):</p>
                                <input class="input is-default" type="number" name="estimated_mins_durations" min="10"
                                    step="10" v-model="storePanelEvent.event.estimated_mins_durations" />
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
        </div>
    </div>

</template>

<style>
field {
    display: flex;
    flex-wrap: nowrap;
    align-items: center;
    margin-bottom: 10px;
}

field div {
    width: 100%;
}

field p {
    width: 40%;
}

input {
    flex-grow: 1;
    /* width:  */
}

textarea.textarea {
  resize: none;
}
.modal {
    display: block;
    width: 750px;
    padding: 20px;
    margin: 170px auto;
    background: white;
    border-radius: 10px;
}

.backdrop {
    position: absolute;
    overflow: hidden;
    display: flex;
    flex-direction: row;
    justify-content: flex-end;
    top: 0;
    right: 0;
    width: 100vw;
    height: 100vh;
    max-width: 100%;
    max-height: 100%;
    background: rgba(0, 0, 0, 0.5);
    z-index: 100;
}

.modal h1 {
    color: #03cfb4;
    border: none;
    padding: 0;
}

.modal p {
    font-style: normal;
}

.modal .actions {
    text-align: center;
    margin: 30px 0 10px 0;
    color: #333;
}

.modal .actions a {
    color: #333;
    padding: 8px;
    border: 1px solid #eee;
    border-radius: 4px;
    text-decoration: none;
    margin: 10px;
}
</style>

