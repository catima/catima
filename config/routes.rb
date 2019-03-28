# rubocop:disable Metrics/BlockLength
Rails.application.routes.draw do
  # ===========================================================================
  # API

  namespace :api, :format => "json", :only => %w(index show) do
    namespace :v1 do
      resources :catalogs, :param => :slug do
        resources :items
      end
    end
  end

  namespace :api, format: 'json' do
    namespace :v2 do
      scope :path => ':catalog_slug' do
        scope :path => ':locale' do
          get '/' => 'catalogs#show'
          get ':item_type' => 'items#index', as: 'items'
          get ':item_type_slug/:field_uuid' => 'fields#index', as: 'fields'
          get '/categories/:category_id/:field_uuid' => 'fields#index', as: 'category_fields'
        end
      end
    end
  end

  # ===========================================================================
  # Devise, favorites & group memberships

  scope :path => ":locale" do
    devise_for :users, :skip => %i[passwords registrations sessions omniauth_callbacks]
    devise_scope :user do
      # passwords
      get "forgot-password" => "devise/passwords#new", :as => :new_user_password
      post "forgot-password" => "devise/passwords#create", :as => :user_password
      get "change-password" => "devise/passwords#edit",
          :as => :edit_user_password
      patch "change-password" => "devise/passwords#update"

      # registrations
      get "register" => "users/registrations#new",
          :as => :new_user_registration
      post "register" => "users/registrations#create",
          :as => :user_registration
      get "my-profile" => "users/registrations#edit",
          :as => :edit_user_registration
      patch "my-profile" => "users/registrations#update"
      get "cancel-account" => "users/registrations#cancel",
          :as => :cancel_user_registration
      delete "cancel-account" => "users/registrations#destroy"

      # sessions
      get "login" => "users/sessions#new", :as => :new_user_session
      post "login" => "users/sessions#create", :as => :user_session
      delete "logout" => "users/sessions#destroy", :as => :destroy_user_session
    end

    # Favorites
    resources :favorites, :except => [:edit, :show, :new, :update]

    # Group memberships
    resources :memberships, only: %i(index create destroy), path: '_groups'
  end

  devise_for :users, only: :omniauth_callbacks, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }

  # ===========================================================================
  # System administration

  namespace "admin" do
    get "/" => "dashboard#index", :as => :dashboard
    resources :catalogs, :param => :slug, :except => [:index]
    resources :template_storages, :except => :index
    resources :configurations, :only => :update
    resources :users, :except => :index
  end

  mount Sidekiq::Web => "/sidekiq" # monitoring console
  root "home#index"

  # ===========================================================================
  # Containers actions
  post '/contact', :to => 'container#contact'

  # ===========================================================================
  # Catalog administration

  namespace "catalog_admin", :path => ":catalog_slug/:locale/admin" do
    get "/" => "dashboard#setup", :as => :setup
    get "/_data" => "dashboard#data", :as => :data

    get "/_settings" => "catalogs#edit", :as => :settings
    patch "/_settings" => "catalogs#update"

    get "/_style" => "catalogs#edit_style", :as => :style
    patch "/_style" => "catalogs#update_style"

    resources :groups, path: '_groups' do
      resources :memberships
    end

    resources :categories, :path => "_categories", :except => [:show] do
      resources :fields, :param => :slug, :except => :show
    end

    # Exports
    resources :exports, :path => "_exports", :except => [:edit, :show, :new, :destroy, :update] do
      member do
        get 'download'
      end
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

    resources :item_views,
              :path => ":item_type_slug/views",
              :except => [:index, :show],
              :as => "item_views"

    resources :csv_imports,
              :path => ":item_type_slug/import",
              :only => [:new, :create]

    resources :choice_sets, :path => "_choices", :except => :show do
      post 'create_choice' => 'choice_sets#create_choice'
    end

    resources :pages, :path => "_pages", :param => :slug do
      resources :containers,
                :path => "_containers",
                :shallow => true,
                :param => :id,
                :except => :show
    end
    resources :users, :path => "_users"
    resources :advanced_search_configurations, :path => "_advanced_search_configurations"
    resources :menu_items, path: '_menu_items'

    # Data entry
    resources :items, :path => ":item_type_slug", :except => :show do
      member do
        post "approval" => "approvals#create"
        delete "approval" => "approvals#destroy"
        get "duplicate"
      end
    end
    post ":item_type_slug/upload" => "items#upload", :as => 'item_file_upload'

    get ":item_type_slug/search" => "items#search", :as => "simple_search"
  end

  # ===========================================================================
  # Catalog viewing (public)

  # Public catalog views can be customized, along with the controllers.
  # Controllers are referred to in the routes, so we check for each public
  # route if a customized controller exists. If so, we create a separate route
  # with the customized controller instead of the default one for the catalog.

  # This feature leads to a bit clunky route definitions, especially because
  # the custom controllers might not yet have been loaded (especially in
  # development due to auto-loading). However, custom controllers need to
  # be subclasses of the default controller. Hence, we can simply rely on
  # the existence of a file with the appropriate name.

  # First get a list of custom catalogs by inspecting the catalogs directory.
  custom_catalogs = Dir[Rails.root.join('catalogs', '*')].map { |dir| File.basename(dir) }

  custom_catalogs.each do |catalog_slug|
    catalog_snake_slug = catalog_slug.tr('-', '_')
    next unless File.exist?(Rails.root.join('catalogs', catalog_slug, 'controllers', "#{catalog_snake_slug}_catalogs_controller.rb"))

    get "#{catalog_slug}/(:locale)",
        :controller => "#{catalog_snake_slug}_catalogs",
        :action => :show,
        :catalog_slug => catalog_slug,
        :as => "catalog_#{catalog_snake_slug}"
  end

  # Default catalog index route
  get ":catalog_slug/(:locale)" => "catalogs#show",
      :as => "catalog_home",
      :constraints => CatalogsController::Constraint

  # Create per-catalog routes for item type views for customized items controllers.
  custom_catalogs.each do |catalog_slug|
    catalog_snake_slug = catalog_slug.tr('-', '_')

    scope :path => "#{catalog_slug}/:locale",
          :constraints => CatalogsController::Constraint do

      if File.exist?(Rails.root.join('catalogs', catalog_slug, 'controllers', "#{catalog_snake_slug}_simple_search_controller.rb"))
        get "search",
            :controller => "#{catalog_snake_slug}_simple_search",
            :action => :index,
            :as => "#{catalog_snake_slug}_simple_search",
            :catalog_slug => catalog_slug
      end

      if File.exist?(Rails.root.join('catalogs', catalog_slug, 'controllers', "#{catalog_snake_slug}_advanced_searches_controller.rb"))
        get 'search/advanced/new',
            :controller => "#{catalog_snake_slug}_advanced_searches",
            :action => :new,
            :as => "#{catalog_snake_slug}_new_advanced_search",
            :catalog_slug => catalog_slug

        get 'search/advanced/:uuid',
            :controller => "#{catalog_snake_slug}_advanced_searches",
            :action => :show,
            :as => "#{catalog_snake_slug}_advanced_search",
            :catalog_slug => catalog_slug
      end

      if File.exist?(Rails.root.join('catalogs', catalog_slug, 'controllers', "#{catalog_snake_slug}_pages_controller.rb"))
        get ":slug",
            :controller => "#{catalog_snake_slug}_pages",
            :action => :show,
            :as => "#{catalog_snake_slug}_pages",
            :catalog_slug => catalog_slug,
            :constraints => PagesController::Constraint
      end

      if File.exist?(Rails.root.join('catalogs', catalog_slug, 'controllers', "#{catalog_snake_slug}_items_controller.rb"))
        get ":item_type_slug",
            :controller => "#{catalog_snake_slug}_items",
            :action => :index,
            :as => "#{catalog_snake_slug}_items",
            :catalog_slug => catalog_slug,
            :constraints => ItemsController::Constraint

        get ":item_type_slug/:id",
            :controller => "#{catalog_snake_slug}_items",
            :action => :show,
            :as => "#{catalog_snake_slug}_item",
            :catalog_slug => catalog_slug,
            :constraints => ItemsController::Constraint
      end
    end
  end

  # Generating the default routes.
  scope :path => ":catalog_slug/:locale",
        :constraints => CatalogsController::Constraint do
    get "search" => "simple_search#index", :as => "simple_search"

    resources :advanced_searches,
              :path => "search/advanced",
              :param => :uuid,
              :only => [:new, :create, :show]

    get ":slug" => "pages#show",
        :constraints => PagesController::Constraint,
        :as => :page

    resources :items,
              :path => ":item_type_slug",
              :only => [:index, :show],
              :constraints => ItemsController::Constraint

    get ":slug" => "custom#show", :constraints => CustomController::Constraint

    get "/doc", :to => "documentation#index"
  end

  # ===========================================================================
  # Image thumbnails

  get '/thumbs/:catalog_slug/:size/fill/:crop/:field_uuid/:image.:ext',
    :to => 'images#thumbnail_cropped',
    :constraints => CatalogsController::Constraint

  get '/thumbs/:catalog_slug/:size/fill/:field_uuid/:image.:ext',
    :to => 'images#thumbnail_default_cropped',
    :constraints => CatalogsController::Constraint

  get '/thumbs/:catalog_slug/:size/resize/:field_uuid/:image.:ext',
    :to => 'images#thumbnail',
    :constraints => CatalogsController::Constraint

  # ===========================================================================
  # Service URLs

  # Service for converting DOCX to HTML
  post "s/docx2html" => "docx#convert_to_html", :as => 'docx2html'

  # ===========================================================================
  # Error pages

  match '/404', to:'errors#error_404', :via => :all
  match '/422', to:'errors#error_404', :via => :all
  match '/500', to:'errors#error_500', :via => :all
  match '/505', to:'errors#error_500', :via => :all
end
