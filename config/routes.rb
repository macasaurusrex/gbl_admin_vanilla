Rails.application.routes.draw do
  mount Blacklight::Engine => '/'
  mount BlacklightAdvancedSearch::Engine => '/'

  root to: "catalog#index"
  concern :searchable, Blacklight::Routes::Searchable.new

  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :searchable
  end

  concern :exportable, Blacklight::Routes::Exportable.new

  resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog' do
    concerns :exportable
  end

  resources :bookmarks do
    concerns :exportable

    collection do
      delete 'clear'
    end
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  # root "posts#index"
mount Geoblacklight::Engine => 'geoblacklight'
        concern :gbl_exportable, Geoblacklight::Routes::Exportable.new
        resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog' do
          concerns :gbl_exportable
        end
        concern :gbl_wms, Geoblacklight::Routes::Wms.new
        namespace :wms do
          concerns :gbl_wms
        end
        concern :gbl_downloadable, Geoblacklight::Routes::Downloadable.new
        namespace :download do
          concerns :gbl_downloadable
        end
        resources :download, only: [:show]
        ####################
        # GBL‡ADMIN

        # Bulk Actions
        resources :bulk_actions do
          patch :run, on: :member
          patch :revert, on: :member
        end

        # Users
        devise_for :users, skip: [:registrations]
        as :user do
          get "/sign_in" => "devise/sessions#new" # custom path to login/sign_in
          get "/sign_up" => "devise/registrations#new", :as => "new_user_registration" # custom path to sign_up/registration
          get "users/edit" => "devise/registrations#edit", :as => "edit_user_registration"
          put "users" => "devise/registrations#update", :as => "user_registration"
        end

        namespace :admin do
          # Root
          root to: "documents#index"

          # Assets
          # Note "assets" is Rails reserved word for routing, oops. So we use
          # asset_files.
          resources :assets, path: "asset_files" do
            collection do
              get "display_attach_form"
              post "attach_files"

              get "destroy_all"
              post "destroy_all"
            end

            post :sort, on: :collection
          end

          # Bulk Actions
          resources :bulk_actions do
            patch :run, on: :member
            patch :revert, on: :member
          end

          # Imports
          resources :imports do
            resources :mappings
            resources :import_documents, only: [:show]
            patch :run, on: :member
          end

          # Elements
          resources :elements do
            post :sort, on: :collection
          end

          # Form Elements
          resources :form_elements do
            post :sort, on: :collection
          end
          resources :form_header, path: :form_elements, controller: :form_elements
          resources :form_group, path: :form_elements, controller: :form_elements
          resources :form_control, path: :form_elements, controller: :form_elements
          resources :form_feature, path: :form_elements, controller: :form_elements

          # Reference Types
          resources :reference_types do
            post :sort, on: :collection
          end

          # Notifications
          resources :notifications do
            put "batch", on: :collection
          end

          # Users
          get "users/index"

          # Bookmarks
          resources :bookmarks
          delete "/bookmarks", to: "bookmarks#destroy", as: :bookmarks_destroy_by_fkeys

          # Search controller
          get "/search" => "search#index"
          
          # AdvancedSearch controller
          get '/advanced_search' => 'advanced_search#index', constraints: lambda { |req| req.format == :json }
          get '/advanced_search/facets' => 'advanced_search#facets', constraints: lambda { |req| req.format == :json }
          get '/advanced_search/facet/:id' => 'advanced_search#facet', constraints: lambda { |req| req.format == :json }, as: 'advanced_search_facet'

          # Ids controller
          get '/api/ids' => 'ids#index', constraints: lambda { |req| req.format == :json }
          get '/api' => 'api#index', constraints: lambda { |req| req.format == :json }
          get '/api/fetch' => 'api#fetch', constraints: lambda { |req| req.format == :json }
          get '/api/facet/:id' => 'api#facet', constraints: lambda { |req| req.format == :json }

          # Documents
          resources :documents do
            get "admin"
            get "versions"

            collection do
              get "fetch"
            end

            # DocumentAccesses
            resources :document_accesses, path: "access" do
              collection do
                get "import"
                post "import"

                get "destroy_all"
                post "destroy_all"
              end
            end

            # Document Assets
            resources :document_assets, path: "assets" do
              collection do
                get "display_attach_form"
                post "attach_files"

                get "destroy_all"
                post "destroy_all"
              end
            end

            # DocumentDownloads
            resources :document_downloads, path: "downloads" do
              collection do
                get "import"
                post "import"

                get "destroy_all"
                post "destroy_all"
              end
            end

            # Document References
            resources :document_distributions, path: "distributions" do
              collection do
                get "display_attach_form"
                post "attach_files"

                get "import"
                post "import"

                get "destroy_all"
                post "destroy_all"
              end
            end
          end

          # Document Accesses
          resources :document_accesses, path: "access" do
            collection do
              get "import"
              post "import"

              get "destroy_all"
              post "destroy_all"
            end
          end

          # Document Downloads
          resources :document_downloads, path: "downloads" do
            collection do
              get "import"
              post "import"

              get "destroy_all"
              post "destroy_all"
            end
          end

          # Document Distributions
          resources :document_distributions, path: "distributions" do
            collection do
              get "import"
              post "import"

              get "destroy_all"
              post "destroy_all"
            end
          end

          # Document Assets
          resources :document_assets, path: "assets" do
            collection do
              get "display_attach_form"
              post "attach_files"

              get "destroy_all"
              post "destroy_all"
            end
          end

          # Assets
          get "/asset_files/ingest", to: "assets#display_attach_form", as: "assets_ingest"
          post "/asset_files/ingest", to: "assets#attach_files"
          
          # DocumentAssets
          get "/documents/:id/ingest", to: "document_assets#display_attach_form", as: "asset_ingest"
          post "/documents/:id/ingest", to: "document_assets#attach_files"
          
          # Asset Direct Upload
          mount Kithe::AssetUploader.upload_endpoint(:cache) => "/direct_upload", :as => :direct_app_upload

          resources :collections, except: [:show]

          # Note "assets" is Rails reserved word for routing, oops. So we use
          # asset_files.
          resources :assets, path: "asset_files", except: [:new, :create] do
            member do
              put "convert_to_child_work"
            end
          end

          # @TODO
          # mount Qa::Engine => "/authorities"
          mount ActionCable.server => "/cable"

          # @TODO
          # authenticate :user, ->(user) { user } do
            # mount Blazer::Engine, at: "blazer"
          # end
        end
end
