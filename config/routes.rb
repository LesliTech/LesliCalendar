CloudDriver::Engine.routes.draw do

    root to: 'calendars#default'

    resource  :calendar
    resources :calendars do
        scope module: :calendar do
            resources :actions
            resources :comments
            resources :activities
            resources :attachments
            resources :details
        end
    end

    resources :events

end
