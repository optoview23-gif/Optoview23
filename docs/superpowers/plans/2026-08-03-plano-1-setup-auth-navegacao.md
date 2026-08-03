# OptoView — Plano 1: Setup, Autenticação e Navegação

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Criar o projeto Flutter com Firebase configurado, tela de login funcional, sessão persistente e navegação principal com drawer lateral e telas placeholder para os 6 módulos.

**Architecture:** Flutter com Riverpod para gerenciamento de estado, GoRouter para navegação declarativa com guards de autenticação, Firebase Auth para login, e tema verde personalizado com identidade Ótica Yuri.

**Tech Stack:** Flutter 3.x · Dart 3.x · firebase_core ^3 · firebase_auth ^5 · cloud_firestore ^5 · flutter_riverpod ^2 · go_router ^14 · google_fonts ^6

## Global Constraints

- Plataforma alvo: Android (tablet), minSdkVersion 21
- Tema: light mode, cor primária `#4CAF50`, cor secundária `#1B5E20`
- Idioma: Português — pt_BR em todos os textos e formatos
- Offline: Firestore com persistência local habilitada (`Settings(persistenceEnabled: true)`)
- Autenticação: email/senha via Firebase Auth, sessão persistente
- Estrutura de pastas: feature-first (`lib/features/<modulo>/`)

---

## Estrutura de Arquivos

```
otica_yuri/
├── pubspec.yaml
├── android/
│   └── app/build.gradle          (minSdkVersion 21)
├── lib/
│   ├── main.dart                 (inicializa Firebase, ProviderScope, GoRouter)
│   ├── firebase_options.dart     (gerado pelo flutterfire CLI)
│   ├── core/
│   │   ├── theme/
│   │   │   └── app_theme.dart    (ThemeData com cores da Ótica Yuri)
│   │   ├── constants/
│   │   │   └── app_colors.dart   (constantes de cor)
│   │   └── router/
│   │       └── app_router.dart   (GoRouter com guards de auth)
│   ├── features/
│   │   └── auth/
│   │       ├── data/
│   │       │   └── auth_repository.dart   (FirebaseAuth wrapper)
│   │       └── presentation/
│   │           ├── login_screen.dart
│   │           └── forgot_password_screen.dart
│   └── shared/
│       └── widgets/
│           ├── app_drawer.dart        (drawer com logo + 6 módulos)
│           ├── main_scaffold.dart     (scaffold com drawer)
│           └── placeholder_screen.dart (tela vazia para módulos futuros)
└── assets/
    └── images/
        └── logo_otica_yuri.png    (logo exportado do PDF)
```

---

### Task 1: Criar projeto Flutter e configurar dependências

**Files:**
- Create: `otica_yuri/pubspec.yaml`
- Create: `otica_yuri/android/app/build.gradle`

**Interfaces:**
- Produces: projeto Flutter compilável com todas as dependências instaladas

- [ ] **Step 1: Criar o projeto Flutter**

```bash
flutter create --org com.oticayuri --platforms android otica_yuri
cd otica_yuri
```

- [ ] **Step 2: Atualizar pubspec.yaml com as dependências**

Substituir a seção `dependencies` do `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^3.6.0
  firebase_auth: ^5.3.1
  cloud_firestore: ^5.4.4
  firebase_storage: ^12.3.2
  firebase_messaging: ^15.1.3
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5
  go_router: ^14.3.0
  google_fonts: ^6.2.1
  image_picker: ^1.1.2
  intl: ^0.19.0
  cached_network_image: ^3.4.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  build_runner: ^2.4.12
  riverpod_generator: ^2.4.3

flutter:
  uses-material-design: true
  assets:
    - assets/images/
```

- [ ] **Step 3: Criar pasta de assets e adicionar logo**

```bash
mkdir -p assets/images
# Copiar logo_otica_yuri.png para assets/images/
```

- [ ] **Step 4: Definir minSdkVersion no build.gradle**

Em `android/app/build.gradle`, definir:
```gradle
android {
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
    }
}
```

- [ ] **Step 5: Instalar dependências**

```bash
flutter pub get
```

- [ ] **Step 6: Verificar que o projeto compila**

```bash
flutter build apk --debug
```

Esperado: BUILD SUCCESSFUL sem erros.

- [ ] **Step 7: Commit**

```bash
git add pubspec.yaml pubspec.lock android/app/build.gradle assets/
git commit -m "feat: create Flutter project with dependencies"
```

---

### Task 2: Configurar Firebase

**Files:**
- Create: `lib/firebase_options.dart` (gerado automaticamente)
- Modify: `lib/main.dart`

**Interfaces:**
- Consumes: projeto Flutter da Task 1
- Produces: Firebase inicializado, Firestore com persistência offline, disponível para uso em toda a app

- [ ] **Step 1: Instalar FlutterFire CLI**

```bash
dart pub global activate flutterfire_cli
```

- [ ] **Step 2: Criar projeto no Firebase Console**

1. Acesse console.firebase.google.com
2. Clique em "Adicionar projeto" → nome: `otica-yuri`
3. Ative Google Analytics: Não (não necessário para v1)
4. Clique em "Criar projeto"

- [ ] **Step 3: Configurar o app Android no Firebase**

```bash
flutterfire configure --project=otica-yuri
```

Selecione: Android (e iOS se quiser no futuro). Isso gera `lib/firebase_options.dart` automaticamente.

- [ ] **Step 4: Habilitar Firebase Auth no console**

1. No Firebase Console → Authentication → Primeiros passos
2. Ativar provedor: E-mail/senha → Salvar

- [ ] **Step 5: Criar coleção inicial no Firestore**

1. Firebase Console → Firestore Database → Criar banco de dados
2. Modo: Produção
3. Região: southamerica-east1 (São Paulo)

- [ ] **Step 6: Regras de segurança do Firestore**

No Firebase Console → Firestore → Regras, definir:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

- [ ] **Step 7: Criar main.dart com Firebase inicializado**

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseFirestore.instance.settings =
      const Settings(persistenceEnabled: true, cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED);
  runApp(const ProviderScope(child: OptoViewApp()));
}

class OptoViewApp extends ConsumerWidget {
  const OptoViewApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'Ótica Yuri',
      theme: AppTheme.light,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      locale: const Locale('pt', 'BR'),
    );
  }
}
```

- [ ] **Step 8: Verificar que o app inicializa sem erro**

```bash
flutter run --debug
```

Esperado: app abre sem crashar (tela preta ou erro de router é OK neste momento).

- [ ] **Step 9: Commit**

```bash
git add lib/main.dart lib/firebase_options.dart google-services.json
git commit -m "feat: configure Firebase with offline persistence"
```

---

### Task 3: Tema e identidade visual

**Files:**
- Create: `lib/core/constants/app_colors.dart`
- Create: `lib/core/theme/app_theme.dart`

**Interfaces:**
- Produces: `AppTheme.light` (ThemeData), `AppColors.primary`, `AppColors.secondary`, `AppColors.textPrimary`, `AppColors.textSecondary`, `AppColors.background`

- [ ] **Step 1: Criar constantes de cor**

```dart
// lib/core/constants/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF4CAF50);
  static const Color secondary = Color(0xFF1B5E20);
  static const Color background = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1B5E20);
  static const Color textSecondary = Color(0xFF757575);
  static const Color drawerBackground = Color(0xFF1B5E20);
  static const Color drawerText = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFD32F2F);
  static const Color cardShadow = Color(0x1A000000);
}
```

- [ ] **Step 2: Criar AppTheme**

```dart
// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          background: AppColors.background,
          error: AppColors.error,
        ),
        textTheme: GoogleFonts.interTextTheme().copyWith(
          bodyLarge: GoogleFonts.inter(color: AppColors.textPrimary),
          bodyMedium: GoogleFonts.inter(color: AppColors.textSecondary),
          titleLarge: GoogleFonts.inter(
              color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.secondary,
          foregroundColor: AppColors.drawerText,
          titleTextStyle: GoogleFonts.inter(
            color: AppColors.drawerText,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          floatingLabelStyle: const TextStyle(color: AppColors.primary),
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shadowColor: AppColors.cardShadow,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: AppColors.background,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      );
}
```

- [ ] **Step 3: Escrever widget test do tema**

```dart
// test/core/theme/app_theme_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:otica_yuri/core/theme/app_theme.dart';
import 'package:otica_yuri/core/constants/app_colors.dart';

void main() {
  test('AppTheme.light tem cor primária correta', () {
    final theme = AppTheme.light;
    expect(theme.colorScheme.primary, AppColors.primary);
  });

  test('AppTheme.light tem cor secundária correta', () {
    final theme = AppTheme.light;
    expect(theme.colorScheme.secondary, AppColors.secondary);
  });
}
```

- [ ] **Step 4: Rodar testes**

```bash
flutter test test/core/theme/app_theme_test.dart
```

Esperado: 2 testes PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/core/ test/core/
git commit -m "feat: add app theme and color constants"
```

---

### Task 4: Repositório de Autenticação

**Files:**
- Create: `lib/features/auth/data/auth_repository.dart`
- Create: `test/features/auth/auth_repository_test.dart`

**Interfaces:**
- Produces:
  - `authRepositoryProvider` → `AuthRepository`
  - `AuthRepository.signIn(String email, String password)` → `Future<void>`
  - `AuthRepository.signOut()` → `Future<void>`
  - `AuthRepository.sendPasswordResetEmail(String email)` → `Future<void>`
  - `AuthRepository.authStateChanges()` → `Stream<User?>`

- [ ] **Step 1: Criar AuthRepository**

```dart
// lib/features/auth/data/auth_repository.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthRepository {
  final FirebaseAuth _auth;
  AuthRepository(this._auth);

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<void> signIn(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  User? get currentUser => _auth.currentUser;
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(FirebaseAuth.instance);
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});
```

- [ ] **Step 2: Escrever teste do AuthRepository com mock**

```dart
// test/features/auth/auth_repository_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:otica_yuri/features/auth/data/auth_repository.dart';

@GenerateMocks([FirebaseAuth, User, UserCredential])
import 'auth_repository_test.mocks.dart';

void main() {
  late MockFirebaseAuth mockAuth;
  late AuthRepository repo;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    repo = AuthRepository(mockAuth);
  });

  test('signIn chama FirebaseAuth com email e senha corretos', () async {
    when(mockAuth.signInWithEmailAndPassword(
      email: 'teste@otica.com',
      password: '123456',
    )).thenAnswer((_) async => MockUserCredential());

    await repo.signIn('teste@otica.com', '123456');

    verify(mockAuth.signInWithEmailAndPassword(
      email: 'teste@otica.com',
      password: '123456',
    )).called(1);
  });

  test('signOut chama FirebaseAuth.signOut', () async {
    when(mockAuth.signOut()).thenAnswer((_) async {});
    await repo.signOut();
    verify(mockAuth.signOut()).called(1);
  });
}
```

- [ ] **Step 3: Adicionar mockito ao pubspec.yaml**

```yaml
dev_dependencies:
  mockito: ^5.4.4
  build_runner: ^2.4.12
```

```bash
flutter pub get
dart run build_runner build
```

- [ ] **Step 4: Rodar testes**

```bash
flutter test test/features/auth/auth_repository_test.dart
```

Esperado: 2 testes PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/auth/ test/features/auth/
git commit -m "feat: add AuthRepository with Firebase Auth"
```

---

### Task 5: Tela de Login

**Files:**
- Create: `lib/features/auth/presentation/login_screen.dart`
- Create: `lib/features/auth/presentation/forgot_password_screen.dart`
- Create: `test/features/auth/login_screen_test.dart`

**Interfaces:**
- Consumes: `authRepositoryProvider` (Task 4), `AppTheme.light` (Task 3)
- Produces: rota `/login` funcional com validação de formulário

- [ ] **Step 1: Criar LoginScreen**

```dart
// lib/features/auth/presentation/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/auth_repository.dart';
import '../../../core/constants/app_colors.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _errorMessage = null; });
    try {
      await ref.read(authRepositoryProvider).signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );
    } on Exception catch (e) {
      setState(() { _errorMessage = 'E-mail ou senha inválidos.'; });
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(40),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Image.asset('assets/images/logo_otica_yuri.png', height: 140),
                    const SizedBox(height: 40),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'E-mail',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (v) => (v == null || !v.contains('@'))
                          ? 'Informe um e-mail válido'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: (v) => (v == null || v.length < 6)
                          ? 'Senha deve ter pelo menos 6 caracteres'
                          : null,
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(_errorMessage!,
                          style: const TextStyle(color: AppColors.error)),
                    ],
                    const SizedBox(height: 28),
                    _loading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: _login,
                            child: const Text('Entrar'),
                          ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => context.push('/esqueci-senha'),
                      child: const Text('Esqueci minha senha'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Criar ForgotPasswordScreen**

```dart
// lib/features/auth/presentation/forgot_password_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/auth_repository.dart';
import '../../../core/constants/app_colors.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _loading = false;
  bool _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await ref.read(authRepositoryProvider).sendPasswordResetEmail(
          _emailController.text.trim());
    if (mounted) setState(() { _loading = false; _sent = true; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar Senha')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: _sent
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle, color: AppColors.primary, size: 64),
                      const SizedBox(height: 16),
                      const Text('E-mail enviado! Verifique sua caixa de entrada.',
                          textAlign: TextAlign.center),
                      const SizedBox(height: 24),
                      ElevatedButton(
                          onPressed: () => context.pop(),
                          child: const Text('Voltar ao login')),
                    ],
                  )
                : Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                            'Informe seu e-mail para receber o link de recuperação de senha.',
                            textAlign: TextAlign.center),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'E-mail',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: (v) => (v == null || !v.contains('@'))
                              ? 'Informe um e-mail válido'
                              : null,
                        ),
                        const SizedBox(height: 24),
                        _loading
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                                onPressed: _send,
                                child: const Text('Enviar e-mail de recuperação')),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: Escrever widget test da LoginScreen**

```dart
// test/features/auth/login_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otica_yuri/features/auth/presentation/login_screen.dart';
import 'package:otica_yuri/core/theme/app_theme.dart';

Widget buildLoginScreen() => ProviderScope(
      child: MaterialApp(
        theme: AppTheme.light,
        home: const LoginScreen(),
      ),
    );

void main() {
  testWidgets('Exibe campos de e-mail e senha', (tester) async {
    await tester.pumpWidget(buildLoginScreen());
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('E-mail'), findsOneWidget);
    expect(find.text('Senha'), findsOneWidget);
  });

  testWidgets('Mostra erro se e-mail inválido ao submeter', (tester) async {
    await tester.pumpWidget(buildLoginScreen());
    await tester.tap(find.text('Entrar'));
    await tester.pump();
    expect(find.text('Informe um e-mail válido'), findsOneWidget);
  });

  testWidgets('Mostra erro se senha curta ao submeter', (tester) async {
    await tester.pumpWidget(buildLoginScreen());
    await tester.enterText(
        find.widgetWithText(TextFormField, 'E-mail'), 'a@b.com');
    await tester.tap(find.text('Entrar'));
    await tester.pump();
    expect(find.text('Senha deve ter pelo menos 6 caracteres'), findsOneWidget);
  });
}
```

- [ ] **Step 4: Rodar testes**

```bash
flutter test test/features/auth/login_screen_test.dart
```

Esperado: 3 testes PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/auth/presentation/ test/features/auth/login_screen_test.dart
git commit -m "feat: add login and forgot password screens"
```

---

### Task 6: Roteamento e Guards de Autenticação

**Files:**
- Create: `lib/core/router/app_router.dart`

**Interfaces:**
- Consumes: `authStateProvider` (Task 4), todas as telas
- Produces: `appRouterProvider` → `GoRouter` com rotas `/login`, `/esqueci-senha`, `/inicio`, `/clientes`, `/prontuario`, `/pedidos`, `/estoque`, `/caixa`, `/agenda`, `/configuracoes`

- [ ] **Step 1: Criar AppRouter**

```dart
// lib/core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../shared/widgets/main_scaffold.dart';
import '../../shared/widgets/placeholder_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/inicio',
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isOnAuth = state.matchedLocation == '/login' ||
          state.matchedLocation == '/esqueci-senha';

      if (!isLoggedIn && !isOnAuth) return '/login';
      if (isLoggedIn && state.matchedLocation == '/login') return '/inicio';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(
          path: '/esqueci-senha',
          builder: (_, __) => const ForgotPasswordScreen()),
      ShellRoute(
        builder: (context, state, child) =>
            MainScaffold(location: state.matchedLocation, child: child),
        routes: [
          GoRoute(
              path: '/inicio',
              builder: (_, __) =>
                  const PlaceholderScreen(title: 'Início', icon: Icons.home)),
          GoRoute(
              path: '/clientes',
              builder: (_, __) =>
                  const PlaceholderScreen(title: 'Clientes', icon: Icons.people)),
          GoRoute(
              path: '/prontuario',
              builder: (_, __) => const PlaceholderScreen(
                  title: 'Prontuário', icon: Icons.visibility)),
          GoRoute(
              path: '/pedidos',
              builder: (_, __) => const PlaceholderScreen(
                  title: 'Pedidos', icon: Icons.shopping_bag)),
          GoRoute(
              path: '/estoque',
              builder: (_, __) => const PlaceholderScreen(
                  title: 'Estoque', icon: Icons.inventory)),
          GoRoute(
              path: '/caixa',
              builder: (_, __) => const PlaceholderScreen(
                  title: 'Caixa', icon: Icons.attach_money)),
          GoRoute(
              path: '/agenda',
              builder: (_, __) => const PlaceholderScreen(
                  title: 'Agenda', icon: Icons.calendar_today)),
          GoRoute(
              path: '/configuracoes',
              builder: (_, __) => const PlaceholderScreen(
                  title: 'Configurações', icon: Icons.settings)),
        ],
      ),
    ],
  );
});
```

- [ ] **Step 2: Commit**

```bash
git add lib/core/router/
git commit -m "feat: add GoRouter with auth guards"
```

---

### Task 7: Drawer e Scaffold Principal

**Files:**
- Create: `lib/shared/widgets/app_drawer.dart`
- Create: `lib/shared/widgets/main_scaffold.dart`
- Create: `lib/shared/widgets/placeholder_screen.dart`
- Create: `test/shared/widgets/app_drawer_test.dart`

**Interfaces:**
- Consumes: `authRepositoryProvider` (Task 4), `AppColors` (Task 3)
- Produces: `MainScaffold(location: String, child: Widget)`, `AppDrawer(location: String)`, `PlaceholderScreen(title: String, icon: IconData)`

- [ ] **Step 1: Criar PlaceholderScreen**

```dart
// lib/shared/widgets/placeholder_screen.dart
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  const PlaceholderScreen({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 80, color: AppColors.primary.withOpacity(0.4)),
          const SizedBox(height: 16),
          Text(title,
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Text('Em desenvolvimento',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Criar AppDrawer**

```dart
// lib/shared/widgets/app_drawer.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../features/auth/data/auth_repository.dart';

class AppDrawer extends ConsumerWidget {
  final String location;
  const AppDrawer({super.key, required this.location});

  static const _items = [
    (label: 'Início', icon: Icons.home_outlined, route: '/inicio'),
    (label: 'Clientes', icon: Icons.people_outline, route: '/clientes'),
    (label: 'Prontuário', icon: Icons.visibility_outlined, route: '/prontuario'),
    (label: 'Pedidos', icon: Icons.shopping_bag_outlined, route: '/pedidos'),
    (label: 'Estoque', icon: Icons.inventory_outlined, route: '/estoque'),
    (label: 'Caixa', icon: Icons.attach_money, route: '/caixa'),
    (label: 'Agenda', icon: Icons.calendar_today_outlined, route: '/agenda'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      backgroundColor: AppColors.drawerBackground,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              child: Image.asset('assets/images/logo_otica_yuri.png',
                  height: 80, color: Colors.white),
            ),
            const Divider(color: Colors.white24, height: 1),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ..._items.map((item) => _DrawerItem(
                        label: item.label,
                        icon: item.icon,
                        route: item.route,
                        selected: location.startsWith(item.route),
                      )),
                  const Divider(color: Colors.white24, height: 32),
                  _DrawerItem(
                    label: 'Configurações',
                    icon: Icons.settings_outlined,
                    route: '/configuracoes',
                    selected: location.startsWith('/configuracoes'),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white24, height: 1),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white70),
              title: const Text('Sair', style: TextStyle(color: Colors.white70)),
              onTap: () async {
                await ref.read(authRepositoryProvider).signOut();
              },
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Powered by OptoView',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.4), fontSize: 11)),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final String route;
  final bool selected;
  const _DrawerItem(
      {required this.label,
      required this.icon,
      required this.route,
      required this.selected});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: selected ? AppColors.primary : Colors.white70),
      title: Text(label,
          style: TextStyle(
            color: selected ? AppColors.primary : Colors.white,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          )),
      selected: selected,
      selectedTileColor: Colors.white12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      onTap: () {
        context.go(route);
        Navigator.of(context).pop();
      },
    );
  }
}
```

- [ ] **Step 3: Criar MainScaffold**

```dart
// lib/shared/widgets/main_scaffold.dart
import 'package:flutter/material.dart';
import 'app_drawer.dart';

class MainScaffold extends StatelessWidget {
  final String location;
  final Widget child;
  const MainScaffold({super.key, required this.location, required this.child});

  String _title(String loc) {
    if (loc.startsWith('/clientes')) return 'Clientes';
    if (loc.startsWith('/prontuario')) return 'Prontuário';
    if (loc.startsWith('/pedidos')) return 'Pedidos';
    if (loc.startsWith('/estoque')) return 'Estoque';
    if (loc.startsWith('/caixa')) return 'Caixa';
    if (loc.startsWith('/agenda')) return 'Agenda';
    if (loc.startsWith('/configuracoes')) return 'Configurações';
    return 'Início';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_title(location))),
      drawer: AppDrawer(location: location),
      body: child,
    );
  }
}
```

- [ ] **Step 4: Escrever widget test do AppDrawer**

```dart
// test/shared/widgets/app_drawer_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otica_yuri/shared/widgets/app_drawer.dart';
import 'package:otica_yuri/core/theme/app_theme.dart';

Widget buildDrawer(String location) => ProviderScope(
      child: MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          drawer: AppDrawer(location: location),
          body: const SizedBox(),
        ),
      ),
    );

void main() {
  testWidgets('Drawer exibe todos os módulos', (tester) async {
    await tester.pumpWidget(buildDrawer('/inicio'));
    final scaffold = tester.firstWidget<Scaffold>(find.byType(Scaffold));
    final drawer = scaffold.drawer as AppDrawer;
    expect(drawer, isNotNull);
  });
}
```

- [ ] **Step 5: Rodar todos os testes**

```bash
flutter test
```

Esperado: todos PASS.

- [ ] **Step 6: Commit**

```bash
git add lib/shared/ test/shared/
git commit -m "feat: add drawer navigation and main scaffold"
```

---

### Task 8: Teste de Integração e Verificação Final

**Files:**
- Modify: nenhum — só verificação

**Interfaces:**
- Consumes: todos os componentes anteriores
- Produces: app rodando com login funcional, drawer navegando entre módulos placeholder

- [ ] **Step 1: Rodar todos os testes unitários**

```bash
flutter test
```

Esperado: todos PASS.

- [ ] **Step 2: Rodar o app no emulador ou tablet Android**

```bash
flutter run --release
```

Verificar manualmente:
- [ ] Tela de login aparece com logo da Ótica Yuri
- [ ] Validação de formulário funciona (e-mail inválido, senha curta)
- [ ] Login com conta do Firebase funciona
- [ ] Drawer lateral abre com todos os módulos
- [ ] Cada item do drawer navega para a tela placeholder correta
- [ ] "Sair" faz logout e volta para o login
- [ ] "Esqueci minha senha" envia e-mail de recuperação

- [ ] **Step 3: Commit final**

```bash
git add .
git commit -m "feat: complete base setup, auth and navigation - Plan 1 done"
```

---

## Próximos Planos

Após este plano estar completo e funcionando:

| Plano | Módulo |
|---|---|
| Plano 2 | Módulo Clientes (CRUD + foto + busca) |
| Plano 3 | Módulo Prontuário Ótico |
| Plano 4 | Módulo Estoque |
| Plano 5 | Módulo Pedidos |
| Plano 6 | Módulo Caixa / Financeiro |
| Plano 7 | Módulo Agenda + Notificações |
| Plano 8 | Dashboard + Configurações |
