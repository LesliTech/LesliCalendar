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

    data(){
        return {
            event_type: null,
            event_type_id: null,
            translations: {
                main: I18n.t('driver.catalog/event_types'),
                core: I18n.t('core.shared')
            },
            index_abilities: this.abilities.privilege('catalog/event_types', 'cloud_focus')
        }
    },

    mounted(){
        this.setEventTypeId()
        this.getEventType()
    },

    methods: {
        setEventTypeId(){
            this.event_type_id = this.$route.params.id
        },

        getEventType(){
            let url = this.url.driver('catalog/event_types/:event_type_id', {event_type_id: this.event_type_id})
            this.http.get(url).then(result => {
                if (result.successful) {
                    this.event_type = result.data
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
    <section class="application-component">
        <component-header
            :title="translations.main.view_title_main"
        >
            <div class="buttons">
                <router-link class="button" to="/">
                    <b-icon icon="list" size="is-small"></b-icon>
                    <span>{{ translations.core.view_btn_list }}</span>
                </router-link>
            </div>
        </component-header>
        <component-form v-if="event_type" :event_type="event_type"/>
        <component-data-loading v-else size="is-medium" />
    </section>
</template>
