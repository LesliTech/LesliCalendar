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
import eventComponent from '../components/event.vue'


// · 
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~


export default {  
    components: {
        'component-form': componentForm,
        'event-component': eventComponent
    },
}
</script>
<template>
    <section class="application-component">
        <component-header title="Edit Event">
            <div class="is-grouped">
                <router-link class="button" :to="`/${this.$route.params.id}/edit`">
                    <span class="icon">
                        <i class="fas fa-eye"></i>
                    </span>
                    <span>Edit Event</span>
                </router-link>
                <router-link class="button" to="/">
                    <span class="icon">
                        <i class="fas fa-undo"></i>
                    </span>
                    <span>Return</span>
                </router-link>
            </div>
        </component-header>
        <event-component :event-id="this.$route.params.id"></event-component>
    </section>
</template>
