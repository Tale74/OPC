import 'package:flutter/material.dart';

import '../../../core/database/database.dart';
import '../data/auth_repository.dart';
import '../domain/session_service.dart';
import 'pin_input_widget.dart';

/// Ekran za upravljanje korisnicima — dostupan samo administratoru.
/// Poziva se i iz Podešavanja i kao poseban ekran.
class KorisniciScreen extends StatefulWidget {
  const KorisniciScreen({
    super.key,
    required this.authRepo,
    required this.session,
    this.embedded = false,
  });

  final AuthRepository authRepo;
  final SessionService session;
  final bool embedded;

  @override
  State<KorisniciScreen> createState() => _KorisniciScreenState();
}

class _KorisniciScreenState extends State<KorisniciScreen> {
  late Future<List<KorisniciData>> _futureLista;
  late Future<Set<int>> _futureTrajnoObrisiviIds;

  @override
  void initState() {
    super.initState();
    _osveziListu();
  }

  void _osveziListu() {
    final futureLista = widget.authRepo.sviKorisnici();
    final futureTrajnoObrisiviIds = futureLista.then(
      (lista) => widget.authRepo.trajnoObrisiviKorisnikIds(
        lista.map((k) => k.id).toList(),
        izvrsilacId: widget.session.korisnik?.id,
      ),
    );
    setState(() {
      _futureLista = futureLista;
      _futureTrajnoObrisiviIds = futureTrajnoObrisiviIds;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.session.jeAdmin) {
      final blocked = Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Pristup ekranu korisnika je dozvoljen samo administratoru.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ),
      );
      if (widget.embedded) return blocked;
      return Scaffold(
        appBar: AppBar(title: const Text('KORISNICI')),
        body: blocked,
      );
    }

    final body = FutureBuilder<List<KorisniciData>>(
      future: _futureLista,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final lista = snap.data ?? [];
        if (lista.isEmpty) {
          return const Center(child: Text('Nema korisnika.'));
        }
        return FutureBuilder<Set<int>>(
          future: _futureTrajnoObrisiviIds,
          builder: (context, deleteSnap) {
            final trajnoObrisiviIds = deleteSnap.data ?? const <int>{};
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: lista.length,
              separatorBuilder: (context, i) => const SizedBox(height: 8),
              itemBuilder: (context, i) => _KorisnikTile(
                korisnik: lista[i],
                trenutniKorisnikId: widget.session.korisnik?.id,
                mozeTrajnoBrisanje: trajnoObrisiviIds.contains(lista[i].id),
                onDeaktiviraj: () => _deaktiviraj(lista[i]),
                onPromeniUlogu: () => _promeniUlogu(lista[i]),
                onResetujPin: () => _resetujPin(lista[i]),
                onPromeniPin: () => _promeniSopstveniPin(lista[i]),
                onTrajnoObrisi: () => _trajnoObrisi(lista[i]),
              ),
            );
          },
        );
      },
    );

    if (widget.embedded) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
            child: Row(
              children: [
                Text(
                  'KORISNICI',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const Spacer(),
                FilledButton.icon(
                  icon: const Icon(Icons.person_add_outlined),
                  label: const Text('NOVI KORISNIK'),
                  onPressed: _noviKorisnik,
                ),
              ],
            ),
          ),
          Expanded(child: body),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('KORISNICI'),
        centerTitle: false,
        actions: [
          FilledButton.icon(
            icon: const Icon(Icons.person_add_outlined),
            label: const Text('NOVI KORISNIK'),
            onPressed: _noviKorisnik,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: body,
    );
  }

  // ── Akcije ───────────────────────────────────────────────────────────────

  Future<void> _noviKorisnik() async {
    final result = await showDialog<_NoviKorisnikResult>(
      context: context,
      builder: (_) => _NoviKorisnikDialog(authRepo: widget.authRepo),
    );
    if (result != null) {
      try {
        await widget.authRepo.kreirajKorisnika(
          imePrezime: result.imePrezime,
          uloga: result.uloga,
          pin: result.pin,
        );
        _osveziListu();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Korisnik ${result.imePrezime} kreiran.'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) _prikaziGresku(e.toString());
      }
    }
  }

  Future<void> _deaktiviraj(KorisniciData k) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Deaktivacija korisnika'),
        content: Text(
          'Da li želite da deaktivirate korisnika ${k.imePrezime}?\n\n'
          'Predmeti ostaju u bazi.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ODUSTANI'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('DEAKTIVIRAJ'),
          ),
        ],
      ),
    );
    if (ok == true) {
      try {
        await widget.authRepo.deaktivirajKorisnika(
          k.id,
          izvrsilacId: widget.session.korisnik?.id,
        );
        _osveziListu();
      } catch (e) {
        if (mounted) _prikaziGresku(e.toString());
      }
    }
  }

  Future<void> _promeniUlogu(KorisniciData k) async {
    final novaUloga = k.uloga == 'ADMINISTRATOR' ? 'SAVETNIK' : 'ADMINISTRATOR';
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Promena uloge'),
        content: Text(
          'Promeniti ulogu korisnika ${k.imePrezime}\n'
          'iz ${k.uloga} u $novaUloga?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ODUSTANI'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('POTVRDI'),
          ),
        ],
      ),
    );
    if (ok == true) {
      try {
        await widget.authRepo.promeniUlogu(
          k.id,
          novaUloga,
          izvrsilacId: widget.session.korisnik?.id,
        );
        _osveziListu();
      } catch (e) {
        if (mounted) _prikaziGresku(e.toString());
      }
    }
  }

  Future<void> _trajnoObrisi(KorisniciData k) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Trajno brisanje korisnika'),
        content: Text(
          'Da li želite trajno da obrišete korisnika ${k.imePrezime}?\n\n'
          'Ova akcija je dozvoljena samo kada korisnik nema vezane podatke.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ODUSTANI'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('OBRIŠI TRAJNO'),
          ),
        ],
      ),
    );
    if (ok == true) {
      try {
        await widget.authRepo.trajnoObrisiKorisnika(
          k.id,
          izvrsilacId: widget.session.korisnik?.id,
        );
        _osveziListu();
      } catch (e) {
        if (mounted) _prikaziGresku(e.toString());
      }
    }
  }

  Future<void> _resetujPin(KorisniciData k) async {
    final pin = await _pinDialog(
      title: 'Reset PIN-a',
      subtitle: 'Privremeni PIN za ${k.imePrezime}',
    );
    if (pin != null) {
      if (!mounted) return;
      final adminPin = await _pinDialog(
        title: 'Potvrda administratora',
        subtitle: 'Unesite svoj trenutni PIN za potvrdu reset-a',
      );
      if (adminPin == null) return;
      final adminId = widget.session.korisnik?.id;
      if (adminId == null) return;
      try {
        await widget.authRepo.resetujPinUzAdminPotvrdu(
          adminId: adminId,
          adminPin: adminPin,
          targetUserId: k.id,
          noviPin: pin,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'PIN je resetovan. Korisnik mora da ga promeni pri sledećoj prijavi.',
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) _prikaziGresku(e.toString());
      }
    }
  }

  Future<void> _promeniSopstveniPin(KorisniciData k) async {
    final stari = await _pinDialog(
      title: 'Promena PIN-a',
      subtitle: 'Unesite trenutni PIN',
    );
    if (stari == null) return;
    if (!mounted) return;
    final novi = await _pinDialog(
      title: 'Promena PIN-a',
      subtitle: 'Unesite novi PIN',
    );
    if (novi == null) return;
    try {
      await widget.authRepo.promeniSopstveniPin(k.id, stari, novi);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PIN je promenjen.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) _prikaziGresku(e.toString());
    }
  }

  Future<String?> _pinDialog({
    required String title,
    required String subtitle,
  }) {
    return showDialog<String>(
      context: context,
      builder: (_) => _PinDialog(title: title, subtitle: subtitle),
    );
  }

  void _prikaziGresku(String poruka) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(poruka),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }
}

// ── Tile za korisnika ────────────────────────────────────────────────────────

class _KorisnikTile extends StatelessWidget {
  const _KorisnikTile({
    required this.korisnik,
    required this.trenutniKorisnikId,
    required this.mozeTrajnoBrisanje,
    required this.onDeaktiviraj,
    required this.onPromeniUlogu,
    required this.onResetujPin,
    required this.onPromeniPin,
    required this.onTrajnoObrisi,
  });

  final KorisniciData korisnik;
  final int? trenutniKorisnikId;
  final bool mozeTrajnoBrisanje;
  final VoidCallback onDeaktiviraj;
  final VoidCallback onPromeniUlogu;
  final VoidCallback onResetujPin;
  final VoidCallback onPromeniPin;
  final VoidCallback onTrajnoObrisi;

  @override
  Widget build(BuildContext context) {
    final neaktivan = !korisnik.aktivan;
    final jeAktivniKorisnik = korisnik.id == trenutniKorisnikId;
    final mozeUpravljatiKorisnikom = !jeAktivniKorisnik;
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: neaktivan
              ? Colors.grey.shade300
              : (korisnik.uloga == 'ADMINISTRATOR'
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.secondaryContainer),
          child: Text(
            korisnik.imePrezime.isNotEmpty
                ? korisnik.imePrezime[0]
                : '?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: neaktivan ? Colors.grey : null,
            ),
          ),
        ),
        title: Text(
          korisnik.imePrezime,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: neaktivan ? Colors.grey : null,
            decoration: neaktivan ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Row(
          children: [
            _BadgeChip(
              label: korisnik.uloga,
              color: korisnik.uloga == 'ADMINISTRATOR'
                  ? Colors.indigo
                  : Colors.teal,
            ),
            if (neaktivan) ...[
              const SizedBox(width: 6),
              const _BadgeChip(label: 'NEAKTIVAN', color: Colors.grey),
            ],
          ],
        ),
        trailing: neaktivan
            ? null
            : PopupMenuButton<String>(
                onSelected: (v) {
                  switch (v) {
                    case 'uloga':
                      onPromeniUlogu();
                      return;
                    case 'reset_pin':
                      onResetujPin();
                      return;
                    case 'pin':
                      onPromeniPin();
                      return;
                    case 'trajno_obrisi':
                      onTrajnoObrisi();
                      return;
                    case 'deaktiviraj':
                      onDeaktiviraj();
                      return;
                  }
                },
                itemBuilder: (_) => [
                  if (jeAktivniKorisnik)
                    const PopupMenuItem(
                      value: 'pin',
                      child: ListTile(
                        leading: Icon(Icons.lock_reset),
                        title: Text('Promeni sopstveni PIN'),
                        dense: true,
                      ),
                    ),
                  if (mozeUpravljatiKorisnikom) ...[
                    PopupMenuItem(
                      value: 'uloga',
                      child: ListTile(
                        leading: const Icon(Icons.swap_horiz),
                        title: Text(
                          korisnik.uloga == 'ADMINISTRATOR'
                              ? 'Promeni ulogu u SAVETNIK'
                              : 'Promeni ulogu u ADMINISTRATOR',
                        ),
                        dense: true,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'reset_pin',
                      child: ListTile(
                        leading: Icon(Icons.pin_outlined),
                        title: Text('Resetuj PIN'),
                        dense: true,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'deaktiviraj',
                      child: ListTile(
                        leading: Icon(Icons.person_off_outlined),
                        title: Text('Deaktiviraj korisnika'),
                        dense: true,
                      ),
                    ),
                    if (mozeTrajnoBrisanje)
                      const PopupMenuItem(
                        value: 'trajno_obrisi',
                        child: ListTile(
                          leading: Icon(Icons.delete_forever_outlined),
                          title: Text('Trajno obriši korisnika'),
                          dense: true,
                        ),
                      ),
                  ],
                ],
              ),
      ),
    );
  }
}

class _BadgeChip extends StatelessWidget {
  const _BadgeChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// ── Dijalozi ─────────────────────────────────────────────────────────────────

class _NoviKorisnikResult {
  const _NoviKorisnikResult({
    required this.imePrezime,
    required this.uloga,
    required this.pin,
  });

  final String imePrezime;
  final String uloga;
  final String pin;
}

class _NoviKorisnikDialog extends StatefulWidget {
  const _NoviKorisnikDialog({required this.authRepo});

  final AuthRepository authRepo;

  @override
  State<_NoviKorisnikDialog> createState() => _NoviKorisnikDialogState();
}

class _NoviKorisnikDialogState extends State<_NoviKorisnikDialog> {
  final _formKey = GlobalKey<FormState>();
  final _imeCtrl = TextEditingController();
  String _uloga = 'SAVETNIK';
  int _korak = 1; // 1 = podaci, 2 = pin, 3 = potvrda
  String _pin = '';
  String? _greska;

  @override
  void dispose() {
    _imeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400, minWidth: 320),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'NOVI KORISNIK',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),
              if (_korak == 1) _buildPodaciForm(),
              if (_korak == 2) _buildPinUnos(false),
              if (_korak == 3) _buildPinUnos(true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPodaciForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _imeCtrl,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              labelText: 'IME I PREZIME',
              border: OutlineInputBorder(),
            ),
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Obavezno polje.' : null,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _uloga,
            decoration: const InputDecoration(
              labelText: 'ULOGA',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(
                value: 'SAVETNIK',
                child: Text('SAVETNIK'),
              ),
              DropdownMenuItem(
                value: 'ADMINISTRATOR',
                child: Text('ADMINISTRATOR'),
              ),
            ],
            onChanged: (v) => setState(() => _uloga = v ?? 'SAVETNIK'),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('ODUSTANI'),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    setState(() => _korak = 2);
                  }
                },
                child: const Text('DALJE'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPinUnos(bool potvrda) {
    return PinInputWidget(
      label: potvrda ? 'Potvrdite PIN' : 'Postavite PIN (4 cifre)',
      errorText: _greska,
      onPinComplete: (pin) {
        if (!potvrda) {
          setState(() {
            _pin = pin;
            _korak = 3;
            _greska = null;
          });
        } else {
          if (_pin != pin) {
            setState(() => _greska = 'PIN-ovi se ne poklapaju.');
          } else {
            Navigator.pop(
              context,
              _NoviKorisnikResult(
                imePrezime: _imeCtrl.text.trim().toUpperCase(),
                uloga: _uloga,
                pin: pin,
              ),
            );
          }
        }
      },
    );
  }
}

class _PinDialog extends StatefulWidget {
  const _PinDialog({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  State<_PinDialog> createState() => _PinDialogState();
}

class _PinDialogState extends State<_PinDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360, minWidth: 300),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.title,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              PinInputWidget(
                label: widget.subtitle,
                onPinComplete: (pin) => Navigator.pop(context, pin),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('ODUSTANI'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
