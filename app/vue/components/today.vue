<script>
import dayjs from "dayjs"

export default {
    props: {
        todayEvents: {
            default() {
                return []
            },
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
                let start = new Date(event.start) 
                if (this.isToday(start)) {
                    this.events.push({
                        id: event.id,
                        title: event.title,
                        start: start
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
                    {{ ('0' + event.start.getHours()).slice(-2) }}:{{ ('0' + event.start.getMinutes()).slice(-2) }}
                </b>
                {{ event.title }}
            </a>
        </article>
    </section>
</template>
