import { DEFAULT_DAYS_TO_DISPLAY } from '../constants';

export default () => ({
  id: null,
  features: {},
  endpoints: {},
  daysInPast: DEFAULT_DAYS_TO_DISPLAY,
  createdAfter: null,
  createdBefore: null,
  stages: [],
  summary: [],
  analytics: [],
  stats: [],
  valueStreams: [],
  selectedValueStream: {},
  selectedStage: {},
  selectedStageEvents: [],
  selectedStageError: '',
  medians: {},
  stageCounts: {},
  hasError: false,
  isLoading: false,
  isLoadingStage: false,
  isEmptyStage: false,
  permissions: {},
});