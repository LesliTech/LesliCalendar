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
export default {
    
    data() {
        return {
            calendars: [],
        }
    },
    mounted() {
        this.getCalendars()
    },
    methods: {

        getCalendars() {
            this.http.get("/driver/calendars.json").then(result => {
                this.calendars = result.data
            }).catch(error => {
                console.log(error)
            })
        }

    }
}
</script>
<template>
    <section>
        <div class="box">
            <div class="field" v-for="calendar in calendars" :key="calendar.id">
                {{ calendar.name }}
            </div>
        </div>
    </section>
</template>
