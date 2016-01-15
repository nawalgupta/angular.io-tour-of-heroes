import 'package:grinder/grinder.dart';
import 'package:git/git.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'dart:async';

void main(List<String> args) {
  grind(args);
}

@DefaultTask()
@Depends(format, analyze, peanut)
void prePush() {}

@Task('Peanut should be run before each push, to update the demo in gh-pages.')
peanut() async {
  final tempDir = await Directory.systemTemp.createTemp('peanut');

  final args = ['build', 'web', '--output=${tempDir.path}'];

  final process = await startProcess('pub', args);

  final exitCode = await process.exitCode;
  if (exitCode != 0) throw 'Error running pub ${args.join(' ')}';

  final gitDir = await GitDir.fromExisting('../');

  final commit = await gitDir.updateBranchWithDirectoryContents(
      'gh-pages', path.join(tempDir.path, 'web'), '.');

  if (commit == null) {
    print('There was no change in branch. No commit created.');
  } else {
    print('Branch gh-pages was updated '
        'with "pub build" output from web.');
  }
  final process2 = await startProcess('git', ['push', 'origin', 'gh-pages']);
  await process2.exitCode;
}

@Task('Analyze all Dart files.')
void analyze() {
  Analyzer.analyze(existingSourceDirs);
}

@Task('Apply dartfmt to all Dart source files')
void format() {
  DartFmt.format(existingSourceDirs);
}

Future<Process> startProcess(String executable, List<String> arguments) async {
  print('--- $executable ${arguments.join(' ')} ---');
  return await Process.start(executable, arguments, runInShell: true)
    ..stdout.transform(SYSTEM_ENCODING.decoder).forEach(stdout.write)
    ..stderr.transform(SYSTEM_ENCODING.decoder).forEach(stderr.write);
}
