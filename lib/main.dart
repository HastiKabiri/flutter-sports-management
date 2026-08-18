gitimport 'package:flutter/material.dart';
import 'dart:math';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Add this function at the top level, after the imports
Future<List<String>> fetchGalleryImages() async {
  try {
    final doc = await FirebaseFirestore.instance
        .collection('publicGallery')
        .doc('galleryData')
        .get();

    if (doc.exists) {
      final data = doc.data();
      if (data != null && data['image'] != null) {
        return List<String>.from(data['image']);
      }
    }
    return [];
  } catch (e) {
    print("Error fetching gallery: $e");
    return [];
  }
}

void main() async {
  //WidgetsFlutterBinding.ensureInitialized();
  //await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // --- TEMPORARY TEST WRITE ---
  try {
    await FirebaseFirestore.instance.collection('test_connection').add({
      'status': 'connected_from_app',
      'timestamp': FieldValue.serverTimestamp(),
    });
    print("SUCCESS: Firestore write worked!");
  } catch (e) {
    print("FIRESTORE ERROR: $e");
  }
  // -----------------------------

  runApp(const MyApp());
}

enum UserRole { player, admin, coach, parent, performanceAnalyst, other }

enum AppLanguage { english, hindi, malay, chinese }

extension AppLanguageLabel on AppLanguage {
  String get label {
    switch (this) {
      case AppLanguage.english:
        return 'English';
      case AppLanguage.hindi:
        return 'हिन्दी';
      case AppLanguage.malay:
        return 'Bahasa Melayu';
      case AppLanguage.chinese:
        return '中文';
    }
  }
}

class L10n {
  static const Map<AppLanguage, Map<String, String>> _strings = {
    AppLanguage.english: {
      'nav_home': 'Home',
      'nav_chat': 'Chat',
      'nav_profile': 'Profile',
      'nav_settings': 'Settings',
      'logout': 'Logout',
      'welcome_back': 'Welcome back',
      'appearance_title': 'Appearance',
      'appearance_subtitle': 'Switch between light and dark mode',
      'light_mode': 'Light mode',
      'dark_mode': 'Dark mode',
      'font_size_title': 'Text size',
      'font_size_subtitle': 'Make text across the app easier to read',
      'notifications_title': 'Notifications',
      'notifications_subtitle': 'Choose what you want to be notified about',
      'notifications_master': 'Allow notifications',
      'notifications_chat': 'Chat messages',
      'notifications_attendance': 'Attendance updates',
      'notifications_announcements': 'Announcements',
      'language_title': 'Language',
      'language_subtitle': 'Choose your preferred app language',
    },
    AppLanguage.hindi: {
      'nav_home': 'होम',
      'nav_chat': 'चैट',
      'nav_profile': 'प्रोफ़ाइल',
      'nav_settings': 'सेटिंग्स',
      'logout': 'लॉगआउट',
      'welcome_back': 'वापसी पर स्वागत है',
      'appearance_title': 'दिखावट',
      'appearance_subtitle': 'लाइट और डार्क मोड के बीच स्विच करें',
      'light_mode': 'लाइट मोड',
      'dark_mode': 'डार्क मोड',
      'font_size_title': 'टेक्स्ट का आकार',
      'font_size_subtitle': 'पूरे ऐप में टेक्स्ट पढ़ने में आसान बनाएं',
      'notifications_title': 'सूचनाएं',
      'notifications_subtitle': 'चुनें कि आपको किस बारे में सूचित किया जाए',
      'notifications_master': 'सूचनाओं की अनुमति दें',
      'notifications_chat': 'चैट संदेश',
      'notifications_attendance': 'उपस्थिति अपडेट',
      'notifications_announcements': 'घोषणाएं',
      'language_title': 'भाषा',
      'language_subtitle': 'अपनी पसंदीदा भाषा चुनें',
    },
    AppLanguage.malay: {
      'nav_home': 'Utama',
      'nav_chat': 'Sembang',
      'nav_profile': 'Profil',
      'nav_settings': 'Tetapan',
      'logout': 'Log keluar',
      'welcome_back': 'Selamat kembali',
      'appearance_title': 'Rupa',
      'appearance_subtitle': 'Tukar antara mod terang dan gelap',
      'light_mode': 'Mod terang',
      'dark_mode': 'Mod gelap',
      'font_size_title': 'Saiz teks',
      'font_size_subtitle':
          'Jadikan teks di seluruh aplikasi lebih mudah dibaca',
      'notifications_title': 'Pemberitahuan',
      'notifications_subtitle': 'Pilih perkara yang anda mahu diberitahu',
      'notifications_master': 'Benarkan pemberitahuan',
      'notifications_chat': 'Mesej sembang',
      'notifications_attendance': 'Kemas kini kehadiran',
      'notifications_announcements': 'Pengumuman',
      'language_title': 'Bahasa',
      'language_subtitle': 'Pilih bahasa aplikasi pilihan anda',
    },
    AppLanguage.chinese: {
      'nav_home': '首页',
      'nav_chat': '聊天',
      'nav_profile': '资料',
      'nav_settings': '设置',
      'logout': '退出',
      'welcome_back': '欢迎回来',
      'appearance_title': '外观',
      'appearance_subtitle': '在浅色和深色模式之间切换',
      'light_mode': '浅色模式',
      'dark_mode': '深色模式',
      'font_size_title': '文字大小',
      'font_size_subtitle': '让整个应用的文字更容易阅读',
      'notifications_title': '通知',
      'notifications_subtitle': '选择您想接收的通知内容',
      'notifications_master': '允许通知',
      'notifications_chat': '聊天消息',
      'notifications_attendance': '出勤更新',
      'notifications_announcements': '公告',
      'language_title': '语言',
      'language_subtitle': '选择您偏好的应用语言',
    },
  };

  static String t(AppLanguage lang, String key) {
    return _strings[lang]?[key] ?? _strings[AppLanguage.english]![key] ?? key;
  }
}

class AppSettings {
  const AppSettings({
    required this.isDarkTheme,
    required this.fontScale,
    required this.notificationsEnabled,
    required this.notifyChat,
    required this.notifyAttendance,
    required this.notifyAnnouncements,
    required this.language,
  });

  final bool isDarkTheme;
  final double fontScale;
  final bool notificationsEnabled;
  final bool notifyChat;
  final bool notifyAttendance;
  final bool notifyAnnouncements;
  final AppLanguage language;
}

class SettingsCallbacks {
  const SettingsCallbacks({
    required this.onThemeChanged,
    required this.onFontScaleChanged,
    required this.onNotificationsChanged,
    required this.onNotifyChatChanged,
    required this.onNotifyAttendanceChanged,
    required this.onNotifyAnnouncementsChanged,
    required this.onLanguageChanged,
  });

  final ValueChanged<bool> onThemeChanged;
  final ValueChanged<double> onFontScaleChanged;
  final ValueChanged<bool> onNotificationsChanged;
  final ValueChanged<bool> onNotifyChatChanged;
  final ValueChanged<bool> onNotifyAttendanceChanged;
  final ValueChanged<bool> onNotifyAnnouncementsChanged;
  final ValueChanged<AppLanguage> onLanguageChanged;
}

class AppUser {
  const AppUser({
    required this.email,
    required this.password,
    required this.fullName,
    required this.role,
    this.photoUrl,
    this.phone,
    this.team,
    this.school,
    this.position,
    this.notes,
  });

  final String email;
  final String password;
  final String fullName;
  final UserRole role;
  final String? photoUrl;
  final String? phone;
  final String? team;
  final String? school;
  final String? position;
  final String? notes;
}

class PublicNewsItem {
  const PublicNewsItem({
    required this.title,
    required this.date,
    required this.body,
    this.imageUrl,
  });

  final String title;
  final String date;
  final String body;
  final String? imageUrl;
}

class _ChatMessage {
  _ChatMessage({
    required this.sender,
    required this.text,
    required this.timeLabel,
  });

  final String sender;
  final String text;
  final String timeLabel;
}

final List<_ChatGroup> _sharedTeamChats = [
  _ChatGroup(
    name: 'Coach Malik',
    members: ['Coach Malik', 'Alicia Tan'],
    canType: [true, true],
    visibleTo: [UserRole.admin, UserRole.coach, UserRole.player],
    messages: [
      _ChatMessage(
        sender: 'Coach Malik',
        text: 'Training starts at 5 PM. Be on time with full kit.',
        timeLabel: 'Today',
      ),
      _ChatMessage(
        sender: 'Alicia Tan',
        text: 'Got it coach, I will be there early.',
        timeLabel: 'Today',
      ),
    ],
  ),
  _ChatGroup(
    name: 'Elite Squad',
    members: ['Coach Malik', 'Alicia Tan'],
    canType: [true, false],
    visibleTo: [UserRole.admin, UserRole.coach, UserRole.player],
    messages: [
      _ChatMessage(
        sender: 'Admin User',
        text: 'Elite Squad group is ready for match updates.',
        timeLabel: 'Today',
      ),
    ],
  ),
  _ChatGroup(
    name: 'Parents Updates',
    members: ['Sarah Tan', 'Admin User'],
    canType: [true, true],
    visibleTo: [UserRole.admin, UserRole.parent],
    messages: [
      _ChatMessage(
        sender: 'Admin User',
        text: 'Parents, please check the schedule for this week.',
        timeLabel: 'Today',
      ),
    ],
  ),
];

class _PublicVideo {
  const _PublicVideo({
    required this.title,
    required this.date,
    required this.thumbnail,
    required this.url,
  });
  final String title;
  final String date;
  final String thumbnail;
  final String url;
}

// removed unused top-level `_publicGallery` (app state provides gallery data)

final List<_PublicVideo> _publicMatchVideos = [
  const _PublicVideo(
    title: 'U16 vs Tigers - Full Match',
    date: '2026-07-18',
    thumbnail: 'https://placehold.co/320x180?text=Match+1',
    url: 'https://example.com/video/match1.mp4',
  ),
  const _PublicVideo(
    title: 'U16 vs Hawks - Highlights',
    date: '2026-06-25',
    thumbnail: 'https://placehold.co/320x180?text=Highlights',
    url: 'https://example.com/video/highlights.mp4',
  ),
];

// Global attendance state so both coach and player views can access it.
String? _globalAttendanceCode;
DateTime? _globalAttendanceExpiry;
final Map<String, List<String>> _globalAttendanceRecords = {};

void generateAttendanceCodeGlobal() {
  final rnd = Random();
  _globalAttendanceCode = (rnd.nextInt(900) + 100).toString();
  _globalAttendanceExpiry = DateTime.now().add(const Duration(minutes: 15));
}

bool markAttendanceGlobal(String email, String code) {
  final today = DateTime.now().toIso8601String().split('T').first;
  if (_globalAttendanceCode == null || _globalAttendanceExpiry == null) {
    return false;
  }
  if (DateTime.now().isAfter(_globalAttendanceExpiry!)) return false;
  if (code != _globalAttendanceCode) return false;
  _globalAttendanceRecords.putIfAbsent(today, () => []);
  if (!_globalAttendanceRecords[today]!.contains(email)) {
    _globalAttendanceRecords[today]!.add(email);
  }
  return true;
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final List<AppUser> _users = [
    const AppUser(
      email: 'admin@jmhockey.com',
      password: 'admin123',
      fullName: 'Admin User',
      role: UserRole.admin,
    ),
    const AppUser(
      email: 'coach@jmhockey.com',
      password: 'coach123',
      fullName: 'Coach Malik',
      role: UserRole.coach,
    ),
    const AppUser(
      email: 'player@jmhockey.com',
      password: 'player123',
      fullName: 'Alicia Tan',
      role: UserRole.player,
      photoUrl:
          'https://images.unsplash.com/photo-1519864600265-abb23847ef2c?auto=format&fit=crop&w=400&q=80',
    ),
    const AppUser(
      email: 'parent@jmhockey.com',
      password: 'parent123',
      fullName: 'Sarah Tan',
      role: UserRole.parent,
    ),
    const AppUser(
      email: 'analyst@jmhockey.com',
      password: 'analyst123',
      fullName: 'Aina Rahman',
      role: UserRole.performanceAnalyst,
    ),
  ];

  List<String> publicGallery = [];
  @override
  void initState() {
    super.initState();
    _loadGallery();
    // ... any other init code you might have ...
  }

  void _loadGallery() async {
    try {
      final images = await fetchGalleryImages();
      print("Fetched ${images.length} images: $images"); // 👈 ADD THIS
      setState(() {
        publicGallery = images;
      });
    } catch (e) {
      print("Error loading gallery: $e");
    }
  }

  AppUser? _currentUser;
  int _selectedIndex = 0;
  bool _useDarkTheme = false;
  bool _showAuth = false;
  bool _showOnboarding = true;
  double _fontScale = 1.0;
  bool _notificationsEnabled = true;
  bool _notifyChat = true;
  bool _notifyAttendance = true;
  bool _notifyAnnouncements = true;
  AppLanguage _language = AppLanguage.english;

  // Team lineups maintained by coach users. Keyed by team name.
  final Map<String, List<String>> _teamLineups = {};

  String _publicAboutText =
      'JM Hockey Academy trains players of all ages with a focus '
      'on skill, discipline, and teamwork. Our certified coaches '
      'run structured programs across the season, from beginner '
      'clinics to elite squad training, alongside parent updates '
      'and club events throughout the year.';

  final List<PublicNewsItem> _publicNews = [
    const PublicNewsItem(
      title: 'Elite Squad clinches regional title',
      date: 'Jul 21, 2026',
      body:
          'Our U-16 Elite Squad brought home the regional championship after '
          'a hard-fought final. Congratulations to the whole team!',
    ),
    const PublicNewsItem(
      title: 'Registration open for the winter intake',
      date: 'Jul 12, 2026',
      body:
          'Spots are limited for beginner and intermediate clinics starting '
          'next month. Sign up early to reserve your place.',
    ),
    const PublicNewsItem(
      title: 'New conditioning program launched',
      date: 'Jun 30, 2026',
      body:
          'Coach Malik has introduced a revamped off-ice conditioning '
          'program focused on speed and injury prevention.',
    ),
  ];

  String? _createUser({
    required String fullName,
    required String email,
    required String password,
    required UserRole role,
    String? photoUrl,
    String? phone,
    String? team,
    String? school,
    String? position,
    String? notes,
  }) {
    final normalizedEmail = email.trim().toLowerCase();
    final trimmedName = fullName.trim();

    if (_users.any((user) => user.email.toLowerCase() == normalizedEmail)) {
      return 'An account with this email already exists';
    }

    final user = AppUser(
      email: normalizedEmail,
      password: password,
      fullName: trimmedName,
      role: role,
      photoUrl: photoUrl?.trim().isEmpty == true ? null : photoUrl?.trim(),
      phone: phone?.trim().isEmpty == true ? null : phone?.trim(),
      team: team?.trim().isEmpty == true ? null : team?.trim(),
      school: school?.trim().isEmpty == true ? null : school?.trim(),
      position: position?.trim().isEmpty == true ? null : position?.trim(),
      notes: notes?.trim().isEmpty == true ? null : notes?.trim(),
    );

    setState(() {
      _users.add(user);
    });
    return null;
  }

  Future<bool> _login(String email, String password) async {
    final authService = AuthService();

    // Authenticate with Firebase
    final credential = await authService.signInWithEmail(email, password);

    if (credential != null) {
      setState(() {
        _showAuth = false;
      });
      return true;
    }

    return false;
  }

  Future<String?> _register({
    required String fullName,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    // Added 'async' here
    final authService = AuthService();

    // 1. Create account in Firebase Authentication
    final credential = await authService.signUpWithEmail(email, password);

    if (credential != null && credential.user != null) {
      // 2. Save extra user details (Name & Role) into Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(credential.user!.uid)
          .set({
            'uid': credential.user!.uid,
            'fullName': fullName.trim(),
            'email': email.trim().toLowerCase(),
            'role': role.name, // or role.toString()
            'createdAt': FieldValue.serverTimestamp(),
          });

      // 3. Update local state & close auth modal
      setState(() {
        _showAuth = false;
      });

      return null; // Return null on success
    } else {
      return 'Registration failed. Email might already be in use.';
    }
  }

  void _logout() {
    setState(() {
      _currentUser = null;
      _selectedIndex = 0;
      _showAuth = false;
    });
  }

  void _openAuth() {
    setState(() => _showAuth = true);
  }

  void _closeAuth() {
    setState(() => _showAuth = false);
  }

  void _finishOnboarding() {
    setState(() => _showOnboarding = false);
  }

  void _setThemeMode(bool useDarkTheme) {
    setState(() => _useDarkTheme = useDarkTheme);
  }

  void _setFontScale(double fontScale) {
    setState(() => _fontScale = fontScale);
  }

  void _setNotificationsEnabled(bool enabled) {
    setState(() => _notificationsEnabled = enabled);
  }

  void _setNotifyChat(bool enabled) {
    setState(() => _notifyChat = enabled);
  }

  void _setNotifyAttendance(bool enabled) {
    setState(() => _notifyAttendance = enabled);
  }

  void _setNotifyAnnouncements(bool enabled) {
    setState(() => _notifyAnnouncements = enabled);
  }

  void _setLanguage(AppLanguage language) {
    setState(() => _language = language);
  }

  void _updateTeamLineup(String team, List<String> lineup) {
    setState(() {
      _teamLineups[team] = List<String>.from(lineup);
    });
  }

  void _updatePublicAbout(String value) {
    setState(() => _publicAboutText = value.trim());
  }

  String? _addPublicGalleryImage(String imageUrl) {
    final normalized = imageUrl.trim();
    if (normalized.isEmpty) {
      return 'Please enter an image URL';
    }
    setState(() => publicGallery.insert(0, normalized));
    return null;
  }

  void _removePublicGalleryImage(int index) {
    setState(() => publicGallery.removeAt(index));
  }

  String? _addPublicNews({
    required String title,
    required String body,
    String? imageUrl,
  }) {
    final trimmedTitle = title.trim();
    final trimmedBody = body.trim();
    final trimmedImage = imageUrl?.trim();
    if (trimmedTitle.isEmpty || trimmedBody.isEmpty) {
      return 'Title and content are required';
    }

    setState(() {
      _publicNews.insert(
        0,
        PublicNewsItem(
          title: trimmedTitle,
          body: trimmedBody,
          date: 'Just now',
          imageUrl: trimmedImage == null || trimmedImage.isEmpty
              ? null
              : trimmedImage,
        ),
      );
    });
    return null;
  }

  void _removePublicNews(int index) {
    setState(() => _publicNews.removeAt(index));
  }

  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final seedColor = isDark
        ? const Color(0xFF0D47A1)
        : const Color(0xFF1E88E5);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );
    final surfaceColor = isDark ? Colors.black : const Color(0xFFF7FAFF);
    final cardColor = isDark ? const Color(0xFF111111) : Colors.white;

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: surfaceColor,
      canvasColor: surfaceColor,
      cardColor: cardColor,
      dividerColor: isDark ? Colors.white12 : Colors.black12,
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: isDark ? Colors.white : const Color(0xFF0F4C81),
      ),
      navigationBarTheme: NavigationBarThemeData(backgroundColor: cardColor),
      textTheme: (isDark ? ThemeData.dark() : ThemeData.light()).textTheme
          .apply(
            bodyColor: isDark ? Colors.white : Colors.black87,
            displayColor: isDark ? Colors.white : Colors.black87,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'JM Hockey',
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: _useDarkTheme ? ThemeMode.dark : ThemeMode.light,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(_fontScale)),
          child: child!,
        );
      },
      home: _showOnboarding
          ? OnboardingScreen(onFinished: _finishOnboarding)
          : (_currentUser != null
                ? RoleHomeScreen(
                    user: _currentUser!,
                    allUsers: _users,
                    onCreateUser: _createUser,
                    publicAboutText: _publicAboutText,
                    publicGallery: publicGallery,
                    publicNews: _publicNews,
                    onUpdatePublicAbout: _updatePublicAbout,
                    onAddPublicGalleryImage: _addPublicGalleryImage,
                    onRemovePublicGalleryImage: _removePublicGalleryImage,
                    onAddPublicNews: _addPublicNews,
                    onRemovePublicNews: _removePublicNews,
                    selectedIndex: _selectedIndex,
                    onIndexChanged: (index) =>
                        setState(() => _selectedIndex = index),
                    onLogout: _logout,
                    teamLineups: _teamLineups,
                    onUpdateTeamLineup: _updateTeamLineup,
                    onAttendanceUpdated: () => setState(() {}),
                    settings: AppSettings(
                      isDarkTheme: _useDarkTheme,
                      fontScale: _fontScale,
                      notificationsEnabled: _notificationsEnabled,
                      notifyChat: _notifyChat,
                      notifyAttendance: _notifyAttendance,
                      notifyAnnouncements: _notifyAnnouncements,
                      language: _language,
                    ),
                    callbacks: SettingsCallbacks(
                      onThemeChanged: _setThemeMode,
                      onFontScaleChanged: _setFontScale,
                      onNotificationsChanged: _setNotificationsEnabled,
                      onNotifyChatChanged: _setNotifyChat,
                      onNotifyAttendanceChanged: _setNotifyAttendance,
                      onNotifyAnnouncementsChanged: _setNotifyAnnouncements,
                      onLanguageChanged: _setLanguage,
                    ),
                  )
                : (_showAuth
                      ? LoginScreen(
                          onLogin: _login,
                          onRegister: _register,
                          onBack: _closeAuth,
                        )
                      : PublicHomeScreen(
                          onSignIn: _openAuth,
                          aboutText: _publicAboutText,
                          gallery: publicGallery,
                          news: _publicNews,
                        ))),
    );
  }
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onFinished});

  final VoidCallback onFinished;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _pageIndex = 0;

  // TODO: Replace these with your real academy logo / brand images.
  static const _pages = [
    (
      imageUrl: 'assets/JiwaHockey-PNG-1-1.png',
      title: 'Welcome to JM Hockey Academy',
      body:
          'Your journey to becoming a champion starts here. Train, track '
          'your progress, and stay connected with your team — all in one '
          'app.',
    ),
    (
      imageUrl: 'assets/IMG_8519.jpg',
      title: 'Who we are',
      body:
          'JM Hockey Academy trains players of all ages with a focus on '
          'skill, discipline, and teamwork. Our certified coaches run '
          'structured programs from beginner clinics to elite squad '
          'training, all year round.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_pageIndex < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      widget.onFinished();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _pageIndex == _pages.length - 1;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFF),
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 12, top: 4),
                child: Opacity(
                  opacity: isLastPage ? 0 : 1,
                  child: TextButton(
                    onPressed: isLastPage ? null : widget.onFinished,
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _pageIndex = index),
                children: [
                  for (final page in _pages)
                    _OnboardingPage(
                      imageUrl: page.imageUrl,
                      title: page.title,
                      body: page.body,
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < _pages.length; i++)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: i == _pageIndex ? 22 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: i == _pageIndex
                                ? const Color(0xFF1E88E5)
                                : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _next,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E88E5),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        isLastPage ? 'Get Started' : 'Next',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.imageUrl,
    required this.title,
    required this.body,
  });

  final String imageUrl;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 170,
            height: 170,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFF7FAFF),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              imageUrl,
              height: 120,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const Icon(
                Icons.sports_hockey,
                size: 73,
                color: Color(0xFF0F4C81),
              ),
            ),
          ),
          const SizedBox(height: 36),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          Text(
            body,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
              height: 1.5,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

class PublicHomeScreen extends StatelessWidget {
  const PublicHomeScreen({
    super.key,
    required this.onSignIn,
    required this.aboutText,
    required this.gallery,
    required this.news,
  });

  final VoidCallback onSignIn;
  final String aboutText;
  final List<String> gallery;
  final List<PublicNewsItem> news;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFF),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7FAFF),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Image.asset(
                        'assets/JiwaHockey-PNG-1-1.png',
                        width: 32,
                        height: 32,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'JM Hockey',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: onSignIn,
                      child: const Text(
                        'Sign In',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E88E5), Color(0xFF0F4C81)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Welcome to JM Hockey Academy',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Building champions on and off the ice. Explore our '
                        'programs, latest news, and community — no account '
                        'needed to look around.',
                        style: TextStyle(color: Colors.white70, height: 1.4),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: onSignIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF0F4C81),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Member Sign In / Sign Up',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: _PublicSectionHeader(title: 'About the academy'),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  aboutText,
                  style: TextStyle(color: Colors.grey.shade700, height: 1.5),
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: _PublicSectionHeader(title: 'Gallery'),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 140,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: gallery.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (context, index) =>
                      _GalleryTile(imageUrl: gallery[index]),
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: _PublicSectionHeader(title: 'Latest news'),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList.separated(
                itemCount: news.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = news[index];
                  return _NewsCard(
                    title: item.title,
                    date: item.date,
                    body: item.body,
                    imageUrl: item.imageUrl,
                  );
                },
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Already a member?',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Sign in to see attendance, performance, chat, and '
                        'more — or create a new account in seconds.',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: onSignIn,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text('Sign In'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: onSignIn,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E88E5),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text('Sign Up'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PublicSectionHeader extends StatelessWidget {
  const _PublicSectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
      child: Text(
        title,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _GalleryTile extends StatelessWidget {
  const _GalleryTile({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Image.network(
        imageUrl,
        width: 180,
        height: 140,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            width: 180,
            height: 140,
            color: Colors.grey.shade200,
            child: const Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        },
        errorBuilder: (_, _, _) => Container(
          width: 180,
          height: 140,
          color: const Color(0xFF1E88E5).withValues(alpha: 0.12),
          child: const Icon(
            Icons.photo_outlined,
            color: Color(0xFF1E88E5),
            size: 32,
          ),
        ),
      ),
    );
  }
}

class _NewsCard extends StatelessWidget {
  const _NewsCard({
    required this.title,
    required this.date,
    required this.body,
    this.imageUrl,
  });

  final String title;
  final String date;
  final String body;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E88E5).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.campaign_outlined,
                  color: Color(0xFF1E88E5),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            date,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: TextStyle(color: Colors.grey.shade700, height: 1.4),
          ),
          if (imageUrl != null && imageUrl!.isNotEmpty) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl!,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  height: 150,
                  color: const Color(0xFF1E88E5).withValues(alpha: 0.1),
                  child: const Center(
                    child: Icon(Icons.photo_outlined, color: Color(0xFF1E88E5)),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.onLogin,
    required this.onRegister,
    this.onBack,
  });

  final Future<bool> Function(String, String) onLogin;
  final Future<String?> Function({
    required String fullName,
    required String email,
    required String password,
    required UserRole role,
  })
  onRegister;
  final VoidCallback? onBack;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isSignUp = false;
  final _emailController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  UserRole _selectedRole = UserRole.player;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _fullNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_isSignUp) {
      final fullName = _fullNameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      final confirmPassword = _confirmPasswordController.text;

      if (fullName.isEmpty || email.isEmpty || password.isEmpty) {
        setState(() => _error = 'Please fill out all fields');
        return;
      }

      if (password != confirmPassword) {
        setState(() => _error = 'Passwords do not match');
        return;
      }

      final error = await widget.onRegister(
        fullName: fullName,
        email: email,
        password: password,
        role: _selectedRole,
      );
      setState(() => _error = error);
      return;
    }

    final ok = await widget.onLogin(
      _emailController.text,
      _passwordController.text,
    );
    setState(() => _error = ok ? null : 'Invalid email or password');
  }

  void _toggleMode() {
    setState(() {
      _isSignUp = !_isSignUp;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFF),
      body: SafeArea(
        child: Column(
          children: [
            if (widget.onBack != null)
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: widget.onBack,
                  icon: const Icon(Icons.arrow_back_ios_new),
                ),
              ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Container(
                    width: 420,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7FAFF),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Image.asset(
                            'assets/JiwaHockey-PNG-1-1.png',
                            width: 64,
                            height: 64,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          _isSignUp ? 'Create account' : 'Welcome back',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isSignUp
                              ? 'Join your JM Hockey account'
                              : 'Sign in to your JM Hockey account',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (_isSignUp) ...[
                          _AuthField(
                            controller: _fullNameController,
                            label: 'Full name',
                            icon: Icons.badge_outlined,
                          ),
                          const SizedBox(height: 12),
                        ],
                        _AuthField(
                          controller: _emailController,
                          label: 'Email',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 12),
                        _AuthField(
                          controller: _passwordController,
                          label: 'Password',
                          icon: Icons.lock_outline,
                          obscureText: true,
                        ),
                        if (_isSignUp) ...[
                          const SizedBox(height: 12),
                          _AuthField(
                            controller: _confirmPasswordController,
                            label: 'Confirm password',
                            icon: Icons.lock_reset_outlined,
                            obscureText: true,
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<UserRole>(
                            initialValue: _selectedRole,
                            decoration: InputDecoration(
                              labelText: 'Role',
                              prefixIcon: const Icon(Icons.person_outline),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: UserRole.player,
                                child: Text('Player'),
                              ),
                              DropdownMenuItem(
                                value: UserRole.parent,
                                child: Text('Parent'),
                              ),
                              DropdownMenuItem(
                                value: UserRole.coach,
                                child: Text('Coach'),
                              ),
                              DropdownMenuItem(
                                value: UserRole.performanceAnalyst,
                                child: Text('Performance Analyst'),
                              ),
                              DropdownMenuItem(
                                value: UserRole.admin,
                                child: Text('Admin'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _selectedRole = value);
                              }
                            },
                          ),
                        ],
                        if (_error != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            _error!,
                            style: const TextStyle(color: Colors.redAccent),
                          ),
                        ],
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E88E5),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(
                              _isSignUp ? 'Sign Up' : 'Sign In',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: _toggleMode,
                          child: Text(
                            _isSignUp
                                ? 'Already have an account? Sign In'
                                : 'Need an account? Sign Up',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RoleHomeScreen extends StatelessWidget {
  const RoleHomeScreen({
    super.key,
    required this.user,
    required this.allUsers,
    required this.onCreateUser,
    required this.publicAboutText,
    required this.publicGallery,
    required this.publicNews,
    required this.onUpdatePublicAbout,
    required this.onAddPublicGalleryImage,
    required this.onRemovePublicGalleryImage,
    required this.onAddPublicNews,
    required this.onRemovePublicNews,
    required this.selectedIndex,
    required this.onIndexChanged,
    required this.onLogout,
    required this.teamLineups,
    required this.onUpdateTeamLineup,
    required this.onAttendanceUpdated,
    required this.settings,
    required this.callbacks,
  });

  final AppUser user;
  final List<AppUser> allUsers;
  final Map<String, List<String>> teamLineups;
  final void Function(String, List<String>) onUpdateTeamLineup;
  final VoidCallback onAttendanceUpdated;
  final String? Function({
    required String fullName,
    required String email,
    required String password,
    required UserRole role,
    String? photoUrl,
    String? phone,
    String? team,
    String? school,
    String? position,
    String? notes,
  })
  onCreateUser;
  final String publicAboutText;
  final List<String> publicGallery;
  final List<PublicNewsItem> publicNews;
  final ValueChanged<String> onUpdatePublicAbout;
  final String? Function(String imageUrl) onAddPublicGalleryImage;
  final ValueChanged<int> onRemovePublicGalleryImage;
  final String? Function({
    required String title,
    required String body,
    String? imageUrl,
  })
  onAddPublicNews;
  final ValueChanged<int> onRemovePublicNews;
  final int selectedIndex;
  final ValueChanged<int> onIndexChanged;
  final VoidCallback onLogout;
  final AppSettings settings;
  final SettingsCallbacks callbacks;

  @override
  Widget build(BuildContext context) {
    final accent = _accentForRole(user.role);
    final modules = _modulesForRole(user.role);
    final body = switch (selectedIndex) {
      0 => _homeView(context, modules, accent),
      1 => _chatView(context, accent),
      2 => _profileView(context, accent),
      3 => _settingsView(context, accent),
      _ => _homeView(context, modules, accent),
    };

    final lang = settings.language;
    return Scaffold(
      appBar: AppBar(
        title: const Text('JM Hockey'),
        elevation: 0,
        actions: [
          Builder(
            builder: (context) {
              final lang = settings.language;
              return IconButton(
                icon: const Icon(Icons.logout),
                tooltip: L10n.t(lang, 'logout'),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(L10n.t(lang, 'logout')),
                      content: Text('Are you sure you want to log out?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: const Text('Log out'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) onLogout();
                },
              );
            },
          ),
        ],
      ),
      body: SafeArea(child: body),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onIndexChanged,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home),
            label: L10n.t(lang, 'nav_home'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.chat_bubble_outline),
            label: L10n.t(lang, 'nav_chat'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.person),
            label: L10n.t(lang, 'nav_profile'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings),
            label: L10n.t(lang, 'nav_settings'),
          ),
        ],
      ),
      floatingActionButton: user.role == UserRole.admin
          ? FloatingActionButton.extended(
              heroTag: 'admin-public-page',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => DetailPage(
                      title: 'Public Page Editor',
                      subtitle:
                          'Edit gallery pictures, news, and public page content',
                      accent: accent,
                      icon: Icons.public,
                      viewerRole: user.role,
                      allUsers: allUsers,
                      onCreateUser: onCreateUser,
                      publicAboutText: publicAboutText,
                      publicGallery: publicGallery,
                      publicNews: publicNews,
                      onUpdatePublicAbout: onUpdatePublicAbout,
                      onAddPublicGalleryImage: onAddPublicGalleryImage,
                      onRemovePublicGalleryImage: onRemovePublicGalleryImage,
                      onAddPublicNews: onAddPublicNews,
                      onRemovePublicNews: onRemovePublicNews,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.public),
              label: const Text('Public Page'),
            )
          : null,
    );
  }

  Widget _homeView(
    BuildContext context,
    List<_DashboardItem> modules,
    Color accent,
  ) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _headlineForRole(user.role),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${L10n.t(settings.language, 'welcome_back')}, ${user.fullName}',
                  style: TextStyle(color: Colors.grey.shade500),
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [accent, accent.withValues(alpha: 0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    _taglineForRole(user.role),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverGrid.count(
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 0.95,
            children: [
              for (final module in modules)
                _DashboardCard(
                  item: module,
                  accent: accent,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => DetailPage(
                          title: module.detailTitle,
                          subtitle: module.detailText,
                          accent: accent,
                          icon: module.icon,
                          viewerRole: user.role,
                          allUsers: allUsers,
                          onCreateUser: onCreateUser,
                          publicAboutText: publicAboutText,
                          publicGallery: publicGallery,
                          publicNews: publicNews,
                          onUpdatePublicAbout: onUpdatePublicAbout,
                          onAddPublicGalleryImage: onAddPublicGalleryImage,
                          onRemovePublicGalleryImage:
                              onRemovePublicGalleryImage,
                          onAddPublicNews: onAddPublicNews,
                          onRemovePublicNews: onRemovePublicNews,
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
      ],
    );
  }

  Widget _chatView(BuildContext context, Color accent) {
    return _ChatListPage(
      accent: accent,
      currentUser: user,
      allUsers: allUsers,
      groupThreads: _sharedTeamChats,
    );
  }

  Widget _profileView(BuildContext context, Color accent) {
    if (user.role == UserRole.player) {
      return _playerProfileView(context, accent);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      children: [
        _ProfileCard(
          name: user.fullName,
          role: _headlineForRole(user.role),
          team: 'JM Hockey',
          accent: accent,
          avatarIcon: Icons.person,
        ),
        const SizedBox(height: 12),
        _ChartCard(
          title: 'Activity overview',
          subtitle: 'Recent account activity',
          accent: accent,
          values: const [64, 70, 77, 85, 90],
          labels: const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
        ),
        if (user.role == UserRole.coach) ...[
          const SizedBox(height: 12),
          _PanelCard(
            title: 'Team lineup',
            subtitle: 'Arrange player order for match day',
            accent: accent,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final team = user.team ?? 'JM Hockey';
                  final initial = List<String>.from(
                    teamLineups[team] ??
                        allUsers
                            .where((u) => u.role == UserRole.player)
                            .map((u) => u.fullName),
                  );
                  final lineup = List<String>.from(initial);
                  final saved = await showModalBottomSheet<bool>(
                    context: context,
                    isScrollControlled: true,
                    builder: (ctx) {
                      return StatefulBuilder(
                        builder: (ctx2, setLocalState) {
                          return SafeArea(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Arrange lineup',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(ctx).pop(false),
                                        child: const Text('Cancel'),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    height: 360,
                                    child: ReorderableListView(
                                      onReorder: (oldIndex, newIndex) {
                                        setLocalState(() {
                                          if (newIndex > oldIndex) {
                                            newIndex -= 1;
                                          }
                                          final item = lineup.removeAt(
                                            oldIndex,
                                          );
                                          lineup.insert(newIndex, item);
                                        });
                                      },
                                      children: [
                                        for (var i = 0; i < lineup.length; i++)
                                          ListTile(
                                            key: ValueKey(lineup[i]),
                                            title: Text(lineup[i]),
                                            leading: const Icon(
                                              Icons.drag_handle,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  ElevatedButton(
                                    onPressed: () {
                                      onUpdateTeamLineup(team, lineup);
                                      Navigator.of(ctx).pop(true);
                                    },
                                    child: const Text('Save lineup'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                  if (saved == true) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Lineup saved')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: accent),
                child: const Text('Arrange lineup'),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _PanelCard(
            title: 'Manual attendance',
            subtitle: 'Mark players present or absent for today',
            accent: accent,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final team = user.team ?? 'JM Hockey';
                  final todayKey = DateTime.now()
                      .toIso8601String()
                      .split('T')
                      .first;
                  _globalAttendanceRecords.putIfAbsent(todayKey, () => []);
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (ctx) {
                      return SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Manage attendance',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(ctx).pop(),
                                    child: const Text('Done'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 360,
                                child: ListView(
                                  children: [
                                    for (final player in allUsers.where(
                                      (u) => u.role == UserRole.player,
                                    ))
                                      CheckboxListTile(
                                        value:
                                            (_globalAttendanceRecords[todayKey] ??
                                                    [])
                                                .contains(player.email),
                                        title: Text(player.fullName),
                                        subtitle: Text(player.email),
                                        onChanged: (v) {
                                          if (v == null) return;
                                          if (v) {
                                            _globalAttendanceRecords[todayKey]!
                                                .add(player.email);
                                          } else {
                                            _globalAttendanceRecords[todayKey]!
                                                .remove(player.email);
                                          }
                                          onAttendanceUpdated();
                                        },
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: accent),
                child: const Text('Manage attendance'),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _settingsView(BuildContext context, Color accent) {
    final lang = settings.language;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      children: [
        _PanelCard(
          title: L10n.t(lang, 'appearance_title'),
          subtitle: L10n.t(lang, 'appearance_subtitle'),
          accent: accent,
          child: _DarkModeToggleRow(
            isDarkTheme: settings.isDarkTheme,
            accent: accent,
            label: settings.isDarkTheme
                ? L10n.t(lang, 'dark_mode')
                : L10n.t(lang, 'light_mode'),
            onChanged: callbacks.onThemeChanged,
          ),
        ),
        const SizedBox(height: 12),
        _PanelCard(
          title: L10n.t(lang, 'font_size_title'),
          subtitle: L10n.t(lang, 'font_size_subtitle'),
          accent: accent,
          child: _FontSizeRow(
            fontScale: settings.fontScale,
            accent: accent,
            onChanged: callbacks.onFontScaleChanged,
          ),
        ),
        const SizedBox(height: 12),
        _PanelCard(
          title: L10n.t(lang, 'notifications_title'),
          subtitle: L10n.t(lang, 'notifications_subtitle'),
          accent: accent,
          child: Column(
            children: [
              _SettingsSwitchRow(
                icon: Icons.notifications_active_outlined,
                label: L10n.t(lang, 'notifications_master'),
                value: settings.notificationsEnabled,
                accent: accent,
                onChanged: callbacks.onNotificationsChanged,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Divider(height: 1),
              ),
              Opacity(
                opacity: settings.notificationsEnabled ? 1 : 0.4,
                child: IgnorePointer(
                  ignoring: !settings.notificationsEnabled,
                  child: Column(
                    children: [
                      _SettingsSwitchRow(
                        icon: Icons.chat_bubble_outline,
                        label: L10n.t(lang, 'notifications_chat'),
                        value: settings.notifyChat,
                        accent: accent,
                        dense: true,
                        onChanged: callbacks.onNotifyChatChanged,
                      ),
                      const SizedBox(height: 10),
                      _SettingsSwitchRow(
                        icon: Icons.fact_check_outlined,
                        label: L10n.t(lang, 'notifications_attendance'),
                        value: settings.notifyAttendance,
                        accent: accent,
                        dense: true,
                        onChanged: callbacks.onNotifyAttendanceChanged,
                      ),
                      const SizedBox(height: 10),
                      _SettingsSwitchRow(
                        icon: Icons.campaign_outlined,
                        label: L10n.t(lang, 'notifications_announcements'),
                        value: settings.notifyAnnouncements,
                        accent: accent,
                        dense: true,
                        onChanged: callbacks.onNotifyAnnouncementsChanged,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _PanelCard(
          title: L10n.t(lang, 'language_title'),
          subtitle: L10n.t(lang, 'language_subtitle'),
          accent: accent,
          child: Column(
            children: [
              for (final option in AppLanguage.values) ...[
                _LanguageOptionRow(
                  language: option,
                  selected: settings.language == option,
                  accent: accent,
                  onTap: () => callbacks.onLanguageChanged(option),
                ),
                if (option != AppLanguage.values.last)
                  const SizedBox(height: 8),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        _ProfileCard(
          name: user.fullName,
          role: _headlineForRole(user.role),
          team: 'JM Hockey',
          accent: accent,
          avatarIcon: Icons.person,
        ),
      ],
    );
  }

  Widget _playerProfileView(BuildContext context, Color accent) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      children: [
        _ProfileCard(
          name: user.fullName,
          role: 'Player #12 • Forward',
          team: 'JM Hockey U-16 Boys Team A',
          accent: accent,
          avatarIcon: Icons.sports_hockey,
          imageUrl: user.photoUrl,
        ),
        const SizedBox(height: 12),
        _PanelCard(
          title: 'Player overview',
          subtitle: 'Games, attendance, and season snapshot',
          accent: accent,
          child: Row(
            children: const [
              Expanded(
                child: _StatChip(label: 'Games', value: '21'),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _StatChip(label: 'Goals', value: '8'),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _StatChip(label: 'Assists', value: '5'),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _StatChip(label: 'Attendance', value: '18 / 21'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _PanelCard(
          title: 'Player details',
          subtitle: 'Quick facts about the player',
          accent: accent,
          child: const Column(
            children: [
              _StatusLine(label: 'Jersey', value: '12'),
              _StatusLine(label: 'Position', value: 'Forward'),
              _StatusLine(label: 'Preferred side', value: 'Left wing'),
              _StatusLine(label: 'Medical note', value: 'Cleared'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _PanelCard(
          title: 'Mark attendance',
          subtitle: 'Tap to enter code provided by the coach',
          accent: accent,
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final codeController = TextEditingController();
                    final result = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Mark attendance'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: codeController,
                              decoration: const InputDecoration(
                                labelText: '3-digit code',
                                hintText: 'e.g. 123',
                              ),
                              keyboardType: TextInputType.number,
                              maxLength: 3,
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              final code = codeController.text.trim();
                              if (code.length != 3) return;
                              final ok = markAttendanceGlobal(user.email, code);
                              Navigator.of(ctx).pop(ok);
                            },
                            child: const Text('Submit'),
                          ),
                        ],
                      ),
                    );
                    if (result == true) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Attendance marked')),
                      );
                    } else if (result == false) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Invalid or expired code'),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: accent),
                  child: const Text('Mark attendance'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _MonthHeader(
          title: 'Attendance month',
          accent: accent,
          onPrevious: () {},
          onNext: () {},
        ),
        const SizedBox(height: 12),
        _MonthSelector(
          months: _attendanceMonths,
          selectedIndex: _attendanceMonths.indexWhere(
            (month) => month.label == 'Oct 2023',
          ),
          accent: accent,
          onChanged: (_) {},
        ),
        const SizedBox(height: 12),
        _SummaryStrip(
          total: '21',
          present: '18 (G)',
          late: '2 (Y)',
          absent: '1 (R)',
          accent: accent,
        ),
        const SizedBox(height: 12),
        _ChartCard(
          title: 'Attendance trend',
          subtitle: 'Season summary',
          accent: accent,
          values: const [76, 84, 89, 94, 97],
          labels: const ['W1', 'W2', 'W3', 'W4', 'W5'],
        ),
        const SizedBox(height: 12),
        const _AttendanceCard(
          session: _AttendanceSession(
            date: 'Oct 24, 2023',
            title: 'Practice Session',
            detail: 'Drills & tactics • strong defensive work',
            status: 'PRESENT',
            statusColor: Color(0xFF1E88E5),
            icon: Icons.check_circle,
          ),
        ),
        const SizedBox(height: 10),
        const _AttendanceCard(
          session: _AttendanceSession(
            date: 'Oct 21, 2023',
            title: 'Scrimmage - Inter-Squad',
            detail: 'Strong passing and positioning',
            status: 'PRESENT',
            statusColor: Color(0xFF1E88E5),
            icon: Icons.check_circle,
          ),
        ),
        const SizedBox(height: 10),
        const _AttendanceCard(
          session: _AttendanceSession(
            date: 'Oct 18, 2023',
            title: 'Conditioning & Strength',
            detail: 'Slightly late, but good effort',
            status: 'LATE (5 mins)',
            statusColor: Color(0xFFFFB300),
            icon: Icons.schedule,
          ),
        ),
        const SizedBox(height: 10),
        const _AttendanceCard(
          session: _AttendanceSession(
            date: 'Oct 14, 2023',
            title: 'Strategy Meeting',
            detail: 'Excused from training',
            status: 'ABSENT',
            statusColor: Color(0xFFD32F2F),
            icon: Icons.cancel,
          ),
        ),
      ],
    );
  }

  String _headlineForRole(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Admin control center';
      case UserRole.player:
        return 'Player hub';
      case UserRole.coach:
        return 'Coach command center';
      case UserRole.parent:
        return 'Parent insights';
      case UserRole.performanceAnalyst:
        return 'Performance analyst hub';
      case UserRole.other:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  String _taglineForRole(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Full access: manage analytics, content, operations, communication, security, and every player profile from one dashboard.';
      case UserRole.player:
        return 'Track training, attendance, performance, and achievements with ease.';
      case UserRole.coach:
        return 'Plan sessions, evaluate players, and review match stats in real time.';
      case UserRole.parent:
        return 'Follow progress, schedules, and payments for your child.';
      case UserRole.performanceAnalyst:
        return 'Tag match events, review analytics, and manage video intelligence.';
      case UserRole.other:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  Color _accentForRole(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return const Color(0xFF1E88E5);
      case UserRole.player:
        return const Color(0xFF1E88E5);
      case UserRole.coach:
        return const Color(0xFFB71C1C);
      case UserRole.parent:
        return const Color(0xFF7B1FA2);
      case UserRole.performanceAnalyst:
        return const Color(0xFF00695C);
      case UserRole.other:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  List<_DashboardItem> _modulesForRole(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return const [
          _DashboardItem(
            title: 'Admin Panel',
            subtitle: 'Full admin dashboard',
            icon: Icons.admin_panel_settings,
            detailTitle: 'Admin Panel',
            detailText:
                'Web admin dashboard: users, payments, tournaments, analytics, and CMS.',
          ),
          _DashboardItem(
            title: 'Analytics',
            subtitle: 'Overview',
            icon: Icons.insights,
            detailTitle: 'Main Dashboard & Analytics Hub',
            detailText:
                'Review club growth, attendance, and performance metrics in one view.',
          ),
          _DashboardItem(
            title: 'Players',
            subtitle: 'Manage roster',
            icon: Icons.groups_2,
            detailTitle: 'Player Roster & Management',
            detailText:
                'Open, review, and edit every player profile, performance record, and achievement.',
          ),
          _DashboardItem(
            title: 'Users',
            subtitle: 'Add people',
            icon: Icons.person_add_alt_1,
            detailTitle: 'User Management',
            detailText:
                'Create a new player, coach, parent, or admin account with full details and a photo.',
          ),
          _DashboardItem(
            title: 'Attendance',
            subtitle: 'Player metrics',
            icon: Icons.fact_check,
            detailTitle: 'Player Attendance Page',
            detailText:
                'Track attendance across players and drill statuses in real time.',
          ),
          _DashboardItem(
            title: 'Operations',
            subtitle: 'Schedule management',
            icon: Icons.calendar_month,
            detailTitle: 'Operations & Schedule Management',
            detailText: 'Keep matches, training, and events smoothly planned.',
          ),
          _DashboardItem(
            title: 'Security',
            subtitle: 'System controls',
            icon: Icons.security,
            detailTitle: 'System Settings & Security',
            detailText: 'Secure the platform with permissions and controls.',
          ),
          _DashboardItem(
            title: 'Communication',
            subtitle: 'Groups and messages',
            icon: Icons.forum,
            detailTitle: 'Communication Portal',
            detailText: 'Send updates to staff, players, and parents.',
          ),
          _DashboardItem(
            title: 'Public Page',
            subtitle: 'Edit gallery and news',
            icon: Icons.public,
            detailTitle: 'Public Page Editor',
            detailText:
                'Update gallery pictures, news posts, and public page information.',
          ),
          _DashboardItem(
            title: 'CMS',
            subtitle: 'Content manager',
            icon: Icons.article,
            detailTitle: 'Content Management System',
            detailText: 'Publish announcements, stories, and resources.',
          ),
          _DashboardItem(
            title: 'E-Commerce',
            subtitle: 'Merchandise store',
            icon: Icons.shopping_bag,
            detailTitle: 'E-Commerce Module',
            detailText:
                'Manage JM and partner merchandise, stock, and order delivery.',
          ),
        ];
      case UserRole.player:
        return const [
          _DashboardItem(
            title: 'Profile',
            subtitle: 'Player profile',
            icon: Icons.account_circle,
            detailTitle: 'Player Profile Page',
            detailText:
                'A clean personal profile for your profile, ID, and details.',
          ),
          _DashboardItem(
            title: 'Attendance',
            subtitle: 'Track sessions',
            icon: Icons.fact_check,
            detailTitle: 'Player Attendance Page',
            detailText: 'See attendance history, session notes, and status.',
          ),
          _DashboardItem(
            title: 'Performance',
            subtitle: 'Training insights',
            icon: Icons.show_chart,
            detailTitle: 'Performance Page',
            detailText: 'Monitor strength, velocity, and training output.',
          ),
          _DashboardItem(
            title: 'Achievements',
            subtitle: 'Rewards',
            icon: Icons.emoji_events,
            detailTitle: 'Achievements Page',
            detailText: 'Celebrate milestones, badges, and MVP moments.',
          ),
          _DashboardItem(
            title: 'E-Commerce',
            subtitle: 'Shop gear',
            icon: Icons.shopping_cart,
            detailTitle: 'E-Commerce Module',
            detailText: 'Browse and buy JM merchandise and partner products.',
          ),
        ];
      case UserRole.coach:
        return const [
          _DashboardItem(
            title: 'Attendance taking',
            subtitle: 'Mark session attendance',
            icon: Icons.fact_check,
            detailTitle: 'Coach Attendance Taking',
            detailText: 'Mark player attendance and review session statuses.',
          ),
          _DashboardItem(
            title: 'Session planning',
            subtitle: 'Plan weekly sessions',
            icon: Icons.event_note,
            detailTitle: 'Session Planning',
            detailText:
                'Build the weekly plan with goals, timings, and coaching focus.',
          ),
          _DashboardItem(
            title: 'Session templates',
            subtitle: 'Reusable session formats',
            icon: Icons.copy_all,
            detailTitle: 'Session Templates',
            detailText:
                'Use reusable templates for recovery, technical, and match-prep sessions.',
          ),
          _DashboardItem(
            title: 'Drill library',
            subtitle: 'Drills and variations',
            icon: Icons.sports,
            detailTitle: 'Drill Library',
            detailText:
                'Browse drills by objective, intensity, and group size.',
          ),
          _DashboardItem(
            title: 'Tactical board',
            subtitle: 'Shape and tactics',
            icon: Icons.dashboard_customize,
            detailTitle: 'Tactical Board',
            detailText:
                'Set formations, transitions, and pressing instructions.',
          ),
          _DashboardItem(
            title: 'Player grading',
            subtitle: 'Rate development',
            icon: Icons.grading,
            detailTitle: 'Player Grading',
            detailText:
                'Track player grades for technical, tactical, and attitude metrics.',
          ),
          _DashboardItem(
            title: 'Match analysis upload',
            subtitle: 'Video and notes',
            icon: Icons.video_file,
            detailTitle: 'Match Analysis Upload',
            detailText:
                'Upload post-match clips and analysis notes for review.',
          ),
          _DashboardItem(
            title: 'Injury reports',
            subtitle: 'Medical tracking',
            icon: Icons.healing,
            detailTitle: 'Injury Reports',
            detailText:
                'Log injury incidents, treatment status, and return timelines.',
          ),
          _DashboardItem(
            title: 'Team selection tools',
            subtitle: 'Lineup builder',
            icon: Icons.groups,
            detailTitle: 'Team Selection Tools',
            detailText:
                'Build lineups, assign roles, and finalize match-day squads.',
          ),
        ];
      case UserRole.parent:
        return const [
          _DashboardItem(
            title: 'Dashboard',
            subtitle: 'Parent overview',
            icon: Icons.dashboard,
            detailTitle: 'Parent Dashboard',
            detailText: 'A calm, focused place for parent updates.',
          ),
          _DashboardItem(
            title: 'Progress',
            subtitle: 'Child progress',
            icon: Icons.timeline,
            detailTitle: 'Child Progress Page',
            detailText: 'Follow growth, readiness, and performance trends.',
          ),
          _DashboardItem(
            title: 'Attendance',
            subtitle: 'Session tracking',
            icon: Icons.fact_check,
            detailTitle: 'Parent Attendance Page',
            detailText: 'Review your child’s training attendance.',
          ),
          _DashboardItem(
            title: 'Payments',
            subtitle: 'Fee overview',
            icon: Icons.receipt_long,
            detailTitle: 'Financials & Payment Monitoring',
            detailText: 'Keep track of fees, invoices, and payment updates.',
          ),
          _DashboardItem(
            title: 'E-Commerce',
            subtitle: 'Kit and merchandise',
            icon: Icons.storefront,
            detailTitle: 'E-Commerce Module',
            detailText:
                'Order JM apparel and partner merchandise with delivery tracking.',
          ),
        ];
      case UserRole.performanceAnalyst:
        return const [
          _DashboardItem(
            title: 'Match Tagging',
            subtitle: 'Tag key events',
            icon: Icons.tag,
            detailTitle: 'Performance Match Tagging',
            detailText:
                'Tag goals, assists, turnovers, interceptions, circle entries, shots, and penalty corners.',
          ),
          _DashboardItem(
            title: 'Analytics',
            subtitle: 'Performance insights',
            icon: Icons.analytics,
            detailTitle: 'Performance Analytics',
            detailText:
                'Review heatmaps, passing statistics, possession zones, team shape, and performance trends.',
          ),
          _DashboardItem(
            title: 'Video System',
            subtitle: 'Replay and clips',
            icon: Icons.ondemand_video,
            detailTitle: 'Performance Video System',
            detailText:
                'Manage video replay, highlight clipping, tactical breakdowns, and AI tagging later.',
          ),
        ];
      case UserRole.other:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }
}

class _DarkModeToggleRow extends StatelessWidget {
  const _DarkModeToggleRow({
    required this.isDarkTheme,
    required this.accent,
    required this.onChanged,
    required this.label,
  });

  final bool isDarkTheme;
  final Color accent;
  final ValueChanged<bool> onChanged;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(isDarkTheme ? Icons.dark_mode : Icons.light_mode, color: accent),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Switch(
            value: isDarkTheme,
            activeThumbColor: accent,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _FontSizeRow extends StatelessWidget {
  const _FontSizeRow({
    required this.fontScale,
    required this.accent,
    required this.onChanged,
  });

  final double fontScale;
  final Color accent;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Text(
            'A',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade500,
            ),
          ),
          Expanded(
            child: Slider(
              value: fontScale,
              min: 0.85,
              max: 1.3,
              divisions: 9,
              activeColor: accent,
              label: '${(fontScale * 100).round()}%',
              onChanged: onChanged,
            ),
          ),
          Text(
            'A',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '${(fontScale * 100).round()}%',
              style: TextStyle(
                color: accent,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsSwitchRow extends StatelessWidget {
  const _SettingsSwitchRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
    required this.onChanged,
    this.dense = false,
  });

  final IconData icon;
  final String label;
  final bool value;
  final Color accent;
  final ValueChanged<bool> onChanged;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: accent, size: dense ? 18 : 22),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: dense ? 13 : 15,
            ),
          ),
        ),
        Switch(value: value, activeThumbColor: accent, onChanged: onChanged),
      ],
    );
  }
}

class _LanguageOptionRow extends StatelessWidget {
  const _LanguageOptionRow({
    required this.language,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  final AppLanguage language;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? accent.withValues(alpha: 0.12)
                : Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: selected ? accent : Colors.transparent),
          ),
          child: Row(
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: accent,
              ),
              const SizedBox(width: 12),
              Text(
                language.label,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({
    required this.item,
    required this.accent,
    required this.onTap,
  });

  final _DashboardItem item;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: accent.withValues(alpha: 0.12),
                child: Icon(item.icon, color: accent),
              ),
              const SizedBox(height: 12),
              Text(
                item.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.subtitle,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrivateChat {
  _PrivateChat({
    required this.participantEmailA,
    required this.participantNameA,
    required this.participantEmailB,
    required this.participantNameB,
    List<_ChatMessage>? messages,
  }) : messages = messages ?? <_ChatMessage>[];

  final String participantEmailA;
  final String participantNameA;
  final String participantEmailB;
  final String participantNameB;
  final List<_ChatMessage> messages;

  bool includes(String email) =>
      participantEmailA.toLowerCase() == email.toLowerCase() ||
      participantEmailB.toLowerCase() == email.toLowerCase();
}

final List<_PrivateChat> _sharedPrivateChats = [];

_PrivateChat _getOrCreatePrivateChat(AppUser a, AppUser b) {
  for (final chat in _sharedPrivateChats) {
    if (chat.includes(a.email) && chat.includes(b.email)) {
      return chat;
    }
  }
  final chat = _PrivateChat(
    participantEmailA: a.email,
    participantNameA: a.fullName,
    participantEmailB: b.email,
    participantNameB: b.fullName,
  );
  _sharedPrivateChats.add(chat);
  return chat;
}

String _roleLabel(UserRole role) {
  switch (role) {
    case UserRole.admin:
      return 'Admin';
    case UserRole.coach:
      return 'Coach';
    case UserRole.player:
      return 'Player';
    case UserRole.parent:
      return 'Parent';
    case UserRole.performanceAnalyst:
      return 'Performance Analyst';
    case UserRole.other:
      // TODO: Handle this case.
      throw UnimplementedError();
  }
}

class _ChatListPage extends StatefulWidget {
  const _ChatListPage({
    required this.accent,
    required this.currentUser,
    required this.allUsers,
    required this.groupThreads,
  });

  final Color accent;
  final AppUser currentUser;
  final List<AppUser> allUsers;
  final List<_ChatGroup> groupThreads;

  @override
  State<_ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<_ChatListPage> {
  List<_ChatGroup> get _visibleGroups {
    if (widget.currentUser.role == UserRole.admin) {
      return widget.groupThreads;
    }
    return widget.groupThreads
        .where((thread) => thread.visibleTo.contains(widget.currentUser.role))
        .toList();
  }

  List<AppUser> get _contacts {
    final others = widget.allUsers.where(
      (u) => u.email.toLowerCase() != widget.currentUser.email.toLowerCase(),
    );
    switch (widget.currentUser.role) {
      case UserRole.admin:
        return others.toList();
      case UserRole.coach:
        return others.where((u) => u.role != UserRole.coach).toList();
      case UserRole.performanceAnalyst:
        return others
            .where(
              (u) =>
                  u.role == UserRole.admin ||
                  u.role == UserRole.coach ||
                  u.role == UserRole.player,
            )
            .toList();
      case UserRole.player:
      case UserRole.parent:
        return others
            .where((u) => u.role == UserRole.admin || u.role == UserRole.coach)
            .toList();
      case UserRole.other:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  String _lastMessagePreview(List<_ChatMessage> messages) {
    if (messages.isEmpty) {
      return 'No messages yet';
    }
    final last = messages.last;
    return '${last.sender}: ${last.text}';
  }

  Future<void> _openGroup(_ChatGroup group) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _ChatThreadPage(
          title: group.name,
          subtitle: 'Members: ${group.members.join(', ')}',
          messages: group.messages,
          currentUserName: widget.currentUser.fullName,
          accent: widget.accent,
          avatarLabel: group.name.isNotEmpty ? group.name[0] : '#',
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  Future<void> _openPrivate(AppUser contact) async {
    final chat = _getOrCreatePrivateChat(widget.currentUser, contact);
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _ChatThreadPage(
          title: contact.fullName,
          subtitle: _roleLabel(contact.role),
          messages: chat.messages,
          currentUserName: widget.currentUser.fullName,
          accent: widget.accent,
          avatarLabel: contact.fullName.isNotEmpty ? contact.fullName[0] : '?',
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final groups = _visibleGroups;
    final contacts = _contacts;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      children: [
        Text(
          'Groups',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 15,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 8),
        if (groups.isEmpty)
          Text(
            'No group chats yet',
            style: TextStyle(color: Colors.grey.shade500),
          )
        else
          for (final group in groups) ...[
            _ChatListTile(
              title: group.name,
              subtitle: _lastMessagePreview(group.messages),
              avatarLabel: group.name.isNotEmpty ? group.name[0] : '#',
              accent: widget.accent,
              onTap: () => _openGroup(group),
            ),
            const SizedBox(height: 8),
          ],
        const SizedBox(height: 16),
        Text(
          'Direct messages',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 15,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 8),
        if (contacts.isEmpty)
          Text(
            'No contacts available',
            style: TextStyle(color: Colors.grey.shade500),
          )
        else
          for (final contact in contacts) ...[
            Builder(
              builder: (context) {
                final chat = _getOrCreatePrivateChat(
                  widget.currentUser,
                  contact,
                );
                return _ChatListTile(
                  title: contact.fullName,
                  subtitle: chat.messages.isEmpty
                      ? _roleLabel(contact.role)
                      : _lastMessagePreview(chat.messages),
                  avatarLabel: contact.fullName.isNotEmpty
                      ? contact.fullName[0]
                      : '?',
                  accent: widget.accent,
                  onTap: () => _openPrivate(contact),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
      ],
    );
  }
}

class _ChatListTile extends StatelessWidget {
  const _ChatListTile({
    required this.title,
    required this.subtitle,
    required this.avatarLabel,
    required this.accent,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String avatarLabel;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: accent.withValues(alpha: 0.14),
                child: Text(
                  avatarLabel.toUpperCase(),
                  style: TextStyle(color: accent, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade500),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatThreadPage extends StatefulWidget {
  const _ChatThreadPage({
    required this.title,
    required this.subtitle,
    required this.messages,
    required this.currentUserName,
    required this.accent,
    required this.avatarLabel,
  });

  final String title;
  final String subtitle;
  final List<_ChatMessage> messages;
  final String currentUserName;
  final Color accent;
  final String avatarLabel;

  @override
  State<_ChatThreadPage> createState() => _ChatThreadPageState();
}

class _ChatThreadPageState extends State<_ChatThreadPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      return;
    }
    setState(() {
      widget.messages.add(
        _ChatMessage(
          sender: widget.currentUserName,
          text: text,
          timeLabel: 'Now',
        ),
      );
      _controller.clear();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: widget.accent.withValues(alpha: 0.15),
              foregroundColor: widget.accent,
              child: Text(widget.avatarLabel.toUpperCase()),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (widget.subtitle.isNotEmpty)
                    Text(
                      widget.subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: widget.messages.isEmpty
                  ? Center(
                      child: Text(
                        'No messages yet — say hello!',
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: widget.messages.length,
                      itemBuilder: (context, index) {
                        final message = widget.messages[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _ChatMessageTile(
                            message: message,
                            isMe: message.sender == widget.currentUserName,
                            accent: widget.accent,
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Message',
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: widget.accent,
                    child: IconButton(
                      onPressed: _send,
                      icon: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatMessageTile extends StatelessWidget {
  const _ChatMessageTile({
    required this.message,
    required this.isMe,
    required this.accent,
  });

  final _ChatMessage message;
  final bool isMe;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe
              ? accent.withValues(alpha: 0.12)
              : (isDark ? Colors.white10 : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              message.sender,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(message.text),
            const SizedBox(height: 4),
            Text(
              message.timeLabel,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class AttendanceDetailPage extends StatefulWidget {
  const AttendanceDetailPage({
    super.key,
    required this.playerName,
    required this.playerRole,
    required this.accent,
  });

  final String playerName;
  final String playerRole;
  final Color accent;

  @override
  State<AttendanceDetailPage> createState() => _AttendanceDetailPageState();
}

class _AttendanceDetailPageState extends State<AttendanceDetailPage> {
  int _selectedAttendanceMonth = 0;

  void _previousMonth() {
    setState(() {
      _selectedAttendanceMonth =
          (_selectedAttendanceMonth - 1 + _attendanceMonths.length) %
          _attendanceMonths.length;
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedAttendanceMonth =
          (_selectedAttendanceMonth + 1) % _attendanceMonths.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final month = _attendanceMonths[_selectedAttendanceMonth];
    const team = 'JM Hockey U-16 Boys Team A';

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_ios_new),
              ),
              const SizedBox(height: 8),
              _MonthHeader(
                title: 'Month: ${month.label}',
                accent: widget.accent,
                onPrevious: _previousMonth,
                onNext: _nextMonth,
              ),
              const SizedBox(height: 12),
              _ProfileCard(
                name: widget.playerName,
                role: widget.playerRole,
                team: team,
                accent: widget.accent,
                avatarIcon: Icons.person,
              ),
              const SizedBox(height: 12),
              _SummaryStrip(
                total: month.totalSessions,
                present: month.present,
                late: month.late,
                absent: month.absent,
                accent: widget.accent,
              ),
              const SizedBox(height: 12),
              _ChartCard(
                title: 'Attendance trend',
                subtitle: month.chartSubtitle,
                accent: widget.accent,
                values: month.trendValues,
                labels: month.trendLabels,
              ),
              const SizedBox(height: 12),
              for (final session in month.sessions) ...[
                _AttendanceCard(session: session),
                const SizedBox(height: 10),
              ],
              _BottomReportCard(
                buttonText: 'Detailed Performance Report',
                subtitle:
                    'Attendance history is linked to player development data.',
                accent: widget.accent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CmsPost {
  _CmsPost({required this.title, required this.body, required this.date});

  final String title;
  final String body;
  final String date;
}

class DetailPage extends StatefulWidget {
  const DetailPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.icon,
    required this.viewerRole,
    required this.onCreateUser,
    required this.publicAboutText,
    required this.publicGallery,
    required this.publicNews,
    required this.onUpdatePublicAbout,
    required this.onAddPublicGalleryImage,
    required this.onRemovePublicGalleryImage,
    required this.onAddPublicNews,
    required this.onRemovePublicNews,
    this.allUsers = const [],
  });

  final String title;
  final String subtitle;
  final Color accent;
  final IconData icon;
  final UserRole viewerRole;
  final List<AppUser> allUsers;
  final String publicAboutText;
  final List<String> publicGallery;
  final List<PublicNewsItem> publicNews;
  final ValueChanged<String> onUpdatePublicAbout;
  final String? Function(String imageUrl) onAddPublicGalleryImage;
  final ValueChanged<int> onRemovePublicGalleryImage;
  final String? Function({
    required String title,
    required String body,
    String? imageUrl,
  })
  onAddPublicNews;
  final ValueChanged<int> onRemovePublicNews;
  final String? Function({
    required String fullName,
    required String email,
    required String password,
    required UserRole role,
    String? photoUrl,
    String? phone,
    String? team,
    String? school,
    String? position,
    String? notes,
  })
  onCreateUser;

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final TextEditingController _groupMessageController = TextEditingController();
  final TextEditingController _newGroupNameController = TextEditingController();
  final TextEditingController _newMemberNameController =
      TextEditingController();
  final List<_ChatGroup> _groups = _sharedTeamChats;

  final Map<UserRole, bool> _typePermissions = {
    UserRole.admin: true,
    UserRole.coach: true,
    UserRole.player: false,
    UserRole.parent: false,
    UserRole.performanceAnalyst: true,
  };

  final Map<UserRole, bool> _createPermissions = {
    UserRole.admin: true,
    UserRole.coach: false,
    UserRole.player: false,
    UserRole.parent: false,
    UserRole.performanceAnalyst: false,
  };

  final List<_CmsPost> _cmsPosts = [
    _CmsPost(
      title: 'Elite Squad clinches regional title',
      body:
          'Our U-16 Elite Squad brought home the regional championship after '
          'a hard-fought final. Congratulations to the whole team!',
      date: 'Jul 21, 2026',
    ),
    _CmsPost(
      title: 'Registration open for the winter intake',
      body:
          'Spots are limited for beginner and intermediate clinics starting '
          'next month. Sign up early to reserve your place.',
      date: 'Jul 12, 2026',
    ),
    _CmsPost(
      title: 'New conditioning program launched',
      body:
          'Coach Malik has introduced a revamped off-ice conditioning '
          'program focused on speed and injury prevention.',
      date: 'Jun 30, 2026',
    ),
  ];
  final TextEditingController _cmsTitleController = TextEditingController();
  final TextEditingController _cmsBodyController = TextEditingController();
  final TextEditingController _newUserNameController = TextEditingController();
  final TextEditingController _newUserEmailController = TextEditingController();
  final TextEditingController _newUserPasswordController =
      TextEditingController();
  final TextEditingController _newUserPhotoController = TextEditingController();
  final TextEditingController _newUserPhoneController = TextEditingController();
  final TextEditingController _newUserTeamController = TextEditingController();
  final TextEditingController _newUserSchoolController =
      TextEditingController();
  final TextEditingController _newUserPositionController =
      TextEditingController();
  final TextEditingController _newUserNotesController = TextEditingController();
  // deprecated controller `_newPublicImageController` removed
  final TextEditingController _publicAboutController = TextEditingController();
  final TextEditingController _publicGalleryImageController =
      TextEditingController();
  final TextEditingController _publicNewsTitleController =
      TextEditingController();
  final TextEditingController _publicNewsBodyController =
      TextEditingController();
  final TextEditingController _publicNewsImageController =
      TextEditingController();

  int _selectedGroup = 0;
  int _attendanceMonthIndex = 0;
  int _analyticsMonthIndex = 0;
  UserRole _newUserRole = UserRole.player;
  UserRole? _userRoleFilter;
  String? _newUserError;
  // deprecated attendance locals removed; use global attendance helpers
  String? _publicEditError;

  @override
  void initState() {
    super.initState();
    _publicAboutController.text = widget.publicAboutText;
  }

  @override
  void dispose() {
    _groupMessageController.dispose();
    _newGroupNameController.dispose();
    _newMemberNameController.dispose();
    _cmsTitleController.dispose();
    _cmsBodyController.dispose();
    _newUserNameController.dispose();
    _newUserEmailController.dispose();
    _newUserPasswordController.dispose();
    _newUserPhotoController.dispose();
    _newUserPhoneController.dispose();
    _newUserTeamController.dispose();
    _newUserSchoolController.dispose();
    _newUserPositionController.dispose();
    _newUserNotesController.dispose();
    _publicAboutController.dispose();
    _publicGalleryImageController.dispose();
    _publicNewsTitleController.dispose();
    _publicNewsBodyController.dispose();
    _publicNewsImageController.dispose();
    super.dispose();
  }

  void _createGroup() {
    final name = _newGroupNameController.text.trim();
    if (name.isEmpty) {
      return;
    }

    setState(() {
      _groups.add(
        _ChatGroup(
          name: name,
          members: ['Admin User'],
          canType: [true],
          visibleTo: [UserRole.admin, UserRole.coach, UserRole.player],
          messages: const [],
        ),
      );
      _selectedGroup = _groups.length - 1;
      _newGroupNameController.clear();
    });
  }

  void _addMemberToGroup() {
    final name = _newMemberNameController.text.trim();
    if (name.isEmpty || _groups.isEmpty) {
      return;
    }

    setState(() {
      final group = _groups[_selectedGroup];
      group.members.add(name);
      group.canType.add(true);
      _newMemberNameController.clear();
    });
  }

  void _sendGroupMessage() {
    final text = _groupMessageController.text.trim();
    if (text.isEmpty || _groups.isEmpty) {
      return;
    }

    setState(() {
      _groups[_selectedGroup].messages.add(
        _ChatMessage(sender: 'Admin User', text: text, timeLabel: 'Now'),
      );
      _groupMessageController.clear();
    });
  }

  void _toggleMemberTyping(int memberIndex) {
    if (_groups.isEmpty) {
      return;
    }

    setState(() {
      final group = _groups[_selectedGroup];
      if (memberIndex < group.canType.length) {
        group.canType[memberIndex] = !group.canType[memberIndex];
      }
    });
  }

  void _previousAttendanceMonth() {
    setState(() {
      _attendanceMonthIndex =
          (_attendanceMonthIndex - 1 + _attendanceMonths.length) %
          _attendanceMonths.length;
    });
  }

  void _nextAttendanceMonth() {
    setState(() {
      _attendanceMonthIndex =
          (_attendanceMonthIndex + 1) % _attendanceMonths.length;
    });
  }

  void _selectAttendanceMonth(int index) {
    setState(() => _attendanceMonthIndex = index);
  }

  void _previousAnalyticsMonth() {
    setState(() {
      _analyticsMonthIndex =
          (_analyticsMonthIndex - 1 + _attendanceMonths.length) %
          _attendanceMonths.length;
    });
  }

  void _nextAnalyticsMonth() {
    setState(() {
      _analyticsMonthIndex =
          (_analyticsMonthIndex + 1) % _attendanceMonths.length;
    });
  }

  void _togglePermission(UserRole role, {required bool canType}) {
    setState(() {
      if (canType) {
        _typePermissions[role] = !(_typePermissions[role] ?? false);
      } else {
        _createPermissions[role] = !(_createPermissions[role] ?? false);
      }
    });
  }

  void _publishCmsPost() {
    final title = _cmsTitleController.text.trim();
    final body = _cmsBodyController.text.trim();
    if (title.isEmpty || body.isEmpty) {
      return;
    }
    setState(() {
      _cmsPosts.insert(0, _CmsPost(title: title, body: body, date: 'Just now'));
      _cmsTitleController.clear();
      _cmsBodyController.clear();
    });
  }

  void _deleteCmsPost(int index) {
    setState(() => _cmsPosts.removeAt(index));
  }

  void _submitNewUser() {
    final fullName = _newUserNameController.text.trim();
    final email = _newUserEmailController.text.trim();
    final password = _newUserPasswordController.text;

    if (fullName.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() => _newUserError = 'Please fill out all required fields');
      return;
    }

    final error = widget.onCreateUser(
      fullName: fullName,
      email: email,
      password: password,
      role: _newUserRole,
      photoUrl: _newUserPhotoController.text,
      phone: _newUserPhoneController.text,
      team: _newUserTeamController.text,
      school: _newUserSchoolController.text,
      position: _newUserPositionController.text,
      notes: _newUserNotesController.text,
    );

    if (error != null) {
      setState(() => _newUserError = error);
      return;
    }

    setState(() {
      _newUserError = null;
      _newUserNameController.clear();
      _newUserEmailController.clear();
      _newUserPasswordController.clear();
      _newUserPhotoController.clear();
      _newUserPhoneController.clear();
      _newUserTeamController.clear();
      _newUserSchoolController.clear();
      _newUserPositionController.clear();
      _newUserNotesController.clear();
      _newUserRole = UserRole.player;
    });
  }

  void _savePublicAbout() {
    final value = _publicAboutController.text.trim();
    if (value.isEmpty) {
      setState(
        () => _publicEditError = 'Public page description cannot be empty',
      );
      return;
    }
    widget.onUpdatePublicAbout(value);
    setState(() => _publicEditError = null);
  }

  void _addGalleryImage() {
    final error = widget.onAddPublicGalleryImage(
      _publicGalleryImageController.text,
    );
    if (error != null) {
      setState(() => _publicEditError = error);
      return;
    }
    setState(() {
      _publicEditError = null;
      _publicGalleryImageController.clear();
    });
  }

  void _publishPublicNews() {
    final error = widget.onAddPublicNews(
      title: _publicNewsTitleController.text,
      body: _publicNewsBodyController.text,
      imageUrl: _publicNewsImageController.text,
    );
    if (error != null) {
      setState(() => _publicEditError = error);
      return;
    }
    setState(() {
      _publicEditError = null;
      _publicNewsTitleController.clear();
      _publicNewsBodyController.clear();
      _publicNewsImageController.clear();
    });
  }

  void _generateAttendanceCode() {
    generateAttendanceCodeGlobal();
    setState(() {});
  }

  bool _markAttendance(String email, String code) {
    final ok = markAttendanceGlobal(email, code);
    if (ok) setState(() {});
    return ok;
  }

  @override
  Widget build(BuildContext context) {
    final lower = widget.title.toLowerCase();
    final isPlayerProfile = lower.contains('player profile');
    final isPerformance = lower.contains('performance');
    final isAchievements = lower.contains('achievements');
    final isUserManagement =
        lower.contains('user management') ||
        lower.contains('add new user') ||
        lower.contains('users');
    final isCoachFeature =
        lower.contains('session planning') ||
        lower.contains('session templates') ||
        lower.contains('drill library') ||
        lower.contains('tactical board') ||
        lower.contains('player grading') ||
        lower.contains('match analysis upload') ||
        lower.contains('injury reports') ||
        lower.contains('team selection tools');
    final isPerformanceAnalystFeature =
        lower.contains('performance match tagging') ||
        lower.contains('performance analytics') ||
        lower.contains('performance video system') ||
        lower.contains('match tagging') ||
        lower.contains('video system');
    final isEcommerce =
        lower.contains('e-commerce') ||
        lower.contains('ecommerce') ||
        lower.contains('merchandise') ||
        lower.contains('store');
    final isAttendance = lower.contains('attendance');
    final isOperations =
        lower.contains('operations') || lower.contains('schedule');
    final isSecurity = lower.contains('security');
    final isCommunication =
        lower.contains('communication') || lower.contains('portal');
    final isCms = lower.contains('cms') || lower.contains('content management');
    final isAdminPanel =
        lower.contains('admin panel') || lower.contains('admin dashboard');
    final isPublicPage =
        lower.contains('public page') || lower.contains('public page editor');
    final isAnalytics =
        (lower.contains('analytics') && !isPerformanceAnalystFeature) ||
        lower.contains('main dashboard');
    final isPlayerRoster =
        lower.contains('player roster') || lower.contains('player management');

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_ios_new),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: widget.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: widget.accent.withValues(alpha: 0.2),
                      child: Icon(widget.icon, color: widget.accent),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            widget.subtitle,
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (isPlayerRoster) ..._playerRosterView(),
              if (isAnalytics) ..._analyticsView(),
              if (isCms) ..._cmsView(),
              if (isPlayerProfile) ..._playerProfileDetailView(),
              if (isPerformance) ..._playerPerformanceView(),
              if (isAchievements) ..._playerAchievementsView(),
              if (isUserManagement) ..._adminUsersView(),
              if (isAdminPanel) ..._adminPanelView(),
              if (isAttendance && !isCoachFeature) ..._attendanceView(),
              if (isCoachFeature) ..._coachFeatureView(lower),
              if (isPerformanceAnalystFeature)
                ..._performanceAnalystView(lower),
              if (isEcommerce) ..._ecommerceView(),
              if (isOperations) ..._operationsView(),
              if (isCommunication) ..._communicationView(),
              if (isSecurity) ..._securityView(widget.accent),
              if (isPublicPage && widget.viewerRole == UserRole.admin)
                ..._publicPageEditorView(),
              if (!isAttendance &&
                  !isPlayerProfile &&
                  !isPerformance &&
                  !isAchievements &&
                  !isUserManagement &&
                  !isCoachFeature &&
                  !isPerformanceAnalystFeature &&
                  !isEcommerce &&
                  !isOperations &&
                  !isCommunication &&
                  !isSecurity &&
                  !isPublicPage &&
                  !isCms &&
                  !isAnalytics &&
                  !isPlayerRoster)
                ..._defaultView(),
            ],
          ),
        ),
      ),
    );
  }

  void _openFeatureSheet({
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                    const SizedBox(height: 16),
                    ...children,
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _attendanceView() {
    if (widget.viewerRole == UserRole.admin) {
      return _adminAttendanceView();
    }

    final isCoachAttendance = widget.viewerRole == UserRole.coach;
    return _attendanceDetailView(isCoachAttendance: isCoachAttendance);
  }

  List<Widget> _attendanceDetailView({required bool isCoachAttendance}) {
    final month = _attendanceMonths[_attendanceMonthIndex];

    return [
      _MonthHeader(
        title: 'Month: ${month.label}',
        accent: widget.accent,
        onPrevious: _previousAttendanceMonth,
        onNext: _nextAttendanceMonth,
      ),
      const SizedBox(height: 12),
      _MonthSelector(
        months: _attendanceMonths,
        selectedIndex: _attendanceMonthIndex,
        accent: widget.accent,
        onChanged: _selectAttendanceMonth,
      ),
      const SizedBox(height: 12),
      _ProfileCard(
        name: isCoachAttendance ? 'Coach Malik' : month.playerName,
        role: isCoachAttendance ? 'Head Coach' : month.playerRole,
        team: month.team,
        accent: widget.accent,
        avatarIcon: isCoachAttendance ? Icons.co_present : Icons.person,
      ),
      const SizedBox(height: 12),
      _SummaryStrip(
        total: month.totalSessions,
        present: isCoachAttendance ? month.coachPresent : month.present,
        late: isCoachAttendance ? month.coachLate : month.late,
        absent: month.absent,
        accent: widget.accent,
      ),
      const SizedBox(height: 12),
      _ChartCard(
        title: 'Attendance trend',
        subtitle: month.chartSubtitle,
        accent: widget.accent,
        values: month.trendValues,
        labels: month.trendLabels,
      ),
      const SizedBox(height: 12),
      for (final session in month.sessions) ...[
        _AttendanceCard(session: session),
        const SizedBox(height: 10),
      ],
      _BottomReportCard(
        buttonText: 'Detailed Performance Report',
        subtitle: 'Attendance history is linked to player development data.',
        accent: widget.accent,
        onPressed: () => _openFeatureSheet(
          title: 'Detailed Performance Report',
          subtitle: 'Attendance history linked to player development data',
          children: const [
            _StatusLine(label: 'Sessions tracked', value: '21'),
            _StatusLine(label: 'Present', value: '18'),
            _StatusLine(label: 'Late', value: '2'),
            _StatusLine(label: 'Absent', value: '1'),
          ],
        ),
      ),
    ];
  }

  List<Widget> _playerRosterView() {
    final players = widget.allUsers
        .where((u) => u.role == UserRole.player)
        .toList();

    return [
      _PanelCard(
        title: 'Full player access',
        subtitle: 'As admin you can open and manage every player record',
        accent: widget.accent,
        child: Row(
          children: [
            Expanded(
              child: _StatChip(label: 'Players', value: '${players.length}'),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: _StatChip(label: 'Access', value: 'Full'),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      if (players.isEmpty)
        Text(
          'No registered players yet.',
          style: TextStyle(color: Colors.grey.shade500),
        )
      else
        for (final player in players) ...[
          _AdminPlayerCard(
            player: player,
            accent: widget.accent,
            onOpenProfile: () => _openPlayerSection(player, 'Player Profile'),
            onOpenPerformance: () => _openPlayerSection(player, 'Performance'),
            onOpenAchievements: () =>
                _openPlayerSection(player, 'Achievements'),
          ),
          const SizedBox(height: 10),
        ],
    ];
  }

  void _openPlayerSection(AppUser player, String section) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DetailPage(
          title: '$section — ${player.fullName}',
          subtitle: 'Managed by admin',
          accent: widget.accent,
          icon: Icons.person,
          viewerRole: UserRole.admin,
          allUsers: widget.allUsers,
          onCreateUser: widget.onCreateUser,
          publicAboutText: widget.publicAboutText,
          publicGallery: widget.publicGallery,
          publicNews: widget.publicNews,
          onUpdatePublicAbout: widget.onUpdatePublicAbout,
          onAddPublicGalleryImage: widget.onAddPublicGalleryImage,
          onRemovePublicGalleryImage: widget.onRemovePublicGalleryImage,
          onAddPublicNews: widget.onAddPublicNews,
          onRemovePublicNews: widget.onRemovePublicNews,
        ),
      ),
    );
  }

  List<Widget> _analyticsView() {
    final totalUsers = widget.allUsers.length;
    final players = widget.allUsers
        .where((u) => u.role == UserRole.player)
        .length;
    final coaches = widget.allUsers
        .where((u) => u.role == UserRole.coach)
        .length;
    final parents = widget.allUsers
        .where((u) => u.role == UserRole.parent)
        .length;
    final month = _attendanceMonths[_analyticsMonthIndex];

    return [
      _PanelCard(
        title: 'Club overview',
        subtitle: 'Live snapshot across every role',
        accent: widget.accent,
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _StatChip(label: 'Total accounts', value: '$totalUsers'),
            _StatChip(label: 'Players', value: '$players'),
            _StatChip(label: 'Coaches', value: '$coaches'),
            _StatChip(label: 'Parents', value: '$parents'),
          ],
        ),
      ),
      const SizedBox(height: 12),
      _MonthHeader(
        title: 'Analytics for: ${month.label}',
        accent: widget.accent,
        onPrevious: _previousAnalyticsMonth,
        onNext: _nextAnalyticsMonth,
      ),
      const SizedBox(height: 12),
      _ChartCard(
        title: 'Team attendance trend',
        subtitle: month.chartSubtitle,
        accent: widget.accent,
        values: month.trendValues,
        labels: month.trendLabels,
      ),
      const SizedBox(height: 12),
      _PanelCard(
        title: 'Attendance summary',
        subtitle: 'Average across the squad for ${month.label}',
        accent: widget.accent,
        child: Column(
          children: [
            _StatusLine(
              label: 'Average attendance',
              value: month.averageAttendance,
            ),
            _StatusLine(label: 'Sessions logged', value: month.totalSessions),
            _StatusLine(label: 'Present (top player)', value: month.present),
            _StatusLine(label: 'Late (top player)', value: month.late),
          ],
        ),
      ),
      const SizedBox(height: 12),
      _PanelCard(
        title: 'Engagement health',
        subtitle: 'Operational readiness this period',
        accent: widget.accent,
        child: Column(
          children: [
            _ProgressRow(
              label: 'Attendance goal',
              progress: 0.9,
              accent: widget.accent,
            ),
            const SizedBox(height: 10),
            _ProgressRow(
              label: 'Content published on schedule',
              progress: _cmsPosts.isEmpty ? 0.2 : 0.86,
              accent: widget.accent,
            ),
            const SizedBox(height: 10),
            _ProgressRow(
              label: 'Group chats active',
              progress: _groups.isEmpty ? 0.1 : 0.78,
              accent: widget.accent,
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _cmsView() {
    return [
      _PanelCard(
        title: 'Publish content',
        subtitle: 'Announcements appear instantly on the public home page',
        accent: widget.accent,
        child: Column(
          children: [
            TextField(
              controller: _cmsTitleController,
              decoration: InputDecoration(
                hintText: 'Post title',
                filled: true,
                fillColor: Theme.of(context).scaffoldBackgroundColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _cmsBodyController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Post content',
                filled: true,
                fillColor: Theme.of(context).scaffoldBackgroundColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _publishCmsPost,
                icon: const Icon(Icons.publish_outlined),
                label: const Text('Publish'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      _PanelCard(
        title: 'Published content',
        subtitle: '${_cmsPosts.length} posts live',
        accent: widget.accent,
        child: _cmsPosts.isEmpty
            ? Text(
                'No content published yet.',
                style: TextStyle(color: Colors.grey.shade500),
              )
            : Column(
                children: [
                  for (var i = 0; i < _cmsPosts.length; i++) ...[
                    _CmsPostCard(
                      post: _cmsPosts[i],
                      accent: widget.accent,
                      onDelete: () => _deleteCmsPost(i),
                    ),
                    if (i != _cmsPosts.length - 1) const SizedBox(height: 10),
                  ],
                ],
              ),
      ),
    ];
  }

  List<Widget> _publicPageEditorView() {
    return [
      _PanelCard(
        title: 'Public page content',
        subtitle: 'Edit what visitors see on the public page',
        accent: widget.accent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _publicAboutController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'About the academy text',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _savePublicAbout,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Save public page text'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      _PanelCard(
        title: 'Gallery manager',
        subtitle: 'Add or remove gallery pictures shown on the public page',
        accent: widget.accent,
        child: Column(
          children: [
            TextField(
              controller: _publicGalleryImageController,
              decoration: InputDecoration(
                labelText: 'Gallery image URL',
                hintText: 'https://.../image.jpg',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _addGalleryImage,
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: const Text('Add picture to gallery'),
              ),
            ),
            const SizedBox(height: 12),
            for (var i = 0; i < widget.publicGallery.length; i++) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.grey.withValues(alpha: 0.18),
                  ),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        widget.publicGallery[i],
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          width: 56,
                          height: 56,
                          color: widget.accent.withValues(alpha: 0.12),
                          child: const Icon(Icons.photo_outlined),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.publicGallery[i],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                    IconButton(
                      onPressed: () => widget.onRemovePublicGalleryImage(i),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
      const SizedBox(height: 12),
      _PanelCard(
        title: 'News manager',
        subtitle: 'Edit public news feed with optional cover picture',
        accent: widget.accent,
        child: Column(
          children: [
            TextField(
              controller: _publicNewsTitleController,
              decoration: InputDecoration(
                labelText: 'News title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _publicNewsBodyController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'News content',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _publicNewsImageController,
              decoration: InputDecoration(
                labelText: 'Optional news image URL',
                hintText: 'https://.../news-cover.jpg',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _publishPublicNews,
                icon: const Icon(Icons.campaign_outlined),
                label: const Text('Publish public news'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            for (var i = 0; i < widget.publicNews.length; i++) ...[
              _NewsCard(
                title: widget.publicNews[i].title,
                date: widget.publicNews[i].date,
                body: widget.publicNews[i].body,
                imageUrl: widget.publicNews[i].imageUrl,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => widget.onRemovePublicNews(i),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Remove'),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
      if (_publicEditError != null) ...[
        const SizedBox(height: 12),
        Text(
          _publicEditError!,
          style: const TextStyle(color: Colors.redAccent),
        ),
      ],
    ];
  }

  List<Widget> _adminUsersView() {
    final previewUrl = _newUserPhotoController.text.trim();
    final filteredUsers = _userRoleFilter == null
        ? widget.allUsers
        : widget.allUsers
              .where((user) => user.role == _userRoleFilter)
              .toList();
    final filterLabel = _userRoleFilter == null
        ? 'All users'
        : _roleLabel(_userRoleFilter!);

    return [
      _PanelCard(
        title: 'Create new user',
        subtitle: 'Add a player, parent, coach, or admin account',
        accent: widget.accent,
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: widget.accent.withValues(alpha: 0.15),
                  backgroundImage: previewUrl.isEmpty
                      ? null
                      : NetworkImage(previewUrl),
                  child: previewUrl.isEmpty
                      ? Icon(Icons.person, color: widget.accent)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _newUserPhotoController,
                    decoration: InputDecoration(
                      labelText: 'Picture URL',
                      hintText: 'https://.../photo.jpg',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newUserNameController,
                    decoration: InputDecoration(
                      labelText: 'Full name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _newUserEmailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newUserPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    obscureText: true,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<UserRole>(
                    initialValue: _newUserRole,
                    decoration: InputDecoration(
                      labelText: 'Role',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: UserRole.player,
                        child: Text('Player'),
                      ),
                      DropdownMenuItem(
                        value: UserRole.parent,
                        child: Text('Parent'),
                      ),
                      DropdownMenuItem(
                        value: UserRole.coach,
                        child: Text('Coach'),
                      ),
                      DropdownMenuItem(
                        value: UserRole.performanceAnalyst,
                        child: Text('Performance Analyst'),
                      ),
                      DropdownMenuItem(
                        value: UserRole.admin,
                        child: Text('Admin'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _newUserRole = value);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newUserPhoneController,
                    decoration: InputDecoration(
                      labelText: 'Phone',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _newUserTeamController,
                    decoration: InputDecoration(
                      labelText: 'Team',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newUserSchoolController,
                    decoration: InputDecoration(
                      labelText: 'School / Institute',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _newUserPositionController,
                    decoration: InputDecoration(
                      labelText: 'Position',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _newUserNotesController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            if (_newUserError != null) ...[
              const SizedBox(height: 12),
              Text(
                _newUserError!,
                style: const TextStyle(color: Colors.redAccent),
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _submitNewUser,
                icon: const Icon(Icons.person_add_alt_1),
                label: const Text('Create user'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      _PanelCard(
        title: 'Registered users',
        subtitle:
            '${filteredUsers.length} accounts shown • Filter: $filterLabel',
        accent: widget.accent,
        child: Column(
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: _userRoleFilter == null,
                  onSelected: (_) => setState(() => _userRoleFilter = null),
                ),
                ChoiceChip(
                  label: const Text('Performance Analyst'),
                  selected: _userRoleFilter == UserRole.performanceAnalyst,
                  onSelected: (_) => setState(
                    () => _userRoleFilter = UserRole.performanceAnalyst,
                  ),
                ),
                ChoiceChip(
                  label: const Text('Players'),
                  selected: _userRoleFilter == UserRole.player,
                  onSelected: (_) =>
                      setState(() => _userRoleFilter = UserRole.player),
                ),
                ChoiceChip(
                  label: const Text('Coaches'),
                  selected: _userRoleFilter == UserRole.coach,
                  onSelected: (_) =>
                      setState(() => _userRoleFilter = UserRole.coach),
                ),
                ChoiceChip(
                  label: const Text('Parents'),
                  selected: _userRoleFilter == UserRole.parent,
                  onSelected: (_) =>
                      setState(() => _userRoleFilter = UserRole.parent),
                ),
                ChoiceChip(
                  label: const Text('Admins'),
                  selected: _userRoleFilter == UserRole.admin,
                  onSelected: (_) =>
                      setState(() => _userRoleFilter = UserRole.admin),
                ),
              ],
            ),
            const SizedBox(height: 12),
            for (final user in filteredUsers) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey.withValues(alpha: 0.18),
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: widget.accent.withValues(alpha: 0.15),
                      backgroundImage: user.photoUrl == null
                          ? null
                          : NetworkImage(user.photoUrl!),
                      child: user.photoUrl == null
                          ? Text(
                              user.fullName.isEmpty ? '?' : user.fullName[0],
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.fullName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_roleLabel(user.role)} • ${user.email}',
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                          if (user.team != null || user.position != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              [
                                user.team,
                                user.position,
                              ].whereType<String>().join(' • '),
                              style: TextStyle(color: Colors.grey.shade500),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
            if (filteredUsers.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'No users match this role filter yet.',
                  style: TextStyle(color: Colors.grey.shade500),
                ),
              ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _playerProfileDetailView() {
    return [
      _ProfileCard(
        name: 'Alicia Tan',
        role: 'Player #12 • Forward',
        team: 'JM Hockey U-16 Boys Team A',
        accent: widget.accent,
        avatarIcon: Icons.sports_hockey,
      ),
      const SizedBox(height: 12),
      _PanelCard(
        title: 'Player snapshot',
        subtitle: 'Profile, squad info, and season overview',
        accent: widget.accent,
        child: Column(
          children: const [
            _StatChip(label: 'Jersey', value: '12'),
            SizedBox(height: 10),
            _StatChip(label: 'Position', value: 'Forward'),
            SizedBox(height: 10),
            _StatChip(label: 'Status', value: 'Active'),
          ],
        ),
      ),
      const SizedBox(height: 12),
      _ChartCard(
        title: 'Season profile trend',
        subtitle: 'Training consistency and growth',
        accent: widget.accent,
        values: const [68, 74, 81, 88, 94],
        labels: const ['W1', 'W2', 'W3', 'W4', 'W5'],
      ),
      const SizedBox(height: 12),
      _PanelCard(
        title: 'Profile details',
        subtitle: 'What the admin and coach see on this player',
        accent: widget.accent,
        child: const Column(
          children: [
            _StatusLine(label: 'ID', value: 'JM-0124'),
            _StatusLine(label: 'Age group', value: 'U-16'),
            _StatusLine(label: 'Preferred side', value: 'Left wing'),
            _StatusLine(label: 'Medical note', value: 'Cleared'),
          ],
        ),
      ),
      const SizedBox(height: 12),
      _BottomReportCard(
        buttonText: 'Open Attendance Record',
        subtitle: 'Go to the full attendance timeline for this player.',
        accent: widget.accent,
        onPressed: () => _openFeatureSheet(
          title: 'Attendance Record',
          subtitle: 'Full attendance timeline for this player',
          children: const [
            _StatusLine(label: 'Current month', value: '18 / 21'),
            _StatusLine(label: 'Last session', value: 'Present'),
            _StatusLine(label: 'Trend', value: 'Strong attendance'),
            _StatusLine(label: 'Alert', value: '1 late arrival'),
          ],
        ),
      ),
    ];
  }

  List<Widget> _playerPerformanceView() {
    return [
      _PanelCard(
        title: 'Performance summary',
        subtitle: 'Training load, speed, and technical work',
        accent: widget.accent,
        child: Column(
          children: [
            _StatChip(
              label: 'Speed',
              value: '86%',
              onTap: () => _openFeatureSheet(
                title: 'Speed',
                subtitle: 'Acceleration and pace',
                children: const [
                  _StatusLine(label: 'Current', value: '86%'),
                  _StatusLine(label: 'Trend', value: 'Improving'),
                  _StatusLine(
                    label: 'Coach note',
                    value: 'Explosive first step',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            _StatChip(
              label: 'Control',
              value: '91%',
              onTap: () => _openFeatureSheet(
                title: 'Control',
                subtitle: 'Stick handling and retention',
                children: const [
                  _StatusLine(label: 'Current', value: '91%'),
                  _StatusLine(label: 'Trend', value: 'Stable'),
                  _StatusLine(
                    label: 'Coach note',
                    value: 'Clean under pressure',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            _StatChip(
              label: 'Stamina',
              value: '88%',
              onTap: () => _openFeatureSheet(
                title: 'Stamina',
                subtitle: 'Energy and recovery',
                children: const [
                  _StatusLine(label: 'Current', value: '88%'),
                  _StatusLine(label: 'Trend', value: 'Strong'),
                  _StatusLine(
                    label: 'Coach note',
                    value: 'High late-session output',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      _ChartCard(
        title: 'Training performance',
        subtitle: 'Last 5 weeks',
        accent: widget.accent,
        values: const [62, 70, 78, 85, 93],
        labels: const ['W1', 'W2', 'W3', 'W4', 'W5'],
      ),
      const SizedBox(height: 12),
      _PanelCard(
        title: 'Coach notes',
        subtitle: 'What the staff is tracking',
        accent: widget.accent,
        child: const Column(
          children: [
            _StatusLine(label: 'Puck handling', value: 'Improving'),
            _StatusLine(label: 'Decision making', value: 'Strong'),
            _StatusLine(label: 'Defensive work', value: 'Needs focus'),
            _StatusLine(label: 'Next goal', value: 'More shots on net'),
          ],
        ),
      ),
      const SizedBox(height: 12),
      _BottomReportCard(
        buttonText: 'View Full Performance Report',
        subtitle: 'Detailed player development metrics and assessments.',
        accent: widget.accent,
        onPressed: () => _openFeatureSheet(
          title: 'Full Performance Report',
          subtitle: 'Detailed player development metrics and assessments',
          children: const [
            _StatusLine(label: 'Speed', value: '86%'),
            _StatusLine(label: 'Control', value: '91%'),
            _StatusLine(label: 'Stamina', value: '88%'),
            _StatusLine(label: 'Coach rating', value: '8.7 / 10'),
            _StatusLine(label: 'Next goal', value: 'More shots on net'),
          ],
        ),
      ),
    ];
  }

  List<Widget> _playerAchievementsView() {
    return [
      _PanelCard(
        title: 'Achievements summary',
        subtitle: 'Badges, milestones, and standout moments',
        accent: widget.accent,
        child: Column(
          children: [
            _StatChip(
              label: 'Badges',
              value: '6',
              onTap: () => _openFeatureSheet(
                title: 'Badges',
                subtitle: 'Earned badge collection',
                children: const [
                  _StatusLine(label: 'Total', value: '6'),
                  _StatusLine(label: 'Latest', value: 'Consistency Badge'),
                  _StatusLine(label: 'Next', value: 'Team Player'),
                ],
              ),
            ),
            const SizedBox(height: 10),
            _StatChip(
              label: 'MVPs',
              value: '3',
              onTap: () => _openFeatureSheet(
                title: 'MVPs',
                subtitle: 'Most valuable player moments',
                children: const [
                  _StatusLine(label: 'MVP awards', value: '3'),
                  _StatusLine(label: 'Latest', value: 'Last month'),
                  _StatusLine(label: 'Trend', value: 'Improving'),
                ],
              ),
            ),
            const SizedBox(height: 10),
            _StatChip(
              label: 'Milestones',
              value: '12',
              onTap: () => _openFeatureSheet(
                title: 'Milestones',
                subtitle: 'Season checkpoints and progress markers',
                children: const [
                  _StatusLine(label: 'Completed', value: '12'),
                  _StatusLine(label: 'Latest', value: '20 training sessions'),
                  _StatusLine(label: 'Next', value: 'Tournament debut'),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      _ChartCard(
        title: 'Achievement growth',
        subtitle: 'Progress over the season',
        accent: widget.accent,
        values: const [52, 64, 72, 84, 96],
        labels: const ['W1', 'W2', 'W3', 'W4', 'W5'],
      ),
      const SizedBox(height: 12),
      _PanelCard(
        title: 'Unlocked achievements',
        subtitle: 'What this player has earned so far',
        accent: widget.accent,
        child: Column(
          children: const [
            _AchievementTile(
              title: 'First Goal',
              subtitle: 'Scored the first goal of the season',
              icon: Icons.sports_soccer,
              color: Color(0xFFFFB300),
            ),
            SizedBox(height: 10),
            _AchievementTile(
              title: 'Consistency Badge',
              subtitle: 'Reached 5 straight sessions on time',
              icon: Icons.task_alt,
              color: Color(0xFF1E88E5),
            ),
            SizedBox(height: 10),
            _AchievementTile(
              title: 'Team Player',
              subtitle: 'Recognized for support and communication',
              icon: Icons.groups,
              color: Color(0xFF1E88E5),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      _BottomReportCard(
        buttonText: 'View All Rewards',
        subtitle:
            'Awards and achievements can be expanded with live data later.',
        accent: widget.accent,
        onPressed: () => _openFeatureSheet(
          title: 'All Rewards',
          subtitle: 'Season awards and progress markers',
          children: const [
            _StatusLine(label: 'Unlocked', value: '8'),
            _StatusLine(label: 'Available', value: '2'),
            _StatusLine(label: 'Next reward', value: 'MVP badge'),
            _StatusLine(label: 'Latest award', value: 'Consistency Badge'),
          ],
        ),
      ),
    ];
  }

  List<Widget> _adminAttendanceView() {
    final month = _attendanceMonths[_attendanceMonthIndex];
    final players = month.adminSummaries;

    return [
      _MonthHeader(
        title: 'Month: ${month.label}',
        accent: widget.accent,
        onPrevious: _previousAttendanceMonth,
        onNext: _nextAttendanceMonth,
      ),
      const SizedBox(height: 12),
      _MonthSelector(
        months: _attendanceMonths,
        selectedIndex: _attendanceMonthIndex,
        accent: widget.accent,
        onChanged: _selectAttendanceMonth,
      ),
      const SizedBox(height: 12),
      _PanelCard(
        title: 'Attendance summary for admin',
        subtitle: 'Tap a player to open their full attendance page',
        accent: widget.accent,
        child: Column(
          children: [
            _StatChip(label: 'Players', value: '${players.length}'),
            const SizedBox(height: 10),
            _StatChip(label: 'Average', value: month.averageAttendance),
          ],
        ),
      ),
      const SizedBox(height: 12),
      _ChartCard(
        title: 'Team attendance summary',
        subtitle: 'Overall attendance for the squad',
        accent: widget.accent,
        values: month.trendValues,
        labels: month.trendLabels,
      ),
      const SizedBox(height: 12),
      for (final player in players) ...[
        _PlayerAttendanceSummaryCard(
          player: player,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AttendanceDetailPage(
                  playerName: player.name,
                  playerRole: player.role,
                  accent: player.accent,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
      ],
    ];
  }

  List<Widget> _coachFeatureView(String lower) {
    if (lower.contains('attendance')) {
      final today = DateTime.now().toIso8601String().split('T').first;
      final attendees = _globalAttendanceRecords[today] ?? [];
      return [
        _PanelCard(
          title: 'Attendance (QR / 3-digit code)',
          subtitle: 'Generate a code or show QR for players to mark attendance',
          accent: widget.accent,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _globalAttendanceCode == null
                          ? 'No active code'
                          : 'Code: $_globalAttendanceCode (expires ${_globalAttendanceExpiry?.toLocal().hour}:${_globalAttendanceExpiry?.toLocal().minute.toString().padLeft(2, '0')})',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      generateAttendanceCodeGlobal();
                      setState(() {});
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.accent,
                    ),
                    child: const Text('Generate'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Players marked present today: ${attendees.length}',
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) {
                          final todayKey = DateTime.now()
                              .toIso8601String()
                              .split('T')
                              .first;
                          final todayAttendees =
                              _globalAttendanceRecords[todayKey] ?? [];
                          return SafeArea(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).scaffoldBackgroundColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.all(12),
                                height:
                                    MediaQuery.of(context).size.height * 0.75,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Attendance QR / Code',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: widget.accent,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Center(
                                      child: Column(
                                        children: [
                                          Container(
                                            width: 220,
                                            height: 220,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              color: Colors.grey.shade200,
                                            ),
                                            child: Center(
                                              child: Text(
                                                _globalAttendanceCode ??
                                                    'No code',
                                                style: const TextStyle(
                                                  fontSize: 28,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            _globalAttendanceExpiry == null
                                                ? ''
                                                : 'Expires at ${_globalAttendanceExpiry!.toLocal()}',
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    const Divider(),
                                    const SizedBox(height: 8),
                                    Expanded(
                                      child: ListView(
                                        children: [
                                          for (final player
                                              in widget.allUsers.where(
                                                (u) =>
                                                    u.role == UserRole.player,
                                              ))
                                            CheckboxListTile(
                                              value:
                                                  (_globalAttendanceRecords[todayKey] ??
                                                          [])
                                                      .contains(player.email),
                                              title: Text(player.fullName),
                                              subtitle: Text(player.email),
                                              onChanged: (v) {
                                                final key = todayKey;
                                                _globalAttendanceRecords
                                                    .putIfAbsent(key, () => []);
                                                if (v == true) {
                                                  if (!_globalAttendanceRecords[key]!
                                                      .contains(player.email)) {
                                                    _globalAttendanceRecords[key]!
                                                        .add(player.email);
                                                  }
                                                } else {
                                                  _globalAttendanceRecords[key]!
                                                      .remove(player.email);
                                                }
                                                setState(() {});
                                              },
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.accent,
                    ),
                    child: const Text('Show QR / Manage'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
      ];
    }
    if (lower.contains('session planning')) {
      return [
        _PanelCard(
          title: 'Session planning',
          subtitle: 'Build and track the weekly training plan',
          accent: widget.accent,
          child: const Column(
            children: [
              _StatusLine(label: 'This week sessions', value: '5'),
              _StatusLine(label: 'Focus block', value: 'Transition play'),
              _StatusLine(label: 'Match prep day', value: 'Wednesday'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _ChartCard(
          title: 'Session load balance',
          subtitle: 'Intensity distribution this week',
          accent: widget.accent,
          values: const [55, 72, 86, 64, 78],
          labels: const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
        ),
      ];
    }

    if (lower.contains('session templates')) {
      return [
        _PanelCard(
          title: 'Session templates',
          subtitle: 'Reusable structures for coach workflows',
          accent: widget.accent,
          child: const Column(
            children: [
              _StatusLine(label: 'Recovery template', value: '45 min'),
              _StatusLine(label: 'Technical template', value: '75 min'),
              _StatusLine(label: 'Match-prep template', value: '60 min'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _BottomReportCard(
          buttonText: 'Open Template Library',
          subtitle: 'Choose a template and apply it to this week.',
          accent: widget.accent,
          onPressed: () => _openFeatureSheet(
            title: 'Template Library',
            subtitle: 'Session templates ready for reuse',
            children: const [
              _StatusLine(label: 'Saved templates', value: '12'),
              _StatusLine(label: 'Most used', value: 'Technical template'),
              _StatusLine(label: 'Updated', value: 'Today'),
            ],
          ),
        ),
      ];
    }

    if (lower.contains('drill library')) {
      return [
        _PanelCard(
          title: 'Drill library',
          subtitle: 'Filter drills by objective and age group',
          accent: widget.accent,
          child: const Column(
            children: [
              _StatusLine(label: 'Total drills', value: '84'),
              _StatusLine(label: 'Technical drills', value: '31'),
              _StatusLine(label: 'Small-sided drills', value: '18'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _ChartCard(
          title: 'Drill usage',
          subtitle: 'Most used categories this month',
          accent: widget.accent,
          values: const [68, 74, 59, 83, 71],
          labels: const ['Passing', 'Finishing', 'Pressing', 'Shape', 'Speed'],
        ),
      ];
    }

    if (lower.contains('tactical board')) {
      return [
        _PanelCard(
          title: 'Tactical board',
          subtitle: 'Plan shape, transitions, and set pieces',
          accent: widget.accent,
          child: const Column(
            children: [
              _StatusLine(label: 'Primary shape', value: '2-3-1 press'),
              _StatusLine(label: 'In-possession plan', value: 'Wide overloads'),
              _StatusLine(label: 'Set-piece package', value: 'Version B'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _BottomReportCard(
          buttonText: 'Open Tactical Canvas',
          subtitle: 'Adjust player roles and movement paths.',
          accent: widget.accent,
          onPressed: () => _openFeatureSheet(
            title: 'Tactical Canvas',
            subtitle: 'Tactical board actions',
            children: const [
              _StatusLine(label: 'Saved boards', value: '7'),
              _StatusLine(label: 'Last edited', value: 'Today 4:10 PM'),
              _StatusLine(label: 'Shared with squad', value: 'Yes'),
            ],
          ),
        ),
      ];
    }

    if (lower.contains('player grading')) {
      return [
        _PanelCard(
          title: 'Player grading',
          subtitle: 'Rate technical, tactical, and behavior metrics',
          accent: widget.accent,
          child: const Column(
            children: [
              _StatusLine(label: 'Players graded this week', value: '19 / 22'),
              _StatusLine(label: 'Average technical score', value: '8.1 / 10'),
              _StatusLine(label: 'Average tactical score', value: '7.6 / 10'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _ChartCard(
          title: 'Grading trend',
          subtitle: 'Team development over 5 reviews',
          accent: widget.accent,
          values: const [64, 69, 73, 78, 82],
          labels: const ['R1', 'R2', 'R3', 'R4', 'R5'],
        ),
      ];
    }

    if (lower.contains('match analysis upload')) {
      return [
        _PanelCard(
          title: 'Match analysis upload',
          subtitle: 'Upload clips, tag events, and run tactical reviews',
          accent: widget.accent,
          child: const Column(
            children: [
              _StatusLine(label: 'Latest upload', value: 'U16 vs Tigers'),
              _StatusLine(label: 'Clips tagged', value: '26'),
              _StatusLine(label: 'Review status', value: 'Ready for meeting'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _PanelCard(
          title: 'Match tagging',
          subtitle:
              'Tag key actions for searchable and filterable match events',
          accent: widget.accent,
          child: const Column(
            children: [
              _StatusLine(label: 'Goals', value: 'Enabled'),
              _StatusLine(label: 'Assists', value: 'Enabled'),
              _StatusLine(label: 'Turnovers', value: 'Enabled'),
              _StatusLine(label: 'Interceptions', value: 'Enabled'),
              _StatusLine(label: 'Circle entries', value: 'Enabled'),
              _StatusLine(label: 'Shots', value: 'Enabled'),
              _StatusLine(label: 'Penalty corners', value: 'Enabled'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _PanelCard(
          title: 'Analytics',
          subtitle: 'Visual and tactical analytics for coach decision-making',
          accent: widget.accent,
          child: const Column(
            children: [
              _StatusLine(label: 'Heatmaps', value: 'Available'),
              _StatusLine(label: 'Passing statistics', value: 'Available'),
              _StatusLine(label: 'Possession zones', value: 'Available'),
              _StatusLine(label: 'Team shape', value: 'Available'),
              _StatusLine(label: 'Performance trends', value: 'Available'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _ChartCard(
          title: 'Performance trends',
          subtitle: 'Recent trend snapshot from tagged match data',
          accent: widget.accent,
          values: const [61, 68, 74, 79, 86],
          labels: const ['Heatmap', 'Passing', 'Possession', 'Shape', 'Trend'],
        ),
        const SizedBox(height: 12),
        _PanelCard(
          title: 'Video system',
          subtitle: 'Replay, clipping, and tactical review workflow',
          accent: widget.accent,
          child: const Column(
            children: [
              _StatusLine(label: 'Video replay', value: 'Ready'),
              _StatusLine(label: 'Highlight clipping', value: 'Ready'),
              _StatusLine(label: 'Tactical breakdowns', value: 'Ready'),
              _StatusLine(label: 'AI tagging later', value: 'Planned'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _BottomReportCard(
          buttonText: 'Upload New Analysis',
          subtitle: 'Attach video clips and summary notes for staff.',
          accent: widget.accent,
          onPressed: () => _openFeatureSheet(
            title: 'Upload Queue',
            subtitle: 'Match analysis uploads and video workflow',
            children: const [
              _StatusLine(label: 'Pending uploads', value: '2'),
              _StatusLine(label: 'Storage used', value: '3.2 GB'),
              _StatusLine(label: 'Video replay', value: 'Enabled'),
              _StatusLine(label: 'Highlight clipping', value: 'Enabled'),
              _StatusLine(label: 'Tactical breakdowns', value: 'Enabled'),
              _StatusLine(label: 'AI tagging later', value: 'Planned'),
            ],
          ),
        ),
      ];
    }

    if (lower.contains('injury reports')) {
      return [
        _PanelCard(
          title: 'Injury reports',
          subtitle: 'Medical incidents and return-to-play tracking',
          accent: widget.accent,
          child: const Column(
            children: [
              _StatusLine(label: 'Open injury cases', value: '3'),
              _StatusLine(label: 'In rehab', value: '2'),
              _StatusLine(label: 'Ready to return', value: '1'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _ChartCard(
          title: 'Injury timeline',
          subtitle: 'Case trend across recent weeks',
          accent: widget.accent,
          values: const [4, 3, 3, 2, 3],
          labels: const ['W1', 'W2', 'W3', 'W4', 'W5'],
        ),
      ];
    }

    if (lower.contains('team selection tools')) {
      return [
        _PanelCard(
          title: 'Team selection tools',
          subtitle: 'Build lineups and assign roles for matches',
          accent: widget.accent,
          child: const Column(
            children: [
              _StatusLine(label: 'Squad candidates', value: '24'),
              _StatusLine(label: 'Matchday slots', value: '16'),
              _StatusLine(label: 'Selection status', value: 'Draft ready'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _BottomReportCard(
          buttonText: 'Open Selection Builder',
          subtitle: 'Finalize lineup and bench roles for match day.',
          accent: widget.accent,
          onPressed: () => _openFeatureSheet(
            title: 'Selection Builder',
            subtitle: 'Team selection controls',
            children: const [
              _StatusLine(label: 'Starting lineup', value: '11 selected'),
              _StatusLine(label: 'Bench', value: '5 selected'),
              _StatusLine(label: 'Captain assigned', value: 'Yes'),
            ],
          ),
        ),
      ];
    }

    return _defaultView();
  }

  List<Widget> _performanceAnalystView(String lower) {
    if (lower.contains('match tagging') ||
        lower.contains('performance match tagging')) {
      return [
        _PanelCard(
          title: 'Match Tagging',
          subtitle: 'Tag all key match actions for analysis',
          accent: widget.accent,
          child: const Column(
            children: [
              _StatusLine(label: 'Goals', value: 'Enabled'),
              _StatusLine(label: 'Assists', value: 'Enabled'),
              _StatusLine(label: 'Turnovers', value: 'Enabled'),
              _StatusLine(label: 'Interceptions', value: 'Enabled'),
              _StatusLine(label: 'Circle entries', value: 'Enabled'),
              _StatusLine(label: 'Shots', value: 'Enabled'),
              _StatusLine(label: 'Penalty corners', value: 'Enabled'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _ChartCard(
          title: 'Tagging load',
          subtitle: 'Tagged events across the last five matches',
          accent: widget.accent,
          values: const [18, 24, 21, 29, 26],
          labels: const ['M1', 'M2', 'M3', 'M4', 'M5'],
        ),
      ];
    }

    if (lower.contains('performance analytics') ||
        lower.contains('analytics')) {
      return [
        _PanelCard(
          title: 'Analytics',
          subtitle: 'Core tactical and performance analytics',
          accent: widget.accent,
          child: const Column(
            children: [
              _StatusLine(label: 'Heatmaps', value: 'Available'),
              _StatusLine(label: 'Passing statistics', value: 'Available'),
              _StatusLine(label: 'Possession zones', value: 'Available'),
              _StatusLine(label: 'Team shape', value: 'Available'),
              _StatusLine(label: 'Performance trends', value: 'Available'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _ChartCard(
          title: 'Performance trends',
          subtitle: 'Analyst dashboard trend summary',
          accent: widget.accent,
          values: const [63, 69, 75, 81, 88],
          labels: const ['Heatmap', 'Passing', 'Possession', 'Shape', 'Trend'],
        ),
      ];
    }

    if (lower.contains('performance video system') ||
        lower.contains('video system')) {
      return [
        _PanelCard(
          title: 'Video System',
          subtitle: 'Replay and tactical video tooling',
          accent: widget.accent,
          child: const Column(
            children: [
              _StatusLine(label: 'Video replay', value: 'Ready'),
              _StatusLine(label: 'Highlight clipping', value: 'Ready'),
              _StatusLine(label: 'Tactical breakdowns', value: 'Ready'),
              _StatusLine(label: 'AI tagging later', value: 'Planned'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        for (final v in _publicMatchVideos) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.12)),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    v.thumbnail,
                    width: 120,
                    height: 68,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        v.title,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        v.date,
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (_) => Container(
                        padding: const EdgeInsets.all(16),
                        height: 320,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              v.title,
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: widget.accent,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Expanded(
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        v.thumbnail,
                                        width: 260,
                                        height: 140,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Playing video (placeholder)',
                                            ),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: widget.accent,
                                      ),
                                      child: const Text('Play'),
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
                  child: const Text('Open'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 12),
        _BottomReportCard(
          buttonText: 'Open Video Workspace',
          subtitle: 'Replay clips and build tactical breakdown packages.',
          accent: widget.accent,
          onPressed: () => _openFeatureSheet(
            title: 'Video Workspace',
            subtitle: 'Performance analyst video tools',
            children: const [
              _StatusLine(label: 'Replay queue', value: '4 clips'),
              _StatusLine(label: 'Highlights clipped', value: '12'),
              _StatusLine(label: 'Tactical packages', value: '3 prepared'),
              _StatusLine(label: 'AI tagging later', value: 'Planned'),
            ],
          ),
        ),
      ];
    }

    return _defaultView();
  }

  List<Widget> _operationsView() {
    const week = [
      _OpsDay(
        label: 'Mon',
        title: 'Recovery & review',
        detail: 'Video notes and rehab check-in',
        color: Color(0xFF1E88E5),
      ),
      _OpsDay(
        label: 'Tue',
        title: 'Field training',
        detail: 'Technical drills and unit work',
        color: Color(0xFFFFB300),
      ),
      _OpsDay(
        label: 'Wed',
        title: 'Match prep',
        detail: 'Tactics and set pieces',
        color: Color(0xFF1E88E5),
      ),
      _OpsDay(
        label: 'Thu',
        title: 'Light session',
        detail: 'Agility and finishing',
        color: Color(0xFF0F4C81),
      ),
      _OpsDay(
        label: 'Fri',
        title: 'Game day',
        detail: 'Arrival, kit, and lineup',
        color: Color(0xFFD32F2F),
      ),
    ];

    const tasks = [
      _OpsTask(
        title: 'Confirm bus pickup',
        status: 'Due today',
        icon: Icons.directions_bus,
      ),
      _OpsTask(
        title: 'Check cones and bibs',
        status: 'Ready',
        icon: Icons.inventory_2_outlined,
      ),
      _OpsTask(
        title: 'Send game reminders',
        status: 'Pending',
        icon: Icons.notifications_active,
      ),
      _OpsTask(
        title: 'Approve venue booking',
        status: 'Booked',
        icon: Icons.stadium,
      ),
    ];

    return [
      _PanelCard(
        title: 'Operations control tower',
        subtitle: 'Weekly planning and readiness',
        accent: widget.accent,
        child: Row(
          children: const [
            Expanded(
              child: _StatChip(label: 'Sessions', value: '18'),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _StatChip(label: 'Venue', value: 'Ready'),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _StatChip(label: 'Tasks', value: '4 Open'),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      _PanelCard(
        title: 'This week',
        subtitle: 'Plan by day and keep the squad aligned',
        accent: widget.accent,
        child: Column(
          children: [
            for (final day in week) ...[
              _DayCard(day: day),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
      const SizedBox(height: 12),
      _PanelCard(
        title: 'Readiness checklist',
        subtitle: 'Track the items that keep training and matches on time',
        accent: widget.accent,
        child: Column(
          children: [
            _ProgressRow(
              label: 'Venue readiness',
              progress: 0.94,
              accent: widget.accent,
            ),
            const SizedBox(height: 10),
            _ProgressRow(
              label: 'Session planning',
              progress: 0.88,
              accent: widget.accent,
            ),
            const SizedBox(height: 14),
            for (final task in tasks) ...[
              _TaskCard(task: task, accent: widget.accent),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
      const SizedBox(height: 12),
      _PanelCard(
        title: 'Next event',
        subtitle: 'Game day operations summary',
        accent: widget.accent,
        child: const Column(
          children: [
            _StatusLine(label: 'Arrival window', value: '4:30 PM - 5:00 PM'),
            _StatusLine(label: 'Kit check', value: 'Completed'),
            _StatusLine(label: 'Referee booking', value: 'Confirmed'),
          ],
        ),
      ),
    ];
  }

  List<Widget> _ecommerceView() {
    return [
      _PanelCard(
        title: 'JM Merchandise',
        subtitle: 'Official academy gear and match essentials',
        accent: widget.accent,
        child: const Column(
          children: [
            _StatusLine(label: 'Apparel', value: 'Available'),
            _StatusLine(label: 'Stick', value: 'Available'),
            _StatusLine(label: 'Shin guards', value: 'Available'),
            _StatusLine(label: 'Training jerseys', value: 'Available'),
            _StatusLine(label: 'Tournament jerseys', value: 'Available'),
          ],
        ),
      ),
      const SizedBox(height: 12),
      _PanelCard(
        title: 'Partner Merchandise',
        subtitle: 'Trusted external partners integrated into the store',
        accent: widget.accent,
        child: const Column(
          children: [
            _StatusLine(label: 'OBO Hockey', value: 'www.obohockey.com'),
            _StatusLine(label: 'Lila Sports', value: 'lilasports.com'),
            _StatusLine(label: 'KuKerja', value: 'kukerja.my'),
          ],
        ),
      ),
      const SizedBox(height: 12),
      _PanelCard(
        title: 'Store Features',
        subtitle: 'Commerce features active in the module',
        accent: widget.accent,
        child: const Column(
          children: [
            _StatusLine(label: 'Pictures', value: 'Enabled'),
            _StatusLine(label: 'Size guides', value: 'Enabled'),
            _StatusLine(label: 'Stock management', value: 'Enabled'),
            _StatusLine(label: 'Payment gateway', value: 'Enabled'),
            _StatusLine(label: 'Delivery tracking', value: 'Enabled'),
          ],
        ),
      ),
      const SizedBox(height: 12),
      _ChartCard(
        title: 'Stock overview',
        subtitle: 'Availability trend by product category',
        accent: widget.accent,
        values: const [82, 76, 68, 71, 79],
        labels: const ['Apparel', 'Stick', 'Shin', 'Training', 'Tournament'],
      ),
      const SizedBox(height: 12),
      _BottomReportCard(
        buttonText: 'Open Storefront',
        subtitle: 'Browse products, select size, pay, and track delivery.',
        accent: widget.accent,
        onPressed: () => _openFeatureSheet(
          title: 'Storefront',
          subtitle: 'E-commerce flow status',
          children: const [
            _StatusLine(label: 'Catalog pictures', value: 'Live'),
            _StatusLine(label: 'Size guides', value: 'S-XXL mapped'),
            _StatusLine(label: 'Payment gateway', value: 'Connected'),
            _StatusLine(label: 'Delivery tracking', value: 'Realtime updates'),
          ],
        ),
      ),
    ];
  }

  List<Widget> _communicationView() {
    final group = _groups[_selectedGroup];
    return [
      _PanelCard(
        title: 'Communication hub',
        subtitle: 'Telegram-style group control',
        accent: widget.accent,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                _StatChip(label: 'Groups', value: '2'),
                _StatChip(label: 'Typing access', value: 'Managed'),
                _StatChip(label: 'Alerts', value: '22'),
              ],
            ),
            const SizedBox(height: 14),
            _ChartCard(
              title: 'Message delivery',
              subtitle: 'Last 5 days',
              accent: widget.accent,
              values: const [72, 81, 88, 93, 96],
              labels: const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      _PanelCard(
        title: 'Group communication',
        subtitle: group.name,
        accent: widget.accent,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newGroupNameController,
                    decoration: InputDecoration(
                      hintText: 'New group name',
                      filled: true,
                      fillColor: Theme.of(context).scaffoldBackgroundColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _createGroup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.accent,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Create'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i = 0; i < _groups.length; i++)
                  ChoiceChip(
                    label: Text(_groups[i].name),
                    selected: i == _selectedGroup,
                    onSelected: (_) => setState(() => _selectedGroup = i),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newMemberNameController,
                    decoration: InputDecoration(
                      hintText: 'Add member to ${group.name}',
                      filled: true,
                      fillColor: Theme.of(context).scaffoldBackgroundColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _addMemberToGroup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD54F),
                    foregroundColor: const Color(0xFF0F4C81),
                  ),
                  child: const Text('Add member'),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _groupMessageController,
                    decoration: InputDecoration(
                      hintText: 'Write a message to ${group.name}',
                      filled: true,
                      fillColor: Theme.of(context).scaffoldBackgroundColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _sendGroupMessage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.accent,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Send'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            for (var index = 0; index < group.members.length; index++)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    CircleAvatar(child: Text(group.members[index][0])),
                    const SizedBox(width: 10),
                    Expanded(child: Text(group.members[index])),
                    TextButton.icon(
                      onPressed: () => _toggleMemberTyping(index),
                      icon: Icon(
                        group.canType[index] ? Icons.edit : Icons.lock,
                        size: 18,
                        color: group.canType[index]
                            ? widget.accent
                            : Colors.grey.shade500,
                      ),
                      label: Text(
                        group.canType[index] ? 'Typing on' : 'Read only',
                        style: TextStyle(
                          color: group.canType[index]
                              ? widget.accent
                              : Colors.grey.shade500,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _securityView(Color accent) {
    final roles = const [
      (label: 'Admin', role: UserRole.admin),
      (label: 'Coach', role: UserRole.coach),
      (label: 'Player', role: UserRole.player),
      (label: 'Parent', role: UserRole.parent),
      (label: 'Performance Analyst', role: UserRole.performanceAnalyst),
    ];

    return [
      _PanelCard(
        title: 'Security panel',
        subtitle: 'Permissions, access, and audit controls',
        accent: accent,
        child: Column(
          children: [
            _ProgressRow(
              label: 'Access review',
              progress: 0.79,
              accent: accent,
            ),
            const SizedBox(height: 10),
            _ProgressRow(
              label: 'Audit completion',
              progress: 0.85,
              accent: accent,
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                _StatChip(label: 'Recent alerts', value: '2'),
                _StatChip(label: '2FA', value: 'On'),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      _PanelCard(
        title: 'Role access matrix',
        subtitle: 'Admin always retains full access. Toggle other roles here.',
        accent: accent,
        child: Column(
          children: [
            for (final row in roles) ...[
              _SecurityRow(
                role: row.label,
                canType: row.role == UserRole.admin
                    ? true
                    : (_typePermissions[row.role] ?? false),
                canCreate: row.role == UserRole.admin
                    ? true
                    : (_createPermissions[row.role] ?? false),
                accent: accent,
                locked: row.role == UserRole.admin,
                onToggleType: () => _togglePermission(row.role, canType: true),
                onToggleCreate: () =>
                    _togglePermission(row.role, canType: false),
              ),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
      const SizedBox(height: 12),
      _PanelCard(
        title: 'Recent security activity',
        subtitle: 'Latest account and access events',
        accent: accent,
        child: Column(
          children: const [
            _ActivityLine(
              title: 'Admin login verified',
              subtitle: '2FA completed successfully',
            ),
            _ActivityLine(
              title: 'New group created',
              subtitle: 'Elite Squad group was added with typing rules',
            ),
            _ActivityLine(
              title: 'Muted typing rights',
              subtitle: 'One player was set to read-only access',
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _defaultView() {
    return const [
      _PanelCard(
        title: 'Overview',
        subtitle: 'This section is ready for future content and backend data.',
        accent: Color(0xFF1E88E5),
        child: Text('Connect this screen to live data or API content.'),
      ),
    ];
  }

  List<Widget> _adminPanelView() {
    // Local state helpers inside DetailPage state
    _mockPayments ??= [
      {
        'id': 'TX1001',
        'user': 'alice@example.com',
        'amount': '120.00',
        'status': 'Paid',
      },
      {
        'id': 'TX1002',
        'user': 'bob@example.com',
        'amount': '85.00',
        'status': 'Pending',
      },
    ];
    _tournaments ??= [
      {'name': 'Summer Cup', 'date': '2026-08-20'},
    ];
    _sponsorBanners ??= List<String>.from(widget.publicGallery);

    return [
      _PanelCard(
        title: 'Admin — User Management',
        subtitle: 'Create, edit, and remove users',
        accent: widget.accent,
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _openFeatureSheet(
                  title: 'Create new user',
                  subtitle: 'Add a player, parent, coach, or admin account',
                  children: _adminUserCreateSheet(),
                ),
                icon: const Icon(Icons.person_add_alt_1),
                label: const Text('Create user'),
                style: ElevatedButton.styleFrom(backgroundColor: widget.accent),
              ),
            ),
            const SizedBox(height: 12),
            for (var i = 0; i < widget.allUsers.length; i++) ...[
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: widget.accent.withValues(alpha: 0.12),
                  child: Text(
                    widget.allUsers[i].fullName.isEmpty
                        ? '?'
                        : widget.allUsers[i].fullName[0],
                  ),
                ),
                title: Text(widget.allUsers[i].fullName),
                subtitle: Text(widget.allUsers[i].email),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButton<UserRole>(
                      value: widget.allUsers[i].role,
                      items: [
                        DropdownMenuItem(
                          value: UserRole.player,
                          child: Text('Player'),
                        ),
                        DropdownMenuItem(
                          value: UserRole.coach,
                          child: Text('Coach'),
                        ),
                        DropdownMenuItem(
                          value: UserRole.parent,
                          child: Text('Parent'),
                        ),
                        DropdownMenuItem(
                          value: UserRole.performanceAnalyst,
                          child: Text('Analyst'),
                        ),
                        DropdownMenuItem(
                          value: UserRole.admin,
                          child: Text('Admin'),
                        ),
                      ],
                      onChanged: (newRole) {
                        if (newRole == null) return;
                        widget.allUsers[i] = AppUser(
                          email: widget.allUsers[i].email,
                          password: widget.allUsers[i].password,
                          fullName: widget.allUsers[i].fullName,
                          role: newRole,
                          photoUrl: widget.allUsers[i].photoUrl,
                          phone: widget.allUsers[i].phone,
                          team: widget.allUsers[i].team,
                          school: widget.allUsers[i].school,
                          position: widget.allUsers[i].position,
                          notes: widget.allUsers[i].notes,
                        );
                        setState(() {});
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () {
                        widget.allUsers.removeAt(i);
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      const SizedBox(height: 12),
      _PanelCard(
        title: 'Payment monitoring',
        subtitle: 'Recent transactions and totals',
        accent: widget.accent,
        child: Column(
          children: [
            for (final p in _mockPayments!)
              ListTile(
                title: Text('${p['id']} • ${p['user']}'),
                subtitle: Text('\$${p['amount']} • ${p['status']}'),
                trailing: TextButton(
                  onPressed: () {
                    p['status'] = p['status'] == 'Paid' ? 'Refunded' : 'Paid';
                    setState(() {});
                  },
                  child: const Text('Toggle'),
                ),
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Total revenue: '),
                const SizedBox(width: 8),
                Text(
                  '\$${_mockPayments!.fold<double>(0, (s, e) => s + double.parse(e['amount']!)).toStringAsFixed(2)}',
                ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      _PanelCard(
        title: 'Attendance overview',
        subtitle: 'Quick attendance stats',
        accent: widget.accent,
        child: Column(
          children: [
            for (final entry in _globalAttendanceRecords.entries.take(10))
              ListTile(
                title: Text(entry.key),
                subtitle: Text('${entry.value.length} present'),
              ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      _PanelCard(
        title: 'Push notifications',
        subtitle: 'Send a broadcast to app users',
        accent: widget.accent,
        child: Column(
          children: [
            TextField(
              controller: _publicNewsTitleController,
              decoration: const InputDecoration(
                labelText: 'Notification message',
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final msg = _publicNewsTitleController.text.trim();
                  if (msg.isEmpty) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Broadcast sent: $msg')),
                  );
                  _publicNewsTitleController.clear();
                  setState(() {});
                },
                style: ElevatedButton.styleFrom(backgroundColor: widget.accent),
                child: const Text('Send'),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      _PanelCard(
        title: 'Tournament management',
        subtitle: 'Create and manage tournaments',
        accent: widget.accent,
        child: Column(
          children: [
            for (var t in _tournaments ?? [])
              ListTile(
                title: Text(t['name']!),
                subtitle: Text(t['date']!),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    _tournaments!.remove(t);
                    setState(() {});
                  },
                ),
              ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _openFeatureSheet(
                  title: 'New tournament',
                  subtitle: 'Add a tournament',
                  children: [
                    TextField(
                      controller: _publicNewsTitleController,
                      decoration: const InputDecoration(labelText: 'Name'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _publicNewsBodyController,
                      decoration: const InputDecoration(labelText: 'Date'),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          final name = _publicNewsTitleController.text.trim();
                          final date = _publicNewsBodyController.text.trim();
                          if (name.isEmpty || date.isEmpty) return;
                          _tournaments!.add({'name': name, 'date': date});
                          _publicNewsTitleController.clear();
                          _publicNewsBodyController.clear();
                          setState(() {});
                        },
                        child: const Text('Create'),
                      ),
                    ),
                  ],
                ),
                child: const Text('Add tournament'),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      _PanelCard(
        title: 'Sponsor banner control',
        subtitle: 'Manage sponsor banners shown on site',
        accent: widget.accent,
        child: Column(
          children: [
            for (var i = 0; i < (_sponsorBanners?.length ?? 0); i++)
              ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    _sponsorBanners![i],
                    width: 64,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(_sponsorBanners![i]),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    _sponsorBanners!.removeAt(i);
                    setState(() {});
                  },
                ),
              ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  _openFeatureSheet(
                    title: 'Add sponsor banner',
                    subtitle: 'Provide image URL',
                    children: [
                      TextField(
                        controller: _publicNewsImageController,
                        decoration: const InputDecoration(
                          labelText: 'Image URL',
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_publicNewsImageController.text
                                .trim()
                                .isNotEmpty) {
                              _sponsorBanners ??= [];
                              _sponsorBanners!.add(
                                _publicNewsImageController.text.trim(),
                              );
                              _publicNewsImageController.clear();
                              setState(() {});
                            }
                          },
                          child: const Text('Add'),
                        ),
                      ),
                    ],
                  );
                },
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: const Text('Add banner'),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      _PanelCard(
        title: 'Analytics dashboard',
        subtitle: 'Quick metrics',
        accent: widget.accent,
        child: Column(
          children: [
            _ChartCard(
              title: 'User growth',
              subtitle: 'Last 6 months',
              accent: widget.accent,
              values: const [12, 18, 24, 30, 44, 52],
              labels: const ['M1', 'M2', 'M3', 'M4', 'M5', 'M6'],
            ),
            const SizedBox(height: 8),
            _ChartCard(
              title: 'Revenue',
              subtitle: 'Monthly',
              accent: widget.accent,
              values: const [1200, 1800, 2300, 2100, 2700],
              labels: const ['Jan', 'Feb', 'Mar', 'Apr', 'May'],
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      _PanelCard(
        title: 'Content management',
        subtitle: 'Manage news and CMS posts',
        accent: widget.accent,
        child: Column(
          children: [
            for (var i = 0; i < _cmsPosts.length; i++) ...[
              _CmsPostCard(
                post: _cmsPosts[i],
                accent: widget.accent,
                onDelete: () => _deleteCmsPost(i),
              ),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    ];
  }

  // Lazy-initialized admin lists stored as nullable fields in state
  List<Map<String, String>>? _mockPayments;
  List<Map<String, String>>? _tournaments;
  List<String>? _sponsorBanners;

  List<Widget> _adminUserCreateSheet() {
    final TextEditingController name = TextEditingController();
    final TextEditingController email = TextEditingController();
    final TextEditingController password = TextEditingController();
    UserRole role = UserRole.player;

    return [
      StatefulBuilder(
        builder: (ctx, setLocalState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Full name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: email,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: password,
                decoration: const InputDecoration(labelText: 'Password'),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Role:'),
                  const SizedBox(width: 8),
                  DropdownButton<UserRole>(
                    value: role,
                    items: const [
                      DropdownMenuItem(
                        value: UserRole.player,
                        child: Text('Player'),
                      ),
                      DropdownMenuItem(
                        value: UserRole.coach,
                        child: Text('Coach'),
                      ),
                      DropdownMenuItem(
                        value: UserRole.parent,
                        child: Text('Parent'),
                      ),
                      DropdownMenuItem(
                        value: UserRole.performanceAnalyst,
                        child: Text('Analyst'),
                      ),
                      DropdownMenuItem(
                        value: UserRole.admin,
                        child: Text('Admin'),
                      ),
                    ],
                    onChanged: (v) {
                      if (v != null) setLocalState(() => role = v);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final err = widget.onCreateUser(
                      fullName: name.text.trim(),
                      email: email.text.trim(),
                      password: password.text,
                      role: role,
                    );
                    if (err != null) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(err)));
                      return;
                    }
                    Navigator.of(context).pop();
                    setState(() {});
                  },
                  child: const Text('Create'),
                ),
              ),
            ],
          );
        },
      ),
    ];
  }
}

class _AdminPlayerCard extends StatelessWidget {
  const _AdminPlayerCard({
    required this.player,
    required this.accent,
    required this.onOpenProfile,
    required this.onOpenPerformance,
    required this.onOpenAchievements,
  });

  final AppUser player;
  final Color accent;
  final VoidCallback onOpenProfile;
  final VoidCallback onOpenPerformance;
  final VoidCallback onOpenAchievements;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: accent.withValues(alpha: 0.14),
                child: Icon(Icons.sports_hockey, color: accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      player.fullName,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      player.email,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton(
                onPressed: onOpenProfile,
                child: const Text('Profile'),
              ),
              OutlinedButton(
                onPressed: onOpenPerformance,
                child: const Text('Performance'),
              ),
              OutlinedButton(
                onPressed: onOpenAchievements,
                child: const Text('Achievements'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CmsPostCard extends StatelessWidget {
  const _CmsPostCard({
    required this.post,
    required this.accent,
    required this.onDelete,
  });

  final _CmsPost post;
  final Color accent;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.campaign_outlined, color: accent, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  post.title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                tooltip: 'Delete',
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            post.date,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            post.body,
            style: TextStyle(color: Colors.grey.shade700, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _PlayerAttendanceSummary {
  const _PlayerAttendanceSummary({
    required this.name,
    required this.role,
    required this.present,
    required this.late,
    required this.absent,
    required this.accent,
  });

  final String name;
  final String role;
  final String present;
  final String late;
  final String absent;
  final Color accent;
}

class _AttendanceMonthData {
  const _AttendanceMonthData({
    required this.label,
    required this.playerName,
    required this.playerRole,
    required this.team,
    required this.totalSessions,
    required this.present,
    required this.late,
    required this.absent,
    required this.coachPresent,
    required this.coachLate,
    required this.averageAttendance,
    required this.chartSubtitle,
    required this.trendValues,
    required this.trendLabels,
    required this.sessions,
    required this.adminSummaries,
  });

  final String label;
  final String playerName;
  final String playerRole;
  final String team;
  final String totalSessions;
  final String present;
  final String late;
  final String absent;
  final String coachPresent;
  final String coachLate;
  final String averageAttendance;
  final String chartSubtitle;
  final List<double> trendValues;
  final List<String> trendLabels;
  final List<_AttendanceSession> sessions;
  final List<_PlayerAttendanceSummary> adminSummaries;
}

const List<_AttendanceMonthData> _attendanceMonths = [
  _AttendanceMonthData(
    label: 'Oct 2023',
    playerName: 'Ahmed Khan',
    playerRole: 'Player #12',
    team: 'JM Hockey U-16 Boys Team A',
    totalSessions: '21',
    present: '18 (G)',
    late: '2 (Y)',
    absent: '1 (R)',
    coachPresent: '19 (G)',
    coachLate: '1 (Y)',
    averageAttendance: '89%',
    chartSubtitle: 'Last 5 weeks',
    trendValues: [76, 84, 89, 94, 97],
    trendLabels: ['W1', 'W2', 'W3', 'W4', 'W5'],
    sessions: [
      _AttendanceSession(
        date: 'Oct 24, 2023',
        title: 'Practice Session',
        detail: 'Drills & tactics • strong defensive work',
        status: 'PRESENT',
        statusColor: Color(0xFF1E88E5),
        icon: Icons.check_circle,
      ),
      _AttendanceSession(
        date: 'Oct 21, 2023',
        title: 'Scrimmage - Inter-Squad',
        detail: 'Strong passing and positioning',
        status: 'PRESENT',
        statusColor: Color(0xFF1E88E5),
        icon: Icons.check_circle,
      ),
      _AttendanceSession(
        date: 'Oct 18, 2023',
        title: 'Conditioning & Strength',
        detail: 'Slightly late, but good effort',
        status: 'LATE (5 mins)',
        statusColor: Color(0xFFFFB300),
        icon: Icons.schedule,
      ),
      _AttendanceSession(
        date: 'Oct 14, 2023',
        title: 'Strategy Meeting',
        detail: 'Excused from training',
        status: 'ABSENT',
        statusColor: Color(0xFFD32F2F),
        icon: Icons.cancel,
      ),
    ],
    adminSummaries: [
      _PlayerAttendanceSummary(
        name: 'Ahmed Khan',
        role: 'Player #12',
        present: '18',
        late: '2',
        absent: '1',
        accent: Color(0xFF1E88E5),
      ),
      _PlayerAttendanceSummary(
        name: 'Liam Patel',
        role: 'Player #08',
        present: '20',
        late: '1',
        absent: '0',
        accent: Color(0xFF1E88E5),
      ),
      _PlayerAttendanceSummary(
        name: 'Noah Wilson',
        role: 'Player #15',
        present: '17',
        late: '2',
        absent: '2',
        accent: Color(0xFFFFB300),
      ),
      _PlayerAttendanceSummary(
        name: 'Ethan Brown',
        role: 'Player #04',
        present: '19',
        late: '1',
        absent: '1',
        accent: Color(0xFF0F4C81),
      ),
    ],
  ),
  _AttendanceMonthData(
    label: 'Sep 2023',
    playerName: 'Ahmed Khan',
    playerRole: 'Player #12',
    team: 'JM Hockey U-16 Boys Team A',
    totalSessions: '20',
    present: '17 (G)',
    late: '2 (Y)',
    absent: '1 (R)',
    coachPresent: '18 (G)',
    coachLate: '1 (Y)',
    averageAttendance: '85%',
    chartSubtitle: 'September form',
    trendValues: [62, 71, 79, 86, 90],
    trendLabels: ['W1', 'W2', 'W3', 'W4', 'W5'],
    sessions: [
      _AttendanceSession(
        date: 'Sep 23, 2023',
        title: 'Practice Session',
        detail: 'Power skating and puck control',
        status: 'PRESENT',
        statusColor: Color(0xFF1E88E5),
        icon: Icons.check_circle,
      ),
      _AttendanceSession(
        date: 'Sep 20, 2023',
        title: 'Small-area games',
        detail: 'Good communication under pressure',
        status: 'PRESENT',
        statusColor: Color(0xFF1E88E5),
        icon: Icons.check_circle,
      ),
      _AttendanceSession(
        date: 'Sep 16, 2023',
        title: 'Strength session',
        detail: 'Arrived late due to school',
        status: 'LATE (7 mins)',
        statusColor: Color(0xFFFFB300),
        icon: Icons.schedule,
      ),
      _AttendanceSession(
        date: 'Sep 12, 2023',
        title: 'Team meeting',
        detail: 'Missed with prior notice',
        status: 'ABSENT',
        statusColor: Color(0xFFD32F2F),
        icon: Icons.cancel,
      ),
    ],
    adminSummaries: [
      _PlayerAttendanceSummary(
        name: 'Ahmed Khan',
        role: 'Player #12',
        present: '17',
        late: '2',
        absent: '1',
        accent: Color(0xFF1E88E5),
      ),
      _PlayerAttendanceSummary(
        name: 'Liam Patel',
        role: 'Player #08',
        present: '19',
        late: '1',
        absent: '0',
        accent: Color(0xFF1E88E5),
      ),
      _PlayerAttendanceSummary(
        name: 'Noah Wilson',
        role: 'Player #15',
        present: '16',
        late: '2',
        absent: '2',
        accent: Color(0xFFFFB300),
      ),
      _PlayerAttendanceSummary(
        name: 'Ethan Brown',
        role: 'Player #04',
        present: '18',
        late: '1',
        absent: '1',
        accent: Color(0xFF0F4C81),
      ),
    ],
  ),
];

class _PlayerAttendanceSummaryCard extends StatelessWidget {
  const _PlayerAttendanceSummaryCard({
    required this.player,
    required this.onTap,
  });

  final _PlayerAttendanceSummary player;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: player.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.person, color: player.accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      player.name,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      player.role,
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _Pill(
                          label: 'Present',
                          value: player.present,
                          color: player.accent,
                        ),
                        _Pill(
                          label: 'Late',
                          value: player.late,
                          color: Color(0xFFFFB300),
                        ),
                        _Pill(
                          label: 'Absent',
                          value: player.absent,
                          color: const Color(0xFFD32F2F),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade500),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardItem {
  const _DashboardItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.detailTitle,
    required this.detailText,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String detailTitle;
  final String detailText;
}

class _AuthField extends StatelessWidget {
  const _AuthField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

class _PanelCard extends StatelessWidget {
  const _PanelCard({
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Color accent;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(color: Colors.grey.shade500)),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value, this.onTap});

  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? Colors.white10 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '$label: $value',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  const _DayCard({required this.day});

  final _OpsDay day;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: day.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: day.color.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: day.color,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              day.label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  day.title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(day.detail, style: TextStyle(color: Colors.grey.shade500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.task, required this.accent});

  final _OpsTask task;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: accent.withValues(alpha: 0.12),
            child: Icon(task.icon, color: accent, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  task.status,
                  style: TextStyle(color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'Open',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusLine extends StatelessWidget {
  const _StatusLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _SecurityRow extends StatelessWidget {
  const _SecurityRow({
    required this.role,
    required this.canType,
    required this.canCreate,
    required this.accent,
    required this.onToggleType,
    required this.onToggleCreate,
    this.locked = false,
  });

  final String role;
  final bool canType;
  final bool canCreate;
  final Color accent;
  final VoidCallback onToggleType;
  final VoidCallback onToggleCreate;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Text(role, style: const TextStyle(fontWeight: FontWeight.w700)),
                if (locked) ...[
                  const SizedBox(width: 6),
                  Icon(Icons.lock, size: 14, color: accent),
                ],
              ],
            ),
          ),
          _PermissionButton(
            label: 'Type ${canType ? 'On' : 'Off'}',
            enabled: canType,
            accent: accent,
            onPressed: locked ? () {} : onToggleType,
          ),
          const SizedBox(width: 8),
          _PermissionButton(
            label: 'Create ${canCreate ? 'On' : 'Off'}',
            enabled: canCreate,
            accent: accent,
            onPressed: locked ? () {} : onToggleCreate,
          ),
        ],
      ),
    );
  }
}

class _PermissionButton extends StatelessWidget {
  const _PermissionButton({
    required this.label,
    required this.enabled,
    required this.accent,
    required this.onPressed,
  });

  final String label;
  final bool enabled;
  final Color accent;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: enabled ? accent : Colors.grey.shade300),
        backgroundColor: enabled
            ? accent.withValues(alpha: 0.12)
            : Colors.transparent,
        foregroundColor: enabled ? accent : Colors.grey.shade500,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _ActivityLine extends StatelessWidget {
  const _ActivityLine({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 18,
            child: Icon(Icons.lock_outline, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: Colors.grey.shade500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({
    required this.title,
    required this.accent,
    required this.onPrevious,
    required this.onNext,
  });

  final String title;
  final Color accent;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onPrevious,
            icon: Icon(Icons.chevron_left, color: accent),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(color: accent, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: onNext,
            icon: Icon(Icons.chevron_right, color: accent),
          ),
        ],
      ),
    );
  }
}

class _MonthSelector extends StatelessWidget {
  const _MonthSelector({
    required this.months,
    required this.selectedIndex,
    required this.accent,
    required this.onChanged,
  });

  final List<_AttendanceMonthData> months;
  final int selectedIndex;
  final Color accent;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_month_outlined, color: accent),
          const SizedBox(width: 10),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: selectedIndex,
                isExpanded: true,
                borderRadius: BorderRadius.circular(16),
                icon: Icon(Icons.keyboard_arrow_down, color: accent),
                items: [
                  for (var i = 0; i < months.length; i++)
                    DropdownMenuItem<int>(
                      value: i,
                      child: Text(months[i].label),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    onChanged(value);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.name,
    required this.role,
    required this.team,
    required this.accent,
    required this.avatarIcon,
    this.imageUrl,
  });

  final String name;
  final String role;
  final String team;
  final Color accent;
  final IconData avatarIcon;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            clipBehavior: Clip.antiAlias,
            child: imageUrl == null
                ? Icon(avatarIcon, color: accent, size: 40)
                : Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Center(
                      child: Icon(avatarIcon, color: accent, size: 40),
                    ),
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(role, style: TextStyle(color: Colors.grey.shade500)),
                const SizedBox(height: 6),
                Text(team, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _Pill(label: 'Injury', value: 'OK', color: accent),
                    const SizedBox(width: 8),
                    const _Pill(
                      label: 'Status',
                      value: 'Active',
                      color: Color(0xFFFFB300),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SummaryStrip extends StatelessWidget {
  const _SummaryStrip({
    required this.total,
    required this.present,
    required this.late,
    required this.absent,
    required this.accent,
  });

  final String total;
  final String present;
  final String late;
  final String absent;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F4C81),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SummaryCell(
              title: 'Total Sessions',
              value: total,
              valueColor: Colors.white,
            ),
          ),
          Expanded(
            child: _SummaryCell(
              title: 'Present',
              value: present,
              valueColor: const Color(0xFF8BC34A),
            ),
          ),
          Expanded(
            child: _SummaryCell(
              title: 'Late',
              value: late,
              valueColor: const Color(0xFFFFD54F),
            ),
          ),
          Expanded(
            child: _SummaryCell(
              title: 'Absent',
              value: absent,
              valueColor: const Color(0xFFFF8A80),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCell extends StatelessWidget {
  const _SummaryCell({
    required this.title,
    required this.value,
    required this.valueColor,
  });

  final String title;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _AttendanceCard extends StatelessWidget {
  const _AttendanceCard({required this.session});

  final _AttendanceSession session;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: session.statusColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(session.icon, color: session.statusColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.date,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  session.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  session.detail,
                  style: TextStyle(color: Colors.grey.shade500, height: 1.3),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: session.statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              session.status,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: session.statusColor,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomReportCard extends StatelessWidget {
  const _BottomReportCard({
    required this.buttonText,
    required this.subtitle,
    required this.accent,
    this.onPressed,
  });

  final String buttonText;
  final String subtitle;
  final Color accent;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade500, height: 1.4),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(buttonText),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartCard extends StatefulWidget {
  const _ChartCard({
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.values,
    required this.labels,
  });

  final String title;
  final String subtitle;
  final Color accent;
  final List<double> values;
  final List<String> labels;

  @override
  State<_ChartCard> createState() => _ChartCardState();
}

class _ChartCardState extends State<_ChartCard> {
  int? _selectedIndex;

  void _toggleSelection(int index) {
    setState(() {
      _selectedIndex = _selectedIndex == index ? null : index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasSelection = _selectedIndex != null;
    final selectedValue = hasSelection ? widget.values[_selectedIndex!] : null;
    final selectedLabel = hasSelection ? widget.labels[_selectedIndex!] : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle,
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                child: hasSelection
                    ? Container(
                        key: ValueKey(_selectedIndex),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: widget.accent.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '$selectedLabel: ${selectedValue!.round()}',
                          style: TextStyle(
                            color: widget.accent,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      )
                    : Icon(
                        Icons.touch_app_outlined,
                        size: 18,
                        color: Colors.grey.shade500,
                      ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < widget.values.length; i++)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _toggleSelection(i),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              widget.values[i].round().toString(),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: _selectedIndex == i
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                                color: _selectedIndex == i
                                    ? widget.accent
                                    : Colors.grey.shade500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Expanded(
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: FractionallySizedBox(
                                  heightFactor: (widget.values[i] / 100).clamp(
                                    0.04,
                                    1.0,
                                  ),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 150),
                                    decoration: BoxDecoration(
                                      color: _selectedIndex == i
                                          ? widget.accent
                                          : (i.isEven
                                                ? widget.accent.withValues(
                                                    alpha: 0.55,
                                                  )
                                                : const Color(
                                                    0xFFFFD54F,
                                                  ).withValues(alpha: 0.85)),
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(8),
                                      ),
                                      border: _selectedIndex == i
                                          ? Border.all(
                                              color: widget.accent,
                                              width: 2,
                                            )
                                          : null,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              widget.labels[i],
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: _selectedIndex == i
                                    ? FontWeight.w800
                                    : FontWeight.normal,
                                color: _selectedIndex == i
                                    ? widget.accent
                                    : Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasSelection
                ? 'Tap the bar again to close'
                : 'Tap a bar to see its exact number',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({
    required this.label,
    required this.progress,
    required this.accent,
  });

  final String label;
  final double progress;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
            Text(
              '${(progress * 100).round()}%',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 12,
            color: accent,
            backgroundColor: accent.withValues(alpha: 0.16),
          ),
        ),
      ],
    );
  }
}

class _AchievementTile extends StatelessWidget {
  const _AchievementTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: color.withValues(alpha: 0.14),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: Colors.grey.shade500)),
              ],
            ),
          ),
          const Icon(Icons.emoji_events_outlined, color: Color(0xFFFFB300)),
        ],
      ),
    );
  }
}

class _OpsDay {
  const _OpsDay({
    required this.label,
    required this.title,
    required this.detail,
    required this.color,
  });

  final String label;
  final String title;
  final String detail;
  final Color color;
}

class _OpsTask {
  const _OpsTask({
    required this.title,
    required this.status,
    required this.icon,
  });

  final String title;
  final String status;
  final IconData icon;
}

class _AttendanceSession {
  const _AttendanceSession({
    required this.date,
    required this.title,
    required this.detail,
    required this.status,
    required this.statusColor,
    required this.icon,
  });

  final String date;
  final String title;
  final String detail;
  final String status;
  final Color statusColor;
  final IconData icon;
}

class _ChatGroup {
  _ChatGroup({
    required this.name,
    required this.members,
    required this.canType,
    required this.visibleTo,
    List<_ChatMessage>? messages,
  }) : messages = messages ?? <_ChatMessage>[];

  final String name;
  final List<String> members;
  final List<bool> canType;
  final List<UserRole> visibleTo;
  final List<_ChatMessage> messages;
}
