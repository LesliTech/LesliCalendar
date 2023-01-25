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

<style lang='css'>
/* overwrited styles provied by FullCalendar lib */

/* used for event dates/times */
div.box b {
    margin-right: 3px;
}

/* used for events on dates */
div.fc-event-main b,
div.fc-event-main i {
    color: black;
}

/* used for headerToolbar buttons */
.fc-prev-button.fc-button.fc-button-primary,
.fc-next-button.fc-button.fc-button-primary,
.fc-today-button.fc-button.fc-button-primary,
.fc-dayGridMonth-button.fc-button.fc-button-primary,
.fc-timeGridWeek-button.fc-button.fc-button-primary,
.fc-timeGridDay-button.fc-button.fc-button-primary {
    background-color: white;
    border-color: #dbdbdb;
    border-width: 1px;
    color: #363636;
    cursor: pointer;
    justify-content: center;
    padding-bottom: calc(0.5em - 1px);
    padding-left: 1em;
    padding-right: 1em;
    padding-top: calc(0.5em - 1px);
    text-align: center;
    white-space: nowrap;
}

.fc-prev-button.fc-button.fc-button-primary:focus:not(:active),
.fc-next-button.fc-button.fc-button-primary:focus:not(:active),
.fc-today-button.fc-button.fc-button-primary:focus:not(:active),
.fc-dayGridMonth-button.fc-button.fc-button-primary:focus:not(:active),
.fc-timeGridWeek-button.fc-button.fc-button-primary:focus:not(:active),
.fc-timeGridDay-button.fc-button.fc-button-primary:focus:not(:active) {
    box-shadow: none;
    background-color: white;
}

.fc-prev-button.fc-button.fc-button-primary:focus,
.fc-next-button.fc-button.fc-button-primary:focus,
.fc-today-button.fc-button.fc-button-primary:focus,
.fc-dayGridMonth-button.fc-button.fc-button-primary:focus,
.fc-timeGridWeek-button.fc-button.fc-button-primary:focus,
.fc-timeGridDay-button.fc-button.fc-button-primary:focus {
    border-color: #dbdbdb;
    color: #363636;
    background-color: var(--lesli-color-primary);
}

.fc-prev-button.fc-button.fc-button-primary:not(:disabled):hover,
.fc-next-button.fc-button.fc-button-primary:not(:disabled):hover,
.fc-today-button.fc-button.fc-button-primary:not(:disabled):hover,
.fc-dayGridMonth-button.fc-button.fc-button-primary:not(:disabled):hover,
.fc-timeGridWeek-button.fc-button.fc-button-primary:not(:disabled):hover,
.fc-timeGridDay-button.fc-button.fc-button-primary:not(:disabled):hover {
    border-color: var(--lesli-color-primary);
    color: var(--lesli-color-primary);
    background-color: white;
}

.fc-prev-button.fc-button.fc-button-primary:not(:disabled):active:focus,
.fc-next-button.fc-button.fc-button-primary:not(:disabled):active:focus,
.fc-today-button.fc-button.fc-button-primary:not(:disabled):active:focus,
.fc-dayGridMonth-button.fc-button.fc-button-primary:not(:disabled):active:focus,
.fc-timeGridWeek-button.fc-button.fc-button-primary:not(:disabled):active:focus,
.fc-timeGridDay-button.fc-button.fc-button-primary:not(:disabled):active:focus {
    border-color: white;
    color: white;
    background-color: var(--lesli-color-primary);
    box-shadow: none;
}

.fc-dayGridMonth-button.fc-button.fc-button-primary.fc-button-active:focus:not(:active),
.fc-timeGridWeek-button.fc-button.fc-button-primary.fc-button-active:focus:not(:active),
.fc-timeGridDay-button.fc-button.fc-button-primary.fc-button-active:focus:not(:active),
.fc-dayGridMonth-button.fc-button.fc-button-primary.fc-button-active:focus:not(:active),
.fc-timeGridWeek-button.fc-button.fc-button-primary.fc-button-active:focus:not(:active),
.fc-timeGridDay-button.fc-button.fc-button-primary.fc-button-active:focus:not(:active) {
    border-color: var(--lesli-color-primary);
    color: var(--lesli-color-primary);
    box-shadow: none;
}

.fc-dayGridMonth-button.fc-button.fc-button-active.fc-button-primary:not(:disabled),
.fc-timeGridWeek-button.fc-button.fc-button-active.fc-button-primary:not(:disabled),
.fc-timeGridDay-button.fc-button.fc-button-active.fc-button-primary:not(:disabled) {
    background-color: white;
    border-color: var(--lesli-color-primary);
    color: var(--lesli-color-primary);
}
</style>