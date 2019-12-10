<script>
export default {
    
}
</script>
<template>
    <section>
        <div class="list is-hoverable">
            <a class="list-item" v-for="calendar in [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14]" :key ="calendar">
                calendar #{{ calendar + 1 }}
            </a>
        </div>
    </section>
</template>
