CloudDriver::Engine.routes.draw do
    root to: "calendars#default"

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
            resources :actions
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
            get "/resource/files-zip-download",    to:  "event/files#zip_download"
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
