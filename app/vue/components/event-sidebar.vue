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


import componentSidebarView from "LesliVue/components/views/sidebar-view.vue"


export default {
    components: {
        "component-sidebar-view": componentSidebarView
    },

    methods: {
        getDate(date){
            let start_date = date
            if( typeof(start_date) === 'string') {
                start_date = new Date(date)
            }
            return start_date;
        }
    },
    computed: {
        start() {
            return this.date.toString(this.getDate(this.data.event.details.start))
        },
        time() {
            return this.date.toStringTime(this.getDate(this.data.event.details.start))
        }
    }
}
</script>
<template>
    <component-sidebar-view :open.sync="data.event.show" size="large">
            <div class="content p-5" v-if="data.event.details">
                <h1> {{ data.event.details.title}} </h1>
                <div>
                    <span class="icon-text">
                        <span class="icon">
                            <i class="fas fa-calendar-day"></i>
                        </span>
                        <span>{{ start }}</span>
                    </span>
                    <br>
                    <span class="icon-text">
                        <span class="icon">
                            <i class="fas fa-clock"></i>
                        </span>
                        <span>{{ time }}</span>
                    </span>
                </div>
                <div class="mt-3">
                    <p>
                        {{ data.event.details.description }}
                    </p>
                </div>
            </div>
    </component-sidebar-view>
</template>
