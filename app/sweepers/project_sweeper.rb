class ProjectSweeper < ActionController::Caching::Sweeper
  observe Project, Doc
  
  def after_save(record)
    project = record.is_a?(Project) ? record : record.project
    expire_fragment(project_path(project))
  end
end