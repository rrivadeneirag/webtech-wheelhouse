Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  # Static pages from Lab 4
  root "pages#home"
  get "visiting", to: "pages#visiting", as: :visiting
  get "about",    to: "pages#about",    as: :about

  # Full CRUD from the browser: all seven RESTful actions per resource.
  resources :customers
  resources :bikes
  resources :repairs
  resources :services
  resources :staffs
end
