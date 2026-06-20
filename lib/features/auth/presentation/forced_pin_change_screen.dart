import 'package:flutter/material.dart';

import '../data/auth_repository.dart';
import '../domain/session_service.dart';
import 'pin_input_widget.dart';

class ForcedPinChangeScreen extends StatefulWidget {
  const ForcedPinChangeScreen({
    super.key,
    required this.authRepo,
    required this.session,
    required this.onCompleted,
  });

  final AuthRepository authRepo;
  final SessionService session;
  final VoidCallback onCompleted;

  @override
  State<ForcedPinChangeScreen> createState() => _ForcedPinChangeScreenState();
}

class _ForcedPinChangeScreenState extends State<ForcedPinChangeScreen> {
  int _korak = 1;
  String _noviPin = '';
  String? _greska;
  bool _snimam = false;

  void _unesiNoviPin(String pin) {
    if (pin.isEmpty) {
      setState(() => _greska = 'Novi PIN je obavezan.');
      return;
    }

    setState(() {
      _noviPin = pin;
      _korak = 2;
      _greska = null;
    });
  }

  Future<void> _potvrdiPin(String potvrda) async {
    if (potvrda.isEmpty) {
      setState(() => _greska = 'Potvrda PIN-a je obavezna.');
      return;
    }
    if (potvrda != _noviPin) {
      setState(() => _greska = 'PIN-ovi se ne poklapaju.');
      return;
    }

    final korisnikId = widget.session.korisnik?.id;
    if (korisnikId == null) return;

    setState(() {
      _snimam = true;
      _greska = null;
    });

    try {
      await widget.authRepo.zavrsiObaveznuPromenuPina(korisnikId, potvrda);
      widget.onCompleted();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _snimam = false;
        _korak = 1;
        _noviPin = '';
        _greska = e.toString();
      });
    }
  }

  void _odjava() {
    widget.session.odjavi();
  }

  @override
  Widget build(BuildContext context) {
    final korisnik = widget.session.korisnik;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _odjava();
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('OBAVEZNA PROMENA PIN-A'),
          actions: [
            TextButton(
              onPressed: _snimam ? null : _odjava,
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              child: const Text('ODJAVA'),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock_reset,
                      size: 56,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Privremeni PIN mora biti promenjen pre nastavka rada.',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      korisnik == null
                          ? 'Prijava je uspešna, ali morate da promenite PIN.'
                          : 'Korisnik ${korisnik.imePrezime} mora da postavi novi PIN pre ulaska u aplikaciju.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),
                    if (_snimam)
                      const CircularProgressIndicator()
                    else
                      PinInputWidget(
                        label: _korak == 1
                            ? 'Unesite novi PIN'
                            : 'Potvrdite novi PIN',
                        errorText: _greska,
                        onPinComplete: _korak == 1
                            ? _unesiNoviPin
                            : _potvrdiPin,
                      ),
                    if (!_snimam && _korak == 2) ...[
                      const SizedBox(height: 16),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _korak = 1;
                            _noviPin = '';
                            _greska = null;
                          });
                        },
                        icon: const Icon(Icons.arrow_back, size: 16),
                        label: const Text('Unesite novi PIN ponovo'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
