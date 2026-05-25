import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_ui.dart';
import '../../../core/design.dart';
import '../../../domain/repositories/photos_repository.dart';
import '../../state/app_refresh.dart';

class PhotosScreen extends ConsumerStatefulWidget {
  const PhotosScreen({super.key});

  @override
  ConsumerState<PhotosScreen> createState() => _PhotosScreenState();
}

class _PhotosScreenState extends ConsumerState<PhotosScreen>
    with AutomaticKeepAliveClientMixin<PhotosScreen> {
  late String todayKey;
  String? _pendingTodayKey;

  late final Map<int, ValueNotifier<String?>> selectedPhotoNotifiers;

  List<dynamic> savedPhotos = const [];
  bool completed = false;
  String? loadErrorText;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    todayKey = ref.read(currentDayKeyProvider);

    selectedPhotoNotifiers = {
      1: ValueNotifier<String?>(null),
      2: ValueNotifier<String?>(null),
      3: ValueNotifier<String?>(null),
      4: ValueNotifier<String?>(null),
    };

    _loadExistingPhotosSilently(todayKey);
  }

  @override
  void dispose() {
    for (final notifier in selectedPhotoNotifiers.values) {
      notifier.dispose();
    }
    super.dispose();
  }

  Future<void> _loadExistingPhotosSilently([String? dayKey]) async {
    final requestedDayKey = dayKey ?? todayKey;

    try {
      final photos = await ref
          .read(photosRepositoryProvider)
          .photosForDay(requestedDayKey);

      if (!mounted || requestedDayKey != todayKey) return;

      setState(() {
        savedPhotos = photos;
        completed = photos.map((e) => e.slot).toSet().length == 4;
        loadErrorText = null;
      });
    } catch (e) {
      if (!mounted || requestedDayKey != todayKey) return;

      setState(() {
        loadErrorText = e.toString();
      });
    }
  }

  Future<void> _pickForSlot(int slot) async {
    try {
      final file = await ref.read(photosRepositoryProvider).pickJpeg();
      if (file == null) return;

      selectedPhotoNotifiers[slot]!.value = file.path;
    } catch (e) {
      if (!mounted) return;
      showAppSnackBar(context, e.toString());
    }
  }

  bool _allPhotosSelected() {
    return selectedPhotoNotifiers.values.every((notifier) {
      final path = notifier.value;
      return path != null && path.isNotEmpty && File(path).existsSync();
    });
  }

  Map<int, String> _selectedPhotosMap() {
    return {
      for (final entry in selectedPhotoNotifiers.entries)
        if (entry.value.value != null) entry.key: entry.value.value!,
    };
  }

  void _clearSelectedPhotos() {
    for (final notifier in selectedPhotoNotifiers.values) {
      notifier.value = null;
    }
  }

  void _handleTodayChanged(String nextDayKey) {
    if (!mounted) return;
    if (nextDayKey == todayKey) {
      _pendingTodayKey = null;
      return;
    }

    _clearSelectedPhotos();

    setState(() {
      todayKey = nextDayKey;
      _pendingTodayKey = null;
      savedPhotos = const [];
      completed = false;
      loadErrorText = null;
    });

    _loadExistingPhotosSilently(todayKey);
  }

  void _scheduleTodayChangeIfNeeded(String nextDayKey) {
    if (nextDayKey == todayKey || nextDayKey == _pendingTodayKey) return;

    _pendingTodayKey = nextDayKey;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleTodayChanged(nextDayKey);
    });
  }

  Future<void> _savePhotos() async {
    if (!_allPhotosSelected()) return;

    try {
      await ref.read(photosRepositoryProvider).savePhotosForDay(
            dayKey: todayKey,
            slotToLocalPath: _selectedPhotosMap(),
          );

      final photos =
          await ref.read(photosRepositoryProvider).photosForDay(todayKey);

      if (!mounted) return;

      _clearSelectedPhotos();

      setState(() {
        savedPhotos = photos;
        completed = photos.map((e) => e.slot).toSet().length == 4;
        loadErrorText = null;
      });

      notifyAppDataChanged(ref);
      showAppSnackBar(context, 'Фото сохранены');
    } catch (e) {
      if (!mounted) return;
      showAppSnackBar(context, e.toString());
    }
  }

  String _slotLabel(int slot) {
    switch (slot) {
      case 1:
        return 'Спереди';
      case 2:
        return 'Сзади';
      case 3:
        return 'Левый бок';
      case 4:
        return 'Правый бок';
      default:
        return 'Фото $slot';
    }
  }

  String _slotHint(int slot) {
    switch (slot) {
      case 1:
        return 'Фото тела в полный рост спереди';
      case 2:
        return 'Фото тела в полный рост сзади';
      case 3:
        return 'Повернитесь левым боком';
      case 4:
        return 'Повернитесь правым боком';
      default:
        return 'Выберите фото';
    }
  }

  String _slotAsset(int slot) {
    switch (slot) {
      case 1:
        return 'assets/images/photo_front.png';
      case 2:
        return 'assets/images/photo_back.png';
      case 3:
        return 'assets/images/photo_left.png';
      case 4:
        return 'assets/images/photo_right.png';
      default:
        return 'assets/images/photo_front.png';
    }
  }

  String _ruDateFromDayKey(String dayKey) {
    final parts = dayKey.split('-');
    if (parts.length != 3) return dayKey;
    return '${parts[2]}.${parts[1]}.${parts[0]}';
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final currentTodayKey = ref.watch(currentDayKeyProvider);
    _scheduleTodayChangeIfNeeded(currentTodayKey);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Фото'),
        actions: const [
          ScreenHelpAction(
            title: 'Фото прогресса',
            message:
                'На этом экране можно один раз в день добавить 4 фото прогресса: спереди, сзади, левый бок и правый бок. '
                'Нажмите на нужную область, выберите изображение JPG или JPEG из памяти телефона и заполните все 4 позиции. '
                'Фото показываются в ячейках формата 3:4 без долгой обработки при сохранении. '
                'После сохранения фото за этот день изменить нельзя, следующий набор можно добавить завтра.',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: completed
            ? _SavedPhotosContent(
                photos: savedPhotos,
                dayText: _ruDateFromDayKey(todayKey),
                slotLabel: _slotLabel,
              )
            : _AddPhotosContent(
                dayText: _ruDateFromDayKey(todayKey),
                loadErrorText: loadErrorText,
                selectedPhotoNotifiers: selectedPhotoNotifiers,
                slotLabel: _slotLabel,
                slotHint: _slotHint,
                slotAsset: _slotAsset,
                onPickForSlot: _pickForSlot,
                allPhotosSelected: _allPhotosSelected,
                onSave: _savePhotos,
              ),
      ),
    );
  }
}

class _SavedPhotosContent extends StatelessWidget {
  const _SavedPhotosContent({
    required this.photos,
    required this.dayText,
    required this.slotLabel,
  });

  final List<dynamic> photos;
  final String dayText;
  final String Function(int slot) slotLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PhotosHeaderCard(
          title: 'Фото за сегодня сохранены',
          subtitle: dayText,
          icon: Icons.check_circle_outline,
        ),
        const SizedBox(height: AppSpacing.lg),
        Expanded(
          child: GridView.builder(
            itemCount: 4,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              childAspectRatio: 3 / 4,
            ),
            itemBuilder: (context, index) {
              final slot = index + 1;
              final photo = photos.firstWhere(
                (e) => e.slot == slot,
              );

              return _SavedPhotoSlotCell(
                slot: slot,
                label: slotLabel(slot),
                localPath: photo.localPath as String,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AddPhotosContent extends StatelessWidget {
  const _AddPhotosContent({
    required this.dayText,
    required this.loadErrorText,
    required this.selectedPhotoNotifiers,
    required this.slotLabel,
    required this.slotHint,
    required this.slotAsset,
    required this.onPickForSlot,
    required this.allPhotosSelected,
    required this.onSave,
  });

  final String dayText;
  final String? loadErrorText;
  final Map<int, ValueNotifier<String?>> selectedPhotoNotifiers;
  final String Function(int slot) slotLabel;
  final String Function(int slot) slotHint;
  final String Function(int slot) slotAsset;
  final Future<void> Function(int slot) onPickForSlot;
  final bool Function() allPhotosSelected;
  final Future<void> Function() onSave;

  int _selectedCount() {
    var count = 0;
    for (final notifier in selectedPhotoNotifiers.values) {
      final path = notifier.value;
      if (path != null && path.isNotEmpty && File(path).existsSync()) {
        count++;
      }
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(selectedPhotoNotifiers.values.toList()),
      builder: (context, _) {
        final selectedCount = _selectedCount();
        final canSave = allPhotosSelected();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _PhotosHeaderCard(
                title: 'Фото прогресса за сегодня',
                subtitle: dayText,
                icon: Icons.photo_camera_outlined),
            const SizedBox(height: AppSpacing.md),
            _PhotoSelectionProgress(selectedCount: selectedCount),
            if (loadErrorText != null) ...[
              const SizedBox(height: AppSpacing.md),
              _ErrorBanner(text: loadErrorText!),
            ],
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: GridView.builder(
                itemCount: 4,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisSpacing: AppSpacing.md,
                  childAspectRatio: 3 / 4,
                ),
                itemBuilder: (context, index) {
                  final slot = index + 1;

                  return _EditablePhotoSlotCell(
                    slot: slot,
                    label: slotLabel(slot),
                    hint: slotHint(slot),
                    assetPath: slotAsset(slot),
                    pathNotifier: selectedPhotoNotifiers[slot]!,
                    onTap: () => onPickForSlot(slot),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AnimatedScale(
              duration: const Duration(milliseconds: 180),
              scale: canSave ? 1.0 : 0.98,
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: canSave ? onSave : null,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Сохранить фото'),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PhotosHeaderCard extends StatelessWidget {
  const _PhotosHeaderCard({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.primaryContainer.withValues(alpha: 0.94),
            colors.secondaryContainer.withValues(alpha: 0.86),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: colors.surface.withValues(alpha: 0.72),
            foregroundColor: colors.primary,
            child: Icon(icon),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onPrimaryContainer.withValues(alpha: 0.76),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoSelectionProgress extends StatelessWidget {
  const _PhotoSelectionProgress({required this.selectedCount});

  final int selectedCount;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final progress = selectedCount / 4.0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border:
            Border.all(color: colors.outlineVariant.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  selectedCount == 4
                      ? 'Все фото выбраны'
                      : 'Выбрано $selectedCount из 4 фото',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: colors.surfaceContainerHighest,
              color: selectedCount == 4 ? colors.primary : colors.tertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.errorContainer.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Text(
        'Ошибка загрузки фото: $text',
        style: TextStyle(color: colors.onErrorContainer),
      ),
    );
  }
}

class _SavedPhotoSlotCell extends StatelessWidget {
  const _SavedPhotoSlotCell({
    required this.slot,
    required this.label,
    required this.localPath,
  });

  final int slot;
  final String label;
  final String localPath;

  @override
  Widget build(BuildContext context) {
    final file = File(localPath);

    return _PhotoSlotFrame(
      slot: slot,
      label: label,
      completed: file.existsSync(),
      child: file.existsSync()
          ? Image.file(
              file,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            )
          : Center(child: Text('Фото $slot')),
    );
  }
}

class _EditablePhotoSlotCell extends StatelessWidget {
  const _EditablePhotoSlotCell({
    required this.slot,
    required this.label,
    required this.hint,
    required this.assetPath,
    required this.pathNotifier,
    required this.onTap,
  });

  final int slot;
  final String label;
  final String hint;
  final String assetPath;
  final ValueNotifier<String?> pathNotifier;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: pathNotifier,
      builder: (context, path, _) {
        final file = path == null ? null : File(path);
        final hasPhoto = file != null && file.existsSync();

        return AnimatedScale(
          duration: const Duration(milliseconds: 180),
          scale: hasPhoto ? 1.0 : 0.985,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: _PhotoSlotFrame(
              slot: slot,
              label: label,
              completed: hasPhoto,
              child: hasPhoto
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(
                          file,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                        const Positioned(
                          right: AppSpacing.sm,
                          top: AppSpacing.sm,
                          child: _PhotoCheckBadge(),
                        ),
                      ],
                    )
                  : _EmptyPhotoSlotContent(
                      label: label,
                      hint: hint,
                      assetPath: assetPath,
                    ),
            ),
          ),
        );
      },
    );
  }
}

class _PhotoSlotFrame extends StatelessWidget {
  const _PhotoSlotFrame({
    required this.slot,
    required this.label,
    required this.completed,
    required this.child,
  });

  final int slot;
  final String label;
  final bool completed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                color: colors.surface.withValues(alpha: 0.82),
                border: Border.all(
                  color: completed
                      ? colors.primary.withValues(alpha: 0.42)
                      : colors.outlineVariant.withValues(alpha: 0.7),
                ),
              ),
              child: child,
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.64),
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.white.withValues(alpha: 0.88),
                      child: Text(
                        '$slot',
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyPhotoSlotContent extends StatelessWidget {
  const _EmptyPhotoSlotContent({
    required this.label,
    required this.hint,
    required this.assetPath,
  });

  final String label;
  final String hint;
  final String assetPath;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.primaryContainer.withValues(alpha: 0.22),
            colors.primaryContainer.withValues(alpha: 0.38),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Center(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: colors.primaryContainer.withValues(alpha: 0.28),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: colors.primary.withValues(alpha: 0.14),
              ),
            ),
            child: Opacity(
              opacity: 0.82,
              child: Image.asset(
                assetPath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.image_not_supported_outlined,
                    size: 58,
                    color: colors.primary.withValues(alpha: 0.68),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PhotoCheckBadge extends StatelessWidget {
  const _PhotoCheckBadge();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.primary,
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.18),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const Icon(
        Icons.check_rounded,
        color: Colors.white,
        size: 21,
      ),
    );
  }
}
