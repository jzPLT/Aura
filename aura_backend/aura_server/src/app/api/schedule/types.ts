// Schedule-specific types and API interfaces

import { StaticEntry, DynamicEntry, ResultingEntry } from '../user/types';

export type Day = 'monday' | 'tuesday' | 'wednesday' | 'thursday' | 'friday' | 'saturday' | 'sunday';
export type TimePeriod = 'day' | 'week' | 'month' | 'year' | 'never';

// Combined schedule view for frontend
export interface ScheduleOverview {
  staticEntries: StaticEntry[];
  dynamicEntries: DynamicEntry[];
  resultingEntries: ResultingEntry[];
}

// For AI processing input
export interface ScheduleInput {
  userUid: string;
  originalText: string;
  timeRange?: {
    start?: string; // ISO date string
    end?: string;   // ISO date string
  };
}

// AI parsing result - what the LLM returns
export interface ParsedScheduleEntry {
  type: 'static' | 'dynamic';
  description: string;
  startingDatetime?: string;
  endingDatetime?: string;
  frequency?: {
    perPeriod: number;
    period: 'day' | 'week' | 'month' | 'year' | 'never';
  };
  dependency?: {
    name: string;
    type: 'before' | 'after' | 'during' | 'not_same_day' | 'same_day' | 'not_same_week' | 'same_week' | 'not_same_month' | 'same_month';
  };
}

// API response types
export interface ApiResponse<T> {
  success: boolean;
  data?: T;
  error?: string;
  message?: string;
}

export interface PaginatedResponse<T> {
  success: boolean;
  data: T[];
  pagination: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
}
