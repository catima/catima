Rails.application.routes.draw do
  # ===========================================================================
  # Devise

  scope :path => ":locale" do
    devise_for :users, :skip => [:passwords, :registrations, :sessions]
    devise_scope :user do
      # passwords
      get "forgot-password" => "devise/passwords#new", :as => :new_user_password
      post "forgot-password" => "devise/passwords#create", :as => :user_password
      get "change-password" => "devise/passwords#edit",
          :as => :edit_user_password
      patch "change-password" => "devise/passwords#update"

      # registrations
      get "register" => "devise/registrations#new",
          :as => :new_user_registration
      post "register" => "devise/registrations#create",
          :as => :user_registration
      get "my-profile" => "devise/registrations#edit",
          :as => :edit_user_registration
      patch "my-profile" => "devise/registrations#update"
      get "cancel-account" => "devise/registrations#cancel",
          :as => :cancel_user_registration
      delete "cancel-account" => "devise/registrations#destroy"

      # sessions
      get "login" => "users/sessions#new", :as => :new_user_session
      post "login" => "users/sessions#create", :as => :user_session
      delete "logout" => "users/sessions#destroy", :as => :destroy_user_session
    end
  end

  # ===========================================================================
  # System administration

  namespace "admin" do
    get "/" => "dashboard#index", :as => :dashboard
    resources :catalogs, :param => :slug, :except => [:index, :destroy]
    resources :users, :except => :index
  end

  mount Sidekiq::Web => "/sidekiq" # monitoring console
  root "home#index"

  # ===========================================================================
  # Catalog administration

  namespace "catalog_admin", :path => ":catalog_slug/admin" do
    get "/" => "dashboard#setup", :as => :setup
    get "/_data" => "dashboard#data", :as => :data

    resources :categories, :path => "_categories", :except => [:show] do
      resources :fields,
                :controller => "categories/fields",
                :param => :slug,
                :except => :show
    end

    resources :item_types,
              :path => "_item-types",
              :only => [:new, :create]

    resources :item_types,
              :param => :slug,
              :path => "",
              :except => [:index, :show, :new, :create]

    resources :fields,
              :path => ":item_type_slug/fields",
              :param => :slug,
              :except => :show,
              :as => "item_type_fields"

    resources :choice_sets, :path => "_choices", :except => :show
    resources :pages, :path => "_pages", :param => :slug
    resources :users, :path => "_users"

    # Data entry
    resources :items, :path => ":item_type_slug", :except => :show do
      member do
        post "approval" => "approvals#create"
        delete "approval" => "approvals#destroy"
      end
    end
  end

  # ===========================================================================
  # Catalog viewing (public)

  get ":catalog_slug/(:locale)" => "catalogs#show",
      :as => "catalog_home",
      :constraints => CatalogsController::Constraint

  scope :path => ":catalog_slug/:locale",
        :constraints => CatalogsController::Constraint do
    get "search" => "simple_search#index", :as => "simple_search"

    resources :advanced_searches,
              :path => "search/advanced",
              :param => :uuid,
              :only => [:new, :create, :show]

    get ":slug" => "pages#show", :constraints => PagesController::Constraint

    resources :items,
              :path => ":item_type_slug",
              :only => [:index, :show],
              :constraints => ItemsController::Constraint

    get ":slug" => "custom#show", :constraints => CustomController::Constraint
  end
end
