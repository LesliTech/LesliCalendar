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
    }
}
</script>
<template>
    <component-sidebar-view :open.sync="data.event.show" size="large">
        <h1>hola</h1>
    </component-sidebar-view>
</template>
