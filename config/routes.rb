CloudDriver::Engine.routes.draw do

    root to: 'calendars#default'

    resources :events
    namespace :event do
        resources :actions
        resources :comments
        resources :activities
        resources :attachments
        resources :details
    end

    resources :calendars
    namespace :calendar do
        resources :actions
        resources :comments
        resources :activities
        resources :attachments
        resources :details
    end

    scope :api do
        get '/employees', to: 'employees#api_index'
    end

end
