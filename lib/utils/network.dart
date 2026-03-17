import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

// ---------------------------------------------------------------------------
// Exceptions
// ---------------------------------------------------------------------------

/// Free-tier limit reached (402)
class LimitReachedException implements Exception {
  final String message;
  const LimitReachedException(this.message);

  @override
  String toString() => message;
}

/// Feature requires Pro subscription
class ProRequiredException implements Exception {
  final String message;
  const ProRequiredException(this.message);

  @override
  String toString() => message;
}

/// No internet connection
class NoConnectionException implements Exception {
  const NoConnectionException();

  @override
  String toString() => 'No internet connection';
}

/// Server error (5xx) after retries exhausted
class ServerException implements Exception {
  final int statusCode;
  final String body;
  const ServerException(this.statusCode, this.body);

  @override
  String toString() => 'Server error ($statusCode)';
}

// ---------------------------------------------------------------------------
// Connectivity check
// ---------------------------------------------------------------------------

/// Quick connectivity check — tries to reach a DNS server.
/// Returns false if device is fully offline.
Future<bool> hasConnectivity() async {
  try {
    final result = await InternetAddress.lookup('google.com')
        .timeout(const Duration(seconds: 3));
    return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  } on SocketException {
    return false;
  } on TimeoutException {
    return false;
  }
}

// ---------------------------------------------------------------------------
// Retry wrapper for HTTP calls
// ---------------------------------------------------------------------------

/// Wraps an HTTP call with retry logic for transient (5xx) failures.
///
/// - [maxRetries]: number of retries after the first attempt (default 2)
/// - [initialDelay]: base delay before first retry (doubles each attempt)
/// - Non-retryable status codes (4xx) throw immediately.
/// - 402 → [LimitReachedException]
/// - 403 with "pro" in body → [ProRequiredException]
Future<http.Response> httpWithRetry(
  Future<http.Response> Function() request, {
  int maxRetries = 2,
  Duration initialDelay = const Duration(milliseconds: 500),
}) async {
  // Check connectivity first
  if (!await hasConnectivity()) {
    throw const NoConnectionException();
  }

  late http.Response response;
  var delay = initialDelay;

  for (var attempt = 0; attempt <= maxRetries; attempt++) {
    try {
      response = await request().timeout(const Duration(seconds: 30));
    } on SocketException {
      throw const NoConnectionException();
    } on TimeoutException {
      if (attempt == maxRetries) {
        throw const ServerException(408, 'Request timed out');
      }
      await Future.delayed(delay);
      delay *= 2;
      continue;
    }

    // Success
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    }

    // Client errors — don't retry
    if (response.statusCode == 402) {
      throw LimitReachedException(
        'Free tier limit reached',
      );
    }
    if (response.statusCode == 403) {
      if (response.body.toLowerCase().contains('pro')) {
        throw const ProRequiredException('This feature requires Pro');
      }
      throw Exception('Forbidden: ${response.body}');
    }
    if (response.statusCode >= 400 && response.statusCode < 500) {
      throw Exception('Request failed (${response.statusCode}): ${response.body}');
    }

    // Server errors — retry
    if (response.statusCode >= 500) {
      if (attempt == maxRetries) {
        throw ServerException(response.statusCode, response.body);
      }
      debugPrint(
        'Server error ${response.statusCode}, retrying in ${delay.inMilliseconds}ms...',
      );
      await Future.delayed(delay);
      delay *= 2;
    }
  }

  return response;
}
