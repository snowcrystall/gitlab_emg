# frozen_string_literal: true

require 'spec_helper'

RSpec.describe HasIntegrations do
  let_it_be(:project_1) { create(:project) }
  let_it_be(:project_2) { create(:project) }
  let_it_be(:project_3) { create(:project) }
  let_it_be(:project_4) { create(:project) }
  let_it_be(:instance_integration) { create(:jira_integration, :instance) }

  before do
    create(:jira_integration, project: project_1, inherit_from_id: instance_integration.id)
    create(:jira_integration, project: project_2, inherit_from_id: nil)
    create(:jira_integration, group: create(:group), project: nil, inherit_from_id: nil)
    create(:jira_integration, project: project_3, inherit_from_id: nil)
    create(:integrations_slack, project: project_4, inherit_from_id: nil)
  end

  describe '.without_integration' do
    it 'returns projects without integration' do
      expect(Project.without_integration(instance_integration)).to contain_exactly(project_4)
    end
  end
end
