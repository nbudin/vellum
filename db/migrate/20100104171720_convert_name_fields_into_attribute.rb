class ConvertNameFieldsIntoAttribute < ActiveRecord::Migration
  def self.up
    add_column :structures, :name, :string
    
    say "Saving generated names for structures"
    Structure.all.each do |s|
      s.name = s.generated_name
      s.save!
    end
    
    say "Destroying existing name attrs"
    StructureTemplate.all(:include => :attrs).each do |t|
      name_attr = t.attr("Name")
      next if name_attr.nil?
      
      name_attr.attr_value_metadatas.destroy_all
      name_attr.destroy
    end
  end

  def self.down
    StructureTemplate.all.each do |t|
      say "Converting name field into explicit attribute for all #{t.plural_name}"
      
      name_attr = t.attrs.create(:name => "Name")
      name_attr.attr_configuration = TextField.new(:attr => name_attr)
      name_attr.save!
      
      t.structures.all.each do |s|
        avm = s.obtain_avm_for_attr(name_attr)
        avm.save!
        
        av = avm.obtain_value
        av.value = s.name
        av.save!
      end
    end
    
    remove_column :structures, :name
  end
end
