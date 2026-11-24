import 'package:flutter/material.dart';
import '../app.dart';
import '../data/emotions.dart';
import '../services/auth_service.dart';
import '../utils/validators.dart';
import '../widgets/common.dart';

Widget _header(BuildContext context, String title, String sub) => Column(children: [
      const AppLogo(),
      const SizedBox(height: 14),
      Text(title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
      const SizedBox(height: 4),
      Text(sub, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13)),
      const SizedBox(height: 22),
    ]);

InputDecoration _dec(String label, String hint, IconData icon, {Widget? suffix}) =>
    InputDecoration(labelText: label, hintText: hint, prefixIcon: Icon(icon), suffixIcon: suffix);

class _OrDivider extends StatelessWidget {
  const _OrDivider();
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(children: [
          const Expanded(child: Divider()),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text('or', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant))),
          const Expanded(child: Divider()),
        ]),
      );
}

class _GuestButton extends StatelessWidget {
  final VoidCallback onTap;
  const _GuestButton({required this.onTap});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(1.5),
        decoration: BoxDecoration(gradient: kGradient, borderRadius: BorderRadius.circular(16)),
        child: Material(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(14.5),
          child: InkWell(
            borderRadius: BorderRadius.circular(14.5),
            onTap: onTap,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.explore_outlined, color: kPurple, size: 20),
                SizedBox(width: 8),
                Text('Continue as Guest', style: TextStyle(color: kPurple, fontWeight: FontWeight.w700, fontSize: 15)),
              ]),
            ),
          ),
        ),
      );
}

class _Strength extends StatelessWidget {
  final TextEditingController c;
  const _Strength(this.c);
  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: c,
        builder: (_, __) {
          if (c.text.isEmpty) return const SizedBox.shrink();
          final s = passwordScore(c.text);
          final col = s <= 2 ? Colors.red : (s <= 4 ? Colors.orange : Colors.green);
          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(children: [
              Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(9), child: LinearProgressIndicator(value: s / 5, minHeight: 6, color: col, backgroundColor: Theme.of(context).colorScheme.outlineVariant))),
              const SizedBox(width: 10),
              Text(s <= 2 ? 'Weak' : (s <= 4 ? 'Medium' : 'Strong'), style: TextStyle(color: col, fontWeight: FontWeight.w700, fontSize: 12)),
            ]),
          );
        },
      );
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginState();
}

class _LoginState extends State<LoginScreen> {
  final _f = GlobalKey<FormState>();
  final _e = TextEditingController(), _p = TextEditingController();
  bool _hide = true, _busy = false;
  String? _err;

  Future<void> _go() async {
    if (!_f.currentState!.validate()) return;
    setState(() { _busy = true; _err = null; });
    try {
      await AuthService().login(_e.text.trim(), _p.text);
    } catch (e) {
      if (mounted) setState(() => _err = AuthService.friendly(e));
    }
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _forgot() async {
    if (validateEmail(_e.text) != null) {
      setState(() => _err = 'Type your email above first, then tap Forgot password.');
      return;
    }
    try {
      await AuthService().resetPassword(_e.text.trim());
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password reset link sent. Check your inbox.')));
    } catch (e) {
      if (mounted) setState(() => _err = AuthService.friendly(e));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(children: [
                _header(context, 'Welcome back', 'Login to continue to Ehsaas AI'),
                SoftCard(
                  child: Form(
                    key: _f,
                    child: Column(children: [
                      TextFormField(
                        controller: _e,
                        keyboardType: TextInputType.emailAddress,
                        decoration: _dec('Email', 'name@gmail.com', Icons.mail_outline),
                        validator: validateEmail,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _p,
                        obscureText: _hide,
                        decoration: _dec('Password', 'Enter your password', Icons.lock_outline, suffix: IconButton(icon: Icon(_hide ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _hide = !_hide))),
                        validator: (v) => (v ?? '').isEmpty ? 'Enter your password' : null,
                      ),
                      Align(alignment: Alignment.centerRight, child: TextButton(onPressed: _forgot, child: const Text('Forgot password?'))),
                      if (_err != null) Padding(padding: const EdgeInsets.only(bottom: 10), child: Text(_err!, style: const TextStyle(color: Colors.red))),
                      SizedBox(width: double.infinity, child: GradientButton(label: 'Login', loading: _busy, onTap: _go)),
                    ]),
                  ),
                ),
                const _OrDivider(),
                const SizedBox(height: 6),
                SizedBox(width: double.infinity, child: _GuestButton(onTap: () => appState.setGuest(true))),
                const SizedBox(height: 6),
                TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupScreen())),
                  child: const Text('New here? Create an account'),
                ),
              ]),
            ),
          ),
        ),
      );
}

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupState();
}

class _SignupState extends State<SignupScreen> {
  final _f = GlobalKey<FormState>();
  final _n = TextEditingController(), _e = TextEditingController(), _p = TextEditingController(), _c = TextEditingController();
  String? _role, _err;
  bool _hide = true, _busy = false;

  Future<void> _go() async {
    if (!_f.currentState!.validate()) return;
    setState(() { _busy = true; _err = null; });
    try {
      await AuthService().signUp(_n.text.trim(), _e.text.trim(), _p.text, _role!);
      if (!mounted) return;
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (d) => AlertDialog(
          title: const Text('Verify your email'),
          content: Text('We sent a verification link to ${_e.text.trim()}.\n\nOpen it (check Spam too), then login.'),
          actions: [TextButton(onPressed: () => Navigator.pop(d), child: const Text('OK'))],
        ),
      );
      if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
    } catch (e) {
      if (mounted) setState(() => _err = AuthService.friendly(e));
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              _header(context, 'Create account', 'Join Ehsaas AI to save your analyses'),
              SoftCard(
                child: Form(
                  key: _f,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(children: [
                    TextFormField(
                      controller: _n,
                      textCapitalization: TextCapitalization.words,
                      decoration: _dec('Full name', 'e.g. Ali Khan', Icons.person_outline),
                      validator: (v) => RegExp(r"^[\p{L} .'-]{2,}$", unicode: true).hasMatch((v ?? '').trim()) ? null : 'Enter your real name',
                    ),
                    const SizedBox(height: 14),
                    TextFormField(controller: _e, keyboardType: TextInputType.emailAddress, decoration: _dec('Email', 'name@gmail.com', Icons.mail_outline), validator: validateEmail),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      value: _role,
                      isExpanded: true,
                      decoration: _dec('Role', 'Select your role', Icons.badge_outlined),
                      hint: const Text('Select your role'),
                      items: roles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                      onChanged: (v) => setState(() => _role = v),
                      validator: (v) => v == null ? 'Please select your role' : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _p,
                      obscureText: _hide,
                      decoration: _dec('Password', '8+ chars, A-z, 0-9 and a symbol', Icons.lock_outline, suffix: IconButton(icon: Icon(_hide ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _hide = !_hide))),
                      validator: (v) => validatePassword(v, email: _e.text),
                    ),
                    _Strength(_p),
                    const SizedBox(height: 14),
                    TextFormField(controller: _c, obscureText: _hide, decoration: _dec('Confirm password', 'Re-enter your password', Icons.lock_reset), validator: (v) => v == _p.text ? null : 'Passwords do not match'),
                    if (_err != null) Padding(padding: const EdgeInsets.only(top: 10), child: Text(_err!, style: const TextStyle(color: Colors.red))),
                    const SizedBox(height: 16),
                    SizedBox(width: double.infinity, child: GradientButton(label: 'Sign Up', loading: _busy, onTap: _go)),
                  ]),
                ),
              ),
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Already have an account? Login')),
            ]),
          ),
        ),
      );
}
