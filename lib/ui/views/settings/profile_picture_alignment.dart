import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:goipvc/providers/settings_provider.dart';
import 'package:goipvc/ui/widgets/profile_picture.dart';

import '../../../models/myipvc/user.dart';
import '../../../providers/profile_provider.dart';

class _PopUpNotifier extends StateNotifier<bool> {
  _PopUpNotifier() : super(false);

  void set(bool val) {
    state = val;
  }
}

final _popUpProvider = StateNotifierProvider<_PopUpNotifier, bool>(
        (ref) => _PopUpNotifier()
);

class ProfilePictureAlignmentSettings<T> extends ConsumerWidget {
  const ProfilePictureAlignmentSettings({super.key});

  void _showAppearanceMenu(BuildContext context, WidgetRef ref) {
    MyIPVCUser? profile = ref.watch(profileProvider);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Alinhamento de foto"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if(profile != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
                  child: ProfilePicture(imageData: profile.fotografia, size: 96)
                ),
              
              DropdownMenu<String>(
                dropdownMenuEntries: <DropdownMenuEntry<String>>[
                  for(var alignment in ref.read(settingsProvider.notifier).getAlignmentMapKeys())
                    DropdownMenuEntry<String>(
                      value: alignment,
                      label: alignment,
                    ),
                ],
                initialSelection: ref.read(settingsProvider).pictureAlignment,
                label: const Text("Alinhamento"),
                onSelected: (String? alignment) {
                  ref.read(settingsProvider.notifier)
                      .setPictureAlignment(alignment ?? "center");
                },
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(_popUpProvider);
    ref.watch(settingsProvider);

    return Wrap(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 2, 0, 2),
          child: Builder(
            builder: (BuildContext context) {
              return Text(
                "Perfil",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Theme.of(context).colorScheme.primary,
                ),
              );
            },
          ),
        ),
        ListTile(
          leading: const Icon(Icons.account_circle),
          title: const Text("Alinhamento da foto"),
          onTap: () {
            _showAppearanceMenu(context, ref);
          },
          trailing: Text(ref.read(settingsProvider.notifier).getAlignmentString()),
        )
      ],
    );
  }
}