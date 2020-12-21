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
        return {}
    },

    // @return [void]
    // @description Executes the necessary functions needed to initialize this component
    mounted(){
    },

    methods: {
    }
}
</script>
<template>
    <section class="application-component">
        <component-header title="New Event">
            <div class="is-grouped">
                <router-link class="button" to="/">
                    <span class="icon">
                        <i class="fas fa-undo"></i>
                    </span>
                    <span>Return</span>
                </router-link>
            </div>
        </component-header>
        <component-form view-type="new" />
    </section>
</template>
