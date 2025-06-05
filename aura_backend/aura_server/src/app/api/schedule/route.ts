import { NextRequest, NextResponse } from 'next/server';
import { processWithLLM } from './service';
import { auth } from '@/lib/firebase/admin';
import { UserService } from '../user/service';
import { StaticEntry, DynamicEntry } from '../user/types';
import { ParsedScheduleEntry } from './types';

export async function POST(req: NextRequest) {
  try {
    // Get the Authorization header
    const authHeader = req.headers.get('Authorization');
    if (!authHeader?.startsWith('Bearer ')) {
      return NextResponse.json(
        { error: 'Missing or invalid authorization header' },
        { status: 401 }
      );
    }

    // Extract the token
    const idToken = authHeader.split('Bearer ')[1];

    try {
      // Verify the Firebase token
      const decodedToken = await auth.verifyIdToken(idToken);
      const userUid = decodedToken.uid;

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

        // Transform and save the LLM entries to database
        const savedEntries = {
          staticEntries: [] as StaticEntry[],
          dynamicEntries: [] as DynamicEntry[]
        };

        for (const entry of parsedResponse.entries) {
          if (entry.type === 'static') {
            // Transform ParsedScheduleEntry to StaticEntry format
            const staticEntry: Omit<StaticEntry, 'id' | 'createdAt' | 'updatedAt'> = {
              userUid,
              originalInputText: parsedResponse.originalText,
              description: entry.description,
              startingDatetime: entry.startingDatetime,
              endingDatetime: entry.endingDatetime,
              frequencyPerPeriod: entry.frequency?.perPeriod,
              frequencyPeriod: entry.frequency?.period || 'never'
            };

            const savedStaticEntry = await UserService.createStaticEntry(staticEntry);
            savedEntries.staticEntries.push(savedStaticEntry);
            console.log(`✅ Saved static entry: ${savedStaticEntry.id} - ${savedStaticEntry.description}`);

          } else if (entry.type === 'dynamic') {
            // Transform ParsedScheduleEntry to DynamicEntry format
            const dynamicEntry: Omit<DynamicEntry, 'id' | 'createdAt' | 'updatedAt'> = {
              userUid,
              originalInputText: parsedResponse.originalText,
              descriptionOfEntry: entry.description,
              startingDatetime: entry.startingDatetime,
              endingDatetime: entry.endingDatetime,
              frequencyPerPeriod: entry.frequency?.perPeriod,
              frequencyPeriod: entry.frequency?.period === 'never' ? undefined : entry.frequency?.period,
              dependencyName: entry.dependency?.name,
              dependencyType: entry.dependency?.type
            };

            const savedDynamicEntry = await UserService.createDynamicEntry(dynamicEntry);
            savedEntries.dynamicEntries.push(savedDynamicEntry);
            console.log(`✅ Saved dynamic entry: ${savedDynamicEntry.id} - ${savedDynamicEntry.descriptionOfEntry}`);
          }
        }

        return NextResponse.json({ 
          success: true, 
          data: {
            originalText: parsedResponse.originalText,
            savedEntries,
            totalEntries: savedEntries.staticEntries.length + savedEntries.dynamicEntries.length
          },
          message: `Successfully processed and saved ${savedEntries.staticEntries.length + savedEntries.dynamicEntries.length} schedule entries` 
        });
      } catch (error) {
        console.error('Error processing LLM response or saving entries:', error);
        return NextResponse.json({ 
          success: false, 
          message: error instanceof Error ? error.message : 'Unknown error processing schedule',
          error: error instanceof Error ? error.stack : undefined
        }, { status: 500 });
      }
    } catch (error) {
      console.error('Token verification failed:', error);
      return NextResponse.json(
        { error: 'Invalid authentication token' },
        { status: 401 }
      );
    }
  } catch (error) {
    console.error('Error processing request:', error);
    return NextResponse.json({ 
      success: false, 
      message: 'Failed to process schedule entry',
      error: error instanceof Error ? error.message : 'Unknown error'
    }, { status: 500 });
  }
}
