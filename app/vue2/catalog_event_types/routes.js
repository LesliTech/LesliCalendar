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

// · Import main app from core
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
import app from 'LesliVue/app'


// · Import common apps
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
import eventTypesList  from './apps/list.vue'
import eventTypesEdit  from './apps/edit.vue'
import eventTypesNew   from './apps/new.vue'

const routes = [
    {
        path: '/catalog/event_types',
        component: eventTypesList
    },{
        path: '/catalog/event_types/new',
        component: eventTypesNew
    },{
        path: '/catalog/event_types/:id',
        component: eventTypesEdit
    }
]

export default routes
