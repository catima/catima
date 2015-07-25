Rails.application.routes.draw do
  
  root 'static_pages#index'
  get 'admin' => 'static_pages#sysadmin'
  
  resources :instances
  
end
