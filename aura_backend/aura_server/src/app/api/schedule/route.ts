import { NextRequest, NextResponse } from 'next/server';
import { processWithLLM } from './service';

export async function POST(req: NextRequest) {
  try {
    const { text } = await req.json();
    
    if (!text || typeof text !== 'string') {
      return NextResponse.json(
        { error: 'Text is required and must be a string' },
        { status: 400 }
      );
    }
    
    if (!process.env.GOOGLE_API_KEY) {
      return NextResponse.json({ 
        success: false, 
        message: 'Google API key not configured' 
      }, { status: 500 });
    }

    try {
      const parsedResponse = await processWithLLM(text);
      console.log('LLM Response:', parsedResponse); // Debug log

      return NextResponse.json({ 
        success: true, 
        data: parsedResponse,
        message: 'Schedule entries processed successfully' 
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
