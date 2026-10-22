abstract final class AppStrings {
  static const String appName = 'BayanSense';
  static const String appNameUpper = 'BAYANSENSE';
  static const String tagline =
      'A simpler way to report local flooding, drainage, sewer, and water concerns.';
  static const String publicHeadline =
      'A better barangay starts with being heard.';
  static const String publicDescription =
      'Report local infrastructure and water concerns, then follow their progress with your community.';
  static const String login = 'Log in';
  static const String createAccount = 'Create account';
  static const String createAccountLink = 'Create an account';
  static const String residentAccountHint = 'Residents can create an account.';
  static const String staffAccountNote =
      'Staff and administrators use the account created for them.';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String fullName = 'Full name';
  static const String showPassword = 'Show password';
  static const String hidePassword = 'Hide password';
  static const String invalidEmail = 'Please enter a valid email address.';
  static const String passwordRequired = 'Please enter your password.';
  static const String passwordTooShort = 'Use at least 8 characters.';
  static const String nameRequired = 'Please enter your full name.';
  static const String publicHome = 'Home';
  static const String previewDashboards = 'Preview dashboards';
  static const String submitReport = 'Submit a report';
  static const String submitReportAction = 'Submit report';
  static const String characterCount = 'characters';
  static const String myReports = 'My reports';
  static const String allReports = 'All reports';
  static const String staffAccounts = 'Staff accounts';
  static const String queue = 'Queue';
  static const String logout = 'Log out';
  static const String logoutTooltip = 'Log out';
  static const String thisSectionNextPhase =
      'This section is built in the next phase';
  static const String howItWorks = 'How it works';
  static const String whatWeHandle = 'What we handle';
  static const String submitStep = 'Submit a report';
  static const String routingStep = 'It is routed to the right team';
  static const String trackStep = 'Track its progress';
  static const String footer = 'BayanSense | A public barangay service';
  static const String reportProblem = 'Report a problem';
  static const String flooding = 'Flooding';
  static const String waterWaste = 'Water Waste';
  static const String drainageProblem = 'Drainage Problem';
  static const String sewerProblem = 'Sewer Problem';
  static const String cloggedDrainage = 'Clogged or Damaged Drainage';
  static const String outOfScope = 'Out of Scope';
  static const String received = 'Received';
  static const String inProgress = 'In Progress';
  static const String resolved = 'Resolved';
  static const String needsReview = 'Needs review';
  static const String totalReports = 'Total reports';
  static const String flaggedForReview = 'Flagged for review';
  static const String unrouted = 'Unrouted (Out of Scope)';
  static const String activeStaff = 'Active staff';
  static const String recentReports = 'Recent reports';
  static const String departmentQueue = 'Department queue';
  static const String reportsByDepartment = 'Reports by department';
  static const String recentActivity = 'Recent activity';
  static const String viewAll = 'View all';
  static const String noReportsTitle = 'No reports yet';
  static const String noReportsDescription =
      'Reports you submit will appear here with their latest status.';
  static const String notRoutedDescription =
      'Out-of-scope reports are not routed to a department.';
  static const String loadingReports = 'Loading reports...';
  static const String loadReportsError = 'Reports could not be loaded.';
  static const String reference = 'Reference';
  static const String description = 'Description';
  static const String category = 'Category';
  static const String confidence = 'Confidence';
  static const String status = 'Status';
  static const String date = 'Date';
  static const String department = 'Department';
  static const String unassigned = 'Unassigned';
  static const String all = 'All';
  static const String searchReports = 'Search by description';
  static const String needsReviewOnly = 'Needs review';
  static const String filterOn = 'On';
  static const String filterOff = 'Off';
  static const String reportDescriptionHelper =
      'Describe the problem and where it is. You may write in Bisaya, Tagalog, or English.';
  static const String reportDescriptionLabel = 'Describe the problem';
  static const String reportLocation = 'Location (optional)';
  static const String reportFormTitle = 'Send a report';
  static const String reportCategoryLabel = 'Category';
  static const String reportCategoryHint = 'Choose a category';
  static const String reportCategoryRequired = 'Choose a category.';
  static const String reportLocationRequired = 'Enter a location or purok.';
  static const String reportLocationPurok = 'Location / Purok';
  static const String reportLocationHint = 'Enter a street, landmark, or purok';
  static const String reportDescriptionRequired =
      'Please describe the concern in more detail.';
  static const String reportSimulationNote =
      'Responses are simulated. Nothing is saved or sent.';
  static const String simulateFailure = 'Simulate failure';
  static const String reportsSentThisSession = 'Reports sent this session';
  static const String noSessionReports = 'No reports yet';
  static const String startReportAction = 'Start a report';
  static const String submitReportRetry = 'Retry';
  static const String simulatedReportError =
      'The simulated submission failed. Turn off failure simulation and try again.';
  static const String simulatedReportSuccessTitle = 'Report received';
  static const String simulatedReportSuccessMessage =
      'Your report was submitted in this simulation.';
  static const String submitAnotherReport = 'Submit another report';
  static const String latitude = 'Latitude';
  static const String longitude = 'Longitude';
  static const String reportReceivedOutsideServices =
      'Your report was received, but it is outside the barangay environmental services handled by BayanSense.';
  static const String notAssigned =
      'This report was received but has not been assigned to a department.';
  static const String updateStatus = 'Update status';
  static const String resolutionNote = 'Note (required when resolving)';
  static const String statusUpdateConfirmation =
      'Update this report to the selected status?';
  static const String createStaffTitle = 'Create staff account';
  static const String departmentRequired = 'Choose a department.';
  static const String staffAccountCreated =
      'Staff account created successfully.';
  static const String passwordRule = 'Password must be at least 8 characters.';
  static const String statusHistoryUnavailable =
      'Status history is not available; showing the current status and last updated date.';
  static const String adminReportsUnavailable =
      'All reports are unavailable because the backend does not permit admin access to GET /reports.';
  static const String activeStaffUnavailable =
      'Active staff statistics are unavailable because there is no staff-list endpoint.';
  static const String photoUploadUnavailable =
      'Photo attachments are unavailable because the backend has no upload endpoint.';
  static const String noReportsMatch = 'No reports match these filters.';
  static const String resolutionNoteRequired =
      'Add a note before marking this report Resolved.';
  static const String cancel = 'Cancel';
  static const String confirm = 'Confirm';
  static const String newestFirst = 'Newest first';
  static const String oldestFirst = 'Oldest first';
  static const String submittedDate = 'Submitted';
  static const String lastUpdatedDate = 'Last updated';
  static const String referenceNumberLabel = 'Reference number';
  static const String reportReceivedTitle = 'Report received';
  static const String thankYouReportReceived =
      'Thank you. We received your report.';
  static const String sentTo = 'Sent to';
  static const String staffWillDecide = 'Staff will decide';
  static const String unclassified = 'Unclassified';
  static const String outsideServicesTitle =
      'This looks like something BayanSense does not handle.';
  static const String latitudeInvalid = 'Enter a latitude between -90 and 90.';
  static const String longitudeInvalid =
      'Enter a longitude between -180 and 180.';
  static const String sessionClearFailure =
      'Your session could not be cleared from this device.';
  static const String accessDenied = 'You do not have access to this page.';
  static const String sessionExpired =
      'Your session has expired. Please log in again.';
  static const String residentGreeting = 'Welcome back';
  static const String loginError =
      'We could not sign you in with those details.';
  static const String accountCreatedLogin =
      'Your account was created. Please log in.';
  static const String registrationError =
      'An account could not be created with those details.';
  static const String emailAlreadyRegistered =
      'An account with that email already exists.';
  static const String categoryPending = 'Category pending';
  static const String staffSubtitle = 'Department team';
  static const String activeStaffValue = '0';
  static const String percentSuffix = '%';
  static const String welcomeBack = 'Welcome back,';
  static const String footerCopyright = 'Public service for our barangay';
  static const String accountPrompt = 'New to BayanSense?';
  static const String existingAccountPrompt = 'Already have an account?';
  static const String signInAction = 'Sign in';
  static const String loading = 'Loading...';
  static const String emptyQueueTitle = 'Your queue is clear';
  static const String emptyQueueDescription =
      'New reports routed to your department will appear here.';
  static const String registerTitle = 'Create a resident account';
  static const String emailLabel = 'Email address';
  static const String loginTitle = 'Sign in to BayanSense';
  static const String createStaffAccount = 'Create staff account';
  static const String residentRole = 'Resident';
  static const String staffRole = 'Staff';
  static const String adminRole = 'Administrator';
  static const String barangayCouncil = 'Barangay Council';
  static const String bdrmm =
      'Barangay Disaster Risk Reduction and Management (BDRRM)';
  static const String sanitationCommittee = 'Sanitation and Health Committee';
  static const String publicWorks = 'Public Works and Engineering';
  static const String drainageTeam = 'Drainage Maintenance Team';
  static const String roadTeam = 'Road and Infrastructure Team';
  static const String environmentalCommittee = 'Environmental Committee';
  static const List<String> problemTypes = <String>[
    flooding,
    waterWaste,
    drainageProblem,
    sewerProblem,
    cloggedDrainage,
  ];
  static const List<String> departments = <String>[
    barangayCouncil,
    bdrmm,
    sanitationCommittee,
    publicWorks,
    drainageTeam,
    roadTeam,
    environmentalCommittee,
  ];

  static const List<DepartmentOption> departmentNames = <DepartmentOption>[
    DepartmentOption(1, barangayCouncil),
    DepartmentOption(2, bdrmm),
    DepartmentOption(3, sanitationCommittee),
    DepartmentOption(4, publicWorks),
    DepartmentOption(5, drainageTeam),
    DepartmentOption(6, roadTeam),
    DepartmentOption(7, environmentalCommittee),
  ];

  static String departmentNameForId(int id) =>
      departmentNames.firstWhere((department) => department.id == id).name;
}

class DepartmentOption {
  const DepartmentOption(this.id, this.name);

  final int id;
  final String name;
}
