<script>
export default {
    data() {
        return {
            show: !false,
            event: {
                detail_attributes: {
                    title: null,
                    description: "",
                    time_start: "",
                    time_end: "",
                    location: "",
                    url: ""
                }
            }
        }
    },
    methods: {
        toggleView() {
            this.show = !this.show
        },
        postEvent(e) {
            if (e) { e.preventDefault() }
            console.log(JSON.stringify(this.event))
            this.http.post("/driver/events", {event: this.event}).then(result => {
                this.alert("Event succesfully created")
            }).catch(error => {
                console.log(error)
            })
        }
    }

}
</script>
<template>
    <div :class="[{ 'is-active': show }, 'quickview', 'is-size-large']">
        <header class="quickview-header">
            <h4 class="title">{{ (this.event.detail_attributes.title ? this.event.detail_attributes.title : 'Create new event') }}</h4>
            <span class="delete" @click="show = false"></span>
        </header>
        <div class="quickview-body">
            <b-tabs>
                <b-tab-item label="Information">
                    <form @submit.prevent="postEvent()">
                        <div class="field">
                            <label class="label">Name</label>
                                <div class="control">
                                <input class="input" type="text" v-model="event.detail_attributes.title" placeholder="Title">
                            </div>
                        </div>
                        <div class="field">
                            <label class="label">Description</label>
                                <div class="control">
                                <textarea class="textarea" v-model="event.detail_attributes.description"></textarea>
                            </div>
                        </div>
                        <div class="field">
                            <label class="label">Address</label>
                                <div class="control">
                                <input class="input" type="text" v-model="event.detail_attributes.location" placeholder="Address">
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
                                icon="clock"
                                v-model="event.detail_attributes.time_start">
                            </b-timepicker>
                        </b-field>
                        <b-field label="End at">
                            <b-timepicker
                                placeholder="Select time"
                                icon="clock"
                                v-model="event.detail_attributes.time_end">
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
