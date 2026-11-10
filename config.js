// WINter Fantasy settings (Supabase → Project Settings → API Keys).
// The anon key is meant to be public: the database rules in supabase/schema.sql
// decide what each signed-in person can read and change.
// Never put the service_role key here.
window.WINTER_CONFIG = {
  supabaseUrl: "https://pkftgdviovllansnswah.supabase.co",
  supabaseAnonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBrZnRnZHZpb3ZsbGFuc25zd2FoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTQzMzUwMjksImV4cCI6MjEwOTkxMTAyOX0.ZbCr5EwXIvreOEQsNV_7YBqHtKWyKZLj-y9C-IqYsF4",
};
