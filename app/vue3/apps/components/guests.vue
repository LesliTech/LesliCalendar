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
import { useGuests } from 'CloudDriver/stores/guests'
import { useCalendar } from 'CloudDriver/stores/calendar'

// · implement stores
const storeGuests = useGuests()
const storeCalendar = useCalendar()

onMounted(() => {
    storeGuests.getAttendants()
    storeGuests.getUsers()
})

const translations = {
    main: I18n.t('driver.events'),
    core: I18n.t('core.shared'),
    core_users: I18n.t('core.users'),
    users: I18n.t('deutscheleibrenten.users'),
    attendants: I18n.t('driver.event/attendants')
}

function submitGuest(user) {
    user.checked = !user.checked;
    if (user.checked) storeGuests.postAttendant(user)
    else storeGuests.deleteInvite(user)
}

function confirmedInvitesCount() {
    return storeGuests.attendants.filter(attendant => attendant.confirmed_at_string).length
}

function totalInvitesCount() {
    return storeGuests.attendants.length
}

function searchUser(text) {
    console.log('text:', text)
}

// :checked="storeGuests.attendants.findIndex(attendant => attendant.users_id === record.id) !== -1"
</script>

<template>
    <h5 class="title is-5">
        {{ storeGuests.translations.attendants.view_title_confirmed_invites_count }}: {{ confirmedInvitesCount() }} /
        {{ storeGuests.translations.attendants.view_title_total_invites_count }}: {{ totalInvitesCount() }}
    </h5>
    <lesli-tabs v-model="tab">

        <lesli-tab-item :title="storeGuests.translations.main.view_tab_title_users" icon="add">
            <lesli-toolbar @search="searchUser"></lesli-toolbar>
            <lesli-table
                :columns="[{ field: 'name', label: 'translations.core.view_text_name' }, { field: 'email', label: 'translations.core.view_text_email' }, { field: 'actions', label: '' }]"
                :records="storeGuests.attendant_options.users">
                <template #head(actions)="{ column }">
                </template>
                <template #actions="{ record }">
                    <input type="checkbox" v-model="record.checked" @input="submitGuest(record)"
                    :checked="storeGuests.attendant_options.users.checked"
                    
                    >
                </template>
            </lesli-table>
        </lesli-tab-item>

        <lesli-tab-item :title="storeGuests.translations.main.view_tab_title_guests" icon="info">
        </lesli-tab-item>

        <lesli-tab-item :title="storeGuests.translations.main.view_tab_title_attendants_list" icon="info">
        </lesli-tab-item>

    </lesli-tabs>
</template>