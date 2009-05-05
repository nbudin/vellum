class JipeGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.directory "public/images/jipe"
      m.file 'edit-field.png', 'public/images/jipe/edit-field.png'
    end
  end
end
