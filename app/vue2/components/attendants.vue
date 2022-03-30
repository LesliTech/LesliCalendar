<script>
export default {
    props: {
        eventId: {
            required: true
        },

        eventEditable: {
            type: Boolean,
            default: true
        },
        engineEndpoint: {
            type: String,
            default: "driver"
        },
        customTableClass: {
            type: String,
            default: ''
        }
    },

    data(){
        return {
            active_tab: 2,
            main_route: `/${this.engineEndpoint}/events`,
            users_route: '/administration/users/list.json?role=kop,callcenter,api,support&type=exclude',
            translations: {
                main: I18n.t('driver.events'),
                core: I18n.t('core.shared'),
                core_users: I18n.t('core.users'),
                users: I18n.t('deutscheleibrenten.users')
            },
            loading: {
                attendants: false,
                options: false
            },
            lists_synched: false,
            loaded: {
                attendants: false,
                attendant_options: false
            },
            search: '',
            pagination: {
                current_page: 1,
                range_before: 3,
                range_after: 3,
                per_page: 10
            },
            attendant_options: {
                users: []
            },
            guest: { name: "", email: "" },
            attendants: [],
            guests: []
        }
    },

    mounted(){
        this.getUsers()
        this.getAttendants()
    },

    methods: {
        getUsers(){
            this.loading.options = true

            this.http.get(this.users_route).then(result => {
                this.loading.options = false
                if (result.successful) {
                    this.$set(this.attendant_options, 'users', result.data)
                    this.loaded.attendant_options = true
                    this.syncLists()
                }else{
                    this.msg.error(result.error.message)
                }
            }).catch(error => {
                console.log(error)
            })
        },

        getAttendants() {
            let url = `${this.main_route}/${this.eventId}/attendants.json`
            this.loading.attendants = true

            this.http.get(url).then(result => {
                this.loading.attendants = false
                if (result.successful) {
                    this.attendants = result.data
                    this.loaded.attendants = true
                    this.syncLists()
                }else{
                    this.msg.error(result.error.message)
                }
            }).catch(error => {
                console.log(error)
            })
        },

        syncLists(){
            if(! this.loaded.attendant_options || ! this.loaded.attendants){
                return
            }

            if(this.lists_synched){
                return
            }

            let users = this.attendant_options.users
            this.attendants.forEach((attendant)=>{
                
                let user = users.find((user)=>{
                    return user.id == attendant.users_id
                })

                this.$set(user, 'attendant_id', attendant.id)
                this.$set(user, 'checked', true)
            })

            this.lists_synched = true

        },

        clearSearch(event){
            if(event){
                event.preventDefault()
            }
            
            this.search = ''
        },

        submitAttendant(user){
            if(user.checked){
                this.postAttendant(user)
            }else{
                this.deleteAttendant(user)
            }
        },

        postAttendant(user){
            let url = `${this.main_route}/${this.eventId}/attendants`
            let data = {
                event_attendant: {
                    users_id: user.id
                }
            }
            this.$set(user, 'submitting', true)

            this.http.post(url, data).then(result => {
                this.$set(user, 'submitting', false)
                if (result.successful) {
                    this.$set(user, 'attendant_id', result.data.id)
                    this.attendants.push({
                        id: result.data.id,
                        name: user.name || user.email,
                        email: user.email,
                        users_id: user.id
                    })
                    this.msg.success(this.translations.main.messages_success_attendant_created)
                }else{
                    this.msg.error(result.error.message)
                }
            }).catch(error => {
                console.log(error)
            })
        },

        deleteAttendant(attendant){
            // If it is clicked from the main tab, the attendant object received will have the id in the 'attendant_id' field
            let attendant_id = attendant.attendant_id
            // However, if it is not clicked from the main tab, the object received will have the id in the 'id' field
            if(! attendant_id){
                attendant_id = attendant.id
            }
            let url = `${this.main_route}/${this.eventId}/attendants/${attendant_id}`
            this.$set(attendant, 'submitting', true)

            this.http.delete(url).then(result => {
                this.$set(attendant, 'submitting', false)
                if (result.successful) {
                    this.msg.success(this.translations.main.messages_success_attendant_deleted)
                    
                    this.attendants = this.attendants.filter((attendant)=>{
                        return attendant.id != attendant_id
                    })

                    let user = this.attendant_options.users.find((user)=>{
                        return user.attendant_id == attendant_id
                    })
                    user.attendant_id = null
                    user.checked = false
                }else{
                    this.msg.error(result.error.message)
                }
            }).catch(error => {
                console.log(error)
            })
        },

        clearOptions(){
            this.attendant_options.users.forEach((user)=>{
                this.$set(user, 'checked', false)
            })
        },


        postGuest() {
            let url = `${this.main_route}/${this.eventId}/guests`

            this.http.post(url, {
                event_guest: this.guest
            }).then(result => {

                if (!result.successful) {
                    return this.msg.error(result.error.message)
                }

                this.attendants.push({
                    id: result.data.id,
                    name: this.guest.name || this.guest.email,
                    email: this.guest.email
                })

                this.guest = {}
                this.msg.success(this.translations.main.messages_success_attendant_created)

            }).catch(error => {
                console.log(error)
            })
        },

        deleteGuest(attendant){
            // If it is clicked from the main tab, the attendant object received will have the id in the 'attendant_id' field
            let attendant_id = attendant.attendant_id
            // However, if it is not clicked from the main tab, the object received will have the id in the 'id' field
            if(! attendant_id){
                attendant_id = attendant.id
            }
            let url = `${this.main_route}/${this.eventId}/attendants/${attendant_id}`
            this.$set(attendant, 'submitting', true)

            this.http.delete(url).then(result => {
                this.$set(attendant, 'submitting', false)
                if (result.successful) {
                    this.msg.success(this.translations.main.messages_success_attendant_deleted)
                    
                    this.attendants = this.attendants.filter((attendant)=>{
                        return attendant.id != attendant_id
                    })

                    let user = this.attendant_options.users.find((user)=>{
                        return user.attendant_id == attendant_id
                    })
                    user.attendant_id = null
                    user.checked = false
                }else{
                    this.msg.error(result.error.message)
                }
            }).catch(error => {
                console.log(error)
            })
        },

    },

    computed: {
        filteredUsers(){
            let search_field = this.search.toLowerCase()
            return this.attendant_options.users.filter((user)=>{
                return user.email.toLowerCase().includes(search_field) ||
                    (
                        user.name &&
                        user.name.toLowerCase().includes(search_field)
                    ) ||
                    (
                        user.role &&
                        user.role.toLowerCase().includes(search_field)
                    )
            })
        },

        currentUserPage(){
            if(this.filteredUsers.length <= this.pagination.per_page){
                return this.filteredUsers
            }else{
                let data = this.filteredUsers.slice(
                    (this.pagination.current_page - 1) * this.pagination.per_page,
                    (this.pagination.current_page) * this.pagination.per_page
                )
                return data
            }
        }
    },

    watch: {
        eventId(){
            this.lists_synched = false
            this.loaded.attendants = false
            this.clearOptions()
            this.getAttendants()
        },

        eventEditable(){
            if(! this.eventEditable){
                this.active_tab = 1
            }
        },

        search(){
            this.pagination.current_page = 1
        }
    }
}
</script>
<template>
    <b-tabs expanded v-model="active_tab">
        <b-tab-item :label="translations.main.view_tab_title_users" :visible="eventEditable">
            <b-field>
                <b-input :placeholder="translations.main.form_attendants_filter_placeholder"
                    v-model="search"
                    type="text"
                    icon="search"
                    icon-right="close-circle"
                    icon-right-clickable
                    @icon-right-click="clearSearch">
                </b-input>
            </b-field>
            <component-data-loading v-if="loading.options" />
            <component-data-empty v-if="!loading.options && attendant_options.users.length == 0" />
            <b-table :data="currentUserPage" narrowed :class="customTableClass">
                <template slot-scope="props">
                    <b-table-column field="name" :label="translations.core.view_text_name">
                        {{ props.row.name }}
                    </b-table-column>
                    <b-table-column field="email" :label="translations.core.view_text_email">
                        {{ props.row.email }}
                    </b-table-column>
                    <b-table-column field="actions" label="">
                        <b-checkbox :disabled="props.row.submitting" size="is-small" v-model="props.row.checked" @input="submitAttendant(props.row)" />
                    </b-table-column>
                </template>
            </b-table>
            <hr>
            <b-pagination
                :simple="false"
                :total="filteredUsers.length"
                :current.sync="pagination.current_page"
                :range-before="pagination.range_before"
                :range-after="pagination.range_after"
                :per-page="pagination.per_page"
                order="is-centered"
                icon-prev="chevron-left"
                icon-next="chevron-right"
                aria-next-label="Next page"
                aria-previous-label="Previous page"
                aria-page-label="Page"
                aria-current-label="Current page"
            >
            </b-pagination>
        </b-tab-item>
        <b-tab-item :label="translations.main.view_tab_title_guests" :visible="eventEditable">
            <form v-on:submit.prevent="postGuest">
                <div class="field">
                    <label class="label">{{translations.core.view_text_name}}</label>
                    <div class="control">
                        <input class="input" type="text" v-model="guest.name">
                    </div>
                </div>
                <div class="field">
                    <label class="label">{{translations.core.view_text_email}}</label>
                    <div class="control">
                        <input class="input" type="email" v-model="guest.email">
                    </div>
                </div>
                <div class="field is-grouped">
                    <div class="control">
                        <button class="button is-primary">{{translations.core.view_btn_save}}</button>
                    </div>
                </div>
            </form>
        </b-tab-item>
        <b-tab-item :label="translations.main.view_tab_title_attendants_list">
            <component-data-loading v-if="loading.attendants" />
            <component-data-empty v-if="!loading.attendants && attendants.length == 0" />
            <b-table v-if="!loading.attendants && attendants.length > 0" :data="attendants" narrowed :class="customTableClass">
                <template slot-scope="props">
                    <b-table-column field="name" :label="translations.core.view_text_name">
                        {{ props.row.name }}
                    </b-table-column>
                    <b-table-column field="email" :label="translations.core.view_text_email">
                        {{ props.row.email }}
                    </b-table-column>
                    <b-table-column field="confirmed_at" :label="translations.main.confirmed_at" class="has-text-centered">
                        {{ props.row.confirmed_at || "not confirmed" }}
                    </b-table-column>
                    <b-table-column field="actions" class="has-text-centered">
                        <a 
                            role="button" 
                            class="delete is-pulled-right" 
                            v-if="eventEditable" 
                            @click="deleteAttendant(props.row)">
                        </a>
                    </b-table-column>
                </template>
            </b-table>
        </b-tab-item>
    </b-tabs>
</template>
