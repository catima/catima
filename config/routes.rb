Rails.application.routes.draw do

  root 'static_pages#index'
  get 'admin' => 'static_pages#sysadmin', as: :sysadmin
  
  resources :instances do
    resources :schema_elements, shallow: true do
      resources :schema_fields, shallow: true
    end
  end
  
  get ':catalog' => 'catalogs#show', as: :catalog_show
  
end
