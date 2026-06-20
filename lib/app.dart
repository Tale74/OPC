import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'core/database/database.dart';
import 'core/theme/app_typography.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/domain/session_service.dart';
import 'features/auth/presentation/first_launch_screen.dart';
import 'features/auth/presentation/forced_pin_change_screen.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/podesavanja/data/podesavanja_repository.dart';
import 'features/predmeti/data/predmeti_repository.dart';
import 'features/predmeti/presentation/lista_predmeta_screen.dart';
import 'features/predmeti/reminders/reminder_mvp_service.dart';

class OpcApp extends StatefulWidget {
  const OpcApp({super.key, required this.db});

  final AppDatabase db;

  @override
  State<OpcApp> createState() => _OpcAppState();
}

class _OpcAppState extends State<OpcApp> with WindowListener {
  late final AuthRepository _authRepo;
  late final SessionService _session;
  late final PodesavanjaRepository _podesavanjaRepo;
  late final PredmetiRepository _predmetiRepo;
  late final ReminderMvpService _reminderService;
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _authRepo = AuthRepository(widget.db);
    _session = SessionService();
    _podesavanjaRepo = PodesavanjaRepository(widget.db);
    _predmetiRepo = PredmetiRepository(widget.db);
    _reminderService = ReminderMvpService();
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      windowManager.addListener(this);
    }
  }

  @override
  void dispose() {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      windowManager.removeListener(this);
    }
    super.dispose();
  }

  /// Poziva se kada korisnik klikne X na Windows prozoru.
  /// setPreventClose(true) u main.dart blokira default zatvaranje.
  @override
  void onWindowClose() async {
    final nav = _navigatorKey.currentState;
    if (nav == null) return;

    if (nav.canPop()) {
      // Sekundarni ekran — maybePop dozvoljava PopScope da interveniše
      nav.maybePop();
    } else {
      // Na root ekranu — prikaži dijalog za potvrdu izlaska
      final ctx = _navigatorKey.currentContext;
      if (ctx == null || !ctx.mounted) return;
      final izlaz = await _prikaziIzlazDijalog(ctx);
      if (izlaz == true) {
        await windowManager.destroy();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OPC',
      debugShowCheckedModeBanner: false,
      navigatorKey: _navigatorKey,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      home: _StartRouter(
        authRepo: _authRepo,
        session: _session,
        podesavanjaRepo: _podesavanjaRepo,
        predmetiRepo: _predmetiRepo,
        reminderService: _reminderService,
      ),
    );
  }

  Future<bool?> _prikaziIzlazDijalog(BuildContext ctx) {
    return showDialog<bool>(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Izlaz iz aplikacije'),
        content: const Text('Da li želite da izađete iz aplikacije?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('OSTANI'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('IZAĐI'),
          ),
        ],
      ),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF1A5276),
      brightness: brightness,
    );
    final baseTheme = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: AppTypography.fontFamily,
      textTheme: AppTypography.textTheme(baseTheme.textTheme),
      primaryTextTheme: AppTypography.textTheme(baseTheme.primaryTextTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: colorScheme.onPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: const CardThemeData(
        elevation: 1,
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
      // TabBar je uvek unutar AppBar.bottom (pozadina = colorScheme.primary).
      // labelColor/unselectedLabelColor moraju biti čitljivi na toj pozadini.
      // Kontrast: onPrimary (belo) na primary (tamno plavo) ≈ 13:1 (aktivni tab)
      //           onPrimary 70% ≈ 8:1 (neaktivni tab) — oba > 4.5:1 WCAG AA.
      tabBarTheme: TabBarThemeData(
        labelColor: colorScheme.onPrimary,
        unselectedLabelColor: colorScheme.onPrimary.withAlpha(179),
        indicatorColor: colorScheme.onPrimary,
        dividerColor: Colors.transparent,
        labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        unselectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
      ),
    );
  }
}

/// Određuje koji ekran se prikazuje pri startu:
/// - prazna baza → FirstLaunchScreen → prijava prvog admina → ListaPredmetaScreen
/// - ima korisnika, niko nije prijavljen → LoginScreen
/// - prijavljen → ListaPredmetaScreen
class _StartRouter extends StatefulWidget {
  const _StartRouter({
    required this.authRepo,
    required this.session,
    required this.podesavanjaRepo,
    required this.predmetiRepo,
    required this.reminderService,
  });

  final AuthRepository authRepo;
  final SessionService session;
  final PodesavanjaRepository podesavanjaRepo;
  final PredmetiRepository predmetiRepo;
  final ReminderMvpService reminderService;

  @override
  State<_StartRouter> createState() => _StartRouterState();
}

class _StartRouterState extends State<_StartRouter> {
  late Future<bool> _hasKorisnika;

  @override
  void initState() {
    super.initState();
    _hasKorisnika = widget.authRepo.hasKorisnika();
    widget.session.addListener(_onSessionChange);
  }

  @override
  void dispose() {
    widget.session.removeListener(_onSessionChange);
    super.dispose();
  }

  void _onSessionChange() => setState(() {});

  @override
  Widget build(BuildContext context) {
    if (widget.session.prijavljen) {
      return FutureBuilder<bool>(
        future: widget.authRepo.korisnikMoraPromenitiPin(
          widget.session.korisnik!.id,
        ),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final mustChangePin = snap.data ?? false;
          if (mustChangePin) {
            return ForcedPinChangeScreen(
              authRepo: widget.authRepo,
              session: widget.session,
              onCompleted: () => setState(() {}),
            );
          }

          return ListaPredmetaScreen(
            predmetiRepo: widget.predmetiRepo,
            authRepo: widget.authRepo,
            podesavanjaRepo: widget.podesavanjaRepo,
            session: widget.session,
            reminderService: widget.reminderService,
          );
        },
      );
    }

    return FutureBuilder<bool>(
      future: _hasKorisnika,
      builder: (_, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final imaKorisnika = snap.data ?? false;
        if (!imaKorisnika) {
          return FirstLaunchScreen(
            authRepo: widget.authRepo,
            session: widget.session,
            onComplete: () {
              // Rebuild → ListaPredmetaScreen; admin odatle otvara Podešavanja.
              setState(() {});
            },
          );
        }
        return LoginScreen(
          authRepo: widget.authRepo,
          session: widget.session,
          onSuccess: () => setState(() {}),
        );
      },
    );
  }
}
