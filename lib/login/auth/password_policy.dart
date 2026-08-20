/// Shared account-password policy for sign-in, registration and profile changes.
abstract final class PasswordPolicy {
  static final _valid = RegExp(
    r'^(?![0-9]+$)(?![a-z]+$)(?![A-Z]+$)(?!([^(0-9a-zA-Z)]|[()])+$)(?!^.*[一-龥].*$)([^(0-9a-zA-Z)]|[()]|[a-z]|[A-Z]|[0-9]){8,18}$',
  );

  static bool isValid(String value) => _valid.hasMatch(value);
}
