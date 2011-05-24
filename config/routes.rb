Vellum::Application.routes.draw do
  devise_for :people

  resources :projects do
    resources :doc_templates do
      resources :doc_template_attrs do
        collection do
          post :sort
        end
      end
    end

    resources :relationship_types
    resources :docs do
      collection do
        post :sort
      end
    end

    resources :relationships
    resources :maps do
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
  end

  root :to => 'projects#index'
  match '/:controller(/:action(/:id))'
  match ':controller/:action.:format' => '#index'
end