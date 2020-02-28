<script>
import dayjs from "dayjs"

export default {
    props: {
        todayEvents: {
            default: [],
            required: true
        }
    },
    data() {
        return {
            today: new Date(),
            events: []
        }
    },
    mounted() {
        this.validateEvents()
    },
    methods: {
        isToday(date) {
            return (
                date.getDate() == this.today.getDate() &&
                date.getMonth() == this.today.getMonth() &&
                date.getFullYear() == this.today.getFullYear()
            )
        },
        validateEvents() {
            this.todayEvents.forEach(event => {
                let time_start = new Date(event.time_start) 
                if (this.isToday(time_start)) {
                    this.events.push({
                        id: event.id,
                        title: event.title,
                        time_start: time_start
                    })
                }
            })
        }
    },
    watch: {
        todayEvents() {
            this.validateEvents()
        }
    }
}
</script>
<template>
    <section class="component-driver-calendar-today">
        <article class="panel">
            <p class="panel-heading">
                Today
            </p>
            <a class="panel-block" v-for="event in events" :key="event.id">
                <b>
                    {{ ('0' + event.time_start.getHours()).slice(-2) }}:{{ ('0' + event.time_start.getMinutes()).slice(-2) }}
                </b>
                {{ event.title }}
            </a>
        </article>
    </section>
</template>
