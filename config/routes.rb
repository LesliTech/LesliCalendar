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

        member do
            get "files.zip" => "files#zip_download_options"
        end

        collection do
            get "search"
            get "options" 
            get "options/file", to: "event/files#file_options"
            get "options/attendant" => "events#attendant_options"
        end

    end
end
