import { NextRequest, NextResponse } from 'next/server';
import { ScheduleEntry } from './types';
import { processWithLLM } from './service';

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
