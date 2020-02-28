<script>
export default {
    
}
</script>
<template>
    <section class="component-driver-calendar-today">
        <article class="panel">
            <p class="panel-heading">
                Today
            </p>
            <a class="panel-block" v-for="(event, index) in [0,0,0,0,0,0,0,0,0]" :key="index">
                <b>{{ index + 8}}:00</b>
                Besuch Kooperationspartner
            </a>
        </article>
    </section>
</template>
