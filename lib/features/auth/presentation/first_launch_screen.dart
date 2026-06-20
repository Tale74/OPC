import 'package:flutter/material.dart';

import '../data/auth_repository.dart';
import '../domain/session_service.dart';
import 'pin_input_widget.dart';

/// Prikazuje se samo pri prvom pokretanju (prazna baza korisnika).
/// Korak 1: unos imena i prezimena.
/// Korak 2: postavljanje PIN-a (4 cifre) + POTVRDI.
/// Nakon uspešnog kreiranja admina → Lista predmeta, pa Podešavanja iz glavnog toka.
class FirstLaunchScreen extends StatefulWidget {
  const FirstLaunchScreen({
    super.key,
    required this.authRepo,
    required this.session,
    required this.onComplete,
  });

  final AuthRepository authRepo;
  final SessionService session;

  /// Poziva se nakon uspešnog kreiranja i vraća aplikaciju u glavni tok.
  final VoidCallback onComplete;

  @override
  State<FirstLaunchScreen> createState() => _FirstLaunchScreenState();
}

class _FirstLaunchScreenState extends State<FirstLaunchScreen> {
  final _formKey = GlobalKey<FormState>();
  final _imeCtrl = TextEditingController();
  int _korak = 1; // 1 = ime, 2 = pin
  String? _greska;
  bool _ucitava = false;

  @override
  void dispose() {
    _imeCtrl.dispose();
    super.dispose();
  }

  Future<void> _kreirajAdmina(String pin) async {
    setState(() {
      _ucitava = true;
      _greska = null;
    });
    try {
      final korisnik = await widget.authRepo.kreirajPrvogAdmina(
        imePrezime: _imeCtrl.text.trim().toUpperCase(),
        pin: pin,
      );
      widget.session.prijavi(korisnik);
      widget.onComplete();
    } catch (e) {
      setState(() {
        _greska = e.toString();
        _ucitava = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 40),
                  if (_korak == 1) _buildImeKorak(),
                  if (_korak == 2) _buildPinKorak(),
                  if (_ucitava) ...[
                    const SizedBox(height: 24),
                    const CircularProgressIndicator(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Icon(
          Icons.admin_panel_settings_outlined,
          size: 64,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 16),
        Text(
          'OPC',
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Organizator pogrebne ceremonije',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 24),
        _StepIndicator(korak: _korak),
      ],
    );
  }

  Widget _buildImeKorak() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Korak 1 od 2 — Administrator',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Unesite vaše ime i prezime.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _imeCtrl,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              labelText: 'IME I PREZIME',
              prefixIcon: Icon(Icons.person_outline),
              border: OutlineInputBorder(),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Ime i prezime je obavezno.';
              }
              return null;
            },
            onFieldSubmitted: (_) => _dalje(),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _dalje,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('DALJE'),
            ),
          ),
        ],
      ),
    );
  }

  void _dalje() {
    if (_formKey.currentState!.validate()) {
      setState(() => _korak = 2);
    }
  }

  Widget _buildPinKorak() {
    return Column(
      children: [
        Text(
          'Korak 2 od 2 — Postavite PIN',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          'Unesite 4-cifreni PIN za prijavu.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        PinInputWidget(
          label: 'PIN (4 cifre)',
          errorText: _greska,
          onPinComplete: _kreirajAdmina,
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => setState(() {
            _korak = 1;
            _greska = null;
          }),
          child: const Text('← Nazad'),
        ),
      ],
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.korak});

  final int korak;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(2, (i) {
        final active = i + 1 <= korak;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? color : color.withAlpha(60),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
