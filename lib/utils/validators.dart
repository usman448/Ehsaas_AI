const _disposable = {
  'mailinator.com', 'tempmail.com', 'temp-mail.org', '10minutemail.com', 'guerrillamail.com', 'yopmail.com',
  'trashmail.com', 'sharklasers.com', 'getnada.com', 'dispostable.com', 'maildrop.cc', 'throwawaymail.com',
  'fakeinbox.com', 'mailnesia.com', 'tempail.com', 'emailondeck.com', 'mintemail.com', 'moakt.com',
  'burnermail.io', 'mohmal.com', 'tempmailo.com', 'mytemp.email', 'spamgourmet.com', 'tmpmail.org',
};
const _fakeDomains = {
  'example.com', 'example.org', 'example.net', 'test.com', 'domain.com', 'fake.com', 'dummy.com',
  'abc.com', 'xyz.com', 'asdf.com', 'temp.com', 'email.com', 'sample.com', 'mail.test', 'a.com',
};
const _typos = {
  'gmial.com': 'gmail.com', 'gmai.com': 'gmail.com', 'gamil.com': 'gmail.com', 'gmail.con': 'gmail.com',
  'gmail.co': 'gmail.com', 'gmaill.com': 'gmail.com', 'gnail.com': 'gmail.com', 'yaho.com': 'yahoo.com',
  'yahooo.com': 'yahoo.com', 'yahoo.con': 'yahoo.com', 'hotmial.com': 'hotmail.com', 'hotmal.com': 'hotmail.com',
  'outlok.com': 'outlook.com', 'outlook.con': 'outlook.com',
};
const _commonPasswords = {
  'password', 'password1', 'password123', '12345678', '123456789', 'qwerty123', 'iloveyou', 'admin123',
  'welcome1', 'abc12345', '11111111', '00000000', 'letmein123', 'pakistan123',
};

final _emailRe = RegExp(r'^[a-z0-9]+([._%+\-][a-z0-9]+)*@([a-z0-9]+(-[a-z0-9]+)*\.)+[a-z]{2,24}$');
final _dummyLocal = RegExp(r'^(test|tester|testing|demo|fake|dummy|sample|abc|abcd|asdf|qwerty|xyz|user|example|noreply|temp|mail|email)\d*$');

/// Catches wrong, dummy and disposable emails. The only way to be 100% sure an
/// address is real is the verification link that Firebase sends after sign up.
String? validateEmail(String? v) {
  final e = (v ?? '').trim().toLowerCase();
  if (e.isEmpty) return 'Enter your email address';
  if (!_emailRe.hasMatch(e)) return 'Enter a valid email address (e.g. name@gmail.com)';
  final i = e.indexOf('@');
  final local = e.substring(0, i), domain = e.substring(i + 1);
  if (_typos.containsKey(domain)) return 'Did you mean $local@${_typos[domain]}?';
  if (_disposable.contains(domain)) return 'Temporary / disposable emails are not allowed';
  if (_fakeDomains.contains(domain)) return 'Please use your real email address';
  if (local.length < 3 || RegExp(r'^(.)\1+$').hasMatch(local) || _dummyLocal.hasMatch(local) || !RegExp(r'[a-z]').hasMatch(local)) {
    return 'This looks like a dummy email. Use your real email';
  }
  return null;
}

int passwordScore(String p) =>
    [p.length >= 8, RegExp(r'[A-Z]').hasMatch(p), RegExp(r'[a-z]').hasMatch(p), RegExp(r'\d').hasMatch(p), RegExp(r'[^A-Za-z0-9]').hasMatch(p)].where((x) => x).length;

String? validatePassword(String? v, {String email = ''}) {
  final p = v ?? '';
  if (p.isEmpty) return 'Enter a password';
  if (p.length < 8) return 'Use at least 8 characters';
  if (p.contains(' ')) return 'Spaces are not allowed';
  if (!RegExp(r'[A-Z]').hasMatch(p)) return 'Add an uppercase letter (A-Z)';
  if (!RegExp(r'[a-z]').hasMatch(p)) return 'Add a lowercase letter (a-z)';
  if (!RegExp(r'\d').hasMatch(p)) return 'Add a number (0-9)';
  if (!RegExp(r'[^A-Za-z0-9]').hasMatch(p)) return 'Add a symbol (! @ # % & * ...)';
  if (_commonPasswords.contains(p.toLowerCase())) return 'This password is too common';
  final local = email.trim().toLowerCase().split('@').first;
  if (local.length >= 3 && p.toLowerCase().contains(local)) return 'Password must not contain your email name';
  return null;
}
