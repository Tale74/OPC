import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/database/database.dart';
import '../data/auth_repository.dart';

class ForgotPinRecoveryDialog extends StatefulWidget {
  const ForgotPinRecoveryDialog({
    super.key,
    required this.authRepo,
  });

  final AuthRepository authRepo;

  @override
  State<ForgotPinRecoveryDialog> createState() =>
      _ForgotPinRecoveryDialogState();
}

class _ForgotPinRecoveryDialogState extends State<ForgotPinRecoveryDialog> {
  late final Future<_RecoveryBootstrapData> _bootstrapFuture = _loadData();
  final TextEditingController _securityCodeCtrl = TextEditingController();
  int? _selectedAdminId;
  String? _error;
  bool _submitting = false;
  ServiceRecoveryResult? _result;

  String _messageFromError(Object error) {
    final text = error.toString();
    const prefix = 'Exception: ';
    return text.startsWith(prefix) ? text.substring(prefix.length) : text;
  }

  Future<_RecoveryBootstrapData> _loadData() async {
    final hasRecoveryCode = await widget.authRepo.imaPodesenSigurnosniKod();
    final administrators = await widget.authRepo.aktivniAdministratori();
    return _RecoveryBootstrapData(
      hasRecoveryCode: hasRecoveryCode,
      administrators: administrators,
    );
  }

  @override
  void dispose() {
    _securityCodeCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit(_RecoveryBootstrapData data) async {
    final securityCode = _securityCodeCtrl.text.trim();
    if (securityCode.isEmpty) {
      setState(() => _error = 'Unesite sigurnosni kod.');
      return;
    }

    final admins = data.administrators;
    if (admins.isEmpty) {
      setState(
        () => _error = 'Nema dostupnog administratora za oporavak pristupa.',
      );
      return;
    }

    final targetAdminId =
        admins.length == 1 ? admins.first.id : _selectedAdminId;
    if (targetAdminId == null) {
      setState(() => _error = 'Izaberite administratora.');
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final result = await widget.authRepo.oporaviAdministratorPristup(
        securityCode: securityCode,
        targetAdminUserId: targetAdminId,
      );
      if (!mounted) return;
      _securityCodeCtrl.clear();
      setState(() {
        _result = result;
        _submitting = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = _messageFromError(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_RecoveryBootstrapData>(
      future: _bootstrapFuture,
      builder: (context, snapshot) {
        final data = snapshot.data ??
            const _RecoveryBootstrapData(
              hasRecoveryCode: false,
              administrators: [],
            );
        final recoveryAvailable = snapshot.connectionState !=
                ConnectionState.waiting &&
            _result == null &&
            data.hasRecoveryCode &&
            data.administrators.isNotEmpty;

        return AlertDialog(
          title: Text(
            _result == null ? 'Oporavak pristupa aplikaciji' : 'Privremeni PIN',
          ),
          content: _buildContent(context, snapshot, data),
          actions: [
            TextButton(
              onPressed: _submitting
                  ? null
                  : () => Navigator.of(context).pop(),
              child: Text(_result == null ? 'OTKAŽI' : 'ZATVORI'),
            ),
            if (recoveryAvailable)
              FilledButton(
                onPressed: _submitting ? null : () => _submit(data),
                child: _submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('POTVRDI'),
              ),
          ],
        );
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    AsyncSnapshot<_RecoveryBootstrapData> snapshot,
    _RecoveryBootstrapData data,
  ) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const SizedBox(
        width: 320,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_result != null) {
      return SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Administrator: ${_result!.targetDisplayName}',
            ),
            const SizedBox(height: 16),
            SelectableText(
              _result!.temporaryPin,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Sačuvajte privremeni PIN. Biće prikazan samo jednom.',
            ),
            const SizedBox(height: 8),
            const Text(
              'Pri sledećoj prijavi moraćete da unesete novi PIN.',
            ),
          ],
        ),
      );
    }

    if (!data.hasRecoveryCode) {
      return const SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Oporavak pristupa aplikaciji nije podešen.'),
            SizedBox(height: 8),
            Text('Obratite se administratoru ili servisnoj podršci.'),
          ],
        ),
      );
    }

    if (data.administrators.isEmpty) {
      return const SizedBox(
        width: 360,
        child: Text('Nema dostupnog administratora za oporavak pristupa.'),
      );
    }

    final singleAdmin = data.administrators.length == 1;
    final selectedAdmin = singleAdmin
        ? data.administrators.first
        : data.administrators.cast<KorisniciData?>().firstWhere(
              (admin) => admin?.id == _selectedAdminId,
              orElse: () => null,
            );

    return SizedBox(
      width: 360,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Unesite sigurnosni kod za povratak pristupa aplikaciji.',
          ),
          const SizedBox(height: 16),
          if (singleAdmin)
            Text('Administrator: ${selectedAdmin!.imePrezime}')
          else
            DropdownButtonFormField<int>(
              initialValue: _selectedAdminId,
              decoration: const InputDecoration(
                labelText: 'Administrator',
              ),
              items: data.administrators
                  .map(
                    (admin) => DropdownMenuItem<int>(
                      value: admin.id,
                      child: Text(admin.imePrezime),
                    ),
                  )
                  .toList(growable: false),
              onChanged: _submitting
                  ? null
                  : (value) {
                      setState(() {
                        _selectedAdminId = value;
                        _error = null;
                      });
                    },
            ),
          const SizedBox(height: 16),
          TextField(
            controller: _securityCodeCtrl,
            enabled: !_submitting,
            autofocus: true,
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp(r'[A-Za-z0-9-]'),
              ),
              _UpperCaseTextFormatter(),
            ],
            decoration: const InputDecoration(
              labelText: 'Sigurnosni kod',
              hintText: 'XXXX-XXXX-XXXX-XXXX',
            ),
            onChanged: (_) {
              if (_error != null) {
                setState(() => _error = null);
              }
            },
            onSubmitted: (_) {
              if (_submitting) return;
              _submit(data);
            },
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RecoveryBootstrapData {
  const _RecoveryBootstrapData({
    required this.hasRecoveryCode,
    required this.administrators,
  });

  final bool hasRecoveryCode;
  final List<KorisniciData> administrators;
}

class _UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
