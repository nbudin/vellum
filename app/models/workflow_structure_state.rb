class WorkflowStructureState < ActiveRecord::Base
  acts_as_versioned :foreign_key => "structure_state_id"
end
