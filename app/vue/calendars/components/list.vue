<script>
export default {
    
}
</script>
<template>
    <section>
        <div class="box">
            <div class="field" v-for="calendar in [0,0]" :key ="calendar">
                <b-checkbox>Basic</b-checkbox>
            </div>
            <div class="field">
                <b-checkbox :value="true">
                    Default
                </b-checkbox>
            </div>
            <div class="field">
                <b-checkbox :value="true"
                type="is-info">
                    Info
                </b-checkbox>
            </div>
            <div class="field">
                <b-checkbox :value="true"
                type="is-success">
                    Success
                </b-checkbox>
            </div>
            <div class="field">
                <b-checkbox :value="true"
                type="is-danger">
                    Danger
                </b-checkbox>
            </div>
            <div class="field">
                <b-checkbox :value="true"
                type="is-warning">
                    Warning
                </b-checkbox>
            </div>
        </div>
    </section>
</template>
