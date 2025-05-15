import { NextRequest, NextResponse } from 'next/server';
import { ScheduleEntry } from './types';
import { GoogleGenerativeAI } from '@google/generative-ai';

// Initialize Gemini client
if (!process.env.GOOGLE_API_KEY) {
  console.error('GOOGLE_API_KEY is not set in environment variables');
}
console.log('API Key available:', !!process.env.GOOGLE_API_KEY); // Just logs true/false, not the actual key
const genAI = new GoogleGenerativeAI(process.env.GOOGLE_API_KEY || '');

async function processWithLLM(text: string): Promise<ScheduleEntry> {
  const model = genAI.getGenerativeModel({ model: "gemini-2.0-flash-lite" });
  const today = new Date();
  
  const prompt = `
    Today's date is: ${today.toISOString().split('T')[0]}
    Current time is: ${today.toLocaleTimeString('en-US', { hour12: false })}
    
    Convert the following natural language schedule description into a structured JSON format.
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

    JSON Structure:
    {
      "activity": "string, required, the main activity name, concise and clear",
      "type": "must be exactly 'recurring' or 'oneTime'",
      "datetime": "ISO string (e.g. '2025-05-21T19:00:00'), required only for oneTime events",
      "schedule": {
        "days": ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"],
        "startDateTime": "ISO string for first occurrence, required when start date/time is mentioned",
        "startTime": "24-hour format HH:mm, for daily pattern without specific start date",
        "endTime": "24-hour format HH:mm, for daily pattern without specific start date",
        "frequency": {
          "times": "number, how many times per period",
          "period": "must be exactly 'day', 'week', 'month', or 'year'"
        }
      },
      "dependsOn": {
        "activity": "string, name of the activity this depends on",
        "relation": "must be exactly 'before', 'after', or 'not_same_day'"
      }
    }

    Example inputs and outputs:
    Input: "gym twice a week starting next monday at 6pm for one hour"
    {
      "activity": "Gym",
      "type": "recurring",
      "schedule": {
        "frequency": {
          "times": 2,
          "period": "week"
        },
        "startDateTime": "2025-05-19T18:00:00",
        "endTime": "19:00"
      }
    }

    Input: "I want to go to the gym every Monday and Wednesday at 6pm for one hour"
    {
      "activity": "Gym",
      "type": "recurring",
      "schedule": {
        "days": ["monday", "wednesday"],
        "startTime": "18:00",
        "endTime": "19:00"
      }
    }

    Input: "Team meeting next Tuesday at 2pm"
    {
      "activity": "Team meeting",
      "type": "oneTime",
      "datetime": "2025-05-20T14:00:00"
    }

    Input: "Team meeting on May 21st 2025 at 2pm"
    {
      "activity": "Team meeting",
      "type": "oneTime",
      "datetime": "2025-05-21T14:00:00"
    }

    Input: "Lunch break at 12pm for 1 hour, must be after morning meeting"
    {
      "activity": "Lunch break",
      "type": "recurring",
      "schedule": {
        "startTime": "12:00",
        "endTime": "13:00"
      },
      "dependsOn": {
        "activity": "morning meeting",
        "relation": "after"
      }
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
    const entry = JSON.parse(cleanedContent) as ScheduleEntry;
    return entry;
  } catch (e) {
    throw new Error('Failed to parse LLM response into valid schedule entry');
  }
}

// Mock database
let scheduleEntries: ScheduleEntry[] = [];

export async function POST(req: NextRequest) {
  try {
    const { text } = await req.json();
    
    if (!process.env.GOOGLE_API_KEY) {
      return NextResponse.json({ 
        success: false, 
        message: 'Google API key not configured' 
      }, { status: 500 });
    }

    try {
      const entry = await processWithLLM(text);
      console.log('LLM Response:', entry); // Debug log
      scheduleEntries.push(entry);

      return NextResponse.json({ 
        success: true, 
        entries: [entry],
        message: 'Schedule processed successfully' 
      });
    } catch (error) {
      console.error('Error processing LLM response:', error);
      return NextResponse.json({ 
        success: false, 
        message: error instanceof Error ? error.message : 'Unknown error processing schedule',
        error: error instanceof Error ? error.stack : undefined
      }, { status: 500 });
    }
  } catch (error) {
    return NextResponse.json({ 
      success: false, 
      message: 'Failed to process schedule entry',
      error: error instanceof Error ? error.message : 'Unknown error'
    }, { status: 500 });
  }
}

export async function GET() {
  return NextResponse.json({ 
    success: true, 
    entries: scheduleEntries 
  });
}
