import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../../domain/entities/user.dart';

/// Écran d'attente de validation avec animation et mini-jeu.
/// 
/// Cette page utilise un polling périodique pour vérifier le statut de l'utilisateur
/// au lieu d'un listener Firestore en temps réel pour éviter les boucles infinies.
class WaitingApprovalScreen extends StatefulWidget {
  const WaitingApprovalScreen({super.key});

  @override
  State<WaitingApprovalScreen> createState() => _WaitingApprovalScreenState();
}

/// Représente une balle qui tombe dans le jeu.
class _FallingBall {
  double x; // Position horizontale (0.0 à 1.0)
  double y; // Position verticale (0.0 à 1.0)
  double speed; // Vitesse de chute
  final Color color;
  final int id;

  _FallingBall({
    required this.x,
    required this.y,
    required this.speed,
    required this.color,
    required this.id,
  });
}

class _WaitingApprovalScreenState extends State<WaitingApprovalScreen>
    with TickerProviderStateMixin {
  Timer? _checkTimer;
  late AnimationController _pulseController;
  late AnimationController _gameController;
  
  // État du jeu "Catch the Ball"
  bool _gameStarted = false;
  bool _gameOver = false;
  int _score = 0;
  int _missedBalls = 0;
  int _level = 1;
  double _basketPosition = 0.5; // Position du panier (0.0 à 1.0)
  List<_FallingBall> _balls = [];
  int _ballIdCounter = 0;
  DateTime? _lastBallSpawn;
  static const int _maxMissedBalls = 10; // Augmenté de 5 à 10
  
  // Flags de contrôle
  bool _isNavigating = false;
  bool _isChecking = false;
  DateTime? _lastCheckTime;

  @override
  void initState() {
    super.initState();

    // Animation de pulsation pour l'icône
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Animation pour le jeu (60 FPS)
    _gameController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..repeat();

    _gameController.addListener(_updateGame);

    // Vérifier immédiatement après le premier frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isNavigating) {
        _checkApprovalStatus();
      }
    });

    // Vérifier périodiquement (toutes les 5 secondes)
    _checkTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted && !_isNavigating && !_isChecking) {
        _checkApprovalStatus();
      }
    });
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    _pulseController.dispose();
    _gameController.dispose();
    _isNavigating = false;
    _isChecking = false;
    super.dispose();
  }

  /// Calcule la zone de capture en fonction du niveau (précision).
  /// Plus le niveau est élevé, plus la zone est petite (plus difficile).
  double _getBasketWidth() {
    // Zone initiale: 0.20 (20%), diminue progressivement jusqu'à 0.08 (8%) au niveau 10+
    return math.max(0.20 - (_level * 0.012), 0.08);
  }

  /// Calcule la vitesse du jeu en fonction du niveau.
  double _calculateGameSpeed() {
    // Vitesse initiale: 0.8, augmente progressivement jusqu'à 2.5 au niveau 10+
    return math.min(0.8 + (_level * 0.15), 2.5);
  }

  /// Met à jour l'état du jeu à chaque frame.
  void _updateGame() {
    if (!_gameStarted || _gameOver || _isNavigating || !mounted) return;

    final now = DateTime.now();
    
    // Calculer la vitesse actuelle en fonction du niveau
    final currentSpeed = _calculateGameSpeed();
    
    // Faire tomber les balles
    _balls.removeWhere((ball) {
      ball.y += ball.speed * currentSpeed;
      
      // Vérifier si la balle est attrapée par le panier
      // Zone de capture qui diminue avec le niveau (précision)
      if (ball.y >= 0.80) {
        final basketWidth = _getBasketWidth();
        final basketLeft = _basketPosition - (basketWidth / 2);
        final basketRight = _basketPosition + (basketWidth / 2);

        if (ball.x >= basketLeft && ball.x <= basketRight) {
          // Balle attrapée !
          setState(() {
            _score++;
            // Augmenter le niveau tous les 10 points pour une progression plus rapide
            if (_score > 0 && _score % 10 == 0) {
              _level++;
            }
          });
          return true; // Retirer la balle
        }
      }
      
      // Retirer la balle si elle est tombée en bas
      if (ball.y >= 1.0) {
        setState(() {
          _missedBalls++;
          if (_missedBalls >= _maxMissedBalls) {
            _gameOver = true;
          }
        });
        return true; // Retirer la balle
      }
      
      return false;
    });

    // Générer de nouvelles balles - intervalle qui diminue avec le niveau (plus de balles)
    // Intervalle initial: 800ms, diminue jusqu'à 300ms au niveau 10+
    final spawnInterval = math.max(800 - (_level * 50), 300).toInt();
    if (_lastBallSpawn == null ||
        now.difference(_lastBallSpawn!).inMilliseconds >= spawnInterval) {
      _spawnBall();
      _lastBallSpawn = now;
    }

    // Mettre à jour l'UI toutes les 2 frames (30 FPS)
    if (_gameController.value % 0.03 < 0.015 && mounted) {
      setState(() {
        // L'état est déjà mis à jour, on force juste le rebuild
      });
    }
  }

  /// Génère une nouvelle balle qui tombe.
  /// La vitesse de base augmente avec le niveau.
  void _spawnBall() {
    final random = math.Random();
    final colors = [
      const Color(0xFF314158),
      const Color(0xFF45556C),
      const Color(0xFFD97706), // Ambre
      const Color(0xFF4CAF50), // Vert
      const Color(0xFFF44336), // Rouge
    ];

    // Vitesse de base qui augmente avec le niveau
    // Niveau 1: 0.003-0.005, Niveau 10+: 0.006-0.010
    final baseSpeed = 0.003 + (_level * 0.0003);
    final speedVariation = 0.002 + (_level * 0.0002);

    _balls.add(_FallingBall(
      x: random.nextDouble() * 0.8 + 0.1, // Entre 0.1 et 0.9
      y: 0.0,
      speed: baseSpeed + (random.nextDouble() * speedVariation),
      color: colors[random.nextInt(colors.length)],
      id: _ballIdCounter++,
    ));
  }

  /// Vérifie le statut d'approbation de l'utilisateur de manière sécurisée.
  Future<void> _checkApprovalStatus() async {
    if (_isChecking || _isNavigating || !mounted) {
      return;
    }

    final now = DateTime.now();
    if (_lastCheckTime != null &&
        now.difference(_lastCheckTime!).inSeconds < 2) {
      return;
    }

    _isChecking = true;
    _lastCheckTime = now;

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.currentUser;
      
      if (user == null) {
        await authProvider.checkAuthStatus();
      }

      if (!mounted || _isNavigating) {
        _isChecking = false;
        return;
      }

      final currentUser = authProvider.currentUser;
      
      if (currentUser != null &&
          (currentUser.isApproved || currentUser.hasAdminAccess)) {
        _isNavigating = true;
        _isChecking = false;
        _checkTimer?.cancel();

        Future.microtask(() async {
          if (!mounted) return;

          try {
            final destination =
                currentUser.hasAdminAccess ? '/admin' : '/home';
            await Future.delayed(const Duration(milliseconds: 100));
            if (mounted) {
              context.go(destination);
            }
          } catch (e) {
            debugPrint('Erreur lors de la navigation: $e');
            if (mounted) {
              setState(() {
                _isNavigating = false;
              });
            }
          }
        });
      } else {
        _isChecking = false;
      }
    } catch (e) {
      debugPrint('Erreur lors de la vérification du statut: $e');
      _isChecking = false;
      if (mounted && _isNavigating) {
        setState(() {
          _isNavigating = false;
        });
      }
    }
  }

  void _startGame() {
    if (mounted && !_isNavigating) {
      setState(() {
        _gameStarted = true;
        _gameOver = false;
        _score = 0;
        _missedBalls = 0;
        _level = 1;
        _basketPosition = 0.5;
        _balls.clear();
        _lastBallSpawn = null;
        _ballIdCounter = 0;
      });
    }
  }

  void _resetGame() {
    _startGame();
  }

  void _onPanUpdate(DragUpdateDetails details, double gameWidth) {
    if (!_gameStarted || _gameOver || _isNavigating) return;

    final newPosition = (details.localPosition.dx / gameWidth).clamp(0.1, 0.9);
    setState(() {
      _basketPosition = newPosition;
    });
  }

  Future<void> _handleLogout() async {
    if (_isNavigating) return;

    _checkTimer?.cancel();
    _isNavigating = true;
    _isChecking = false;

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.signOut();

      if (mounted) {
        Future.microtask(() {
          if (mounted) {
            context.go('/login');
          }
        });
      }
    } catch (e) {
      debugPrint('Erreur lors de la déconnexion: $e');
      if (mounted) {
        setState(() {
          _isNavigating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              // Icône animée
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + (_pulseController.value * 0.1),
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFF314158).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.hourglass_empty,
                        size: 60,
                        color: Color(0xFF314158),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              const Text(
                'En attente de validation',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF314158),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Votre compte est en attente de validation par un administrateur.\n'
                'Vous recevrez une notification une fois votre compte approuvé.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6A7282),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              // Mini-jeu interactif
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      '🎮 Attrape les balles !',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF314158),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            const Text(
                              'Score',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6A7282),
                              ),
                            ),
                            Text(
                              '$_score',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF314158),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            const Text(
                              'Niveau',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6A7282),
                              ),
                            ),
                            Text(
                              '$_level',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF314158),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            const Text(
                              'Ratées',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6A7282),
                              ),
                            ),
                            Text(
                              '$_missedBalls/$_maxMissedBalls',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: _missedBalls >= (_maxMissedBalls * 0.7).round()
                                    ? Colors.red
                                    : const Color(0xFF314158),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Zone de jeu
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final gameWidth = constraints.maxWidth;
                        final gameHeight = 300.0;

                        return GestureDetector(
                          onTap: () {
                            if (!_gameStarted) {
                              _startGame();
                            }
                          },
                          onPanUpdate: (details) =>
                              _onPanUpdate(details, gameWidth),
                          child: Container(
                            height: gameHeight,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFE5E7EB),
                                width: 2,
                              ),
                            ),
                            child: Stack(
                              children: [
                                // Balles qui tombent
                                ..._balls.map((ball) {
                                  return Positioned(
                                    left: ball.x * gameWidth - 15,
                                    top: ball.y * gameHeight,
                                    child: Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: ball.color,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: ball.color.withOpacity(0.5),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.sports_soccer,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  );
                                }),
                                // Panier en bas - plus large pour faciliter la capture
                                Positioned(
                                  left: (_basketPosition - 0.15) * gameWidth,
                                  top: gameHeight * 0.80,
                                  child: Container(
                                    width: gameWidth * 0.3, // Panier plus large (30% au lieu de 20%)
                                    height: 30, // Plus haut aussi
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF314158),
                                          Color(0xFF45556C),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF314158)
                                              .withOpacity(0.4),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.shopping_basket,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                // Écran de démarrage
                                if (!_gameStarted)
                                  Container(
                                    color: Colors.white.withOpacity(0.9),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.play_circle_outline,
                                            size: 64,
                                            color: Color(0xFF314158),
                                          ),
                                          const SizedBox(height: 16),
                                          const Text(
                                            'Appuyez pour commencer',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF314158),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          const Text(
                                            'Déplacez le panier pour attraper les balles',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF6A7282),
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                // Écran de fin de jeu
                                if (_gameOver)
                                  Container(
                                    color: Colors.white.withOpacity(0.95),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.sentiment_dissatisfied,
                                            size: 64,
                                            color: Colors.red,
                                          ),
                                          const SizedBox(height: 16),
                                          const Text(
                                            'Game Over !',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Score final: $_score',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Color(0xFF314158),
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          ElevatedButton.icon(
                                            onPressed: _resetGame,
                                            icon: const Icon(Icons.refresh),
                                            label: const Text('Rejouer'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color(0xFF314158),
                                              foregroundColor: Colors.white,
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
                      },
                    ),
                    const SizedBox(height: 16),
                    if (!_gameStarted)
                      const Text(
                        'Appuyez sur la zone de jeu pour commencer',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6A7282),
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      )
                    else if (!_gameOver)
                      const Text(
                        'Glissez pour déplacer le panier',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6A7282),
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Bouton de déconnexion
              TextButton(
                onPressed: _isNavigating ? null : _handleLogout,
                child: const Text(
                  'Se déconnecter',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6A7282),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
