import { GoogleGenerativeAI } from '@google/generative-ai';

// Initialize Gemini client
if (!process.env.GOOGLE_API_KEY) {
  console.error('GOOGLE_API_KEY is not set in environment variables');
}
console.log('API Key available:', !!process.env.GOOGLE_API_KEY); // Just logs true/false, not the actual key
export const genAI = new GoogleGenerativeAI(process.env.GOOGLE_API_KEY || '');
