require 'test_helper'

class WorkflowTest < ActiveSupport::TestCase
  fixtures :workflows, :structure_templates, :projects, :workflow_steps, :workflow_transitions

  test "approve proposal" do
    fs = Structure.new :project => projects(:foobarcorp), :structure_template => structure_templates(:feature_spec)
    assert fs.save, fs.errors.full_messages.join("\n")

    assert status = fs.obtain_workflow_status
    assert status.workflow_step == workflow_steps(:draft)

    workflow_transitions(:submit).execute(fs)
    assert status.workflow_step == workflow_steps(:approval)

    workflow_transitions(:needs_work).execute(fs)
    assert status.workflow_step == workflow_steps(:draft)

    workflow_transitions(:submit).execute(fs)
    assert status.workflow_step == workflow_steps(:approval)

    workflow_transitions(:approve).execute(fs)
    assert status.workflow_step == workflow_steps(:approved)
  end
end
