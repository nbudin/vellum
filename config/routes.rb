Vellum::Application.routes.draw do
  devise_for :people

  resources :projects
  scope 'projects/:project_id' do
    resources :doc_templates
    scope 'doc_templates/:doc_template_id' do
      resources :doc_template_attrs, :name_prefix => nil do
        collection do
          post :sort
        end
      end
    end

    resources :relationship_types
    resources :docs do
      member do
        post :copy
        put :revert
      end

      collection do
        post :sort
      end

      resources :doc_versions, path: "versions", only: [:index, :show]
    end

    resources :relationships
    resources :maps do
      collection do
        post :sort
      end
    end
    scope 'maps/:map_id' do
      resources :mapped_doc_templates
      resources :mapped_relationship_types
    end

    resources :publication_templates do
      member do
        get :test
        post :test
        get :publish
        post :publish
      end
    end

    resources :csv_exports
  end

  get '/about/settings' => 'about#edit_settings'
  patch '/about/settings' => 'about#update_settings'

  root :to => 'projects#index'
end
