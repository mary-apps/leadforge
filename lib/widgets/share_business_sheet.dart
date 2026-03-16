import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../models/business.dart';

class ShareBusinessSheet extends StatelessWidget {
  final Business business;

  const ShareBusinessSheet({super.key, required this.business});

  static Future<void> show(BuildContext context, Business business) {
    return showCupertinoModalPopup(
      context: context,
      builder: (context) => ShareBusinessSheet(business: business),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoActionSheet(
      title: Text('Share ${business.name}'),
      message: const Text('Choose how to share this lead'),
      actions: [
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
            _copyBusinessText(context);
          },
          child: const Text('Copy Business Info'),
        ),
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
            _shareViaSystem(context);
          },
          child: const Text('Share via...'),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        isDefaultAction: true,
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
    );
  }

  void _copyBusinessText(BuildContext context) {
    Clipboard.setData(ClipboardData(text: _formatBusinessText()));
  }

  void _shareViaSystem(BuildContext context) {
    Share.share(_formatBusinessText(), subject: business.name);
  }

  String _formatBusinessText() {
    final buf = StringBuffer();
    buf.writeln(business.name);
    if (business.address != null) buf.writeln(business.address);
    if (business.phone != null) buf.writeln(business.phone);
    if (business.website != null) buf.writeln(business.website);
    if (business.auditScore != null) buf.writeln('Score: ${business.auditScore}');
    return buf.toString();
  }
}
