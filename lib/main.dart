import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Инициализация Supabase
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_ANON_KEY',
  );
  
  runApp(const AmorLuxApp());
}

class AmorLuxApp extends StatelessWidget {
  const AmorLuxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Amor Lux',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF000000),
        fontFamily: 'Montserrat', // Убедитесь, что добавили шрифт в pubspec.yaml
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFD4AF37), // Золотой
          secondary: Color(0xFF8B0000), // Бордовый
          surface: Color(0xFF1A1A1A),
        ),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}

// Контроллер авторизации: проверяет сессию при запуске
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = snapshot.data?.session;
        if (session != null) {
          return const HomeScreen();
        }
        return const AuthScreen();
      },
    );
  }
}

// --- Экран авторизации ---
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _isLoading = false;

  Future<void> _submit(bool isSignUp) async {
    if (_email.text.isEmpty || _password.text.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      if (isSignUp) {
        await Supabase.instance.client.auth.signUp(email: _email.text.trim(), password: _password.text);
      } else {
        await Supabase.instance.client.auth.signInWithPassword(email: _email.text.trim(), password: _password.text);
      }
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 450),
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Amor Lux', style: TextStyle(fontSize: 56, color: Color(0xFFD4AF37), fontWeight: FontWeight.w200, letterSpacing: 4)),
              const SizedBox(height: 10),
              const Text('LUXURY DATING', style: TextStyle(color: Colors.white38, letterSpacing: 2, fontSize: 12)),
              const SizedBox(height: 60),
              TextField(
                controller: _email,
                decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _password,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Пароль', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 32),
              if (_isLoading)
                const CircularProgressIndicator()
              else ...[
                ElevatedButton(
                  onPressed: () => _submit(false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('ВХОД', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => _submit(true),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 55),
                    side: const BorderSide(color: Color(0xFF8B0000)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('РЕГИСТРАЦИЯ', style: TextStyle(color: Color(0xFF8B0000))),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// --- Главный экран ---
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;
  final _screens = [const DiscoveryPage(), const Placeholder(), const ProfilePage()];

  @override
  Widget build(BuildContext context) {
    bool isWeb = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      body: Center(
        child: Container(
          constraints: isWeb ? const BoxConstraints(maxWidth: 500) : null,
          decoration: isWeb ? BoxDecoration(border: Border.symmetric(vertical: BorderSide(color: Colors.white10))) : null,
          child: _screens[_index],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        selectedItemColor: const Color(0xFFD4AF37),
        unselectedItemColor: Colors.white24,
        backgroundColor: const Color(0xFF0A0A0A),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.auto_awesome), label: 'Поиск'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Чаты'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Профиль'),
        ],
      ),
    );
  }
}

// --- Страница поиска ---
class DiscoveryPage extends StatelessWidget {
  const DiscoveryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network('https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=500', fit: BoxFit.cover),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black87]),
                    ),
                  ),
                  const Positioned(
                    bottom: 20,
                    left: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Анна, 24', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                        Text('Дизайнер • Москва', style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _circleBtn(Icons.close, Colors.white, const Color(0xFF1A1A1A)),
              _circleBtn(Icons.favorite, Colors.black, const Color(0xFFD4AF37)),
              _circleBtn(Icons.star, const Color(0xFFD4AF37), const Color(0xFF1A1A1A)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _circleBtn(IconData icon, Color color, Color bg) {
    return Container(
      width: 65,
      height: 65,
      decoration: BoxDecoration(shape: BoxShape.circle, color: bg, boxShadow: [BoxShadow(color: bg.withOpacity(0.3), blurRadius: 10)]),
      child: Icon(icon, color: color, size: 30),
    );
  }
}

// --- Страница профиля ---
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircleAvatar(radius: 60, backgroundColor: Color(0xFF1A1A1A), child: Icon(Icons.person, size: 60, color: Color(0xFFD4AF37))),
        const SizedBox(height: 20),
        const Text('Ваш Профиль', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 40),
        ListTile(
          leading: const Icon(Icons.logout, color: Color(0xFF8B0000)),
          title: const Text('Выйти из аккаунта'),
          onTap: () => Supabase.instance.client.auth.signOut(),
        ),
      ],
    );
  }
}

