<script>
/*
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
*/
import DatePicker from 'v-calendar/lib/components/date-picker.umd'

export default {
    components: {
        'vc-date-picker': DatePicker,
    },

    props: {
        eventId: {
            required: true
        },
        eventEditable: {
            type: Boolean,
            default: true
        },
        engineEndpoint: {
            type: String,
            default: "driver"
        },
        customTableClass: {
            type: String,
            default: ''
        }
    },

    data() {
        return {
            main_route: `/${this.engineEndpoint}/events`,
            loading: {
                proposal_submit: false,
                proposals: false,
            },
            loaded: {
                proposals: false,
            },
            translations: {
                core: {
                    shared: I18n.t('core.shared')
                },
                driver: {
                    events: I18n.t('driver.events'),
                }
            },
            proposal: {},
            proposals: []
        }
    },

    mounted() {
        this.getProposals()
    },

    methods: {
        getProposals() {
            // const url = `${this.main_route}/${this.eventId}/proposals.json`
            // this.loading.proposals = true

            // this.http.get(url).then(result => {
            //     this.loading.proposals = false
            //     if (result.successful) {
            //         this.proposals = result.data
            //         this.loaded.proposals = true
            //         this.syncLists()
            //     }else{
            //         this.msg.error(result.error.message)
            //     }
            // }).catch(error => {
            //     console.log(error)
            // })
        },

        postProposal() {
            this.proposal_submit = true
            const url = this.url.driver("events/:event_id/proposals", { event_id: this.eventId })

            const data = {
                event_proposal: this.proposal
            }

            this.http.post(url, data).then(result => {
                if (result.successful) {
                    this.msg.success(this.translations.driver.events.messages_success_proposal_created)
                } else {
                    this.msg.error(result.error.message)
                }
            }).catch(error => {
                console.log(error)
            }).finally(() => {
                this.proposal_submit = false
                this.getProposals()
            })
        },

    },

    computed: {},

    watch: {
        eventId() {
            this.loaded.proposals = false
            this.getProposals()
        },
    }
}
</script>
<template>
    <div>
        <h5 class="title is-5">
            {{ "Proposals" }}
        </h5>
        <b-tabs expanded>
            <!-- Create proposal -->
            <b-tab-item label="Proposals">
                <form v-on:submit.prevent="postProposal">
                    <fieldset>
                        <div class="columns">
                            <div class="column is-5">
                                <b-field>
                                    <template v-slot:label>
                                        {{ translations.driver.events.column_event_date }}
                                        <sup class="has-text-danger">*</sup>
                                    </template>
                                    <vc-date-picker
                                        v-model="proposal.event_date"
                                        :locale="date.vcDatepickerConfig()"
                                        :popover="{ visibility: 'focus' }"
                                    >
                                        <template v-slot="{ inputValue, inputEvents }">
                                            <input
                                                name="event_date"
                                                class="input is-default"
                                                v-on="inputEvents"
                                                :value="inputValue"
                                                :placeholder="translations.core.shared.view_placeholder_select_date"
                                                required
                                            />
                                        </template>
                                    </vc-date-picker>
                                </b-field>
                            </div>
                            <div class="column is-3">
                                <b-field :label="translations.driver.events.column_time_start">
                                    <b-timepicker
                                        name="time_start"
                                        :placeholder="translations.core.shared.view_placeholder_select_date"
                                        icon="clock"
                                        :default-minutes="0"
                                        v-model="proposal.time_start">
                                    </b-timepicker>
                                </b-field>
                            </div>
                            <div class="column is-3">
                                <b-field :label="translations.driver.events.column_time_end">
                                    <b-timepicker
                                        name="time_end"
                                        :placeholder="translations.core.shared.view_placeholder_select_date"
                                        icon="clock"
                                        :default-minutes="0"
                                        v-model="proposal.time_end">
                                    </b-timepicker>
                                </b-field>
                            </div>
                        </div>
                        <div class="field is-grouped">
                            <div class="control">
                                <button class="button is-primary">
                                    <span v-if="loading.proposal_submit">
                                        <b-icon icon="circle-notch" custom-class="fa-spin"></b-icon>
                                        <span>{{ translations.core.shared.view_btn_saving }}</span>
                                    </span>
                                    <span v-else>
                                        <b-icon icon="save"></b-icon>
                                        <span>{{ translations.core.shared.view_btn_save }}</span>
                                    </span>
                                </button>
                            </div>
                        </div>
                    </fieldset>
                </form>
            </b-tab-item>
            <b-tab-item :label="translations.driver.events.view_tab_title_proposals_list">
                <!-- <component-data-loading v-if="loading.proposals" />
                <component-data-empty v-if="!loading.proposals && proposals.length == 0" />
                <b-table v-if="!loading.proposals && proposals.length > 0" :data="proposals" narrowed :class="customTableClass">
                    <template slot-scope="props">
                        <b-table-column field="name" :label="translations.core.shared.view_text_name">
                            <small>{{ props.row.name }}</small>
                        </b-table-column>
                        <b-table-column field="email" :label="translations.core.shared.view_text_email">
                            <small>{{ props.row.email }}</small>
                        </b-table-column>
                        <b-table-column field="confirmed_at" :label="translations.driver.events.column_confirmed_at" :centered="true">
                            <button
                                :class="['button', 'is-small', {'is-success': props.row.confirmed_at_string}]"
                                :disabled="props.row.submitting || props.row.deleting || (!!props.row.confirmed_at_string)"
                                @click="confirmAttendance(props.row)"
                            >
                                <b-icon v-if="props.row.submitting" icon="circle-notch" custom-class="fa-spin"></b-icon>
                                <span>
                                    {{ props.row.confirmed_at_string || translations.driver.events.view_text_click_to_confirm }}
                                </span>
                            </button>
                        </b-table-column>
                        <b-table-column field="actions" class="has-text-centered">
                            <a
                                role="button"
                                class="delete is-pulled-right"
                                v-if="eventEditable"
                                @click="deleteInvite(props.row)">
                            </a>
                        </b-table-column>
                    </template>
                </b-table> -->
            </b-tab-item>
        </b-tabs>
    </div>
</template>
