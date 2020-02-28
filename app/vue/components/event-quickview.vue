<script>
export default {
    data() {
        return {
            show: false
        }
    },
    methods: {
        toggleView() {
            this.show = !this.show
            console.log(this.show)
        }
    }

}
</script>
<template>
    <div :class="[{ 'is-active': show }, 'quickview', 'is-size-large']">
        <header class="quickview-header">
            <h4 class="title">Create new event</h4>
            <span class="delete" @click="show = false"></span>
        </header>
        <div class="quickview-body">
            <b-tabs>
                <b-tab-item label="Information">
                    <form action="">
                        <div class="field">
                            <label class="label">Name</label>
                                <div class="control">
                                <input class="input" type="text" placeholder="Text input">
                            </div>
                        </div>
                        <div class="field">
                            <label class="label">Description</label>
                                <div class="control">
                                <textarea class="textarea"></textarea>
                            </div>
                        </div>
                        <div class="field">
                            <label class="label">Address</label>
                                <div class="control">
                                <input class="input" type="text" placeholder="Text input">
                            </div>
                        </div>
                        <div class="field">
                            <label class="checkbox">
                                <input type="checkbox">
                                Mark to make this event public
                            </label>
                        </div>
                        <b-field label="Start at">
                            <b-timepicker
                                placeholder="Select time"
                                icon="clock">
                            </b-timepicker>
                        </b-field>
                        <b-field label="End at">
                            <b-timepicker
                                placeholder="Select time"
                                icon="clock">
                            </b-timepicker>
                        </b-field>
                        <div class="buttons">
                            <button class="button is-primary">
                                <span class="icon">
                                    <i class="far fa-save"></i>
                                </span>
                                <span>Save</span>
                            </button>
                        </div>
                    </form>
                </b-tab-item>
                <b-tab-item label="Employees">
                </b-tab-item>
                <b-tab-item label="Comments">
                </b-tab-item>
                <b-tab-item label="Files">
                </b-tab-item>
            </b-tabs>

            <div class="quickview-block">
                
            </div>
        </div>
        <footer class="quickview-footer">

        </footer>
    </div>
</template>
