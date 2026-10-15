import 'dart:convert';
import 'package:dio/dio.dart';
import 'data_meter.dart';

/// Dio Interceptor that measures HTTP request and response sizes and records them to DataMeter
class DataMeterInterceptor extends Interceptor {
  final DataMeter dataMeter;

  DataMeterInterceptor({required this.dataMeter});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    int requestBytes = 0;
    try {
      if (options.data != null) {
        if (options.data is String) {
          requestBytes = utf8.encode(options.data as String).length;
        } else if (options.data is Map || options.data is List) {
          requestBytes = utf8.encode(jsonEncode(options.data)).length;
        } else if (options.data is List<int>) {
          requestBytes = (options.data as List<int>).length;
        }
      }
    } catch (_) {
      // Ignore estimation errors
    }

    if (requestBytes > 0) {
      dataMeter.recordUsage(kind: 'api', bytes: requestBytes);
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    int responseBytes = 0;
    try {
      final contentLength = response.headers.value(Headers.contentLengthHeader);
      if (contentLength != null && int.tryParse(contentLength) != null) {
        responseBytes = int.parse(contentLength);
      } else if (response.data != null) {
        if (response.data is String) {
          responseBytes = utf8.encode(response.data as String).length;
        } else if (response.data is Map || response.data is List) {
          responseBytes = utf8.encode(jsonEncode(response.data)).length;
        } else if (response.data is List<int>) {
          responseBytes = (response.data as List<int>).length;
        }
      }
    } catch (_) {
      // Ignore estimation errors
    }

    if (responseBytes > 0) {
      dataMeter.recordUsage(kind: 'api', bytes: responseBytes);
    }

    handler.next(response);
  }
}
