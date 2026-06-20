import 'dart:io' show Platform;
import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/database/database.dart';
import '../../../core/format/app_format.dart';
import 'katalog_photo_policy.dart';
import '../data/podesavanja_repository.dart';

// ── Glavni widget ─────────────────────────────────────────────────────────────

class KatalogTab extends StatelessWidget {
  const KatalogTab({super.key, required this.repo});

  final PodesavanjaRepository repo;

  Future<void> _dodajKategoriju(BuildContext context) async {
    final result = await showDialog<_NovaKategorijaResult>(
      context: context,
      builder: (_) => const _NovaKategorijaDialog(),
    );
    if (result == null || !context.mounted) return;

    final ishod = await repo.dodajKorisnickaKategoriju(
      interniNaziv: 'KORISNIK_${DateTime.now().millisecondsSinceEpoch}',
      nazivPrikaz: result.naziv,
      tip: result.tip,
    );

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ishod.uspeh
              ? 'Korisnička kategorija je sačuvana u katalogu.'
              : 'Kategorija nije sačuvana. Upis nije potvrđen u bazi.',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<IriuKatalogConfigData>>(
      stream: repo.watchKatalog(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final stavke = snap.data!;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('DODAJ KATEGORIJU'),
                  onPressed: () => _dodajKategoriju(context),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: stavke.length,
                itemBuilder: (context, i) => _KatalogItemTile(
                  key: ValueKey(stavke[i].interniNaziv),
                  item: stavke[i],
                  repo: repo,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ── Tile za jednu stavku kataloga ─────────────────────────────────────────────

class _KatalogItemTile extends StatefulWidget {
  const _KatalogItemTile({
    super.key,
    required this.item,
    required this.repo,
  });

  final IriuKatalogConfigData item;
  final PodesavanjaRepository repo;

  @override
  State<_KatalogItemTile> createState() => _KatalogItemTileState();
}

class _KatalogItemTileState extends State<_KatalogItemTile> {
  bool _expanded = false;

  bool get _jeKataloska => widget.item.tip == 'KATALOSKA';
  bool get _jeKorisnicka => widget.item.jeKorisnicka;

  Future<void> _editDialog(BuildContext context) async {
    final nazivCtrl =
        TextEditingController(text: widget.item.nazivPrikaz);
    bool vidljiv = widget.item.vidljiv;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          title: const Text('Izmeni stavku'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nazivCtrl,
                decoration: const InputDecoration(
                  labelText: 'Naziv prikaza',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                value: vidljiv,
                onChanged: (v) => setDlg(() => vidljiv = v),
                title: const Text('Vidljivo u katalogu'),
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('ODUSTANI'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('SAČUVAJ'),
            ),
          ],
        ),
      ),
    );

    final noviNaziv = nazivCtrl.text.trim();
    nazivCtrl.dispose();

    if (ok == true && context.mounted) {
      await widget.repo.azurirajKatalogStavku(
        widget.item.interniNaziv,
        IriuKatalogConfigCompanion(
          nazivPrikaz: Value(
            noviNaziv.isEmpty ? widget.item.nazivPrikaz : noviNaziv,
          ),
          vidljiv: Value(vidljiv),
        ),
      );
    }
  }

  Future<void> _ukloniIliDeaktiviraj(BuildContext context) async {
    final status = await widget.repo
        .proveriKategorijuZaLifecycleAkciju(widget.item.interniNaziv);
    if (status == null || !context.mounted) return;

    final ideNaBrisanje = status.mozeFizickoBrisanje;
    final naslov = ideNaBrisanje
        ? 'Obriši kategoriju'
        : 'Deaktiviraj kategoriju';
    final opis = ideNaBrisanje
        ? 'Kategorija nije korišćena i može biti fizički obrisana.'
        : 'Kategorija je korišćena ili povezana, pa će biti bezbedno deaktivirana i sakrivena iz aktivnog kataloga.';

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(naslov),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(opis),
            if (!ideNaBrisanje) ...[
              const SizedBox(height: 12),
              Text(
                status.koriscenaUIriu
                    ? 'Kategorija ima istorijsku upotrebu u IRIU.'
                    : 'Kategorija nije nađena u IRIU istoriji.',
              ),
              if (_jeKataloska)
                Text(
                  status.imaPovezaneArtikle
                      ? 'Kategorija ima povezane artikle.'
                      : 'Kategorija nema povezane artikle.',
                ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('ODUSTANI'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(ideNaBrisanje ? 'OBRIŠI' : 'DEAKTIVIRAJ'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;

    final ishod = await widget.repo
        .ukloniIliDeaktivirajKorisnickuKategoriju(widget.item.interniNaziv);
    if (!context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          ishod.obrisana
              ? 'Kategorija je obrisana.'
              : 'Kategorija je deaktivirana i sakrivena iz aktivnog kataloga.',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 3),
      child: Column(
        children: [
          InkWell(
            onTap: _jeKataloska
                ? () => setState(() => _expanded = !_expanded)
                : null,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.item.nazivPrikaz,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 3),
                        Wrap(
                          spacing: 4,
                          children: [
                            _TipChip(_jeKataloska),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    tooltip: 'Izmeni',
                    onPressed: () => _editDialog(context),
                  ),
                  if (_jeKorisnicka)
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      tooltip: 'Ukloni kategoriju',
                      onPressed: () => _ukloniIliDeaktiviraj(context),
                    ),
                  if (_jeKataloska)
                    Icon(
                      _expanded
                          ? Icons.expand_less
                          : Icons.expand_more,
                      color: scheme.primary,
                    ),
                ],
              ),
            ),
          ),
          if (_jeKataloska && _expanded)
            _ArtikliSection(
              interniNaziv: widget.item.interniNaziv,
              repo: widget.repo,
            ),
        ],
      ),
    );
  }
}

class _NovaKategorijaResult {
  _NovaKategorijaResult({required this.naziv, required this.tip});

  final String naziv;
  final String tip;
}

class _NovaKategorijaDialog extends StatefulWidget {
  const _NovaKategorijaDialog();

  @override
  State<_NovaKategorijaDialog> createState() =>
      _NovaKategorijaDialogState();
}

class _NovaKategorijaDialogState extends State<_NovaKategorijaDialog> {
  final _nazivCtrl = TextEditingController();
  String _tip = 'FIKSNA';
  bool _greskaNaziv = false;

  @override
  void dispose() {
    _nazivCtrl.dispose();
    super.dispose();
  }

  void _potvrdi() {
    final naziv = _nazivCtrl.text.trim();
    if (naziv.isEmpty) {
      setState(() => _greskaNaziv = true);
      return;
    }
    Navigator.pop(
      context,
      _NovaKategorijaResult(naziv: naziv, tip: _tip),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Dodaj kategoriju'),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nazivCtrl,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Naziv kategorije',
                border: const OutlineInputBorder(),
                isDense: true,
                errorText: _greskaNaziv ? 'Naziv je obavezan' : null,
              ),
              onChanged: (_) {
                if (_greskaNaziv) setState(() => _greskaNaziv = false);
              },
              onSubmitted: (_) => _potvrdi(),
            ),
            const SizedBox(height: 16),
            Text(
              'Tip kategorije:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment<String>(
                  value: 'FIKSNA',
                  label: Text('FIKSNA'),
                  icon: Icon(Icons.edit_outlined, size: 16),
                ),
                ButtonSegment<String>(
                  value: 'KATALOSKA',
                  label: Text('KATALOŠKA'),
                  icon: Icon(Icons.library_books_outlined, size: 16),
                ),
              ],
              selected: {_tip},
              onSelectionChanged: (sel) =>
                  setState(() => _tip = sel.first),
              style: const ButtonStyle(
                visualDensity: VisualDensity.compact,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _tip == 'FIKSNA'
                  ? 'Stavka se koristi kao fiksna kategorija bez podliste artikala.'
                  : 'Kategorija ostaje kompatibilna sa postojećim unosom i izmenom artikala.',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('ODUSTANI'),
        ),
        FilledButton(
          onPressed: _potvrdi,
          child: const Text('DODAJ'),
        ),
      ],
    );
  }
}

// ── Chip za tip stavke ────────────────────────────────────────────────────────

class _TipChip extends StatelessWidget {
  const _TipChip(this.jeKataloska);

  final bool jeKataloska;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Chip(
      label: Text(jeKataloska ? 'KATALOŠKA' : 'FIKSNA'),
      labelStyle: TextStyle(
        fontSize: 10,
        color: jeKataloska
            ? scheme.onPrimaryContainer
            : scheme.onSurfaceVariant,
      ),
      backgroundColor: jeKataloska
          ? scheme.primaryContainer
          : scheme.surfaceContainerHighest,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }
}

// ── Lista artikala za KATALOŠKA stavku ────────────────────────────────────────

class _ArtikliSection extends StatefulWidget {
  const _ArtikliSection({
    required this.interniNaziv,
    required this.repo,
  });

  final String interniNaziv;
  final PodesavanjaRepository repo;

  @override
  State<_ArtikliSection> createState() => _ArtikliSectionState();
}

class _ArtikliSectionState extends State<_ArtikliSection> {
  bool _ascending = true;

  List<KatalogArtikliData> _sortiraj(List<KatalogArtikliData> lista) {
    final sorted = [...lista]..sort((a, b) {
        final byCena = a.cena.compareTo(b.cena);
        if (byCena != 0) return _ascending ? byCena : -byCena;
        final byNaziv = a.naziv.compareTo(b.naziv);
        return _ascending ? byNaziv : -byNaziv;
      });
    return sorted;
  }

  Future<void> _artiklDialog(
    BuildContext context, {
    KatalogArtikliData? existing,
  }) async {
    final result = await showDialog<_ArtiklResult>(
      context: context,
      builder: (_) => _ArtiklDialog(existing: existing),
    );
    if (result == null || !context.mounted) return;

    if (existing == null) {
      await widget.repo.dodajArtikl(
        KatalogArtikliCompanion(
          interniNazivKategorije: Value(widget.interniNaziv),
          naziv: Value(result.naziv),
          cena: Value(result.cena),
          fotografija: Value(result.slika),
        ),
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Artikal dodat u katalog.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      await widget.repo.azurirajArtikl(
        existing.id,
        KatalogArtikliCompanion(
          naziv: Value(result.naziv),
          cena: Value(result.cena),
          fotografija: result.slikaIzmenjena
              ? Value(result.slika)
              : const Value.absent(),
        ),
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Artikal sačuvan.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _potvrdiObris(
    BuildContext context,
    KatalogArtikliData a,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Obriši artikal'),
        content: Text('Obrisati "${a.naziv}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('ODUSTANI'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('OBRIŠI'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await widget.repo.obrisiArtikl(a.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${a.naziv}" obrisan iz kataloga.'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<KatalogArtikliData>>(
      stream: widget.repo.watchArtikli(widget.interniNaziv),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Padding(
            padding: EdgeInsets.all(12),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final artikli = _sortiraj(snap.data!);
        return Column(
          children: [
            const Divider(height: 1),
            // Sort toolbar
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                children: [
                  Text(
                    'Cena / naziv',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: Icon(
                      _ascending
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                      size: 18,
                    ),
                    tooltip: _ascending ? 'Rastuće' : 'Opadajuće',
                    onPressed: () =>
                        setState(() => _ascending = !_ascending),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('DODAJ'),
                    onPressed: () => _artiklDialog(context),
                  ),
                ],
              ),
            ),
            ...artikli.map(
              (a) => ListTile(
                dense: true,
                leading: a.fotografija != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: KatalogPhotoPolicy.memoryImage(
                          Uint8List.fromList(a.fotografija!),
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          cacheWidth:
                              KatalogPhotoPolicy.smallThumbnailDecodeTarget,
                          cacheHeight:
                              KatalogPhotoPolicy.smallThumbnailDecodeTarget,
                          errorBuilder: (_, e, st) => const Icon(
                            Icons.image_outlined,
                            size: 28,
                          ),
                        ),
                      )
                    : const SizedBox(
                        width: 40,
                        child: Icon(Icons.image_outlined, size: 28),
                      ),
                title: Text(a.naziv),
                subtitle: Text(formatRsd(a.cena)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      tooltip: 'Izmeni',
                      onPressed: () =>
                          _artiklDialog(context, existing: a),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18),
                      tooltip: 'Obriši',
                      onPressed: () => _potvrdiObris(context, a),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }
}

// ── Rezultat dijaloga za artikal ──────────────────────────────────────────────

typedef _ArtiklResult = ({
  String naziv,
  double cena,
  Uint8List? slika,
  bool slikaIzmenjena,
});

// ── Dijalog za dodavanje / izmenu artikla ─────────────────────────────────────

class _ArtiklDialog extends StatefulWidget {
  const _ArtiklDialog({this.existing});

  final KatalogArtikliData? existing;

  @override
  State<_ArtiklDialog> createState() => _ArtiklDialogState();
}

class _ArtiklDialogState extends State<_ArtiklDialog> {
  late final TextEditingController _nazivCtrl;
  late final TextEditingController _cenaCtrl;
  Uint8List? _slika;
  bool _slikaIzmenjena = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nazivCtrl = TextEditingController(text: e?.naziv ?? '');
    _cenaCtrl = TextEditingController(
      text: e != null && e.cena > 0 ? formatBroj(e.cena) : '',
    );
    if (e?.fotografija != null) {
      _slika = Uint8List.fromList(e!.fotografija!);
    }
  }

  @override
  void dispose() {
    _nazivCtrl.dispose();
    _cenaCtrl.dispose();
    super.dispose();
  }

  Future<void> _odaberiSliku() async {
    Uint8List? bytes;
    if (Platform.isAndroid) {
      final img = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: KatalogPhotoPolicy.storedImportTargetLongEdge.toDouble(),
        maxHeight: KatalogPhotoPolicy.storedImportTargetLongEdge.toDouble(),
      );
      if (img != null) bytes = await img.readAsBytes();
    } else {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png'],
        withData: true,
      );
      if (result != null && result.files.single.bytes != null) {
        bytes = result.files.single.bytes!;
      }
    }
    if (bytes != null && mounted) {
      setState(() {
        _slika = bytes;
        _slikaIzmenjena = true;
      });
    }
  }

  void _ukloniSliku() => setState(() {
        _slika = null;
        _slikaIzmenjena = true;
      });

  void _sacuvaj() {
    final naziv = _nazivCtrl.text.trim();
    if (naziv.isEmpty) return;
    Navigator.pop<_ArtiklResult>(
      context,
      (
        naziv: naziv,
        cena: parsirajBroj(_cenaCtrl.text),
        slika: _slika,
        slikaIzmenjena: _slikaIzmenjena,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AlertDialog(
      title: Text(widget.existing == null ? 'Novi artikal' : 'Izmeni artikal'),
      content: SizedBox(
        width: 360,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. NAZIV
              TextField(
                controller: _nazivCtrl,
                autofocus: true,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'NAZIV',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              // 2. CENA
              TextField(
                controller: _cenaCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'CENA (RSD)',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 16),
              // 3. FOTOGRAFIJA
              Text(
                'FOTOGRAFIJA',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              if (_slika != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: KatalogPhotoPolicy.memoryImage(
                    _slika!,
                    height: 140,
                    fit: BoxFit.contain,
                    cacheWidth: KatalogPhotoPolicy.largeThumbnailDecodeTarget,
                    cacheHeight: KatalogPhotoPolicy.largeThumbnailDecodeTarget,
                  ),
                )
              else
                Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: cs.outlineVariant),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.image_outlined,
                      size: 36,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.upload_outlined, size: 16),
                    label: const Text('ODABERI'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                    onPressed: _odaberiSliku,
                  ),
                  if (_slika != null) ...[
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.clear, size: 16),
                      label: const Text('UKLONI'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                      onPressed: _ukloniSliku,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OTKAŽI'),
        ),
        FilledButton(
          onPressed: _sacuvaj,
          child: const Text('SAČUVAJ'),
        ),
      ],
    );
  }
}
