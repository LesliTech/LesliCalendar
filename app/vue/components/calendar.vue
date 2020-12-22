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


//  · Loading core framework and libraries
// ~·~        ~·~        ~·~        ~·~        ~·~        ~·~        ~·~        ~·~        ~·~
import dayjs from 'dayjs'
import { Calendar, setupCalendar } from 'v-calendar'


//  · Initializing 
// ~·~        ~·~        ~·~        ~·~        ~·~        ~·~        ~·~        ~·~        ~·~
setupCalendar({
    componentPrefix: 'vc'
})



// · LesliCloud app
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
export default {
    components: {
        'v-calendar': Calendar
    },
    data() {
        return {
            attributes: [{
                key: 'today',
                dates: new Date(),
                highlight: 'red'
            }, {
                highlight: true,
                dates: [{ 
                    start: dayjs().add(1, 'day').format(), 
                    end: dayjs().add(5, 'day').format() 
                }]
            }, {
                dot: 'red',
                dates: [
                    dayjs().add(7, 'day').format()
                ]
            }, {
                dot: 'blue',
                dates: [
                    dayjs().add(8, 'day').format()
                ]
            }, {
                bar: 'green',
                dates: [
                    dayjs().add(10, 'day').format(),
                    dayjs().add(11, 'day').format(),
                    dayjs().add(12, 'day').format()
                ]
            }]
        }
    }
}
</script>
<template>
    <v-calendar :attributes="attributes" color="blue" is-expanded></v-calendar>
</template>
<style scoped>
    .vc-container {
        border-radius: 2px;
    }
</style>
