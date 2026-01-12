import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/auth_provider.dart';
import '../../../core/utils/validators.dart';

/// Écran de connexion pour les chefs.
/// Design basé sur Figma: https://www.figma.com/design/03zvjavliXw3YANvKL3Ino/Untitled?node-id=36-2
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRememberedCredentials();
  }

  /// Charge les identifiants sauvegardés si "Se souvenir de moi" était coché
  Future<void> _loadRememberedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final remembered = prefs.getBool('remember_me') ?? false;
    if (remembered) {
      setState(() {
        _rememberMe = true;
        _emailController.text = prefs.getString('saved_email') ?? '';
        _passwordController.text = prefs.getString('saved_password') ?? '';
      });
    }
  }

  /// Sauvegarde les identifiants si "Se souvenir de moi" est coché
  Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setBool('remember_me', true);
      await prefs.setString('saved_email', _emailController.text.trim());
      await prefs.setString('saved_password', _passwordController.text);
    } else {
      await prefs.setBool('remember_me', false);
      await prefs.remove('saved_email');
      await prefs.remove('saved_password');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Désactiver le clavier
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    // Sauvegarder les identifiants si "Se souvenir de moi" est coché
    await _saveCredentials();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      final success = await authProvider.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      if (success) {
        // Le router va automatiquement rediriger grâce à refreshListenable: authProvider
        // Pas besoin de redirection manuelle, le redirect du router s'en charge
        setState(() {
          _isLoading = false;
        });
        // Le router détectera le changement d'état et redirigera automatiquement
      } else {
        // Afficher l'erreur seulement en cas d'échec
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          // Récupérer l'erreur du provider
          final errorMessage = authProvider.error ?? 'Erreur de connexion';
          
          // Afficher le message d'erreur
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur inattendue: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
        ),
      );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
      return PopScope(
      // Empêcher la déconnexion en appuyant sur le bouton retour
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        // Si l'utilisateur appuie sur retour depuis le login, minimiser l'app
        // Cela garde la session active (Firebase Auth persiste automatiquement)
        SystemNavigator.pop();
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Fond avec gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: const [0.0, 0.5, 1.0],
                  colors: [
                    const Color(0xFF314158), // #314158
                    const Color(0xFF1D293D), // #1D293D
                    const Color(0xFF101828), // #101828
                  ],
                ),
              ),
              child: SafeArea(
                child: Stack(
                  children: [
                    // Effets de blur en arrière-plan (approximation)
                    Positioned(
                      left: 33,
                      top: 73,
                      child: Container(
                        width: 302,
                        height: 302,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05 * 0.323),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      left: -67,
                      top: 472,
                      child: Container(
                        width: 418,
                        height: 418,
                        decoration: BoxDecoration(
                          color: const Color(0xFF62748E).withOpacity(0.1 * 0.258),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    // Contenu principal
                    Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 16),
                              // Logo dans un conteneur blanc arrondi
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.25),
                                      blurRadius: 25,
                                      offset: const Offset(0, 12),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.flag,
                                  size: 40,
                                  color: Color(0xFF314158),
                                ),
                              ),
                              const SizedBox(height: 24),
                              // Titre "Scout Manager"
                              const Text(
                                'Scout Manager',
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white,
                                  letterSpacing: 0,
                                  height: 1.11, // 40/36
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              // Sous-titre
                              Text(
                                'Gestion administrative des groupes scouts',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: const Color(0xFFCAD5E2), // #cad5e2
                                  letterSpacing: 0,
                                  height: 1.5, // 24/16
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 32),
                              // Formulaire de connexion dans un conteneur blanc
                              Container(
                                padding: const EdgeInsets.all(32),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.95),
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.25),
                                      blurRadius: 25,
                                      offset: const Offset(0, 12),
                                    ),
                                  ],
                                ),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      // Titre "Connexion"
                                      const Text(
                                        'Connexion',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.normal,
                                          color: Color(0xFF0A0A0A),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 24),
                                      // Champ Email
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Email',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF364153),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          TextFormField(
                                            controller: _emailController,
                                            decoration: InputDecoration(
                                              hintText: 'votre.email@exemple.com',
                                              hintStyle: const TextStyle(
                                                color: Color(0xFF717182),
                                                fontSize: 16,
                                              ),
                                              prefixIcon: const Icon(
                                                Icons.email_outlined,
                                                size: 20,
                                                color: Color(0xFF717182),
                                              ),
                                              filled: true,
                                              fillColor: const Color(0xFFF3F3F5),
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(14),
                                                borderSide: const BorderSide(
                                                  color: Color(0xFFE5E7EB),
                                                  width: 1.219,
                                                ),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(14),
                                                borderSide: const BorderSide(
                                                  color: Color(0xFFE5E7EB),
                                                  width: 1.219,
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(14),
                                                borderSide: const BorderSide(
                                                  color: Color(0xFF314158),
                                                  width: 1.219,
                                                ),
                                              ),
                                              contentPadding: const EdgeInsets.symmetric(
                                                horizontal: 40,
                                                vertical: 12,
                                              ),
                                            ),
                                            keyboardType: TextInputType.emailAddress,
                                            textInputAction: TextInputAction.next,
                                            autovalidateMode:
                                                AutovalidateMode.onUserInteraction,
                                            validator: Validators.validateEmail,
                                          ),
                                    ],
                                ),
                                const SizedBox(height: 16),
                                // Champ Mot de passe
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Mot de passe',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF364153),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: _passwordController,
                                      obscureText: _obscurePassword,
                                      enabled: !_isLoading,
                                      decoration: InputDecoration(
                                        hintText: '••••••••',
                                        hintStyle: const TextStyle(
                                          color: Color(0xFF717182),
                                          fontSize: 16,
                                        ),
                                        prefixIcon: const Icon(
                                          Icons.lock_outlined,
                                          size: 20,
                                          color: Color(0xFF717182),
                                        ),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscurePassword
                                                ? Icons.visibility_outlined
                                                : Icons.visibility_off_outlined,
                                            size: 20,
                                            color: const Color(0xFF717182),
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _obscurePassword = !_obscurePassword;
                                            });
                                          },
                                        ),
                                        filled: true,
                                        fillColor: const Color(0xFFF3F3F5),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(14),
                                          borderSide: const BorderSide(
                                            color: Color(0xFFE5E7EB),
                                            width: 1.219,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(14),
                                          borderSide: const BorderSide(
                                            color: Color(0xFFE5E7EB),
                                            width: 1.219,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(14),
                                          borderSide: const BorderSide(
                                            color: Color(0xFF314158),
                                            width: 1.219,
                                          ),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 40,
                                          vertical: 12,
                                        ),
                                      ),
                                      textInputAction: TextInputAction.done,
                                      onFieldSubmitted: (_) => _handleLogin(),
                                      autovalidateMode:
                                          AutovalidateMode.onUserInteraction,
                                      validator: (value) =>
                                          Validators.validateRequired(
                                        value,
                                        'Mot de passe',
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                // "Se souvenir de moi" et "Mot de passe oublié ?"
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: Checkbox(
                                              value: _rememberMe,
                                              onChanged: _isLoading
                                                  ? null
                                                  : (value) {
                                                      setState(() {
                                                        _rememberMe = value ?? false;
                                                      });
                                                    },
                                              activeColor: const Color(0xFF314158),
                                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                              visualDensity: VisualDensity.compact,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Flexible(
                                            child: Text(
                                              'Se souvenir de moi',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Color(0xFF4A5565),
                                                height: 1.5, // 24/16
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: _isLoading
                                          ? null
                                          : () {
                                              // TODO: Implémenter la réinitialisation du mot de passe
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Fonctionnalité à venir'),
                                                ),
                                              );
                                            },
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: Size.zero,
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: const Text(
                                        'Mot de passe oublié ?',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Color(0xFF45556C),
                                          height: 1.5, // 24/16
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                // Bouton "Se connecter" avec dégradé
                                Container(
                                  height: 48,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF45556C),
                                        Color(0xFF314158),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 10,
                                        offset: const Offset(0, 3),
                                      ),
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 4,
                                        offset: const Offset(0, -4),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _handleLogin,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                            ),
                                          )
                                        : const Text(
                                            'Se connecter',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.white,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    // Séparateur "OU"
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        const Divider(
                                          color: Color(0xFFE5E7EB),
                                          thickness: 1.219,
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                          ),
                                          color: Colors.white.withOpacity(0.95),
                                          child: const Text(
                                            'OU',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF6A7282),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),
                                    // Bouton "Se connecter avec Google"
                                    Container(
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: const Color(0xFFE5E7EB),
                                          width: 1.219,
                                        ),
                                      ),
                                      child: ElevatedButton.icon(
                                        onPressed: _isLoading
                                            ? null
                                            : () {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text('Fonctionnalité à venir'),
                                                    backgroundColor: Colors.orange,
                                                    duration: Duration(seconds: 2),
                                                  ),
                                                );
                                              },
                                        icon: Container(
                                          width: 16,
                                          height: 16,
                                          margin: const EdgeInsets.only(right: 8),
                                          child: Image.asset(
                                            'assets/icons/google.png',
                                            width: 16,
                                            height: 16,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                        label: const Text(
                                          'Se connecter avec Google',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF0A0A0A),
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          shadowColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    // Bouton "Créer un compte"
                                    TextButton(
                                      onPressed: _isLoading
                                          ? null
                                          : () => context.push('/signup'),
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        minimumSize: Size.zero,
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: const Text(
                                        'Créer un compte',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF4A5565),
                                        ),
                                      ),
                                    ),
                                    ],
                                  ),
                                ),
                              ),
                            ]
                          ),
                  
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
