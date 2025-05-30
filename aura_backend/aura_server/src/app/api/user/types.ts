// User data matching the database schema
export interface UserData {
  uid: string;
  email: string;
  displayName?: string;
  preferencesTheme?: string;
  preferencesNotifications?: boolean;
  defaultDurationForScheduling?: number; // Default duration in minutes
  createdAt: string;  // ISO date string
  updatedAt: string;  // ISO date string
}

// Static entries - recurring patterns or fixed events
export interface StaticEntry {
  id?: number;
  userUid: string;
  originalInputText?: string;
  description: string;
  startingDatetime?: string; // ISO date string
  endingDatetime?: string;   // ISO date string
  frequencyPerPeriod?: number; // e.g., 2 times
  frequencyPeriod: 'day' | 'week' | 'month' | 'year' | 'never';
  createdAt?: string;
  updatedAt?: string;
  deletedAt?: string;
}

// Dynamic entries - flexible tasks/goals to be scheduled
export interface DynamicEntry {
  id?: number;
  userUid: string;
  originalInputText?: string;
  descriptionOfEntry: string;
  startingDatetime?: string; // Optional preferred start
  endingDatetime?: string;   // Optional preferred end
  frequencyPerPeriod?: number; // e.g., 2 times for "run 2 times a week"
  frequencyPeriod?: 'day' | 'week' | 'month' | 'year';
  dependencyName?: string;
  dependencyType?: 'before' | 'after' | 'during' | 'not_same_day' | 'same_day' | 'not_same_week' | 'same_week' | 'not_same_month' | 'same_month';
  createdAt?: string;
  updatedAt?: string;
  deletedAt?: string;
}

// Resulting entries - concrete scheduled instances on calendar
export interface ResultingEntry {
  id?: number;
  userUid: string;
  originStaticEntryId?: number;
  originDynamicEntryId?: number;
  description: string;
  startingDatetime: string; // ISO date string
  endingDatetime: string;   // ISO date string
  createdAt?: string;
  updatedAt?: string;
  deletedAt?: string;
}

// Request/Response types for API
export interface CreateStaticEntryRequest {
  originalInputText?: string;
  description: string;
  startingDatetime?: string;
  endingDatetime?: string;
  frequencyPerPeriod?: number;
  frequencyPeriod: 'day' | 'week' | 'month' | 'year' | 'never';
}

export interface CreateDynamicEntryRequest {
  originalInputText?: string;
  descriptionOfEntry: string;
  startingDatetime?: string;
  endingDatetime?: string;
  frequencyPerPeriod?: number;
  frequencyPeriod?: 'day' | 'week' | 'month' | 'year';
  dependencyName?: string;
  dependencyType?: 'before' | 'after' | 'during' | 'not_same_day' | 'same_day' | 'not_same_week' | 'same_week' | 'not_same_month' | 'same_month';
}

export interface UpdateUserRequest {
  displayName?: string;
  preferencesTheme?: string;
  preferencesNotifications?: boolean;
  defaultDurationForScheduling?: number;
}

// Schedule query parameters
export interface ScheduleQuery {
  startDate?: string; // ISO date string
  endDate?: string;   // ISO date string
  includeStatic?: boolean;
  includeDynamic?: boolean;
  includeResulting?: boolean;
}

// Database row types (matching SQL column names exactly)
export interface UserRow {
  uid: string;
  email: string;
  display_name: string | null;
  preferences_theme: string | null;
  preferences_notifications: boolean | null;
  default_duration_for_scheduling: number | null;
  created_at: Date;
  updated_at: Date;
}

export interface StaticEntryRow {
  id: number;
  user_uid: string;
  original_input_text: string | null;
  description: string;
  starting_datetime: Date | null;
  ending_datetime: Date | null;
  frequency_per_period: number | null;
  frequency_period: string;
  created_at: Date;
  updated_at: Date;
  deleted_at: Date | null;
}

export interface DynamicEntryRow {
  id: number;
  user_uid: string;
  original_input_text: string | null;
  description_of_entry: string;
  starting_datetime: Date | null;
  ending_datetime: Date | null;
  frequency_per_period: number | null;
  frequency_period: string | null;
  dependency_name: string | null;
  dependency_type: string | null;
  created_at: Date;
  updated_at: Date;
  deleted_at: Date | null;
}

export interface ResultingEntryRow {
  id: number;
  user_uid: string;
  origin_static_entry_id: number | null;
  origin_dynamic_entry_id: number | null;
  description: string;
  starting_datetime: Date;
  ending_datetime: Date;
  created_at: Date;
  updated_at: Date;
  deleted_at: Date | null;
}

// Alias for consistency with service usage
export type UserDbRow = UserRow;
