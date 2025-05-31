import { ParsedScheduleEntry, ParsedScheduleResponse } from './types';
import { genAI } from '@/lib/llm/client';

export async function processWithLLM(text: string): Promise<ParsedScheduleResponse> {
  const model = genAI.getGenerativeModel({ model: "gemini-2.0-flash-lite" });
  const today = new Date();
  
  const prompt = `
    Today's date is: ${today.toISOString().split('T')[0]}
    Current time is: ${today.toLocaleTimeString('en-US', { hour12: false })}
    
    Convert the following natural language schedule description into structured JSON format.
    When processing relative dates (e.g., "next Tuesday", "tomorrow", "in 2 days"):
    - Use the current date above as reference
    - Always convert to specific dates in ISO format
    - For recurring events that start from a relative date, use that date as the first occurrence
    
    Requirements:
    1. ONLY output the JSON object, no additional text or explanations
    2. DO NOT include any fields that aren't explicitly mentioned in the input
    3. Use EXACTLY the structure and field names shown in the example
    4. All string fields must match the exact values shown in the examples
    5. Do not invent or assume any information not present in the input
    6. Return an array of entries if multiple activities are mentioned
    7. **CRITICAL**: If an activity has a specific time (like "at 2pm", "at 9am"), DO NOT include a dependency field even if dependency words (like "after", "before") are mentioned
    
    JSON Structure:
    {
      "entries": [
        {
          "type": "static or dynamic - static for fixed recurring patterns, dynamic for flexible goals/tasks",
          "description": "string, required, the main activity name, concise and clear",
          "startingDatetime": "ISO string (e.g. '2025-05-21T19:00:00'), optional, only if specific start time mentioned",
          "endingDatetime": "ISO string (e.g. '2025-05-21T20:00:00'), optional, only if specific end time mentioned",
          "frequency": {
            "perPeriod": "number, how many times per period (e.g., 2 for 'twice a week')",
            "period": "must be exactly 'day', 'week', 'month', 'year', or 'never'"
          },
          "dependency": {
            "name": "string, name of the activity this depends on",
            "type": "must be exactly 'before', 'after', 'during', 'not_same_day', 'same_day', 'not_same_week', 'same_week', 'not_same_month', 'same_month'"
          }
        }
      ]
    }

    🚨 CRITICAL RULE: If an activity mentions BOTH a specific time (like "at 1pm", "at 9am") AND a dependency word (like "after", "before"), classify it as "static" and DO NOT include the dependency field. Specific times always take precedence over dependencies.

    Entry Type Guidelines:
    - Use "static" for:
      * Events with specific scheduled times and dates (appointments, meetings with fixed times like "at 2pm", "at 9am")
      * Regular recurring events with fixed patterns and specific times (daily standup at 9am)
      * Any activity that has a specific datetime, even if it's one-time
      * Activities with consistent frequency AND specific timing
    
    - Use "dynamic" for:
      * Goals or tasks with flexible scheduling (exercise 3 times a week, but timing flexible)
      * Activities that need to fit around other commitments without specific times
      * Tasks with frequency requirements but no fixed schedule or time specified
      * Activities with dependencies but NO specific time mentioned (like "meeting after lunch break")

    CRITICAL RULES: 
    1. If an activity has BOTH a specific time (like "at 1pm", "at 9am") AND mentions a dependency, classify it as "static" and DO NOT include the dependency field
    2. If an activity has a dependency but NO specific time, classify it as "dynamic" and INCLUDE the dependency field

    Frequency Guidelines:
    - "every weekday" = 5 times per week (Monday through Friday)
    - "daily" = 1 time per day
    - "weekly" = 1 time per week
    - "twice a week" = 2 times per week
    - "3 times per week" = 3 times per week
    - For "after work" dependencies, only include if work hours/schedule is mentioned

    Example inputs and outputs:
    
    Input: "gym twice a week starting next monday at 6pm for one hour"
    {
      "entries": [{
        "type": "static",
        "description": "Gym",
        "startingDatetime": "2025-06-02T18:00:00",
        "endingDatetime": "2025-06-02T19:00:00",
        "frequency": {
          "perPeriod": 2,
          "period": "week"
        }
      }]
    }

    Input: "Team meeting every Monday at 2pm and doctor appointment next Tuesday at 10am"
    {
      "entries": [
        {
          "type": "static",
          "description": "Team meeting",
          "startingDatetime": "2025-06-02T14:00:00",
          "frequency": {
            "perPeriod": 1,
            "period": "week"
          }
        },
        {
          "type": "static",
          "description": "Doctor appointment",
          "startingDatetime": "2025-06-03T10:00:00"
        }
      ]
    }

    Input: "I want to exercise 3 times a week and have a dentist appointment on Friday at 2pm"
    {
      "entries": [
        {
          "type": "dynamic",
          "description": "Exercise",
          "frequency": {
            "perPeriod": 3,
            "period": "week"
          }
        },
        {
          "type": "static",
          "description": "Dentist appointment",
          "startingDatetime": "2025-06-06T14:00:00"
        }
      ]
    }

    Input: "Standup meeting every weekday at 9am for 30 minutes"
    {
      "entries": [{
        "type": "static",
        "description": "Standup meeting",
        "startingDatetime": "2025-06-02T09:00:00",
        "endingDatetime": "2025-06-02T09:30:00",
        "frequency": {
          "perPeriod": 5,
          "period": "week"
        }
      }]
    }

    Input: "Daily standup meeting at 9am, lunch break at 12pm for 1 hour after standup, and exercise 3 times per week"
    {
      "entries": [
        {
          "type": "static",
          "description": "Daily standup meeting",
          "startingDatetime": "2025-06-01T09:00:00",
          "frequency": {
            "perPeriod": 1,
            "period": "day"
          }
        },
        {
          "type": "static",
          "description": "Lunch break",
          "startingDatetime": "2025-06-01T12:00:00",
          "endingDatetime": "2025-06-01T13:00:00",
          "frequency": {
            "perPeriod": 1,
            "period": "day"
          },
          "dependency": {
            "name": "Daily standup meeting",
            "type": "after"
          }
        },
        {
          "type": "dynamic",
          "description": "Exercise",
          "frequency": {
            "perPeriod": 3,
            "period": "week"
          }
        }
      ]
    }

    Input: "Quarterly review meeting every 3 months starting next month"
    {
      "entries": [{
        "type": "static",
        "description": "Quarterly review meeting",
        "startingDatetime": "2025-07-01T00:00:00",
        "frequency": {
          "perPeriod": 1,
          "period": "month"
        }
      }]
    }

    Input: "Lunch break at 12pm for 1 hour, must be after morning meeting, and gym session 3 times per week"
    {
      "entries": [
        {
          "type": "static",
          "description": "Lunch break",
          "startingDatetime": "2025-06-01T12:00:00",
          "endingDatetime": "2025-06-01T13:00:00",
          "frequency": {
            "perPeriod": 1,
            "period": "day"
          }
        },
        {
          "type": "dynamic",
          "description": "Gym session",
          "frequency": {
            "perPeriod": 3,
            "period": "week"
          }
        }
      ]
    }

    Input: "Team sync at 3pm after standup every Tuesday"
    {
      "entries": [{
        "type": "static",
        "description": "Team sync",
        "startingDatetime": "2025-06-03T15:00:00",
        "frequency": {
          "perPeriod": 1,
          "period": "week"
        }
      }]
    }

    Input: "Meeting after lunch break every Tuesday"
    {
      "entries": [{
        "type": "dynamic",
        "description": "Meeting",
        "frequency": {
          "perPeriod": 1,
          "period": "week"
        },
        "dependency": {
          "name": "lunch break",
          "type": "after"
        }
      }]
    }

    Now, parse this input into the exact same format:
    ${text}
  `;

  const result = await model.generateContent(prompt);
  const response = await result.response;
  const content = response.text();

  try {
    // Clean the response text to ensure it's valid JSON
    const cleanedContent = content.replace(/```json\n?|\n?```/g, '').trim();
    const parsedResponse = JSON.parse(cleanedContent) as ParsedScheduleResponse;
    
    // Add the original text for context
    parsedResponse.originalText = text;
    
    return parsedResponse;
  } catch (e) {
    console.error('Failed to parse LLM response:', e);
    console.error('Raw response:', content);
    throw new Error('Failed to parse LLM response into valid schedule entries');
  }
}
