import 'package:flutter/material.dart';

import 'opc_guide_screen.dart';

const _opcHelpRaspberry = Color(0xFFC2185B);

String predmetGuideChapterIdForSegment(int segmentNumber) =>
    switch (segmentNumber) {
      1 => 'predmet.preminulo_lice',
      2 => 'predmet.cinjenice_o_smrti',
      3 => 'predmet.statusi',
      4 => 'predmet.platilac',
      5 => 'predmet.ceremonija',
      6 => 'predmet.parte',
      7 => 'predmet.roba_i_usluge',
      8 => 'predmet.finansije',
      9 => 'predmet.dokumenti',
      10 => 'predmet.pregled_i_potvrda',
      _ => 'predmet',
    };

class OpcHelpButton extends StatelessWidget {
  const OpcHelpButton({
    super.key,
    required this.chapterId,
    this.tooltip = 'POMOĆ',
  });

  final String chapterId;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: tooltip,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              key: Key('opc-help-button-$chapterId'),
              customBorder: const CircleBorder(),
              onTap: () => openOpcGuide(context, chapterId: chapterId),
              child: Center(
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: _opcHelpRaspberry,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.help_outline,
                    size: 19,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class OpcHelpTitle extends StatelessWidget {
  const OpcHelpTitle({super.key, required this.title, required this.chapterId});

  final Widget title;
  final String chapterId;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      OpcHelpButton(chapterId: chapterId),
      const SizedBox(width: 4),
      Expanded(child: title),
    ],
  );
}

Future<void> openOpcGuide(BuildContext context, {required String chapterId}) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      fullscreenDialog: false,
      builder: (_) => OpcGuideScreen(initialChapterId: chapterId),
    ),
  );
}
