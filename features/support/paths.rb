module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name
    
    when /the home\s?page/
      '/'
    when /the projects page/
      projects_path
    when /the project page for (.*)/
      project_path(Project.find_by_name($1))
    when /the templates page for (.*)/
      doc_templates_path(Project.find_by_name($1))
    when /the maps page for (.*)/
      maps_path(Project.find_by_name($1))
    when /the template page for (.*)/
      tmpl = DocTemplate.find_by_name($1)
      doc_template_path(tmpl.project, tmpl)
    when /the doc page for (.*)/
      struct = Doc.find_by_name($1)
      doc_path(struct.project, struct)
    when /the map page for (.*)/
      map = Map.find_by_name($1)
      map_path(map.project, map)
    when /the login page/
      url_for(:controller => "auth", :action => "login", :only_path => true)
    
    # Add more mappings here.
    # Here is an example that pulls values out of the Regexp:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by_login($1))

    else
      raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
        "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(NavigationHelpers)
