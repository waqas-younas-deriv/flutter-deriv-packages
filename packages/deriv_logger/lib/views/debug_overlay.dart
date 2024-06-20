import 'package:deriv_logger/controllers/logger_controller.dart';
import 'package:deriv_logger/views/console_log_view.dart';
import 'package:deriv_logger/views/debug_button.dart';
import 'package:deriv_logger/views/logger_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// DebugOverlay
class DebugOverlay extends StatefulWidget {
  /// Overlay UI
  const DebugOverlay({
    required this.builder,
    super.key,
    this.icon = const Icon(Icons.bug_report_outlined),
    this.enabled = kDebugMode,
  });

  /// Widget that is displayed at DebugOverlay action header.
  final Widget icon;

  /// Should return your application widget for which DebugOverlay is applied.
  final WidgetBuilder builder;

  /// When this field is [true] - debug overlay is running in your app.
  /// By default, this field get value from const [kDebugMode].
  final bool enabled;

  @override
  State<DebugOverlay> createState() => _DebugOverlayState();
}

class _DebugOverlayState extends State<DebugOverlay> {
  final ConsoleLogController consoleLogsController = ConsoleLogController();

  @override
  void initState() {
    super.initState();

    if (widget.enabled) {
      WidgetsBinding.instance.addPostFrameCallback(
          (Duration timeStamp) => _insertOverlay(context));
    }

    consoleLogsController.initialize();
  }

  @override
  Widget build(BuildContext context) => widget.builder.call(context);

  void _insertOverlay(BuildContext context) {
    const DebugOverlayTheme theme = DebugOverlayTheme();

    return Overlay.of(context).insert(
      OverlayEntry(
        builder: (BuildContext context) => DebugOverlayButton(
          theme: theme,
          onTap: () => _onButtonTap(context, theme),
          child: widget.icon,
        ),
      ),
    );
  }

  void _onButtonTap(BuildContext context, DebugOverlayTheme theme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (BuildContext ctx) => FractionallySizedBox(
        heightFactor: 0.9,
        child: ConsoleLogsView(
          theme: theme,
          consoleLogsController: consoleLogsController,
        ),
      ),
    );
  }
}