class ConvertWorkflowsToSimpleAssignee < ActiveRecord::Migration
  class WorkflowStatus < ActiveRecord::Base
    belongs_to :assignee, :class_name => "Person"
    belongs_to :structure
    acts_as_versioned
  end

  class Structure < ActiveRecord::Base
    belongs_to :assignee, :class_name => "Person"
  end

  def self.up
    add_column :structures, :assignee_id, :integer

    WorkflowStatus.all.each do |status|
      if status.assignee && status.structure
        structure = status.structure
        structure.assignee = status.assignee
        structure.save!
      end
    end

    drop_table :workflow_status_versions
    drop_table :workflow_statuses
    drop_table :workflow_actions
    drop_table :workflow_transitions
    drop_table :workflows

    execute "DELETE FROM permissions WHERE permissioned_type = 'Workflow'"
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration.new
  end
end
