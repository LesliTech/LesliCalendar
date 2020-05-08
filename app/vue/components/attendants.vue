<script>
export default {
    props: {
        eventId: {
            required: true
        }
    },

    data(){
        return {
            active_tab: 0,
            main_route: '/driver/events',
            users_route: '/users.json?role=kop&type=exclude',
            translations: {
                main: I18n.t('driver.events'),
                core: I18n.t('core.shared'),
                users: I18n.t('core.users')
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
                per_page: 8
            },
            attendant_options: {
                users: []
            },
            attendants: []
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
                    this.notification.alert(result.error.message, 'danger')
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
                    this.notification.alert(result.error.message,'danger')
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

            this.http.post(url, data).then(result => {
                if (result.successful) {
                    this.$set(user, 'attendant_id', result.data.id)
                    this.attendants.push({
                        id: result.data.id,
                        name: user.name || user.email,
                        email: user.email,
                        role: user.role,
                        users_id: user.id
                    })
                    this.notification.alert(this.translations.main.notification_attendant_created, 'success')
                }else{
                    this.notification.alert(result.error.message,'danger')
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

            this.http.delete(url).then(result => {
                if (result.successful) {
                    this.notification.alert(this.translations.main.notification_attendant_deleted, 'success')
                    
                    this.attendants = this.attendants.filter((attendant)=>{
                        return attendant.id != attendant_id
                    })

                    let user = this.attendant_options.users.find((user)=>{
                        return user.attendant_id == attendant_id
                    })
                    user.attendant_id = null
                    user.checked = false
                }else{
                    this.notification.alert(result.error.message,'danger')
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

        translateUserRole(role){
            let new_role = this.translations.users[`enum_role_${role}`]
            if(new_role){
                return new_role
            }

            return role
        }
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

        search(){
            this.pagination.current_page = 1
        }
    }
}
</script>
<template>
    <b-tabs expanded v-model="active_tab">
        <b-tab-item :label="translations.main.form_attendants_tab_new">
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
            <b-table :data="currentUserPage">
                <template slot-scope="props">
                    <b-table-column field="name" :label="translations.core.text_name">
                        {{ props.row.name }}
                    </b-table-column>
                    <b-table-column field="email" :label="translations.core.text_email">
                        {{ props.row.email }}
                    </b-table-column>
                    <b-table-column field="role" :label="translations.core.text_role">
                        {{ translateUserRole(props.row.role) }}
                    </b-table-column>
                    <b-table-column field="actions" label="">
                        <b-checkbox size="is-small" v-model="props.row.checked" @input="submitAttendant(props.row)" />
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
        <b-tab-item :label="translations.main.form_attendants_tab_list">
            <component-data-loading v-if="loading.attendants" />
            <component-data-empty v-if="!loading.attendants && attendants.length == 0" />
            <b-table v-if="!loading.attendants && attendants.length > 0" :data="attendants">
                <template slot-scope="props">
                    <b-table-column field="name" :label="translations.core.text_name">
                        {{ props.row.name }}
                    </b-table-column>
                    <b-table-column field="email" :label="translations.core.text_email">
                        {{ props.row.email }}
                    </b-table-column>
                    <b-table-column field="role" :label="translations.core.text_role">
                        {{ translateUserRole(props.row.role) }}
                    </b-table-column>
                    <b-table-column field="actions" label="">
                        <a class="delete" role="button" @click="deleteAttendant(props.row)"></a>
                    </b-table-column>
                </template>
            </b-table>
        </b-tab-item>
    </b-tabs>
</template>
