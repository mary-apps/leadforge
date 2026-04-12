import 'package:flutter/widgets.dart';

enum FormFactor { compact, medium, expanded }

FormFactor formFactorOf(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  if (width < 600) return FormFactor.compact;
  if (width < 1024) return FormFactor.medium;
  return FormFactor.expanded;
}

bool isCompact(BuildContext context) => formFactorOf(context) == FormFactor.compact;
bool isExpanded(BuildContext context) => formFactorOf(context) == FormFactor.expanded;
