<script>
/*
Lesli

Copyright (c) 2020, Lesli Technologies, S. A.

All the information provided by this website is protected by laws of Guatemala related 
to industrial property, intellectual property, copyright and relative international laws. 
Lesli Technologies, S. A. is the exclusive owner of all intellectual or industrial property
rights of the code, texts, trade mark, design, pictures and any other information.
Without the written permission of Lesli Technologies, S. A., any replication, modification,
transmission, publication is strictly forbidden.
For more information read the license file including with this software.

LesliCloud - Your Smart Business Assistant

Powered by https://www.lesli.tech
Building a better future, one line of code at a time.

@license  Propietary - all rights reserved.
@version  0.1.0-alpha

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
