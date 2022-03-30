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

// · Import main app from core
import app from "LesliVue/app2"


// · Import common apps
import appDashboardShow  from "./dashboards/apps/show.vue"
import appEventShow from "./events/apps/show.vue"


// · 
app("CloudDriver", "/driver", "[dashboard]", [{
    path: "/",
    component: appDashboardShow
}, {
    path: "/events/:id",
    component: appEventShow
}], {
    event: {
        show: false,
        id: null,
        details: {}
    },
    calendar: {
        title: '',
        selected_date: null
    },
    agenda_day: new Date()
})
