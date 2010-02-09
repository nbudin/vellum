class RelationshipType < ActiveRecord::Base
  belongs_to :project
  has_many :relationships, :dependent => :destroy
  belongs_to :left_template, :class_name => "DocTemplate"
  belongs_to :right_template, :class_name => "DocTemplate"
 
  validates_presence_of :left_template, :right_template, :project
  validate :check_templates_in_project

  def name
    real_name = read_attribute :name
    if real_name
      return real_name
    else
      return "Untitled relationship type"
    end
  end

  def description
    if read_attribute(:name)
      return name
    else
      return left_name
    end
  end

  def direction_of(template)
    if template == left_template
      :left
    elsif template == right_template
      :right
    else
      nil
    end
  end
  
  def same_template?
    left_template == right_template
  end

  def description_for(template, dir=nil)
    dir ||= direction_of template
    if dir == :left
      return left_description
    elsif dir == :right
      return right_description
    else
      return name
    end
  end

  def left_name
    if left_template and right_template and left_description
      "#{left_template.name} #{left_description} #{right_template.name}"
    elsif left_template and right_template
      "Untitled relationship type (#{left_template.name} to #{right_template.name})"
    else
      "Untitled relationship type"
    end
  end

  def right_name
    if left_template and right_template and right_description
      "#{right_template.name} #{right_description} #{left_template.name}"
    else
      left_name
    end
  end

  def other_template(template)
    dir = direction_of(template)
    if dir == :left
      right_template
    elsif dir == :right
      left_template
    else
      nil
    end
  end

  private
  def check_templates_in_project
    if project
      if left_template and left_template.project
        unless left_template.project == project
          errors.add("left_template", "is not in project #{project.name}")
        end
      end
  
      if right_template and right_template.project
        unless right_template.project == project
          errors.add("right_template", "is not in project #{project.name}")
        end
      end
    end
  end
end
