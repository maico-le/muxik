import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/pixel_theme.dart';
import '../../core/widgets/pixel_widgets.dart';
import '../../core/widgets/pixel_dialog.dart';
import '../../core/providers/auth_providers.dart';
import '../../core/providers/network_providers.dart';
import '../../core/network/network_policy.dart';
import '../../core/network/data_meter.dart';
import '../auth/account_switcher_sheet.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.pixelTheme;
    final activeAccountAsync = ref.watch(activeAccountProvider);
    final networkPolicy = ref.watch(networkPolicyProvider);
    final cacheManager = ref.watch(audioCacheManagerProvider);
    final historyAsync = ref.watch(dailyUsageHistoryProvider);
    final cacheBytesAsync = ref.watch(totalCacheSizeBytesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SETTINGS'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. Account Management Card
          PixelCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TÀI KHOẢN (ACCOUNT)',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                        color: theme.primary,
                      ),
                    ),
                    activeAccountAsync.when(
                      data: (acc) => acc != null
                          ? GestureDetector(
                              onTap: () => AccountSwitcherSheet.show(context),
                              child: Text(
                                'QUẢN LÝ',
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                  color: theme.amber,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                activeAccountAsync.when(
                  data: (account) {
                    if (account != null) {
                      return Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  account.name,
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: theme.textPrimary,
                                  ),
                                ),
                                Text(
                                  account.email,
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 11,
                                    color: theme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PixelButton(
                            isSmall: true,
                            onPressed: () => context.push('/login'),
                            child: const Text('CHI TIẾT'),
                          ),
                        ],
                      );
                    }
                    return Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Chưa đăng nhập (Khách)',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                              color: theme.textSecondary,
                            ),
                          ),
                        ),
                        PixelButton(
                          isSmall: true,
                          isPrimary: true,
                          onPressed: () => context.push('/login'),
                          child: const Text('ĐĂNG NHẬP'),
                        ),
                      ],
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Text(
                    'Error: $err',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      color: theme.accentRed,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 2. Data Meter & Real Usage Card (Core Requirement)
          PixelCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ĐỒNG HỒ ĐO LƯU LƯỢNG (DATA METER)',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: theme.primary,
                      ),
                    ),
                    // Network Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: networkPolicy.isOffline
                            ? theme.textSecondary
                            : networkPolicy.isCellular
                                ? theme.primary
                                : theme.amber,
                        border: Border.all(color: theme.border, width: 1),
                      ),
                      child: Text(
                        networkPolicy.isOffline
                            ? 'OFFLINE'
                            : networkPolicy.isCellular
                                ? '4G/5G'
                                : 'WI-FI',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Active Mode
                Row(
                  children: [
                    Text(
                      'Chế độ đang áp dụng: ',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: theme.textSecondary,
                      ),
                    ),
                    Text(
                      _modeLabel(networkPolicy.effectiveMode),
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: networkPolicy.effectiveMode == DataSaverMode.superSaver
                            ? theme.primary
                            : theme.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Monthly Cellular Usage vs Cap Bar
                Builder(
                  builder: (context) {
                    final capBytes = networkPolicy.monthlyDataCapMb * 1024 * 1024;
                    final usedBytes = networkPolicy.currentMonthCellularBytes;
                    final progress = capBytes > 0 ? (usedBytes / capBytes).clamp(0.0, 1.0) : 0.0;
                    final percent = (progress * 100).toStringAsFixed(1);
                    final isOver = networkPolicy.isCapExceeded;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Hạn mức di động tháng:',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 11,
                                color: theme.textSecondary,
                              ),
                            ),
                            Text(
                              '${formatBytes(usedBytes)} / ${networkPolicy.monthlyDataCapMb} MB ($percent%)',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isOver ? theme.accentRed : theme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        PixelProgressBar(
                          value: progress,
                          height: 10,
                          segments: 20,
                          barColor: isOver ? theme.accentRed : theme.primary,
                        ),
                        if (isOver) ...[
                          const SizedBox(height: 4),
                          Text(
                            '⚠️ Đã vượt hạn mức! Chế độ Siêu Tiết Kiệm đã tự động kích hoạt.',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: theme.accentRed,
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),

                // 7-Day Pixel Bar Chart
                Text(
                  'LƯU LƯỢNG 7 NGÀY GẦN NHẤT:',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: theme.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                historyAsync.when(
                  data: (history) => _buildPixelBarChart(context, history),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 3. Data Saver Policies Card
          PixelCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CHÍNH SÁCH TIẾT KIỆM (DATA POLICIES)',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                    color: theme.primary,
                  ),
                ),
                const SizedBox(height: 12),

                // Super Saver Switch
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Chế độ Siêu Tiết Kiệm',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: theme.textPrimary,
                            ),
                          ),
                          Text(
                            'Tắt tải ảnh bìa, ép opus 48kbps, tắt prefetch (<20MB/giờ)',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 10,
                              color: theme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    PixelSwitch(
                      value: networkPolicy.superSaverEnabled,
                      onChanged: (val) => networkPolicy.setSuperSaverEnabled(val),
                    ),
                  ],
                ),
                const Divider(height: 20),

                // Cellular Quality Selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Chất lượng trên 4G/5G:',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: theme.textPrimary,
                      ),
                    ),
                    DropdownButton<DataSaverMode>(
                      value: networkPolicy.cellularMode,
                      isDense: true,
                      underline: const SizedBox.shrink(),
                      items: const [
                        DropdownMenuItem(
                          value: DataSaverMode.saving,
                          child: Text('Tiết kiệm (~48kbps)', style: TextStyle(fontFamily: 'monospace', fontSize: 11)),
                        ),
                        DropdownMenuItem(
                          value: DataSaverMode.balanced,
                          child: Text('Cân bằng (~128kbps)', style: TextStyle(fontFamily: 'monospace', fontSize: 11)),
                        ),
                        DropdownMenuItem(
                          value: DataSaverMode.highQuality,
                          child: Text('Chất lượng (~160kbps)', style: TextStyle(fontFamily: 'monospace', fontSize: 11)),
                        ),
                      ],
                      onChanged: (mode) {
                        if (mode != null) networkPolicy.setCellularMode(mode);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Wi-Fi Quality Selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Chất lượng trên Wi-Fi:',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: theme.textPrimary,
                      ),
                    ),
                    DropdownButton<DataSaverMode>(
                      value: networkPolicy.wifiMode,
                      isDense: true,
                      underline: const SizedBox.shrink(),
                      items: const [
                        DropdownMenuItem(
                          value: DataSaverMode.highQuality,
                          child: Text('Chất lượng cao (~160kbps)', style: TextStyle(fontFamily: 'monospace', fontSize: 11)),
                        ),
                        DropdownMenuItem(
                          value: DataSaverMode.balanced,
                          child: Text('Cân bằng (~128kbps)', style: TextStyle(fontFamily: 'monospace', fontSize: 11)),
                        ),
                        DropdownMenuItem(
                          value: DataSaverMode.saving,
                          child: Text('Tiết kiệm (~48kbps)', style: TextStyle(fontFamily: 'monospace', fontSize: 11)),
                        ),
                      ],
                      onChanged: (mode) {
                        if (mode != null) networkPolicy.setWifiMode(mode);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Monthly Cap Selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Hạn mức 4G/5G tháng:',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: theme.textPrimary,
                      ),
                    ),
                    DropdownButton<int>(
                      value: networkPolicy.monthlyDataCapMb,
                      isDense: true,
                      underline: const SizedBox.shrink(),
                      items: const [
                        DropdownMenuItem(value: 100, child: Text('100 MB', style: TextStyle(fontFamily: 'monospace', fontSize: 11))),
                        DropdownMenuItem(value: 250, child: Text('250 MB', style: TextStyle(fontFamily: 'monospace', fontSize: 11))),
                        DropdownMenuItem(value: 500, child: Text('500 MB', style: TextStyle(fontFamily: 'monospace', fontSize: 11))),
                        DropdownMenuItem(value: 1000, child: Text('1 GB', style: TextStyle(fontFamily: 'monospace', fontSize: 11))),
                        DropdownMenuItem(value: 2000, child: Text('2 GB', style: TextStyle(fontFamily: 'monospace', fontSize: 11))),
                        DropdownMenuItem(value: 5000, child: Text('5 GB', style: TextStyle(fontFamily: 'monospace', fontSize: 11))),
                      ],
                      onChanged: (mb) {
                        if (mb != null) networkPolicy.setMonthlyDataCapMb(mb);
                      },
                    ),
                  ],
                ),
                const Divider(height: 20),

                // Auto Super Saver on Cap Switch
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Tự động hạ Siêu Tiết Kiệm khi chạm ngưỡng',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          color: theme.textPrimary,
                        ),
                      ),
                    ),
                    PixelSwitch(
                      value: networkPolicy.autoSuperSaverOnCap,
                      onChanged: (val) => networkPolicy.setAutoSuperSaverOnCap(val),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Wi-Fi Only for Sync Switch
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Chỉ Wi-Fi cho Sync & Đồng bộ',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          color: theme.textPrimary,
                        ),
                      ),
                    ),
                    PixelSwitch(
                      value: networkPolicy.wifiOnlyForSync,
                      onChanged: (val) => networkPolicy.setWifiOnlyForSync(val),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Wi-Fi Only for Prefetch Switch
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Chỉ Wi-Fi cho Prefetch bài kế',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          color: theme.textPrimary,
                        ),
                      ),
                    ),
                    PixelSwitch(
                      value: networkPolicy.wifiOnlyForPrefetch,
                      onChanged: (val) => networkPolicy.setWifiOnlyForPrefetch(val),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 4. Audio Cache (LRU) Card
          PixelCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'BỘ NHỚ ĐỆM ÂM THANH (LRU CACHE)',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                        color: theme.primary,
                      ),
                    ),
                    DropdownButton<int>(
                      value: cacheManager.maxCacheMb,
                      isDense: true,
                      underline: const SizedBox.shrink(),
                      items: const [
                        DropdownMenuItem(value: 100, child: Text('100 MB', style: TextStyle(fontFamily: 'monospace', fontSize: 11))),
                        DropdownMenuItem(value: 250, child: Text('250 MB', style: TextStyle(fontFamily: 'monospace', fontSize: 11))),
                        DropdownMenuItem(value: 500, child: Text('500 MB', style: TextStyle(fontFamily: 'monospace', fontSize: 11))),
                        DropdownMenuItem(value: 1000, child: Text('1 GB', style: TextStyle(fontFamily: 'monospace', fontSize: 11))),
                        DropdownMenuItem(value: 2000, child: Text('2 GB', style: TextStyle(fontFamily: 'monospace', fontSize: 11))),
                      ],
                      onChanged: (mb) {
                        if (mb != null) cacheManager.setMaxCacheMb(mb);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Bài hát đã nghe sẽ được lưu trên đĩa. Nghe lại lần sau tiêu thụ 0 byte mạng.',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    color: theme.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                cacheBytesAsync.when(
                  data: (used) {
                    final maxBytes = cacheManager.maxCacheBytes;
                    final progress = maxBytes > 0 ? (used / maxBytes).clamp(0.0, 1.0) : 0.0;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Đã dùng:',
                              style: TextStyle(fontFamily: 'monospace', fontSize: 11, color: theme.textSecondary),
                            ),
                            Text(
                              '${formatBytes(used)} / ${cacheManager.maxCacheMb} MB',
                              style: TextStyle(fontFamily: 'monospace', fontSize: 11, fontWeight: FontWeight.bold, color: theme.textPrimary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        PixelProgressBar(
                          value: progress,
                          height: 10,
                          segments: 20,
                          barColor: theme.amber,
                        ),
                      ],
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 12),
                PixelButton(
                  isSmall: true,
                  onPressed: () async {
                    final confirm = await PixelDialog.showConfirmation(
                      context: context,
                      title: 'XOÁ CACHE',
                      message: 'Bạn có chắc muốn xoá toàn bộ bộ nhớ đệm bài hát? Các bài hát sẽ cần tải lại từ mạng.',
                      confirmText: 'XOÁ NGAY',
                    );
                    if (confirm == true) {
                      await cacheManager.clearCache();
                      ref.invalidate(totalCacheSizeBytesProvider);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đã xoá sạch bộ nhớ đệm âm thanh!')),
                        );
                      }
                    }
                  },
                  child: const Text('XOÁ BỘ NHỚ ĐỆM (CLEAR CACHE)'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 5. Background Playback & Battery Optimization Card (Spec 9)
          PixelCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BACKGROUND PLAYBACK',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                    color: theme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Music keeps playing when your screen is locked or while using other apps.',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: theme.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  color: theme.amber.withValues(alpha: 0.15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BATTERY OPTIMIZATION NOTICE',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          color: theme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Some manufacturers (Xiaomi, Samsung, Oppo, Huawei) aggressively terminate background services. To ensure non-stop background audio, disable battery optimization for Muxik in your Android system settings.',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 10,
                          color: theme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _modeLabel(DataSaverMode mode) {
    switch (mode) {
      case DataSaverMode.saving:
        return 'Tiết kiệm (~48kbps)';
      case DataSaverMode.balanced:
        return 'Cân bằng (~128kbps)';
      case DataSaverMode.highQuality:
        return 'Chất lượng (~160kbps)';
      case DataSaverMode.superSaver:
        return 'SIÊU TIẾT KIỆM (<20MB/h)';
    }
  }

  Widget _buildPixelBarChart(BuildContext context, List<DailyUsageSummary> history) {
    final theme = context.pixelTheme;
    if (history.isEmpty) return const SizedBox.shrink();

    // Find max bytes for chart scale
    int maxDaily = history.fold<int>(0, (max, h) => h.totalBytes > max ? h.totalBytes : max);
    if (maxDaily == 0) maxDaily = 1024 * 1024; // Default scale 1MB

    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: theme.surface,
        border: Border.all(color: theme.border, width: theme.borderWidth),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: history.map((day) {
          final cellRatio = (day.cellBytes / maxDaily).clamp(0.0, 1.0);
          final wifiRatio = (day.wifiBytes / maxDaily).clamp(0.0, 1.0);
          final dayLabel = '${day.day.day}/${day.day.month}';

          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (wifiRatio > 0)
                          Container(
                            width: 12,
                            height: (wifiRatio * 50).clamp(2.0, 50.0),
                            color: theme.amber,
                          ),
                        if (cellRatio > 0)
                          Container(
                            width: 12,
                            height: (cellRatio * 50).clamp(2.0, 50.0),
                            color: theme.primary,
                          ),
                        if (cellRatio == 0 && wifiRatio == 0)
                          Container(
                            width: 12,
                            height: 2,
                            color: theme.textSecondary.withValues(alpha: 0.3),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dayLabel,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 8,
                    color: theme.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
