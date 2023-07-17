import 'package:flutter/material.dart';

class BottomSheetModal extends StatelessWidget {
  final Widget appbar;
  final Widget child;
  final bool shrink;

  const BottomSheetModal({
    super.key,
    this.shrink = false,
    required this.child,
    required this.appbar,
  });

  Future<T?> show<T>(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (BuildContext context) => BottomSheetModal(
        appbar: appbar,
        shrink: shrink,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  top: 24,
                  right: 16,
                ),
                child: appbar,
              ),
              Flexible(
                fit: shrink ? FlexFit.loose : FlexFit.tight,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  physics: const ClampingScrollPhysics(),
                  child: child,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class BottomSheetNavigationBar extends StatelessWidget {
  final String? title;
  final String? trailing;
  final GestureTapCallback? onClose;

  const BottomSheetNavigationBar({
    super.key,
    this.title,
    this.trailing,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (title != null)
          Text(
            title!,
            style: const TextStyle(fontSize: 18),
          ),
        if (trailing != null)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                if (onClose != null) {
                  onClose!();
                }
                Navigator.maybePop(context);
              },
              child: Text(
                trailing!,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
      ],
    );
  }
}
