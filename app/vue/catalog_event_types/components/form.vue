<script>
/*
Copyright (c) 2020, all rights reserved.

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


// · List of Imported Components
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~


// ·
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
export default {
    props: {
        event_type: {
            required: true
        }
    },

    components: {

    },

    data() {
        return {
            submitting: false,
            deleting: false,
            options: {
                model_types: []
            },
            translations: {
                main: I18n.t('driver.catalog/event_types'),
                core: I18n.t('core.shared')
            }
        }
    },

    mounted() {
        this.getEventTypeOptions()
    },

    methods: {
        getEventTypeOptions(){
            let url = this.url.driver('catalog/event_types/options')

            this.http.get(url).then(result => {
                if (result.successful) {
                    this.options = result.data||{}
                }else{
                    this.alert(result.error.message,'danger')
                }
            }).catch(error => {
                console.log(error)
            })
        },

        submitEventType(event){
            if (event) { event.preventDefault() }

            if (this.event_type.id) {
                this.putEventType()
            } else {
                this.postEventType()
            }
        },

        postEventType() {
            this.submitting = true
            let url = this.url.driver('catalog/event_types')

            let form_data = {
                event_type: this.event_type
            }

            this.http.post(url, form_data).then(result => {
                this.submitting = false
                if (result.successful) {
                    this.msg.success(this.translations.main.messages_success_event_type_created)

                    this.$router.push(`/${result.data.id}`)
                }else{
                    this.msg.error(result.error.message)
                }
            }).catch(error => {
                console.log(error)
            })
        },

        putEventType() {
            this.submitting = true
            let url = this.url.driver('catalog/event_types/:event_type_id', {event_type_id: this.event_type.id})

            let form_data = {
                event_type: this.event_type
            }

            this.http.put(url, form_data).then(result => {
                this.submitting = false
                if (result.successful) {
                    this.msg.success(this.translations.main.messages_success_event_type_updated)
                }else{
                    this.msg.error(result.error.message)
                }
            }).catch(error => {
                console.log(error)
            })

        },

        deleteEventType() {
            this.deleting = true
            let url = this.url.driver('catalog/event_types/:event_type_id', {event_type_id: this.event_type.id})

            this.http.delete(url).then(result => {
                this.deleting = false
                if (result.successful) {
                    this.msg.success(this.translations.main.messages_success_event_type_destroyed)

                    this.$router.push('/')
                }else{
                    this.msg.error(result.error.message)
                }
            }).catch(error => {
                console.log(error)
            })
        }
    }
}
</script>
<template>
    <div class="card" v-if="event_type">
        <div class="card-header" v-if="event_type.id">
            <h2 class="card-header-title">
                {{translations.main.view_title_edit}}
            </h2>
        </div>

        <div class="card-content">
            <b-tabs>
                <b-tab-item :label="translations.core.view_tab_title_general_information">
                    <form @submit="submitEventType">
                        <div class="columns">
                            <div class="column">
                                <b-field>
                                    <template v-slot:label>
                                        {{translations.core.column_name}}
                                        <sup class="has-text-danger">*</sup>
                                    </template>
                                    <b-input v-model="event_type.name" required="true"></b-input>
                                </b-field>
                            </div>
                            <div class="column">
                                <b-field :label="translations.main.column_model_type" :message="translations.main.view_text_column_model_type_description">
                                    <b-select v-model="event_type.model_type" expanded>
                                        <option :value="null">{{translations.core.view_text_none}}</option>
                                        <option v-for="model_type in options.model_types" :key="model_type.value" :value="model_type.value">
                                            {{object_utils.translateEnum(translations.main, 'column_enum_model_type', model_type.text)}}
                                        </option>
                                    </b-select>
                                </b-field>
                            </div>
                        </div>

                        <div class="columns">
                            <div v-if="event_type.id" class="column">
                                <div class="field">
                                    <small>
                                        <span class="has-text-model_type-bold">
                                            {{translations.core.column_created_at}}:
                                        </span>
                                        {{ event_type.created_at }}
                                        <br>
                                        <span class="has-text-model_type-bold">
                                            {{translations.core.column_updated_at}}:
                                        </span>
                                        {{ event_type.updated_at }}
                                    </small>
                                </div>
                            </div>
                            <div class="column has-text-right">
                                <b-field>
                                    <b-button type="is-primary" native-type="submit" :disabled="submitting">
                                        <span v-if="submitting">
                                            <i class="fas fa-circle-notch fa-spin"></i>
                                            &nbsp; {{translations.core.view_btn_saving}}
                                        </span>
                                        <span v-else>
                                            <i class="fas fa-save"></i>
                                            &nbsp; {{translations.core.view_btn_save}}
                                        </span>
                                    </b-button>
                                </b-field>
                            </div>
                        </div>
                    </form>
                </b-tab-item>
                <b-tab-item :label="translations.core.view_tab_title_delete_record" v-if="event_type.id">
                    <span class="has-text-danger">
                        {{translations.main.view_text_delete_confirmation}}
                    </span>
                    <br>
                    <br>
                    <b-field v-if="event_type.id">
                        <b-button type="is-danger" @click="deleteEventType" expanded class="submit-button" :disabled="deleting">
                            <span v-if="deleting">
                                <i class="fas fa-spin fa-circle-notch"></i> {{translations.core.view_btn_deleting}}
                            </span>
                            <span v-else>
                                <i class="fas fa-trash-alt"></i> {{translations.core.view_btn_delete}}
                            </span>
                        </b-button>
                    </b-field>
                </b-tab-item>
            </b-tabs>
        </div>
    </div>
</template>
