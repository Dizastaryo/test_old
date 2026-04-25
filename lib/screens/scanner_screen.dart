import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../core/design/design.dart';
import '../models/ble_device_model.dart';
import '../services/account_session.dart';
import '../services/user_resolver.dart';
import '../widgets/account_switcher_button.dart';
import '../widgets/device_card.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with TickerProviderStateMixin {
  final Map<String, BleDeviceModel> _devicesMap = {};
  StreamSubscription<List<ScanResult>>? _scanSub;
  StreamSubscription<bool>? _isScanSub;
  bool _isScanning = false;
  bool _bluetoothOn = true;
  late AnimationController _pulseController;
  late AnimationController _radarController;

  late UserResolver _resolver;
  final _session = AccountSession.instance;

  @override
  void initState() {
    super.initState();
    _resolver = UserResolver(_session);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _isScanSub = FlutterBluePlus.isScanning.listen((scanning) {
      if (mounted) setState(() => _isScanning = scanning);
      if (scanning) {
        _pulseController.repeat(reverse: true);
        _radarController.repeat();
      } else {
        _pulseController.stop();
        _radarController.stop();
      }
    });

    FlutterBluePlus.adapterState.listen((state) {
      if (mounted) {
        setState(() => _bluetoothOn = state == BluetoothAdapterState.on);
      }
    });

    _session.addListener(_onSessionChanged);
  }

  void _onSessionChanged() {
    // Пересчитываем резолв при смене аккаунта (без ре-скана)
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _session.removeListener(_onSessionChanged);
    _scanSub?.cancel();
    _isScanSub?.cancel();
    _pulseController.dispose();
    _radarController.dispose();
    FlutterBluePlus.stopScan();
    super.dispose();
  }

  /// Сортировка: me/myChipOff → friend → knownPublic → strangerPrivate → unknown.
  /// Фильтр: скрываем чужие OFF-чипы (unknown с mode=0xFF и hasValidPacket).
  List<_ResolvedEntry> get _sortedDevices {
    final entries = <_ResolvedEntry>[];

    for (final d in _devicesMap.values) {
      final resolved = _resolver.resolve(d);

      // Скрыть чужие выключенные чипы
      if (resolved.relationship == Relationship.unknown &&
          resolved.hasValidPacket &&
          resolved.mode == 0xFF) {
        continue;
      }

      entries.add(_ResolvedEntry(device: d, resolved: resolved));
    }

    entries.sort((a, b) {
      final orderCmp = _resolver.sortOrder(a.resolved.relationship)
          .compareTo(_resolver.sortOrder(b.resolved.relationship));
      if (orderCmp != 0) return orderCmp;
      return b.device.rssi.compareTo(a.device.rssi);
    });

    return entries;
  }

  Future<void> _startScan() async {
    _devicesMap.clear();
    setState(() {});

    _scanSub?.cancel();
    _scanSub = FlutterBluePlus.onScanResults.listen((results) {
      for (final r in results) {
        if (r.advertisementData.advName != 'ESP32C3_TAG') continue;
        final device = BleDeviceModel.fromScanResult(r);
        _devicesMap[device.macAddress] = device;
      }
      if (mounted) setState(() {});
    });

    await FlutterBluePlus.startScan(
      continuousUpdates: true,
      removeIfGone: const Duration(seconds: 5),
    );
  }

  Future<void> _stopScan() async {
    await FlutterBluePlus.stopScan();
  }

  void _toggleScan() {
    if (_isScanning) {
      _stopScan();
    } else {
      _startScan();
    }
  }

  String _deviceWord(int count) {
    if (count % 10 == 1 && count % 100 != 11) {
      return 'устройство';
    }
    if (count % 10 >= 2 && count % 10 <= 4 &&
        (count % 100 < 10 || count % 100 >= 20)) {
      return 'устройства';
    }
    return 'устройств';
  }

  @override
  Widget build(BuildContext context) {
    final entries = _sortedDevices;

    return Scaffold(
      backgroundColor: SeeUColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildHeader(entries.length),
          if (!_bluetoothOn)
            SliverToBoxAdapter(child: _buildBluetoothOffBanner()),
          if (entries.isEmpty)
            SliverFillRemaining(child: _buildEmptyState())
          else ...[
            SliverToBoxAdapter(child: _buildStatsBar(entries)),
            SliverPadding(
              padding: const EdgeInsets.only(top: 4, bottom: 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => DeviceCard(
                    device: entries[index].device,
                    resolved: entries[index].resolved,
                  ),
                  childCount: entries.length,
                ),
              ),
            ),
          ],
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 100),
        child: _buildFab(),
      ),
    );
  }

  Widget _buildHeader(int count) {
    return SliverAppBar(
      expandedHeight: 160,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: SeeUColors.background,
      surfaceTintColor: Colors.transparent,
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 16, top: 8),
          child: AccountSwitcherButton(),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'SeeU',
                      style: GoogleFonts.fraunces(
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -1,
                        color: SeeUColors.textPrimary,
                      ),
                    ),
                    if (_isScanning) ...[
                      const SizedBox(width: 10),
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, _) => Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: SeeUColors.accent.withValues(
                              alpha: 0.4 + _pulseController.value * 0.6,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: SeeUColors.accent
                                    .withValues(alpha: _pulseController.value * 0.5),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  _isScanning
                      ? 'ПОИСК · $count ${_deviceWord(count)}'
                      : 'НАЙДИ СВОИХ',
                  style: SeeUTypography.micro.copyWith(
                    color: SeeUColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 1),
                ListenableBuilder(
                  listenable: _session,
                  builder: (context, _) => Text(
                    'Я: ${_session.currentUser.name}',
                    style: SeeUTypography.micro.copyWith(
                      color: SeeUColors.textTertiary.withValues(alpha: 0.6),
                      fontSize: 9,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsBar(List<_ResolvedEntry> entries) {
    final friends = entries.where(
      (e) => e.resolved.relationship == Relationship.friend,
    ).length;
    final known = entries.where(
      (e) => e.resolved.relationship == Relationship.knownPublic,
    ).length;
    final other = entries.where(
      (e) =>
          e.resolved.relationship == Relationship.strangerPrivate ||
          e.resolved.relationship == Relationship.unknown,
    ).length;

    // Найти свой чип для 4-й ячейки
    final myChipEntry = entries.cast<_ResolvedEntry?>().firstWhere(
      (e) => e!.resolved.isMyChip,
      orElse: () => null,
    );

    String? myChipLabel;
    if (myChipEntry != null) {
      final mode = myChipEntry.resolved.mode;
      if (mode == 0x00) {
        myChipLabel = 'общий';
      } else if (mode == 0x01) {
        myChipLabel = 'приватный';
      } else {
        myChipLabel = 'молчит';
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _statCard('ДРУЗЬЯ', friends, const Color(0xFF5DCAA5)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _statCard('ЗНАКОМЫЕ', known, const Color(0xFF85B7EB)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _statCard('ПРОЧИЕ', other, const Color(0xFFCECBF6)),
              ),
            ],
          ),
          if (myChipLabel != null) ...[
            const SizedBox(height: 8),
            _myChipCard(myChipLabel),
          ],
        ],
      ),
    );
  }

  Widget _statCard(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SeeUColors.surfaceElevated,
        borderRadius: BorderRadius.circular(SeeURadii.card),
        boxShadow: SeeUShadows.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$count',
                style: SeeUTypography.displayL.copyWith(color: SeeUColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: SeeUTypography.micro.copyWith(color: SeeUColors.textTertiary),
          ),
        ],
      ),
    );
  }

  Widget _myChipCard(String modeLabel) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: SeeUColors.surfaceElevated,
        borderRadius: BorderRadius.circular(SeeURadii.card),
        boxShadow: SeeUShadows.sm,
      ),
      child: Row(
        children: [
          Icon(
            PhosphorIcons.cpu(PhosphorIconsStyle.fill),
            size: 16,
            color: SeeUColors.accent,
          ),
          const SizedBox(width: 8),
          Text(
            'МОЙ ЧИП',
            style: SeeUTypography.micro.copyWith(color: SeeUColors.textTertiary),
          ),
          const Spacer(),
          Text(
            modeLabel.toUpperCase(),
            style: SeeUTypography.micro.copyWith(
              color: SeeUColors.accent,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBluetoothOffBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SeeUColors.accentSoft,
        borderRadius: BorderRadius.circular(SeeURadii.card),
        border: Border.all(color: SeeUColors.accent.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: SeeUColors.accent.withValues(alpha: 0.15),
            ),
            child: Icon(
              PhosphorIcons.heartBreak(PhosphorIconsStyle.fill),
              color: SeeUColors.accent,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bluetooth выключен',
                  style: SeeUTypography.subtitle.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Включите Bluetooth для поиска людей рядом',
                  style: SeeUTypography.caption.copyWith(
                    color: SeeUColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _radarController,
            builder: (context, child) {
              return SizedBox(
                width: 160,
                height: 160,
                child: CustomPaint(
                  painter: _RadarPainter(
                    progress: _isScanning ? _radarController.value : 0,
                    isActive: _isScanning,
                    color: SeeUColors.accent,
                  ),
                  child: Center(
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isScanning
                            ? SeeUColors.accent.withValues(alpha: 0.15)
                            : SeeUColors.borderSubtle,
                      ),
                      child: Icon(
                        PhosphorIcons.heartbeat(PhosphorIconsStyle.fill),
                        size: 30,
                        color: _isScanning
                            ? SeeUColors.accent
                            : SeeUColors.textTertiary,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          Text(
            _isScanning ? 'Ищем людей рядом...' : 'Никого рядом',
            style: GoogleFonts.fraunces(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: SeeUColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isScanning
                ? 'Пользователи SeeU появятся здесь'
                : 'Нажмите кнопку поиска',
            style: SeeUTypography.body.copyWith(
              color: SeeUColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFab() {
    return GestureDetector(
      onTap: _bluetoothOn ? _toggleScan : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        decoration: BoxDecoration(
          color: _isScanning ? SeeUColors.like : SeeUColors.accent,
          borderRadius: BorderRadius.circular(SeeURadii.pill),
          boxShadow: SeeUShadows.lg,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isScanning
                  ? PhosphorIcons.stop(PhosphorIconsStyle.fill)
                  : PhosphorIcons.play(PhosphorIconsStyle.fill),
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              _isScanning ? 'Стоп' : 'Поиск',
              style: SeeUTypography.subtitle.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResolvedEntry {
  final BleDeviceModel device;
  final ResolvedDevice resolved;
  const _ResolvedEntry({required this.device, required this.resolved});
}

class _RadarPainter extends CustomPainter {
  final double progress;
  final bool isActive;
  final Color color;

  _RadarPainter({
    required this.progress,
    required this.isActive,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    for (var i = 1; i <= 3; i++) {
      double ringProgress;
      if (isActive) {
        ringProgress = (progress + i * 0.33) % 1.0;
      } else {
        ringProgress = i / 3.0;
      }

      final radius = maxRadius * (0.3 + ringProgress * 0.7);
      final alpha = isActive
          ? (1.0 - ringProgress) * 0.25
          : 0.06;
      final paint = Paint()
        ..color = color.withValues(alpha: alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = isActive ? 2.0 * (1.0 - ringProgress) + 0.5 : 1.0;
      canvas.drawCircle(center, radius, paint);
    }

    if (isActive) {
      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.08 + progress * 0.04)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, maxRadius * 0.35, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) =>
      progress != oldDelegate.progress || isActive != oldDelegate.isActive;
}
