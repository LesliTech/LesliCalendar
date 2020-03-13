CloudDriver::Engine.routes.draw do

    root to: 'calendars#default'

    resources :calendars do
        scope module: :calendar do
            resources :actions
            resources :comments
            resources :activities
            resources :attachments
            resources :details
        end
    end

    resources :events do
        scope module: :event do
            resources :actions
            resources :comments
            resources :activities
            resources :attachments
            resources :details
            resources :files
        end
    end

end
