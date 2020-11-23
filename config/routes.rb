=begin
    
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
    
=end

CloudDriver::Engine.routes.draw do

    root to: "dashboards#index"

    resource :dashboards






    # the routes bellow needs revision
    resources :workflows do
        member do
            get "actions/options",          to: "workflow/actions#options"
        end
        collection do
            post "list" => :index
            get  "associations/options",    to: "workflow/associations#options"
            get "/resources/transition-options/:cloud_object_name/:cloud_object_id", to: "workflows#transition_options"
        end
        scope module: :workflow do
            resources :associations
            resources :statuses
            resources :actions do
                collection do 
                    scope :resources do
                        get :options_create_cloud_object_file
                        get :options_cloud_object_clone
                    end
                end
            end
        end
    end

    resources :dashboards do
        collection do
            post "list" => :index
            get :options
        end
        scope module: :dashboard do
            resources :components
        end
    end
    
    resources :calendars do
        scope module: :calendar do
            resources :actions
            resources :discussions
            resources :activities
            resources :attachments
            resources :details
        end
    end

    resources :events do
        member do
            get "/resources/files-zip-download",    to:  "event/files#zip_download"
        end
        collection do
            get :search
            get :options 
            get "/files/options",                   to: "event/files#options"
            get "/resources/events-by-model/:model_type/:model_id" =>  :events_by_model
        end
        scope module: :event do
            resources :actions
            resources :discussions
            resources :activities
            resources :subscriptions
            resources :attachments
            resources :details
            resources :files

            resources :attendants
        end

    end
end
