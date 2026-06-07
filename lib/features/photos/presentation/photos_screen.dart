import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shapeup/core/shared/errors.dart';

import 'package:shapeup/core/design/ui.dart';
import 'package:shapeup/core/design/theme.dart';
import 'package:shapeup/core/shared/today_scheduler.dart';
import 'package:shapeup/presentation/providers/app_providers.dart'
    as app_providers;
import 'package:shapeup/core/shared/photo_labels.dart';
import 'package:shapeup/features/photos/presentation/widgets/add_photos_widget.dart';
import 'package:shapeup/features/photos/presentation/widgets/saved_photos_widget.dart';
import 'package:shapeup/features/photos/domain/entities/progress_photo_entity.dart';
import 'package:shapeup/features/photos/providers/photos_provider.dart';

class PhotosScreen extends ConsumerStatefulWidget {
  const PhotosScreen({super.key});

  @override
  ConsumerState<PhotosScreen> createState() => _PhotosScreenState();
}

class _PhotosScreenState extends ConsumerState<PhotosScreen>
    with
        AutomaticKeepAliveClientMixin<PhotosScreen>,
        TodayChangeScheduler<PhotosScreen> {
  late String todayKey;

  late final Map<int, ValueNotifier<String?>> selectedPhotoNotifiers;

  List<ProgressPhotoEntity> savedPhotos = const [];
  bool completed = false;
  String? loadErrorText;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    todayKey = ref.read(app_providers.currentDayKeyProvider);

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
          .read(photosControllerProvider)
          .photosForDay(requestedDayKey);

      if (!mounted || requestedDayKey != todayKey) return;

      setState(() {
        savedPhotos = photos;
        completed = ref.read(photosControllerProvider).dayIsCompleted(photos);
        loadErrorText = null;
      });
    } catch (e) {
      if (!mounted || requestedDayKey != todayKey) return;

      setState(() {
        loadErrorText = russianErrorMessage(e);
      });
    }
  }

  Future<void> _pickForSlot(int slot) async {
    try {
      final path = await ref.read(photosControllerProvider).pickJpegPath();
      if (path == null) return;

      selectedPhotoNotifiers[slot]!.value = path;
    } catch (e) {
      if (!mounted) return;
      showAppSnackBar(context, russianErrorMessage(e));
    }
  }

  Map<int, String?> _selectedPhotoPaths() {
    return {
      for (final entry in selectedPhotoNotifiers.entries)
        entry.key: entry.value.value,
    };
  }

  bool _pathExists(String path) {
    return File(path).existsSync();
  }

  bool _allPhotosSelected() {
    return ref.read(photosControllerProvider).allPhotosSelected(
          _selectedPhotoPaths(),
          pathExists: _pathExists,
        );
  }

  Map<int, String> _selectedPhotosMap() {
    return ref
        .read(photosControllerProvider)
        .selectedPhotosMap(_selectedPhotoPaths());
  }

  void _clearSelectedPhotos() {
    for (final notifier in selectedPhotoNotifiers.values) {
      notifier.value = null;
    }
  }

  void _handleTodayChanged(String nextDayKey) {
    if (!mounted || nextDayKey == todayKey) return;

    _clearSelectedPhotos();

    setState(() {
      todayKey = nextDayKey;
      savedPhotos = const [];
      completed = false;
      loadErrorText = null;
    });

    _loadExistingPhotosSilently(todayKey);
  }

  Future<void> _savePhotos() async {
    if (!_allPhotosSelected()) return;

    try {
      final photos = await ref.read(photosControllerProvider).savePhotosForDay(
            dayKey: todayKey,
            slotToLocalPath: _selectedPhotosMap(),
          );

      if (!mounted) return;

      _clearSelectedPhotos();

      setState(() {
        savedPhotos = photos;
        completed = ref.read(photosControllerProvider).dayIsCompleted(photos);
        loadErrorText = null;
      });

      app_providers.notifyAppDataChanged(ref);
      showAppSnackBar(context, photoSavedMessage);
    } catch (e) {
      if (!mounted) return;
      showAppSnackBar(context, russianErrorMessage(e));
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

    final currentTodayKey = ref.watch(app_providers.currentDayKeyProvider);
    scheduleTodayChangeIfNeeded(
      currentTodayKey: todayKey,
      nextTodayKey: currentTodayKey,
      onTodayChanged: _handleTodayChanged,
    );
    int selectedCount() {
      return ref.read(photosControllerProvider).selectedCount(
            _selectedPhotoPaths(),
            pathExists: _pathExists,
          );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Фото'),
        actions: const [
          ScreenHelpAction(
            title: 'Фото прогресса',
            message:
                'На этом экране можно один раз в день добавить 4 фото тела: спереди, сзади, левый бок и правый бок. '
                'Для сохранения предоставьте разрешение доступа к галерее. '
                'Нажмите на нужную область, выберите изображение формата jpg или jpeg из памяти телефона и заполните все 4 позиции. '
                'Фото показываются в ячейках формата 3:4.\n\n'
                'Выбирайте фото, где фигура находится на одинаковом расстоянии до камеры. Для сохранения позиции рекомендуется ставить ноги по краям листа А4.\n\n'
                'При сохранении Вы соглашаетесь с хранением фото в локальной базе данных на телефоне. '
                'После сохранения фото за этот день изменить нельзя, следующий набор можно добавить завтра.',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: completed
            ? SavedPhotosWidget(
                photos: savedPhotos,
                dayText: _ruDateFromDayKey(todayKey),
                slotLabel: photoSlotLabel,
                requiredPhotoCount:
                    ref.read(photosControllerProvider).requiredPhotoCount,
              )
            : AddPhotosWidget(
                dayText: _ruDateFromDayKey(todayKey),
                loadErrorText: loadErrorText,
                selectedPhotoNotifiers: selectedPhotoNotifiers,
                slotLabel: photoSlotLabel,
                slotHint: _slotHint,
                slotAsset: _slotAsset,
                onPickForSlot: _pickForSlot,
                allPhotosSelected: _allPhotosSelected,
                onSave: _savePhotos,
                requiredPhotoCount:
                    ref.read(photosControllerProvider).requiredPhotoCount,
                selectedCount: selectedCount,
              ),
      ),
    );
  }
}
