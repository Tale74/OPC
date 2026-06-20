import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


/// Reusable PIN unos widget — fiksno 4 cifre, numerička tastatura na ekranu.
/// Podržava i unos sa fizičke tastature (cifre + backspace + Enter).
/// POTVRDI dugme se pojavljuje (AnimatedSize) kada korisnik unese sve 4 cifre.
class PinInputWidget extends StatefulWidget {
  const PinInputWidget({
    super.key,
    required this.onPinComplete,
    this.errorText,
    this.label = 'Unesite PIN',
  });

  final void Function(String pin) onPinComplete;
  final String? errorText;
  final String label;

  @override
  State<PinInputWidget> createState() => PinInputWidgetState();
}

class PinInputWidgetState extends State<PinInputWidget> {
  static const int _duzinaPin = 4;

  /// Mapa logičkih tastera cifara (red + numpad) → string cifre.
  /// static final (ne const) jer LogicalKeyboardKey overriduje == i hashCode.
  static final _digitMap = <LogicalKeyboardKey, String>{
    LogicalKeyboardKey.digit0: '0',
    LogicalKeyboardKey.digit1: '1',
    LogicalKeyboardKey.digit2: '2',
    LogicalKeyboardKey.digit3: '3',
    LogicalKeyboardKey.digit4: '4',
    LogicalKeyboardKey.digit5: '5',
    LogicalKeyboardKey.digit6: '6',
    LogicalKeyboardKey.digit7: '7',
    LogicalKeyboardKey.digit8: '8',
    LogicalKeyboardKey.digit9: '9',
    LogicalKeyboardKey.numpad0: '0',
    LogicalKeyboardKey.numpad1: '1',
    LogicalKeyboardKey.numpad2: '2',
    LogicalKeyboardKey.numpad3: '3',
    LogicalKeyboardKey.numpad4: '4',
    LogicalKeyboardKey.numpad5: '5',
    LogicalKeyboardKey.numpad6: '6',
    LogicalKeyboardKey.numpad7: '7',
    LogicalKeyboardKey.numpad8: '8',
    LogicalKeyboardKey.numpad9: '9',
  };

  String _pin = '';
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Automatski zatraži fokus da tastatura odmah radi
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void ocisti() => setState(() => _pin = '');

  void _dodaj(String cifra) {
    if (_pin.length >= _duzinaPin) return;
    setState(() => _pin += cifra);
  }

  void _brisi() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  void _potvrdi() {
    if (_pin.length < _duzinaPin) return;
    final pin = _pin;
    setState(() => _pin = '');
    widget.onPinComplete(pin);
  }

  void _onKey(KeyEvent event) {
    if (event is! KeyDownEvent) return;
    final cifra = _digitMap[event.logicalKey];
    if (cifra != null) {
      _dodaj(cifra);
    } else if (event.logicalKey == LogicalKeyboardKey.backspace) {
      _brisi();
    } else if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.numpadEnter) {
      if (_pin.length == _duzinaPin) _potvrdi();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pinPun = _pin.length == _duzinaPin;

    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: _onKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.label,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),
          _PinDots(pin: _pin, duzinaPin: _duzinaPin),
          if (widget.errorText != null) ...[
            const SizedBox(height: 8),
            Text(
              widget.errorText!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          // POTVRDI — pojavljuje se samo kada je PIN popunjen (ne zauzima prostor)
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: pinPun
                ? Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: FilledButton.icon(
                      onPressed: _potvrdi,
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 8,
                        ),
                        child: Text(
                          'POTVRDI',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox(height: 16),
          ),
          const SizedBox(height: 8),
          _NumericKeypad(onDigit: _dodaj, onDelete: _brisi),
        ],
      ),
    );
  }
}

class _PinDots extends StatelessWidget {
  const _PinDots({required this.pin, required this.duzinaPin});

  final String pin;
  final int duzinaPin;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(duzinaPin, (i) {
        final filled = i < pin.length;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 10),
          width: filled ? 20 : 18,
          height: filled ? 20 : 18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? color : Colors.transparent,
            border: Border.all(color: color, width: 2),
          ),
        );
      }),
    );
  }
}

class _NumericKeypad extends StatelessWidget {
  const _NumericKeypad({required this.onDigit, required this.onDelete});

  final void Function(String) onDigit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final row in [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
          ['', '0', 'DEL'],
        ])
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.map((c) {
              if (c.isEmpty) return const SizedBox(width: 72, height: 52);
              if (c == 'DEL') {
                return _KeyButton(
                  onTap: onDelete,
                  child: const Icon(Icons.backspace_outlined, size: 20),
                );
              }
              return _KeyButton(
                onTap: () => onDigit(c),
                child: Text(
                  c,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}

class _KeyButton extends StatelessWidget {
  const _KeyButton({required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Material(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(36),
        child: InkWell(
          borderRadius: BorderRadius.circular(36),
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          child: SizedBox(
            width: 60,
            height: 60,
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}
