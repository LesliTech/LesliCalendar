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
        appMountPath: {
            type: String,
            default: '/driver/catalog/event_types'
        }
    },

    data(){
        return {
            translations: {
                main: I18n.t('driver.catalog/event_types'),
                core: I18n.t('core.shared')
            },
            event_types: [],
            loading: false,
            pagination: {
                total_count: 0,
                current_page: 1,
                range_before: 3,
                range_after: 3
            },
            filters: {
                search: '',
                per_page: 15
            },
            filters_ready: false,
            sorting: {
                field: 'created_at',
                order: 'desc'
            },
            index_abilities: this.abilities.privilege('catalog/event_types', 'cloud_driver')
        }
    },

    // @return [void]
    // @description Executes the necessary functions needed to initialize this component
    mounted() {
        this.setSessionStorageFilters()
       this.getEventTypes()
    },

    methods: {
        setSessionStorageFilters(){
            let stored_filters = this.storage.local('filters')

            if(stored_filters){
                for(let key in stored_filters){
                    this.$set(this.filters, key, stored_filters[key])
                }
            }

            this.$nextTick(()=>{
                this.filters_ready = true
            })
        },

        getEventTypes() {
            this.storage.local('filters', this.filters)

            let url = this.url.driver('catalog/event_types')

            url = url.search(this.filters.search).paginate(
                this.pagination.current_page,
                this.pagination.per_page
            ).order(
                this.sorting.field,
                this.sorting.order
            )

            this.loading = true
            this.http.get(url).then(result => {
                this.loading = false

                if (result.successful) {
                    this.event_types = result.data.records
                    this.pagination.total_count = result.data.pagination.count_total
                }else{
                    this.msg.error(result.error.message)
                }
            }).catch(error => {
                console.log(error)
            })
        },

        showEventType(event_type) {
            this.$router.push(`${this.appMountPath}/${event_type.id}`)
        },

        reloadEventTypes(){
            this.loading = true
            this.getEventTypes()
        },

        searchEventTypes(text) {
            this.pagination.current_page = 1
            this.filters.search = text
            this.getEventTypes()
        },

        sortEventTypes(field, order){
            if(this.sorting.field == field){
                if(this.sorting.order == 'asc'){
                    this.sorting.order = 'desc'
                }else{
                    this.sorting.order = 'asc'
                }
            }else{
                this.sorting.field = field
                this.sorting.order = 'desc'
            }
            this.getEventTypes()
        }
    },

    watch: {
        'pagination.current_page': function(){
            if(! this.loading){
                this.getEventTypes()
            }
        },

        'filters.per_page'(){
            if(this.filters_ready){
                this.getEventTypes()
            }
        }
    }
}
</script>
<template>
    <section class="application-component">
        <component-header
            :title="translations.main.view_title_main">
            <div class="buttons">
                <button class="button" @click="reloadEventTypes()">
                    <b-icon icon="sync" size="is-small" :custom-class="loading ? 'fa-spin' : ''" />
                    <span> {{ translations.core.view_text_btn_reload }}</span>
                </button>
                <router-link class="button" tag="button" :to="`${appMountPath}/new`" v-if="index_abilities.create">
                    <b-icon icon="plus" size="is-small" />
                    <span>{{ translations.main.view_btn_create }}</span>
                </router-link>
            </div>
        </component-header>

        <component-toolbar
            v-if="filters_ready"
            :search-text="translations.main.view_placeholder_text_filter"
            @search="searchEventTypes"
            :initial-value="filters.search"
        >
            <div class="control">
                <div class="select">
                    <select v-model="filters.per_page">
                        <option :value="10">10</option>
                        <option :value="15">15</option>
                        <option :value="30">30</option>
                        <option :value="50">50</option>
                    </select>
                </div>
            </div>
        </component-toolbar>

        <div class="card">
            <div class="card-content">

                <component-data-loading v-if="loading" />
                <component-data-empty v-if="!loading && event_types.length == 0" />

                <b-table
                    :data="event_types"
                    @click="showEventType"
                    :hoverable="true"
                    v-if="!loading && event_types.length > 0"
                    @sort="sortEventTypes"
                    backend-sorting
                >
                    <template slot-scope="props">
                        <b-table-column field="id" :label="translations.main.column_id" sortable>
                            <template slot="header" slot-scope="{ column }">
                                {{ column.label }}
                                <span v-if="sorting.field == 'id'">
                                    <b-icon v-if="sorting.order == 'asc'" size="is-small" icon="arrow-up" ></b-icon>
                                    <b-icon v-else size="is-small" icon="arrow-down"></b-icon>
                                </span>
                            </template>
                            {{props.row.id}}
                        </b-table-column>

                        <b-table-column field="name" :label="translations.main.column_name" sortable>
                            <template slot="header" slot-scope="{ column }">
                                {{ column.label }}
                                <span v-if="sorting.field == 'name'">
                                    <b-icon v-if="sorting.order == 'asc'" size="is-small" icon="arrow-up" ></b-icon>
                                    <b-icon v-else size="is-small" icon="arrow-down"></b-icon>
                                </span>
                            </template>
                            {{props.row.name}}
                        </b-table-column>

                        <b-table-column field="model_type" :label="translations.main.column_model_type" sortable>
                            <template slot="header" slot-scope="{ column }">
                                {{ column.label }}
                                <span v-if="sorting.field == 'model_type'">
                                    <b-icon v-if="sorting.order == 'asc'" size="is-small" icon="arrow-up" ></b-icon>
                                    <b-icon v-else size="is-small" icon="arrow-down"></b-icon>
                                </span>
                            </template>
                            {{props.row.model_type}}
                        </b-table-column>

                        <b-table-column field="created_at" :label="translations.core.column_created_at" sortable>
                            <template slot="header" slot-scope="{ column }">
                                {{ column.label }}
                                <span v-if="sorting.field == 'created_at'">
                                    <b-icon v-if="sorting.order == 'asc'" size="is-small" icon="arrow-up" ></b-icon>
                                    <b-icon v-else size="is-small" icon="arrow-down"></b-icon>
                                </span>
                            </template>
                            {{props.row.created_at_string}}
                        </b-table-column>
                    </template>
                </b-table>
                <hr>
                <b-pagination
                    :simple="false"
                    :total="pagination.total_count"
                    :current.sync="pagination.current_page"
                    :range-before="pagination.range_before"
                    :range-after="pagination.range_after"
                    :per-page="filters.per_page"
                    order="is-centered"
                    icon-prev="chevron-left"
                    icon-next="chevron-right"
                    aria-next-label="Next page"
                    aria-previous-label="Previous page"
                    aria-page-label="Page"
                    aria-current-label="Current page"
                >
                </b-pagination>
            </div>
        </div>
    </section>
</template>
