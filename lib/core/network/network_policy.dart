import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

enum NetworkType {
  wifi,
  cellular,
  offline,
}

enum DataSaverMode {
  saving,      // Opus/AAC ~48kbps, LRU cache, minimal prefetch, small thumbnails (~22MB/h)
  balanced,    // Medium bitrate (~128kbps)
  highQuality, // Opus ~160kbps / AAC 128kbps, full prefetch (~58MB/h)
  superSaver,  // Extreme: Opus 48kbps, NO image downloads, NO prefetch, strict buffer (<20MB/h)
}

/// Network policy controller managing connectivity status, data saver profiles, and threshold caps
class NetworkPolicy extends ChangeNotifier {
  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  NetworkType _currentNetwork = NetworkType.wifi;
  bool _isMetered = false;

  // Preferences
  DataSaverMode _cellularMode = DataSaverMode.saving;
  DataSaverMode _wifiMode = DataSaverMode.highQuality;
  bool _wifiOnlyForSync = true;
  bool _wifiOnlyForPrefetch = true;
  bool _superSaverEnabled = false;
  int _monthlyDataCapMb = 500;
  bool _autoSuperSaverOnCap = true;
  int _currentMonthCellularBytes = 0;

  NetworkPolicy({
    Connectivity? connectivity,
    NetworkType initialNetwork = NetworkType.wifi,
    bool isMetered = false,
    bool autoListen = true,
  })  : _connectivity = connectivity ?? Connectivity(),
        _currentNetwork = initialNetwork,
        _isMetered = isMetered {
    if (autoListen) {
      _initConnectivity();
    }
  }

  // --- Getters ---
  NetworkType get currentNetwork => _currentNetwork;
  bool get isMetered => _isMetered;
  bool get isCellular => _currentNetwork == NetworkType.cellular || _isMetered;
  bool get isWifi => _currentNetwork == NetworkType.wifi && !_isMetered;
  bool get isOffline => _currentNetwork == NetworkType.offline;

  DataSaverMode get cellularMode => _cellularMode;
  DataSaverMode get wifiMode => _wifiMode;
  bool get wifiOnlyForSync => _wifiOnlyForSync;
  bool get wifiOnlyForPrefetch => _wifiOnlyForPrefetch;
  bool get superSaverEnabled => _superSaverEnabled;
  int get monthlyDataCapMb => _monthlyDataCapMb;
  bool get autoSuperSaverOnCap => _autoSuperSaverOnCap;
  int get currentMonthCellularBytes => _currentMonthCellularBytes;

  /// Check if monthly cellular usage exceeded the cap
  bool get isCapExceeded {
    if (_monthlyDataCapMb <= 0) return false;
    final capBytes = _monthlyDataCapMb * 1024 * 1024;
    return _currentMonthCellularBytes >= capBytes;
  }

  /// Calculate the effective mode right now
  DataSaverMode get effectiveMode {
    if (_superSaverEnabled) return DataSaverMode.superSaver;
    if (isCellular && _autoSuperSaverOnCap && isCapExceeded) {
      return DataSaverMode.superSaver;
    }
    if (isCellular) {
      return _cellularMode;
    }
    if (isWifi) {
      return _wifiMode;
    }
    return DataSaverMode.saving;
  }

  /// Whether StreamResolver should pick lowest bitrate (~48kbps opus/aac)
  bool get shouldPreferLowBitrate =>
      effectiveMode == DataSaverMode.saving || effectiveMode == DataSaverMode.superSaver;

  /// Whether image thumbnails should be fetched or blocked (spec 7.5)
  bool get shouldLoadThumbnails => effectiveMode != DataSaverMode.superSaver;

  /// Whether next tracks in queue should be prefetched
  bool get shouldPrefetch {
    if (effectiveMode == DataSaverMode.superSaver) return false;
    if (isCellular && _wifiOnlyForPrefetch) return false;
    if (isOffline) return false;
    return true;
  }

  /// Whether background / auto sync is permitted on current connection
  bool get shouldAllowSync {
    if (isOffline) return false;
    if (isCellular && _wifiOnlyForSync) return false;
    return true;
  }

  /// Initialize connectivity listener
  void _initConnectivity() {
    _connectivitySub = _connectivity.onConnectivityChanged.listen((results) {
      _updateFromResults(results);
    });
  }

  void _updateFromResults(List<ConnectivityResult> results) {
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      _currentNetwork = NetworkType.offline;
    } else if (results.contains(ConnectivityResult.mobile)) {
      _currentNetwork = NetworkType.cellular;
    } else if (results.contains(ConnectivityResult.wifi)) {
      _currentNetwork = NetworkType.wifi;
    } else {
      _currentNetwork = NetworkType.wifi;
    }
    notifyListeners();
  }

  // --- Configuration Mutators ---

  void setNetworkForTesting(NetworkType type, {bool isMetered = false}) {
    _currentNetwork = type;
    _isMetered = isMetered;
    notifyListeners();
  }

  void setCellularMode(DataSaverMode mode) {
    _cellularMode = mode;
    notifyListeners();
  }

  void setWifiMode(DataSaverMode mode) {
    _wifiMode = mode;
    notifyListeners();
  }

  void setWifiOnlyForSync(bool value) {
    _wifiOnlyForSync = value;
    notifyListeners();
  }

  void setWifiOnlyForPrefetch(bool value) {
    _wifiOnlyForPrefetch = value;
    notifyListeners();
  }

  void setSuperSaverEnabled(bool value) {
    _superSaverEnabled = value;
    notifyListeners();
  }

  void setMonthlyDataCapMb(int mb) {
    _monthlyDataCapMb = mb;
    notifyListeners();
  }

  void setAutoSuperSaverOnCap(bool value) {
    _autoSuperSaverOnCap = value;
    notifyListeners();
  }

  void updateCurrentMonthCellularBytes(int bytes) {
    _currentMonthCellularBytes = bytes;
    notifyListeners();
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    super.dispose();
  }
}
