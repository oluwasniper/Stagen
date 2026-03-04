import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class LinkAccountDialog extends StatefulWidget {
  final Future<void> Function(String email, String password, String? name)
      onSubmit;
  const LinkAccountDialog({super.key, required this.onSubmit});

  @override
  State<LinkAccountDialog> createState() => _LinkAccountDialogState();
}

class _LinkAccountDialogState extends State<LinkAccountDialog> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String? _name;
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    _formKey.currentState!.save();
    try {
      setState(() => _error = null);
      await widget.onSubmit(_email, _password, _name);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.linkAccountTitle),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: l10n.linkAccountEmailLabel),
              keyboardType: TextInputType.emailAddress,
              validator: (v) =>
                  v == null || v.isEmpty ? l10n.linkAccountEmailRequired : null,
              onSaved: (v) => _email = v!.trim(),
            ),
            TextFormField(
              decoration: InputDecoration(
                labelText: l10n.linkAccountPasswordLabel,
                suffixIcon: IconButton(
                  icon:
                      Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              obscureText: _obscure,
              validator: (v) =>
                  v == null || v.length < 8 ? l10n.linkAccountPasswordMin : null,
              onSaved: (v) => _password = v!,
            ),
            TextFormField(
              decoration:
                  InputDecoration(labelText: l10n.linkAccountNameOptionalLabel),
              onSaved: (v) => _name = v?.trim(),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ]
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.pop(context),
          child: Text(l10n.linkAccountCancel),
        ),
        ElevatedButton(
          onPressed: _loading ? null : _submit,
          child: _loading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : Text(l10n.linkAccountAction),
        ),
      ],
    );
  }
}
