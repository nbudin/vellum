ActionController::Routing::Routes.draw do |map|
  map.resources :workflows

  map.resources :projects do |projects|
    projects.resources :structures, :name_prefix => nil
    projects.resources :relationships, :name_prefix => nil
    projects.resources :docs, :name_prefix => nil
  end
  
  map.resources :template_schemas do |schemas|
    schemas.resources :structure_templates, :name_prefix => nil do |templates|
      templates.resources :attrs, :collection => { :sort => :post }, :name_prefix => nil
    end
    schemas.resources :relationship_types, :name_prefix => nil
  end

  map.connect('template_schemas/:template_schema_id/structure_templates/:structure_template_id/attrs/:id/config.:format',
              :conditions => { :method => :get },
              :controller => 'attrs',
              :action => 'show_config')
              
  map.connect('template_schemas/:template_schema_id/structure_templates/:structure_template_id/attrs/:id/config.:format',
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
