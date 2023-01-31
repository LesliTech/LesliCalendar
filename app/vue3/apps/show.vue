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
// · 
*/


// · import vue tools
import { ref, reactive, onMounted, watch, computed, inject } from "vue"
import { useRouter, useRoute } from 'vue-router'

// · Import components
import componentCalendar from './components/calendar.vue'
import componentEvent from './components/event.vue'

// · import lesli stores
import { useShow } from 'CloudDriver/stores/show'
import { useCalendar } from 'CloudDriver/stores/calendar'
import { useEvent } from 'CloudDriver/stores/event'
// import { useGuests } from 'CloudDriver/stores/guests'

// · initialize/inject plugins
const router = useRouter()
const msg = inject("msg")
const url = inject("url")

// · implement stores
const storeShow = useShow()
const storeCalendar = useCalendar()
const storeEvent = useEvent()
// const storeGuests = useGuests()

const newEvent = () => {
    storeCalendar.reset()
    storeEvent.showModal = !storeEvent.showModal
}

onMounted(() => {
})


</script>

<template>
    <section class="application-component">
        <lesli-header :title="storeShow.setTitle()">
            <div class="navbar-item">
                <div class="buttons">
                    <button class="button"><span class="icon"><i class="fab fa-google"></i></span></button>
                    <button class="button" @click="newEvent()"><span class="icon"><i
                                class="fas fa-plus"></i></span></button>
                </div>
            </div>
        </lesli-header>
        <lesli-toolbar @search="a"></lesli-toolbar>
        <div class="columns">
            <div class="column">
                <div class="box">
                    <componentCalendar />
                </div>
            </div>
        </div>
        <componentEvent />
    </section>
</template>