// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_codemagic_suppression.dart';

const _tracerName = 'dartastic_otel_libs_codemagic';

APITracer _tracer() => OTelAPI.tracerProvider().getTracer(_tracerName);

class CodemagicResult {
  /// Creates a result.
  const CodemagicResult({
    this.appId,
    this.workflowId,
    this.workflowName,
    this.buildId,
    this.buildNumber,
    this.branch,
    this.tag,
    this.commit,
    this.instanceType,
    this.platform,
    this.status,
    this.durationSec,
    this.creditsUsed,
    this.publishingTargets,
    this.testCount,
    this.testFailedCount,
    this.codeSigningProvider,
    this.cachePullSec,
    this.cachePushSec,
    this.rateLimitRemaining,
    this.errorCode,
    this.statusCode,
  });

  final String? appId;
  final String? workflowId;
  final String? workflowName;
  final String? buildId;
  final int? buildNumber;
  final String? branch;
  final String? tag;
  final String? commit;

  /// `mac_mini_m1`, `mac_mini_m2`, `mac_pro`, `linux_x2`, `linux_standard`,
  /// `linux_premium`, `windows_x2`.
  final String? instanceType;

  /// `android`, `ios`, `flutter`, `react_native`, `web`.
  final String? platform;

  /// `queued`, `preparing`, `fetching`, `testing`, `building`,
  /// `publishing`, `finished`, `success`, `failed`, `canceled`,
  /// `skipped`, `timeout`.
  final String? status;

  final int? durationSec;

  /// Compute minutes consumed (Codemagic billing unit).
  final int? creditsUsed;

  /// `appStore`, `googlePlay`, `firebaseAppDistribution`, `testflight`,
  /// `huaweiAppGallery`, `s3`, `slack`, `email`.
  final List<String>? publishingTargets;

  final int? testCount;
  final int? testFailedCount;

  /// `app_store_connect`, `manual`, `automatic`.
  final String? codeSigningProvider;

  final int? cachePullSec;
  final int? cachePushSec;

  final int? rateLimitRemaining;

  final String? errorCode;
  final int? statusCode;
}

/// What a traced call returned: the value for the caller plus fields
/// recorded on the span.
class CodemagicCallResult<T> {
  /// Creates a call result.
  const CodemagicCallResult({required this.value, this.result});

  /// The value returned to the caller.
  final T value;
  final CodemagicResult? result;
}

/// Wraps a Codemagic API call in a CLIENT span. [operation] is one of
/// `listApplications`, `getApplication`, `getEnvironmentVariables`,
/// `addEnvironmentVariable`, `deleteEnvironmentVariable`,
/// `startBuild`, `getBuild`, `cancelBuild`, `listBuilds`,
/// `getBuildArtifact`, `downloadArtifact`, `addAppleSigningCertificate`,
/// `addAndroidKeystore`.
Future<T> tracedCodemagic<T>({
  required String operation,
  required Future<CodemagicCallResult<T>> Function() invoke,
}) async {
  if (codemagicInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final m = <String, Object>{
    'rpc.system': 'codemagic',
    'rpc.method': operation,
    'codemagic.operation': operation,
  };

  final span = _tracer().startSpan(
    'codemagic $operation',
    kind: SpanKind.client,
    attributes: OTelAPI.attributesFromMap(m),
  );
  try {
    final r = await invoke();
    if (r.result != null) {
      final res = r.result!;
      final extras = <Attribute<Object>>[];
      if (res.appId != null) {
        extras.add(OTelAPI.attributeString('codemagic.app.id', res.appId!));
      }
      if (res.workflowId != null) {
        extras.add(OTelAPI.attributeString(
          'codemagic.workflow.id',
          res.workflowId!,
        ));
      }
      if (res.workflowName != null) {
        extras.add(OTelAPI.attributeString(
          'codemagic.workflow.name',
          res.workflowName!,
        ));
      }
      if (res.buildId != null) {
        extras.add(OTelAPI.attributeString('codemagic.build.id', res.buildId!));
      }
      if (res.buildNumber != null) {
        extras.add(OTelAPI.attributeInt(
          'codemagic.build.number',
          res.buildNumber!,
        ));
      }
      if (res.branch != null) {
        extras.add(OTelAPI.attributeString('codemagic.branch', res.branch!));
      }
      if (res.tag != null) {
        extras.add(OTelAPI.attributeString('codemagic.tag', res.tag!));
      }
      if (res.commit != null) {
        extras.add(OTelAPI.attributeString('codemagic.commit', res.commit!));
      }
      if (res.instanceType != null) {
        extras.add(OTelAPI.attributeString(
          'codemagic.instance.type',
          res.instanceType!,
        ));
      }
      if (res.platform != null) {
        extras
            .add(OTelAPI.attributeString('codemagic.platform', res.platform!));
      }
      if (res.status != null) {
        extras.add(OTelAPI.attributeString('codemagic.status', res.status!));
        if (res.status == 'failed' || res.status == 'timeout') {
          span.setStatus(
            SpanStatusCode.Error,
            'Codemagic build ${res.status}',
          );
        }
      }
      if (res.durationSec != null) {
        extras.add(OTelAPI.attributeInt(
          'codemagic.duration_sec',
          res.durationSec!,
        ));
      }
      if (res.creditsUsed != null) {
        extras.add(OTelAPI.attributeInt(
          'codemagic.credits.used',
          res.creditsUsed!,
        ));
      }
      if (res.publishingTargets != null) {
        extras.add(OTelAPI.attributeStringList(
          'codemagic.publishing.targets',
          res.publishingTargets!,
        ));
      }
      if (res.testCount != null) {
        extras.add(OTelAPI.attributeInt(
          'codemagic.test.count',
          res.testCount!,
        ));
      }
      if (res.testFailedCount != null) {
        extras.add(OTelAPI.attributeInt(
          'codemagic.test.failed_count',
          res.testFailedCount!,
        ));
        if (res.testFailedCount! > 0) {
          span.setStatus(
            SpanStatusCode.Error,
            'Codemagic ${res.testFailedCount} test(s) failed',
          );
        }
      }
      if (res.codeSigningProvider != null) {
        extras.add(OTelAPI.attributeString(
          'codemagic.code_signing.provider',
          res.codeSigningProvider!,
        ));
      }
      if (res.cachePullSec != null) {
        extras.add(OTelAPI.attributeInt(
          'codemagic.cache.pull_sec',
          res.cachePullSec!,
        ));
      }
      if (res.cachePushSec != null) {
        extras.add(OTelAPI.attributeInt(
          'codemagic.cache.push_sec',
          res.cachePushSec!,
        ));
      }
      if (res.rateLimitRemaining != null) {
        extras.add(OTelAPI.attributeInt(
          'codemagic.rate_limit.remaining',
          res.rateLimitRemaining!,
        ));
      }
      if (res.errorCode != null) {
        extras.add(OTelAPI.attributeString(
          'codemagic.error.code',
          res.errorCode!,
        ));
        span.setStatus(SpanStatusCode.Error, 'Codemagic ${res.errorCode}');
      }
      if (res.statusCode != null) {
        extras.add(OTelAPI.attributeInt(
          'http.response.status_code',
          res.statusCode!,
        ));
        if (res.statusCode! >= 400) {
          span.setStatus(
            SpanStatusCode.Error,
            'Codemagic HTTP ${res.statusCode}',
          );
        }
      }
      if (extras.isNotEmpty) span.addAttributes(OTelAPI.attributes(extras));
    }
    return r.value;
  } catch (e, st) {
    span.addAttributes(OTelAPI.attributes([
      OTelAPI.attributeString(
        ErrorAttributes.errorType.key,
        e.runtimeType.toString(),
      ),
    ]));
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
