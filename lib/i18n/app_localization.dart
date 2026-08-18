import 'package:flutter/widgets.dart';

import 'app_strings.dart';

/// Supported application languages.
///
/// English remains the authoritative source language. Urdu is introduced as
/// a translation layer without changing the existing AppStrings API.
enum AppLanguage {
  english,
  urdu,
}

extension AppLanguageCode on AppLanguage {
  String get code => switch (this) {
        AppLanguage.english => 'en',
        AppLanguage.urdu => 'ur',
      };

  TextDirection get textDirection => this == AppLanguage.urdu
      ? TextDirection.rtl
      : TextDirection.ltr;

  Locale get locale => Locale(code);
}

/// Localised values for the existing AppStrings keys.
///
/// This first layer deliberately covers the complete current AppStrings
/// surface. English is returned unchanged; Urdu will be populated in the
/// dedicated Urdu translation map rather than hardcoded into UI widgets.
class AppLocalization {
  const AppLocalization(this.language);

  final AppLanguage language;

  String get appName => _value('appName', AppStrings.appName);
  String get dashboard => _value('dashboard', AppStrings.dashboard);
  String get work => _value('work', AppStrings.work);
  String get history => _value('history', AppStrings.history);
  String get finance => _value('finance', AppStrings.finance);
  String get settings => _value('settings', AppStrings.settings);

  String get workEarn => _value('workEarn', AppStrings.workEarn);
  String get foundation => _value('foundation', AppStrings.foundation);
  String get founder => _value('founder', AppStrings.founder);

  String get save => _value('save', AppStrings.save);
  String get update => _value('update', AppStrings.update);
  String get delete => _value('delete', AppStrings.delete);
  String get cancel => _value('cancel', AppStrings.cancel);
  String get clear => _value('clear', AppStrings.clear);
  String get done => _value('done', AppStrings.done);
  String get edit => _value('edit', AppStrings.edit);

  String get newEntry => _value('newEntry', AppStrings.newEntry);
  String get editEntry => _value('editEntry', AppStrings.editEntry);
  String get workDetails => _value('workDetails', AppStrings.workDetails);
  String get itemName => _value('itemName', AppStrings.itemName);
  String get customItem => _value('customItem', AppStrings.customItem);
  String get pieces => _value('pieces', AppStrings.pieces);
  String get rate => _value('rate', AppStrings.rate);
  String get rateType => _value('rateType', AppStrings.rateType);
  String get perPiece => _value('perPiece', AppStrings.perPiece);
  String get perDozen => _value('perDozen', AppStrings.perDozen);
  String get notes => _value('notes', AppStrings.notes);
  String get total => _value('total', AppStrings.total);
  String get saveEntry => _value('saveEntry', AppStrings.saveEntry);
  String get updateEntry => _value('updateEntry', AppStrings.updateEntry);
  String get selectSizes => _value('selectSizes', AppStrings.selectSizes);
  String get customSizes => _value('customSizes', AppStrings.customSizes);

  String get addFinanceRecord => _value('addFinanceRecord', AppStrings.addFinanceRecord);
  String get editFinanceRecord => _value('editFinanceRecord', AppStrings.editFinanceRecord);
  String get salaryReceived => _value('salaryReceived', AppStrings.salaryReceived);
  String get advanceReceived => _value('advanceReceived', AppStrings.advanceReceived);
  String get other => _value('other', AppStrings.other);
  String get amount => _value('amount', AppStrings.amount);
  String get reason => _value('reason', AppStrings.reason);
  String get currentBalance => _value('currentBalance', AppStrings.currentBalance);
  String get salary => _value('salary', AppStrings.salary);
  String get advance => _value('advance', AppStrings.advance);
  String get noFinanceRecords => _value('noFinanceRecords', AppStrings.noFinanceRecords);

  String get weeklyHistory => _value('weeklyHistory', AppStrings.weeklyHistory);
  String get monthlyHistory => _value('monthlyHistory', AppStrings.monthlyHistory);
  String get thisWeek => _value('thisWeek', AppStrings.thisWeek);
  String get thisMonth => _value('thisMonth', AppStrings.thisMonth);
  String get searchItemOrDate => _value('searchItemOrDate', AppStrings.searchItemOrDate);
  String get selectedWeek => _value('selectedWeek', AppStrings.selectedWeek);
  String get selectedMonth => _value('selectedMonth', AppStrings.selectedMonth);
  String get entries => _value('entries', AppStrings.entries);
  String get earnings => _value('earnings', AppStrings.earnings);
  String get noEntriesYet => _value('noEntriesYet', AppStrings.noEntriesYet);

  String get welcomeToWorkEarn => _value('welcomeToWorkEarn', AppStrings.welcomeToWorkEarn);
  String get today => _value('today', AppStrings.today);
  String get week => _value('week', AppStrings.week);
  String get month => _value('month', AppStrings.month);
  String get keepEarningKeepGrowing => _value('keepEarningKeepGrowing', AppStrings.keepEarningKeepGrowing);
  String get turnEveryStitchIntoProgress => _value('turnEveryStitchIntoProgress', AppStrings.turnEveryStitchIntoProgress);
  String get addYourFirstEntry => _value('addYourFirstEntry', AppStrings.addYourFirstEntry);
  String get totalEntries => _value('totalEntries', AppStrings.totalEntries);
  String get totalPieces => _value('totalPieces', AppStrings.totalPieces);
  String get todaysEarnings => _value('todaysEarnings', AppStrings.todaysEarnings);
  String get weeklyEarnings => _value('weeklyEarnings', AppStrings.weeklyEarnings);
  String get monthlyEarnings => _value('monthlyEarnings', AppStrings.monthlyEarnings);
  String get totalEarnings => _value('totalEarnings', AppStrings.totalEarnings);

  String get profileAndCover => _value('profileAndCover', AppStrings.profileAndCover);
  String get addCoverImage => _value('addCoverImage', AppStrings.addCoverImage);
  String get operatorName => _value('operatorName', AppStrings.operatorName);
  String get mobileNumberOptional => _value('mobileNumberOptional', AppStrings.mobileNumberOptional);
  String get companyNameOptional => _value('companyNameOptional', AppStrings.companyNameOptional);
  String get defaultMachineType => _value('defaultMachineType', AppStrings.defaultMachineType);
  String get singleNeedle => _value('singleNeedle', AppStrings.singleNeedle);
  String get overLock => _value('overLock', AppStrings.overLock);
  String get flatLock => _value('flatLock', AppStrings.flatLock);
  String get defaultJobType => _value('defaultJobType', AppStrings.defaultJobType);
  String get fullPiece => _value('fullPiece', AppStrings.fullPiece);
  String get halfPiece => _value('halfPiece', AppStrings.halfPiece);
  String get contract => _value('contract', AppStrings.contract);
  String get currency => _value('currency', AppStrings.currency);
  String get theme => _value('theme', AppStrings.theme);
  String get saveSettings => _value('saveSettings', AppStrings.saveSettings);

  String get entrySavedSuccessfully => _value('entrySavedSuccessfully', AppStrings.entrySavedSuccessfully);
  String get entryUpdatedSuccessfully => _value('entryUpdatedSuccessfully', AppStrings.entryUpdatedSuccessfully);
  String get entryDeletedSuccessfully => _value('entryDeletedSuccessfully', AppStrings.entryDeletedSuccessfully);
  String get financeRecordSaved => _value('financeRecordSaved', AppStrings.financeRecordSaved);
  String get financeRecordUpdated => _value('financeRecordUpdated', AppStrings.financeRecordUpdated);
  String get financeRecordDeletedSuccessfully => _value('financeRecordDeletedSuccessfully', AppStrings.financeRecordDeletedSuccessfully);
  String get profileSavedSuccessfully => _value('profileSavedSuccessfully', AppStrings.profileSavedSuccessfully);
  String get piecesMustBeGreaterThanZero => _value('piecesMustBeGreaterThanZero', AppStrings.piecesMustBeGreaterThanZero);
  String get rateMustBeGreaterThanZero => _value('rateMustBeGreaterThanZero', AppStrings.rateMustBeGreaterThanZero);
  String get pleaseEnterAnItem => _value('pleaseEnterAnItem', AppStrings.pleaseEnterAnItem);

  String _value(String key, String english) {
    // Urdu values are intentionally not inserted here yet. This keeps the
    // architecture change separate from translation content and guarantees
    // an English fallback until the Urdu catalogue is sealed.
    return english;
  }
}
