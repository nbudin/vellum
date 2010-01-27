ActionController::Routing::Routes.draw do |map|
  map.resources :workflows do |workflows|
    workflows.resources :workflow_steps, :name_prefix => nil, :collection => { :sort => :post } do |steps|
      steps.resources :workflow_transitions, :name_prefix => nil do |transitions|
        transitions.resources :workflow_actions, :name_prefix => nil, :collection => { :sort => :post }
      end
    end
  end

  map.resources :projects do |projects|
    projects.resources :structure_templates, :name_prefix => nil do |templates|
      templates.resources :attrs, :collection => { :sort => :post }, :name_prefix => nil
    end
    projects.resources :relationship_types, :name_prefix => nil
    projects.resources :structures, :name_prefix => nil, :collection => { :sort => :post }, 
                       :member => { :transition => :post } do |structures|
      structures.resources :doc_values, :name_prefix => nil do |doc_values|
        doc_values.resources :versions, :controller => 'DocValueVersions', :name_prefix => 'doc_value_'
      end
    end
    projects.resources :relationships, :name_prefix => nil
    projects.resources :maps, :name_prefix => nil, :collection => { :sort => :post } do |maps|
      maps.resources :mapped_structure_templates, :name_prefix => nil
      maps.resources :mapped_relationship_types, :name_prefix => nil
    end
  end

  map.connect('projects/:project_id/structure_templates/:structure_template_id/attrs/:id/config.:format',
              :conditions => { :method => :get },
              :controller => 'attrs',
              :action => 'show_config')
              
  map.connect('projects/:project_id/structure_templates/:structure_template_id/attrs/:id/config.:format',
              :conditions => { :method => :put },
              :controller => 'attrs',
              :action => 'update_config')
              

  # The priority is based upon order of creation: first created -> highest priority.
  
  # Sample of regular route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  # map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  AeUsers.map_openid(map)
  
  # You can have the root of your site routed by hooking up '' 
  # -- just remember to delete public/index.html.
  map.root :controller => "projects"

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  map.connect ':controller/service.wsdl', :action => 'wsdl'

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action.:format'
end
