import 'dart:io';

Future<void> main() async {
  final result = await Process.run('dart', ['run', 'intl_utils:generate']);
  stdout.write(result.stdout);
  stderr.write(result.stderr);
  if (result.exitCode != 0) {
    exitCode = result.exitCode;
  }
}
