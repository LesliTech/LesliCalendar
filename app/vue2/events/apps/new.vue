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
import componentForm from '../components/form.vue'


// · 
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~


export default {
    props: {
    },

    components: {
        'component-form': componentForm
    },

    // @return [Object] Data used by this component's methods
    // @description Returns the data needed for this component to work properly
    // @data_variable event [Object] An object representing a Event, with
    //      the same params as the associated rails model
    data(){
        return {
            event: null,
            translations: {
                main: I18n.t('driver.events'),
                core: I18n.t('core.shared')
            }
        }
    },

    // @return [void]
    // @description Executes the necessary functions needed to initialize this component
    mounted(){
        this.initializeEvent()
    },

    methods: {
        initializeEvent(){
            let event_data =  {
                detail_attributes: {
                    title: '',
                    description: '',
                    event_date: new Date(),
                    time_start: new Date(),
                    time_end: new Date(),
                    event_type: null,
                    public: false,
                },
                organizer_name: '',
                editable: true,
            }

            event_data.detail_attributes.time_start.setHours(12)
            event_data.detail_attributes.time_start.setMinutes(0)

            event_data.detail_attributes.time_end.setHours(13)
            event_data.detail_attributes.time_end.setMinutes(0)
            
            this.data.event = event_data
            this.event = this.data.event
        }
    }
}
</script>
<template>
    <section class="application-component">
        <component-header :title="translations.main.view_title_new" >
            <div class="navbar-item">
                <div class="buttons">
                    <router-link class="button" to="/">
                        <b-icon icon="list" size="is-small" />
                        <span>{{ translations.core.view_btn_list }}</span>
                    </router-link>
                </div>
            </div>
        </component-header>
        <component-form v-if="event" view-type="new">
        </component-form>
    </section>
</template>
