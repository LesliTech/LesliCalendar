<script>
/*

Copyright (c) 2020, all rights reserved.

All the information provided by this platform is protected by international laws related  to 
industrial property, intellectual property, copyright and relative international laws. 
All intellectual or industrial property rights of the code, texts, trade mark, design, 
pictures and any other information belongs to the owner of this platform.

Without the written permission of the owner, any replication, modification,
transmission, publication is strictly forbidden.

For more information read the license file including with this software.

// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
// · 

*/


// · List of Imported Components
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~


// · 
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~


export default {
    
    // @component_prop dashboards [Object] The object representation of the dashboards.
    //      If this component is being used by the *new* app, all the object properties are empty
    // @component_prop viewType [String] Either 'new', 'edit' or 'show'. Represents the main app that
    //      imported this component
    props: {
        dashboards: {
            required: true
        },

        viewType: {
            type: String,
            required: true
        }
    },

    components: {

    },
    
    // @return [Object] Data used by this component's methods
    // @description Returns the data needed for this component to work properly
    // @data_variable main_route [String] the main route to which this component connects to the lesli API
    // @data_variable dashboards [Object] An object representing a Dashboards, with
    //      the same params as the associated rails model
    data() {
        return {
            main_route: '/driver/dashboards',
            dashboards: null
        }
    },

    // @return [void]
    // @description Executes the necessary functions needed to initialize this component
    mounted() {
        this.setdashboardsId()
        this.copydashboardsProp()
    },

    methods: {

        // @return [void]
        // @description Retrieves the id of the Dashboards and stores it in the data variable dashboards_id
        // @example
        //      console.log(this.dashboards_id) // will display null
        //      this.setdashboardsId()
        //      console.log(this.dashboards_id) // will display a number, like 5
        setdashboardsId(){
            this.dashboards_id = this.$route.params.id
        },

        // @return [void]
        // @description Copies the content of the prop dashboards into the data variable dashboards.
        //      This is done to allow this component to modify the Dashboards's attributes without directly
        //      modifying the received prop
        // @example
        //      console.log(this.dashboards) // will display null
        //      this.copydashboardsProp()
        //      console.log(this.dashboards_id) // will display an exact copy of the dashboards prop
        copydashboardsProp(){
            this.dashboards = {... this.dashboards}
        },

        // @return [void]
        // @description Catches the submit event of the HTML form, and prevents its default behavior. Depending on the
        //      value of the *viewType* variable, executes a method that sends and HTTP post or put to the lesli API
        //  @example
        //      this.submitdashboards() // will trigger a post if viewMode is 'new' or a put if viewMode is 'edit'
        submitdashboards(event){
            if (event) { event.preventDefault() }

            if(this.viewType == 'new'){
                this.postdashboards()
            }else if(this.viewType == 'edit'){
                this.putdashboards()
            }
        },

        // @return [void]
        // @description Connects to the backend using HTTP to create a new Dashboards under the current user's
        //       account. If the HTTP request fails, an error message is shown
        // @example
        //      console.log(this.dashboards.id)  // will display null since this will be a new record
        //      this.postdashboards()            // will create a new record and redirect to it's show app
        postdashboards() {
            let form_data = {
                dashboards: this.dashboards
            }
            let url = `${this.main_route}.json`

            this.http.post(url, form_data).then(result => {
                if (result.successful) {
                    this.msg.success('Dashboards created successfully')
                    this.$router.push(`/${result.data.id}`)
                }else{
                    this.msg.error(result.error.message)
                }
            }).catch(error => {
                console.log(error)
            })

        },

        // @return [void]
        // @description Connects to the backend using HTTP to update an existing Dashboards under the current user's
        //      account. The id of the Dashboards is provided in the *id* route param. If the HTTP request fails,
        //      an error message is shown
        // @example
        //      this.putdashboards() // will update the record and redirect to it's show app
        putdashboards() {
            let form_data = {
                dashboards: this.dashboards
            }
            let url = `${this.main_route}/${this.dashboards_id}.json`

            this.http.put(url, form_data).then(result => {
                if (result.successful) {
                    this.msg.success('Dashboards updated successfully')
                    this.$router.push(`/${this.dashboards.id}`)
                }else{
                    this.msg.error(result.error.message)
                }
            }).catch(error => {
                console.log(error)
            })

        },

        // @return [void]
        // @description Connects to the backend using HTTP to delete an existing Dashboards under the current user's
        //      account. The id of the Dashboards is provided in the *id* route param. If the HTTP request fails,
        //      an error message is shown
        // @example
        //      this.deletedashboards() // will delete the record and redirect to the list app
        deletedashboards() {
            let url = `${this.main_route}/${this.dashboards_id}`

            this.http.delete(url).then(result => {
                if (result.successful) {
                    this.msg.success('Dashboards deleted successfully')
                    this.$router.push('/')
                }else{
                    this.msg.error(result.error.message)
                }
            }).catch(error => {
                console.log(error)
            })
        }
    }
}
</script>
<template>
    <div class="card" v-if="dashboards">
        <!--------------------------------------- START CARD HEADER --------------------------------------->
        <div class="card-header">
            <h2 class="card-header-title">
                Dashboards
            </h2>
            <div class="card-header-icon">
                <router-link v-if="viewType == 'edit'" :to="`/${dashboards.id}`">
                    <i class="fas fa-eye"></i>
                    Show Dashboards
                </router-link>
                <router-link v-if="viewType == 'show'" :to="`/${dashboards.id}/edit`">
                    <i class="fas fa-eye"></i>
                    Edit Dashboards
                </router-link>
                <router-link to="/">
                    &nbsp;&nbsp;&nbsp;
                    <i class="fas fa-undo"></i>
                    Return
                </router-link>
            </div>
        </div>
        <!---------------------------------------  END CARD HEADER  --------------------------------------->

        <!--------------------------------------- START CARD CONTENT--------------------------------------->
        <div class="card-content">
            <form @submit="submitdashboards">

                <!---------------------------------- START SUBMIT BUTTON ---------------------------------->
                <b-field v-if="viewType == 'new' || viewType == 'edit'">
                    <b-button type="is-primary" native-type="submit" expended>
                        <span v-if="viewType == 'new'">
                            Create Dashboards
                        </span>
                        <span v-else>
                            Update Dashboards
                        </span>
                    </b-button>
                </b-field>
                <!----------------------------------  END SUBMIT BUTTON  ---------------------------------->
                
                <!---------------------------------- START DELETE BUTTON ---------------------------------->
                <b-field v-if="viewType == 'show'">
                    <b-button type="is-danger" @click="deletedashboards">
                        Delete Dashboards
                    </b-button>
                </b-field>
                <!----------------------------------  END DELETE BUTTON  ---------------------------------->
            </form>
        </div>
        <!---------------------------------------  END CARD CONTENT --------------------------------------->
    </div>
</template>
