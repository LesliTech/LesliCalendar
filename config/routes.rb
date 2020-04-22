CloudDriver::Engine.routes.draw do

    root to: 'calendars#default'

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
    end

    scope :options do
        scope :event, module: :event do
            get "/attendants",                  to: "attendants#attendant_options"
            get "/files",                       to: "files#file_options"
            get "/:cloud_object_id/files/zip",  to: "files#zip_download_options"
        end
    end

end
