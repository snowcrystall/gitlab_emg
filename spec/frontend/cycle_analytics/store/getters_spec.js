import * as getters from '~/cycle_analytics/store/getters';
import {
  allowedStages,
  stageMedians,
  transformedProjectStagePathData,
  selectedStage,
  stageCounts,
} from '../mock_data';

describe('Value stream analytics getters', () => {
  describe('pathNavigationData', () => {
    it('returns the transformed data', () => {
      const state = { stages: allowedStages, medians: stageMedians, selectedStage, stageCounts };
      expect(getters.pathNavigationData(state)).toEqual(transformedProjectStagePathData);
    });
  });
});
