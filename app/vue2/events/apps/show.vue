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

import componentAttendants from "../../components/attendants.vue"

// · 
export default {
    components: {
        "component-attendants": componentAttendants
    },
    data() {
        return {
            id: null,
            event: {detail_attributes:{}},
            tab: 0,
            translations: {
                events: I18n.t('driver.events'),
                core: I18n.t('core.shared')
            }
        }
    },
    mounted() {
        this.id = this.$route.params.id
        this.getEvent()
    },
    methods: {

        getEvent() {

            let url = this.url.driver("events/:id", this.id)

            this.http.get(url).then(result => {

                if (!result.successful) {
                    return this.msg.error(result.error.message)
                }

                this.event = result.data;

                this.event.detail_attributes.event_date = this.date.toStringFull(new Date(this.event.detail_attributes.event_date));
                this.event.detail_attributes.time_start = this.date.toStringTime(new Date(this.event.detail_attributes.time_start));
                this.event.detail_attributes.time_end = this.date.toStringTime(new Date(this.event.detail_attributes.time_end));

            }).catch(error => {
                console.log(error)
            })

        },

        confirmAttendance() {

            let url = this.url.driver("events/:id/attendants/:current_user", {
                id: this.id,
                current_user: this.lesli.current_user.id
            })

            this.http.put(url, {
                confirmed_at: new Date()
            }).then(result => {
                console.log(result)
            }).catch(error => {
                console.log(error)
            })

        }

    }
}
</script>
<template>
    <section class="application-component">
        <component-header :title="event.detail_attributes.title"></component-header>

        <b-tabs expanded v-if="id" v-model="tab">
            <b-tab-item :label="translations.core.view_tab_title_general_information">
                <div class="box" v-if="event.detail_attributes">
                    <p class="mb-2">
                        {{ event.detail_attributes.event_date }} &bull; 
                        {{ event.detail_attributes.time_start }} - 
                        {{ event.detail_attributes.time_end }} 
                    </p>
                    <p>{{ event.detail_attributes.description }}</p>
                </div>
            </b-tab-item>
            <b-tab-item :label="translations.events.view_tab_title_attendants">
                <component-attendants :event-id="id" :event-editable="false"></component-attendants>
            </b-tab-item>
        </b-tabs> 


        
        <div class="box">
            <div class="buttons">
                <button class="button" @click="confirmAttendance()">
                    Confirm attendance
                </button>
            </div>
        </div>
    </section>
</template>
