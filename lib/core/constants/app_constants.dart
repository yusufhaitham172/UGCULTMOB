/// Global App Constants & Config
abstract final class AppConstants {
  static const String appName = 'UGCULT';
  static const String appVersion = '1.0.0';

  // Supabase Project Ref: yobkcmhedovixvbqokza
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://yobkcmhedovixvbqokza.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlvYmtjbWhlZG92aXh2YnFva3phIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTAzMzM2MjUsImV4cCI6MjEwNTkwOTYyNX0.vf6U_XATY_pfrYfd1z_FDZz27zpWwOz8fo1vxg90_-Y',
  );

  // Sentry DSN (optional at runtime; no-op if empty)
  static const String sentryDsn = String.fromEnvironment(
    'SENTRY_DSN',
    defaultValue: '',
  );

  // Storage Bucket Identifiers
  static const String bucketPortfolios = 'portfolios';
  static const String bucketSubmissions = 'submissions';
  static const String bucketAvatars = 'avatars';
  static const String bucketCampaignCovers = 'campaign-covers';
}
