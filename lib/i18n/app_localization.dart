import 'app_strings.dart';

enum AppLanguage { english, urdu }

class AppLocalization {
  const AppLocalization(this.language);
  const AppLocalization.english() : language = AppLanguage.english;
  final AppLanguage language;

  String get appName => AppStrings.appName;
  String get dashboard => AppStrings.dashboard;
  String get work => AppStrings.work;
  String get history => AppStrings.history;
  String get finance => AppStrings.finance;
  String get settings => AppStrings.settings;
  String get languageLabel => AppStrings.language;
  String get britishEnglish => AppStrings.britishEnglish;
  String get urduPakistan => AppStrings.urduPakistan;
  String get switchLanguage => AppStrings.switchLanguage;
  String get workEarn => AppStrings.workEarn;
  String get foundation => AppStrings.foundation;
  String get founder => AppStrings.founder;
  String get save => AppStrings.save;
  String get update => AppStrings.update;
  String get delete => AppStrings.delete;
  String get cancel => AppStrings.cancel;
  String get clear => AppStrings.clear;
  String get done => AppStrings.done;
  String get edit => AppStrings.edit;

  String get newEntry => AppStrings.newEntry;
  String get editEntry => AppStrings.editEntry;
  String get workDetails => AppStrings.workDetails;
  String get itemName => AppStrings.itemName;
  String get customItem => AppStrings.customItem;
  String get pieces => AppStrings.pieces;
  String get rate => AppStrings.rate;
  String get rateType => AppStrings.rateType;
  String get perPiece => AppStrings.perPiece;
  String get perDozen => AppStrings.perDozen;
  String get notes => AppStrings.notes;
  String get total => AppStrings.total;
  String get saveEntry => AppStrings.saveEntry;
  String get updateEntry => AppStrings.updateEntry;
  String get selectSizes => AppStrings.selectSizes;
  String get customSizes => AppStrings.customSizes;
  String get itemShirt => AppStrings.itemShirt;
  String get itemPant => AppStrings.itemPant;
  String get itemKameez => AppStrings.itemKameez;
  String get selectSizesPrompt => AppStrings.selectSizesPrompt;

  String get addFinanceRecord => AppStrings.addFinanceRecord;
  String get editFinanceRecord => AppStrings.editFinanceRecord;
  String get deleteFinanceRecord => AppStrings.deleteFinanceRecord;
  String get deleteFinanceRecordConfirmation => AppStrings.deleteFinanceRecordConfirmation;
  String get financeType => AppStrings.financeType;
  String get salaryReceived => AppStrings.salaryReceived;
  String get advanceReceived => AppStrings.advanceReceived;
  String get other => AppStrings.other;
  String get amount => AppStrings.amount;
  String get reason => AppStrings.reason;
  String get currentBalance => AppStrings.currentBalance;
  String get salary => AppStrings.salary;
  String get advance => AppStrings.advance;
  String get noFinanceRecords => AppStrings.noFinanceRecords;

  String get weeklyHistory => AppStrings.weeklyHistory;
  String get monthlyHistory => AppStrings.monthlyHistory;
  String get thisWeek => AppStrings.thisWeek;
  String get thisMonth => AppStrings.thisMonth;
  String get searchItemOrDate => AppStrings.searchItemOrDate;
  String get selectedWeek => AppStrings.selectedWeek;
  String get selectedMonth => AppStrings.selectedMonth;
  String get selectAnyDateInMonth => AppStrings.selectAnyDateInMonth;
  String get monthLabel => AppStrings.monthLabel;
  String get item => AppStrings.item;
  String get size => AppStrings.size;
  String get errorPrefix => AppStrings.errorPrefix;
  String get deleteEntry => AppStrings.deleteEntry;
  String get deleteEntryConfirmation => AppStrings.deleteEntryConfirmation;
  String get entries => AppStrings.entries;
  String get earnings => AppStrings.earnings;
  String get noEntriesYet => AppStrings.noEntriesYet;

  String get welcomeToWorkEarn => AppStrings.welcomeToWorkEarn;
  String get today => AppStrings.today;
  String get week => AppStrings.week;
  String get month => AppStrings.month;
  String get keepEarningKeepGrowing => AppStrings.keepEarningKeepGrowing;
  String get turnEveryStitchIntoProgress => AppStrings.turnEveryStitchIntoProgress;
  String get addYourFirstEntry => AppStrings.addYourFirstEntry;
  String get totalEntries => AppStrings.totalEntries;
  String get totalPieces => AppStrings.totalPieces;
  String get todaysEarnings => AppStrings.todaysEarnings;
  String get weeklyEarnings => AppStrings.weeklyEarnings;
  String get monthlyEarnings => AppStrings.monthlyEarnings;
  String get totalEarnings => AppStrings.totalEarnings;

  String get profilePicture => AppStrings.profilePicture;
  String get profileAndCover => AppStrings.profileAndCover;
  String get addCoverImage => AppStrings.addCoverImage;
  String get operatorName => AppStrings.operatorName;
  String get mobileNumberOptional => AppStrings.mobileNumberOptional;
  String get companyNameOptional => AppStrings.companyNameOptional;
  String get defaultMachineType => AppStrings.defaultMachineType;
  String get singleNeedle => AppStrings.singleNeedle;
  String get overLock => AppStrings.overLock;
  String get flatLock => AppStrings.flatLock;
  String get defaultJobType => AppStrings.defaultJobType;
  String get fullPiece => AppStrings.fullPiece;
  String get halfPiece => AppStrings.halfPiece;
  String get contract => AppStrings.contract;
  String get currency => AppStrings.currency;
  String get theme => AppStrings.theme;
  String get saveSettings => AppStrings.saveSettings;

  String get entrySavedSuccessfully => AppStrings.entrySavedSuccessfully;
  String get entryUpdatedSuccessfully => AppStrings.entryUpdatedSuccessfully;
  String get entryDeletedSuccessfully => AppStrings.entryDeletedSuccessfully;
  String get entrySaveFailed => AppStrings.entrySaveFailed;
  String get financeRecordSaved => AppStrings.financeRecordSaved;
  String get financeRecordUpdated => AppStrings.financeRecordUpdated;
  String get financeRecordDeletedSuccessfully => AppStrings.financeRecordDeletedSuccessfully;
  String get profileSavedSuccessfully => AppStrings.profileSavedSuccessfully;
  String get piecesMustBeGreaterThanZero => AppStrings.piecesMustBeGreaterThanZero;
  String get rateMustBeGreaterThanZero => AppStrings.rateMustBeGreaterThanZero;
  String get pleaseEnterAnItem => AppStrings.pleaseEnterAnItem;
}
