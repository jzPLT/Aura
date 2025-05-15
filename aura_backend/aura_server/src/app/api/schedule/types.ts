export type Day = 'monday' | 'tuesday' | 'wednesday' | 'thursday' | 'friday' | 'saturday' | 'sunday';
export type TimePeriod = 'day' | 'week' | 'month' | 'year';

export interface ScheduleEntry {
  activity: string;
  type: 'recurring' | 'oneTime';
  // For one-time events
  datetime?: string;  // ISO datetime string
  // For recurring events
  schedule?: {
    days?: Day[];
    startDateTime?: string;  // ISO datetime string for first occurrence
    startTime?: string;   // HH:mm format for daily pattern
    endTime?: string;     // HH:mm format for daily pattern
    frequency?: {
      times: number;
      period: TimePeriod;
    };
  };
  // For activities that depend on other activities
  dependsOn?: {
    activity: string;
    relation: 'before' | 'after' | 'not_same_day';
  };
}
