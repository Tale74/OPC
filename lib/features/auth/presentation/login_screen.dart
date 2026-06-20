import 'package:flutter/material.dart';

import '../../../core/database/database.dart';
import '../data/auth_repository.dart';
import '../domain/session_service.dart';
import 'forgot_pin_recovery_dialog.dart';
import 'pin_input_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.authRepo,
    required this.session,
    required this.onSuccess,
  });

  final AuthRepository authRepo;
  final SessionService session;
  final VoidCallback onSuccess;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late Future<List<KorisniciData>> _futureKorisnici;
  KorisniciData? _selektovan;
  String? _greska;
  bool _ucitava = false;
  final _pinKey = GlobalKey<PinInputWidgetState>();

  @override
  void initState() {
    super.initState();
    _futureKorisnici = widget.authRepo.sviKorisnici(samoAktivni: true);
  }

  Future<void> _prijava(String pin) async {
    if (_selektovan == null) return;
    setState(() {
      _ucitava = true;
      _greska = null;
    });
    final korisnik = await widget.authRepo.prijavaKorisnikPin(
      _selektovan!.id,
      pin,
    );
    if (!mounted) return;
    if (korisnik != null) {
      widget.session.prijavi(korisnik);
      widget.onSuccess();
    } else {
      setState(() {
        _greska = 'Pogrešan PIN. Pokušajte ponovo.';
        _ucitava = false;
      });
      // Resetuj numpad, selekcija korisnika ostaje
      _pinKey.currentState?.ocisti();
    }
  }

  void _promeniKorisnika() {
    setState(() {
      _selektovan = null;
      _greska = null;
    });
  }

  Future<void> _otvoriZaboravljenPin() {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ForgotPinRecoveryDialog(authRepo: widget.authRepo),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 56,
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
                  const SizedBox(height: 4),
                  Text(
                    'Organizator pogrebne ceremonije',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 40),
                  if (_selektovan == null)
                    _KorisniciLista(
                      futureKorisnici: _futureKorisnici,
                      onSelekcija: (k) => setState(() => _selektovan = k),
                    )
                  else
                    _PinKorak(
                      korisnik: _selektovan!,
                      pinKey: _pinKey,
                      greska: _greska,
                      ucitava: _ucitava,
                      onPinComplete: _prijava,
                      onPromeniKorisnika: _promeniKorisnika,
                    ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _ucitava ? null : _otvoriZaboravljenPin,
                    child: const Text('Zaboravljen PIN'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Lista korisnika ───────────────────────────────────────────────────────────

class _KorisniciLista extends StatelessWidget {
  const _KorisniciLista({
    required this.futureKorisnici,
    required this.onSelekcija,
  });

  final Future<List<KorisniciData>> futureKorisnici;
  final void Function(KorisniciData) onSelekcija;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<KorisniciData>>(
      future: futureKorisnici,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        final lista = snap.data ?? [];
        if (lista.isEmpty) {
          return const Text('Nema aktivnih savetnika.');
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Izaberite savetnika',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ...lista.map((k) => _KorisnikKartica(
                  korisnik: k,
                  onTap: () => onSelekcija(k),
                )),
          ],
        );
      },
    );
  }
}

class _KorisnikKartica extends StatelessWidget {
  const _KorisnikKartica({required this.korisnik, required this.onTap});

  final KorisniciData korisnik;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: colorScheme.primaryContainer,
                  child: Text(
                    korisnik.imePrezime.isNotEmpty
                        ? korisnik.imePrezime[0]
                        : '?',
                    style: TextStyle(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        korisnik.imePrezime,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '(${korisnik.uloga})',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── PIN korak ─────────────────────────────────────────────────────────────────

class _PinKorak extends StatelessWidget {
  const _PinKorak({
    required this.korisnik,
    required this.pinKey,
    required this.greska,
    required this.ucitava,
    required this.onPinComplete,
    required this.onPromeniKorisnika,
  });

  final KorisniciData korisnik;
  final GlobalKey<PinInputWidgetState> pinKey;
  final String? greska;
  final bool ucitava;
  final void Function(String) onPinComplete;
  final VoidCallback onPromeniKorisnika;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          korisnik.imePrezime,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          '(${korisnik.uloga})',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 24),
        if (ucitava)
          const CircularProgressIndicator()
        else
          PinInputWidget(
            key: pinKey,
            label: 'Unesite PIN',
            errorText: greska,
            onPinComplete: onPinComplete,
          ),
        const SizedBox(height: 16),
        TextButton.icon(
          onPressed: onPromeniKorisnika,
          icon: const Icon(Icons.arrow_back, size: 16),
          label: const Text('Promeni savetnika'),
        ),
      ],
    );
  }
}
