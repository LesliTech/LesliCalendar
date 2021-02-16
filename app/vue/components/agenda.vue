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


// · Import framework libraries and tools
import dayjs from "dayjs"



// · 
export default {
    props: {
        driverEvents: {
            default() {
                return []
            }
        },
        focusTasks: {
            default() {
                return []
            }
        }
    },
    data() {
        return {
            events: [{
                id: 0,
                title: "My task planned for today",
                category: "",
                datetime: "today"
            },{
                id: 1,
                title: "My task",
                category: "",
                datetime: "tomorrow - 7 PM"
            }],
            translations: {
                core: I18n.t('deutscheleibrenten.shared')
            }
        }
    }
}
</script>
<template>
    <div>
        <div class="mb-5" v-for="event in events" :key="event.id">
            <div class="media">
                <div class="media-left">
                    <span class="icon is-medium">
                        <i class="far fa-lg fa-calendar-alt"></i>
                    </span>
                </div>
                <div class="media-content">
                    <div class="content">
                        <p class="is-size-5 mb-0">{{ event.title }}</p>
                        <p class="has-text-grey">{{ event.datetime }}</p>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>
