class RelationshipType < ActiveRecord::Base
  belongs_to :template_schema
  has_many :relationships, :dependent => :destroy
  belongs_to :left_template, :class_name => "StructureTemplate"
  belongs_to :right_template, :class_name => "StructureTemplate"
 
  validates_presence_of :left_template, :right_template, :template_schema
  validate :check_templates_in_schema

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

  def left_name
    if left_template and right_template and right_description
      "#{left_template.name} #{left_description} #{right_template.name}"
    elsif left_template and right_template
      "Untitled relationship type (#{left_template.name} to #{right_template.name})"
    else
      "Untitled relationship type"
    end
  end

  def right_name
    if right_description
      "#{right_template.name} #{right_description} #{left_template.name}"
    else
      left_name
    end
  end

  private
  def check_templates_in_schema
    if left_template
      unless left_template.template_schema == template_schema
        errors.add("left_template", "is not in template schema #{template_schema.name}")
      end
    end

    if right_template
      unless right_template.template_schema == template_schema
        errors.add("right_template", "is not in template schema #{template_schema.name}")
      end
    end
  end
end
