// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_codemagic/otel_codemagic.dart';

/// Traces Codemagic calls with OpenTelemetry.
///
/// `otel_codemagic` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Codemagic call in
/// [tracedCodemagic]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'codemagic-example');

  // Wraps a Codemagic API call in a CLIENT span.
  final codemagicId = await tracedCodemagic<String>(
    operation: 'create',
    invoke: () async {
      // Make the Codemagic call here, then report what it returned.
      const id = 'codemagic_8f3a2c';
      return const CodemagicCallResult(
          value: id,
          result: CodemagicResult(
              appId: 'app_8f3a2c',
              workflowId: 'workflow_8f3a2c',
              workflowName: 'example',
              buildId: 'build_8f3a2c',
              buildNumber: 1,
              branch: 'example',
              tag: 'example',
              commit: 'example',
              instanceType: 'mac_mini_m1',
              platform: 'android',
              status: 'queued',
              durationSec: 120,
              creditsUsed: 1,
              publishingTargets: ['appStore'],
              testCount: 3,
              testFailedCount: 3,
              codeSigningProvider: 'app_store_connect',
              cachePullSec: 1,
              cachePushSec: 1,
              rateLimitRemaining: 25,
              errorCode: 'example',
              statusCode: 201));
    },
  );
  OTelLog.info('tracedCodemagic create returned $codemagicId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutCodemagicInstrumentationAsync.
  await runWithoutCodemagicInstrumentationAsync(
    () => tracedCodemagic<String>(
      operation: 'create',
      invoke: () async {
        const id = 'codemagic_8f3a2c';
        return const CodemagicCallResult(
            value: id,
            result: CodemagicResult(
                appId: 'app_8f3a2c',
                workflowId: 'workflow_8f3a2c',
                workflowName: 'example',
                buildId: 'build_8f3a2c',
                buildNumber: 1,
                branch: 'example',
                tag: 'example',
                commit: 'example',
                instanceType: 'mac_mini_m1',
                platform: 'android',
                status: 'queued',
                durationSec: 120,
                creditsUsed: 1,
                publishingTargets: ['appStore'],
                testCount: 3,
                testFailedCount: 3,
                codeSigningProvider: 'app_store_connect',
                cachePullSec: 1,
                cachePushSec: 1,
                rateLimitRemaining: 25,
                errorCode: 'example',
                statusCode: 201));
      },
    ),
  );

  await OTel.shutdown();
}
