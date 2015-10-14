module PageTitleHelper
  def page_title
    verbnoun = [noun_for_page_title, verb_for_page_title].compact.join(" ")
    [verbnoun, project_name_for_page_title].compact.join(" - ")
  end
  
  private
  
  def effective_single_object_for_page
    var_name = "@#{controller.controller_name.tableize.singularize}"
    if instance_variable_defined?(var_name)
      obj = instance_variable_get var_name
    else
      klass = controller.controller_name.classify.singularize.constantize rescue nil
      
      if klass.kind_of? Class and klass.respond_to? 'find'
        obj = klass.find(params[:id])
      end
    end
  end
  
  def generic_noun_for_page_title
    noun = controller.controller_name.humanize
    if controller.action_name == 'index'
      noun
    else
      noun.singularize
    end
  end
  
  def noun_for_page_title
    if params[:id]
      obj = effective_single_object_for_page
      if obj and obj.respond_to? 'name'
        return obj.name
      end
    end
    
    # fallback - we couldn't get the current object's name
    generic_noun_for_page_title
  end
  
  def verb_for_page_title
    case controller.action_name
    when 'edit' then 'Editing'
    when 'new' then 'New'
    end
  end
  
  def project_name_for_page_title
    project = if params[:project_id]
      if instance_variable_defined?(:@project)
        @project
      else
        Project.find(params[:project_id])
      end
    end
    
    project.try(:name)
  end
end