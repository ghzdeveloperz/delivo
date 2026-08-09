import 'dart:async';

import 'package:flutter/services.dart';
import 'package:photo_manager/photo_manager.dart';

abstract interface class GalleryChangeObserver {
  Stream<void> get changes;

  Future<void> start();

  Future<void> stop();
}

final class PhotoManagerGalleryChangeObserver implements GalleryChangeObserver {
  PhotoManagerGalleryChangeObserver();

  final StreamController<void> _controller = StreamController<void>.broadcast();

  bool _started = false;

  @override
  Stream<void> get changes => _controller.stream;

  @override
  Future<void> start() async {
    if (_started) {
      return;
    }

    PhotoManager.addChangeCallback(_onChange);
    await PhotoManager.startChangeNotify();

    _started = true;
  }

  @override
  Future<void> stop() async {
    if (!_started) {
      return;
    }

    PhotoManager.removeChangeCallback(_onChange);
    await PhotoManager.stopChangeNotify();

    _started = false;
  }

  void _onChange(MethodCall _) {
    if (!_controller.isClosed) {
      _controller.add(null);
    }
  }

  Future<void> dispose() async {
    await stop();
    await _controller.close();
  }
}
