Rails.application.routes.draw do
  resource :session
  resource :registration, only: %i[new create]
  resources :passwords, param: :token
  get "up" => "rails/health#show", as: :rails_health_check

  # Static pages from Lab 4
  root "pages#home"
  get "visiting", to: "pages#visiting", as: :visiting
  get "about",    to: "pages#about",    as: :about

  # Full CRUD from the browser.
  resources :customers
  resources :bikes
  resources :services
  resources :staffs

  # A repair, plus its intake photos which can be removed one at a time.
  resources :repairs do
    resources :photos, only: :destroy, controller: "intake_photos"
  end

  # JSON API for programs that are not a browser: the public price list, the
  # private repairs for the accounting program, and registering a new service.
  namespace :api do
    namespace :v1 do
      resources :services, only: %i[index show create]
      resources :repairs,  only: %i[index show]
    end
  end
end
