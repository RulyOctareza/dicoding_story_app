import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/session_provider.dart';
import '../providers/locale_provider.dart';
import '../l10n/app_localizations.dart';
import '../utils/validation_utils.dart';
import '../widgets/form_fields.dart';

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
    final localeProvider = Provider.of<LocaleProvider>(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Language Switch
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(loc.translate('language')),
                    const SizedBox(width: 8),
                    Switch(
                      value: localeProvider.isIndonesian,
                      onChanged: (value) {
                        localeProvider.setLocale(value ? 'id' : 'en');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Icon(Icons.account_circle, size: 80),
                const SizedBox(height: 16),
                Text(
                  loc.translate('story_app'),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  loc.translate('please_register'),
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                CustomTextFormField(
                  controller: _nameController,
                  label: 'Name',
                  prefixIcon: Icons.person,
                  textInputAction: TextInputAction.next,
                  validator:
                      (value) =>
                          ValidationUtils.validateRequired(value, 'Name'),
                ),
                const SizedBox(height: 16),
                CustomTextFormField(
                  controller: _emailController,
                  label: loc.translate('email'),
                  prefixIcon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: ValidationUtils.validateEmail,
                ),
                const SizedBox(height: 16),
                CustomTextFormField(
                  controller: _passwordController,
                  label: loc.translate('password'),
                  prefixIcon: Icons.lock,
                  obscureText: _obscurePassword,
                  validator: ValidationUtils.validatePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 24),
                if (sessionProvider.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      sessionProvider.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        sessionProvider.isLoading
                            ? null
                            : () {
                              if (_formKey.currentState!.validate()) {
                                sessionProvider.register(
                                  _nameController.text,
                                  _emailController.text,
                                  _passwordController.text,
                                  context,
                                );
                              }
                            },
                    child:
                        sessionProvider.isLoading
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : Text(loc.translate('register')),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => sessionProvider.goToLogin(context),
                  child: Text(loc.translate('login')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
