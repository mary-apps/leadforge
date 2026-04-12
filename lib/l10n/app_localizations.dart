import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'LeadForge'**
  String get appTitle;

  /// No description provided for @aiPoweredLeadGen.
  ///
  /// In en, this message translates to:
  /// **'AI-powered lead generation'**
  String get aiPoweredLeadGen;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign In'**
  String get alreadyHaveAccount;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign Up'**
  String get dontHaveAccount;

  /// No description provided for @continueWithApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get continueWithApple;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get enterValidEmail;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// No description provided for @emailSent.
  ///
  /// In en, this message translates to:
  /// **'Email Sent'**
  String get emailSent;

  /// No description provided for @passwordResetSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset link sent to {email}. Check your inbox.'**
  String passwordResetSent(String email);

  /// No description provided for @enterEmailFirst.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email address'**
  String get enterEmailFirst;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get or;

  /// No description provided for @scout.
  ///
  /// In en, this message translates to:
  /// **'Scout'**
  String get scout;

  /// No description provided for @pipeline.
  ///
  /// In en, this message translates to:
  /// **'Pipeline'**
  String get pipeline;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @searchBusinesses.
  ///
  /// In en, this message translates to:
  /// **'Search businesses...'**
  String get searchBusinesses;

  /// No description provided for @suggestedNiches.
  ///
  /// In en, this message translates to:
  /// **'Suggested Niches'**
  String get suggestedNiches;

  /// No description provided for @searchesRemaining.
  ///
  /// In en, this message translates to:
  /// **'{count} searches remaining'**
  String searchesRemaining(int count);

  /// No description provided for @businessDetail.
  ///
  /// In en, this message translates to:
  /// **'Business Detail'**
  String get businessDetail;

  /// No description provided for @analyzeBusiness.
  ///
  /// In en, this message translates to:
  /// **'Analyze Business'**
  String get analyzeBusiness;

  /// No description provided for @aiAnalysis.
  ///
  /// In en, this message translates to:
  /// **'AI Analysis'**
  String get aiAnalysis;

  /// No description provided for @generateReport.
  ///
  /// In en, this message translates to:
  /// **'Generate Report'**
  String get generateReport;

  /// No description provided for @createMessage.
  ///
  /// In en, this message translates to:
  /// **'Create Message'**
  String get createMessage;

  /// No description provided for @businessNotFound.
  ///
  /// In en, this message translates to:
  /// **'Business not found'**
  String get businessNotFound;

  /// No description provided for @checkingWebsite.
  ///
  /// In en, this message translates to:
  /// **'Checking website...'**
  String get checkingWebsite;

  /// No description provided for @analyzingReviews.
  ///
  /// In en, this message translates to:
  /// **'Analyzing reviews...'**
  String get analyzingReviews;

  /// No description provided for @calculatingScore.
  ///
  /// In en, this message translates to:
  /// **'Calculating score...'**
  String get calculatingScore;

  /// No description provided for @generateAuditReport.
  ///
  /// In en, this message translates to:
  /// **'Generate Audit Report'**
  String get generateAuditReport;

  /// No description provided for @createReportFor.
  ///
  /// In en, this message translates to:
  /// **'Create an audit report for'**
  String get createReportFor;

  /// No description provided for @chooseTemplate.
  ///
  /// In en, this message translates to:
  /// **'Choose Template'**
  String get chooseTemplate;

  /// No description provided for @reportCreated.
  ///
  /// In en, this message translates to:
  /// **'Report Created!'**
  String get reportCreated;

  /// No description provided for @shareWithProspect.
  ///
  /// In en, this message translates to:
  /// **'Share this link with your prospect'**
  String get shareWithProspect;

  /// No description provided for @linkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied to clipboard'**
  String get linkCopied;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @reportLimitReached.
  ///
  /// In en, this message translates to:
  /// **'Report Limit Reached'**
  String get reportLimitReached;

  /// No description provided for @reportLimitMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'ve used your free report this month. Upgrade to Pro for unlimited reports.'**
  String get reportLimitMessage;

  /// No description provided for @maybeLater.
  ///
  /// In en, this message translates to:
  /// **'Maybe Later'**
  String get maybeLater;

  /// No description provided for @upgradeToPro.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Pro'**
  String get upgradeToPro;

  /// No description provided for @createOutreachMessage.
  ///
  /// In en, this message translates to:
  /// **'Create Outreach Message'**
  String get createOutreachMessage;

  /// No description provided for @generateMessageFor.
  ///
  /// In en, this message translates to:
  /// **'Generate message for'**
  String get generateMessageFor;

  /// No description provided for @outreachChannel.
  ///
  /// In en, this message translates to:
  /// **'Outreach Channel'**
  String get outreachChannel;

  /// No description provided for @tone.
  ///
  /// In en, this message translates to:
  /// **'Tone'**
  String get tone;

  /// No description provided for @generateMessage.
  ///
  /// In en, this message translates to:
  /// **'Generate Message'**
  String get generateMessage;

  /// No description provided for @messageGenerated.
  ///
  /// In en, this message translates to:
  /// **'Message Generated'**
  String get messageGenerated;

  /// No description provided for @regenerate.
  ///
  /// In en, this message translates to:
  /// **'Regenerate'**
  String get regenerate;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @messageCopied.
  ///
  /// In en, this message translates to:
  /// **'Message copied to clipboard'**
  String get messageCopied;

  /// No description provided for @proFeature.
  ///
  /// In en, this message translates to:
  /// **'Pro Feature'**
  String get proFeature;

  /// No description provided for @proFeatureMessage.
  ///
  /// In en, this message translates to:
  /// **'AI message generation is a Pro feature.'**
  String get proFeatureMessage;

  /// No description provided for @upgradeForPro.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Pro for:'**
  String get upgradeForPro;

  /// No description provided for @unlimitedAiMessages.
  ///
  /// In en, this message translates to:
  /// **'Unlimited AI messages'**
  String get unlimitedAiMessages;

  /// No description provided for @fourChannels.
  ///
  /// In en, this message translates to:
  /// **'4 outreach channels'**
  String get fourChannels;

  /// No description provided for @threeTones.
  ///
  /// In en, this message translates to:
  /// **'3 tone options'**
  String get threeTones;

  /// No description provided for @bilingual.
  ///
  /// In en, this message translates to:
  /// **'Bilingual (EN/ES)'**
  String get bilingual;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @totalLeads.
  ///
  /// In en, this message translates to:
  /// **'Total Leads'**
  String get totalLeads;

  /// No description provided for @audited.
  ///
  /// In en, this message translates to:
  /// **'Audited'**
  String get audited;

  /// No description provided for @reportsSent.
  ///
  /// In en, this message translates to:
  /// **'Reports Sent'**
  String get reportsSent;

  /// No description provided for @closedDeals.
  ///
  /// In en, this message translates to:
  /// **'Closed Deals'**
  String get closedDeals;

  /// No description provided for @revenueTracker.
  ///
  /// In en, this message translates to:
  /// **'Revenue Tracker'**
  String get revenueTracker;

  /// No description provided for @totalMrr.
  ///
  /// In en, this message translates to:
  /// **'Total MRR'**
  String get totalMrr;

  /// No description provided for @weeklyActivity.
  ///
  /// In en, this message translates to:
  /// **'Weekly Activity'**
  String get weeklyActivity;

  /// No description provided for @filterByStatus.
  ///
  /// In en, this message translates to:
  /// **'Filter by Status'**
  String get filterByStatus;

  /// No description provided for @allStages.
  ///
  /// In en, this message translates to:
  /// **'All Stages'**
  String get allStages;

  /// No description provided for @exportCsv.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get exportCsv;

  /// No description provided for @found.
  ///
  /// In en, this message translates to:
  /// **'Found'**
  String get found;

  /// No description provided for @reportSent.
  ///
  /// In en, this message translates to:
  /// **'Report Sent'**
  String get reportSent;

  /// No description provided for @contacted.
  ///
  /// In en, this message translates to:
  /// **'Contacted'**
  String get contacted;

  /// No description provided for @interested.
  ///
  /// In en, this message translates to:
  /// **'Interested'**
  String get interested;

  /// No description provided for @closed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closed;

  /// No description provided for @lost.
  ///
  /// In en, this message translates to:
  /// **'Lost'**
  String get lost;

  /// No description provided for @movedTo.
  ///
  /// In en, this message translates to:
  /// **'Moved to {status}'**
  String movedTo(String status);

  /// No description provided for @deleteBusiness.
  ///
  /// In en, this message translates to:
  /// **'Delete Business'**
  String get deleteBusiness;

  /// No description provided for @removeFromPipeline.
  ///
  /// In en, this message translates to:
  /// **'Remove {name} from pipeline?'**
  String removeFromPipeline(String name);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @businessRemoved.
  ///
  /// In en, this message translates to:
  /// **'Business removed'**
  String get businessRemoved;

  /// No description provided for @noBusinessesInStage.
  ///
  /// In en, this message translates to:
  /// **'No businesses in this stage'**
  String get noBusinessesInStage;

  /// No description provided for @subscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get subscription;

  /// No description provided for @pro.
  ///
  /// In en, this message translates to:
  /// **'Pro'**
  String get pro;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// No description provided for @usageThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Usage This Month'**
  String get usageThisMonth;

  /// No description provided for @searches.
  ///
  /// In en, this message translates to:
  /// **'Searches'**
  String get searches;

  /// No description provided for @audits.
  ///
  /// In en, this message translates to:
  /// **'Audits'**
  String get audits;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @unlimited.
  ///
  /// In en, this message translates to:
  /// **'∞'**
  String get unlimited;

  /// No description provided for @limitReached.
  ///
  /// In en, this message translates to:
  /// **'Limit reached. Upgrade to Pro for unlimited.'**
  String get limitReached;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @signOutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get signOutConfirm;

  /// No description provided for @restaurant.
  ///
  /// In en, this message translates to:
  /// **'Restaurant'**
  String get restaurant;

  /// No description provided for @restaurantDesc.
  ///
  /// In en, this message translates to:
  /// **'Perfect for cafes, bars, and eateries'**
  String get restaurantDesc;

  /// No description provided for @professionalServices.
  ///
  /// In en, this message translates to:
  /// **'Professional Services'**
  String get professionalServices;

  /// No description provided for @professionalDesc.
  ///
  /// In en, this message translates to:
  /// **'Lawyers, accountants, consultants'**
  String get professionalDesc;

  /// No description provided for @healthBeauty.
  ///
  /// In en, this message translates to:
  /// **'Health & Beauty'**
  String get healthBeauty;

  /// No description provided for @healthBeautyDesc.
  ///
  /// In en, this message translates to:
  /// **'Salons, spas, clinics'**
  String get healthBeautyDesc;

  /// No description provided for @professional.
  ///
  /// In en, this message translates to:
  /// **'Professional'**
  String get professional;

  /// No description provided for @casual.
  ///
  /// In en, this message translates to:
  /// **'Casual'**
  String get casual;

  /// No description provided for @direct.
  ///
  /// In en, this message translates to:
  /// **'Direct'**
  String get direct;

  /// No description provided for @emailChannel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailChannel;

  /// No description provided for @whatsapp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get whatsapp;

  /// No description provided for @instagram.
  ///
  /// In en, this message translates to:
  /// **'Instagram'**
  String get instagram;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
