import 'package:flutter/material.dart';
import 'package:mujeeb24_app/app/localization/app_localizations.dart';
import 'package:mujeeb24_app/app/theme/app_theme.dart';
import 'package:mujeeb24_app/core/models/auth_models.dart';
import 'package:mujeeb24_app/features/auth/providers/auth_provider.dart';

class InvitationScreen extends StatefulWidget {
  final AuthProvider authProvider;
  final VoidCallback onBackToLogin;

  final String? initialToken;

  const InvitationScreen({
    super.key,
    required this.authProvider,
    required this.onBackToLogin,
    this.initialToken,
  });

  @override
  State<InvitationScreen> createState() => _InvitationScreenState();
}

class _InvitationScreenState extends State<InvitationScreen> {
  final _tokenController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _passwordController = TextEditingController();

  TeamInvitation? _inspectedInvitation;
  bool _isInspecting = false;
  bool _isAccepting = false;
  String? _localError;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    if (widget.initialToken != null && widget.initialToken!.isNotEmpty) {
      _tokenController.text = widget.initialToken!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _inspectToken();
      });
    }
  }

  @override
  void dispose() {
    _tokenController.dispose();
    _displayNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _inspectToken() async {
    final token = _tokenController.text.trim();
    if (token.isEmpty) {
      setState(() => _localError = 'يرجى إدخال رمز الدعوة');
      return;
    }

    setState(() {
      _isInspecting = true;
      _localError = null;
      _successMessage = null;
    });

    final inv = await widget.authProvider.inspectInvitation(token);
    setState(() {
      _isInspecting = false;
      _inspectedInvitation = inv;
      if (inv != null && inv.displayName.isNotEmpty) {
        _displayNameController.text = inv.displayName;
      }
    });
  }

  Future<void> _acceptInvitation() async {
    if (_inspectedInvitation == null) return;
    final token = _tokenController.text.trim();

    setState(() {
      _isAccepting = true;
      _localError = null;
      _successMessage = null;
    });

    bool ok = false;
    if (_inspectedInvitation!.accountState == 'new') {
      final name = _displayNameController.text.trim();
      final pass = _passwordController.text;
      if (name.isEmpty || pass.length < 12) {
        setState(() {
          _isAccepting = false;
          _localError =
              'كلمة المرور يجب أن تكون 12 حرفًا على الأقل والاسم مطلوب';
        });
        return;
      }
      ok = await widget.authProvider.acceptNewAccountInvitation(
        token: token,
        displayName: name,
        password: pass,
      );
    } else {
      // Existing account acceptance
      ok = await widget.authProvider.acceptTeamInvitation(token: token);
    }

    setState(() {
      _isAccepting = false;
      if (ok) {
        _successMessage = 'تم قبول الدعوة بنجاح! يمكنك الآن تسجيل الدخول.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    String strings(String key) => AppStrings.get(key, context);
    final auth = widget.authProvider;

    return Scaffold(
      appBar: AppBar(
        title: Text(strings('invitation_title')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: widget.onBackToLogin,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                strings('invitation_subtitle'),
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 16),

              // Token Field
              TextFormField(
                controller: _tokenController,
                decoration: InputDecoration(
                  labelText: strings('acceptance_token'),
                  hintText: 'inv_...',
                  prefixIcon: const Icon(Icons.vpn_key_outlined, size: 20),
                ),
              ),
              const SizedBox(height: 12),

              ElevatedButton(
                onPressed: _isInspecting ? null : _inspectToken,
                child: _isInspecting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(strings('inspect_token')),
              ),
              const SizedBox(height: 16),

              // Error banner
              if (_localError != null || auth.errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.statusErrorContainer,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.statusError.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    _localError ?? auth.errorMessage ?? '',
                    style: const TextStyle(
                      color: AppColors.statusError,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Success banner
              if (_successMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.statusSuccessContainer,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.statusSuccess.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    _successMessage!,
                    style: const TextStyle(
                      color: AppColors.statusSuccess,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Inspected Invitation Details Card
              if (_inspectedInvitation != null) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          strings('invitation_details'),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const Divider(height: 20),
                        _buildRow(
                          strings('business'),
                          _inspectedInvitation!.businessName,
                        ),
                        _buildRow(
                          strings('invited_email'),
                          _inspectedInvitation!.email,
                        ),
                        _buildRow(strings('role'), _inspectedInvitation!.role),
                        _buildRow(
                          'حالة الحساب',
                          _inspectedInvitation!.accountState,
                        ),
                        _buildRow(
                          strings('expires_at'),
                          _inspectedInvitation!.expiresAt,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Form for New Account or Button for Existing Account
                if (_inspectedInvitation!.accountState == 'new') ...[
                  TextFormField(
                    controller: _displayNameController,
                    decoration: InputDecoration(
                      labelText: strings('display_name'),
                      prefixIcon: const Icon(Icons.person_outline_rounded),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: strings('new_password'),
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isAccepting ? null : _acceptInvitation,
                    child: _isAccepting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(strings('accept_and_create')),
                  ),
                ] else ...[
                  ElevatedButton(
                    onPressed: _isAccepting ? null : _acceptInvitation,
                    child: _isAccepting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(strings('accept_existing')),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
