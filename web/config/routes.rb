Rails.application.routes.draw do
  root :to => "homepage#home"

  devise_for :users, :skip => %i[registrations sessions]
  as :user do
    post "/users/sign_in" => "devise/sessions#create", :as => :user_session
    delete "/users/sign_out" => "devise/sessions#destroy", :as => :destroy_user_session
  end

  authenticate :user do
    resources :book, :only => %i[create new edit show update destroy], :param => :book_slug do
      resources :entry, :only => %i[create show update destroy]
      resources :extractor, :only => %i[create new show update destroy]
      resources :shorthand, :only => %i[create new show update destroy]
      get "/at/:requested_time", :to => "book#show", :as => :at
    end

    resources :reports, :only => %i[index show]
    resource :search, :only => %i[show]
    resource :user, :only => %i[show update]

    post "/query/execute", :to => "query#execute"
  end
end
