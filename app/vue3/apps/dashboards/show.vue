<script setup>
/*
Copyright (c) 2022, all rights reserved.

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
import componentAgenda from './components/agenda.vue'
import componentPanelEvent from './components/panel-event.vue'

// · import lesli stores
import { useShow } from 'CloudDriver/stores/dashboard/show'
import { useCalendar } from 'CloudDriver/stores/dashboard/calendar'
import { usePanelEvent } from 'CloudDriver/stores/dashboard/panel-event'

// · initialize/inject plugins
const router = useRouter()
const msg = inject("msg")
const url = inject("url")

// · implement stores
const storeShow = useShow()
const storeCalendar = useCalendar()
const storePanelEvent = usePanelEvent()

onMounted(() => {
})

</script>

<template>
    <section class="application-component">

        <lesli-header :title="storeShow.setTitle()">
            <div class="navbar-item">
                <div class="buttons">
                    <button class="button"><span class="icon"><i class="fab fa-google"></i></span></button>
                    <button class="button" @click="togleModal"><span class="icon"><i class="fas fa-plus"></i></span></button>
                </div>
            </div>
        </lesli-header>

        <lesli-toolbar @search="a"></lesli-toolbar>

        <div class="columns">
            <div class="column is-one-quarter">
                <div class="box">
                    <componentAgenda />
                </div>
            </div>
            <div class="column">
                <div class="box">
                    <componentCalendar />
                </div>
            </div>
        </div>

    </section>
</template>