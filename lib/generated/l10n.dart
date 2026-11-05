// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Base URL Configuration`
  String get baseUrlConfig {
    return Intl.message(
      'Base URL Configuration',
      name: 'baseUrlConfig',
      desc: '',
      args: [],
    );
  }

  /// `Protocol`
  String get protocol {
    return Intl.message('Protocol', name: 'protocol', desc: '', args: []);
  }

  /// `Domain`
  String get domain {
    return Intl.message('Domain', name: 'domain', desc: '', args: []);
  }

  /// `Please enter a domain`
  String get pleaseEnterDomain {
    return Intl.message(
      'Please enter a domain',
      name: 'pleaseEnterDomain',
      desc: '',
      args: [],
    );
  }

  /// `Invalid domain or IP address`
  String get invalidDomain {
    return Intl.message(
      'Invalid domain or IP address',
      name: 'invalidDomain',
      desc: '',
      args: [],
    );
  }

  /// `History`
  String get serverHistory {
    return Intl.message('History', name: 'serverHistory', desc: '', args: []);
  }

  /// `No history`
  String get serverHistoryEmpty {
    return Intl.message(
      'No history',
      name: 'serverHistoryEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Choose a saved server`
  String get serverHistorySelect {
    return Intl.message(
      'Choose a saved server',
      name: 'serverHistorySelect',
      desc: '',
      args: [],
    );
  }

  /// `Port`
  String get port {
    return Intl.message('Port', name: 'port', desc: '', args: []);
  }

  /// `API prefix`
  String get apiPrefixLabel {
    return Intl.message(
      'API prefix',
      name: 'apiPrefixLabel',
      desc: '',
      args: [],
    );
  }

  /// `Developer options shown: API prefix (this launch only)`
  String get developerPrefixUnlocked {
    return Intl.message(
      'Developer options shown: API prefix (this launch only)',
      name: 'developerPrefixUnlocked',
      desc: '',
      args: [],
    );
  }

  /// `Prefix must start and not end with / (e.g. /dev-api); leave empty for none`
  String get apiPrefixInvalid {
    return Intl.message(
      'Prefix must start and not end with / (e.g. /dev-api); leave empty for none',
      name: 'apiPrefixInvalid',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a port`
  String get pleaseEnterPort {
    return Intl.message(
      'Please enter a port',
      name: 'pleaseEnterPort',
      desc: '',
      args: [],
    );
  }

  /// `Invalid port number`
  String get invalidPort {
    return Intl.message(
      'Invalid port number',
      name: 'invalidPort',
      desc: '',
      args: [],
    );
  }

  /// `Confirm`
  String get confirm {
    return Intl.message('Confirm', name: 'confirm', desc: '', args: []);
  }

  /// `Cannot connect to server. Please check the address, port, or network.`
  String get serverConnectionFailed {
    return Intl.message(
      'Cannot connect to server. Please check the address, port, or network.',
      name: 'serverConnectionFailed',
      desc: '',
      args: [],
    );
  }

  /// `Server version is too low (v{actual}). Please contact the administrator to upgrade the server to {required} or above.`
  String apiVersionTooLow(Object actual, Object required) {
    return Intl.message(
      'Server version is too low (v$actual). Please contact the administrator to upgrade the server to $required or above.',
      name: 'apiVersionTooLow',
      desc: '',
      args: [actual, required],
    );
  }

  /// `Server version is too high (v{actual}). This client supports versions below {supportedMax}. Please upgrade the client or contact the administrator.`
  String apiVersionTooHigh(Object actual, Object supportedMax) {
    return Intl.message(
      'Server version is too high (v$actual). This client supports versions below $supportedMax. Please upgrade the client or contact the administrator.',
      name: 'apiVersionTooHigh',
      desc: '',
      args: [actual, supportedMax],
    );
  }

  /// `The server does not support version detection, so compatibility cannot be confirmed. Verify the server and upgrade it to {required} or above.`
  String apiVersionEndpointUnavailable(Object required) {
    return Intl.message(
      'The server does not support version detection, so compatibility cannot be confirmed. Verify the server and upgrade it to $required or above.',
      name: 'apiVersionEndpointUnavailable',
      desc: '',
      args: [required],
    );
  }

  /// `The server returned invalid version information, so compatibility cannot be confirmed.`
  String get apiVersionUnavailable {
    return Intl.message(
      'The server returned invalid version information, so compatibility cannot be confirmed.',
      name: 'apiVersionUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `Error`
  String get error {
    return Intl.message('Error', name: 'error', desc: '', args: []);
  }

  /// `OK`
  String get ok {
    return Intl.message('OK', name: 'ok', desc: '', args: []);
  }

  /// `Nickname cannot be empty`
  String get nickname_required {
    return Intl.message(
      'Nickname cannot be empty',
      name: 'nickname_required',
      desc: '',
      args: [],
    );
  }

  /// `Invalid email address`
  String get invalid_email {
    return Intl.message(
      'Invalid email address',
      name: 'invalid_email',
      desc: '',
      args: [],
    );
  }

  /// `Invalid phone number`
  String get invalid_phone_number {
    return Intl.message(
      'Invalid phone number',
      name: 'invalid_phone_number',
      desc: '',
      args: [],
    );
  }

  /// `Registration failed`
  String get registration_failed {
    return Intl.message(
      'Registration failed',
      name: 'registration_failed',
      desc: '',
      args: [],
    );
  }

  /// `FortuneBoot`
  String get main_logo {
    return Intl.message('FortuneBoot', name: 'main_logo', desc: '', args: []);
  }

  /// `You are trying to login/sign up on server hosted on`
  String get login_message {
    return Intl.message(
      'You are trying to login/sign up on server hosted on',
      name: 'login_message',
      desc: '',
      args: [],
    );
  }

  /// `demo.fortuneboot.com`
  String get login_host {
    return Intl.message(
      'demo.fortuneboot.com',
      name: 'login_host',
      desc: '',
      args: [],
    );
  }

  /// `LOGIN`
  String get login_button_text {
    return Intl.message('LOGIN', name: 'login_button_text', desc: '', args: []);
  }

  /// `REGISTER`
  String get register {
    return Intl.message('REGISTER', name: 'register', desc: '', args: []);
  }

  /// `or login with`
  String get or_login_with {
    return Intl.message(
      'or login with',
      name: 'or_login_with',
      desc: '',
      args: [],
    );
  }

  /// `Authenticate`
  String get authenticate {
    return Intl.message(
      'Authenticate',
      name: 'authenticate',
      desc: '',
      args: [],
    );
  }

  /// `Forgot huh?`
  String get forgot_huh {
    return Intl.message('Forgot huh?', name: 'forgot_huh', desc: '', args: []);
  }

  /// `User`
  String get login_account {
    return Intl.message('User', name: 'login_account', desc: '', args: []);
  }

  /// `Pass`
  String get login_pass {
    return Intl.message('Pass', name: 'login_pass', desc: '', args: []);
  }

  /// `Confirm`
  String get login_confirm {
    return Intl.message('Confirm', name: 'login_confirm', desc: '', args: []);
  }

  /// `Term of services`
  String get term_of_services {
    return Intl.message(
      'Term of services',
      name: 'term_of_services',
      desc: '',
      args: [],
    );
  }

  /// `Email must contain '@' and end with '.com'`
  String get email_auth {
    return Intl.message(
      'Email must contain \'@\' and end with \'.com\'',
      name: 'email_auth',
      desc: '',
      args: [],
    );
  }

  /// `Password is empty`
  String get password_is_empty {
    return Intl.message(
      'Password is empty',
      name: 'password_is_empty',
      desc: '',
      args: [],
    );
  }

  /// `Required`
  String get service_required {
    return Intl.message(
      'Required',
      name: 'service_required',
      desc: '',
      args: [],
    );
  }

  /// `HELP ME`
  String get help_me {
    return Intl.message('HELP ME', name: 'help_me', desc: '', args: []);
  }

  /// `GO BACK`
  String get go_back {
    return Intl.message('GO BACK', name: 'go_back', desc: '', args: []);
  }

  /// `Not match!`
  String get not_match {
    return Intl.message('Not match!', name: 'not_match', desc: '', args: []);
  }

  /// `Don't feel bad. Happens all the time.`
  String get dont_worry_be_happy {
    return Intl.message(
      'Don\'t feel bad. Happens all the time.',
      name: 'dont_worry_be_happy',
      desc: '',
      args: [],
    );
  }

  /// `Lorem Ipsum is simply dummy text of the printing and typesetting industry`
  String get default_comment {
    return Intl.message(
      'Lorem Ipsum is simply dummy text of the printing and typesetting industry',
      name: 'default_comment',
      desc: '',
      args: [],
    );
  }

  /// `Password rescued successfully`
  String get password_rescued_successfully {
    return Intl.message(
      'Password rescued successfully',
      name: 'password_rescued_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Oh no!`
  String get oh_no {
    return Intl.message('Oh no!', name: 'oh_no', desc: '', args: []);
  }

  /// `Succes!`
  String get succes {
    return Intl.message('Succes!', name: 'succes', desc: '', args: []);
  }

  /// `Username`
  String get username {
    return Intl.message('Username', name: 'username', desc: '', args: []);
  }

  /// `Please fill in this form to complete the signup`
  String get fill_to_signup {
    return Intl.message(
      'Please fill in this form to complete the signup',
      name: 'fill_to_signup',
      desc: '',
      args: [],
    );
  }

  /// `Phone Number`
  String get phone_number {
    return Intl.message(
      'Phone Number',
      name: 'phone_number',
      desc: '',
      args: [],
    );
  }

  /// `SUBMIT`
  String get sign_up_submit {
    return Intl.message('SUBMIT', name: 'sign_up_submit', desc: '', args: []);
  }

  /// `This isn't a valid phone number`
  String get valid_phone_number {
    return Intl.message(
      'This isn\'t a valid phone number',
      name: 'valid_phone_number',
      desc: '',
      args: [],
    );
  }

  /// `Account is empty`
  String get user_auth_vaild {
    return Intl.message(
      'Account is empty',
      name: 'user_auth_vaild',
      desc: '',
      args: [],
    );
  }

  /// `User not exists`
  String get user_not_exist {
    return Intl.message(
      'User not exists',
      name: 'user_not_exist',
      desc: '',
      args: [],
    );
  }

  /// `Sign Up Success!`
  String get sign_up_success {
    return Intl.message(
      'Sign Up Success!',
      name: 'sign_up_success',
      desc: '',
      args: [],
    );
  }

  /// `Nickname`
  String get login_nickname {
    return Intl.message('Nickname', name: 'login_nickname', desc: '', args: []);
  }

  /// `Email`
  String get login_email {
    return Intl.message('Email', name: 'login_email', desc: '', args: []);
  }

  /// `sex`
  String get sex {
    return Intl.message('sex', name: 'sex', desc: '', args: []);
  }

  /// `female`
  String get female {
    return Intl.message('female', name: 'female', desc: '', args: []);
  }

  /// `male`
  String get male {
    return Intl.message('male', name: 'male', desc: '', args: []);
  }

  /// `Currently, only two genders are supported. Please fill in 'Male' or 'Female'.`
  String get sex_valid {
    return Intl.message(
      'Currently, only two genders are supported. Please fill in \'Male\' or \'Female\'.',
      name: 'sex_valid',
      desc: '',
      args: [],
    );
  }

  /// `Duplicate username, think of a new one or just log in`
  String get account_valid {
    return Intl.message(
      'Duplicate username, think of a new one or just log in',
      name: 'account_valid',
      desc: '',
      args: [],
    );
  }

  /// `Flutter Todos`
  String get todosOverviewAppBarTitle {
    return Intl.message(
      'Flutter Todos',
      name: 'todosOverviewAppBarTitle',
      desc: 'Title text shown in the AppBar of the Todos Overview Page',
      args: [],
    );
  }

  /// `Filter`
  String get todosOverviewFilterTooltip {
    return Intl.message(
      'Filter',
      name: 'todosOverviewFilterTooltip',
      desc:
          'Tooltip text shown in the filter dropdown of the Todos Overview Page',
      args: [],
    );
  }

  /// `All`
  String get todosOverviewFilterAll {
    return Intl.message(
      'All',
      name: 'todosOverviewFilterAll',
      desc:
          'Text shown in the filter dropdown of the Todos Overview Page for the option to display all todos',
      args: [],
    );
  }

  /// `Active only`
  String get todosOverviewFilterActiveOnly {
    return Intl.message(
      'Active only',
      name: 'todosOverviewFilterActiveOnly',
      desc:
          'Text shown in the filter dropdown of the Todos Overview Page for the option to display active todos only',
      args: [],
    );
  }

  /// `Completed only`
  String get todosOverviewFilterCompletedOnly {
    return Intl.message(
      'Completed only',
      name: 'todosOverviewFilterCompletedOnly',
      desc:
          'Text shown in the filter dropdown of the Todos Overview Page for the option to display completed todos only',
      args: [],
    );
  }

  /// `Mark all complete`
  String get todosOverviewMarkAllCompleteButtonText {
    return Intl.message(
      'Mark all complete',
      name: 'todosOverviewMarkAllCompleteButtonText',
      desc:
          'Button text shown in the options dropdown of the Todos Overview Page that marks all current todos as complete',
      args: [],
    );
  }

  /// `Clear completed`
  String get todosOverviewClearCompletedButtonText {
    return Intl.message(
      'Clear completed',
      name: 'todosOverviewClearCompletedButtonText',
      desc:
          'Button text shown in the options dropdown of the Todos Overview Page that deletes all completed todos',
      args: [],
    );
  }

  /// `No todos found with the selected filters.`
  String get todosOverviewEmptyText {
    return Intl.message(
      'No todos found with the selected filters.',
      name: 'todosOverviewEmptyText',
      desc:
          'Text shown in the Todos Overview Page when no todos are found with the selected filters',
      args: [],
    );
  }

  /// `Todo "{todoTitle}" deleted.`
  String todosOverviewTodoDeletedSnackbarText(Object todoTitle) {
    return Intl.message(
      'Todo "$todoTitle" deleted.',
      name: 'todosOverviewTodoDeletedSnackbarText',
      desc:
          'Snackbar text shown when a todo is deleted from the Todos Overview Page',
      args: [todoTitle],
    );
  }

  /// `Undo`
  String get todosOverviewUndoDeletionButtonText {
    return Intl.message(
      'Undo',
      name: 'todosOverviewUndoDeletionButtonText',
      desc:
          'Button text shown in the snackbar that undoes a deletion of a todo',
      args: [],
    );
  }

  /// `An error occurred while loading todos.`
  String get todosOverviewErrorSnackbarText {
    return Intl.message(
      'An error occurred while loading todos.',
      name: 'todosOverviewErrorSnackbarText',
      desc: 'Snackbar text shown when an error occurs while loading todos',
      args: [],
    );
  }

  /// `Options`
  String get todosOverviewOptionsTooltip {
    return Intl.message(
      'Options',
      name: 'todosOverviewOptionsTooltip',
      desc:
          'Tooltip text shown in the options dropdown of the Todos Overview Page',
      args: [],
    );
  }

  /// `Mark all as completed`
  String get todosOverviewOptionsMarkAllComplete {
    return Intl.message(
      'Mark all as completed',
      name: 'todosOverviewOptionsMarkAllComplete',
      desc:
          'Button text shown in the options dropdown of the Todos Overview Page that marks all todos as complete',
      args: [],
    );
  }

  /// `Mark all as incomplete`
  String get todosOverviewOptionsMarkAllIncomplete {
    return Intl.message(
      'Mark all as incomplete',
      name: 'todosOverviewOptionsMarkAllIncomplete',
      desc:
          'Button text shown in the options dropdown of the Todos Overview Page that marks all todos as incomplete',
      args: [],
    );
  }

  /// `Clear completed`
  String get todosOverviewOptionsClearCompleted {
    return Intl.message(
      'Clear completed',
      name: 'todosOverviewOptionsClearCompleted',
      desc:
          'Button text shown in the options dropdown of the Todos Overview Page that deletes all completed todos',
      args: [],
    );
  }

  /// `Todo Details`
  String get todoDetailsAppBarTitle {
    return Intl.message(
      'Todo Details',
      name: 'todoDetailsAppBarTitle',
      desc: 'Title text shown in the AppBar of the Todo Details Page',
      args: [],
    );
  }

  /// `Delete`
  String get todoDetailsDeleteButtonTooltip {
    return Intl.message(
      'Delete',
      name: 'todoDetailsDeleteButtonTooltip',
      desc: 'Tooltip text shown in the delete button on the Todo Details Page',
      args: [],
    );
  }

  /// `Edit`
  String get todoDetailsEditButtonTooltip {
    return Intl.message(
      'Edit',
      name: 'todoDetailsEditButtonTooltip',
      desc: 'Tooltip text shown in the edit button on the Todo Details Page',
      args: [],
    );
  }

  /// `Edit Todo`
  String get editTodoEditAppBarTitle {
    return Intl.message(
      'Edit Todo',
      name: 'editTodoEditAppBarTitle',
      desc:
          'Title text shown in the AppBar of the Todo Edit Page when editing an existing todo',
      args: [],
    );
  }

  /// `Add Todo`
  String get editTodoAddAppBarTitle {
    return Intl.message(
      'Add Todo',
      name: 'editTodoAddAppBarTitle',
      desc:
          'Title text shown in the AppBar of the Todo Edit Page when adding a new todo',
      args: [],
    );
  }

  /// `Title`
  String get editTodoTitleLabel {
    return Intl.message(
      'Title',
      name: 'editTodoTitleLabel',
      desc: 'Label text shown in the title input field of the Todo Edit Page',
      args: [],
    );
  }

  /// `Description`
  String get editTodoDescriptionLabel {
    return Intl.message(
      'Description',
      name: 'editTodoDescriptionLabel',
      desc:
          'Label text shown in the description input field of the Todo Edit Page',
      args: [],
    );
  }

  /// `Save changes`
  String get editTodoSaveButtonTooltip {
    return Intl.message(
      'Save changes',
      name: 'editTodoSaveButtonTooltip',
      desc: 'Tooltip text shown in the save button on the Todo Edit Page',
      args: [],
    );
  }

  /// `Stats`
  String get statsAppBarTitle {
    return Intl.message(
      'Stats',
      name: 'statsAppBarTitle',
      desc: 'Title text shown in the AppBar of the Stats Page',
      args: [],
    );
  }

  /// `Completed todos`
  String get statsCompletedTodoCountLabel {
    return Intl.message(
      'Completed todos',
      name: 'statsCompletedTodoCountLabel',
      desc:
          'Label text shown in the completed todos count section of the Stats Page',
      args: [],
    );
  }

  /// `Active todos`
  String get statsActiveTodoCountLabel {
    return Intl.message(
      'Active todos',
      name: 'statsActiveTodoCountLabel',
      desc:
          'Label text shown in the active todos count section of the Stats Page',
      args: [],
    );
  }

  /// `My`
  String get mine {
    return Intl.message('My', name: 'mine', desc: '', args: []);
  }

  /// `Save`
  String get commonSave {
    return Intl.message('Save', name: 'commonSave', desc: '', args: []);
  }

  /// `Cancel`
  String get commonCancel {
    return Intl.message('Cancel', name: 'commonCancel', desc: '', args: []);
  }

  /// `Discard unsaved changes?`
  String get fxUnsavedChangesTitle {
    return Intl.message(
      'Discard unsaved changes?',
      name: 'fxUnsavedChangesTitle',
      desc: '',
      args: [],
    );
  }

  /// `Your changes have not been saved. Leaving now will discard them.`
  String get fxUnsavedChangesMessage {
    return Intl.message(
      'Your changes have not been saved. Leaving now will discard them.',
      name: 'fxUnsavedChangesMessage',
      desc: '',
      args: [],
    );
  }

  /// `Keep editing`
  String get fxKeepEditing {
    return Intl.message(
      'Keep editing',
      name: 'fxKeepEditing',
      desc: '',
      args: [],
    );
  }

  /// `Discard changes`
  String get fxDiscardChanges {
    return Intl.message(
      'Discard changes',
      name: 'fxDiscardChanges',
      desc: '',
      args: [],
    );
  }

  /// `The action could not be completed. Try again.`
  String get fxConfirmFailure {
    return Intl.message(
      'The action could not be completed. Try again.',
      name: 'fxConfirmFailure',
      desc: '',
      args: [],
    );
  }

  /// `Clear`
  String get fxClearLabel {
    return Intl.message('Clear', name: 'fxClearLabel', desc: '', args: []);
  }

  /// `Delete`
  String get fxDeleteLabel {
    return Intl.message('Delete', name: 'fxDeleteLabel', desc: '', args: []);
  }

  /// `More actions`
  String get commonMoreActions {
    return Intl.message(
      'More actions',
      name: 'commonMoreActions',
      desc: '',
      args: [],
    );
  }

  /// `{count} results in this branch`
  String manageSearchBranchResults(Object count) {
    return Intl.message(
      '$count results in this branch',
      name: 'manageSearchBranchResults',
      desc: '',
      args: [count],
    );
  }

  /// `This action cannot be undone.`
  String get confirmDestructiveWarning {
    return Intl.message(
      'This action cannot be undone.',
      name: 'confirmDestructiveWarning',
      desc: '',
      args: [],
    );
  }

  /// `Confirm`
  String get commonConfirm {
    return Intl.message('Confirm', name: 'commonConfirm', desc: '', args: []);
  }

  /// `Hide amounts`
  String get commonHideAmounts {
    return Intl.message(
      'Hide amounts',
      name: 'commonHideAmounts',
      desc: '',
      args: [],
    );
  }

  /// `Retry`
  String get commonRetry {
    return Intl.message('Retry', name: 'commonRetry', desc: '', args: []);
  }

  /// `Show amounts`
  String get commonShowAmounts {
    return Intl.message(
      'Show amounts',
      name: 'commonShowAmounts',
      desc: '',
      args: [],
    );
  }

  /// `Follow system`
  String get commonFollowSystem {
    return Intl.message(
      'Follow system',
      name: 'commonFollowSystem',
      desc: '',
      args: [],
    );
  }

  /// `Edit profile`
  String get profileEditProfile {
    return Intl.message(
      'Edit profile',
      name: 'profileEditProfile',
      desc: '',
      args: [],
    );
  }

  /// `Books & groups`
  String get profileBookGroup {
    return Intl.message(
      'Books & groups',
      name: 'profileBookGroup',
      desc: '',
      args: [],
    );
  }

  /// `Current group · book`
  String get profileCurrentGroupBook {
    return Intl.message(
      'Current group · book',
      name: 'profileCurrentGroupBook',
      desc: '',
      args: [],
    );
  }

  /// `Manage groups`
  String get profileGroupManage {
    return Intl.message(
      'Manage groups',
      name: 'profileGroupManage',
      desc: '',
      args: [],
    );
  }

  /// `Manage books`
  String get profileBookManage {
    return Intl.message(
      'Manage books',
      name: 'profileBookManage',
      desc: '',
      args: [],
    );
  }

  /// `Members (group)`
  String get profileMemberManageGroup {
    return Intl.message(
      'Members (group)',
      name: 'profileMemberManageGroup',
      desc: '',
      args: [],
    );
  }

  /// `Bookkeeping`
  String get profileBillingManage {
    return Intl.message(
      'Bookkeeping',
      name: 'profileBillingManage',
      desc: '',
      args: [],
    );
  }

  /// `Categories`
  String get profileCategoryManage {
    return Intl.message(
      'Categories',
      name: 'profileCategoryManage',
      desc: '',
      args: [],
    );
  }

  /// `Tags`
  String get profileTagManage {
    return Intl.message('Tags', name: 'profileTagManage', desc: '', args: []);
  }

  /// `Payees`
  String get profilePayeeManage {
    return Intl.message(
      'Payees',
      name: 'profilePayeeManage',
      desc: '',
      args: [],
    );
  }

  /// `Members (bill)`
  String get profileMemberManageBill {
    return Intl.message(
      'Members (bill)',
      name: 'profileMemberManageBill',
      desc: '',
      args: [],
    );
  }

  /// `Accounts`
  String get profileAccountManage {
    return Intl.message(
      'Accounts',
      name: 'profileAccountManage',
      desc: '',
      args: [],
    );
  }

  /// `Toolbox`
  String get profileToolbox {
    return Intl.message('Toolbox', name: 'profileToolbox', desc: '', args: []);
  }

  /// `Belongings`
  String get profileGoodsManage {
    return Intl.message(
      'Belongings',
      name: 'profileGoodsManage',
      desc: '',
      args: [],
    );
  }

  /// `Documents`
  String get profileOrdersManage {
    return Intl.message(
      'Documents',
      name: 'profileOrdersManage',
      desc: '',
      args: [],
    );
  }

  /// `Recurring`
  String get profileRecurringManage {
    return Intl.message(
      'Recurring',
      name: 'profileRecurringManage',
      desc: '',
      args: [],
    );
  }

  /// `Export`
  String get profileImportExport {
    return Intl.message(
      'Export',
      name: 'profileImportExport',
      desc: '',
      args: [],
    );
  }

  /// `Logs`
  String get profileLogs {
    return Intl.message('Logs', name: 'profileLogs', desc: '', args: []);
  }

  /// `Operations`
  String get logsOperation {
    return Intl.message(
      'Operations',
      name: 'logsOperation',
      desc: '',
      args: [],
    );
  }

  /// `Sign-in`
  String get logsLogin {
    return Intl.message('Sign-in', name: 'logsLogin', desc: '', args: []);
  }

  /// `No logs`
  String get logsEmpty {
    return Intl.message('No logs', name: 'logsEmpty', desc: '', args: []);
  }

  /// `Search by username`
  String get logsSearchHint {
    return Intl.message(
      'Search by username',
      name: 'logsSearchHint',
      desc: '',
      args: [],
    );
  }

  /// `User`
  String get logsUsername {
    return Intl.message('User', name: 'logsUsername', desc: '', args: []);
  }

  /// `Time`
  String get logsTime {
    return Intl.message('Time', name: 'logsTime', desc: '', args: []);
  }

  /// `Status`
  String get logsStatus {
    return Intl.message('Status', name: 'logsStatus', desc: '', args: []);
  }

  /// `Module`
  String get logsModule {
    return Intl.message('Module', name: 'logsModule', desc: '', args: []);
  }

  /// `Action`
  String get logsBusinessType {
    return Intl.message('Action', name: 'logsBusinessType', desc: '', args: []);
  }

  /// `Method`
  String get logsMethod {
    return Intl.message('Method', name: 'logsMethod', desc: '', args: []);
  }

  /// `URL`
  String get logsUrl {
    return Intl.message('URL', name: 'logsUrl', desc: '', args: []);
  }

  /// `IP`
  String get logsIp {
    return Intl.message('IP', name: 'logsIp', desc: '', args: []);
  }

  /// `Location`
  String get logsLocation {
    return Intl.message('Location', name: 'logsLocation', desc: '', args: []);
  }

  /// `System`
  String get logsSystem {
    return Intl.message('System', name: 'logsSystem', desc: '', args: []);
  }

  /// `Browser`
  String get logsBrowser {
    return Intl.message('Browser', name: 'logsBrowser', desc: '', args: []);
  }

  /// `Message`
  String get logsMessage {
    return Intl.message('Message', name: 'logsMessage', desc: '', args: []);
  }

  /// `Request`
  String get logsParam {
    return Intl.message('Request', name: 'logsParam', desc: '', args: []);
  }

  /// `Response`
  String get logsResult {
    return Intl.message('Response', name: 'logsResult', desc: '', args: []);
  }

  /// `Error`
  String get logsError {
    return Intl.message('Error', name: 'logsError', desc: '', args: []);
  }

  /// `Preferences`
  String get profilePreferences {
    return Intl.message(
      'Preferences',
      name: 'profilePreferences',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get profileLanguage {
    return Intl.message(
      'Language',
      name: 'profileLanguage',
      desc: '',
      args: [],
    );
  }

  /// `Theme mode`
  String get profileThemeMode {
    return Intl.message(
      'Theme mode',
      name: 'profileThemeMode',
      desc: '',
      args: [],
    );
  }

  /// `Light`
  String get profileThemeLight {
    return Intl.message('Light', name: 'profileThemeLight', desc: '', args: []);
  }

  /// `Dark`
  String get profileThemeDark {
    return Intl.message('Dark', name: 'profileThemeDark', desc: '', args: []);
  }

  /// `Billing start day`
  String get profileMonthStartDay {
    return Intl.message(
      'Billing start day',
      name: 'profileMonthStartDay',
      desc: '',
      args: [],
    );
  }

  /// `Refresh rates`
  String get profileCurrencyRefresh {
    return Intl.message(
      'Refresh rates',
      name: 'profileCurrencyRefresh',
      desc: '',
      args: [],
    );
  }

  /// `Hide home amounts`
  String get profileHideAmounts {
    return Intl.message(
      'Hide home amounts',
      name: 'profileHideAmounts',
      desc: '',
      args: [],
    );
  }

  /// `When hidden, home amounts show as ••••`
  String get profileHideAmountsSubtitle {
    return Intl.message(
      'When hidden, home amounts show as ••••',
      name: 'profileHideAmountsSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Bill colors`
  String get profileFinanceColors {
    return Intl.message(
      'Bill colors',
      name: 'profileFinanceColors',
      desc: '',
      args: [],
    );
  }

  /// `Customize income / expense / holiday colors`
  String get profileFinanceColorsSubtitle {
    return Intl.message(
      'Customize income / expense / holiday colors',
      name: 'profileFinanceColorsSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `About`
  String get profileAbout {
    return Intl.message('About', name: 'profileAbout', desc: '', args: []);
  }

  /// `Help`
  String get profileHelp {
    return Intl.message('Help', name: 'profileHelp', desc: '', args: []);
  }

  /// `Donate`
  String get profileDonate {
    return Intl.message('Donate', name: 'profileDonate', desc: '', args: []);
  }

  /// `WeChat`
  String get profileDonateWechat {
    return Intl.message(
      'WeChat',
      name: 'profileDonateWechat',
      desc: '',
      args: [],
    );
  }

  /// `Alipay`
  String get profileDonateAlipay {
    return Intl.message(
      'Alipay',
      name: 'profileDonateAlipay',
      desc: '',
      args: [],
    );
  }

  /// `Long press to save the QR code, or scan it with another device.`
  String get profileDonateScanHint {
    return Intl.message(
      'Long press to save the QR code, or scan it with another device.',
      name: 'profileDonateScanHint',
      desc: '',
      args: [],
    );
  }

  /// `Donation items are unavailable right now. Please try again later.`
  String get profileDonateIapUnavailable {
    return Intl.message(
      'Donation items are unavailable right now. Please try again later.',
      name: 'profileDonateIapUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `Couldn't start the donation. Please try again later.`
  String get profileDonateIapStartFailed {
    return Intl.message(
      'Couldn\'t start the donation. Please try again later.',
      name: 'profileDonateIapStartFailed',
      desc: '',
      args: [],
    );
  }

  /// `Thanks for your support!`
  String get profileDonateThanks {
    return Intl.message(
      'Thanks for your support!',
      name: 'profileDonateThanks',
      desc: '',
      args: [],
    );
  }

  /// `Saving…`
  String get imageSaveSaving {
    return Intl.message('Saving…', name: 'imageSaveSaving', desc: '', args: []);
  }

  /// `Download started`
  String get imageSaveDownloadStarted {
    return Intl.message(
      'Download started',
      name: 'imageSaveDownloadStarted',
      desc: '',
      args: [],
    );
  }

  /// `Download failed`
  String get imageSaveDownloadFailed {
    return Intl.message(
      'Download failed',
      name: 'imageSaveDownloadFailed',
      desc: '',
      args: [],
    );
  }

  /// `Saved to photos`
  String get imageSaveSuccess {
    return Intl.message(
      'Saved to photos',
      name: 'imageSaveSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Could not save the image. Please try again.`
  String get imageSaveFailed {
    return Intl.message(
      'Could not save the image. Please try again.',
      name: 'imageSaveFailed',
      desc: '',
      args: [],
    );
  }

  /// `Saving images is not supported on this platform. Please take a screenshot or download it instead.`
  String get imageSaveUnsupported {
    return Intl.message(
      'Saving images is not supported on this platform. Please take a screenshot or download it instead.',
      name: 'imageSaveUnsupported',
      desc: '',
      args: [],
    );
  }

  /// `Log out`
  String get profileLogout {
    return Intl.message('Log out', name: 'profileLogout', desc: '', args: []);
  }

  /// `Delete account`
  String get profileDeleteAccount {
    return Intl.message(
      'Delete account',
      name: 'profileDeleteAccount',
      desc: '',
      args: [],
    );
  }

  /// `Account deletion cannot be undone. Groups and books used only by you will be deleted; shared groups will remain for other members, and owner permissions will be transferred to another member.`
  String get profileDeleteAccountWarning {
    return Intl.message(
      'Account deletion cannot be undone. Groups and books used only by you will be deleted; shared groups will remain for other members, and owner permissions will be transferred to another member.',
      name: 'profileDeleteAccountWarning',
      desc: '',
      args: [],
    );
  }

  /// `Current password`
  String get profileDeleteAccountPasswordLabel {
    return Intl.message(
      'Current password',
      name: 'profileDeleteAccountPasswordLabel',
      desc: '',
      args: [],
    );
  }

  /// `Enter your current password`
  String get profileDeleteAccountPasswordRequired {
    return Intl.message(
      'Enter your current password',
      name: 'profileDeleteAccountPasswordRequired',
      desc: '',
      args: [],
    );
  }

  /// `Show password`
  String get profileDeleteAccountShowPassword {
    return Intl.message(
      'Show password',
      name: 'profileDeleteAccountShowPassword',
      desc: '',
      args: [],
    );
  }

  /// `Hide password`
  String get profileDeleteAccountHidePassword {
    return Intl.message(
      'Hide password',
      name: 'profileDeleteAccountHidePassword',
      desc: '',
      args: [],
    );
  }

  /// `Delete account`
  String get profileDeleteAccountConfirm {
    return Intl.message(
      'Delete account',
      name: 'profileDeleteAccountConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Failed to delete the account. Please try again later.`
  String get profileDeleteAccountFailed {
    return Intl.message(
      'Failed to delete the account. Please try again later.',
      name: 'profileDeleteAccountFailed',
      desc: '',
      args: [],
    );
  }

  /// `Select language`
  String get profileSelectLanguage {
    return Intl.message(
      'Select language',
      name: 'profileSelectLanguage',
      desc: '',
      args: [],
    );
  }

  /// `Dashboard`
  String get navDashboard {
    return Intl.message('Dashboard', name: 'navDashboard', desc: '', args: []);
  }

  /// `Bills`
  String get navBills {
    return Intl.message('Bills', name: 'navBills', desc: '', args: []);
  }

  /// `Stats`
  String get navStats {
    return Intl.message('Stats', name: 'navStats', desc: '', args: []);
  }

  /// `Mine`
  String get navProfile {
    return Intl.message('Mine', name: 'navProfile', desc: '', args: []);
  }

  /// `In development`
  String get navInDevelopment {
    return Intl.message(
      'In development',
      name: 'navInDevelopment',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get commonLanguage {
    return Intl.message('Language', name: 'commonLanguage', desc: '', args: []);
  }

  /// `中文`
  String get commonChinese {
    return Intl.message('中文', name: 'commonChinese', desc: '', args: []);
  }

  /// `English`
  String get commonEnglish {
    return Intl.message('English', name: 'commonEnglish', desc: '', args: []);
  }

  /// `Account Management`
  String get accountsTitle {
    return Intl.message(
      'Account Management',
      name: 'accountsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Add Account`
  String get accountsAddTitle {
    return Intl.message(
      'Add Account',
      name: 'accountsAddTitle',
      desc: '',
      args: [],
    );
  }

  /// `Edit Account`
  String get accountsEditTitle {
    return Intl.message(
      'Edit Account',
      name: 'accountsEditTitle',
      desc: '',
      args: [],
    );
  }

  /// `No accounts yet. Tap + in the top right to add one.`
  String get accountsEmptyHint {
    return Intl.message(
      'No accounts yet. Tap + in the top right to add one.',
      name: 'accountsEmptyHint',
      desc: '',
      args: [],
    );
  }

  /// `Please select a ledger/group first`
  String get accountsSelectBookGroup {
    return Intl.message(
      'Please select a ledger/group first',
      name: 'accountsSelectBookGroup',
      desc: '',
      args: [],
    );
  }

  /// `Please select a ledger before adjusting the balance`
  String get accountsSelectBookForAdjust {
    return Intl.message(
      'Please select a ledger before adjusting the balance',
      name: 'accountsSelectBookForAdjust',
      desc: '',
      args: [],
    );
  }

  /// `Recycle Bin`
  String get accountsRecycleBin {
    return Intl.message(
      'Recycle Bin',
      name: 'accountsRecycleBin',
      desc: '',
      args: [],
    );
  }

  /// `Recycle bin is empty`
  String get accountsRecycleBinEmpty {
    return Intl.message(
      'Recycle bin is empty',
      name: 'accountsRecycleBinEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Adjust Balance · {name}`
  String accountsAdjustTitle(Object name) {
    return Intl.message(
      'Adjust Balance · $name',
      name: 'accountsAdjustTitle',
      desc: '',
      args: [name],
    );
  }

  /// `Balance adjusted`
  String get accountsBalanceAdjusted {
    return Intl.message(
      'Balance adjusted',
      name: 'accountsBalanceAdjusted',
      desc: '',
      args: [],
    );
  }

  /// `Move to Recycle Bin`
  String get accountsMoveToRecycleBinTitle {
    return Intl.message(
      'Move to Recycle Bin',
      name: 'accountsMoveToRecycleBinTitle',
      desc: '',
      args: [],
    );
  }

  /// `Move "{name}" to the recycle bin?`
  String accountsMoveToRecycleBinConfirm(Object name) {
    return Intl.message(
      'Move "$name" to the recycle bin?',
      name: 'accountsMoveToRecycleBinConfirm',
      desc: '',
      args: [name],
    );
  }

  /// `Move in`
  String get accountsMoveIn {
    return Intl.message('Move in', name: 'accountsMoveIn', desc: '', args: []);
  }

  /// `Delete Permanently`
  String get accountsDeletePermanently {
    return Intl.message(
      'Delete Permanently',
      name: 'accountsDeletePermanently',
      desc: '',
      args: [],
    );
  }

  /// `Permanently delete "{name}"? This cannot be undone.`
  String accountsDeleteConfirm(Object name) {
    return Intl.message(
      'Permanently delete "$name"? This cannot be undone.',
      name: 'accountsDeleteConfirm',
      desc: '',
      args: [name],
    );
  }

  /// `Delete`
  String get accountsDelete {
    return Intl.message('Delete', name: 'accountsDelete', desc: '', args: []);
  }

  /// `Restore`
  String get accountsRestore {
    return Intl.message('Restore', name: 'accountsRestore', desc: '', args: []);
  }

  /// `this account`
  String get accountsDefaultName {
    return Intl.message(
      'this account',
      name: 'accountsDefaultName',
      desc: '',
      args: [],
    );
  }

  /// `Unnamed Account`
  String get accountsUnnamed {
    return Intl.message(
      'Unnamed Account',
      name: 'accountsUnnamed',
      desc: '',
      args: [],
    );
  }

  /// `Cash Account`
  String get accountsTypeCash {
    return Intl.message(
      'Cash Account',
      name: 'accountsTypeCash',
      desc: '',
      args: [],
    );
  }

  /// `Credit Card`
  String get accountsTypeCredit {
    return Intl.message(
      'Credit Card',
      name: 'accountsTypeCredit',
      desc: '',
      args: [],
    );
  }

  /// `Asset Account`
  String get accountsTypeAsset {
    return Intl.message(
      'Asset Account',
      name: 'accountsTypeAsset',
      desc: '',
      args: [],
    );
  }

  /// `Loan Account`
  String get accountsTypeLoan {
    return Intl.message(
      'Loan Account',
      name: 'accountsTypeLoan',
      desc: '',
      args: [],
    );
  }

  /// `Other Account`
  String get accountsTypeOther {
    return Intl.message(
      'Other Account',
      name: 'accountsTypeOther',
      desc: '',
      args: [],
    );
  }

  /// `Net Worth`
  String get accountsNetWorth {
    return Intl.message(
      'Net Worth',
      name: 'accountsNetWorth',
      desc: '',
      args: [],
    );
  }

  /// `Assets`
  String get accountsAssets {
    return Intl.message('Assets', name: 'accountsAssets', desc: '', args: []);
  }

  /// `Liabilities`
  String get accountsLiabilities {
    return Intl.message(
      'Liabilities',
      name: 'accountsLiabilities',
      desc: '',
      args: [],
    );
  }

  /// `In net worth`
  String get accountsIncludedInNetWorth {
    return Intl.message(
      'In net worth',
      name: 'accountsIncludedInNetWorth',
      desc: '',
      args: [],
    );
  }

  /// `Limit`
  String get accountsCreditLimit {
    return Intl.message(
      'Limit',
      name: 'accountsCreditLimit',
      desc: '',
      args: [],
    );
  }

  /// `Used`
  String get accountsUsed {
    return Intl.message('Used', name: 'accountsUsed', desc: '', args: []);
  }

  /// `Statement day {day}`
  String accountsBillDayChip(Object day) {
    return Intl.message(
      'Statement day $day',
      name: 'accountsBillDayChip',
      desc: '',
      args: [day],
    );
  }

  /// `Repayment day {day}`
  String accountsRepayDayChip(Object day) {
    return Intl.message(
      'Repayment day $day',
      name: 'accountsRepayDayChip',
      desc: '',
      args: [day],
    );
  }

  /// `Rate {rate}`
  String accountsAprChip(Object rate) {
    return Intl.message(
      'Rate $rate',
      name: 'accountsAprChip',
      desc: '',
      args: [rate],
    );
  }

  /// `Adjust Balance`
  String get accountsAdjustBalance {
    return Intl.message(
      'Adjust Balance',
      name: 'accountsAdjustBalance',
      desc: '',
      args: [],
    );
  }

  /// `Adjust Balance (select a ledger first)`
  String get accountsAdjustBalanceNeedBook {
    return Intl.message(
      'Adjust Balance (select a ledger first)',
      name: 'accountsAdjustBalanceNeedBook',
      desc: '',
      args: [],
    );
  }

  /// `Exp`
  String get accountsDotExpense {
    return Intl.message('Exp', name: 'accountsDotExpense', desc: '', args: []);
  }

  /// `Inc`
  String get accountsDotIncome {
    return Intl.message('Inc', name: 'accountsDotIncome', desc: '', args: []);
  }

  /// `Out`
  String get accountsDotTransferOut {
    return Intl.message(
      'Out',
      name: 'accountsDotTransferOut',
      desc: '',
      args: [],
    );
  }

  /// `In`
  String get accountsDotTransferIn {
    return Intl.message(
      'In',
      name: 'accountsDotTransferIn',
      desc: '',
      args: [],
    );
  }

  /// `Expense`
  String get accountsToggleCanExpense {
    return Intl.message(
      'Expense',
      name: 'accountsToggleCanExpense',
      desc: '',
      args: [],
    );
  }

  /// `Income`
  String get accountsToggleCanIncome {
    return Intl.message(
      'Income',
      name: 'accountsToggleCanIncome',
      desc: '',
      args: [],
    );
  }

  /// `Transfer out`
  String get accountsToggleCanTransferOut {
    return Intl.message(
      'Transfer out',
      name: 'accountsToggleCanTransferOut',
      desc: '',
      args: [],
    );
  }

  /// `Transfer in`
  String get accountsToggleCanTransferIn {
    return Intl.message(
      'Transfer in',
      name: 'accountsToggleCanTransferIn',
      desc: '',
      args: [],
    );
  }

  /// `Include in net worth`
  String get accountsToggleInclude {
    return Intl.message(
      'Include in net worth',
      name: 'accountsToggleInclude',
      desc: '',
      args: [],
    );
  }

  /// `Enable`
  String get accountsToggleEnable {
    return Intl.message(
      'Enable',
      name: 'accountsToggleEnable',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid amount`
  String get accountsInvalidAmount {
    return Intl.message(
      'Please enter a valid amount',
      name: 'accountsInvalidAmount',
      desc: '',
      args: [],
    );
  }

  /// `Current balance {amount}`
  String accountsCurrentBalance(Object amount) {
    return Intl.message(
      'Current balance $amount',
      name: 'accountsCurrentBalance',
      desc: '',
      args: [amount],
    );
  }

  /// `Adjusted amount`
  String get accountsAdjustedAmount {
    return Intl.message(
      'Adjusted amount',
      name: 'accountsAdjustedAmount',
      desc: '',
      args: [],
    );
  }

  /// `Actual amount after adjustment`
  String get accountsAdjustedAmountHint {
    return Intl.message(
      'Actual amount after adjustment',
      name: 'accountsAdjustedAmountHint',
      desc: '',
      args: [],
    );
  }

  /// `Time`
  String get accountsOccurredTime {
    return Intl.message(
      'Time',
      name: 'accountsOccurredTime',
      desc: '',
      args: [],
    );
  }

  /// `Title (optional)`
  String get accountsTitleOptional {
    return Intl.message(
      'Title (optional)',
      name: 'accountsTitleOptional',
      desc: '',
      args: [],
    );
  }

  /// `Balance adjustment`
  String get accountsBalanceAdjustHint {
    return Intl.message(
      'Balance adjustment',
      name: 'accountsBalanceAdjustHint',
      desc: '',
      args: [],
    );
  }

  /// `Remark (optional)`
  String get accountsRemarkOptional {
    return Intl.message(
      'Remark (optional)',
      name: 'accountsRemarkOptional',
      desc: '',
      args: [],
    );
  }

  /// `Remark`
  String get accountsRemarkHint {
    return Intl.message(
      'Remark',
      name: 'accountsRemarkHint',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Adjustment`
  String get accountsConfirmAdjust {
    return Intl.message(
      'Confirm Adjustment',
      name: 'accountsConfirmAdjust',
      desc: '',
      args: [],
    );
  }

  /// `Please enter an account name`
  String get accountsNameRequired {
    return Intl.message(
      'Please enter an account name',
      name: 'accountsNameRequired',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a currency`
  String get accountsCurrencyRequired {
    return Intl.message(
      'Please enter a currency',
      name: 'accountsCurrencyRequired',
      desc: '',
      args: [],
    );
  }

  /// `Account name`
  String get accountsFieldName {
    return Intl.message(
      'Account name',
      name: 'accountsFieldName',
      desc: '',
      args: [],
    );
  }

  /// `e.g. CMB debit card`
  String get accountsFieldNameHint {
    return Intl.message(
      'e.g. CMB debit card',
      name: 'accountsFieldNameHint',
      desc: '',
      args: [],
    );
  }

  /// `Account type`
  String get accountsFieldType {
    return Intl.message(
      'Account type',
      name: 'accountsFieldType',
      desc: '',
      args: [],
    );
  }

  /// `Balance`
  String get accountsFieldBalance {
    return Intl.message(
      'Balance',
      name: 'accountsFieldBalance',
      desc: '',
      args: [],
    );
  }

  /// `Initial balance`
  String get accountsFieldInitialBalance {
    return Intl.message(
      'Initial balance',
      name: 'accountsFieldInitialBalance',
      desc: '',
      args: [],
    );
  }

  /// `Unused: 0; debt as negative (not the limit)`
  String get accountsFieldBalanceLiabilityHint {
    return Intl.message(
      'Unused: 0; debt as negative (not the limit)',
      name: 'accountsFieldBalanceLiabilityHint',
      desc: '',
      args: [],
    );
  }

  /// `Currency`
  String get accountsFieldCurrency {
    return Intl.message(
      'Currency',
      name: 'accountsFieldCurrency',
      desc: '',
      args: [],
    );
  }

  /// `Card number (optional)`
  String get accountsFieldCardNo {
    return Intl.message(
      'Card number (optional)',
      name: 'accountsFieldCardNo',
      desc: '',
      args: [],
    );
  }

  /// `Used to show the last four digits`
  String get accountsFieldCardNoHint {
    return Intl.message(
      'Used to show the last four digits',
      name: 'accountsFieldCardNoHint',
      desc: '',
      args: [],
    );
  }

  /// `Credit/loan limit`
  String get accountsFieldCreditLimit {
    return Intl.message(
      'Credit/loan limit',
      name: 'accountsFieldCreditLimit',
      desc: '',
      args: [],
    );
  }

  /// `e.g. 50000`
  String get accountsFieldCreditLimitHint {
    return Intl.message(
      'e.g. 50000',
      name: 'accountsFieldCreditLimitHint',
      desc: '',
      args: [],
    );
  }

  /// `Repayment day (yyyy-MM-dd)`
  String get accountsFieldRepayDay {
    return Intl.message(
      'Repayment day (yyyy-MM-dd)',
      name: 'accountsFieldRepayDay',
      desc: '',
      args: [],
    );
  }

  /// `Statement day (yyyy-MM-dd)`
  String get accountsFieldBillDay {
    return Intl.message(
      'Statement day (yyyy-MM-dd)',
      name: 'accountsFieldBillDay',
      desc: '',
      args: [],
    );
  }

  /// `Annual rate (APR)`
  String get accountsFieldApr {
    return Intl.message(
      'Annual rate (APR)',
      name: 'accountsFieldApr',
      desc: '',
      args: [],
    );
  }

  /// `e.g. 0.045`
  String get accountsFieldAprHint {
    return Intl.message(
      'e.g. 0.045',
      name: 'accountsFieldAprHint',
      desc: '',
      args: [],
    );
  }

  /// `Save Changes`
  String get accountsSaveChanges {
    return Intl.message(
      'Save Changes',
      name: 'accountsSaveChanges',
      desc: '',
      args: [],
    );
  }

  /// `Create Account`
  String get accountsCreateAccount {
    return Intl.message(
      'Create Account',
      name: 'accountsCreateAccount',
      desc: '',
      args: [],
    );
  }

  /// `Filter`
  String get billsFilterTitle {
    return Intl.message('Filter', name: 'billsFilterTitle', desc: '', args: []);
  }

  /// `Delete bill`
  String get billsDeleteTitle {
    return Intl.message(
      'Delete bill',
      name: 'billsDeleteTitle',
      desc: '',
      args: [],
    );
  }

  /// `Delete "{title}"? This action cannot be undone.`
  String billsDeleteConfirm(Object title) {
    return Intl.message(
      'Delete "$title"? This action cannot be undone.',
      name: 'billsDeleteConfirm',
      desc: '',
      args: [title],
    );
  }

  /// `Delete`
  String get billsDelete {
    return Intl.message('Delete', name: 'billsDelete', desc: '', args: []);
  }

  /// `Copy`
  String get billsCopy {
    return Intl.message('Copy', name: 'billsCopy', desc: '', args: []);
  }

  /// `{month} cycle`
  String billsBillingCycle(Object month) {
    return Intl.message(
      '$month cycle',
      name: 'billsBillingCycle',
      desc: '',
      args: [month],
    );
  }

  /// `Expense`
  String get billsExpense {
    return Intl.message('Expense', name: 'billsExpense', desc: '', args: []);
  }

  /// `Income`
  String get billsIncome {
    return Intl.message('Income', name: 'billsIncome', desc: '', args: []);
  }

  /// `Balance`
  String get billsBalance {
    return Intl.message('Balance', name: 'billsBalance', desc: '', args: []);
  }

  /// `Please select a ledger first`
  String get billsSelectBookFirst {
    return Intl.message(
      'Please select a ledger first',
      name: 'billsSelectBookFirst',
      desc: '',
      args: [],
    );
  }

  /// `No bills in this cycle`
  String get billsEmpty {
    return Intl.message(
      'No bills in this cycle',
      name: 'billsEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Exp {amount}`
  String billsDayExpense(Object amount) {
    return Intl.message(
      'Exp $amount',
      name: 'billsDayExpense',
      desc: '',
      args: [amount],
    );
  }

  /// `Inc {amount}`
  String billsDayIncome(Object amount) {
    return Intl.message(
      'Inc $amount',
      name: 'billsDayIncome',
      desc: '',
      args: [amount],
    );
  }

  /// `Pending`
  String get billsPendingConfirm {
    return Intl.message(
      'Pending',
      name: 'billsPendingConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Mon`
  String get billsWeekdayMon {
    return Intl.message('Mon', name: 'billsWeekdayMon', desc: '', args: []);
  }

  /// `Tue`
  String get billsWeekdayTue {
    return Intl.message('Tue', name: 'billsWeekdayTue', desc: '', args: []);
  }

  /// `Wed`
  String get billsWeekdayWed {
    return Intl.message('Wed', name: 'billsWeekdayWed', desc: '', args: []);
  }

  /// `Thu`
  String get billsWeekdayThu {
    return Intl.message('Thu', name: 'billsWeekdayThu', desc: '', args: []);
  }

  /// `Fri`
  String get billsWeekdayFri {
    return Intl.message('Fri', name: 'billsWeekdayFri', desc: '', args: []);
  }

  /// `Sat`
  String get billsWeekdaySat {
    return Intl.message('Sat', name: 'billsWeekdaySat', desc: '', args: []);
  }

  /// `Sun`
  String get billsWeekdaySun {
    return Intl.message('Sun', name: 'billsWeekdaySun', desc: '', args: []);
  }

  /// `Bill`
  String get billsBillDefaultTitle {
    return Intl.message(
      'Bill',
      name: 'billsBillDefaultTitle',
      desc: '',
      args: [],
    );
  }

  /// `Bill details`
  String get billsDetailTitle {
    return Intl.message(
      'Bill details',
      name: 'billsDetailTitle',
      desc: '',
      args: [],
    );
  }

  /// `Category breakdown`
  String get billsCategoryDetail {
    return Intl.message(
      'Category breakdown',
      name: 'billsCategoryDetail',
      desc: '',
      args: [],
    );
  }

  /// `Uncategorized`
  String get billsUncategorized {
    return Intl.message(
      'Uncategorized',
      name: 'billsUncategorized',
      desc: '',
      args: [],
    );
  }

  /// `From account`
  String get billsTransferOutAccount {
    return Intl.message(
      'From account',
      name: 'billsTransferOutAccount',
      desc: '',
      args: [],
    );
  }

  /// `To account`
  String get billsTransferInAccount {
    return Intl.message(
      'To account',
      name: 'billsTransferInAccount',
      desc: '',
      args: [],
    );
  }

  /// `Received amount`
  String get billsReceivedAmount {
    return Intl.message(
      'Received amount',
      name: 'billsReceivedAmount',
      desc: '',
      args: [],
    );
  }

  /// `Payee`
  String get billsPayee {
    return Intl.message('Payee', name: 'billsPayee', desc: '', args: []);
  }

  /// `Tags`
  String get billsTags {
    return Intl.message('Tags', name: 'billsTags', desc: '', args: []);
  }

  /// `Members`
  String get billsMembers {
    return Intl.message('Members', name: 'billsMembers', desc: '', args: []);
  }

  /// `Extra charges`
  String get billsExtras {
    return Intl.message(
      'Extra charges',
      name: 'billsExtras',
      desc: '',
      args: [],
    );
  }

  /// `Note`
  String get billsRemark {
    return Intl.message('Note', name: 'billsRemark', desc: '', args: []);
  }

  /// `Attachments`
  String get billsAttachments {
    return Intl.message(
      'Attachments',
      name: 'billsAttachments',
      desc: '',
      args: [],
    );
  }

  /// `Fee`
  String get billsFee {
    return Intl.message('Fee', name: 'billsFee', desc: '', args: []);
  }

  /// `Discount`
  String get billsDiscount {
    return Intl.message('Discount', name: 'billsDiscount', desc: '', args: []);
  }

  /// `Charge`
  String get billsCharge {
    return Intl.message('Charge', name: 'billsCharge', desc: '', args: []);
  }

  /// `Out`
  String get billsSideOut {
    return Intl.message('Out', name: 'billsSideOut', desc: '', args: []);
  }

  /// `In`
  String get billsSideIn {
    return Intl.message('In', name: 'billsSideIn', desc: '', args: []);
  }

  /// `{type} ({side})`
  String billsExtraWithSide(Object type, Object side) {
    return Intl.message(
      '$type ($side)',
      name: 'billsExtraWithSide',
      desc: '',
      args: [type, side],
    );
  }

  /// `No attachments`
  String get billsNoAttachments {
    return Intl.message(
      'No attachments',
      name: 'billsNoAttachments',
      desc: '',
      args: [],
    );
  }

  /// `Close`
  String get billsClose {
    return Intl.message('Close', name: 'billsClose', desc: '', args: []);
  }

  /// `Edit`
  String get billsEdit {
    return Intl.message('Edit', name: 'billsEdit', desc: '', args: []);
  }

  /// `Unconfirm`
  String get billsUnconfirm {
    return Intl.message(
      'Unconfirm',
      name: 'billsUnconfirm',
      desc: '',
      args: [],
    );
  }

  /// `Title`
  String get billsFilterByTitle {
    return Intl.message(
      'Title',
      name: 'billsFilterByTitle',
      desc: '',
      args: [],
    );
  }

  /// `Search by bill title`
  String get billsFilterTitleHint {
    return Intl.message(
      'Search by bill title',
      name: 'billsFilterTitleHint',
      desc: '',
      args: [],
    );
  }

  /// `Bill type`
  String get billsFilterBillType {
    return Intl.message(
      'Bill type',
      name: 'billsFilterBillType',
      desc: '',
      args: [],
    );
  }

  /// `Amount range`
  String get billsFilterAmountRange {
    return Intl.message(
      'Amount range',
      name: 'billsFilterAmountRange',
      desc: '',
      args: [],
    );
  }

  /// `Min`
  String get billsFilterMin {
    return Intl.message('Min', name: 'billsFilterMin', desc: '', args: []);
  }

  /// `Max`
  String get billsFilterMax {
    return Intl.message('Max', name: 'billsFilterMax', desc: '', args: []);
  }

  /// `Confirmation status`
  String get billsFilterConfirmStatus {
    return Intl.message(
      'Confirmation status',
      name: 'billsFilterConfirmStatus',
      desc: '',
      args: [],
    );
  }

  /// `Confirmed`
  String get billsFilterConfirmed {
    return Intl.message(
      'Confirmed',
      name: 'billsFilterConfirmed',
      desc: '',
      args: [],
    );
  }

  /// `Unconfirmed`
  String get billsFilterUnconfirmed {
    return Intl.message(
      'Unconfirmed',
      name: 'billsFilterUnconfirmed',
      desc: '',
      args: [],
    );
  }

  /// `Include in stats`
  String get billsFilterIncludeStatus {
    return Intl.message(
      'Include in stats',
      name: 'billsFilterIncludeStatus',
      desc: '',
      args: [],
    );
  }

  /// `Included`
  String get billsFilterIncluded {
    return Intl.message(
      'Included',
      name: 'billsFilterIncluded',
      desc: '',
      args: [],
    );
  }

  /// `Excluded`
  String get billsFilterExcluded {
    return Intl.message(
      'Excluded',
      name: 'billsFilterExcluded',
      desc: '',
      args: [],
    );
  }

  /// `Reset`
  String get billsReset {
    return Intl.message('Reset', name: 'billsReset', desc: '', args: []);
  }

  /// `Apply`
  String get billsApply {
    return Intl.message('Apply', name: 'billsApply', desc: '', args: []);
  }

  /// `Any`
  String get billsFilterAny {
    return Intl.message('Any', name: 'billsFilterAny', desc: '', args: []);
  }

  /// `Please select a ledger before adding a bill`
  String get billEditorSelectBookFirst {
    return Intl.message(
      'Please select a ledger before adding a bill',
      name: 'billEditorSelectBookFirst',
      desc: '',
      args: [],
    );
  }

  /// `Edit bill`
  String get billEditorEditTitle {
    return Intl.message(
      'Edit bill',
      name: 'billEditorEditTitle',
      desc: '',
      args: [],
    );
  }

  /// `Add a bill`
  String get billEditorNewTitle {
    return Intl.message(
      'Add a bill',
      name: 'billEditorNewTitle',
      desc: '',
      args: [],
    );
  }

  /// `Transfer amount`
  String get billEditorTransferAmount {
    return Intl.message(
      'Transfer amount',
      name: 'billEditorTransferAmount',
      desc: '',
      args: [],
    );
  }

  /// `{type} amount`
  String billEditorAmountOf(Object type) {
    return Intl.message(
      '$type amount',
      name: 'billEditorAmountOf',
      desc: '',
      args: [type],
    );
  }

  /// `Amount is the sum of the category breakdown below`
  String get billEditorAmountHint {
    return Intl.message(
      'Amount is the sum of the category breakdown below',
      name: 'billEditorAmountHint',
      desc: '',
      args: [],
    );
  }

  /// `Account`
  String get billEditorAccount {
    return Intl.message(
      'Account',
      name: 'billEditorAccount',
      desc: '',
      args: [],
    );
  }

  /// `Select an account`
  String get billEditorSelectAccountHint {
    return Intl.message(
      'Select an account',
      name: 'billEditorSelectAccountHint',
      desc: '',
      args: [],
    );
  }

  /// `Select account`
  String get billEditorSelectAccount {
    return Intl.message(
      'Select account',
      name: 'billEditorSelectAccount',
      desc: '',
      args: [],
    );
  }

  /// `From account`
  String get billEditorTransferOutAccount {
    return Intl.message(
      'From account',
      name: 'billEditorTransferOutAccount',
      desc: '',
      args: [],
    );
  }

  /// `To account`
  String get billEditorTransferInAccount {
    return Intl.message(
      'To account',
      name: 'billEditorTransferInAccount',
      desc: '',
      args: [],
    );
  }

  /// `Select the from account`
  String get billEditorSelectTransferOutHint {
    return Intl.message(
      'Select the from account',
      name: 'billEditorSelectTransferOutHint',
      desc: '',
      args: [],
    );
  }

  /// `Select the to account`
  String get billEditorSelectTransferInHint {
    return Intl.message(
      'Select the to account',
      name: 'billEditorSelectTransferInHint',
      desc: '',
      args: [],
    );
  }

  /// `Select from account`
  String get billEditorSelectTransferOut {
    return Intl.message(
      'Select from account',
      name: 'billEditorSelectTransferOut',
      desc: '',
      args: [],
    );
  }

  /// `Select to account`
  String get billEditorSelectTransferIn {
    return Intl.message(
      'Select to account',
      name: 'billEditorSelectTransferIn',
      desc: '',
      args: [],
    );
  }

  /// `Payee`
  String get billEditorPayee {
    return Intl.message('Payee', name: 'billEditorPayee', desc: '', args: []);
  }

  /// `Optional`
  String get billEditorOptional {
    return Intl.message(
      'Optional',
      name: 'billEditorOptional',
      desc: '',
      args: [],
    );
  }

  /// `Select payee`
  String get billEditorSelectPayee {
    return Intl.message(
      'Select payee',
      name: 'billEditorSelectPayee',
      desc: '',
      args: [],
    );
  }

  /// `Linked reimbursement order`
  String get billEditorOrder {
    return Intl.message(
      'Linked reimbursement order',
      name: 'billEditorOrder',
      desc: '',
      args: [],
    );
  }

  /// `Required`
  String get billEditorRequired {
    return Intl.message(
      'Required',
      name: 'billEditorRequired',
      desc: '',
      args: [],
    );
  }

  /// `Select an active reimbursement order`
  String get billEditorSelectOrder {
    return Intl.message(
      'Select an active reimbursement order',
      name: 'billEditorSelectOrder',
      desc: '',
      args: [],
    );
  }

  /// `Time`
  String get billEditorTime {
    return Intl.message('Time', name: 'billEditorTime', desc: '', args: []);
  }

  /// `Trade time`
  String get billEditorTradeTime {
    return Intl.message(
      'Trade time',
      name: 'billEditorTradeTime',
      desc: '',
      args: [],
    );
  }

  /// `Select tags`
  String get billEditorSelectTags {
    return Intl.message(
      'Select tags',
      name: 'billEditorSelectTags',
      desc: '',
      args: [],
    );
  }

  /// `Tags`
  String get billEditorTags {
    return Intl.message('Tags', name: 'billEditorTags', desc: '', args: []);
  }

  /// `Add tags`
  String get billEditorAddTags {
    return Intl.message(
      'Add tags',
      name: 'billEditorAddTags',
      desc: '',
      args: [],
    );
  }

  /// `Members`
  String get billEditorMembers {
    return Intl.message(
      'Members',
      name: 'billEditorMembers',
      desc: '',
      args: [],
    );
  }

  /// `Select members`
  String get billEditorSelectMembers {
    return Intl.message(
      'Select members',
      name: 'billEditorSelectMembers',
      desc: '',
      args: [],
    );
  }

  /// `Please select`
  String get billEditorSelectHint {
    return Intl.message(
      'Please select',
      name: 'billEditorSelectHint',
      desc: '',
      args: [],
    );
  }

  /// `Title`
  String get billEditorTitle {
    return Intl.message('Title', name: 'billEditorTitle', desc: '', args: []);
  }

  /// `Enter a title`
  String get billEditorTitleHint {
    return Intl.message(
      'Enter a title',
      name: 'billEditorTitleHint',
      desc: '',
      args: [],
    );
  }

  /// `Default: {name}`
  String billEditorTitleDefault(Object name) {
    return Intl.message(
      'Default: $name',
      name: 'billEditorTitleDefault',
      desc: '',
      args: [name],
    );
  }

  /// `Note`
  String get billEditorRemark {
    return Intl.message('Note', name: 'billEditorRemark', desc: '', args: []);
  }

  /// `Add a note…`
  String get billEditorRemarkHint {
    return Intl.message(
      'Add a note…',
      name: 'billEditorRemarkHint',
      desc: '',
      args: [],
    );
  }

  /// `Confirmed`
  String get billEditorConfirmed {
    return Intl.message(
      'Confirmed',
      name: 'billEditorConfirmed',
      desc: '',
      args: [],
    );
  }

  /// `Unconfirmed bills are excluded from the balance`
  String get billEditorConfirmedSubtitle {
    return Intl.message(
      'Unconfirmed bills are excluded from the balance',
      name: 'billEditorConfirmedSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Include in stats`
  String get billEditorInclude {
    return Intl.message(
      'Include in stats',
      name: 'billEditorInclude',
      desc: '',
      args: [],
    );
  }

  /// `When off, excluded from income/expense stats`
  String get billEditorIncludeSubtitle {
    return Intl.message(
      'When off, excluded from income/expense stats',
      name: 'billEditorIncludeSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Save changes`
  String get billEditorSaveEdit {
    return Intl.message(
      'Save changes',
      name: 'billEditorSaveEdit',
      desc: '',
      args: [],
    );
  }

  /// `Save bill`
  String get billEditorSaveNew {
    return Intl.message(
      'Save bill',
      name: 'billEditorSaveNew',
      desc: '',
      args: [],
    );
  }

  /// `Discard changes?`
  String get billEditorDiscardTitle {
    return Intl.message(
      'Discard changes?',
      name: 'billEditorDiscardTitle',
      desc: '',
      args: [],
    );
  }

  /// `The information you entered will be lost. This action cannot be undone.`
  String get billEditorDiscardMessage {
    return Intl.message(
      'The information you entered will be lost. This action cannot be undone.',
      name: 'billEditorDiscardMessage',
      desc: '',
      args: [],
    );
  }

  /// `Discard`
  String get billEditorDiscardConfirm {
    return Intl.message(
      'Discard',
      name: 'billEditorDiscardConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Attachments`
  String get billEditorAttachments {
    return Intl.message(
      'Attachments',
      name: 'billEditorAttachments',
      desc: '',
      args: [],
    );
  }

  /// `Add attachment`
  String get billEditorAddAttachment {
    return Intl.message(
      'Add attachment',
      name: 'billEditorAddAttachment',
      desc: '',
      args: [],
    );
  }

  /// `Choose photos`
  String get billEditorChoosePhoto {
    return Intl.message(
      'Choose photos',
      name: 'billEditorChoosePhoto',
      desc: '',
      args: [],
    );
  }

  /// `Choose files`
  String get billEditorChooseFile {
    return Intl.message(
      'Choose files',
      name: 'billEditorChooseFile',
      desc: '',
      args: [],
    );
  }

  /// `{count} attachments selected`
  String billEditorSelectedCount(Object count) {
    return Intl.message(
      '$count attachments selected',
      name: 'billEditorSelectedCount',
      desc: '',
      args: [count],
    );
  }

  /// `Some attachments cannot be read or exceed the size limit`
  String get billEditorAttachmentInvalid {
    return Intl.message(
      'Some attachments cannot be read or exceed the size limit',
      name: 'billEditorAttachmentInvalid',
      desc: '',
      args: [],
    );
  }

  /// `Could not select attachments. Please try again.`
  String get billEditorAttachmentPickFailed {
    return Intl.message(
      'Could not select attachments. Please try again.',
      name: 'billEditorAttachmentPickFailed',
      desc: '',
      args: [],
    );
  }

  /// `An attachment cannot be read. Please select it again.`
  String get billEditorAttachmentUnreadable {
    return Intl.message(
      'An attachment cannot be read. Please select it again.',
      name: 'billEditorAttachmentUnreadable',
      desc: '',
      args: [],
    );
  }

  /// `File access permission is missing. Update the app or contact an administrator.`
  String get billEditorAttachmentPermissionRequired {
    return Intl.message(
      'File access permission is missing. Update the app or contact an administrator.',
      name: 'billEditorAttachmentPermissionRequired',
      desc: '',
      args: [],
    );
  }

  /// `The attachment component did not load correctly. Restart the app and try again.`
  String get billEditorAttachmentPluginUnavailable {
    return Intl.message(
      'The attachment component did not load correctly. Restart the app and try again.',
      name: 'billEditorAttachmentPluginUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `Network error. Check your connection and try again.`
  String get billEditorSubmitNetworkFailed {
    return Intl.message(
      'Network error. Check your connection and try again.',
      name: 'billEditorSubmitNetworkFailed',
      desc: '',
      args: [],
    );
  }

  /// `Your session has expired. Please sign in again.`
  String get billEditorSubmitAuthFailed {
    return Intl.message(
      'Your session has expired. Please sign in again.',
      name: 'billEditorSubmitAuthFailed',
      desc: '',
      args: [],
    );
  }

  /// `Category breakdown`
  String get billEditorCategorySplit {
    return Intl.message(
      'Category breakdown',
      name: 'billEditorCategorySplit',
      desc: '',
      args: [],
    );
  }

  /// `{count} items`
  String billEditorItemCount(Object count) {
    return Intl.message(
      '$count items',
      name: 'billEditorItemCount',
      desc: '',
      args: [count],
    );
  }

  /// `Select category`
  String get billEditorSelectCategory {
    return Intl.message(
      'Select category',
      name: 'billEditorSelectCategory',
      desc: '',
      args: [],
    );
  }

  /// `Add category`
  String get billEditorAddCategory {
    return Intl.message(
      'Add category',
      name: 'billEditorAddCategory',
      desc: '',
      args: [],
    );
  }

  /// `Extra charges`
  String get billEditorExtras {
    return Intl.message(
      'Extra charges',
      name: 'billEditorExtras',
      desc: '',
      args: [],
    );
  }

  /// `Add fee/discount`
  String get billEditorAddExtra {
    return Intl.message(
      'Add fee/discount',
      name: 'billEditorAddExtra',
      desc: '',
      args: [],
    );
  }

  /// `Fee`
  String get billEditorFee {
    return Intl.message('Fee', name: 'billEditorFee', desc: '', args: []);
  }

  /// `Discount`
  String get billEditorDiscount {
    return Intl.message(
      'Discount',
      name: 'billEditorDiscount',
      desc: '',
      args: [],
    );
  }

  /// `Note`
  String get billEditorExtraRemark {
    return Intl.message(
      'Note',
      name: 'billEditorExtraRemark',
      desc: '',
      args: [],
    );
  }

  /// `e.g. inter-bank transfer fee`
  String get billEditorExtraRemarkHint {
    return Intl.message(
      'e.g. inter-bank transfer fee',
      name: 'billEditorExtraRemarkHint',
      desc: '',
      args: [],
    );
  }

  /// `Category`
  String get billEditorExtraCategory {
    return Intl.message(
      'Category',
      name: 'billEditorExtraCategory',
      desc: '',
      args: [],
    );
  }

  /// `Select category`
  String get billEditorSelectExtraCategory {
    return Intl.message(
      'Select category',
      name: 'billEditorSelectExtraCategory',
      desc: '',
      args: [],
    );
  }

  /// `Add or select a category before adding an extra charge`
  String get billEditorExtraCategoryRequired {
    return Intl.message(
      'Add or select a category before adding an extra charge',
      name: 'billEditorExtraCategoryRequired',
      desc: '',
      args: [],
    );
  }

  /// `No options available`
  String get billEditorNoOptions {
    return Intl.message(
      'No options available',
      name: 'billEditorNoOptions',
      desc: '',
      args: [],
    );
  }

  /// `None`
  String get billEditorNoSelection {
    return Intl.message(
      'None',
      name: 'billEditorNoSelection',
      desc: '',
      args: [],
    );
  }

  /// `Add Group`
  String get booksAddGroup {
    return Intl.message('Add Group', name: 'booksAddGroup', desc: '', args: []);
  }

  /// `Edit Group`
  String get booksEditGroup {
    return Intl.message(
      'Edit Group',
      name: 'booksEditGroup',
      desc: '',
      args: [],
    );
  }

  /// `Delete Group`
  String get booksRemoveGroupTitle {
    return Intl.message(
      'Delete Group',
      name: 'booksRemoveGroupTitle',
      desc: '',
      args: [],
    );
  }

  /// `this group`
  String get booksThisGroup {
    return Intl.message(
      'this group',
      name: 'booksThisGroup',
      desc: '',
      args: [],
    );
  }

  /// `Delete "{name}"? Books under this group will no longer be accessible.`
  String booksRemoveGroupMessage(Object name) {
    return Intl.message(
      'Delete "$name"? Books under this group will no longer be accessible.',
      name: 'booksRemoveGroupMessage',
      desc: '',
      args: [name],
    );
  }

  /// `Switched to "{name}"`
  String booksSwitchedToGroup(Object name) {
    return Intl.message(
      'Switched to "$name"',
      name: 'booksSwitchedToGroup',
      desc: '',
      args: [name],
    );
  }

  /// `Add Book`
  String get booksAddBook {
    return Intl.message('Add Book', name: 'booksAddBook', desc: '', args: []);
  }

  /// `Edit Book`
  String get booksEditBook {
    return Intl.message('Edit Book', name: 'booksEditBook', desc: '', args: []);
  }

  /// `Permanently Delete Book`
  String get booksRemoveBookTitle {
    return Intl.message(
      'Permanently Delete Book',
      name: 'booksRemoveBookTitle',
      desc: '',
      args: [],
    );
  }

  /// `this book`
  String get booksThisBook {
    return Intl.message('this book', name: 'booksThisBook', desc: '', args: []);
  }

  /// `Permanently delete "{name}"? This action cannot be undone.`
  String booksRemoveBookMessage(Object name) {
    return Intl.message(
      'Permanently delete "$name"? This action cannot be undone.',
      name: 'booksRemoveBookMessage',
      desc: '',
      args: [name],
    );
  }

  /// `Groups`
  String get booksTabGroups {
    return Intl.message('Groups', name: 'booksTabGroups', desc: '', args: []);
  }

  /// `Books`
  String get booksTabBooks {
    return Intl.message('Books', name: 'booksTabBooks', desc: '', args: []);
  }

  /// `Please create a group first`
  String get booksCreateGroupFirst {
    return Intl.message(
      'Please create a group first',
      name: 'booksCreateGroupFirst',
      desc: '',
      args: [],
    );
  }

  /// `No groups yet. Tap + in the top right to add one.`
  String get booksEmptyGroups {
    return Intl.message(
      'No groups yet. Tap + in the top right to add one.',
      name: 'booksEmptyGroups',
      desc: '',
      args: [],
    );
  }

  /// `Unnamed group`
  String get booksUnnamedGroup {
    return Intl.message(
      'Unnamed group',
      name: 'booksUnnamedGroup',
      desc: '',
      args: [],
    );
  }

  /// `Current`
  String get booksCurrent {
    return Intl.message('Current', name: 'booksCurrent', desc: '', args: []);
  }

  /// `Set as default group`
  String get booksSetDefaultGroup {
    return Intl.message(
      'Set as default group',
      name: 'booksSetDefaultGroup',
      desc: '',
      args: [],
    );
  }

  /// `Disabled`
  String get booksDisabled {
    return Intl.message('Disabled', name: 'booksDisabled', desc: '', args: []);
  }

  /// `Default book: {name}`
  String booksDefaultBook(Object name) {
    return Intl.message(
      'Default book: $name',
      name: 'booksDefaultBook',
      desc: '',
      args: [name],
    );
  }

  /// `Please select a group first`
  String get booksSelectGroupFirst {
    return Intl.message(
      'Please select a group first',
      name: 'booksSelectGroupFirst',
      desc: '',
      args: [],
    );
  }

  /// `Group`
  String get booksBelongGroup {
    return Intl.message('Group', name: 'booksBelongGroup', desc: '', args: []);
  }

  /// `No books in this group. Tap + in the top right to add one.`
  String get booksEmptyBooks {
    return Intl.message(
      'No books in this group. Tap + in the top right to add one.',
      name: 'booksEmptyBooks',
      desc: '',
      args: [],
    );
  }

  /// `Recycle Bin`
  String get booksRecycleBin {
    return Intl.message(
      'Recycle Bin',
      name: 'booksRecycleBin',
      desc: '',
      args: [],
    );
  }

  /// `Unnamed book`
  String get booksUnnamedBook {
    return Intl.message(
      'Unnamed book',
      name: 'booksUnnamedBook',
      desc: '',
      args: [],
    );
  }

  /// `Restore`
  String get booksPutBack {
    return Intl.message('Restore', name: 'booksPutBack', desc: '', args: []);
  }

  /// `Set as default book`
  String get booksSetDefaultBook {
    return Intl.message(
      'Set as default book',
      name: 'booksSetDefaultBook',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get booksEdit {
    return Intl.message('Edit', name: 'booksEdit', desc: '', args: []);
  }

  /// `Enable`
  String get booksEnable {
    return Intl.message('Enable', name: 'booksEnable', desc: '', args: []);
  }

  /// `Disable`
  String get booksDisable {
    return Intl.message('Disable', name: 'booksDisable', desc: '', args: []);
  }

  /// `Move to Recycle Bin`
  String get booksMoveToRecycle {
    return Intl.message(
      'Move to Recycle Bin',
      name: 'booksMoveToRecycle',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get booksDelete {
    return Intl.message('Delete', name: 'booksDelete', desc: '', args: []);
  }

  /// `Please enter a group name`
  String get booksGroupNameRequired {
    return Intl.message(
      'Please enter a group name',
      name: 'booksGroupNameRequired',
      desc: '',
      args: [],
    );
  }

  /// `Please select a default currency`
  String get booksCurrencyRequired {
    return Intl.message(
      'Please select a default currency',
      name: 'booksCurrencyRequired',
      desc: '',
      args: [],
    );
  }

  /// `Group Name`
  String get booksGroupName {
    return Intl.message(
      'Group Name',
      name: 'booksGroupName',
      desc: '',
      args: [],
    );
  }

  /// `e.g. Family Account`
  String get booksGroupNameHint {
    return Intl.message(
      'e.g. Family Account',
      name: 'booksGroupNameHint',
      desc: '',
      args: [],
    );
  }

  /// `Default Currency`
  String get booksDefaultCurrency {
    return Intl.message(
      'Default Currency',
      name: 'booksDefaultCurrency',
      desc: '',
      args: [],
    );
  }

  /// `Enable`
  String get booksEnabled {
    return Intl.message('Enable', name: 'booksEnabled', desc: '', args: []);
  }

  /// `Remark (optional)`
  String get booksRemarkOptional {
    return Intl.message(
      'Remark (optional)',
      name: 'booksRemarkOptional',
      desc: '',
      args: [],
    );
  }

  /// `Remark`
  String get booksRemarkHint {
    return Intl.message('Remark', name: 'booksRemarkHint', desc: '', args: []);
  }

  /// `Save Changes`
  String get booksSaveChanges {
    return Intl.message(
      'Save Changes',
      name: 'booksSaveChanges',
      desc: '',
      args: [],
    );
  }

  /// `Create Group`
  String get booksCreateGroup {
    return Intl.message(
      'Create Group',
      name: 'booksCreateGroup',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a book name`
  String get booksBookNameRequired {
    return Intl.message(
      'Please enter a book name',
      name: 'booksBookNameRequired',
      desc: '',
      args: [],
    );
  }

  /// `Book Name`
  String get booksBookName {
    return Intl.message('Book Name', name: 'booksBookName', desc: '', args: []);
  }

  /// `e.g. Daily Expenses`
  String get booksBookNameHint {
    return Intl.message(
      'e.g. Daily Expenses',
      name: 'booksBookNameHint',
      desc: '',
      args: [],
    );
  }

  /// `Book Template (optional)`
  String get booksBookTemplateOptional {
    return Intl.message(
      'Book Template (optional)',
      name: 'booksBookTemplateOptional',
      desc: '',
      args: [],
    );
  }

  /// `Sort (optional)`
  String get booksSortOptional {
    return Intl.message(
      'Sort (optional)',
      name: 'booksSortOptional',
      desc: '',
      args: [],
    );
  }

  /// `Lower values appear first`
  String get booksSortHint {
    return Intl.message(
      'Lower values appear first',
      name: 'booksSortHint',
      desc: '',
      args: [],
    );
  }

  /// `Create Book`
  String get booksCreateBook {
    return Intl.message(
      'Create Book',
      name: 'booksCreateBook',
      desc: '',
      args: [],
    );
  }

  /// `Groups & Books`
  String get booksManageTitle {
    return Intl.message(
      'Groups & Books',
      name: 'booksManageTitle',
      desc: '',
      args: [],
    );
  }

  /// `Current: {tab}`
  String booksCurrentAt(Object tab) {
    return Intl.message(
      'Current: $tab',
      name: 'booksCurrentAt',
      desc: '',
      args: [tab],
    );
  }

  /// `Groups`
  String get booksTabGroupShort {
    return Intl.message(
      'Groups',
      name: 'booksTabGroupShort',
      desc: '',
      args: [],
    );
  }

  /// `Books`
  String get booksTabBookShort {
    return Intl.message('Books', name: 'booksTabBookShort', desc: '', args: []);
  }

  /// `Search group name / note / currency`
  String get booksGroupSearchHint {
    return Intl.message(
      'Search group name / note / currency',
      name: 'booksGroupSearchHint',
      desc: '',
      args: [],
    );
  }

  /// `No matching groups`
  String get booksNoMatchingGroups {
    return Intl.message(
      'No matching groups',
      name: 'booksNoMatchingGroups',
      desc: '',
      args: [],
    );
  }

  /// `All`
  String get booksFilterAll {
    return Intl.message('All', name: 'booksFilterAll', desc: '', args: []);
  }

  /// `Enabled`
  String get booksFilterEnabled {
    return Intl.message(
      'Enabled',
      name: 'booksFilterEnabled',
      desc: '',
      args: [],
    );
  }

  /// `Disabled`
  String get booksFilterDisabled {
    return Intl.message(
      'Disabled',
      name: 'booksFilterDisabled',
      desc: '',
      args: [],
    );
  }

  /// `More available`
  String get booksHasMore {
    return Intl.message(
      'More available',
      name: 'booksHasMore',
      desc: '',
      args: [],
    );
  }

  /// `No note`
  String get booksNoRemark {
    return Intl.message('No note', name: 'booksNoRemark', desc: '', args: []);
  }

  /// `Default group`
  String get booksDefaultGroupTag {
    return Intl.message(
      'Default group',
      name: 'booksDefaultGroupTag',
      desc: '',
      args: [],
    );
  }

  /// `Current`
  String get booksCurrentUsingTag {
    return Intl.message(
      'Current',
      name: 'booksCurrentUsingTag',
      desc: '',
      args: [],
    );
  }

  /// `Default book: Not set`
  String get booksNoDefaultBook {
    return Intl.message(
      'Default book: Not set',
      name: 'booksNoDefaultBook',
      desc: '',
      args: [],
    );
  }

  /// `You are a visitor and can only view group information`
  String get booksVisitorViewGroupOnly {
    return Intl.message(
      'You are a visitor and can only view group information',
      name: 'booksVisitorViewGroupOnly',
      desc: '',
      args: [],
    );
  }

  /// `You are a visitor and do not have permission to access this`
  String get permissionVisitorNoAccess {
    return Intl.message(
      'You are a visitor and do not have permission to access this',
      name: 'permissionVisitorNoAccess',
      desc: '',
      args: [],
    );
  }

  /// `The system is busy. Please try again later.`
  String get commonSystemBusy {
    return Intl.message(
      'The system is busy. Please try again later.',
      name: 'commonSystemBusy',
      desc: '',
      args: [],
    );
  }

  /// `Invite members`
  String get booksInviteMembers {
    return Intl.message(
      'Invite members',
      name: 'booksInviteMembers',
      desc: '',
      args: [],
    );
  }

  /// `Permanently delete group`
  String get booksDeleteGroupForever {
    return Intl.message(
      'Permanently delete group',
      name: 'booksDeleteGroupForever',
      desc: '',
      args: [],
    );
  }

  /// `This group has no available books. Create or enable a book first.`
  String get booksGroupNoAvailableBook {
    return Intl.message(
      'This group has no available books. Create or enable a book first.',
      name: 'booksGroupNoAvailableBook',
      desc: '',
      args: [],
    );
  }

  /// `Group created`
  String get booksGroupCreated {
    return Intl.message(
      'Group created',
      name: 'booksGroupCreated',
      desc: '',
      args: [],
    );
  }

  /// `Group saved`
  String get booksGroupSaved {
    return Intl.message(
      'Group saved',
      name: 'booksGroupSaved',
      desc: '',
      args: [],
    );
  }

  /// `Book created`
  String get booksBookCreated {
    return Intl.message(
      'Book created',
      name: 'booksBookCreated',
      desc: '',
      args: [],
    );
  }

  /// `Book saved`
  String get booksBookSaved {
    return Intl.message(
      'Book saved',
      name: 'booksBookSaved',
      desc: '',
      args: [],
    );
  }

  /// `Search book name / note`
  String get booksBookSearchHint {
    return Intl.message(
      'Search book name / note',
      name: 'booksBookSearchHint',
      desc: '',
      args: [],
    );
  }

  /// `Recycle bin is empty`
  String get booksRecycleEmpty {
    return Intl.message(
      'Recycle bin is empty',
      name: 'booksRecycleEmpty',
      desc: '',
      args: [],
    );
  }

  /// `No books in this group`
  String get booksGroupNoBooks {
    return Intl.message(
      'No books in this group',
      name: 'booksGroupNoBooks',
      desc: '',
      args: [],
    );
  }

  /// `This group is disabled. You can only view historical books; enable it to edit.`
  String get booksGroupDisabledReadonly {
    return Intl.message(
      'This group is disabled. You can only view historical books; enable it to edit.',
      name: 'booksGroupDisabledReadonly',
      desc: '',
      args: [],
    );
  }

  /// `Active`
  String get booksActiveSegment {
    return Intl.message(
      'Active',
      name: 'booksActiveSegment',
      desc: '',
      args: [],
    );
  }

  /// `Select a group`
  String get booksSelectGroup {
    return Intl.message(
      'Select a group',
      name: 'booksSelectGroup',
      desc: '',
      args: [],
    );
  }

  /// `Tap to switch group`
  String get booksTapSwitchGroup {
    return Intl.message(
      'Tap to switch group',
      name: 'booksTapSwitchGroup',
      desc: '',
      args: [],
    );
  }

  /// `Disabled · view only`
  String get booksGroupDisabledViewOnly {
    return Intl.message(
      'Disabled · view only',
      name: 'booksGroupDisabledViewOnly',
      desc: '',
      args: [],
    );
  }

  /// `Switch group`
  String get booksSwitchGroup {
    return Intl.message(
      'Switch group',
      name: 'booksSwitchGroup',
      desc: '',
      args: [],
    );
  }

  /// `Default`
  String get booksDefaultTag {
    return Intl.message('Default', name: 'booksDefaultTag', desc: '', args: []);
  }

  /// `Default account settings`
  String get booksDefaultAccountSettings {
    return Intl.message(
      'Default account settings',
      name: 'booksDefaultAccountSettings',
      desc: '',
      args: [],
    );
  }

  /// `Delete forever`
  String get booksDeleteForever {
    return Intl.message(
      'Delete forever',
      name: 'booksDeleteForever',
      desc: '',
      args: [],
    );
  }

  /// `this book`
  String get booksBookFallbackName {
    return Intl.message(
      'this book',
      name: 'booksBookFallbackName',
      desc: '',
      args: [],
    );
  }

  /// `Permanently delete group "{name}"?`
  String booksDeleteGroupTitle(Object name) {
    return Intl.message(
      'Permanently delete group "$name"?',
      name: 'booksDeleteGroupTitle',
      desc: '',
      args: [name],
    );
  }

  /// `This cannot be undone. It will delete books, accounts, categories, tags, payees, member relations, all bill records, and photos. This version cannot preview exact counts.`
  String get booksDeleteGroupWarning {
    return Intl.message(
      'This cannot be undone. It will delete books, accounts, categories, tags, payees, member relations, all bill records, and photos. This version cannot preview exact counts.',
      name: 'booksDeleteGroupWarning',
      desc: '',
      args: [],
    );
  }

  /// `I understand counts cannot be previewed and still want to delete`
  String get booksDeleteGroupUnderstand {
    return Intl.message(
      'I understand counts cannot be previewed and still want to delete',
      name: 'booksDeleteGroupUnderstand',
      desc: '',
      args: [],
    );
  }

  /// `Permanently delete book "{name}"?`
  String booksDeleteBookForeverTitle(Object name) {
    return Intl.message(
      'Permanently delete book "$name"?',
      name: 'booksDeleteBookForeverTitle',
      desc: '',
      args: [name],
    );
  }

  /// `This cannot be undone. Make sure the group still keeps at least one active enabled book.`
  String get booksDeleteBookWarning {
    return Intl.message(
      'This cannot be undone. Make sure the group still keeps at least one active enabled book.',
      name: 'booksDeleteBookWarning',
      desc: '',
      args: [],
    );
  }

  /// `Visitors cannot create groups`
  String get booksVisitorCannotCreateGroup {
    return Intl.message(
      'Visitors cannot create groups',
      name: 'booksVisitorCannotCreateGroup',
      desc: '',
      args: [],
    );
  }

  /// `Cannot create books in recycle bin`
  String get booksRecycleCannotCreateBook {
    return Intl.message(
      'Cannot create books in recycle bin',
      name: 'booksRecycleCannotCreateBook',
      desc: '',
      args: [],
    );
  }

  /// `Enable the group before creating a book`
  String get booksEnableGroupBeforeCreateBook {
    return Intl.message(
      'Enable the group before creating a book',
      name: 'booksEnableGroupBeforeCreateBook',
      desc: '',
      args: [],
    );
  }

  /// `Visitors cannot create books`
  String get booksVisitorCannotCreateBook {
    return Intl.message(
      'Visitors cannot create books',
      name: 'booksVisitorCannotCreateBook',
      desc: '',
      args: [],
    );
  }

  /// `Group details`
  String get booksGroupDetailTitle {
    return Intl.message(
      'Group details',
      name: 'booksGroupDetailTitle',
      desc: '',
      args: [],
    );
  }

  /// `Book details`
  String get booksBookDetailTitle {
    return Intl.message(
      'Book details',
      name: 'booksBookDetailTitle',
      desc: '',
      args: [],
    );
  }

  /// `Members ({count})`
  String booksMembersCount(Object count) {
    return Intl.message(
      'Members ($count)',
      name: 'booksMembersCount',
      desc: '',
      args: [count],
    );
  }

  /// `Invite`
  String get booksInvite {
    return Intl.message('Invite', name: 'booksInvite', desc: '', args: []);
  }

  /// `To adjust roles, remove the member and invite again.`
  String get booksAdjustRoleHint {
    return Intl.message(
      'To adjust roles, remove the member and invite again.',
      name: 'booksAdjustRoleHint',
      desc: '',
      args: [],
    );
  }

  /// `Unknown role`
  String get booksUnknownRole {
    return Intl.message(
      'Unknown role',
      name: 'booksUnknownRole',
      desc: '',
      args: [],
    );
  }

  /// `You cannot remove yourself`
  String get booksCannotRemoveSelf {
    return Intl.message(
      'You cannot remove yourself',
      name: 'booksCannotRemoveSelf',
      desc: '',
      args: [],
    );
  }

  /// `You cannot remove the only owner`
  String get booksCannotRemoveOnlyOwner {
    return Intl.message(
      'You cannot remove the only owner',
      name: 'booksCannotRemoveOnlyOwner',
      desc: '',
      args: [],
    );
  }

  /// `Invited {username}`
  String booksInvitedUser(Object username) {
    return Intl.message(
      'Invited $username',
      name: 'booksInvitedUser',
      desc: '',
      args: [username],
    );
  }

  /// `Book overview`
  String get booksBookOverview {
    return Intl.message(
      'Book overview',
      name: 'booksBookOverview',
      desc: '',
      args: [],
    );
  }

  /// `No books`
  String get booksNoBooks {
    return Intl.message('No books', name: 'booksNoBooks', desc: '', args: []);
  }

  /// `Manage all books in the Books tab`
  String get booksManageAllBooksInTab {
    return Intl.message(
      'Manage all books in the Books tab',
      name: 'booksManageAllBooksInTab',
      desc: '',
      args: [],
    );
  }

  /// `Info`
  String get booksInfo {
    return Intl.message('Info', name: 'booksInfo', desc: '', args: []);
  }

  /// `Sort order: {sort}`
  String booksSortValue(Object sort) {
    return Intl.message(
      'Sort order: $sort',
      name: 'booksSortValue',
      desc: '',
      args: [sort],
    );
  }

  /// `Remark: {remark}`
  String booksRemarkValue(Object remark) {
    return Intl.message(
      'Remark: $remark',
      name: 'booksRemarkValue',
      desc: '',
      args: [remark],
    );
  }

  /// `None`
  String get booksNone {
    return Intl.message('None', name: 'booksNone', desc: '', args: []);
  }

  /// `Default book updated`
  String get booksDefaultBookUpdated {
    return Intl.message(
      'Default book updated',
      name: 'booksDefaultBookUpdated',
      desc: '',
      args: [],
    );
  }

  /// `Username`
  String get booksUsername {
    return Intl.message('Username', name: 'booksUsername', desc: '', args: []);
  }

  /// `Role`
  String get booksRole {
    return Intl.message('Role', name: 'booksRole', desc: '', args: []);
  }

  /// `Confirm invitation`
  String get booksInviteConfirmTitle {
    return Intl.message(
      'Confirm invitation',
      name: 'booksInviteConfirmTitle',
      desc: '',
      args: [],
    );
  }

  /// `Invite {username} to this group. Please confirm the username is exact.`
  String booksInviteConfirmMessage(Object username) {
    return Intl.message(
      'Invite $username to this group. Please confirm the username is exact.',
      name: 'booksInviteConfirmMessage',
      desc: '',
      args: [username],
    );
  }

  /// `Send invitation`
  String get booksSendInvite {
    return Intl.message(
      'Send invitation',
      name: 'booksSendInvite',
      desc: '',
      args: [],
    );
  }

  /// `Enter a username and select a role`
  String get booksInviteInputError {
    return Intl.message(
      'Enter a username and select a role',
      name: 'booksInviteInputError',
      desc: '',
      args: [],
    );
  }

  /// `Please confirm the username is exact. The current API cannot preview nickname or avatar.`
  String get booksInviteHelp {
    return Intl.message(
      'Please confirm the username is exact. The current API cannot preview nickname or avatar.',
      name: 'booksInviteHelp',
      desc: '',
      args: [],
    );
  }

  /// `No enabled accounts in this group\nYou can save the book first and set default accounts later in account management.`
  String get booksNoEnabledAccounts {
    return Intl.message(
      'No enabled accounts in this group\nYou can save the book first and set default accounts later in account management.',
      name: 'booksNoEnabledAccounts',
      desc: '',
      args: [],
    );
  }

  /// `This account does not support {kind}`
  String booksUnsupportedAccount(Object kind) {
    return Intl.message(
      'This account does not support $kind',
      name: 'booksUnsupportedAccount',
      desc: '',
      args: [kind],
    );
  }

  /// `Clear selection`
  String get booksClearSelection {
    return Intl.message(
      'Clear selection',
      name: 'booksClearSelection',
      desc: '',
      args: [],
    );
  }

  /// `Enter "{name}" to confirm`
  String booksConfirmObjectHint(Object name) {
    return Intl.message(
      'Enter "$name" to confirm',
      name: 'booksConfirmObjectHint',
      desc: '',
      args: [name],
    );
  }

  /// `I understand this action cannot be undone and want to continue`
  String get booksDefaultDestructiveCheckbox {
    return Intl.message(
      'I understand this action cannot be undone and want to continue',
      name: 'booksDefaultDestructiveCheckbox',
      desc: '',
      args: [],
    );
  }

  /// `Permanently delete`
  String get booksPermanentlyDelete {
    return Intl.message(
      'Permanently delete',
      name: 'booksPermanentlyDelete',
      desc: '',
      args: [],
    );
  }

  /// `Owner`
  String get booksRoleOwner {
    return Intl.message('Owner', name: 'booksRoleOwner', desc: '', args: []);
  }

  /// `Collaborator`
  String get booksRoleActor {
    return Intl.message(
      'Collaborator',
      name: 'booksRoleActor',
      desc: '',
      args: [],
    );
  }

  /// `Visitor`
  String get booksRoleVisitor {
    return Intl.message(
      'Visitor',
      name: 'booksRoleVisitor',
      desc: '',
      args: [],
    );
  }

  /// `Unknown member`
  String get booksUnnamedMember {
    return Intl.message(
      'Unknown member',
      name: 'booksUnnamedMember',
      desc: '',
      args: [],
    );
  }

  /// `Unnamed account`
  String get booksUnnamedAccount {
    return Intl.message(
      'Unnamed account',
      name: 'booksUnnamedAccount',
      desc: '',
      args: [],
    );
  }

  /// `Default expense account`
  String get booksDefaultExpenseAccount {
    return Intl.message(
      'Default expense account',
      name: 'booksDefaultExpenseAccount',
      desc: '',
      args: [],
    );
  }

  /// `Default income account`
  String get booksDefaultIncomeAccount {
    return Intl.message(
      'Default income account',
      name: 'booksDefaultIncomeAccount',
      desc: '',
      args: [],
    );
  }

  /// `Default transfer-out account`
  String get booksDefaultTransferOutAccount {
    return Intl.message(
      'Default transfer-out account',
      name: 'booksDefaultTransferOutAccount',
      desc: '',
      args: [],
    );
  }

  /// `Default transfer-in account`
  String get booksDefaultTransferInAccount {
    return Intl.message(
      'Default transfer-in account',
      name: 'booksDefaultTransferInAccount',
      desc: '',
      args: [],
    );
  }

  /// `Please select a book first`
  String get recurringSelectBookFirst {
    return Intl.message(
      'Please select a book first',
      name: 'recurringSelectBookFirst',
      desc: '',
      args: [],
    );
  }

  /// `Execution Logs · {name}`
  String recurringLogsTitle(Object name) {
    return Intl.message(
      'Execution Logs · $name',
      name: 'recurringLogsTitle',
      desc: '',
      args: [name],
    );
  }

  /// `Delete Rule`
  String get recurringRemoveTitle {
    return Intl.message(
      'Delete Rule',
      name: 'recurringRemoveTitle',
      desc: '',
      args: [],
    );
  }

  /// `this rule`
  String get recurringThisRule {
    return Intl.message(
      'this rule',
      name: 'recurringThisRule',
      desc: '',
      args: [],
    );
  }

  /// `Delete "{name}"? This action cannot be undone.`
  String recurringRemoveMessage(Object name) {
    return Intl.message(
      'Delete "$name"? This action cannot be undone.',
      name: 'recurringRemoveMessage',
      desc: '',
      args: [name],
    );
  }

  /// `Delete`
  String get recurringDelete {
    return Intl.message('Delete', name: 'recurringDelete', desc: '', args: []);
  }

  /// `Recurring`
  String get recurringTitle {
    return Intl.message(
      'Recurring',
      name: 'recurringTitle',
      desc: '',
      args: [],
    );
  }

  /// `No recurring rules yet. Tap + in the top right to add one.`
  String get recurringEmpty {
    return Intl.message(
      'No recurring rules yet. Tap + in the top right to add one.',
      name: 'recurringEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Unnamed rule`
  String get recurringUnnamedRule {
    return Intl.message(
      'Unnamed rule',
      name: 'recurringUnnamedRule',
      desc: '',
      args: [],
    );
  }

  /// `Next run`
  String get recurringNextExecution {
    return Intl.message(
      'Next run',
      name: 'recurringNextExecution',
      desc: '',
      args: [],
    );
  }

  /// `Executed`
  String get recurringExecutedLabel {
    return Intl.message(
      'Executed',
      name: 'recurringExecutedLabel',
      desc: '',
      args: [],
    );
  }

  /// `{count} times`
  String recurringExecutedCount(Object count) {
    return Intl.message(
      '$count times',
      name: 'recurringExecutedCount',
      desc: '',
      args: [count],
    );
  }

  /// `Edit`
  String get recurringEdit {
    return Intl.message('Edit', name: 'recurringEdit', desc: '', args: []);
  }

  /// `Execution Logs`
  String get recurringLogs {
    return Intl.message(
      'Execution Logs',
      name: 'recurringLogs',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a rule name`
  String get recurringRuleNameRequired {
    return Intl.message(
      'Please enter a rule name',
      name: 'recurringRuleNameRequired',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a cron expression`
  String get recurringCronRequired {
    return Intl.message(
      'Please enter a cron expression',
      name: 'recurringCronRequired',
      desc: '',
      args: [],
    );
  }

  /// `Invalid cron expression, please fix it`
  String get recurringCronInvalidFix {
    return Intl.message(
      'Invalid cron expression, please fix it',
      name: 'recurringCronInvalidFix',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid template amount`
  String get recurringAmountRequired {
    return Intl.message(
      'Please enter a valid template amount',
      name: 'recurringAmountRequired',
      desc: '',
      args: [],
    );
  }

  /// `Please select an account`
  String get recurringAccountRequired {
    return Intl.message(
      'Please select an account',
      name: 'recurringAccountRequired',
      desc: '',
      args: [],
    );
  }

  /// `Please select a category`
  String get recurringCategoryRequired {
    return Intl.message(
      'Please select a category',
      name: 'recurringCategoryRequired',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a bill title or rule name`
  String get recurringBillTitleRequired {
    return Intl.message(
      'Please enter a bill title or rule name',
      name: 'recurringBillTitleRequired',
      desc: '',
      args: [],
    );
  }

  /// `Edit Recurring Rule`
  String get recurringEditRule {
    return Intl.message(
      'Edit Recurring Rule',
      name: 'recurringEditRule',
      desc: '',
      args: [],
    );
  }

  /// `New Recurring Rule`
  String get recurringAddRule {
    return Intl.message(
      'New Recurring Rule',
      name: 'recurringAddRule',
      desc: '',
      args: [],
    );
  }

  /// `Rule Settings`
  String get recurringSectionRule {
    return Intl.message(
      'Rule Settings',
      name: 'recurringSectionRule',
      desc: '',
      args: [],
    );
  }

  /// `Rule Name`
  String get recurringRuleName {
    return Intl.message(
      'Rule Name',
      name: 'recurringRuleName',
      desc: '',
      args: [],
    );
  }

  /// `e.g. Monthly Rent`
  String get recurringRuleNameHint {
    return Intl.message(
      'e.g. Monthly Rent',
      name: 'recurringRuleNameHint',
      desc: '',
      args: [],
    );
  }

  /// `Cron Expression`
  String get recurringCron {
    return Intl.message(
      'Cron Expression',
      name: 'recurringCron',
      desc: '',
      args: [],
    );
  }

  /// `e.g. 0 0 1 * * ?`
  String get recurringCronHint {
    return Intl.message(
      'e.g. 0 0 1 * * ?',
      name: 'recurringCronHint',
      desc: '',
      args: [],
    );
  }

  /// `Frequency`
  String get recurringSchedule {
    return Intl.message(
      'Frequency',
      name: 'recurringSchedule',
      desc: '',
      args: [],
    );
  }

  /// `Runs at`
  String get recurringScheduleSummary {
    return Intl.message(
      'Runs at',
      name: 'recurringScheduleSummary',
      desc: '',
      args: [],
    );
  }

  /// `Daily`
  String get recurringFreqDaily {
    return Intl.message(
      'Daily',
      name: 'recurringFreqDaily',
      desc: '',
      args: [],
    );
  }

  /// `Weekly`
  String get recurringFreqWeekly {
    return Intl.message(
      'Weekly',
      name: 'recurringFreqWeekly',
      desc: '',
      args: [],
    );
  }

  /// `Monthly`
  String get recurringFreqMonthly {
    return Intl.message(
      'Monthly',
      name: 'recurringFreqMonthly',
      desc: '',
      args: [],
    );
  }

  /// `Yearly`
  String get recurringFreqYearly {
    return Intl.message(
      'Yearly',
      name: 'recurringFreqYearly',
      desc: '',
      args: [],
    );
  }

  /// `Time`
  String get recurringAtTime {
    return Intl.message('Time', name: 'recurringAtTime', desc: '', args: []);
  }

  /// `Repeat on`
  String get recurringOnDays {
    return Intl.message(
      'Repeat on',
      name: 'recurringOnDays',
      desc: '',
      args: [],
    );
  }

  /// `Day of month`
  String get recurringOnDayOfMonth {
    return Intl.message(
      'Day of month',
      name: 'recurringOnDayOfMonth',
      desc: '',
      args: [],
    );
  }

  /// `Last day`
  String get recurringLastDayOfMonth {
    return Intl.message(
      'Last day',
      name: 'recurringLastDayOfMonth',
      desc: '',
      args: [],
    );
  }

  /// `The previous schedule could not be shown visually and has been changed to every day at 09:00. Review it before saving.`
  String get recurringLegacyVisualNotice {
    return Intl.message(
      'The previous schedule could not be shown visually and has been changed to every day at 09:00. Review it before saving.',
      name: 'recurringLegacyVisualNotice',
      desc: '',
      args: [],
    );
  }

  /// `Custom schedule`
  String get recurringCustomSchedule {
    return Intl.message(
      'Custom schedule',
      name: 'recurringCustomSchedule',
      desc: '',
      args: [],
    );
  }

  /// `Month`
  String get recurringOnMonth {
    return Intl.message('Month', name: 'recurringOnMonth', desc: '', args: []);
  }

  /// `Day {day}`
  String recurringDayOfMonthValue(Object day) {
    return Intl.message(
      'Day $day',
      name: 'recurringDayOfMonthValue',
      desc: '',
      args: [day],
    );
  }

  /// `Month {month}`
  String recurringMonthValue(Object month) {
    return Intl.message(
      'Month $month',
      name: 'recurringMonthValue',
      desc: '',
      args: [month],
    );
  }

  /// `Custom cron (advanced)`
  String get recurringAdvancedCron {
    return Intl.message(
      'Custom cron (advanced)',
      name: 'recurringAdvancedCron',
      desc: '',
      args: [],
    );
  }

  /// `Manually edit the cron expression for advanced use`
  String get recurringAdvancedCronHint {
    return Intl.message(
      'Manually edit the cron expression for advanced use',
      name: 'recurringAdvancedCronHint',
      desc: '',
      args: [],
    );
  }

  /// `Use visual picker`
  String get recurringUseVisual {
    return Intl.message(
      'Use visual picker',
      name: 'recurringUseVisual',
      desc: '',
      args: [],
    );
  }

  /// `Switch to custom cron`
  String get recurringUseAdvanced {
    return Intl.message(
      'Switch to custom cron',
      name: 'recurringUseAdvanced',
      desc: '',
      args: [],
    );
  }

  /// `Switch to the visual picker?`
  String get recurringDiscardCustomCronTitle {
    return Intl.message(
      'Switch to the visual picker?',
      name: 'recurringDiscardCustomCronTitle',
      desc: '',
      args: [],
    );
  }

  /// `The current custom cron expression cannot be converted to a visual rule.`
  String get recurringDiscardCustomCronMessage {
    return Intl.message(
      'The current custom cron expression cannot be converted to a visual rule.',
      name: 'recurringDiscardCustomCronMessage',
      desc: '',
      args: [],
    );
  }

  /// `Continuing will replace it with the current visual rule and cannot be undone.`
  String get recurringDiscardCustomCronWarning {
    return Intl.message(
      'Continuing will replace it with the current visual rule and cannot be undone.',
      name: 'recurringDiscardCustomCronWarning',
      desc: '',
      args: [],
    );
  }

  /// `Every day at {time}`
  String recurringSummaryDaily(Object time) {
    return Intl.message(
      'Every day at $time',
      name: 'recurringSummaryDaily',
      desc: '',
      args: [time],
    );
  }

  /// `Every {days} at {time}`
  String recurringSummaryWeekly(Object days, Object time) {
    return Intl.message(
      'Every $days at $time',
      name: 'recurringSummaryWeekly',
      desc: '',
      args: [days, time],
    );
  }

  /// `Day {day} monthly at {time}`
  String recurringSummaryMonthly(Object day, Object time) {
    return Intl.message(
      'Day $day monthly at $time',
      name: 'recurringSummaryMonthly',
      desc: '',
      args: [day, time],
    );
  }

  /// `{month}/{day} yearly at {time}`
  String recurringSummaryYearly(Object month, Object day, Object time) {
    return Intl.message(
      '$month/$day yearly at $time',
      name: 'recurringSummaryYearly',
      desc: '',
      args: [month, day, time],
    );
  }

  /// `Mon`
  String get recurringWeekdayMon {
    return Intl.message('Mon', name: 'recurringWeekdayMon', desc: '', args: []);
  }

  /// `Tue`
  String get recurringWeekdayTue {
    return Intl.message('Tue', name: 'recurringWeekdayTue', desc: '', args: []);
  }

  /// `Wed`
  String get recurringWeekdayWed {
    return Intl.message('Wed', name: 'recurringWeekdayWed', desc: '', args: []);
  }

  /// `Thu`
  String get recurringWeekdayThu {
    return Intl.message('Thu', name: 'recurringWeekdayThu', desc: '', args: []);
  }

  /// `Fri`
  String get recurringWeekdayFri {
    return Intl.message('Fri', name: 'recurringWeekdayFri', desc: '', args: []);
  }

  /// `Sat`
  String get recurringWeekdaySat {
    return Intl.message('Sat', name: 'recurringWeekdaySat', desc: '', args: []);
  }

  /// `Sun`
  String get recurringWeekdaySun {
    return Intl.message('Sun', name: 'recurringWeekdaySun', desc: '', args: []);
  }

  /// `Start Date (optional)`
  String get recurringStartDateOptional {
    return Intl.message(
      'Start Date (optional)',
      name: 'recurringStartDateOptional',
      desc: '',
      args: [],
    );
  }

  /// `End Date (optional)`
  String get recurringEndDateOptional {
    return Intl.message(
      'End Date (optional)',
      name: 'recurringEndDateOptional',
      desc: '',
      args: [],
    );
  }

  /// `Max Executions (optional)`
  String get recurringMaxExecutionsOptional {
    return Intl.message(
      'Max Executions (optional)',
      name: 'recurringMaxExecutionsOptional',
      desc: '',
      args: [],
    );
  }

  /// `Leave empty for unlimited`
  String get recurringMaxExecutionsHint {
    return Intl.message(
      'Leave empty for unlimited',
      name: 'recurringMaxExecutionsHint',
      desc: '',
      args: [],
    );
  }

  /// `Recovery Strategy`
  String get recurringRecoveryStrategy {
    return Intl.message(
      'Recovery Strategy',
      name: 'recurringRecoveryStrategy',
      desc: '',
      args: [],
    );
  }

  /// `Enable`
  String get recurringEnabled {
    return Intl.message('Enable', name: 'recurringEnabled', desc: '', args: []);
  }

  /// `Bill Template`
  String get recurringSectionTemplate {
    return Intl.message(
      'Bill Template',
      name: 'recurringSectionTemplate',
      desc: '',
      args: [],
    );
  }

  /// `Type`
  String get recurringType {
    return Intl.message('Type', name: 'recurringType', desc: '', args: []);
  }

  /// `Title (optional, uses rule name if empty)`
  String get recurringTitleOptional {
    return Intl.message(
      'Title (optional, uses rule name if empty)',
      name: 'recurringTitleOptional',
      desc: '',
      args: [],
    );
  }

  /// `Bill title`
  String get recurringBillTitleHint {
    return Intl.message(
      'Bill title',
      name: 'recurringBillTitleHint',
      desc: '',
      args: [],
    );
  }

  /// `Amount`
  String get recurringAmount {
    return Intl.message('Amount', name: 'recurringAmount', desc: '', args: []);
  }

  /// `Category`
  String get recurringCategory {
    return Intl.message(
      'Category',
      name: 'recurringCategory',
      desc: '',
      args: [],
    );
  }

  /// `Account`
  String get recurringAccount {
    return Intl.message(
      'Account',
      name: 'recurringAccount',
      desc: '',
      args: [],
    );
  }

  /// `Tags (multiple, optional)`
  String get recurringTagsOptional {
    return Intl.message(
      'Tags (multiple, optional)',
      name: 'recurringTagsOptional',
      desc: '',
      args: [],
    );
  }

  /// `Save Changes`
  String get recurringSaveChanges {
    return Intl.message(
      'Save Changes',
      name: 'recurringSaveChanges',
      desc: '',
      args: [],
    );
  }

  /// `Create Rule`
  String get recurringCreateRule {
    return Intl.message(
      'Create Rule',
      name: 'recurringCreateRule',
      desc: '',
      args: [],
    );
  }

  /// `Invalid cron expression`
  String get recurringCronInvalid {
    return Intl.message(
      'Invalid cron expression',
      name: 'recurringCronInvalid',
      desc: '',
      args: [],
    );
  }

  /// `Valid cron expression`
  String get recurringCronValid {
    return Intl.message(
      'Valid cron expression',
      name: 'recurringCronValid',
      desc: '',
      args: [],
    );
  }

  /// `No options available`
  String get recurringNoOptions {
    return Intl.message(
      'No options available',
      name: 'recurringNoOptions',
      desc: '',
      args: [],
    );
  }

  /// `No execution records`
  String get recurringNoLogs {
    return Intl.message(
      'No execution records',
      name: 'recurringNoLogs',
      desc: '',
      args: [],
    );
  }

  /// `Bill #{id}`
  String recurringLogBillId(Object id) {
    return Intl.message(
      'Bill #$id',
      name: 'recurringLogBillId',
      desc: '',
      args: [id],
    );
  }

  /// `Took {ms}ms`
  String recurringLogDuration(Object ms) {
    return Intl.message(
      'Took ${ms}ms',
      name: 'recurringLogDuration',
      desc: '',
      args: [ms],
    );
  }

  /// `Please select a book first`
  String get ordersSelectBookFirst {
    return Intl.message(
      'Please select a book first',
      name: 'ordersSelectBookFirst',
      desc: '',
      args: [],
    );
  }

  /// `Add order`
  String get ordersAddTitle {
    return Intl.message(
      'Add order',
      name: 'ordersAddTitle',
      desc: '',
      args: [],
    );
  }

  /// `Edit {type}`
  String ordersEditTitle(Object type) {
    return Intl.message(
      'Edit $type',
      name: 'ordersEditTitle',
      desc: '',
      args: [type],
    );
  }

  /// `Delete Reimbursement Order`
  String get ordersRemoveTitle {
    return Intl.message(
      'Delete Reimbursement Order',
      name: 'ordersRemoveTitle',
      desc: '',
      args: [],
    );
  }

  /// `this reimbursement order`
  String get ordersThisOrder {
    return Intl.message(
      'this reimbursement order',
      name: 'ordersThisOrder',
      desc: '',
      args: [],
    );
  }

  /// `Delete "{name}"?`
  String ordersRemoveMessage(Object name) {
    return Intl.message(
      'Delete "$name"?',
      name: 'ordersRemoveMessage',
      desc: '',
      args: [name],
    );
  }

  /// `Delete`
  String get ordersDelete {
    return Intl.message('Delete', name: 'ordersDelete', desc: '', args: []);
  }

  /// `Orders`
  String get ordersTitle {
    return Intl.message('Orders', name: 'ordersTitle', desc: '', args: []);
  }

  /// `No orders yet. Tap + in the top right to add one.`
  String get ordersEmpty {
    return Intl.message(
      'No orders yet. Tap + in the top right to add one.',
      name: 'ordersEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Unnamed reimbursement order`
  String get ordersUnnamedOrder {
    return Intl.message(
      'Unnamed reimbursement order',
      name: 'ordersUnnamedOrder',
      desc: '',
      args: [],
    );
  }

  /// `Out `
  String get ordersOutLabel {
    return Intl.message('Out ', name: 'ordersOutLabel', desc: '', args: []);
  }

  /// `In `
  String get ordersInLabel {
    return Intl.message('In ', name: 'ordersInLabel', desc: '', args: []);
  }

  /// `Submitted {time}`
  String ordersSubmitTime(Object time) {
    return Intl.message(
      'Submitted $time',
      name: 'ordersSubmitTime',
      desc: '',
      args: [time],
    );
  }

  /// `Archived {time}`
  String ordersArchivedTime(Object time) {
    return Intl.message(
      'Archived $time',
      name: 'ordersArchivedTime',
      desc: '',
      args: [time],
    );
  }

  /// `Use`
  String get ordersUse {
    return Intl.message('Use', name: 'ordersUse', desc: '', args: []);
  }

  /// `Archive`
  String get ordersArchive {
    return Intl.message('Archive', name: 'ordersArchive', desc: '', args: []);
  }

  /// `Archived orders are excluded from statistics`
  String get ordersArchiveTooltip {
    return Intl.message(
      'Archived orders are excluded from statistics',
      name: 'ordersArchiveTooltip',
      desc: '',
      args: [],
    );
  }

  /// `Unrecognized order status`
  String get ordersStatusUnrecognized {
    return Intl.message(
      'Unrecognized order status',
      name: 'ordersStatusUnrecognized',
      desc: '',
      args: [],
    );
  }

  /// `Reopen`
  String get ordersReopen {
    return Intl.message('Reopen', name: 'ordersReopen', desc: '', args: []);
  }

  /// `Please enter an order title`
  String get ordersTitleRequired {
    return Intl.message(
      'Please enter an order title',
      name: 'ordersTitleRequired',
      desc: '',
      args: [],
    );
  }

  /// `Reimbursement Order Title`
  String get ordersOrderTitle {
    return Intl.message(
      'Reimbursement Order Title',
      name: 'ordersOrderTitle',
      desc: '',
      args: [],
    );
  }

  /// `{type} Title`
  String ordersTitleOfType(Object type) {
    return Intl.message(
      '$type Title',
      name: 'ordersTitleOfType',
      desc: '',
      args: [type],
    );
  }

  /// `e.g. August travel reimbursement`
  String get ordersTitleHint {
    return Intl.message(
      'e.g. August travel reimbursement',
      name: 'ordersTitleHint',
      desc: '',
      args: [],
    );
  }

  /// `Type`
  String get ordersType {
    return Intl.message('Type', name: 'ordersType', desc: '', args: []);
  }

  /// `Expense claim`
  String get ordersTypeReimbursement {
    return Intl.message(
      'Expense claim',
      name: 'ordersTypeReimbursement',
      desc: '',
      args: [],
    );
  }

  /// `Remark (optional)`
  String get ordersRemarkOptional {
    return Intl.message(
      'Remark (optional)',
      name: 'ordersRemarkOptional',
      desc: '',
      args: [],
    );
  }

  /// `Remark`
  String get ordersRemarkHint {
    return Intl.message('Remark', name: 'ordersRemarkHint', desc: '', args: []);
  }

  /// `Save Changes`
  String get ordersSaveChanges {
    return Intl.message(
      'Save Changes',
      name: 'ordersSaveChanges',
      desc: '',
      args: [],
    );
  }

  /// `Create Reimbursement Order`
  String get ordersCreateOrder {
    return Intl.message(
      'Create Reimbursement Order',
      name: 'ordersCreateOrder',
      desc: '',
      args: [],
    );
  }

  /// `Please select a book first`
  String get categoriesSelectBookFirst {
    return Intl.message(
      'Please select a book first',
      name: 'categoriesSelectBookFirst',
      desc: '',
      args: [],
    );
  }

  /// `Add category`
  String get categoriesAdd {
    return Intl.message(
      'Add category',
      name: 'categoriesAdd',
      desc: '',
      args: [],
    );
  }

  /// `Edit category`
  String get categoriesEdit {
    return Intl.message(
      'Edit category',
      name: 'categoriesEdit',
      desc: '',
      args: [],
    );
  }

  /// `Move to recycle bin`
  String get categoriesMoveToRecycleBin {
    return Intl.message(
      'Move to recycle bin',
      name: 'categoriesMoveToRecycleBin',
      desc: '',
      args: [],
    );
  }

  /// `Move "{name}" to the recycle bin?`
  String categoriesMoveToRecycleBinConfirm(Object name) {
    return Intl.message(
      'Move "$name" to the recycle bin?',
      name: 'categoriesMoveToRecycleBinConfirm',
      desc: '',
      args: [name],
    );
  }

  /// `Move`
  String get categoriesMove {
    return Intl.message('Move', name: 'categoriesMove', desc: '', args: []);
  }

  /// `this category`
  String get categoriesThisCategory {
    return Intl.message(
      'this category',
      name: 'categoriesThisCategory',
      desc: '',
      args: [],
    );
  }

  /// `Delete permanently`
  String get categoriesDeletePermanently {
    return Intl.message(
      'Delete permanently',
      name: 'categoriesDeletePermanently',
      desc: '',
      args: [],
    );
  }

  /// `Permanently delete "{name}"? This action cannot be undone.`
  String categoriesDeletePermanentlyConfirm(Object name) {
    return Intl.message(
      'Permanently delete "$name"? This action cannot be undone.',
      name: 'categoriesDeletePermanentlyConfirm',
      desc: '',
      args: [name],
    );
  }

  /// `Delete`
  String get categoriesDelete {
    return Intl.message('Delete', name: 'categoriesDelete', desc: '', args: []);
  }

  /// `Categories`
  String get categoriesTitle {
    return Intl.message(
      'Categories',
      name: 'categoriesTitle',
      desc: '',
      args: [],
    );
  }

  /// `Search category name`
  String get categoriesSearchHint {
    return Intl.message(
      'Search category name',
      name: 'categoriesSearchHint',
      desc: '',
      args: [],
    );
  }

  /// `No categories yet. Tap + in the top right to add one.`
  String get categoriesEmpty {
    return Intl.message(
      'No categories yet. Tap + in the top right to add one.',
      name: 'categoriesEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Expense categories`
  String get categoriesExpenseSection {
    return Intl.message(
      'Expense categories',
      name: 'categoriesExpenseSection',
      desc: '',
      args: [],
    );
  }

  /// `Income categories`
  String get categoriesIncomeSection {
    return Intl.message(
      'Income categories',
      name: 'categoriesIncomeSection',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a category name`
  String get categoriesNameRequired {
    return Intl.message(
      'Please enter a category name',
      name: 'categoriesNameRequired',
      desc: '',
      args: [],
    );
  }

  /// `Category name`
  String get categoriesNameLabel {
    return Intl.message(
      'Category name',
      name: 'categoriesNameLabel',
      desc: '',
      args: [],
    );
  }

  /// `e.g. Dining`
  String get categoriesNameHint {
    return Intl.message(
      'e.g. Dining',
      name: 'categoriesNameHint',
      desc: '',
      args: [],
    );
  }

  /// `Category type`
  String get categoriesTypeLabel {
    return Intl.message(
      'Category type',
      name: 'categoriesTypeLabel',
      desc: '',
      args: [],
    );
  }

  /// `Parent category (optional)`
  String get categoriesParentLabel {
    return Intl.message(
      'Parent category (optional)',
      name: 'categoriesParentLabel',
      desc: '',
      args: [],
    );
  }

  /// `Sort order (optional)`
  String get categoriesSortLabel {
    return Intl.message(
      'Sort order (optional)',
      name: 'categoriesSortLabel',
      desc: '',
      args: [],
    );
  }

  /// `Lower numbers appear first`
  String get categoriesSortHint {
    return Intl.message(
      'Lower numbers appear first',
      name: 'categoriesSortHint',
      desc: '',
      args: [],
    );
  }

  /// `Remark (optional)`
  String get categoriesRemarkLabel {
    return Intl.message(
      'Remark (optional)',
      name: 'categoriesRemarkLabel',
      desc: '',
      args: [],
    );
  }

  /// `Remark`
  String get categoriesRemarkHint {
    return Intl.message(
      'Remark',
      name: 'categoriesRemarkHint',
      desc: '',
      args: [],
    );
  }

  /// `Enable`
  String get categoriesEnable {
    return Intl.message('Enable', name: 'categoriesEnable', desc: '', args: []);
  }

  /// `Save changes`
  String get categoriesSaveEdit {
    return Intl.message(
      'Save changes',
      name: 'categoriesSaveEdit',
      desc: '',
      args: [],
    );
  }

  /// `Create category`
  String get categoriesCreate {
    return Intl.message(
      'Create category',
      name: 'categoriesCreate',
      desc: '',
      args: [],
    );
  }

  /// `Expense`
  String get categoriesTypeExpense {
    return Intl.message(
      'Expense',
      name: 'categoriesTypeExpense',
      desc: '',
      args: [],
    );
  }

  /// `Income`
  String get categoriesTypeIncome {
    return Intl.message(
      'Income',
      name: 'categoriesTypeIncome',
      desc: '',
      args: [],
    );
  }

  /// `None (top-level category)`
  String get categoriesParentNone {
    return Intl.message(
      'None (top-level category)',
      name: 'categoriesParentNone',
      desc: '',
      args: [],
    );
  }

  /// `Unnamed`
  String get categoriesUnnamed {
    return Intl.message(
      'Unnamed',
      name: 'categoriesUnnamed',
      desc: '',
      args: [],
    );
  }

  /// `Please select a book first`
  String get tagsSelectBookFirst {
    return Intl.message(
      'Please select a book first',
      name: 'tagsSelectBookFirst',
      desc: '',
      args: [],
    );
  }

  /// `Add tag`
  String get tagsAdd {
    return Intl.message('Add tag', name: 'tagsAdd', desc: '', args: []);
  }

  /// `Edit tag`
  String get tagsEdit {
    return Intl.message('Edit tag', name: 'tagsEdit', desc: '', args: []);
  }

  /// `Move to recycle bin`
  String get tagsMoveToRecycleBin {
    return Intl.message(
      'Move to recycle bin',
      name: 'tagsMoveToRecycleBin',
      desc: '',
      args: [],
    );
  }

  /// `Move "{name}" to the recycle bin?`
  String tagsMoveToRecycleBinConfirm(Object name) {
    return Intl.message(
      'Move "$name" to the recycle bin?',
      name: 'tagsMoveToRecycleBinConfirm',
      desc: '',
      args: [name],
    );
  }

  /// `Move`
  String get tagsMove {
    return Intl.message('Move', name: 'tagsMove', desc: '', args: []);
  }

  /// `this tag`
  String get tagsThisTag {
    return Intl.message('this tag', name: 'tagsThisTag', desc: '', args: []);
  }

  /// `Delete permanently`
  String get tagsDeletePermanently {
    return Intl.message(
      'Delete permanently',
      name: 'tagsDeletePermanently',
      desc: '',
      args: [],
    );
  }

  /// `Permanently delete "{name}"? This action cannot be undone.`
  String tagsDeletePermanentlyConfirm(Object name) {
    return Intl.message(
      'Permanently delete "$name"? This action cannot be undone.',
      name: 'tagsDeletePermanentlyConfirm',
      desc: '',
      args: [name],
    );
  }

  /// `Delete`
  String get tagsDelete {
    return Intl.message('Delete', name: 'tagsDelete', desc: '', args: []);
  }

  /// `Tags`
  String get tagsTitle {
    return Intl.message('Tags', name: 'tagsTitle', desc: '', args: []);
  }

  /// `Search tag name`
  String get tagsSearchHint {
    return Intl.message(
      'Search tag name',
      name: 'tagsSearchHint',
      desc: '',
      args: [],
    );
  }

  /// `No tags yet. Tap + in the top right to add one.`
  String get tagsEmpty {
    return Intl.message(
      'No tags yet. Tap + in the top right to add one.',
      name: 'tagsEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a tag name`
  String get tagsNameRequired {
    return Intl.message(
      'Please enter a tag name',
      name: 'tagsNameRequired',
      desc: '',
      args: [],
    );
  }

  /// `Tag name`
  String get tagsNameLabel {
    return Intl.message('Tag name', name: 'tagsNameLabel', desc: '', args: []);
  }

  /// `e.g. Gathering`
  String get tagsNameHint {
    return Intl.message(
      'e.g. Gathering',
      name: 'tagsNameHint',
      desc: '',
      args: [],
    );
  }

  /// `Parent tag (optional)`
  String get tagsParentLabel {
    return Intl.message(
      'Parent tag (optional)',
      name: 'tagsParentLabel',
      desc: '',
      args: [],
    );
  }

  /// `Sort order (optional)`
  String get tagsSortLabel {
    return Intl.message(
      'Sort order (optional)',
      name: 'tagsSortLabel',
      desc: '',
      args: [],
    );
  }

  /// `Lower numbers appear first`
  String get tagsSortHint {
    return Intl.message(
      'Lower numbers appear first',
      name: 'tagsSortHint',
      desc: '',
      args: [],
    );
  }

  /// `Remark (optional)`
  String get tagsRemarkLabel {
    return Intl.message(
      'Remark (optional)',
      name: 'tagsRemarkLabel',
      desc: '',
      args: [],
    );
  }

  /// `Remark`
  String get tagsRemarkHint {
    return Intl.message('Remark', name: 'tagsRemarkHint', desc: '', args: []);
  }

  /// `Save changes`
  String get tagsSaveEdit {
    return Intl.message(
      'Save changes',
      name: 'tagsSaveEdit',
      desc: '',
      args: [],
    );
  }

  /// `Create tag`
  String get tagsCreate {
    return Intl.message('Create tag', name: 'tagsCreate', desc: '', args: []);
  }

  /// `None (top-level tag)`
  String get tagsParentNone {
    return Intl.message(
      'None (top-level tag)',
      name: 'tagsParentNone',
      desc: '',
      args: [],
    );
  }

  /// `Unnamed`
  String get tagsUnnamed {
    return Intl.message('Unnamed', name: 'tagsUnnamed', desc: '', args: []);
  }

  /// `Please select a book first`
  String get payeesSelectBookFirst {
    return Intl.message(
      'Please select a book first',
      name: 'payeesSelectBookFirst',
      desc: '',
      args: [],
    );
  }

  /// `Add payee`
  String get payeesAdd {
    return Intl.message('Add payee', name: 'payeesAdd', desc: '', args: []);
  }

  /// `Edit payee`
  String get payeesEdit {
    return Intl.message('Edit payee', name: 'payeesEdit', desc: '', args: []);
  }

  /// `Move to recycle bin`
  String get payeesMoveToRecycleBin {
    return Intl.message(
      'Move to recycle bin',
      name: 'payeesMoveToRecycleBin',
      desc: '',
      args: [],
    );
  }

  /// `Move "{name}" to the recycle bin?`
  String payeesMoveToRecycleBinConfirm(Object name) {
    return Intl.message(
      'Move "$name" to the recycle bin?',
      name: 'payeesMoveToRecycleBinConfirm',
      desc: '',
      args: [name],
    );
  }

  /// `Move`
  String get payeesMove {
    return Intl.message('Move', name: 'payeesMove', desc: '', args: []);
  }

  /// `this payee`
  String get payeesThisPayee {
    return Intl.message(
      'this payee',
      name: 'payeesThisPayee',
      desc: '',
      args: [],
    );
  }

  /// `Delete permanently`
  String get payeesDeletePermanently {
    return Intl.message(
      'Delete permanently',
      name: 'payeesDeletePermanently',
      desc: '',
      args: [],
    );
  }

  /// `Permanently delete "{name}"? This action cannot be undone.`
  String payeesDeletePermanentlyConfirm(Object name) {
    return Intl.message(
      'Permanently delete "$name"? This action cannot be undone.',
      name: 'payeesDeletePermanentlyConfirm',
      desc: '',
      args: [name],
    );
  }

  /// `Delete`
  String get payeesDelete {
    return Intl.message('Delete', name: 'payeesDelete', desc: '', args: []);
  }

  /// `Payees`
  String get payeesTitle {
    return Intl.message('Payees', name: 'payeesTitle', desc: '', args: []);
  }

  /// `Search payee name`
  String get payeesSearchHint {
    return Intl.message(
      'Search payee name',
      name: 'payeesSearchHint',
      desc: '',
      args: [],
    );
  }

  /// `No payees yet. Tap + in the top right to add one.`
  String get payeesEmpty {
    return Intl.message(
      'No payees yet. Tap + in the top right to add one.',
      name: 'payeesEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Unnamed`
  String get payeesUnnamed {
    return Intl.message('Unnamed', name: 'payeesUnnamed', desc: '', args: []);
  }

  /// `Expense`
  String get payeesCanExpenseShort {
    return Intl.message(
      'Expense',
      name: 'payeesCanExpenseShort',
      desc: '',
      args: [],
    );
  }

  /// `Income`
  String get payeesCanIncomeShort {
    return Intl.message(
      'Income',
      name: 'payeesCanIncomeShort',
      desc: '',
      args: [],
    );
  }

  /// `Sort {sort}`
  String payeesSortValue(Object sort) {
    return Intl.message(
      'Sort $sort',
      name: 'payeesSortValue',
      desc: '',
      args: [sort],
    );
  }

  /// `Please enter a payee name`
  String get payeesNameRequired {
    return Intl.message(
      'Please enter a payee name',
      name: 'payeesNameRequired',
      desc: '',
      args: [],
    );
  }

  /// `Payee name`
  String get payeesNameLabel {
    return Intl.message(
      'Payee name',
      name: 'payeesNameLabel',
      desc: '',
      args: [],
    );
  }

  /// `e.g. KFC`
  String get payeesNameHint {
    return Intl.message('e.g. KFC', name: 'payeesNameHint', desc: '', args: []);
  }

  /// `Sort order (optional)`
  String get payeesSortLabel {
    return Intl.message(
      'Sort order (optional)',
      name: 'payeesSortLabel',
      desc: '',
      args: [],
    );
  }

  /// `Lower numbers appear first`
  String get payeesSortHint {
    return Intl.message(
      'Lower numbers appear first',
      name: 'payeesSortHint',
      desc: '',
      args: [],
    );
  }

  /// `Remark (optional)`
  String get payeesRemarkLabel {
    return Intl.message(
      'Remark (optional)',
      name: 'payeesRemarkLabel',
      desc: '',
      args: [],
    );
  }

  /// `Remark`
  String get payeesRemarkHint {
    return Intl.message('Remark', name: 'payeesRemarkHint', desc: '', args: []);
  }

  /// `Save changes`
  String get payeesSaveEdit {
    return Intl.message(
      'Save changes',
      name: 'payeesSaveEdit',
      desc: '',
      args: [],
    );
  }

  /// `Create payee`
  String get payeesCreate {
    return Intl.message(
      'Create payee',
      name: 'payeesCreate',
      desc: '',
      args: [],
    );
  }

  /// `Please select a book first`
  String get membersSelectBookFirst {
    return Intl.message(
      'Please select a book first',
      name: 'membersSelectBookFirst',
      desc: '',
      args: [],
    );
  }

  /// `Add member`
  String get membersAdd {
    return Intl.message('Add member', name: 'membersAdd', desc: '', args: []);
  }

  /// `Edit member`
  String get membersEdit {
    return Intl.message('Edit member', name: 'membersEdit', desc: '', args: []);
  }

  /// `Move to recycle bin`
  String get membersMoveToRecycleBin {
    return Intl.message(
      'Move to recycle bin',
      name: 'membersMoveToRecycleBin',
      desc: '',
      args: [],
    );
  }

  /// `Move "{name}" to the recycle bin?`
  String membersMoveToRecycleBinConfirm(Object name) {
    return Intl.message(
      'Move "$name" to the recycle bin?',
      name: 'membersMoveToRecycleBinConfirm',
      desc: '',
      args: [name],
    );
  }

  /// `Move`
  String get membersMove {
    return Intl.message('Move', name: 'membersMove', desc: '', args: []);
  }

  /// `this member`
  String get membersThisMember {
    return Intl.message(
      'this member',
      name: 'membersThisMember',
      desc: '',
      args: [],
    );
  }

  /// `Delete permanently`
  String get membersDeletePermanently {
    return Intl.message(
      'Delete permanently',
      name: 'membersDeletePermanently',
      desc: '',
      args: [],
    );
  }

  /// `Permanently delete "{name}"? This action cannot be undone.`
  String membersDeletePermanentlyConfirm(Object name) {
    return Intl.message(
      'Permanently delete "$name"? This action cannot be undone.',
      name: 'membersDeletePermanentlyConfirm',
      desc: '',
      args: [name],
    );
  }

  /// `Delete`
  String get membersDelete {
    return Intl.message('Delete', name: 'membersDelete', desc: '', args: []);
  }

  /// `Members`
  String get membersTitle {
    return Intl.message('Members', name: 'membersTitle', desc: '', args: []);
  }

  /// `Search member name`
  String get membersSearchHint {
    return Intl.message(
      'Search member name',
      name: 'membersSearchHint',
      desc: '',
      args: [],
    );
  }

  /// `No members yet. Tap + in the top right to add one.`
  String get membersEmpty {
    return Intl.message(
      'No members yet. Tap + in the top right to add one.',
      name: 'membersEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Unnamed`
  String get membersUnnamed {
    return Intl.message('Unnamed', name: 'membersUnnamed', desc: '', args: []);
  }

  /// `Enabled`
  String get membersStatusEnabled {
    return Intl.message(
      'Enabled',
      name: 'membersStatusEnabled',
      desc: '',
      args: [],
    );
  }

  /// `Disabled`
  String get membersStatusDisabled {
    return Intl.message(
      'Disabled',
      name: 'membersStatusDisabled',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a member name`
  String get membersNameRequired {
    return Intl.message(
      'Please enter a member name',
      name: 'membersNameRequired',
      desc: '',
      args: [],
    );
  }

  /// `Member name`
  String get membersNameLabel {
    return Intl.message(
      'Member name',
      name: 'membersNameLabel',
      desc: '',
      args: [],
    );
  }

  /// `e.g. John Doe`
  String get membersNameHint {
    return Intl.message(
      'e.g. John Doe',
      name: 'membersNameHint',
      desc: '',
      args: [],
    );
  }

  /// `Sort order (optional)`
  String get membersSortLabel {
    return Intl.message(
      'Sort order (optional)',
      name: 'membersSortLabel',
      desc: '',
      args: [],
    );
  }

  /// `Lower numbers appear first`
  String get membersSortHint {
    return Intl.message(
      'Lower numbers appear first',
      name: 'membersSortHint',
      desc: '',
      args: [],
    );
  }

  /// `Remark (optional)`
  String get membersRemarkLabel {
    return Intl.message(
      'Remark (optional)',
      name: 'membersRemarkLabel',
      desc: '',
      args: [],
    );
  }

  /// `Remark`
  String get membersRemarkHint {
    return Intl.message(
      'Remark',
      name: 'membersRemarkHint',
      desc: '',
      args: [],
    );
  }

  /// `Enable`
  String get membersEnable {
    return Intl.message('Enable', name: 'membersEnable', desc: '', args: []);
  }

  /// `Save changes`
  String get membersSaveEdit {
    return Intl.message(
      'Save changes',
      name: 'membersSaveEdit',
      desc: '',
      args: [],
    );
  }

  /// `Create member`
  String get membersCreate {
    return Intl.message(
      'Create member',
      name: 'membersCreate',
      desc: '',
      args: [],
    );
  }

  /// `Please select a group first`
  String get groupUsersSelectGroupFirst {
    return Intl.message(
      'Please select a group first',
      name: 'groupUsersSelectGroupFirst',
      desc: '',
      args: [],
    );
  }

  /// `Invite user`
  String get groupUsersInviteTitle {
    return Intl.message(
      'Invite user',
      name: 'groupUsersInviteTitle',
      desc: '',
      args: [],
    );
  }

  /// `Invitation sent`
  String get groupUsersInviteSent {
    return Intl.message(
      'Invitation sent',
      name: 'groupUsersInviteSent',
      desc: '',
      args: [],
    );
  }

  /// `Remove member`
  String get groupUsersRemoveTitle {
    return Intl.message(
      'Remove member',
      name: 'groupUsersRemoveTitle',
      desc: '',
      args: [],
    );
  }

  /// `Remove "{name}" from this group?`
  String groupUsersRemoveConfirm(Object name) {
    return Intl.message(
      'Remove "$name" from this group?',
      name: 'groupUsersRemoveConfirm',
      desc: '',
      args: [name],
    );
  }

  /// `Remove`
  String get groupUsersRemove {
    return Intl.message('Remove', name: 'groupUsersRemove', desc: '', args: []);
  }

  /// `Members`
  String get groupUsersTitle {
    return Intl.message('Members', name: 'groupUsersTitle', desc: '', args: []);
  }

  /// `Members · {name}`
  String groupUsersTitleWithName(Object name) {
    return Intl.message(
      'Members · $name',
      name: 'groupUsersTitleWithName',
      desc: '',
      args: [name],
    );
  }

  /// `Invite`
  String get groupUsersInvite {
    return Intl.message('Invite', name: 'groupUsersInvite', desc: '', args: []);
  }

  /// `No members in this group yet`
  String get groupUsersEmpty {
    return Intl.message(
      'No members in this group yet',
      name: 'groupUsersEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a username`
  String get groupUsersUsernameRequired {
    return Intl.message(
      'Please enter a username',
      name: 'groupUsersUsernameRequired',
      desc: '',
      args: [],
    );
  }

  /// `Please select a role`
  String get groupUsersRoleRequired {
    return Intl.message(
      'Please select a role',
      name: 'groupUsersRoleRequired',
      desc: '',
      args: [],
    );
  }

  /// `Username`
  String get groupUsersUsernameLabel {
    return Intl.message(
      'Username',
      name: 'groupUsersUsernameLabel',
      desc: '',
      args: [],
    );
  }

  /// `Enter the invitee's username`
  String get groupUsersUsernameHint {
    return Intl.message(
      'Enter the invitee\'s username',
      name: 'groupUsersUsernameHint',
      desc: '',
      args: [],
    );
  }

  /// `Role`
  String get groupUsersRoleLabel {
    return Intl.message(
      'Role',
      name: 'groupUsersRoleLabel',
      desc: '',
      args: [],
    );
  }

  /// `Send invitation`
  String get groupUsersSendInvite {
    return Intl.message(
      'Send invitation',
      name: 'groupUsersSendInvite',
      desc: '',
      args: [],
    );
  }

  /// `Select a book first`
  String get dashboardSelectBookFirst {
    return Intl.message(
      'Select a book first',
      name: 'dashboardSelectBookFirst',
      desc: '',
      args: [],
    );
  }

  /// `Add a record`
  String get dashboardQuickAdd {
    return Intl.message(
      'Add a record',
      name: 'dashboardQuickAdd',
      desc: '',
      args: [],
    );
  }

  /// `Net worth`
  String get dashboardNetWorth {
    return Intl.message(
      'Net worth',
      name: 'dashboardNetWorth',
      desc: '',
      args: [],
    );
  }

  /// `No records yet`
  String get dashboardNoRecordsYet {
    return Intl.message(
      'No records yet',
      name: 'dashboardNoRecordsYet',
      desc: '',
      args: [],
    );
  }

  /// `Add your first record`
  String get dashboardStartFirstBill {
    return Intl.message(
      'Add your first record',
      name: 'dashboardStartFirstBill',
      desc: '',
      args: [],
    );
  }

  /// `Assets`
  String get dashboardAssets {
    return Intl.message('Assets', name: 'dashboardAssets', desc: '', args: []);
  }

  /// `Liabilities`
  String get dashboardLiabilities {
    return Intl.message(
      'Liabilities',
      name: 'dashboardLiabilities',
      desc: '',
      args: [],
    );
  }

  /// `Period expense`
  String get dashboardPeriodExpense {
    return Intl.message(
      'Period expense',
      name: 'dashboardPeriodExpense',
      desc: '',
      args: [],
    );
  }

  /// `Period income`
  String get dashboardPeriodIncome {
    return Intl.message(
      'Period income',
      name: 'dashboardPeriodIncome',
      desc: '',
      args: [],
    );
  }

  /// `Expense trend`
  String get dashboardExpenseTrend {
    return Intl.message(
      'Expense trend',
      name: 'dashboardExpenseTrend',
      desc: '',
      args: [],
    );
  }

  /// `Income & expense trend`
  String get dashboardIncomeExpenseTrend {
    return Intl.message(
      'Income & expense trend',
      name: 'dashboardIncomeExpenseTrend',
      desc: '',
      args: [],
    );
  }

  /// `Not enough data`
  String get dashboardInsufficientData {
    return Intl.message(
      'Not enough data',
      name: 'dashboardInsufficientData',
      desc: '',
      args: [],
    );
  }

  /// `Failed to load`
  String get dashboardLoadFailed {
    return Intl.message(
      'Failed to load',
      name: 'dashboardLoadFailed',
      desc: '',
      args: [],
    );
  }

  /// `Select group`
  String get dashboardSelectGroup {
    return Intl.message(
      'Select group',
      name: 'dashboardSelectGroup',
      desc: '',
      args: [],
    );
  }

  /// `Select book`
  String get dashboardSelectBook {
    return Intl.message(
      'Select book',
      name: 'dashboardSelectBook',
      desc: '',
      args: [],
    );
  }

  /// `Top 3 expense categories`
  String get dashboardTopCategories {
    return Intl.message(
      'Top 3 expense categories',
      name: 'dashboardTopCategories',
      desc: '',
      args: [],
    );
  }

  /// `Uncategorized`
  String get dashboardUncategorized {
    return Intl.message(
      'Uncategorized',
      name: 'dashboardUncategorized',
      desc: '',
      args: [],
    );
  }

  /// `Recent bills`
  String get dashboardRecentBills {
    return Intl.message(
      'Recent bills',
      name: 'dashboardRecentBills',
      desc: '',
      args: [],
    );
  }

  /// `All`
  String get dashboardViewAll {
    return Intl.message('All', name: 'dashboardViewAll', desc: '', args: []);
  }

  /// `No bills yet`
  String get dashboardNoBillsYet {
    return Intl.message(
      'No bills yet',
      name: 'dashboardNoBillsYet',
      desc: '',
      args: [],
    );
  }

  /// `Bill`
  String get dashboardBillFallback {
    return Intl.message(
      'Bill',
      name: 'dashboardBillFallback',
      desc: '',
      args: [],
    );
  }

  /// `Assets & liabilities`
  String get dashboardAssetsLiabilities {
    return Intl.message(
      'Assets & liabilities',
      name: 'dashboardAssetsLiabilities',
      desc: '',
      args: [],
    );
  }

  /// `No data`
  String get dashboardNoData {
    return Intl.message('No data', name: 'dashboardNoData', desc: '', args: []);
  }

  /// `Edit layout`
  String get dashboardEditLayout {
    return Intl.message(
      'Edit layout',
      name: 'dashboardEditLayout',
      desc: '',
      args: [],
    );
  }

  /// `Done`
  String get dashboardDoneEditing {
    return Intl.message(
      'Done',
      name: 'dashboardDoneEditing',
      desc: '',
      args: [],
    );
  }

  /// `Reset layout`
  String get dashboardResetLayout {
    return Intl.message(
      'Reset layout',
      name: 'dashboardResetLayout',
      desc: '',
      args: [],
    );
  }

  /// `Available cards`
  String get dashboardHiddenCards {
    return Intl.message(
      'Available cards',
      name: 'dashboardHiddenCards',
      desc: '',
      args: [],
    );
  }

  /// `No cards to show. Tap edit to add some.`
  String get dashboardNoVisibleCards {
    return Intl.message(
      'No cards to show. Tap edit to add some.',
      name: 'dashboardNoVisibleCards',
      desc: '',
      args: [],
    );
  }

  /// `Long-press a card and drop it onto another to push that card aside. Tap × to remove.`
  String get dashboardDragToReorder {
    return Intl.message(
      'Long-press a card and drop it onto another to push that card aside. Tap × to remove.',
      name: 'dashboardDragToReorder',
      desc: '',
      args: [],
    );
  }

  /// `Remove card`
  String get dashboardRemoveCard {
    return Intl.message(
      'Remove card',
      name: 'dashboardRemoveCard',
      desc: '',
      args: [],
    );
  }

  /// `Place`
  String get dashboardPlaceCard {
    return Intl.message(
      'Place',
      name: 'dashboardPlaceCard',
      desc: '',
      args: [],
    );
  }

  /// `Select a book first`
  String get statsSelectBookFirst {
    return Intl.message(
      'Select a book first',
      name: 'statsSelectBookFirst',
      desc: '',
      args: [],
    );
  }

  /// `Category share`
  String get statsCategoryShare {
    return Intl.message(
      'Category share',
      name: 'statsCategoryShare',
      desc: '',
      args: [],
    );
  }

  /// `Payees`
  String get statsPayees {
    return Intl.message('Payees', name: 'statsPayees', desc: '', args: []);
  }

  /// `Tags`
  String get statsTags {
    return Intl.message('Tags', name: 'statsTags', desc: '', args: []);
  }

  /// `No records this period`
  String get statsNoRecordsThisPeriod {
    return Intl.message(
      'No records this period',
      name: 'statsNoRecordsThisPeriod',
      desc: '',
      args: [],
    );
  }

  /// `Unnamed`
  String get statsUnnamed {
    return Intl.message('Unnamed', name: 'statsUnnamed', desc: '', args: []);
  }

  /// `Uncategorized`
  String get statsUncategorized {
    return Intl.message(
      'Uncategorized',
      name: 'statsUncategorized',
      desc: '',
      args: [],
    );
  }

  /// `Stats`
  String get statsTitle {
    return Intl.message('Stats', name: 'statsTitle', desc: '', args: []);
  }

  /// `This week`
  String get statsRangeWeek {
    return Intl.message(
      'This week',
      name: 'statsRangeWeek',
      desc: '',
      args: [],
    );
  }

  /// `This period`
  String get statsRangePeriod {
    return Intl.message(
      'This period',
      name: 'statsRangePeriod',
      desc: '',
      args: [],
    );
  }

  /// `This year`
  String get statsRangeYear {
    return Intl.message(
      'This year',
      name: 'statsRangeYear',
      desc: '',
      args: [],
    );
  }

  /// `Custom`
  String get statsRangeCustom {
    return Intl.message('Custom', name: 'statsRangeCustom', desc: '', args: []);
  }

  /// `Expense`
  String get statsExpense {
    return Intl.message('Expense', name: 'statsExpense', desc: '', args: []);
  }

  /// `Income`
  String get statsIncome {
    return Intl.message('Income', name: 'statsIncome', desc: '', args: []);
  }

  /// `Surplus`
  String get statsSurplus {
    return Intl.message('Surplus', name: 'statsSurplus', desc: '', args: []);
  }

  /// `Cashflow insight`
  String get statsBasicTitle {
    return Intl.message(
      'Cashflow insight',
      name: 'statsBasicTitle',
      desc: '',
      args: [],
    );
  }

  /// `Expense analytics`
  String get statsExpenseAnalytics {
    return Intl.message(
      'Expense analytics',
      name: 'statsExpenseAnalytics',
      desc: '',
      args: [],
    );
  }

  /// `Income analytics`
  String get statsIncomeAnalytics {
    return Intl.message(
      'Income analytics',
      name: 'statsIncomeAnalytics',
      desc: '',
      args: [],
    );
  }

  /// `Expense category share`
  String get statsExpenseCategoryShare {
    return Intl.message(
      'Expense category share',
      name: 'statsExpenseCategoryShare',
      desc: '',
      args: [],
    );
  }

  /// `Income category share`
  String get statsIncomeCategoryShare {
    return Intl.message(
      'Income category share',
      name: 'statsIncomeCategoryShare',
      desc: '',
      args: [],
    );
  }

  /// `Expense tags`
  String get statsExpenseTags {
    return Intl.message(
      'Expense tags',
      name: 'statsExpenseTags',
      desc: '',
      args: [],
    );
  }

  /// `Income tags`
  String get statsIncomeTags {
    return Intl.message(
      'Income tags',
      name: 'statsIncomeTags',
      desc: '',
      args: [],
    );
  }

  /// `Expense payees`
  String get statsExpensePayees {
    return Intl.message(
      'Expense payees',
      name: 'statsExpensePayees',
      desc: '',
      args: [],
    );
  }

  /// `Income payees`
  String get statsIncomePayees {
    return Intl.message(
      'Income payees',
      name: 'statsIncomePayees',
      desc: '',
      args: [],
    );
  }

  /// `Expense trend`
  String get statsExpenseTrend {
    return Intl.message(
      'Expense trend',
      name: 'statsExpenseTrend',
      desc: '',
      args: [],
    );
  }

  /// `Income trend`
  String get statsIncomeTrend {
    return Intl.message(
      'Income trend',
      name: 'statsIncomeTrend',
      desc: '',
      args: [],
    );
  }

  /// `Export`
  String get ioTitle {
    return Intl.message('Export', name: 'ioTitle', desc: '', args: []);
  }

  /// `Select a book first`
  String get ioSelectBookFirst {
    return Intl.message(
      'Select a book first',
      name: 'ioSelectBookFirst',
      desc: '',
      args: [],
    );
  }

  /// `Download started: {filename}`
  String ioDownloadStarted(Object filename) {
    return Intl.message(
      'Download started: $filename',
      name: 'ioDownloadStarted',
      desc: '',
      args: [filename],
    );
  }

  /// `Saved to: {path}`
  String ioSavedTo(Object path) {
    return Intl.message(
      'Saved to: $path',
      name: 'ioSavedTo',
      desc: '',
      args: [path],
    );
  }

  /// `Export failed: no data`
  String get ioExportFailedNoData {
    return Intl.message(
      'Export failed: no data',
      name: 'ioExportFailedNoData',
      desc: '',
      args: [],
    );
  }

  /// `Download failed`
  String get ioDownloadFailed {
    return Intl.message(
      'Download failed',
      name: 'ioDownloadFailed',
      desc: '',
      args: [],
    );
  }

  /// `Failed to read file`
  String get ioReadFileFailed {
    return Intl.message(
      'Failed to read file',
      name: 'ioReadFileFailed',
      desc: '',
      args: [],
    );
  }

  /// `Import result`
  String get ioImportResult {
    return Intl.message(
      'Import result',
      name: 'ioImportResult',
      desc: '',
      args: [],
    );
  }

  /// `Export bills (Excel)`
  String get ioExportBillsTitle {
    return Intl.message(
      'Export bills (Excel)',
      name: 'ioExportBillsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Export bills from the current book (with filters, up to 10,000 rows)`
  String get ioExportBillsSubtitle {
    return Intl.message(
      'Export bills from the current book (with filters, up to 10,000 rows)',
      name: 'ioExportBillsSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Export`
  String get ioExport {
    return Intl.message('Export', name: 'ioExport', desc: '', args: []);
  }

  /// `Download import template`
  String get ioDownloadTemplateTitle {
    return Intl.message(
      'Download import template',
      name: 'ioDownloadTemplateTitle',
      desc: '',
      args: [],
    );
  }

  /// `Get the standard Excel template, fill it in, then import`
  String get ioDownloadTemplateSubtitle {
    return Intl.message(
      'Get the standard Excel template, fill it in, then import',
      name: 'ioDownloadTemplateSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Download template`
  String get ioDownloadTemplate {
    return Intl.message(
      'Download template',
      name: 'ioDownloadTemplate',
      desc: '',
      args: [],
    );
  }

  /// `Import bills (Excel)`
  String get ioImportBillsTitle {
    return Intl.message(
      'Import bills (Excel)',
      name: 'ioImportBillsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Upload an .xlsx file; results are shown after import`
  String get ioImportBillsSubtitle {
    return Intl.message(
      'Upload an .xlsx file; results are shown after import',
      name: 'ioImportBillsSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Choose file to import`
  String get ioSelectFileImport {
    return Intl.message(
      'Choose file to import',
      name: 'ioSelectFileImport',
      desc: '',
      args: [],
    );
  }

  /// `Success`
  String get ioSuccess {
    return Intl.message('Success', name: 'ioSuccess', desc: '', args: []);
  }

  /// `Failed`
  String get ioFail {
    return Intl.message('Failed', name: 'ioFail', desc: '', args: []);
  }

  /// `Total`
  String get ioTotal {
    return Intl.message('Total', name: 'ioTotal', desc: '', args: []);
  }

  /// `Import failed with error rows. Download the error details (Excel) to see the reasons.`
  String get ioImportFailedWithErrors {
    return Intl.message(
      'Import failed with error rows. Download the error details (Excel) to see the reasons.',
      name: 'ioImportFailedWithErrors',
      desc: '',
      args: [],
    );
  }

  /// `Download error details`
  String get ioDownloadErrorDetails {
    return Intl.message(
      'Download error details',
      name: 'ioDownloadErrorDetails',
      desc: '',
      args: [],
    );
  }

  /// `Done`
  String get ioDone {
    return Intl.message('Done', name: 'ioDone', desc: '', args: []);
  }

  /// `All`
  String get manageSharedTabAll {
    return Intl.message('All', name: 'manageSharedTabAll', desc: '', args: []);
  }

  /// `Enabled`
  String get manageSharedTabEnabled {
    return Intl.message(
      'Enabled',
      name: 'manageSharedTabEnabled',
      desc: '',
      args: [],
    );
  }

  /// `Disabled`
  String get manageSharedTabDisabled {
    return Intl.message(
      'Disabled',
      name: 'manageSharedTabDisabled',
      desc: '',
      args: [],
    );
  }

  /// `Recycle bin`
  String get manageSharedTabRecycleBin {
    return Intl.message(
      'Recycle bin',
      name: 'manageSharedTabRecycleBin',
      desc: '',
      args: [],
    );
  }

  /// `Search by name`
  String get manageSharedSearchHint {
    return Intl.message(
      'Search by name',
      name: 'manageSharedSearchHint',
      desc: '',
      args: [],
    );
  }

  /// `Restore`
  String get manageSharedPutBack {
    return Intl.message(
      'Restore',
      name: 'manageSharedPutBack',
      desc: '',
      args: [],
    );
  }

  /// `Delete permanently`
  String get manageSharedDeleteForever {
    return Intl.message(
      'Delete permanently',
      name: 'manageSharedDeleteForever',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get manageSharedEdit {
    return Intl.message('Edit', name: 'manageSharedEdit', desc: '', args: []);
  }

  /// `Move to recycle bin`
  String get manageSharedMoveToRecycleBin {
    return Intl.message(
      'Move to recycle bin',
      name: 'manageSharedMoveToRecycleBin',
      desc: '',
      args: [],
    );
  }

  /// `Allow screenshots and screen recording`
  String get profileScreenCaptureAllowed {
    return Intl.message(
      'Allow screenshots and screen recording',
      name: 'profileScreenCaptureAllowed',
      desc: '',
      args: [],
    );
  }

  /// `Screenshots, recording, and app previews are protected by default. Enable only when you need to share content.`
  String get profileScreenCaptureAllowedSubtitle {
    return Intl.message(
      'Screenshots, recording, and app previews are protected by default. Enable only when you need to share content.',
      name: 'profileScreenCaptureAllowedSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `iPhone and iPad cannot block system screenshots. Protection masks recording, mirroring, and app-switcher previews.`
  String get profileScreenCaptureAllowedIosHint {
    return Intl.message(
      'iPhone and iPad cannot block system screenshots. Protection masks recording, mirroring, and app-switcher previews.',
      name: 'profileScreenCaptureAllowedIosHint',
      desc: '',
      args: [],
    );
  }

  /// `Screen-capture protection could not be applied. Please try again.`
  String get profileScreenCaptureProtectionFailed {
    return Intl.message(
      'Screen-capture protection could not be applied. Please try again.',
      name: 'profileScreenCaptureProtectionFailed',
      desc: '',
      args: [],
    );
  }

  /// `App lock`
  String get profileAppLock {
    return Intl.message('App lock', name: 'profileAppLock', desc: '', args: []);
  }

  /// `When locked, use face, fingerprint, a custom password, or a custom pattern.`
  String get profileAppLockSubtitle {
    return Intl.message(
      'When locked, use face, fingerprint, a custom password, or a custom pattern.',
      name: 'profileAppLockSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Unlock method`
  String get profileAppLockMethod {
    return Intl.message(
      'Unlock method',
      name: 'profileAppLockMethod',
      desc: '',
      args: [],
    );
  }

  /// `Face`
  String get profileAppLockMethodFace {
    return Intl.message(
      'Face',
      name: 'profileAppLockMethodFace',
      desc: '',
      args: [],
    );
  }

  /// `Fingerprint`
  String get profileAppLockMethodFingerprint {
    return Intl.message(
      'Fingerprint',
      name: 'profileAppLockMethodFingerprint',
      desc: '',
      args: [],
    );
  }

  /// `Custom password`
  String get profileAppLockMethodPassword {
    return Intl.message(
      'Custom password',
      name: 'profileAppLockMethodPassword',
      desc: '',
      args: [],
    );
  }

  /// `Custom pattern`
  String get profileAppLockMethodGesture {
    return Intl.message(
      'Custom pattern',
      name: 'profileAppLockMethodGesture',
      desc: '',
      args: [],
    );
  }

  /// `Choose unlock method`
  String get profileAppLockPickMethod {
    return Intl.message(
      'Choose unlock method',
      name: 'profileAppLockPickMethod',
      desc: '',
      args: [],
    );
  }

  /// `Set app password`
  String get profileAppLockPasswordSetup {
    return Intl.message(
      'Set app password',
      name: 'profileAppLockPasswordSetup',
      desc: '',
      args: [],
    );
  }

  /// `Confirm password`
  String get profileAppLockPasswordConfirm {
    return Intl.message(
      'Confirm password',
      name: 'profileAppLockPasswordConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Use at least 4 characters`
  String get profileAppLockPasswordTooShort {
    return Intl.message(
      'Use at least 4 characters',
      name: 'profileAppLockPasswordTooShort',
      desc: '',
      args: [],
    );
  }

  /// `Passwords do not match`
  String get profileAppLockPasswordMismatch {
    return Intl.message(
      'Passwords do not match',
      name: 'profileAppLockPasswordMismatch',
      desc: '',
      args: [],
    );
  }

  /// `Incorrect password`
  String get profileAppLockPasswordWrong {
    return Intl.message(
      'Incorrect password',
      name: 'profileAppLockPasswordWrong',
      desc: '',
      args: [],
    );
  }

  /// `Set app pattern`
  String get profileAppLockGestureSetup {
    return Intl.message(
      'Set app pattern',
      name: 'profileAppLockGestureSetup',
      desc: '',
      args: [],
    );
  }

  /// `Connect at least 4 dots`
  String get profileAppLockGestureHint {
    return Intl.message(
      'Connect at least 4 dots',
      name: 'profileAppLockGestureHint',
      desc: '',
      args: [],
    );
  }

  /// `Draw the pattern again`
  String get profileAppLockGestureAgain {
    return Intl.message(
      'Draw the pattern again',
      name: 'profileAppLockGestureAgain',
      desc: '',
      args: [],
    );
  }

  /// `Draw your unlock pattern`
  String get profileAppLockGestureUnlock {
    return Intl.message(
      'Draw your unlock pattern',
      name: 'profileAppLockGestureUnlock',
      desc: '',
      args: [],
    );
  }

  /// `Patterns did not match. Try again.`
  String get profileAppLockGestureMismatch {
    return Intl.message(
      'Patterns did not match. Try again.',
      name: 'profileAppLockGestureMismatch',
      desc: '',
      args: [],
    );
  }

  /// `Incorrect pattern`
  String get profileAppLockGestureWrong {
    return Intl.message(
      'Incorrect pattern',
      name: 'profileAppLockGestureWrong',
      desc: '',
      args: [],
    );
  }

  /// `Touch the fingerprint sensor`
  String get profileAppLockFingerprintHint {
    return Intl.message(
      'Touch the fingerprint sensor',
      name: 'profileAppLockFingerprintHint',
      desc: '',
      args: [],
    );
  }

  /// `Set a custom password or pattern. Face and fingerprint need to be enrolled on the device.`
  String get profileAppLockUnavailable {
    return Intl.message(
      'Set a custom password or pattern. Face and fingerprint need to be enrolled on the device.',
      name: 'profileAppLockUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `Verification failed. App lock was not turned on.`
  String get profileAppLockFailed {
    return Intl.message(
      'Verification failed. App lock was not turned on.',
      name: 'profileAppLockFailed',
      desc: '',
      args: [],
    );
  }

  /// `Verify to enable app lock`
  String get profileAppLockEnableReason {
    return Intl.message(
      'Verify to enable app lock',
      name: 'profileAppLockEnableReason',
      desc: '',
      args: [],
    );
  }

  /// `Hao Ji is locked`
  String get appLockTitle {
    return Intl.message(
      'Hao Ji is locked',
      name: 'appLockTitle',
      desc: '',
      args: [],
    );
  }

  /// `Choose how to unlock`
  String get appLockSubtitle {
    return Intl.message(
      'Choose how to unlock',
      name: 'appLockSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Choose how to unlock`
  String get appLockPickMethod {
    return Intl.message(
      'Choose how to unlock',
      name: 'appLockPickMethod',
      desc: '',
      args: [],
    );
  }

  /// `Verify to unlock Hao Ji`
  String get appLockReason {
    return Intl.message(
      'Verify to unlock Hao Ji',
      name: 'appLockReason',
      desc: '',
      args: [],
    );
  }

  /// `Verify`
  String get appLockUnlock {
    return Intl.message('Verify', name: 'appLockUnlock', desc: '', args: []);
  }

  /// `Unlock`
  String get appLockUnlockCta {
    return Intl.message('Unlock', name: 'appLockUnlockCta', desc: '', args: []);
  }

  /// `Add desktop widget`
  String get profileDesktopWidget {
    return Intl.message(
      'Add desktop widget',
      name: 'profileDesktopWidget',
      desc: '',
      args: [],
    );
  }

  /// `Includes the 6×4 stats calendar; or add it from the home screen`
  String get profileDesktopWidgetSubtitle {
    return Intl.message(
      'Includes the 6×4 stats calendar; or add it from the home screen',
      name: 'profileDesktopWidgetSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Edit profile`
  String get profileEditTitle {
    return Intl.message(
      'Edit profile',
      name: 'profileEditTitle',
      desc: '',
      args: [],
    );
  }

  /// `Profile`
  String get profileDetailsTitle {
    return Intl.message(
      'Profile',
      name: 'profileDetailsTitle',
      desc: '',
      args: [],
    );
  }

  /// `View profile`
  String get profileViewProfile {
    return Intl.message(
      'View profile',
      name: 'profileViewProfile',
      desc: '',
      args: [],
    );
  }

  /// `Personal details`
  String get profileDetailedInformation {
    return Intl.message(
      'Personal details',
      name: 'profileDetailedInformation',
      desc: '',
      args: [],
    );
  }

  /// `System records`
  String get profileSystemRecords {
    return Intl.message(
      'System records',
      name: 'profileSystemRecords',
      desc: '',
      args: [],
    );
  }

  /// `Username`
  String get profileUsername {
    return Intl.message(
      'Username',
      name: 'profileUsername',
      desc: '',
      args: [],
    );
  }

  /// `Role`
  String get profileRole {
    return Intl.message('Role', name: 'profileRole', desc: '', args: []);
  }

  /// `Login IP`
  String get profileLoginIp {
    return Intl.message('Login IP', name: 'profileLoginIp', desc: '', args: []);
  }

  /// `Login time`
  String get profileLoginTime {
    return Intl.message(
      'Login time',
      name: 'profileLoginTime',
      desc: '',
      args: [],
    );
  }

  /// `Remark`
  String get profileRemark {
    return Intl.message('Remark', name: 'profileRemark', desc: '', args: []);
  }

  /// `Not set`
  String get profileNotSet {
    return Intl.message('Not set', name: 'profileNotSet', desc: '', args: []);
  }

  /// `Edit avatar`
  String get profileEditAvatar {
    return Intl.message(
      'Edit avatar',
      name: 'profileEditAvatar',
      desc: '',
      args: [],
    );
  }

  /// `Profile QR code`
  String get profileQrCode {
    return Intl.message(
      'Profile QR code',
      name: 'profileQrCode',
      desc: '',
      args: [],
    );
  }

  /// `Back to profile center`
  String get profileBack {
    return Intl.message(
      'Back to profile center',
      name: 'profileBack',
      desc: '',
      args: [],
    );
  }

  /// `Missing user info, cannot upload`
  String get profileMissingUserInfoUpload {
    return Intl.message(
      'Missing user info, cannot upload',
      name: 'profileMissingUserInfoUpload',
      desc: '',
      args: [],
    );
  }

  /// `Avatar updated`
  String get profileAvatarUpdated {
    return Intl.message(
      'Avatar updated',
      name: 'profileAvatarUpdated',
      desc: '',
      args: [],
    );
  }

  /// `Upload failed: {error}`
  String profileUploadFailed(Object error) {
    return Intl.message(
      'Upload failed: $error',
      name: 'profileUploadFailed',
      desc: '',
      args: [error],
    );
  }

  /// `Missing user info, cannot save`
  String get profileMissingUserInfoSave {
    return Intl.message(
      'Missing user info, cannot save',
      name: 'profileMissingUserInfoSave',
      desc: '',
      args: [],
    );
  }

  /// `Nickname cannot be empty`
  String get profileNicknameRequired {
    return Intl.message(
      'Nickname cannot be empty',
      name: 'profileNicknameRequired',
      desc: '',
      args: [],
    );
  }

  /// `Profile saved`
  String get profileSaved {
    return Intl.message(
      'Profile saved',
      name: 'profileSaved',
      desc: '',
      args: [],
    );
  }

  /// `Save failed: {error}`
  String profileSaveFailed(Object error) {
    return Intl.message(
      'Save failed: $error',
      name: 'profileSaveFailed',
      desc: '',
      args: [error],
    );
  }

  /// `Missing user info, cannot change password`
  String get profileMissingUserInfoPassword {
    return Intl.message(
      'Missing user info, cannot change password',
      name: 'profileMissingUserInfoPassword',
      desc: '',
      args: [],
    );
  }

  /// `Change password`
  String get profileChangePassword {
    return Intl.message(
      'Change password',
      name: 'profileChangePassword',
      desc: '',
      args: [],
    );
  }

  /// `Nickname`
  String get profileNickname {
    return Intl.message(
      'Nickname',
      name: 'profileNickname',
      desc: '',
      args: [],
    );
  }

  /// `Enter a nickname`
  String get profileNicknameHint {
    return Intl.message(
      'Enter a nickname',
      name: 'profileNicknameHint',
      desc: '',
      args: [],
    );
  }

  /// `Phone`
  String get profilePhone {
    return Intl.message('Phone', name: 'profilePhone', desc: '', args: []);
  }

  /// `Enter a phone number`
  String get profilePhoneHint {
    return Intl.message(
      'Enter a phone number',
      name: 'profilePhoneHint',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get profileEmail {
    return Intl.message('Email', name: 'profileEmail', desc: '', args: []);
  }

  /// `Enter an email`
  String get profileEmailHint {
    return Intl.message(
      'Enter an email',
      name: 'profileEmailHint',
      desc: '',
      args: [],
    );
  }

  /// `Tap to change avatar`
  String get profileTapToChangeAvatar {
    return Intl.message(
      'Tap to change avatar',
      name: 'profileTapToChangeAvatar',
      desc: '',
      args: [],
    );
  }

  /// `Gender`
  String get profileSex {
    return Intl.message('Gender', name: 'profileSex', desc: '', args: []);
  }

  /// `Male`
  String get profileSexMale {
    return Intl.message('Male', name: 'profileSexMale', desc: '', args: []);
  }

  /// `Female`
  String get profileSexFemale {
    return Intl.message('Female', name: 'profileSexFemale', desc: '', args: []);
  }

  /// `Enter the old and new passwords`
  String get profilePasswordFillOldNew {
    return Intl.message(
      'Enter the old and new passwords',
      name: 'profilePasswordFillOldNew',
      desc: '',
      args: [],
    );
  }

  /// `New password must be at least 6 characters`
  String get profilePasswordMinLength {
    return Intl.message(
      'New password must be at least 6 characters',
      name: 'profilePasswordMinLength',
      desc: '',
      args: [],
    );
  }

  /// `The new passwords do not match`
  String get profilePasswordMismatch {
    return Intl.message(
      'The new passwords do not match',
      name: 'profilePasswordMismatch',
      desc: '',
      args: [],
    );
  }

  /// `Password changed successfully`
  String get profilePasswordChanged {
    return Intl.message(
      'Password changed successfully',
      name: 'profilePasswordChanged',
      desc: '',
      args: [],
    );
  }

  /// `Change failed: {error}`
  String profilePasswordChangeFailed(Object error) {
    return Intl.message(
      'Change failed: $error',
      name: 'profilePasswordChangeFailed',
      desc: '',
      args: [error],
    );
  }

  /// `Old password`
  String get profileOldPassword {
    return Intl.message(
      'Old password',
      name: 'profileOldPassword',
      desc: '',
      args: [],
    );
  }

  /// `New password`
  String get profileNewPassword {
    return Intl.message(
      'New password',
      name: 'profileNewPassword',
      desc: '',
      args: [],
    );
  }

  /// `Confirm new password`
  String get profileConfirmNewPassword {
    return Intl.message(
      'Confirm new password',
      name: 'profileConfirmNewPassword',
      desc: '',
      args: [],
    );
  }

  /// `Confirm change`
  String get profileConfirmChange {
    return Intl.message(
      'Confirm change',
      name: 'profileConfirmChange',
      desc: '',
      args: [],
    );
  }

  /// `Income`
  String get profileColorIncome {
    return Intl.message(
      'Income',
      name: 'profileColorIncome',
      desc: '',
      args: [],
    );
  }

  /// `Expense`
  String get profileColorExpense {
    return Intl.message(
      'Expense',
      name: 'profileColorExpense',
      desc: '',
      args: [],
    );
  }

  /// `Transfer`
  String get profileColorTransfer {
    return Intl.message(
      'Transfer',
      name: 'profileColorTransfer',
      desc: '',
      args: [],
    );
  }

  /// `Adjustment`
  String get profileColorAdjust {
    return Intl.message(
      'Adjustment',
      name: 'profileColorAdjust',
      desc: '',
      args: [],
    );
  }

  /// `Advance`
  String get profileColorAdvance {
    return Intl.message(
      'Advance',
      name: 'profileColorAdvance',
      desc: '',
      args: [],
    );
  }

  /// `Reimbursement`
  String get profileColorReimburse {
    return Intl.message(
      'Reimbursement',
      name: 'profileColorReimburse',
      desc: '',
      args: [],
    );
  }

  /// `Holiday`
  String get profileColorHoliday {
    return Intl.message(
      'Holiday',
      name: 'profileColorHoliday',
      desc: '',
      args: [],
    );
  }

  /// `Rest day`
  String get profileColorRest {
    return Intl.message(
      'Rest day',
      name: 'profileColorRest',
      desc: '',
      args: [],
    );
  }

  /// `Workday makeup`
  String get profileColorWork {
    return Intl.message(
      'Workday makeup',
      name: 'profileColorWork',
      desc: '',
      args: [],
    );
  }

  /// `Default red/green`
  String get profileColorPresetDefault {
    return Intl.message(
      'Default red/green',
      name: 'profileColorPresetDefault',
      desc: '',
      args: [],
    );
  }

  /// `Red-green colorblind friendly`
  String get profileColorPresetDeuteranopia {
    return Intl.message(
      'Red-green colorblind friendly',
      name: 'profileColorPresetDeuteranopia',
      desc: '',
      args: [],
    );
  }

  /// `Protanopia friendly`
  String get profileColorPresetProtanopia {
    return Intl.message(
      'Protanopia friendly',
      name: 'profileColorPresetProtanopia',
      desc: '',
      args: [],
    );
  }

  /// `Blue-yellow colorblind friendly`
  String get profileColorPresetTritanopia {
    return Intl.message(
      'Blue-yellow colorblind friendly',
      name: 'profileColorPresetTritanopia',
      desc: '',
      args: [],
    );
  }

  /// `Colorblind-friendly presets`
  String get profileColorPresetTitle {
    return Intl.message(
      'Colorblind-friendly presets',
      name: 'profileColorPresetTitle',
      desc: '',
      args: [],
    );
  }

  /// `Restore default`
  String get profileRestoreDefault {
    return Intl.message(
      'Restore default',
      name: 'profileRestoreDefault',
      desc: '',
      args: [],
    );
  }

  /// `View table`
  String get statsViewTable {
    return Intl.message(
      'View table',
      name: 'statsViewTable',
      desc: '',
      args: [],
    );
  }

  /// `View chart`
  String get statsViewChart {
    return Intl.message(
      'View chart',
      name: 'statsViewChart',
      desc: '',
      args: [],
    );
  }

  /// `Item`
  String get statsTableItem {
    return Intl.message('Item', name: 'statsTableItem', desc: '', args: []);
  }

  /// `Value`
  String get statsTableValue {
    return Intl.message('Value', name: 'statsTableValue', desc: '', args: []);
  }

  /// `Share`
  String get statsTableShare {
    return Intl.message('Share', name: 'statsTableShare', desc: '', args: []);
  }

  /// `Detail`
  String get statsTableDetail {
    return Intl.message('Detail', name: 'statsTableDetail', desc: '', args: []);
  }

  /// `Chart data table, {count} rows`
  String statsTableSemantics(Object count) {
    return Intl.message(
      'Chart data table, $count rows',
      name: 'statsTableSemantics',
      desc: '',
      args: [count],
    );
  }

  /// `Donut chart, {count} items`
  String statsDonutChartSemantics(Object count) {
    return Intl.message(
      'Donut chart, $count items',
      name: 'statsDonutChartSemantics',
      desc: '',
      args: [count],
    );
  }

  /// `Line chart, {count} points`
  String statsLineChartSemantics(Object count) {
    return Intl.message(
      'Line chart, $count points',
      name: 'statsLineChartSemantics',
      desc: '',
      args: [count],
    );
  }

  /// `Bar chart, {count} items`
  String statsBarChartSemantics(Object count) {
    return Intl.message(
      'Bar chart, $count items',
      name: 'statsBarChartSemantics',
      desc: '',
      args: [count],
    );
  }

  /// `Save failed, please try again`
  String get profileSaveFailedRetry {
    return Intl.message(
      'Save failed, please try again',
      name: 'profileSaveFailedRetry',
      desc: '',
      args: [],
    );
  }

  /// `Failed to load profile`
  String get profileLoadFailed {
    return Intl.message(
      'Failed to load profile',
      name: 'profileLoadFailed',
      desc: '',
      args: [],
    );
  }

  /// `Not logged in`
  String get profileNotLoggedIn {
    return Intl.message(
      'Not logged in',
      name: 'profileNotLoggedIn',
      desc: '',
      args: [],
    );
  }

  /// `Not selected`
  String get profileNotSelected {
    return Intl.message(
      'Not selected',
      name: 'profileNotSelected',
      desc: '',
      args: [],
    );
  }

  /// `Day {day} of each month`
  String profileMonthStartDayValue(Object day) {
    return Intl.message(
      'Day $day of each month',
      name: 'profileMonthStartDayValue',
      desc: '',
      args: [day],
    );
  }

  /// `Short months use the last day automatically`
  String get profileMonthStartDayHint {
    return Intl.message(
      'Short months use the last day automatically',
      name: 'profileMonthStartDayHint',
      desc: '',
      args: [],
    );
  }

  /// `Use current time when copying`
  String get profileCopyUsesCurrentTime {
    return Intl.message(
      'Use current time when copying',
      name: 'profileCopyUsesCurrentTime',
      desc: '',
      args: [],
    );
  }

  /// `When off, copied bills keep the source bill time`
  String get profileCopyUsesCurrentTimeSubtitle {
    return Intl.message(
      'When off, copied bills keep the source bill time',
      name: 'profileCopyUsesCurrentTimeSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Refresh`
  String get profileRefresh {
    return Intl.message('Refresh', name: 'profileRefresh', desc: '', args: []);
  }

  /// `Refreshing exchange rates…`
  String get profileCurrencyRefreshing {
    return Intl.message(
      'Refreshing exchange rates…',
      name: 'profileCurrencyRefreshing',
      desc: '',
      args: [],
    );
  }

  /// `Exchange rates refreshed`
  String get profileCurrencyRefreshed {
    return Intl.message(
      'Exchange rates refreshed',
      name: 'profileCurrencyRefreshed',
      desc: '',
      args: [],
    );
  }

  /// `Refresh failed: {error}`
  String profileCurrencyRefreshFailed(Object error) {
    return Intl.message(
      'Refresh failed: $error',
      name: 'profileCurrencyRefreshFailed',
      desc: '',
      args: [error],
    );
  }

  /// `About FortuneBoot`
  String get profileAboutApp {
    return Intl.message(
      'About FortuneBoot',
      name: 'profileAboutApp',
      desc: '',
      args: [],
    );
  }

  /// `App version`
  String get profileAppVersion {
    return Intl.message(
      'App version',
      name: 'profileAppVersion',
      desc: '',
      args: [],
    );
  }

  /// `API version`
  String get profileApiVersion {
    return Intl.message(
      'API version',
      name: 'profileApiVersion',
      desc: '',
      args: [],
    );
  }

  /// `App ICP`
  String get profileAppIcp {
    return Intl.message('App ICP', name: 'profileAppIcp', desc: '', args: []);
  }

  /// `Server ICP`
  String get profileIcp {
    return Intl.message('Server ICP', name: 'profileIcp', desc: '', args: []);
  }

  /// `Signing validity`
  String get profileSigningValidity {
    return Intl.message(
      'Signing validity',
      name: 'profileSigningValidity',
      desc: '',
      args: [],
    );
  }

  /// `Expired`
  String get profileSigningExpired {
    return Intl.message(
      'Expired',
      name: 'profileSigningExpired',
      desc: '',
      args: [],
    );
  }

  /// `{days}d {hours}h {minutes}m left`
  String profileSigningCountdown(Object days, Object hours, Object minutes) {
    return Intl.message(
      '${days}d ${hours}h ${minutes}m left',
      name: 'profileSigningCountdown',
      desc: '',
      args: [days, hours, minutes],
    );
  }

  /// `Until {date}`
  String profileSigningExpiresOn(Object date) {
    return Intl.message(
      'Until $date',
      name: 'profileSigningExpiresOn',
      desc: '',
      args: [date],
    );
  }

  /// `FortuneBoot is a multi-group, multi-book expense tracker.\n\n· Quickly add a record on the home page, or view details on the bills page.\n· Open "Mine" to manage categories, tags, accounts, members, and more.\n· If you run into problems, contact your admin or check the project docs.`
  String get profileHelpContent {
    return Intl.message(
      'FortuneBoot is a multi-group, multi-book expense tracker.\n\n· Quickly add a record on the home page, or view details on the bills page.\n· Open "Mine" to manage categories, tags, accounts, members, and more.\n· If you run into problems, contact your admin or check the project docs.',
      name: 'profileHelpContent',
      desc: '',
      args: [],
    );
  }

  /// `FortuneBoot is a collaborative expense tracker with multiple groups and books. The sections below explain the common features to get you started.`
  String get profileHelpIntro {
    return Intl.message(
      'FortuneBoot is a collaborative expense tracker with multiple groups and books. The sections below explain the common features to get you started.',
      name: 'profileHelpIntro',
      desc: '',
      args: [],
    );
  }

  /// `Quick entry`
  String get profileHelpQuickTitle {
    return Intl.message(
      'Quick entry',
      name: 'profileHelpQuickTitle',
      desc: '',
      args: [],
    );
  }

  /// `Tap the blue "+" button in the center of the bottom bar to add a record. Enter a title, then pick a category and amount. Switch between expense, income, transfer, advance and reimbursement at the top. You can split across multiple categories, add fees/discounts, and attach receipt photos.`
  String get profileHelpQuickBody {
    return Intl.message(
      'Tap the blue "+" button in the center of the bottom bar to add a record. Enter a title, then pick a category and amount. Switch between expense, income, transfer, advance and reimbursement at the top. You can split across multiple categories, add fees/discounts, and attach receipt photos.',
      name: 'profileHelpQuickBody',
      desc: '',
      args: [],
    );
  }

  /// `Bills & billing cycle`
  String get profileHelpBillsTitle {
    return Intl.message(
      'Bills & billing cycle',
      name: 'profileHelpBillsTitle',
      desc: '',
      args: [],
    );
  }

  /// `The bills page groups records by billing cycle. Use the arrows at the top to move between adjacent cycles; scrolling down loads older bills automatically. Set a custom cycle start day under "Mine → Month start day" (e.g. the 5th) to match your payday.`
  String get profileHelpBillsBody {
    return Intl.message(
      'The bills page groups records by billing cycle. Use the arrows at the top to move between adjacent cycles; scrolling down loads older bills automatically. Set a custom cycle start day under "Mine → Month start day" (e.g. the 5th) to match your payday.',
      name: 'profileHelpBillsBody',
      desc: '',
      args: [],
    );
  }

  /// `Groups & books`
  String get profileHelpBookTitle {
    return Intl.message(
      'Groups & books',
      name: 'profileHelpBookTitle',
      desc: '',
      args: [],
    );
  }

  /// `Groups isolate scenarios (personal, family, company), and each group can hold multiple books. Add, edit, set default or disable them under "Mine → Group / Book management". Switching the current book refreshes bills, stats and accounts.`
  String get profileHelpBookBody {
    return Intl.message(
      'Groups isolate scenarios (personal, family, company), and each group can hold multiple books. Add, edit, set default or disable them under "Mine → Group / Book management". Switching the current book refreshes bills, stats and accounts.',
      name: 'profileHelpBookBody',
      desc: '',
      args: [],
    );
  }

  /// `Base data management`
  String get profileHelpManageTitle {
    return Intl.message(
      'Base data management',
      name: 'profileHelpManageTitle',
      desc: '',
      args: [],
    );
  }

  /// `Categories, tags, payees, members and accounts are each managed separately. Categories and tags support tree hierarchies; accounts cover cash, credit card, asset and loan types and roll up net worth. Disabled or deleted items go to the recycle bin and can be restored.`
  String get profileHelpManageBody {
    return Intl.message(
      'Categories, tags, payees, members and accounts are each managed separately. Categories and tags support tree hierarchies; accounts cover cash, credit card, asset and loan types and roll up net worth. Disabled or deleted items go to the recycle bin and can be restored.',
      name: 'profileHelpManageBody',
      desc: '',
      args: [],
    );
  }

  /// `Recurring bills`
  String get profileHelpRecurringTitle {
    return Intl.message(
      'Recurring bills',
      name: 'profileHelpRecurringTitle',
      desc: '',
      args: [],
    );
  }

  /// `Create automatic rules under "Mine → Recurring". Use the visual frequency picker (daily/weekly/monthly/yearly) to generate a rule without writing cron; advanced users can switch to custom mode and edit the cron expression directly.`
  String get profileHelpRecurringBody {
    return Intl.message(
      'Create automatic rules under "Mine → Recurring". Use the visual frequency picker (daily/weekly/monthly/yearly) to generate a rule without writing cron; advanced users can switch to custom mode and edit the cron expression directly.',
      name: 'profileHelpRecurringBody',
      desc: '',
      args: [],
    );
  }

  /// `Privacy & display`
  String get profileHelpPrivacyTitle {
    return Intl.message(
      'Privacy & display',
      name: 'profileHelpPrivacyTitle',
      desc: '',
      args: [],
    );
  }

  /// `Turn on "Hide amounts" to mask figures on the home and bills pages for public viewing. You can also customize income/expense colors and switch between light and dark themes.`
  String get profileHelpPrivacyBody {
    return Intl.message(
      'Turn on "Hide amounts" to mask figures on the home and bills pages for public viewing. You can also customize income/expense colors and switch between light and dark themes.',
      name: 'profileHelpPrivacyBody',
      desc: '',
      args: [],
    );
  }

  /// `Getting help`
  String get profileHelpContactTitle {
    return Intl.message(
      'Getting help',
      name: 'profileHelpContactTitle',
      desc: '',
      args: [],
    );
  }

  /// `If you hit data issues or have questions, try pull-to-refresh or re-login first. If that doesn't help, contact your group admin or visit the project home page for docs and feedback.`
  String get profileHelpContactBody {
    return Intl.message(
      'If you hit data issues or have questions, try pull-to-refresh or re-login first. If that doesn\'t help, contact your group admin or visit the project home page for docs and feedback.',
      name: 'profileHelpContactBody',
      desc: '',
      args: [],
    );
  }

  /// `Thanks for your support!\nIf you'd like to sponsor development, find donation options on the project home page.`
  String get profileDonateContent {
    return Intl.message(
      'Thanks for your support!\nIf you\'d like to sponsor development, find donation options on the project home page.',
      name: 'profileDonateContent',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to log out?`
  String get profileLogoutConfirm {
    return Intl.message(
      'Are you sure you want to log out?',
      name: 'profileLogoutConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Belongings`
  String get goodsTitle {
    return Intl.message('Belongings', name: 'goodsTitle', desc: '', args: []);
  }

  /// `Please select a book first`
  String get goodsSelectBookFirst {
    return Intl.message(
      'Please select a book first',
      name: 'goodsSelectBookFirst',
      desc: '',
      args: [],
    );
  }

  /// `Add Item`
  String get goodsAddTitle {
    return Intl.message('Add Item', name: 'goodsAddTitle', desc: '', args: []);
  }

  /// `Edit Item`
  String get goodsEditTitle {
    return Intl.message(
      'Edit Item',
      name: 'goodsEditTitle',
      desc: '',
      args: [],
    );
  }

  /// `Item Details`
  String get goodsDetailTitle {
    return Intl.message(
      'Item Details',
      name: 'goodsDetailTitle',
      desc: '',
      args: [],
    );
  }

  /// `View Details`
  String get goodsMenuDetail {
    return Intl.message(
      'View Details',
      name: 'goodsMenuDetail',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get goodsMenuEdit {
    return Intl.message('Edit', name: 'goodsMenuEdit', desc: '', args: []);
  }

  /// `Delete`
  String get goodsMenuDelete {
    return Intl.message('Delete', name: 'goodsMenuDelete', desc: '', args: []);
  }

  /// `Delete Item`
  String get goodsRemoveTitle {
    return Intl.message(
      'Delete Item',
      name: 'goodsRemoveTitle',
      desc: '',
      args: [],
    );
  }

  /// `this item`
  String get goodsThisItem {
    return Intl.message('this item', name: 'goodsThisItem', desc: '', args: []);
  }

  /// `Delete "{name}"? This action cannot be undone.`
  String goodsRemoveConfirm(Object name) {
    return Intl.message(
      'Delete "$name"? This action cannot be undone.',
      name: 'goodsRemoveConfirm',
      desc: '',
      args: [name],
    );
  }

  /// `No items yet. Tap + in the top right to add one.`
  String get goodsEmptyHint {
    return Intl.message(
      'No items yet. Tap + in the top right to add one.',
      name: 'goodsEmptyHint',
      desc: '',
      args: [],
    );
  }

  /// `Total Cost`
  String get goodsStatAllCost {
    return Intl.message(
      'Total Cost',
      name: 'goodsStatAllCost',
      desc: '',
      args: [],
    );
  }

  /// `Active Cost`
  String get goodsStatActiveCost {
    return Intl.message(
      'Active Cost',
      name: 'goodsStatActiveCost',
      desc: '',
      args: [],
    );
  }

  /// `Daily Cost`
  String get goodsStatDailyCost {
    return Intl.message(
      'Daily Cost',
      name: 'goodsStatDailyCost',
      desc: '',
      args: [],
    );
  }

  /// `Unnamed`
  String get goodsUnnamed {
    return Intl.message('Unnamed', name: 'goodsUnnamed', desc: '', args: []);
  }

  /// `Held {days} days`
  String goodsHoldingDays(Object days) {
    return Intl.message(
      'Held $days days',
      name: 'goodsHoldingDays',
      desc: '',
      args: [days],
    );
  }

  /// `Daily avg {amount}`
  String goodsDailyAvg(Object amount) {
    return Intl.message(
      'Daily avg $amount',
      name: 'goodsDailyAvg',
      desc: '',
      args: [amount],
    );
  }

  /// `Purchase Date`
  String get goodsFieldPurchaseDate {
    return Intl.message(
      'Purchase Date',
      name: 'goodsFieldPurchaseDate',
      desc: '',
      args: [],
    );
  }

  /// `Holding Days`
  String get goodsFieldHoldingTime {
    return Intl.message(
      'Holding Days',
      name: 'goodsFieldHoldingTime',
      desc: '',
      args: [],
    );
  }

  /// `{days} days`
  String goodsDaysValue(Object days) {
    return Intl.message(
      '$days days',
      name: 'goodsDaysValue',
      desc: '',
      args: [days],
    );
  }

  /// `Category`
  String get goodsFieldCategory {
    return Intl.message(
      'Category',
      name: 'goodsFieldCategory',
      desc: '',
      args: [],
    );
  }

  /// `Tag`
  String get goodsFieldTag {
    return Intl.message('Tag', name: 'goodsFieldTag', desc: '', args: []);
  }

  /// `Warranty Date`
  String get goodsFieldWarrantyDate {
    return Intl.message(
      'Warranty Date',
      name: 'goodsFieldWarrantyDate',
      desc: '',
      args: [],
    );
  }

  /// `Warranty Status`
  String get goodsFieldWarrantyStatus {
    return Intl.message(
      'Warranty Status',
      name: 'goodsFieldWarrantyStatus',
      desc: '',
      args: [],
    );
  }

  /// `Usage Count`
  String get goodsFieldUsageCount {
    return Intl.message(
      'Usage Count',
      name: 'goodsFieldUsageCount',
      desc: '',
      args: [],
    );
  }

  /// `Status`
  String get goodsFieldStatus {
    return Intl.message('Status', name: 'goodsFieldStatus', desc: '', args: []);
  }

  /// `Retired Date`
  String get goodsFieldRetiredDate {
    return Intl.message(
      'Retired Date',
      name: 'goodsFieldRetiredDate',
      desc: '',
      args: [],
    );
  }

  /// `Sold Price`
  String get goodsFieldSoldPrice {
    return Intl.message(
      'Sold Price',
      name: 'goodsFieldSoldPrice',
      desc: '',
      args: [],
    );
  }

  /// `Sale P/L`
  String get goodsFieldProfit {
    return Intl.message(
      'Sale P/L',
      name: 'goodsFieldProfit',
      desc: '',
      args: [],
    );
  }

  /// `Remark`
  String get goodsFieldRemark {
    return Intl.message('Remark', name: 'goodsFieldRemark', desc: '', args: []);
  }

  /// `Please enter the item name`
  String get goodsErrNameRequired {
    return Intl.message(
      'Please enter the item name',
      name: 'goodsErrNameRequired',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid price`
  String get goodsErrInvalidPrice {
    return Intl.message(
      'Please enter a valid price',
      name: 'goodsErrInvalidPrice',
      desc: '',
      args: [],
    );
  }

  /// `Please select the item status`
  String get goodsErrStatusRequired {
    return Intl.message(
      'Please select the item status',
      name: 'goodsErrStatusRequired',
      desc: '',
      args: [],
    );
  }

  /// `Please select a category`
  String get goodsErrCategoryRequired {
    return Intl.message(
      'Please select a category',
      name: 'goodsErrCategoryRequired',
      desc: '',
      args: [],
    );
  }

  /// `Select Date`
  String get goodsPickDate {
    return Intl.message(
      'Select Date',
      name: 'goodsPickDate',
      desc: '',
      args: [],
    );
  }

  /// `Basic Info`
  String get goodsSectionBasic {
    return Intl.message(
      'Basic Info',
      name: 'goodsSectionBasic',
      desc: '',
      args: [],
    );
  }

  /// `Item Name`
  String get goodsLabelName {
    return Intl.message(
      'Item Name',
      name: 'goodsLabelName',
      desc: '',
      args: [],
    );
  }

  /// `e.g. iPhone 15`
  String get goodsHintName {
    return Intl.message(
      'e.g. iPhone 15',
      name: 'goodsHintName',
      desc: '',
      args: [],
    );
  }

  /// `Purchase Price`
  String get goodsLabelPrice {
    return Intl.message(
      'Purchase Price',
      name: 'goodsLabelPrice',
      desc: '',
      args: [],
    );
  }

  /// `Category & Tag`
  String get goodsSectionCategoryTag {
    return Intl.message(
      'Category & Tag',
      name: 'goodsSectionCategoryTag',
      desc: '',
      args: [],
    );
  }

  /// `Category`
  String get goodsLabelCategoryOptional {
    return Intl.message(
      'Category',
      name: 'goodsLabelCategoryOptional',
      desc: '',
      args: [],
    );
  }

  /// `No category`
  String get goodsEmptyCategory {
    return Intl.message(
      'No category',
      name: 'goodsEmptyCategory',
      desc: '',
      args: [],
    );
  }

  /// `Tag (optional)`
  String get goodsLabelTagOptional {
    return Intl.message(
      'Tag (optional)',
      name: 'goodsLabelTagOptional',
      desc: '',
      args: [],
    );
  }

  /// `No tag`
  String get goodsEmptyTag {
    return Intl.message('No tag', name: 'goodsEmptyTag', desc: '', args: []);
  }

  /// `No categories yet. Create one in Category Management first.`
  String get goodsNoCategoryOptions {
    return Intl.message(
      'No categories yet. Create one in Category Management first.',
      name: 'goodsNoCategoryOptions',
      desc: '',
      args: [],
    );
  }

  /// `Warranty & Status`
  String get goodsSectionWarrantyStatus {
    return Intl.message(
      'Warranty & Status',
      name: 'goodsSectionWarrantyStatus',
      desc: '',
      args: [],
    );
  }

  /// `Warranty Date (optional)`
  String get goodsLabelWarrantyOptional {
    return Intl.message(
      'Warranty Date (optional)',
      name: 'goodsLabelWarrantyOptional',
      desc: '',
      args: [],
    );
  }

  /// `Not set`
  String get goodsNotSet {
    return Intl.message('Not set', name: 'goodsNotSet', desc: '', args: []);
  }

  /// `Unknown`
  String get goodsUnknown {
    return Intl.message('Unknown', name: 'goodsUnknown', desc: '', args: []);
  }

  /// `Current status "{status}" is not recognized. Reselect to change it, or leave it unselected to keep the original.`
  String goodsStatusUnrecognized(Object status) {
    return Intl.message(
      'Current status "$status" is not recognized. Reselect to change it, or leave it unselected to keep the original.',
      name: 'goodsStatusUnrecognized',
      desc: '',
      args: [status],
    );
  }

  /// `Use by count`
  String get goodsUseByTimes {
    return Intl.message(
      'Use by count',
      name: 'goodsUseByTimes',
      desc: '',
      args: [],
    );
  }

  /// `e.g. 120`
  String get goodsHintUsageNum {
    return Intl.message(
      'e.g. 120',
      name: 'goodsHintUsageNum',
      desc: '',
      args: [],
    );
  }

  /// `Disposal`
  String get goodsSectionDisposal {
    return Intl.message(
      'Disposal',
      name: 'goodsSectionDisposal',
      desc: '',
      args: [],
    );
  }

  /// `Remark & Attachments`
  String get goodsSectionRemarkAttach {
    return Intl.message(
      'Remark & Attachments',
      name: 'goodsSectionRemarkAttach',
      desc: '',
      args: [],
    );
  }

  /// `Remark (optional)`
  String get goodsLabelRemarkOptional {
    return Intl.message(
      'Remark (optional)',
      name: 'goodsLabelRemarkOptional',
      desc: '',
      args: [],
    );
  }

  /// `Save Changes`
  String get goodsSaveChanges {
    return Intl.message(
      'Save Changes',
      name: 'goodsSaveChanges',
      desc: '',
      args: [],
    );
  }

  /// `None`
  String get goodsNone {
    return Intl.message('None', name: 'goodsNone', desc: '', args: []);
  }

  /// `Attachments (optional)`
  String get goodsLabelAttachOptional {
    return Intl.message(
      'Attachments (optional)',
      name: 'goodsLabelAttachOptional',
      desc: '',
      args: [],
    );
  }

  /// `{label} (no options)`
  String goodsNoOptions(Object label) {
    return Intl.message(
      '$label (no options)',
      name: 'goodsNoOptions',
      desc: '',
      args: [label],
    );
  }

  /// `Record`
  String get billGroupClassic {
    return Intl.message('Record', name: 'billGroupClassic', desc: '', args: []);
  }

  /// `Expense`
  String get billTypeExpense {
    return Intl.message('Expense', name: 'billTypeExpense', desc: '', args: []);
  }

  /// `Income`
  String get billTypeIncome {
    return Intl.message('Income', name: 'billTypeIncome', desc: '', args: []);
  }

  /// `Transfer`
  String get billTypeTransfer {
    return Intl.message(
      'Transfer',
      name: 'billTypeTransfer',
      desc: '',
      args: [],
    );
  }

  /// `Adjustment`
  String get billTypeAdjust {
    return Intl.message(
      'Adjustment',
      name: 'billTypeAdjust',
      desc: '',
      args: [],
    );
  }

  /// `Advance`
  String get billTypeAdvance {
    return Intl.message('Advance', name: 'billTypeAdvance', desc: '', args: []);
  }

  /// `Reimburse`
  String get billTypeReimburse {
    return Intl.message(
      'Reimburse',
      name: 'billTypeReimburse',
      desc: '',
      args: [],
    );
  }

  /// `Loan out`
  String get billTypeLoanOut {
    return Intl.message(
      'Loan out',
      name: 'billTypeLoanOut',
      desc: '',
      args: [],
    );
  }

  /// `Recover principal`
  String get billTypeLoanRecover {
    return Intl.message(
      'Recover principal',
      name: 'billTypeLoanRecover',
      desc: '',
      args: [],
    );
  }

  /// `Loan in`
  String get billTypeLoanIn {
    return Intl.message('Loan in', name: 'billTypeLoanIn', desc: '', args: []);
  }

  /// `Repay loan`
  String get billTypeLoanRepay {
    return Intl.message(
      'Repay loan',
      name: 'billTypeLoanRepay',
      desc: '',
      args: [],
    );
  }

  /// `Bill`
  String get billTypeFallback {
    return Intl.message('Bill', name: 'billTypeFallback', desc: '', args: []);
  }

  /// `Please select`
  String get commonPleaseSelect {
    return Intl.message(
      'Please select',
      name: 'commonPleaseSelect',
      desc: '',
      args: [],
    );
  }

  /// `Transfer amount cannot be 0`
  String get billEditorValidateTransferAmount {
    return Intl.message(
      'Transfer amount cannot be 0',
      name: 'billEditorValidateTransferAmount',
      desc: '',
      args: [],
    );
  }

  /// `Select source account`
  String get billEditorValidateTransferFrom {
    return Intl.message(
      'Select source account',
      name: 'billEditorValidateTransferFrom',
      desc: '',
      args: [],
    );
  }

  /// `Select destination account`
  String get billEditorValidateTransferTo {
    return Intl.message(
      'Select destination account',
      name: 'billEditorValidateTransferTo',
      desc: '',
      args: [],
    );
  }

  /// `Source and destination must differ`
  String get billEditorValidateTransferSame {
    return Intl.message(
      'Source and destination must differ',
      name: 'billEditorValidateTransferSame',
      desc: '',
      args: [],
    );
  }

  /// `Enter an amount`
  String get billEditorValidateAmount {
    return Intl.message(
      'Enter an amount',
      name: 'billEditorValidateAmount',
      desc: '',
      args: [],
    );
  }

  /// `Enter the write-off reason`
  String get billEditorValidateWriteOffReason {
    return Intl.message(
      'Enter the write-off reason',
      name: 'billEditorValidateWriteOffReason',
      desc: '',
      args: [],
    );
  }

  /// `Non-cash adjustment`
  String get billEditorWriteOffAccount {
    return Intl.message(
      'Non-cash adjustment',
      name: 'billEditorWriteOffAccount',
      desc: '',
      args: [],
    );
  }

  /// `Interest received`
  String get orderActionInterestIn {
    return Intl.message(
      'Interest received',
      name: 'orderActionInterestIn',
      desc: '',
      args: [],
    );
  }

  /// `Interest paid`
  String get orderActionInterestOut {
    return Intl.message(
      'Interest paid',
      name: 'orderActionInterestOut',
      desc: '',
      args: [],
    );
  }

  /// `Fee paid`
  String get orderActionFee {
    return Intl.message('Fee paid', name: 'orderActionFee', desc: '', args: []);
  }

  /// `Confirm uncollectible`
  String get orderActionWriteOffReceivable {
    return Intl.message(
      'Confirm uncollectible',
      name: 'orderActionWriteOffReceivable',
      desc: '',
      args: [],
    );
  }

  /// `Loan forgiven`
  String get orderActionWriteOffPayable {
    return Intl.message(
      'Loan forgiven',
      name: 'orderActionWriteOffPayable',
      desc: '',
      args: [],
    );
  }

  /// `Pay personally`
  String get orderActionWriteOffReimbursement {
    return Intl.message(
      'Pay personally',
      name: 'orderActionWriteOffReimbursement',
      desc: '',
      args: [],
    );
  }

  /// `Add a category`
  String get billEditorValidateCategoryRequired {
    return Intl.message(
      'Add a category',
      name: 'billEditorValidateCategoryRequired',
      desc: '',
      args: [],
    );
  }

  /// `Select a category`
  String get billEditorValidateCategorySelect {
    return Intl.message(
      'Select a category',
      name: 'billEditorValidateCategorySelect',
      desc: '',
      args: [],
    );
  }

  /// `Category amount cannot be 0`
  String get billEditorValidateCategoryAmount {
    return Intl.message(
      'Category amount cannot be 0',
      name: 'billEditorValidateCategoryAmount',
      desc: '',
      args: [],
    );
  }

  /// `Select an account`
  String get billEditorValidateAccount {
    return Intl.message(
      'Select an account',
      name: 'billEditorValidateAccount',
      desc: '',
      args: [],
    );
  }

  /// `Select a related reimbursement order`
  String get billEditorValidateOrder {
    return Intl.message(
      'Select a related reimbursement order',
      name: 'billEditorValidateOrder',
      desc: '',
      args: [],
    );
  }

  /// `Enter a title`
  String get billEditorValidateTitle {
    return Intl.message(
      'Enter a title',
      name: 'billEditorValidateTitle',
      desc: '',
      args: [],
    );
  }

  /// `Select a category for every extra charge`
  String get billEditorValidateExtraCategory {
    return Intl.message(
      'Select a category for every extra charge',
      name: 'billEditorValidateExtraCategory',
      desc: '',
      args: [],
    );
  }

  /// `An extra charge category is not in the current breakdown`
  String get billEditorValidateExtraCategoryInSplit {
    return Intl.message(
      'An extra charge category is not in the current breakdown',
      name: 'billEditorValidateExtraCategoryInSplit',
      desc: '',
      args: [],
    );
  }

  /// `An extra charge account side is invalid`
  String get billEditorValidateTransferExtraAccountSide {
    return Intl.message(
      'An extra charge account side is invalid',
      name: 'billEditorValidateTransferExtraAccountSide',
      desc: '',
      args: [],
    );
  }

  /// `You do not have permission to set the default group`
  String get booksNoPermissionSetDefaultGroup {
    return Intl.message(
      'You do not have permission to set the default group',
      name: 'booksNoPermissionSetDefaultGroup',
      desc: '',
      args: [],
    );
  }

  /// `Enable this group first`
  String get booksEnableGroupFirst {
    return Intl.message(
      'Enable this group first',
      name: 'booksEnableGroupFirst',
      desc: '',
      args: [],
    );
  }

  /// `This group is already the default`
  String get booksAlreadyDefaultGroup {
    return Intl.message(
      'This group is already the default',
      name: 'booksAlreadyDefaultGroup',
      desc: '',
      args: [],
    );
  }

  /// `You do not have permission to enable or disable groups`
  String get booksNoPermissionToggleGroup {
    return Intl.message(
      'You do not have permission to enable or disable groups',
      name: 'booksNoPermissionToggleGroup',
      desc: '',
      args: [],
    );
  }

  /// `This group is already enabled`
  String get booksGroupAlreadyEnabled {
    return Intl.message(
      'This group is already enabled',
      name: 'booksGroupAlreadyEnabled',
      desc: '',
      args: [],
    );
  }

  /// `This group is already disabled`
  String get booksGroupAlreadyDisabled {
    return Intl.message(
      'This group is already disabled',
      name: 'booksGroupAlreadyDisabled',
      desc: '',
      args: [],
    );
  }

  /// `Keep at least one enabled group`
  String get booksKeepOneEnabledGroup {
    return Intl.message(
      'Keep at least one enabled group',
      name: 'booksKeepOneEnabledGroup',
      desc: '',
      args: [],
    );
  }

  /// `Set another group as default first`
  String get booksSetOtherDefaultGroupFirst {
    return Intl.message(
      'Set another group as default first',
      name: 'booksSetOtherDefaultGroupFirst',
      desc: '',
      args: [],
    );
  }

  /// `You do not have permission to delete groups`
  String get booksNoPermissionDeleteGroup {
    return Intl.message(
      'You do not have permission to delete groups',
      name: 'booksNoPermissionDeleteGroup',
      desc: '',
      args: [],
    );
  }

  /// `You do not have permission to set the default book`
  String get booksNoPermissionSetDefaultBook {
    return Intl.message(
      'You do not have permission to set the default book',
      name: 'booksNoPermissionSetDefaultBook',
      desc: '',
      args: [],
    );
  }

  /// `Restore this book first`
  String get booksRestoreBookFirst {
    return Intl.message(
      'Restore this book first',
      name: 'booksRestoreBookFirst',
      desc: '',
      args: [],
    );
  }

  /// `Enable this book before setting it as default`
  String get booksEnableBookBeforeDefault {
    return Intl.message(
      'Enable this book before setting it as default',
      name: 'booksEnableBookBeforeDefault',
      desc: '',
      args: [],
    );
  }

  /// `This book is already the default`
  String get booksAlreadyDefaultBook {
    return Intl.message(
      'This book is already the default',
      name: 'booksAlreadyDefaultBook',
      desc: '',
      args: [],
    );
  }

  /// `You do not have permission to enable or disable books`
  String get booksNoPermissionToggleBook {
    return Intl.message(
      'You do not have permission to enable or disable books',
      name: 'booksNoPermissionToggleBook',
      desc: '',
      args: [],
    );
  }

  /// `This book is already enabled`
  String get booksBookAlreadyEnabled {
    return Intl.message(
      'This book is already enabled',
      name: 'booksBookAlreadyEnabled',
      desc: '',
      args: [],
    );
  }

  /// `This book is already disabled`
  String get booksBookAlreadyDisabled {
    return Intl.message(
      'This book is already disabled',
      name: 'booksBookAlreadyDisabled',
      desc: '',
      args: [],
    );
  }

  /// `Set another book as default first`
  String get booksSetOtherDefaultBookFirst {
    return Intl.message(
      'Set another book as default first',
      name: 'booksSetOtherDefaultBookFirst',
      desc: '',
      args: [],
    );
  }

  /// `This is the only available book in the group. Create or enable another book first.`
  String get booksOnlyAvailableBook {
    return Intl.message(
      'This is the only available book in the group. Create or enable another book first.',
      name: 'booksOnlyAvailableBook',
      desc: '',
      args: [],
    );
  }

  /// `You do not have permission to move books`
  String get booksNoPermissionMoveBook {
    return Intl.message(
      'You do not have permission to move books',
      name: 'booksNoPermissionMoveBook',
      desc: '',
      args: [],
    );
  }

  /// `You do not have permission to restore books`
  String get booksNoPermissionRestoreBook {
    return Intl.message(
      'You do not have permission to restore books',
      name: 'booksNoPermissionRestoreBook',
      desc: '',
      args: [],
    );
  }

  /// `You do not have permission to delete books`
  String get booksNoPermissionDeleteBook {
    return Intl.message(
      'You do not have permission to delete books',
      name: 'booksNoPermissionDeleteBook',
      desc: '',
      args: [],
    );
  }

  /// `Default accounts are incomplete. Tap to complete.`
  String get booksDefaultAccountMissing {
    return Intl.message(
      'Default accounts are incomplete. Tap to complete.',
      name: 'booksDefaultAccountMissing',
      desc: '',
      args: [],
    );
  }

  /// `Default book`
  String get booksDefaultBookTag {
    return Intl.message(
      'Default book',
      name: 'booksDefaultBookTag',
      desc: '',
      args: [],
    );
  }

  /// `Default expense: {name}`
  String booksDefaultExpenseAccountValue(Object name) {
    return Intl.message(
      'Default expense: $name',
      name: 'booksDefaultExpenseAccountValue',
      desc: '',
      args: [name],
    );
  }

  /// `Asset stats`
  String get profileStatsAssets {
    return Intl.message(
      'Asset stats',
      name: 'profileStatsAssets',
      desc: '',
      args: [],
    );
  }

  /// `Loans & finance`
  String get profileStatsLoans {
    return Intl.message(
      'Loans & finance',
      name: 'profileStatsLoans',
      desc: '',
      args: [],
    );
  }

  /// `Stats policy`
  String get profileStatsPolicy {
    return Intl.message(
      'Stats policy',
      name: 'profileStatsPolicy',
      desc: '',
      args: [],
    );
  }

  /// `More reports`
  String get statsMoreReports {
    return Intl.message(
      'More reports',
      name: 'statsMoreReports',
      desc: '',
      args: [],
    );
  }

  /// `Assets, liabilities, net worth trend and credit cards`
  String get statsAssetsEntrySubtitle {
    return Intl.message(
      'Assets, liabilities, net worth trend and credit cards',
      name: 'statsAssetsEntrySubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Receivables, payables, finance P/L and pending bills`
  String get statsLoansEntrySubtitle {
    return Intl.message(
      'Receivables, payables, finance P/L and pending bills',
      name: 'statsLoansEntrySubtitle',
      desc: '',
      args: [],
    );
  }

  /// `See which bills are included in charts`
  String get statsPolicyEntrySubtitle {
    return Intl.message(
      'See which bills are included in charts',
      name: 'statsPolicyEntrySubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Asset stats`
  String get statsAssetsTitle {
    return Intl.message(
      'Asset stats',
      name: 'statsAssetsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Loans & finance`
  String get statsLoansTitle {
    return Intl.message(
      'Loans & finance',
      name: 'statsLoansTitle',
      desc: '',
      args: [],
    );
  }

  /// `Stats policy`
  String get statsPolicyTitle {
    return Intl.message(
      'Stats policy',
      name: 'statsPolicyTitle',
      desc: '',
      args: [],
    );
  }

  /// `Select a group first`
  String get statsSelectGroupFirst {
    return Intl.message(
      'Select a group first',
      name: 'statsSelectGroupFirst',
      desc: '',
      args: [],
    );
  }

  /// `Assets & liabilities mix`
  String get statsAssetsComposition {
    return Intl.message(
      'Assets & liabilities mix',
      name: 'statsAssetsComposition',
      desc: '',
      args: [],
    );
  }

  /// `Net worth trend`
  String get statsNetAssetsTrend {
    return Intl.message(
      'Net worth trend',
      name: 'statsNetAssetsTrend',
      desc: '',
      args: [],
    );
  }

  /// `By account type`
  String get statsAssetsByAccountType {
    return Intl.message(
      'By account type',
      name: 'statsAssetsByAccountType',
      desc: '',
      args: [],
    );
  }

  /// `Credit cards`
  String get statsCreditCardOverview {
    return Intl.message(
      'Credit cards',
      name: 'statsCreditCardOverview',
      desc: '',
      args: [],
    );
  }

  /// `Billing {billing} · Repayment {repayment}`
  String statsCreditCardDates(Object billing, Object repayment) {
    return Intl.message(
      'Billing $billing · Repayment $repayment',
      name: 'statsCreditCardDates',
      desc: '',
      args: [billing, repayment],
    );
  }

  /// `Loan overview`
  String get statsLoanOverview {
    return Intl.message(
      'Loan overview',
      name: 'statsLoanOverview',
      desc: '',
      args: [],
    );
  }

  /// `Receivable`
  String get statsLoanReceivable {
    return Intl.message(
      'Receivable',
      name: 'statsLoanReceivable',
      desc: '',
      args: [],
    );
  }

  /// `Payable`
  String get statsLoanPayable {
    return Intl.message(
      'Payable',
      name: 'statsLoanPayable',
      desc: '',
      args: [],
    );
  }

  /// `Overdue receivable`
  String get statsOverdueReceivable {
    return Intl.message(
      'Overdue receivable',
      name: 'statsOverdueReceivable',
      desc: '',
      args: [],
    );
  }

  /// `Overdue payable`
  String get statsOverduePayable {
    return Intl.message(
      'Overdue payable',
      name: 'statsOverduePayable',
      desc: '',
      args: [],
    );
  }

  /// `Pending confirmation`
  String get statsPendingConfirm {
    return Intl.message(
      'Pending confirmation',
      name: 'statsPendingConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Finance profit`
  String get statsFinanceProfit {
    return Intl.message(
      'Finance profit',
      name: 'statsFinanceProfit',
      desc: '',
      args: [],
    );
  }

  /// `Profit`
  String get statsProfit {
    return Intl.message('Profit', name: 'statsProfit', desc: '', args: []);
  }

  /// `Loss`
  String get statsLoss {
    return Intl.message('Loss', name: 'statsLoss', desc: '', args: []);
  }

  /// `Net profit`
  String get statsNetProfit {
    return Intl.message(
      'Net profit',
      name: 'statsNetProfit',
      desc: '',
      args: [],
    );
  }

  /// `{count} bills`
  String statsBillCount(Object count) {
    return Intl.message(
      '$count bills',
      name: 'statsBillCount',
      desc: '',
      args: [count],
    );
  }

  /// `Statistics scope`
  String get statsPolicyScope {
    return Intl.message(
      'Statistics scope',
      name: 'statsPolicyScope',
      desc: '',
      args: [],
    );
  }

  /// `Included by default`
  String get statsPolicyDefaultInclude {
    return Intl.message(
      'Included by default',
      name: 'statsPolicyDefaultInclude',
      desc: '',
      args: [],
    );
  }

  /// `Excluded by default`
  String get statsPolicyDefaultExclude {
    return Intl.message(
      'Excluded by default',
      name: 'statsPolicyDefaultExclude',
      desc: '',
      args: [],
    );
  }

  /// `Confirmed bills with “include in statistics” enabled are counted in income, expense, trends, category reports, and asset charts. Bills with statistics disabled remain in details only and do not affect charts.`
  String get statsPolicyDefaultDesc {
    return Intl.message(
      'Confirmed bills with “include in statistics” enabled are counted in income, expense, trends, category reports, and asset charts. Bills with statistics disabled remain in details only and do not affect charts.',
      name: 'statsPolicyDefaultDesc',
      desc: '',
      args: [],
    );
  }

  /// `The backend policy endpoint is not available yet, so this page shows the frontend convention.`
  String get statsPolicyEndpointFallback {
    return Intl.message(
      'The backend policy endpoint is not available yet, so this page shows the frontend convention.',
      name: 'statsPolicyEndpointFallback',
      desc: '',
      args: [],
    );
  }

  /// `Bill type policy`
  String get statsPolicyBillTypes {
    return Intl.message(
      'Bill type policy',
      name: 'statsPolicyBillTypes',
      desc: '',
      args: [],
    );
  }

  /// `Included`
  String get statsPolicyIncluded {
    return Intl.message(
      'Included',
      name: 'statsPolicyIncluded',
      desc: '',
      args: [],
    );
  }

  /// `Excluded`
  String get statsPolicyExcluded {
    return Intl.message(
      'Excluded',
      name: 'statsPolicyExcluded',
      desc: '',
      args: [],
    );
  }

  /// `Income & expense calendar`
  String get statsIncomeExpenseCalendar {
    return Intl.message(
      'Income & expense calendar',
      name: 'statsIncomeExpenseCalendar',
      desc: '',
      args: [],
    );
  }

  /// `Month`
  String get statsCalendarMonth {
    return Intl.message(
      'Month',
      name: 'statsCalendarMonth',
      desc: '',
      args: [],
    );
  }

  /// `Year`
  String get statsCalendarYear {
    return Intl.message('Year', name: 'statsCalendarYear', desc: '', args: []);
  }

  /// `History`
  String get statsCalendarHistory {
    return Intl.message(
      'History',
      name: 'statsCalendarHistory',
      desc: '',
      args: [],
    );
  }

  /// `Income`
  String get statsCalendarIncome {
    return Intl.message(
      'Income',
      name: 'statsCalendarIncome',
      desc: '',
      args: [],
    );
  }

  /// `Expense`
  String get statsCalendarExpense {
    return Intl.message(
      'Expense',
      name: 'statsCalendarExpense',
      desc: '',
      args: [],
    );
  }

  /// `Previous`
  String get statsCalendarPrevious {
    return Intl.message(
      'Previous',
      name: 'statsCalendarPrevious',
      desc: '',
      args: [],
    );
  }

  /// `Next`
  String get statsCalendarNext {
    return Intl.message('Next', name: 'statsCalendarNext', desc: '', args: []);
  }

  /// `{count} total`
  String statsCalendarTotalCount(Object count) {
    return Intl.message(
      '$count total',
      name: 'statsCalendarTotalCount',
      desc: '',
      args: [count],
    );
  }

  /// `{count} income`
  String statsCalendarIncomeCount(Object count) {
    return Intl.message(
      '$count income',
      name: 'statsCalendarIncomeCount',
      desc: '',
      args: [count],
    );
  }

  /// `{count} expense`
  String statsCalendarExpenseCount(Object count) {
    return Intl.message(
      '$count expense',
      name: 'statsCalendarExpenseCount',
      desc: '',
      args: [count],
    );
  }

  /// `{date} income & expense`
  String statsCalendarDateSummary(Object date) {
    return Intl.message(
      '$date income & expense',
      name: 'statsCalendarDateSummary',
      desc: '',
      args: [date],
    );
  }

  /// `FortuneBoot`
  String get appTitle {
    return Intl.message('FortuneBoot', name: 'appTitle', desc: '', args: []);
  }

  /// `Select date`
  String get fxDatePickerDateTitle {
    return Intl.message(
      'Select date',
      name: 'fxDatePickerDateTitle',
      desc: '',
      args: [],
    );
  }

  /// `Select date and time`
  String get fxDatePickerDateTimeTitle {
    return Intl.message(
      'Select date and time',
      name: 'fxDatePickerDateTimeTitle',
      desc: '',
      args: [],
    );
  }

  /// `Today`
  String get fxDatePickerToday {
    return Intl.message('Today', name: 'fxDatePickerToday', desc: '', args: []);
  }

  /// `Yesterday`
  String get fxDatePickerYesterday {
    return Intl.message(
      'Yesterday',
      name: 'fxDatePickerYesterday',
      desc: '',
      args: [],
    );
  }

  /// `Start of month`
  String get fxDatePickerStartOfMonth {
    return Intl.message(
      'Start of month',
      name: 'fxDatePickerStartOfMonth',
      desc: '',
      args: [],
    );
  }

  /// `Done`
  String get fxDatePickerDone {
    return Intl.message('Done', name: 'fxDatePickerDone', desc: '', args: []);
  }

  /// `Previous year`
  String get fxDatePickerPreviousYear {
    return Intl.message(
      'Previous year',
      name: 'fxDatePickerPreviousYear',
      desc: '',
      args: [],
    );
  }

  /// `Next year`
  String get fxDatePickerNextYear {
    return Intl.message(
      'Next year',
      name: 'fxDatePickerNextYear',
      desc: '',
      args: [],
    );
  }

  /// `Select`
  String get fxTreePickerTitle {
    return Intl.message(
      'Select',
      name: 'fxTreePickerTitle',
      desc: '',
      args: [],
    );
  }

  /// `Clear`
  String get fxTreePickerClear {
    return Intl.message('Clear', name: 'fxTreePickerClear', desc: '', args: []);
  }

  /// `Done`
  String get fxTreePickerDone {
    return Intl.message('Done', name: 'fxTreePickerDone', desc: '', args: []);
  }

  /// `Search`
  String get fxTreePickerSearch {
    return Intl.message(
      'Search',
      name: 'fxTreePickerSearch',
      desc: '',
      args: [],
    );
  }

  /// `No matches`
  String get fxTreePickerNoMatches {
    return Intl.message(
      'No matches',
      name: 'fxTreePickerNoMatches',
      desc: '',
      args: [],
    );
  }

  /// `Confirm ({count})`
  String fxTreePickerConfirm(Object count) {
    return Intl.message(
      'Confirm ($count)',
      name: 'fxTreePickerConfirm',
      desc: '',
      args: [count],
    );
  }

  /// `Expand {label}`
  String fxTreePickerExpand(Object label) {
    return Intl.message(
      'Expand $label',
      name: 'fxTreePickerExpand',
      desc: '',
      args: [label],
    );
  }

  /// `Collapse {label}`
  String fxTreePickerCollapse(Object label) {
    return Intl.message(
      'Collapse $label',
      name: 'fxTreePickerCollapse',
      desc: '',
      args: [label],
    );
  }

  /// `Open in Bills`
  String get statsCalendarViewBills {
    return Intl.message(
      'Open in Bills',
      name: 'statsCalendarViewBills',
      desc: '',
      args: [],
    );
  }

  /// `Bills this day`
  String get statsCalendarDayBills {
    return Intl.message(
      'Bills this day',
      name: 'statsCalendarDayBills',
      desc: '',
      args: [],
    );
  }

  /// `No bills this day`
  String get statsCalendarDayBillsEmpty {
    return Intl.message(
      'No bills this day',
      name: 'statsCalendarDayBillsEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Welcome`
  String get statsReceiptWelcome {
    return Intl.message(
      'Welcome',
      name: 'statsReceiptWelcome',
      desc: '',
      args: [],
    );
  }

  /// `Item`
  String get statsReceiptItem {
    return Intl.message('Item', name: 'statsReceiptItem', desc: '', args: []);
  }

  /// `Qty`
  String get statsReceiptQty {
    return Intl.message('Qty', name: 'statsReceiptQty', desc: '', args: []);
  }

  /// `Amount`
  String get statsReceiptAmountCol {
    return Intl.message(
      'Amount',
      name: 'statsReceiptAmountCol',
      desc: '',
      args: [],
    );
  }

  /// `Income items`
  String get statsReceiptIncomeGoods {
    return Intl.message(
      'Income items',
      name: 'statsReceiptIncomeGoods',
      desc: '',
      args: [],
    );
  }

  /// `Sold items`
  String get statsReceiptSoldGoods {
    return Intl.message(
      'Sold items',
      name: 'statsReceiptSoldGoods',
      desc: '',
      args: [],
    );
  }

  /// `Transfers`
  String get statsReceiptTransferCount {
    return Intl.message(
      'Transfers',
      name: 'statsReceiptTransferCount',
      desc: '',
      args: [],
    );
  }

  /// `Payment: Face pay`
  String get statsReceiptPayment {
    return Intl.message(
      'Payment: Face pay',
      name: 'statsReceiptPayment',
      desc: '',
      args: [],
    );
  }

  /// `Discount {amount}`
  String statsReceiptDiscountTotal(Object amount) {
    return Intl.message(
      'Discount $amount',
      name: 'statsReceiptDiscountTotal',
      desc: '',
      args: [amount],
    );
  }

  /// `Fees {amount}`
  String statsReceiptFeeTotal(Object amount) {
    return Intl.message(
      'Fees $amount',
      name: 'statsReceiptFeeTotal',
      desc: '',
      args: [amount],
    );
  }

  /// `Please keep this receipt`
  String get statsReceiptKeep {
    return Intl.message(
      'Please keep this receipt',
      name: 'statsReceiptKeep',
      desc: '',
      args: [],
    );
  }

  /// `Thank you`
  String get statsReceiptThanks {
    return Intl.message(
      'Thank you',
      name: 'statsReceiptThanks',
      desc: '',
      args: [],
    );
  }

  /// `Welcome again -- support: san.bug@qq.com`
  String get statsReceiptFooterWelcome {
    return Intl.message(
      'Welcome again -- support: san.bug@qq.com',
      name: 'statsReceiptFooterWelcome',
      desc: '',
      args: [],
    );
  }

  /// `Website: https://www.fortuneboot.com/`
  String get statsReceiptFooterUrl {
    return Intl.message(
      'Website: https://www.fortuneboot.com/',
      name: 'statsReceiptFooterUrl',
      desc: '',
      args: [],
    );
  }

  /// `Keep this receipt. To sponsor us,`
  String get statsReceiptFooterExcel {
    return Intl.message(
      'Keep this receipt. To sponsor us,',
      name: 'statsReceiptFooterExcel',
      desc: '',
      args: [],
    );
  }

  /// `scan the QR code. Thank you!`
  String get statsReceiptFooterScan {
    return Intl.message(
      'scan the QR code. Thank you!',
      name: 'statsReceiptFooterScan',
      desc: '',
      args: [],
    );
  }

  /// `Statement delivered within 24 hours`
  String get statsReceiptFooterDelivery {
    return Intl.message(
      'Statement delivered within 24 hours',
      name: 'statsReceiptFooterDelivery',
      desc: '',
      args: [],
    );
  }

  /// `Nothing is supported yet`
  String get statsReceiptFooterCounter {
    return Intl.message(
      'Nothing is supported yet',
      name: 'statsReceiptFooterCounter',
      desc: '',
      args: [],
    );
  }

  /// `Date:{date}`
  String statsReceiptDate(Object date) {
    return Intl.message(
      'Date:$date',
      name: 'statsReceiptDate',
      desc: '',
      args: [date],
    );
  }

  /// `No.:{id}`
  String statsReceiptSerial(Object id) {
    return Intl.message(
      'No.:$id',
      name: 'statsReceiptSerial',
      desc: '',
      args: [id],
    );
  }

  /// `Cashier: HaoJi`
  String get statsReceiptCashier {
    return Intl.message(
      'Cashier: HaoJi',
      name: 'statsReceiptCashier',
      desc: '',
      args: [],
    );
  }

  /// `Save receipt`
  String get statsReceiptSave {
    return Intl.message(
      'Save receipt',
      name: 'statsReceiptSave',
      desc: '',
      args: [],
    );
  }

  /// `Image data is empty`
  String get base64ImageEmpty {
    return Intl.message(
      'Image data is empty',
      name: 'base64ImageEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Could not read the image`
  String get base64ImageInvalid {
    return Intl.message(
      'Could not read the image',
      name: 'base64ImageInvalid',
      desc: '',
      args: [],
    );
  }

  /// `FortuneBoot is locked`
  String get appLockGateTitle {
    return Intl.message(
      'FortuneBoot is locked',
      name: 'appLockGateTitle',
      desc: '',
      args: [],
    );
  }

  /// `App lock setup is incomplete. Sign in again, then configure it from Mine.`
  String get appLockSetupRequiredDescription {
    return Intl.message(
      'App lock setup is incomplete. Sign in again, then configure it from Mine.',
      name: 'appLockSetupRequiredDescription',
      desc: '',
      args: [],
    );
  }

  /// `Enter your PIN to continue`
  String get appLockEnterPinDescription {
    return Intl.message(
      'Enter your PIN to continue',
      name: 'appLockEnterPinDescription',
      desc: '',
      args: [],
    );
  }

  /// `Draw your unlock pattern to continue`
  String get appLockEnterPatternDescription {
    return Intl.message(
      'Draw your unlock pattern to continue',
      name: 'appLockEnterPatternDescription',
      desc: '',
      args: [],
    );
  }

  /// `6–12 digit PIN`
  String get appLockPinHint {
    return Intl.message(
      '6–12 digit PIN',
      name: 'appLockPinHint',
      desc: '',
      args: [],
    );
  }

  /// `Draw your unlock pattern`
  String get appLockPatternHint {
    return Intl.message(
      'Draw your unlock pattern',
      name: 'appLockPatternHint',
      desc: '',
      args: [],
    );
  }

  /// `Draw unlock pattern`
  String get appLockDrawPattern {
    return Intl.message(
      'Draw unlock pattern',
      name: 'appLockDrawPattern',
      desc: '',
      args: [],
    );
  }

  /// `Draw the pattern again to confirm`
  String get appLockConfirmPattern {
    return Intl.message(
      'Draw the pattern again to confirm',
      name: 'appLockConfirmPattern',
      desc: '',
      args: [],
    );
  }

  /// `Connect at least 4 points`
  String get appLockPatternMinimumPoints {
    return Intl.message(
      'Connect at least 4 points',
      name: 'appLockPatternMinimumPoints',
      desc: '',
      args: [],
    );
  }

  /// `Patterns do not match. Try again.`
  String get appLockPatternMismatch {
    return Intl.message(
      'Patterns do not match. Try again.',
      name: 'appLockPatternMismatch',
      desc: '',
      args: [],
    );
  }

  /// `Redraw`
  String get appLockPatternReset {
    return Intl.message(
      'Redraw',
      name: 'appLockPatternReset',
      desc: '',
      args: [],
    );
  }

  /// `Unlock pattern grid`
  String get appLockPatternAccessibilityLabel {
    return Intl.message(
      'Unlock pattern grid',
      name: 'appLockPatternAccessibilityLabel',
      desc: '',
      args: [],
    );
  }

  /// `{count} points connected`
  String appLockPatternProgress(Object count) {
    return Intl.message(
      '$count points connected',
      name: 'appLockPatternProgress',
      desc: '',
      args: [count],
    );
  }

  /// `Row {row}, column {column} node, {state}`
  String appLockPatternNodeAccessibility(
    Object row,
    Object column,
    Object state,
  ) {
    return Intl.message(
      'Row $row, column $column node, $state',
      name: 'appLockPatternNodeAccessibility',
      desc: '',
      args: [row, column, state],
    );
  }

  /// `selected`
  String get appLockPatternNodeSelected {
    return Intl.message(
      'selected',
      name: 'appLockPatternNodeSelected',
      desc: '',
      args: [],
    );
  }

  /// `not selected`
  String get appLockPatternNodeUnselected {
    return Intl.message(
      'not selected',
      name: 'appLockPatternNodeUnselected',
      desc: '',
      args: [],
    );
  }

  /// `Use biometrics`
  String get appLockUseBiometrics {
    return Intl.message(
      'Use biometrics',
      name: 'appLockUseBiometrics',
      desc: '',
      args: [],
    );
  }

  /// `Verify your identity to unlock FortuneBoot`
  String get appLockBiometricLocalizedReason {
    return Intl.message(
      'Verify your identity to unlock FortuneBoot',
      name: 'appLockBiometricLocalizedReason',
      desc: '',
      args: [],
    );
  }

  /// `App lock`
  String get appLockSettingsTitle {
    return Intl.message(
      'App lock',
      name: 'appLockSettingsTitle',
      desc: '',
      args: [],
    );
  }

  /// `App lock is on`
  String get appLockEnabledHeading {
    return Intl.message(
      'App lock is on',
      name: 'appLockEnabledHeading',
      desc: '',
      args: [],
    );
  }

  /// `Turn on app lock`
  String get appLockEnableHeading {
    return Intl.message(
      'Turn on app lock',
      name: 'appLockEnableHeading',
      desc: '',
      args: [],
    );
  }

  /// `Verification is required after the app leaves the foreground.`
  String get appLockEnabledDescription {
    return Intl.message(
      'Verification is required after the app leaves the foreground.',
      name: 'appLockEnabledDescription',
      desc: '',
      args: [],
    );
  }

  /// `Verification is required after setup when the app leaves the foreground or re-enters the main screen.`
  String get appLockEnableDescription {
    return Intl.message(
      'Verification is required after setup when the app leaves the foreground or re-enters the main screen.',
      name: 'appLockEnableDescription',
      desc: '',
      args: [],
    );
  }

  /// `PIN`
  String get appLockPinMethod {
    return Intl.message('PIN', name: 'appLockPinMethod', desc: '', args: []);
  }

  /// `Unlock pattern`
  String get appLockPatternMethod {
    return Intl.message(
      'Unlock pattern',
      name: 'appLockPatternMethod',
      desc: '',
      args: [],
    );
  }

  /// `Set a 6–12 digit PIN`
  String get appLockPinSetupLabel {
    return Intl.message(
      'Set a 6–12 digit PIN',
      name: 'appLockPinSetupLabel',
      desc: '',
      args: [],
    );
  }

  /// `Draw an unlock pattern`
  String get appLockPatternSetupLabel {
    return Intl.message(
      'Draw an unlock pattern',
      name: 'appLockPatternSetupLabel',
      desc: '',
      args: [],
    );
  }

  /// `Confirm again`
  String get appLockConfirmCredentialLabel {
    return Intl.message(
      'Confirm again',
      name: 'appLockConfirmCredentialLabel',
      desc: '',
      args: [],
    );
  }

  /// `Use biometrics for faster unlocking`
  String get appLockBiometricToggleTitle {
    return Intl.message(
      'Use biometrics for faster unlocking',
      name: 'appLockBiometricToggleTitle',
      desc: '',
      args: [],
    );
  }

  /// `Keep your PIN or pattern as a fallback`
  String get appLockBiometricAvailableSubtitle {
    return Intl.message(
      'Keep your PIN or pattern as a fallback',
      name: 'appLockBiometricAvailableSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Biometrics are unavailable or not configured on this device`
  String get appLockBiometricUnavailableSubtitle {
    return Intl.message(
      'Biometrics are unavailable or not configured on this device',
      name: 'appLockBiometricUnavailableSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Default unlock method`
  String get appLockPreferredUnlockTitle {
    return Intl.message(
      'Default unlock method',
      name: 'appLockPreferredUnlockTitle',
      desc: '',
      args: [],
    );
  }

  /// `Used first on the lock screen; PIN/pattern remain as fallback`
  String get appLockPreferredUnlockSubtitle {
    return Intl.message(
      'Used first on the lock screen; PIN/pattern remain as fallback',
      name: 'appLockPreferredUnlockSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Fallback method`
  String get appLockFallbackMethodTitle {
    return Intl.message(
      'Fallback method',
      name: 'appLockFallbackMethodTitle',
      desc: '',
      args: [],
    );
  }

  /// `Used when face or fingerprint is unavailable`
  String get appLockFallbackMethodSubtitle {
    return Intl.message(
      'Used when face or fingerprint is unavailable',
      name: 'appLockFallbackMethodSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Face`
  String get appLockPreferredFace {
    return Intl.message(
      'Face',
      name: 'appLockPreferredFace',
      desc: '',
      args: [],
    );
  }

  /// `Fingerprint`
  String get appLockPreferredFingerprint {
    return Intl.message(
      'Fingerprint',
      name: 'appLockPreferredFingerprint',
      desc: '',
      args: [],
    );
  }

  /// `Unlock with Face ID`
  String get appLockUseFace {
    return Intl.message(
      'Unlock with Face ID',
      name: 'appLockUseFace',
      desc: '',
      args: [],
    );
  }

  /// `Unlock with fingerprint`
  String get appLockUseFingerprint {
    return Intl.message(
      'Unlock with fingerprint',
      name: 'appLockUseFingerprint',
      desc: '',
      args: [],
    );
  }

  /// `This unlock method is not available on this device`
  String get appLockPreferredUnavailable {
    return Intl.message(
      'This unlock method is not available on this device',
      name: 'appLockPreferredUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `Saving…`
  String get appLockSaving {
    return Intl.message('Saving…', name: 'appLockSaving', desc: '', args: []);
  }

  /// `Turn on app lock`
  String get appLockEnable {
    return Intl.message(
      'Turn on app lock',
      name: 'appLockEnable',
      desc: '',
      args: [],
    );
  }

  /// `Current unlock method`
  String get appLockCurrentMethod {
    return Intl.message(
      'Current unlock method',
      name: 'appLockCurrentMethod',
      desc: '',
      args: [],
    );
  }

  /// `Lock now`
  String get appLockLockNow {
    return Intl.message('Lock now', name: 'appLockLockNow', desc: '', args: []);
  }

  /// `Turn off app lock`
  String get appLockDisable {
    return Intl.message(
      'Turn off app lock',
      name: 'appLockDisable',
      desc: '',
      args: [],
    );
  }

  /// `Verify to turn off app lock`
  String get appLockDisableDialogTitle {
    return Intl.message(
      'Verify to turn off app lock',
      name: 'appLockDisableDialogTitle',
      desc: '',
      args: [],
    );
  }

  /// `Current PIN or pattern`
  String get appLockCurrentCredentialLabel {
    return Intl.message(
      'Current PIN or pattern',
      name: 'appLockCurrentCredentialLabel',
      desc: '',
      args: [],
    );
  }

  /// `Verify`
  String get appLockVerify {
    return Intl.message('Verify', name: 'appLockVerify', desc: '', args: []);
  }

  /// `The entries do not match`
  String get appLockCredentialMismatch {
    return Intl.message(
      'The entries do not match',
      name: 'appLockCredentialMismatch',
      desc: '',
      args: [],
    );
  }

  /// `PIN must contain 6–12 digits`
  String get appLockPinLengthInvalid {
    return Intl.message(
      'PIN must contain 6–12 digits',
      name: 'appLockPinLengthInvalid',
      desc: '',
      args: [],
    );
  }

  /// `Check the PIN or pattern format and try again`
  String get appLockConfigurationInvalid {
    return Intl.message(
      'Check the PIN or pattern format and try again',
      name: 'appLockConfigurationInvalid',
      desc: '',
      args: [],
    );
  }

  /// `Verification failed. Please try again.`
  String get appLockDisableVerificationFailed {
    return Intl.message(
      'Verification failed. Please try again.',
      name: 'appLockDisableVerificationFailed',
      desc: '',
      args: [],
    );
  }

  /// `Verification failed. Please try again.`
  String get appLockFailureInvalidCredential {
    return Intl.message(
      'Verification failed. Please try again.',
      name: 'appLockFailureInvalidCredential',
      desc: '',
      args: [],
    );
  }

  /// `Biometric verification failed. Try again or use your PIN/pattern.`
  String get appLockFailureBiometric {
    return Intl.message(
      'Biometric verification failed. Try again or use your PIN/pattern.',
      name: 'appLockFailureBiometric',
      desc: '',
      args: [],
    );
  }

  /// `Biometrics unavailable. Use your PIN or pattern instead.`
  String get appLockFailureBiometricUnavailable {
    return Intl.message(
      'Biometrics unavailable. Use your PIN or pattern instead.',
      name: 'appLockFailureBiometricUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `Could not save app-lock settings.`
  String get appLockFailureConfigurationSave {
    return Intl.message(
      'Could not save app-lock settings.',
      name: 'appLockFailureConfigurationSave',
      desc: '',
      args: [],
    );
  }

  /// `Could not turn off app lock.`
  String get appLockFailureDisable {
    return Intl.message(
      'Could not turn off app lock.',
      name: 'appLockFailureDisable',
      desc: '',
      args: [],
    );
  }

  /// `Receivable order`
  String get ordersTypeReceivable {
    return Intl.message(
      'Receivable order',
      name: 'ordersTypeReceivable',
      desc: '',
      args: [],
    );
  }

  /// `Payable order`
  String get ordersTypePayable {
    return Intl.message(
      'Payable order',
      name: 'ordersTypePayable',
      desc: '',
      args: [],
    );
  }

  /// `Active`
  String get ordersStatusUsing {
    return Intl.message(
      'Active',
      name: 'ordersStatusUsing',
      desc: '',
      args: [],
    );
  }

  /// `Draft`
  String get ordersStatusDraft {
    return Intl.message('Draft', name: 'ordersStatusDraft', desc: '', args: []);
  }

  /// `Archived`
  String get ordersStatusClosed {
    return Intl.message(
      'Archived',
      name: 'ordersStatusClosed',
      desc: '',
      args: [],
    );
  }

  /// `Search title / counterparty`
  String get ordersSearchHint {
    return Intl.message(
      'Search title / counterparty',
      name: 'ordersSearchHint',
      desc: '',
      args: [],
    );
  }

  /// `Overdue only`
  String get ordersOverdueOnly {
    return Intl.message(
      'Overdue only',
      name: 'ordersOverdueOnly',
      desc: '',
      args: [],
    );
  }

  /// `No orders match the current filters`
  String get ordersFilterEmpty {
    return Intl.message(
      'No orders match the current filters',
      name: 'ordersFilterEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Load more`
  String get ordersLoadMore {
    return Intl.message(
      'Load more',
      name: 'ordersLoadMore',
      desc: '',
      args: [],
    );
  }

  /// `Could not load more. Please retry.`
  String get ordersLoadMoreFailed {
    return Intl.message(
      'Could not load more. Please retry.',
      name: 'ordersLoadMoreFailed',
      desc: '',
      args: [],
    );
  }

  /// `{count} orders`
  String ordersMetricCount(int count) {
    return Intl.message(
      '$count orders',
      name: 'ordersMetricCount',
      desc: '',
      args: [count],
    );
  }

  /// `To recover`
  String get ordersPendingReceivable {
    return Intl.message(
      'To recover',
      name: 'ordersPendingReceivable',
      desc: '',
      args: [],
    );
  }

  /// `To repay`
  String get ordersPendingPayable {
    return Intl.message(
      'To repay',
      name: 'ordersPendingPayable',
      desc: '',
      args: [],
    );
  }

  /// `To reimburse`
  String get ordersPendingReimbursement {
    return Intl.message(
      'To reimburse',
      name: 'ordersPendingReimbursement',
      desc: '',
      args: [],
    );
  }

  /// `Lent out`
  String get ordersIssuedLoanOut {
    return Intl.message(
      'Lent out',
      name: 'ordersIssuedLoanOut',
      desc: '',
      args: [],
    );
  }

  /// `Borrowed in`
  String get ordersIssuedLoanIn {
    return Intl.message(
      'Borrowed in',
      name: 'ordersIssuedLoanIn',
      desc: '',
      args: [],
    );
  }

  /// `Advanced`
  String get ordersIssuedAdvance {
    return Intl.message(
      'Advanced',
      name: 'ordersIssuedAdvance',
      desc: '',
      args: [],
    );
  }

  /// `Recovered`
  String get ordersSettledRecovered {
    return Intl.message(
      'Recovered',
      name: 'ordersSettledRecovered',
      desc: '',
      args: [],
    );
  }

  /// `Repaid`
  String get ordersSettledRepaid {
    return Intl.message(
      'Repaid',
      name: 'ordersSettledRepaid',
      desc: '',
      args: [],
    );
  }

  /// `Reimbursed`
  String get ordersSettledReimbursed {
    return Intl.message(
      'Reimbursed',
      name: 'ordersSettledReimbursed',
      desc: '',
      args: [],
    );
  }

  /// `Partially settled`
  String get ordersPartiallySettled {
    return Intl.message(
      'Partially settled',
      name: 'ordersPartiallySettled',
      desc: '',
      args: [],
    );
  }

  /// `Settled`
  String get ordersSettledTag {
    return Intl.message(
      'Settled',
      name: 'ordersSettledTag',
      desc: '',
      args: [],
    );
  }

  /// `Overdue`
  String get ordersOverdue {
    return Intl.message('Overdue', name: 'ordersOverdue', desc: '', args: []);
  }

  /// `{count} pending`
  String ordersPendingEntryCount(int count) {
    return Intl.message(
      '$count pending',
      name: 'ordersPendingEntryCount',
      desc: '',
      args: [count],
    );
  }

  /// `Needs review`
  String get ordersReviewRequired {
    return Intl.message(
      'Needs review',
      name: 'ordersReviewRequired',
      desc: '',
      args: [],
    );
  }

  /// `This order’s amounts cannot be calculated reliably and are excluded from totals. Check the reconciliation report, or fix related entries before reviewing again.`
  String get ordersReviewRequiredHint {
    return Intl.message(
      'This order’s amounts cannot be calculated reliably and are excluded from totals. Check the reconciliation report, or fix related entries before reviewing again.',
      name: 'ordersReviewRequiredHint',
      desc: '',
      args: [],
    );
  }

  /// `Review report`
  String get ordersViewReconciliation {
    return Intl.message(
      'Review report',
      name: 'ordersViewReconciliation',
      desc: '',
      args: [],
    );
  }

  /// `Issued`
  String get ordersIssuedAmount {
    return Intl.message(
      'Issued',
      name: 'ordersIssuedAmount',
      desc: '',
      args: [],
    );
  }

  /// `Settled`
  String get ordersSettledAmount {
    return Intl.message(
      'Settled',
      name: 'ordersSettledAmount',
      desc: '',
      args: [],
    );
  }

  /// `Adjusted`
  String get ordersAdjustedAmount {
    return Intl.message(
      'Adjusted',
      name: 'ordersAdjustedAmount',
      desc: '',
      args: [],
    );
  }

  /// `Interest income`
  String get ordersInterestIncome {
    return Intl.message(
      'Interest income',
      name: 'ordersInterestIncome',
      desc: '',
      args: [],
    );
  }

  /// `Interest expense`
  String get ordersInterestExpense {
    return Intl.message(
      'Interest expense',
      name: 'ordersInterestExpense',
      desc: '',
      args: [],
    );
  }

  /// `Fees`
  String get ordersFeeAmount {
    return Intl.message('Fees', name: 'ordersFeeAmount', desc: '', args: []);
  }

  /// `Needs review`
  String get ordersAmountUnknown {
    return Intl.message(
      'Needs review',
      name: 'ordersAmountUnknown',
      desc: '',
      args: [],
    );
  }

  /// `Principal`
  String get ordersComponentPrincipal {
    return Intl.message(
      'Principal',
      name: 'ordersComponentPrincipal',
      desc: '',
      args: [],
    );
  }

  /// `Interest`
  String get ordersComponentInterest {
    return Intl.message(
      'Interest',
      name: 'ordersComponentInterest',
      desc: '',
      args: [],
    );
  }

  /// `Fee`
  String get ordersComponentFee {
    return Intl.message('Fee', name: 'ordersComponentFee', desc: '', args: []);
  }

  /// `Write-off`
  String get ordersComponentWriteOff {
    return Intl.message(
      'Write-off',
      name: 'ordersComponentWriteOff',
      desc: '',
      args: [],
    );
  }

  /// `Regular bill`
  String get ordersComponentUnknown {
    return Intl.message(
      'Regular bill',
      name: 'ordersComponentUnknown',
      desc: '',
      args: [],
    );
  }

  /// `Pending confirmation`
  String get ordersPendingConfirmation {
    return Intl.message(
      'Pending confirmation',
      name: 'ordersPendingConfirmation',
      desc: '',
      args: [],
    );
  }

  /// `Voided`
  String get ordersVoided {
    return Intl.message('Voided', name: 'ordersVoided', desc: '', args: []);
  }

  /// `Active entries`
  String get ordersActiveEntries {
    return Intl.message(
      'Active entries',
      name: 'ordersActiveEntries',
      desc: '',
      args: [],
    );
  }

  /// `All entries`
  String get ordersAllEntries {
    return Intl.message(
      'All entries',
      name: 'ordersAllEntries',
      desc: '',
      args: [],
    );
  }

  /// `No entries yet`
  String get ordersEntriesEmpty {
    return Intl.message(
      'No entries yet',
      name: 'ordersEntriesEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Audit log`
  String get ordersAuditTitle {
    return Intl.message(
      'Audit log',
      name: 'ordersAuditTitle',
      desc: '',
      args: [],
    );
  }

  /// `Reconciliation report`
  String get ordersReconciliationTitle {
    return Intl.message(
      'Reconciliation report',
      name: 'ordersReconciliationTitle',
      desc: '',
      args: [],
    );
  }

  /// `No historical reconciliation rows. Orders may still need review — open the order to check its entries.`
  String get ordersReconciliationEmpty {
    return Intl.message(
      'No historical reconciliation rows. Orders may still need review — open the order to check its entries.',
      name: 'ordersReconciliationEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Open this order`
  String get ordersOpenFocusedOrder {
    return Intl.message(
      'Open this order',
      name: 'ordersOpenFocusedOrder',
      desc: '',
      args: [],
    );
  }

  /// `Original out`
  String get ordersReconciliationOutAmount {
    return Intl.message(
      'Original out',
      name: 'ordersReconciliationOutAmount',
      desc: '',
      args: [],
    );
  }

  /// `Original in`
  String get ordersReconciliationInAmount {
    return Intl.message(
      'Original in',
      name: 'ordersReconciliationInAmount',
      desc: '',
      args: [],
    );
  }

  /// `Pending difference`
  String get ordersReconciliationPendingAmount {
    return Intl.message(
      'Pending difference',
      name: 'ordersReconciliationPendingAmount',
      desc: '',
      args: [],
    );
  }

  /// `Order #{id}`
  String ordersReconciliationOrderTitle(Object id) {
    return Intl.message(
      'Order #$id',
      name: 'ordersReconciliationOrderTitle',
      desc: '',
      args: [id],
    );
  }

  /// `Bill #{id}`
  String ordersReconciliationBillTitle(Object id) {
    return Intl.message(
      'Bill #$id',
      name: 'ordersReconciliationBillTitle',
      desc: '',
      args: [id],
    );
  }

  /// `Unlinked record`
  String get ordersReconciliationUnknownTitle {
    return Intl.message(
      'Unlinked record',
      name: 'ordersReconciliationUnknownTitle',
      desc: '',
      args: [],
    );
  }

  /// `Amount calculation is invalid and needs review`
  String get ordersIssueCalculationInvalid {
    return Intl.message(
      'Amount calculation is invalid and needs review',
      name: 'ordersIssueCalculationInvalid',
      desc: '',
      args: [],
    );
  }

  /// `Legacy loan bill is isolated and needs review`
  String get ordersIssueLegacyLoanIsolated {
    return Intl.message(
      'Legacy loan bill is isolated and needs review',
      name: 'ordersIssueLegacyLoanIsolated',
      desc: '',
      args: [],
    );
  }

  /// `Historical cash effect is unknown`
  String get ordersIssueCashEffectUnknown {
    return Intl.message(
      'Historical cash effect is unknown',
      name: 'ordersIssueCashEffectUnknown',
      desc: '',
      args: [],
    );
  }

  /// `Original out`
  String get ordersReconciliationOriginalOut {
    return Intl.message(
      'Original out',
      name: 'ordersReconciliationOriginalOut',
      desc: '',
      args: [],
    );
  }

  /// `Original in`
  String get ordersReconciliationOriginalIn {
    return Intl.message(
      'Original in',
      name: 'ordersReconciliationOriginalIn',
      desc: '',
      args: [],
    );
  }

  /// `Pending to review`
  String get ordersReconciliationCandidatePending {
    return Intl.message(
      'Pending to review',
      name: 'ordersReconciliationCandidatePending',
      desc: '',
      args: [],
    );
  }

  /// `Cash effect unknown`
  String get ordersReconciliationCashUnknown {
    return Intl.message(
      'Cash effect unknown',
      name: 'ordersReconciliationCashUnknown',
      desc: '',
      args: [],
    );
  }

  /// `More actions`
  String get ordersMoreActions {
    return Intl.message(
      'More actions',
      name: 'ordersMoreActions',
      desc: '',
      args: [],
    );
  }

  /// `Edit metadata`
  String get ordersEditMetadata {
    return Intl.message(
      'Edit metadata',
      name: 'ordersEditMetadata',
      desc: '',
      args: [],
    );
  }

  /// `Write off`
  String get ordersWriteOff {
    return Intl.message(
      'Write off',
      name: 'ordersWriteOff',
      desc: '',
      args: [],
    );
  }

  /// `Confirm write-off?`
  String get ordersWriteOffConfirmTitle {
    return Intl.message(
      'Confirm write-off?',
      name: 'ordersWriteOffConfirmTitle',
      desc: '',
      args: [],
    );
  }

  /// `Adjustment: {amount}. It will be recorded in income/expense but will not change account balances again.`
  String ordersWriteOffConfirmMessage(String amount) {
    return Intl.message(
      'Adjustment: $amount. It will be recorded in income/expense but will not change account balances again.',
      name: 'ordersWriteOffConfirmMessage',
      desc: '',
      args: [amount],
    );
  }

  /// `This is a non-cash adjustment and will not change account balances again.`
  String get ordersWriteOffNoCashChange {
    return Intl.message(
      'This is a non-cash adjustment and will not change account balances again.',
      name: 'ordersWriteOffNoCashChange',
      desc: '',
      args: [],
    );
  }

  /// `Confirm voiding?`
  String get ordersVoidConfirmTitle {
    return Intl.message(
      'Confirm voiding?',
      name: 'ordersVoidConfirmTitle',
      desc: '',
      args: [],
    );
  }

  /// `Voiding will roll back funds: {amount}.`
  String ordersVoidCashRollback(String amount) {
    return Intl.message(
      'Voiding will roll back funds: $amount.',
      name: 'ordersVoidCashRollback',
      desc: '',
      args: [amount],
    );
  }

  /// `Voiding removes it from statistics but does not change account balances.`
  String get ordersVoidNoCashChange {
    return Intl.message(
      'Voiding removes it from statistics but does not change account balances.',
      name: 'ordersVoidNoCashChange',
      desc: '',
      args: [],
    );
  }

  /// `Confirm restoring?`
  String get ordersRestoreConfirmTitle {
    return Intl.message(
      'Confirm restoring?',
      name: 'ordersRestoreConfirmTitle',
      desc: '',
      args: [],
    );
  }

  /// `Restoring re-applies the original confirmation state; it is not a bank reversal or a new payment.`
  String get ordersRestoreConfirmMessage {
    return Intl.message(
      'Restoring re-applies the original confirmation state; it is not a bank reversal or a new payment.',
      name: 'ordersRestoreConfirmMessage',
      desc: '',
      args: [],
    );
  }

  /// `Edit entry`
  String get ordersEditEntry {
    return Intl.message(
      'Edit entry',
      name: 'ordersEditEntry',
      desc: '',
      args: [],
    );
  }

  /// `Unconfirm`
  String get ordersUnconfirm {
    return Intl.message(
      'Unconfirm',
      name: 'ordersUnconfirm',
      desc: '',
      args: [],
    );
  }

  /// `Void`
  String get ordersVoid {
    return Intl.message('Void', name: 'ordersVoid', desc: '', args: []);
  }

  /// `Restore`
  String get ordersRestore {
    return Intl.message('Restore', name: 'ordersRestore', desc: '', args: []);
  }

  /// `Archive this order?`
  String get ordersArchiveConfirmTitle {
    return Intl.message(
      'Archive this order?',
      name: 'ordersArchiveConfirmTitle',
      desc: '',
      args: [],
    );
  }

  /// `The order and its entries become read-only; historical statistics remain.`
  String get ordersArchiveConfirmMessage {
    return Intl.message(
      'The order and its entries become read-only; historical statistics remain.',
      name: 'ordersArchiveConfirmMessage',
      desc: '',
      args: [],
    );
  }

  /// `Reopen this order?`
  String get ordersReopenConfirmTitle {
    return Intl.message(
      'Reopen this order?',
      name: 'ordersReopenConfirmTitle',
      desc: '',
      args: [],
    );
  }

  /// `Reopening allows corrections and late entries without rolling back funds.`
  String get ordersReopenConfirmMessage {
    return Intl.message(
      'Reopening allows corrections and late entries without rolling back funds.',
      name: 'ordersReopenConfirmMessage',
      desc: '',
      args: [],
    );
  }

  /// `Only empty orders with no entry history can be deleted.`
  String get ordersDeleteOnlyEmptyMessage {
    return Intl.message(
      'Only empty orders with no entry history can be deleted.',
      name: 'ordersDeleteOnlyEmptyMessage',
      desc: '',
      args: [],
    );
  }

  /// `Counterparty`
  String get ordersCounterparty {
    return Intl.message(
      'Counterparty',
      name: 'ordersCounterparty',
      desc: '',
      args: [],
    );
  }

  /// `Choose an existing contact or enter a name`
  String get ordersCounterpartyHint {
    return Intl.message(
      'Choose an existing contact or enter a name',
      name: 'ordersCounterpartyHint',
      desc: '',
      args: [],
    );
  }

  /// `Enter a counterparty`
  String get ordersCounterpartyRequired {
    return Intl.message(
      'Enter a counterparty',
      name: 'ordersCounterpartyRequired',
      desc: '',
      args: [],
    );
  }

  /// `Entry history exists, so the counterparty is locked`
  String get ordersCounterpartyLockedReason {
    return Intl.message(
      'Entry history exists, so the counterparty is locked',
      name: 'ordersCounterpartyLockedReason',
      desc: '',
      args: [],
    );
  }

  /// `Order type cannot change after creation`
  String get ordersTypeLockedReason {
    return Intl.message(
      'Order type cannot change after creation',
      name: 'ordersTypeLockedReason',
      desc: '',
      args: [],
    );
  }

  /// `Due date (optional)`
  String get ordersDueDateOptional {
    return Intl.message(
      'Due date (optional)',
      name: 'ordersDueDateOptional',
      desc: '',
      args: [],
    );
  }

  /// `Choose or clear a date`
  String get ordersDueDateHint {
    return Intl.message(
      'Choose or clear a date',
      name: 'ordersDueDateHint',
      desc: '',
      args: [],
    );
  }

  /// `Save draft`
  String get ordersSaveDraft {
    return Intl.message(
      'Save draft',
      name: 'ordersSaveDraft',
      desc: '',
      args: [],
    );
  }

  /// `Next, add an entry`
  String get ordersContinueToEntry {
    return Intl.message(
      'Next, add an entry',
      name: 'ordersContinueToEntry',
      desc: '',
      args: [],
    );
  }

  /// `Record advance`
  String get ordersActionAdvance {
    return Intl.message(
      'Record advance',
      name: 'ordersActionAdvance',
      desc: '',
      args: [],
    );
  }

  /// `Record reimbursement`
  String get ordersActionReimburse {
    return Intl.message(
      'Record reimbursement',
      name: 'ordersActionReimburse',
      desc: '',
      args: [],
    );
  }

  /// `Record money lent`
  String get ordersActionLoanOut {
    return Intl.message(
      'Record money lent',
      name: 'ordersActionLoanOut',
      desc: '',
      args: [],
    );
  }

  /// `Recover principal`
  String get ordersActionLoanRecover {
    return Intl.message(
      'Recover principal',
      name: 'ordersActionLoanRecover',
      desc: '',
      args: [],
    );
  }

  /// `Record money borrowed`
  String get ordersActionLoanIn {
    return Intl.message(
      'Record money borrowed',
      name: 'ordersActionLoanIn',
      desc: '',
      args: [],
    );
  }

  /// `Repay principal`
  String get ordersActionLoanRepay {
    return Intl.message(
      'Repay principal',
      name: 'ordersActionLoanRepay',
      desc: '',
      args: [],
    );
  }

  /// `Interest received`
  String get ordersActionInterestIn {
    return Intl.message(
      'Interest received',
      name: 'ordersActionInterestIn',
      desc: '',
      args: [],
    );
  }

  /// `Interest paid`
  String get ordersActionInterestOut {
    return Intl.message(
      'Interest paid',
      name: 'ordersActionInterestOut',
      desc: '',
      args: [],
    );
  }

  /// `Pay fee`
  String get ordersActionFee {
    return Intl.message('Pay fee', name: 'ordersActionFee', desc: '', args: []);
  }

  /// `Overdue to recover`
  String get ordersOverdueReceivable {
    return Intl.message(
      'Overdue to recover',
      name: 'ordersOverdueReceivable',
      desc: '',
      args: [],
    );
  }

  /// `Overdue to repay`
  String get ordersOverduePayable {
    return Intl.message(
      'Overdue to repay',
      name: 'ordersOverduePayable',
      desc: '',
      args: [],
    );
  }

  /// `Overdue to reimburse`
  String get ordersOverdueReimbursement {
    return Intl.message(
      'Overdue to reimburse',
      name: 'ordersOverdueReimbursement',
      desc: '',
      args: [],
    );
  }

  /// `{count} orders need review and are excluded from these totals`
  String ordersReviewRequiredCount(int count) {
    return Intl.message(
      '$count orders need review and are excluded from these totals',
      name: 'ordersReviewRequiredCount',
      desc: '',
      args: [count],
    );
  }

  /// `{count} orphan legacy bills need review`
  String ordersOrphanLegacyCount(int count) {
    return Intl.message(
      '$count orphan legacy bills need review',
      name: 'ordersOrphanLegacyCount',
      desc: '',
      args: [count],
    );
  }

  /// `{count} entries pending confirmation`
  String statsLoanPendingCount(int count) {
    return Intl.message(
      '$count entries pending confirmation',
      name: 'statsLoanPendingCount',
      desc: '',
      args: [count],
    );
  }

  /// `Archived loan income/expense`
  String get statsArchivedLoanIncomeExpense {
    return Intl.message(
      'Archived loan income/expense',
      name: 'statsArchivedLoanIncomeExpense',
      desc: '',
      args: [],
    );
  }

  /// `Based on interest, fees and write-offs of archived receivable/payable orders; it is not an investment return.`
  String get statsArchivedLoanNote {
    return Intl.message(
      'Based on interest, fees and write-offs of archived receivable/payable orders; it is not an investment return.',
      name: 'statsArchivedLoanNote',
      desc: '',
      args: [],
    );
  }

  /// `Use 8-18 characters with letters, numbers, or symbols; Chinese characters are not allowed`
  String get passwordPolicyHint {
    return Intl.message(
      'Use 8-18 characters with letters, numbers, or symbols; Chinese characters are not allowed',
      name: 'passwordPolicyHint',
      desc: '',
      args: [],
    );
  }

  /// `Enter verification code`
  String get captchaTitle {
    return Intl.message(
      'Enter verification code',
      name: 'captchaTitle',
      desc: '',
      args: [],
    );
  }

  /// `Complete the security check to continue signing in`
  String get captchaSubtitle {
    return Intl.message(
      'Complete the security check to continue signing in',
      name: 'captchaSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Refresh verification code`
  String get captchaRefresh {
    return Intl.message(
      'Refresh verification code',
      name: 'captchaRefresh',
      desc: '',
      args: [],
    );
  }

  /// `Enter the code shown in the image`
  String get captchaRequired {
    return Intl.message(
      'Enter the code shown in the image',
      name: 'captchaRequired',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'zh'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
