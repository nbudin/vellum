require File.dirname(__FILE__) + '/../test_helper'

class StructureTest < ActiveSupport::TestCase
  fixtures :structures, :structure_templates, :text_fields, :relationship_types, :projects, :attrs
  
  context "A new structure" do
    setup do
      @structure_template = Factory.create(:structure_template)
      @project = Factory.create(:project, :template_schema => @structure_template.template_schema)
      @bob = Factory.build(:structure, :structure_template => @structure_template, :project => @project, :name => "Bob")
    end

    should_belong_to :assignee
    
    should "save cleanly" do
      assert @bob.save
    end
    
    should "return the right value for name" do
      assert_equal "Bob", @bob.name
    end

    should "not start out assigned to anyone" do
      assert_nil @bob.assignee
    end
    
    context "with an attr" do
      setup do
        assert @bob.save
  
        @attr_configuration = TextField.create
        @attr_name = "Favorite Color"
        @attr = @bob.structure_template.attrs.create(:name => @attr_name, :attr_configuration => @attr_configuration)
        @bob.reload
      end
      
      should "create attr instances in memory on obtain_attr" do
        assert attr = @bob.obtain_attr(@attr_name)
        assert @bob.attrs.include?(attr), "attr doesn't appear in @bob.attrs"
        assert_equal attr, @bob.attr(@attr_name)
      end
    
      should "return the same attr on subsequent obtains" do
        assert attr = @bob.obtain_attr(@attr_name)
        assert_equal attr, @bob.obtain_attr(@attr_name)
      end
      
      should "create AVM instances in memory on obtain_avm_for_attr" do
        assert avm = @bob.obtain_avm_for_attr(@attr_name)
        assert @bob.attr_value_metadatas.include?(avm)
      end
      
      should "return the same AVM instance on subsequent obtains" do
        assert avm = @bob.obtain_avm_for_attr(@attr_name)
        assert_equal avm, @bob.obtain_avm_for_attr(@attr_name)
      end
      
      should "create attr value instances in memory on obtain_attr_value" do
        assert av = @bob.obtain_attr_value(@attr_name)
        assert @bob.attr_values.include?(av), "av doesn't appear in @bob.attr_values"
        assert_equal av, @bob.attr_value(@attr_name)
      end
      
      should "return the same attr_value instance on subsequent obtains" do
        assert av = @bob.obtain_attr_value(@attr_name)
        av.value = "Green"
        assert av2 = @bob.obtain_attr_value(@attr_name)
        assert_equal av, av2
        assert_equal av.value, av2.value
      end
      
      context "having a value" do
        setup do          
          assert @attr_value = @bob.obtain_attr_value(@attr_name)
        end
          
        should "return the right value for attr_value.value" do
          @attr_value.value = "Yellow"
          assert_equal "Yellow", @bob.attr_value(@attr_name).value
        end
      end
    end
    
    context "with a related structure" do
      setup do
        assert @bob.save
        
        @rt = @structure_template.template_schema.relationship_types.create(:left_template => @structure_template,
                                                                            :right_template => @structure_template)
        
        assert @joe = @project.structures.create(:structure_template => @structure_template)
        assert @r = Factory.create(:relationship, :relationship_type => @rt, :left => @joe, :right => @bob, :project => @project)
      end
      
      should "show the relationship on both structures" do
        assert @r.save
        @bob.reload
        assert @bob.inward_relationships.include?(@r), "@r doesn't show up on Bob's inward relationships"
        assert @bob.relationships.include?(@r), "@r doesn't show up on Bob's inward relationships"
        
        @joe.reload
        assert @joe.outward_relationships.include?(@r), "@r doesn't show up on Joe's outward relationships"
        assert @joe.relationships.include?(@r), "@r doesn't show up on Joe's inward relationships"
      end
    end
  end
end
