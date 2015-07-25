Rails.application.routes.draw do
  
  

  root 'static_pages#index'
  get 'admin' => 'static_pages#sysadmin', as: :sysadmin
  
  resources :instances do
    resources :schema_elements, shallow: true
  end
  
end
