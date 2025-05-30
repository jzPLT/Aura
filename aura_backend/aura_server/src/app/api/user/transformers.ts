// Data transformation utilities between database rows and API types

import { 
  UserData, StaticEntry, DynamicEntry, ResultingEntry,
  UserRow, StaticEntryRow, DynamicEntryRow, ResultingEntryRow 
} from './types';

// User transformations
export function userRowToUserData(row: UserRow): UserData {
  return {
    uid: row.uid,
    email: row.email,
    displayName: row.display_name || undefined,
    preferencesTheme: row.preferences_theme || undefined,
    preferencesNotifications: row.preferences_notifications || undefined,
    defaultDurationForScheduling: row.default_duration_for_scheduling || undefined,
    createdAt: row.created_at.toISOString(),
    updatedAt: row.updated_at.toISOString(),
  };
}

// Alias for consistency with service usage
export const transformUserDbRowToUserData = userRowToUserData;

export function validateUserData(userData: Partial<UserData>): UserData {
  const errors: string[] = [];
  
  if (!userData.uid?.trim()) {
    errors.push('User UID is required');
  }
  
  if (!userData.email?.trim()) {
    errors.push('Email is required');
  } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(userData.email)) {
    errors.push('Valid email is required');
  }
  
  if (userData.preferencesTheme && !['light', 'dark', 'system'].includes(userData.preferencesTheme)) {
    errors.push('Theme must be light, dark, or system');
  }
  
  if (userData.defaultDurationForScheduling !== undefined && 
      (userData.defaultDurationForScheduling < 1 || userData.defaultDurationForScheduling > 1440)) {
    errors.push('Default duration must be between 1 and 1440 minutes');
  }
  
  if (errors.length > 0) {
    throw new Error(`Validation failed: ${errors.join(', ')}`);
  }
  
  return {
    uid: userData.uid!,
    email: userData.email!,
    displayName: userData.displayName,
    preferencesTheme: userData.preferencesTheme || 'dark',
    preferencesNotifications: userData.preferencesNotifications !== undefined ? userData.preferencesNotifications : true,
    defaultDurationForScheduling: userData.defaultDurationForScheduling || 30,
    createdAt: userData.createdAt || new Date().toISOString(),
    updatedAt: userData.updatedAt || new Date().toISOString(),
  };
}

export function userDataToUserRow(userData: UserData): Partial<UserRow> {
  return {
    uid: userData.uid,
    email: userData.email,
    display_name: userData.displayName || null,
    preferences_theme: userData.preferencesTheme || null,
    preferences_notifications: userData.preferencesNotifications || null,
    default_duration_for_scheduling: userData.defaultDurationForScheduling || null,
    updated_at: new Date(),
  };
}

// Static entry transformations
export function staticEntryRowToStaticEntry(row: StaticEntryRow): StaticEntry {
  return {
    id: row.id,
    userUid: row.user_uid,
    originalInputText: row.original_input_text || undefined,
    description: row.description,
    startingDatetime: row.starting_datetime?.toISOString(),
    endingDatetime: row.ending_datetime?.toISOString(),
    frequencyPerPeriod: row.frequency_per_period || undefined,
    frequencyPeriod: row.frequency_period as 'day' | 'week' | 'month' | 'year' | 'never',
    createdAt: row.created_at.toISOString(),
    updatedAt: row.updated_at.toISOString(),
    deletedAt: row.deleted_at?.toISOString(),
  };
}

export function staticEntryToStaticEntryRow(entry: StaticEntry): Partial<StaticEntryRow> {
  return {
    user_uid: entry.userUid,
    original_input_text: entry.originalInputText || null,
    description: entry.description,
    starting_datetime: entry.startingDatetime ? new Date(entry.startingDatetime) : null,
    ending_datetime: entry.endingDatetime ? new Date(entry.endingDatetime) : null,
    frequency_per_period: entry.frequencyPerPeriod || null,
    frequency_period: entry.frequencyPeriod,
    updated_at: new Date(),
  };
}

// Dynamic entry transformations
export function dynamicEntryRowToDynamicEntry(row: DynamicEntryRow): DynamicEntry {
  return {
    id: row.id,
    userUid: row.user_uid,
    originalInputText: row.original_input_text || undefined,
    descriptionOfEntry: row.description_of_entry,
    startingDatetime: row.starting_datetime?.toISOString(),
    endingDatetime: row.ending_datetime?.toISOString(),
    frequencyPerPeriod: row.frequency_per_period || undefined,
    frequencyPeriod: row.frequency_period as 'day' | 'week' | 'month' | 'year' | undefined,
    dependencyName: row.dependency_name || undefined,
    dependencyType: row.dependency_type as any || undefined,
    createdAt: row.created_at.toISOString(),
    updatedAt: row.updated_at.toISOString(),
    deletedAt: row.deleted_at?.toISOString(),
  };
}

export function dynamicEntryToDynamicEntryRow(entry: DynamicEntry): Partial<DynamicEntryRow> {
  return {
    user_uid: entry.userUid,
    original_input_text: entry.originalInputText || null,
    description_of_entry: entry.descriptionOfEntry,
    starting_datetime: entry.startingDatetime ? new Date(entry.startingDatetime) : null,
    ending_datetime: entry.endingDatetime ? new Date(entry.endingDatetime) : null,
    frequency_per_period: entry.frequencyPerPeriod || null,
    frequency_period: entry.frequencyPeriod || null,
    dependency_name: entry.dependencyName || null,
    dependency_type: entry.dependencyType || null,
    updated_at: new Date(),
  };
}

// Resulting entry transformations
export function resultingEntryRowToResultingEntry(row: ResultingEntryRow): ResultingEntry {
  return {
    id: row.id,
    userUid: row.user_uid,
    originStaticEntryId: row.origin_static_entry_id || undefined,
    originDynamicEntryId: row.origin_dynamic_entry_id || undefined,
    description: row.description,
    startingDatetime: row.starting_datetime.toISOString(),
    endingDatetime: row.ending_datetime.toISOString(),
    createdAt: row.created_at.toISOString(),
    updatedAt: row.updated_at.toISOString(),
    deletedAt: row.deleted_at?.toISOString(),
  };
}

export function resultingEntryToResultingEntryRow(entry: ResultingEntry): Partial<ResultingEntryRow> {
  return {
    user_uid: entry.userUid,
    origin_static_entry_id: entry.originStaticEntryId || null,
    origin_dynamic_entry_id: entry.originDynamicEntryId || null,
    description: entry.description,
    starting_datetime: new Date(entry.startingDatetime),
    ending_datetime: new Date(entry.endingDatetime),
    updated_at: new Date(),
  };
}

// Utility functions for common operations
export function isValidFrequencyPeriod(period: string): period is 'day' | 'week' | 'month' | 'year' | 'never' {
  return ['day', 'week', 'month', 'year', 'never'].includes(period);
}

export function isValidDependencyType(type: string): boolean {
  return ['before', 'after', 'during', 'not_same_day', 'same_day', 'not_same_week', 'same_week', 'not_same_month', 'same_month'].includes(type);
}

// Validation helpers
export function validateStaticEntry(entry: Partial<StaticEntry>): string[] {
  const errors: string[] = [];
  
  if (!entry.description?.trim()) {
    errors.push('Description is required');
  }
  
  if (!entry.frequencyPeriod || !isValidFrequencyPeriod(entry.frequencyPeriod)) {
    errors.push('Valid frequency period is required');
  }
  
  if (entry.startingDatetime && entry.endingDatetime) {
    const start = new Date(entry.startingDatetime);
    const end = new Date(entry.endingDatetime);
    if (start >= end) {
      errors.push('Starting datetime must be before ending datetime');
    }
  }
  
  return errors;
}

export function validateDynamicEntry(entry: Partial<DynamicEntry>): string[] {
  const errors: string[] = [];
  
  if (!entry.descriptionOfEntry?.trim()) {
    errors.push('Description is required');
  }
  
  if (entry.dependencyType && !isValidDependencyType(entry.dependencyType)) {
    errors.push('Invalid dependency type');
  }
  
  if (entry.dependencyType && !entry.dependencyName?.trim()) {
    errors.push('Dependency name is required when dependency type is specified');
  }
  
  if (entry.startingDatetime && entry.endingDatetime) {
    const start = new Date(entry.startingDatetime);
    const end = new Date(entry.endingDatetime);
    if (start >= end) {
      errors.push('Starting datetime must be before ending datetime');
    }
  }
  
  return errors;
}
