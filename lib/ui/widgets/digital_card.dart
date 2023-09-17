import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myipvc_budget_flutter/models/myipvc_card.dart';

import 'digital_card_container.dart';

class DigitalCard extends ConsumerWidget {
  final MyIPVCCard data;

  const DigitalCard({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int selectedSide = ref.watch(cardSideProvider);
    Uint8List bytesFront = base64.decode(data.front);
    Uint8List bytesBack = base64.decode(data.back);

    // TODO: Stop card containing this image from flickering
    // when the side is changed

    return ClipRRect(
      borderRadius: BorderRadius.circular(10.0),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: Image.memory(
          selectedSide == 0 ? bytesFront : bytesBack,
          key: ValueKey<bool>(selectedSide == 0),
        ),
      )
    );
  }
}