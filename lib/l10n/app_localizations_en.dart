// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'LeadForge';

  @override
  String get aiPoweredLeadGen => 'AI-powered lead generation';

  @override
  String get signIn => 'Sign In';

  @override
  String get signUp => 'Sign Up';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get alreadyHaveAccount => 'Already have an account? Sign In';

  @override
  String get dontHaveAccount => 'Don\'t have an account? Sign Up';

  @override
  String get continueWithApple => 'Continue with Apple';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get enterValidEmail => 'Enter a valid email address';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get emailSent => 'Email Sent';

  @override
  String passwordResetSent(String email) {
    return 'Password reset link sent to $email. Check your inbox.';
  }

  @override
  String get enterEmailFirst => 'Please enter your email address';

  @override
  String get ok => 'OK';

  @override
  String get or => 'OR';

  @override
  String get scout => 'Scout';

  @override
  String get pipeline => 'Pipeline';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get settings => 'Settings';

  @override
  String get searchBusinesses => 'Search businesses...';

  @override
  String get suggestedNiches => 'Suggested Niches';

  @override
  String searchesRemaining(int count) {
    return '$count searches remaining';
  }

  @override
  String get businessDetail => 'Business Detail';

  @override
  String get analyzeBusiness => 'Analyze Business';

  @override
  String get aiAnalysis => 'AI Analysis';

  @override
  String get generateDemo => 'Generate Demo';

  @override
  String get createMessage => 'Create Message';

  @override
  String get businessNotFound => 'Business not found';

  @override
  String get checkingWebsite => 'Checking website...';

  @override
  String get analyzingReviews => 'Analyzing reviews...';

  @override
  String get calculatingScore => 'Calculating score...';

  @override
  String get buildDemoSite => 'Build Demo Site';

  @override
  String get createDemoFor => 'Create a demo website for';

  @override
  String get chooseTemplate => 'Choose Template';

  @override
  String get generateDemoSite => 'Generate Demo Site';

  @override
  String get demoSiteCreated => 'Demo Site Created!';

  @override
  String get shareWithProspect => 'Share this link with your prospect';

  @override
  String get linkCopied => 'Link copied to clipboard';

  @override
  String get share => 'Share';

  @override
  String get open => 'Open';

  @override
  String get demoLimitReached => 'Demo Limit Reached';

  @override
  String get demoLimitMessage =>
      'You\'ve used your free demo this month. Upgrade to Pro for unlimited demos.';

  @override
  String get maybeLater => 'Maybe Later';

  @override
  String get upgradeToPro => 'Upgrade to Pro';

  @override
  String get createOutreachMessage => 'Create Outreach Message';

  @override
  String get generateMessageFor => 'Generate message for';

  @override
  String get outreachChannel => 'Outreach Channel';

  @override
  String get tone => 'Tone';

  @override
  String get generateMessage => 'Generate Message';

  @override
  String get messageGenerated => 'Message Generated';

  @override
  String get regenerate => 'Regenerate';

  @override
  String get copy => 'Copy';

  @override
  String get messageCopied => 'Message copied to clipboard';

  @override
  String get proFeature => 'Pro Feature';

  @override
  String get proFeatureMessage => 'AI message generation is a Pro feature.';

  @override
  String get upgradeForPro => 'Upgrade to Pro for:';

  @override
  String get unlimitedAiMessages => 'Unlimited AI messages';

  @override
  String get fourChannels => '4 outreach channels';

  @override
  String get threeTones => '3 tone options';

  @override
  String get bilingual => 'Bilingual (EN/ES)';

  @override
  String get overview => 'Overview';

  @override
  String get totalLeads => 'Total Leads';

  @override
  String get audited => 'Audited';

  @override
  String get demosSent => 'Demos Sent';

  @override
  String get closedDeals => 'Closed Deals';

  @override
  String get revenueTracker => 'Revenue Tracker';

  @override
  String get totalMrr => 'Total MRR';

  @override
  String get weeklyActivity => 'Weekly Activity';

  @override
  String get filterByStatus => 'Filter by Status';

  @override
  String get allStages => 'All Stages';

  @override
  String get exportCsv => 'Export CSV';

  @override
  String get found => 'Found';

  @override
  String get demoCreated => 'Demo Created';

  @override
  String get contacted => 'Contacted';

  @override
  String get interested => 'Interested';

  @override
  String get closed => 'Closed';

  @override
  String get lost => 'Lost';

  @override
  String movedTo(String status) {
    return 'Moved to $status';
  }

  @override
  String get deleteBusiness => 'Delete Business';

  @override
  String removeFromPipeline(String name) {
    return 'Remove $name from pipeline?';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get businessRemoved => 'Business removed';

  @override
  String get noBusinessesInStage => 'No businesses in this stage';

  @override
  String get subscription => 'Subscription';

  @override
  String get pro => 'Pro';

  @override
  String get free => 'Free';

  @override
  String get usageThisMonth => 'Usage This Month';

  @override
  String get searches => 'Searches';

  @override
  String get audits => 'Audits';

  @override
  String get demos => 'Demos';

  @override
  String get unlimited => '∞';

  @override
  String get limitReached => 'Limit reached. Upgrade to Pro for unlimited.';

  @override
  String get language => 'Language';

  @override
  String get about => 'About';

  @override
  String get signOut => 'Sign Out';

  @override
  String get signOutConfirm => 'Are you sure you want to sign out?';

  @override
  String get restaurant => 'Restaurant';

  @override
  String get restaurantDesc => 'Perfect for cafes, bars, and eateries';

  @override
  String get professionalServices => 'Professional Services';

  @override
  String get professionalDesc => 'Lawyers, accountants, consultants';

  @override
  String get healthBeauty => 'Health & Beauty';

  @override
  String get healthBeautyDesc => 'Salons, spas, clinics';

  @override
  String get professional => 'Professional';

  @override
  String get casual => 'Casual';

  @override
  String get direct => 'Direct';

  @override
  String get emailChannel => 'Email';

  @override
  String get whatsapp => 'WhatsApp';

  @override
  String get instagram => 'Instagram';

  @override
  String get phone => 'Phone';

  @override
  String get other => 'Other';
}
