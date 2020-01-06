<script>
export default {
    
}
</script>
<template>
    <section>
        <div class="box">
            <div class="field">
                <b-checkbox :value="true">
                    Calendar #1
                </b-checkbox>
            </div>
            <div class="field">
                <b-checkbox :value="true" type="is-info">
                    Calendar #2
                </b-checkbox>
            </div>
            <div class="field">
                <b-checkbox :value="true" type="is-success">
                    Calendar #3
                </b-checkbox>
            </div>
            <div class="field">
                <b-checkbox :value="true" type="is-danger">
                    Calendar #4
                </b-checkbox>
            </div>
            <div class="field">
                <b-checkbox :value="true" type="is-warning">
                    Calendar #5
                </b-checkbox>
            </div>
        </div>
    </section>
</template>
