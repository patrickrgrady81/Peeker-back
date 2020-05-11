Rails.application.routes.draw do
root to: "pages#home"

  namespace :api, constraints: {format: :json}, defaults: {format: :json} do
    namespace :v1 do
      resources :compute, only: [:index]

      post "/send", to: "compute#sent"
    end
  end
end
