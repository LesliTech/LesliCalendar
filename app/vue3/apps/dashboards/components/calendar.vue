<script setup>

/*
Copyright (c) 2023, all rights reserved.

All the information provided by this platform is protected by international laws related  to 
industrial property, intellectual property, copyright and relative international laws. 
All intellectual or industrial property rights of the code, texts, trade mark, design, 
pictures and any other information belongs to the owner of this platform.

Without the written permission of the owner, any replication, modification,
transmission, publication is strictly forbidden.

For more information read the license file including with this software.

// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
*/

// · Import components, libraries and tools
import { onMounted } from "vue"

// · import lesli stores
import { useCalendar } from 'CloudDriver/stores/dashboard/calendar'
import { useShow } from 'CloudDriver/stores/dashboard/show'

// · implement stores
const storeCalendar = useCalendar()
const storeShow = useShow()

// · 
onMounted(() => {
    setTimeout(function () {
        storeCalendar.initCalendar();
    }, 1);
    storeCalendar.currentEvents = JSON.parse(localStorage.getItem("currentEvents"))
})

</script>

<template>
    <div id="driver_calendar"></div>
</template>