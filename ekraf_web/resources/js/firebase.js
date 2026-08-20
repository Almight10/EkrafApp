// Bridge for Supabase DB integration (Replacing Firebase)
import { supabase, isSupabaseConfigured } from './supabase.js';

export const isFirebaseConfigured = isSupabaseConfigured;
export const db = supabase;
export { supabase, isSupabaseConfigured };
export default supabase;
