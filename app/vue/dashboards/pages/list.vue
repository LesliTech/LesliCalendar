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
    props: {

    },
    
    components: {

    },

    // @return [Object] Data used by this component's methods
    // @description Returns the data needed for this component to work properly
    // @data_variable main_route [String] the main route to which this component connects to the lesli API
    // @data_variable dashboards [Array] An array of objects, each object represents a 
    //      Dashboards, with the same params as the associated rails model
    data(){
        return {
            main_route: '/driver/calendars',
            dashboards: null,
            calendars: [],
            reloading: false,
            columns: [{
                field: "id",
                label: "ID",
                width: "40"
            }, {
                field: "name",
                label: "Name",
            }]
        }
    },

    // @return [void]
    // @description Executes the necessary functions needed to initialize this component
    mounted() {
       this.getCalendars()
    },

    methods: {

        // @return [void]
        // @description Connects to the backend using HTTP and retrieves a list of Dashboards associated to
        //      the current user's account. If the HTTP request fails, an error message is shown
        // @example
        //      console.log(this.dashboards) // will display null
        //      this.getdashboards()
        //      console.log(this.dashboards) // will display an array of objects, each representing a Dashboards.
        getCalendars() {
            this.http.get(`${this.main_route}.json`).then(result => {
                this.reloading = false
                if (result.successful) {
                    this.calendars = result.data
                }else{
                    this.msg.error(result.error.message)
                }
            }).catch(error => {
                console.log(error)
            })
        },
        
        // @return [void]
        // @param dashboards [Object] The object representation of the selected Dashboards
        // @description Redirects the router to show the selected Dashboards
        // @example
        //      this.showdashboards(this.dashboards[1])
        //      // Asume the id of the Dashboards is 4
        //      // The user will be redirected to the url /driver/dashboards/4
        showCalendar(dashboards) {
            this.$router.push(`/${dashboards.id}`)
        },

        reloadCalendars(){
            this.reloading = true
            this.getCalendars()
        }
    },

    computed: {

        // @return [String] The class that is used to give a spinning animation to the icon (if needed)
        // @description When the user clicks the 'reload' button, it changes the value of the *reloading*
        //      data variable. And that is used by this method to change the class of the icon and add it
        //      the spinning animation
        reloadingClass(){
            if(this.reloading){
                return 'fa-spin'
            }

            return ''
        }
    }
}
</script>
<template>
    <section class="application-component">
        <component-header title='Calendars'></component-header>

        <div class="card">
            <div class="card-content">
                asdef
            </div>
        </div>
    </section>
</template>
