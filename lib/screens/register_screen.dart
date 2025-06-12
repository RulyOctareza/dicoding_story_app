import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/session_provider.dart';
import '../l10n/app_localizations.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final sessionProvider = Provider.of<SessionProvider>(context);
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.account_circle, size: 80),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    border: const OutlineInputBorder(),
                  ),
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Name required'
                              : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: loc.translate('email'),
                    border: const OutlineInputBorder(),
                  ),
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Email required'
                              : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: loc.translate('password'),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed:
                          () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                    ),
                  ),
                  validator:
                      (value) =>
                          value == null || value.length < 8
                              ? 'Password min 8 chars'
                              : null,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        sessionProvider.isLoading
                            ? null
                            : () async {
                              if (_formKey.currentState!.validate()) {
                                await sessionProvider.register(
                                  _nameController.text,
                                  _emailController.text,
                                  _passwordController.text,
                                  context,
                                );
                              }
                            },
                    child:
                        sessionProvider.isLoading
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : Text(loc.translate('register')),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => sessionProvider.goToLogin(context),
                  child: Text(loc.translate('login')),
                ),
                if (sessionProvider.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      sessionProvider.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
