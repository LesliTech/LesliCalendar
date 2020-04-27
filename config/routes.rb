CloudDriver::Engine.routes.draw do

    root to: "calendars#default"

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
            get "files/zip" => "event/files#zip_download"
        end

        collection do
            get "search"
            get "options" 
            get "options/file", to: "event/files#file_options"
            get "options/attendant" => "events#attendant_options"
            get ":model_type/:model_id" => "events#events_by_model"
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
