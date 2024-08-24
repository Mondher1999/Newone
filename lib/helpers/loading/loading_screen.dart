import 'dart:async';
import 'package:flutter/material.dart';

class LoadingScreenManager {
  static final LoadingScreenManager _instance =
      LoadingScreenManager._internal();
  LoadingScreenManager._internal();
  factory LoadingScreenManager() => _instance;

  LoadingScreenController? _controller;

  void show({
    required BuildContext context,
    required String text,
  }) {
    // If there is an existing controller and it successfully updates, do nothing more.
    if (_controller?.update(text) ?? false) {
      return;
    }
    // Otherwise, create a new controller and show a new overlay.
    _controller = _showOverlay(
      context: context,
      text: text,
    );
  }

  void hide() {
    _controller?.close();
    _controller = null;
  }

  LoadingScreenController _showOverlay({
    required BuildContext context,
    required String text,
  }) {
    final textStreamController = StreamController<String>();
    textStreamController.add(text);

    final overlayState = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    final overlayEntry = OverlayEntry(
      builder: (context) => Material(
        color: Colors.black.withAlpha(150),
        child: Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: size.width * 0.8,
              maxHeight: size.height * 0.8,
              minWidth: size.width * 0.5,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.0),
            ),
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  StreamBuilder<String>(
                    stream: textStreamController.stream,
                    builder: (context, snapshot) {
                      return Text(
                        snapshot.data ?? "",
                        textAlign: TextAlign.center,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlayState?.insert(overlayEntry);

    return LoadingScreenController(
      close: () {
        textStreamController.close();
        overlayEntry.remove();
        return true;
      },
      update: (updatedText) {
        textStreamController.add(updatedText);
        return true;
      },
    );
  }
}

class LoadingScreenController {
  final bool Function() close;
  final bool Function(String text) update;

  LoadingScreenController({
    required this.close,
    required this.update,
  });
}
