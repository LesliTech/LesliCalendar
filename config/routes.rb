CloudDriver::Engine.routes.draw do

  namespace :event do
    resources :attendances
  end
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

    resources :events

end
