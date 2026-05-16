// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry/testing.dart';
import 'package:otel_codemagic/otel_codemagic.dart';
import 'package:test/test.dart';

void main() {
  late TestHarness harness;
  late InMemorySpanExporter spans;

  setUpAll(() async {
    harness = await maybeInitializeOtelForTest(
      serviceName: 'otel_codemagic-test',
    );
    spans = harness.spans;
  });

  setUp(() => harness.clear());

  Map<String, Object> attrsOf(Span s) =>
      {for (final a in s.attributes.toList()) a.key: a.value};

  test('getBuild records instance + credits + publishing targets', () async {
    await tracedCodemagic<String>(
      operation: 'getBuild',
      invoke: () async => const CodemagicCallResult(
        value: 'ok',
        result: CodemagicResult(
          buildId: 'b_1',
          buildNumber: 42,
          instanceType: 'mac_mini_m2',
          platform: 'flutter',
          status: 'success',
          durationSec: 720,
          creditsUsed: 24,
          publishingTargets: ['testflight', 'firebaseAppDistribution'],
          testCount: 120,
          testFailedCount: 0,
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('codemagic getBuild')!);
    expect(a['codemagic.instance.type'], 'mac_mini_m2');
    expect(a['codemagic.credits.used'], 24);
    expect(a['codemagic.status'], 'success');
  });

  test('failed status sets span error', () async {
    await tracedCodemagic<String>(
      operation: 'startBuild',
      invoke: () async => const CodemagicCallResult(
        value: 'ok',
        result: CodemagicResult(status: 'failed', buildId: 'b_2'),
      ),
    );
    expect(
      spans.findSpanByName('codemagic startBuild')!.status,
      SpanStatusCode.Error,
    );
  });

  test('test failures set span error', () async {
    await tracedCodemagic<String>(
      operation: 'getBuild',
      invoke: () async => const CodemagicCallResult(
        value: 'ok',
        result: CodemagicResult(
          status: 'finished',
          testCount: 50,
          testFailedCount: 3,
        ),
      ),
    );
    expect(
      spans.findSpanByName('codemagic getBuild')!.status,
      SpanStatusCode.Error,
    );
  });

  test('suppression skips spans', () async {
    await runWithoutCodemagicInstrumentationAsync(() async {
      await tracedCodemagic<String>(
        operation: 'listBuilds',
        invoke: () async => const CodemagicCallResult(value: 'v'),
      );
    });
    expect(spans.findSpansStartingWith('codemagic '), isEmpty);
  });
}
