require 'sidekiq/web'

# rubocop:disable Metrics/BlockLength
Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'

  # Healthcheck
  get '/health', to: proc { [200, { 'Content-Type' => 'text/plain' }, ['success']] }

  authenticate :user, ->(u) { u.system_admin? } do
    mount Sidekiq::Web => '/sidekiq' # monitoring console
  end

  # ===========================================================================
  # API

  namespace :api, :format => "json", :only => %w(index show) do
    namespace :v1 do
      resources :catalogs, :param => :slug, :only => [:index, :show] do
        resources :items, :only => [:index, :show]
        scope :path => ':locale' do
          resources :items, :only => [:index, :show]
        end
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

  namespace :react, format: 'json' do
    scope :path => ':catalog_slug' do
      scope :path => ':locale' do
        get '/' => 'catalogs#show'
        get ':item_type' => 'items#index', as: 'items'
        get 'items' => 'items#geo_viewer_index'
        get 'items/:id' => 'items#geo_viewer_show'
        get ':item_type_slug/:field_uuid' => 'fields#index', as: 'fields'
        get ':item_type_slug/:field_uuid/choices_for_choice_set' => 'fields#choices_for_choice_set', as: 'choices_for_choice_set'
        get ':category_id/:field_uuid/category_choices_for_choice_set' => 'fields#category_choices_for_choice_set', as: 'category_choices_for_choice_set'
        get '/categories/:category_id/:field_uuid' => 'fields#index', as: 'category_fields'
      end
    end
  end

  namespace :api, format: 'json' do
    namespace :v3 do
      devise_for :users, defaults: { format: :json },
                 class_name: 'APIUser',
                 skip: [:registrations, :invitations, :passwords, :confirmations, :unlocks, :omniauth_callbacks],
                 path: '', path_names: { sign_in: 'login', sign_out: 'logout' }
      resources :catalogs, only: %i(index)

      scope module: 'catalog' do
        scope ':catalog_id' do
          resources :suggestions, only: %i(index)
          resources :users, only: %i(index)
          resources :groups, only: %i(index)
          resources :categories, only: %i(index)
          resources :item_types, only: %i(index)
          get '/item_type/:item_type_id' => 'item_types#show'
          resources :choice_sets, only: %i(index)
          get '/choice_set/:choice_set_id' => 'choice_sets#show'

          namespace 'item_type' do
            scope ':item_type_id' do
              resources :fields, only: %i(index)
              get '/field/:field_id' => 'fields#show'
              resources :items, only: %i(index)
              get '/item/:item_id' => 'items#show'
              get '/item/:item_id/suggestions' => 'items#suggestions'
            end
          end

          namespace 'category' do
            scope ':category_id' do
              resources :fields, only: %i(index)
            end
          end

          namespace 'choice_set' do
            scope ':choice_set_id' do
              resources :choices, only: %i(index)
              get '/choice/:choice_id' => 'choices#show'
            end
          end

          resources :simple_searches, path: "search", param: :uuid, only: [:create, :show]
          scope 'advanced_search' do
            get ':item_type_id/new' => 'advanced_searches#new'
            post ':item_type_id' => 'advanced_searches#create'
            get ':uuid' => 'advanced_searches#show'
          end
        end
      end
    end
  end

  # ===========================================================================
  # Maintenance mode

  get :maintenance, to: 'maintenance#show'

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

    # Searches
    resources :searches, :except => [:new]

    # Group memberships
    resources :memberships, only: %i(index create destroy), path: '_groups'
  end

  devise_for :users, only: :omniauth_callbacks, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }

  # ===========================================================================
  # System administration

  namespace "admin" do
    get "/" => "dashboard#index", :as => :dashboard
    get "/stats" => "dashboard#stats"
    get "/stats/download" => 'dashboard#download_stats'
    resources :catalogs, :param => :slug, :except => [:index] do
      get "duplicate_new", on: :member
      post "duplicate", on: :member
      resources :api_logs, only: [:index], on: :member
      resources :entry_logs, only: [:index], on: :member
    end
    resources :template_storages, :except => :index
    resources :configurations, :only => :update
    resources :users, :except => :index
    resources :messages, :except => [:show]
  end

  root "home#index"
  get "/robots.txt", to: "home#robots", :as => :robots

  # ===========================================================================
  # Messages dismissal
  post '/messages/:id/dismiss', to: 'message_dismissals#create', as: :dismiss_message

  # ===========================================================================
  # Containers actions
  post '/contact', :to => 'container#contact'

  # ===========================================================================
  # Catalog administration

  namespace "catalog_admin", :path => ":catalog_slug/:locale/admin" do
    get "/" => "dashboard#setup", :as => :setup
    get "/_data" => "dashboard#data", :as => :data

    get "/_settings" => "catalogs#edit", :as => :settings
    get "/_api" => "catalogs#api", :as => :api
    patch "/_settings" => "catalogs#update"

    get "/_style" => "catalogs#edit_style", :as => :style
    patch "/_style" => "catalogs#update_style"

    get "/stats" => "catalogs#stats"

    resources :groups, path: '_groups' do
      resources :memberships
    end

    resources :api_keys, :only => [:create, :update, :destroy]

    resources :categories, :path => "_categories", :except => [:show] do
      resources :fields, :param => :slug, :except => :show
    end

    # Exports
    resources :exports, :path => "_exports", :except => [:edit, :show, :destroy, :update] do
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

    get "item_types/:item_types_id/geofields",
        :controller => :item_types,
        :action => :geofields,
        :as => "item_type_geofields"

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

    resources :choice_sets, :path => "_choice_sets", :except => :show do
      get :new_import, on: :collection
      get :new_choice_modal, on: :member
      post :export, on: :member
      resources :choices, :path => "_choices", :except => :show, on: :member do
        post 'update_positions' => "choices#update_positions", on: :collection
      end
    end
    post :import_choice_set, controller: 'choice_sets'

    resources :pages, :path => "_pages", :param => :slug do
      post :sort_field_select_options, on: :collection
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
        resources :suggestions, :only => [:destroy] do
          post :update_processed, on: :member, as: :update_processed
        end
      end
    end
    post ":item_type_slug/upload" => "items#upload", :as => 'item_file_upload'

    match ":item_type_slug/search/(:uuid)" => "items#search", :as => "simple_search", via: [:get, :post]
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
      if File.exist?(Rails.root.join('catalogs', catalog_slug, 'controllers', "#{catalog_snake_slug}_simple_searches_controller.rb"))
        get "search/simple/:uuid",
            :controller => "#{catalog_snake_slug}_simple_searches",
            :action => :show,
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
    # Route for simple search legacy URLs
    get "search", :to => "simple_searches#new"

    resources :simple_searches,
              :path => "search/simple",
              :param => :uuid,
              :only => [:new, :create, :show]

    resources :advanced_searches,
              :path => "search/advanced",
              :param => :uuid,
              :only => [:new, :create, :show]

    get ":slug" => "pages#show",
        :constraints => PagesController::Constraint,
        :as => :page

    get ':slug/:container_id/items_for_line/' => "pages#items_for_line",
        :constraints => PagesController::Constraint,
        :as => :page_items_for_line

    resources :items,
              :path => ":item_type_slug",
              :only => [:index, :show],
              :constraints => ItemsController::Constraint do
      resources :suggestions, :only => [:create]
    end

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

  match '/404', to: 'errors#error_404', :via => :all
  match '/422', to: 'errors#error_404', :via => :all
  match '/500', to: 'errors#error_500', :via => :all
  match '/505', to: 'errors#error_500', :via => :all
end
