class Attr < ActiveRecord::Base
  belongs_to :structure_template
  acts_as_list :scope => :structure_template
  belongs_to :attr_configuration, :polymorphic => true, :dependent => :destroy
  has_many :attr_value_metadatas

  validates_uniqueness_of :name, :scope => :structure_template_id
  
  @@attr_classes = []
  def Attr.attr_classes
    return @@attr_classes
  end
  
  def Attr.register_attr_class(cls)
    @@attr_classes.push(cls)
  end
end

Attr.register_attr_class(TextField)
Attr.register_attr_class(NumberField)
Attr.register_attr_class(DocField)
