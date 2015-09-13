Rails.application.routes.draw do


  root 'static_pages#index'
  get 'admin' => 'static_pages#sysadmin', as: :sysadmin
  
  resources :instances do
    resources :schema_elements, shallow: true do
      resources :schema_fields, shallow: true
    end
  end
  
  get ':catalog' => 'catalogs#show', as: :catalog_show
  get ':catalog/admin' => 'catalogs#admin', as: :catalog_admin
  get ':catalog/admin/:element' => 'catalogs#element_admin', as: :catalog_element_admin
  get ':catalog/admin/:element/:id' => 'catalogs#element_edit', as: :catalog_element_edit
  get ':catalog/:slug' => 'views#show', as: :view_show
  
end
