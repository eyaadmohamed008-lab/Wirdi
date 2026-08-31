import 'package:flutter/material.dart';
import 'package:quran/quran.dart' as quran;
import 'package:shared_preferences/shared_preferences.dart';
<<<<<<< HEAD
import 'package:audioplayers/audioplayers.dart';
import 'dart:convert';
import 'dart:async';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WirdyApp());
=======
import 'dart:convert';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const QuranApp());
>>>>>>> 9dc7ff7e6cb7fa45d3c21e35a2c259ab21891d03
}

enum AppColorTheme { green, pink, blue, purple }

<<<<<<< HEAD
class WirdyApp extends StatelessWidget {
  const WirdyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'وِرْدي - Wirdy',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00FF66),
          secondary: Color(0xFF00FF66),
          surface: Color(0xFF1E1E1E),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProfileSelectionScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00FF66).withValues(alpha: 0.15),
                border: Border.all(color: const Color(0xFF00FF66), width: 2),
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                size: 80,
                color: Color(0xFF00FF66),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'تطبيق وِرْدي',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'صفحات القرآن والسكور اليومي ✨',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              color: Color(0xFF00FF66),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileSelectionScreen extends StatefulWidget {
  const ProfileSelectionScreen({super.key});

  @override
  State<ProfileSelectionScreen> createState() => _ProfileSelectionScreenState();
}

class _ProfileSelectionScreenState extends State<ProfileSelectionScreen> {
  List<Map<String, String>> users = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    String? usersJson = prefs.getString('app_users_list');
    if (usersJson != null) {
      List<dynamic> decoded = jsonDecode(usersJson);
      setState(() {
        users = decoded.map((item) => Map<String, String>.from(item as Map)).toList();
      });
    }
  }

  Future<void> _saveUsers() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_users_list', jsonEncode(users));
  }

  void _showAddUserDialog() {
    final nameController = TextEditingController();
    final passController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة حساب جديد'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'اسم المستخدم'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'كلمة المرور'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              String name = nameController.text.trim();
              String pass = passController.text.trim();
              if (name.isNotEmpty && pass.isNotEmpty) {
                if (users.any((u) => u['name'] == name)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('هذا الاسم موجود بالفعل!')),
                  );
                  return;
                }
                setState(() {
                  users.add({'name': name, 'pass': pass});
                });
                _saveUsers();
                Navigator.pop(context);
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void _showLoginDialog(Map<String, String> user) {
    final passController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تسجيل الدخول: ${user['name']}'),
        content: TextField(
          controller: passController,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'أدخل كلمة المرور'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (passController.text.trim() == user['pass']) {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MainContainerScreen(userName: user['name']!),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('كلمة المرور غير صحيحة!')),
                );
              }
            },
            child: const Text('دخول'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تطبيق وِرْدي - الحسابات'),
        centerTitle: true,
        backgroundColor: Colors.teal.shade800,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Icon(Icons.menu_book, size: 70, color: Colors.teal),
            const SizedBox(height: 15),
            const Text(
              'اختر حسابك أو أنشئ حساباً جديداً',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: users.isEmpty
                  ? const Center(
                      child: Text(
                        'لا توجد حسابات مسجلة حالياً.\nاضغط على زر إضافة حساب أدناه للبدء.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Colors.teal,
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                            title: Text(
                              users[index]['name']!,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            subtitle: const Text('انقر لتسجيل الدخول'),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () => _showLoginDialog(users[index]),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                onPressed: _showAddUserDialog,
                icon: const Icon(Icons.person_add),
                label: const Text('إضافة حساب جديد', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MainContainerScreen extends StatefulWidget {
  final String userName;
  const MainContainerScreen({super.key, required this.userName});

  @override
  State<MainContainerScreen> createState() => _MainContainerScreenState();
}

class _MainContainerScreenState extends State<MainContainerScreen> {
=======
class QuranApp extends StatefulWidget {
  const QuranApp({super.key});

  @override
  State<QuranApp> createState() => _QuranAppState();
}

class _QuranAppState extends State<QuranApp> {
>>>>>>> 9dc7ff7e6cb7fa45d3c21e35a2c259ab21891d03
  bool isDarkMode = true;
  AppColorTheme currentColorTheme = AppColorTheme.green;

  static const neonGreen = Color(0xFF00FF66);
  static const neonPink = Color(0xFFFF1493);
  static const neonBlue = Color(0xFF00E5FF);
  static const neonPurple = Color(0xFFBD00FF);

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
<<<<<<< HEAD
      isDarkMode = prefs.getBool('isDarkMode_${widget.userName}') ?? true;
      int themeIndex = prefs.getInt('colorTheme_${widget.userName}') ?? 0;
=======
      isDarkMode = prefs.getBool('isDarkMode') ?? true;
      int themeIndex = prefs.getInt('colorTheme') ?? 0;
>>>>>>> 9dc7ff7e6cb7fa45d3c21e35a2c259ab21891d03
      currentColorTheme = AppColorTheme.values[themeIndex];
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
<<<<<<< HEAD
    await prefs.setBool('isDarkMode_${widget.userName}', isDarkMode);
    await prefs.setInt('colorTheme_${widget.userName}', currentColorTheme.index);
=======
    await prefs.setBool('isDarkMode', isDarkMode);
    await prefs.setInt('colorTheme', currentColorTheme.index);
>>>>>>> 9dc7ff7e6cb7fa45d3c21e35a2c259ab21891d03
  }

  Color _getPrimaryColor() {
    switch (currentColorTheme) {
      case AppColorTheme.green:
        return neonGreen;
      case AppColorTheme.pink:
        return neonPink;
      case AppColorTheme.blue:
        return neonBlue;
      case AppColorTheme.purple:
        return neonPurple;
    }
  }

  ThemeData _getThemeData() {
    final primaryColor = _getPrimaryColor();
    return isDarkMode
        ? ThemeData.dark().copyWith(
            scaffoldBackgroundColor: const Color(0xFF121212),
            colorScheme: ColorScheme.dark(
              primary: primaryColor,
              secondary: primaryColor,
              surface: const Color(0xFF1E1E1E),
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: const Color(0xFF1E1E1E),
              foregroundColor: primaryColor,
              centerTitle: true,
            ),
          )
        : ThemeData.light().copyWith(
            scaffoldBackgroundColor: const Color(0xFFF8F9FA),
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              secondary: primaryColor,
              surface: Colors.white,
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              centerTitle: true,
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    return Theme(
      data: _getThemeData(),
      child: MainNavigationScreen(
        userName: widget.userName,
=======
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'تطبيق القرآن والمهام',
      theme: _getThemeData(),
      home: MainNavigationScreen(
>>>>>>> 9dc7ff7e6cb7fa45d3c21e35a2c259ab21891d03
        isDarkMode: isDarkMode,
        currentColorTheme: currentColorTheme,
        onDarkModeChanged: (v) {
          setState(() => isDarkMode = v);
          _saveSettings();
        },
        onColorThemeChanged: (t) {
          setState(() => currentColorTheme = t);
          _saveSettings();
        },
      ),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
<<<<<<< HEAD
  final String userName;
=======
>>>>>>> 9dc7ff7e6cb7fa45d3c21e35a2c259ab21891d03
  final bool isDarkMode;
  final AppColorTheme currentColorTheme;
  final Function(bool) onDarkModeChanged;
  final Function(AppColorTheme) onColorThemeChanged;

  const MainNavigationScreen({
    super.key,
<<<<<<< HEAD
    required this.userName,
=======
>>>>>>> 9dc7ff7e6cb7fa45d3c21e35a2c259ab21891d03
    required this.isDarkMode,
    required this.currentColorTheme,
    required this.onDarkModeChanged,
    required this.onColorThemeChanged,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
<<<<<<< HEAD
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
=======
>>>>>>> 9dc7ff7e6cb7fa45d3c21e35a2c259ab21891d03

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    final pages = [
<<<<<<< HEAD
      QuranPagesListScreen(
        userName: widget.userName,
=======
      QuranListScreen(
>>>>>>> 9dc7ff7e6cb7fa45d3c21e35a2c259ab21891d03
        isDarkMode: widget.isDarkMode,
        currentColorTheme: widget.currentColorTheme,
        onDarkModeChanged: widget.onDarkModeChanged,
        onColorThemeChanged: widget.onColorThemeChanged,
      ),
      TasksScreen(
<<<<<<< HEAD
        userName: widget.userName,
=======
>>>>>>> 9dc7ff7e6cb7fa45d3c21e35a2c259ab21891d03
        isDarkMode: widget.isDarkMode,
        currentColorTheme: widget.currentColorTheme,
        onDarkModeChanged: widget.onDarkModeChanged,
        onColorThemeChanged: widget.onColorThemeChanged,
      ),
    ];

    return Scaffold(
<<<<<<< HEAD
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: pages,
      ),
=======
      body: pages[_selectedIndex],
>>>>>>> 9dc7ff7e6cb7fa45d3c21e35a2c259ab21891d03
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
<<<<<<< HEAD
        onTap: (index) {
          setState(() => _selectedIndex = index);
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'المصحف (السور)'),
=======
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'المصحف'),
>>>>>>> 9dc7ff7e6cb7fa45d3c21e35a2c259ab21891d03
          BottomNavigationBarItem(icon: Icon(Icons.task_alt), label: 'المهام والسكور'),
        ],
      ),
    );
  }
}

<<<<<<< HEAD
class QuranPagesListScreen extends StatefulWidget {
  final String userName;
=======
class QuranListScreen extends StatelessWidget {
>>>>>>> 9dc7ff7e6cb7fa45d3c21e35a2c259ab21891d03
  final bool isDarkMode;
  final AppColorTheme currentColorTheme;
  final Function(bool) onDarkModeChanged;
  final Function(AppColorTheme) onColorThemeChanged;

<<<<<<< HEAD
  const QuranPagesListScreen({
    super.key,
    required this.userName,
=======
  const QuranListScreen({
    super.key,
>>>>>>> 9dc7ff7e6cb7fa45d3c21e35a2c259ab21891d03
    required this.isDarkMode,
    required this.currentColorTheme,
    required this.onDarkModeChanged,
    required this.onColorThemeChanged,
  });

  @override
<<<<<<< HEAD
  State<QuranPagesListScreen> createState() => _QuranPagesListScreenState();
}

class _QuranPagesListScreenState extends State<QuranPagesListScreen> {
  @override
=======
>>>>>>> 9dc7ff7e6cb7fa45d3c21e35a2c259ab21891d03
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
<<<<<<< HEAD
        title: Text('وِرْدي - سور القرآن ${widget.userName}', style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.wb_sunny : Icons.nightlight_round),
            onPressed: () => widget.onDarkModeChanged(!widget.isDarkMode),
          ),
          ThemePopupMenu(onColorThemeChanged: widget.onColorThemeChanged, isDarkMode: widget.isDarkMode),
        ],
      ),
      body: ListView.builder(
        itemCount: 114,
        padding: const EdgeInsets.all(12),
        itemBuilder: (context, index) {
          int surahNum = index + 1;
          String surahName = quran.getSurahNameArabic(surahNum);
          int startPage = quran.getPageNumber(surahNum, 1);
          int endPage = surahNum < 114 ? quran.getPageNumber(surahNum + 1, 1) - 1 : 604;
          if (endPage < startPage) endPage = 604;

          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 5),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: primaryColor.withValues(alpha: 0.15),
                foregroundColor: primaryColor,
                child: Text('$surahNum', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              title: Text(
                'سورة $surahName',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: widget.isDarkMode ? primaryColor : Colors.black87,
                ),
              ),
              subtitle: Text('الصفحات من $startPage إلى $endPage'),
              trailing: Icon(Icons.arrow_forward_ios, color: primaryColor, size: 16),
=======
        title: const Text('القرآن الكريم', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.wb_sunny : Icons.nightlight_round),
            onPressed: () => onDarkModeChanged(!isDarkMode),
          ),
          ThemePopupMenu(onColorThemeChanged: onColorThemeChanged, isDarkMode: isDarkMode),
        ],
      ),
      body: ListView.builder(
        itemCount: quran.totalSurahCount,
        padding: const EdgeInsets.all(12),
        itemBuilder: (context, index) {
          int surahNumber = index + 1;
          String surahName = quran.getSurahNameArabic(surahNumber);
          int versesCount = quran.getVerseCount(surahNumber);
          String place = quran.getPlaceOfRevelation(surahNumber) == 'Makkah' ? 'مكية' : 'مدنية';

          return Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: primaryColor.withOpacity(0.15),
                foregroundColor: primaryColor,
                child: Text('$surahNumber', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              title: Text(
                surahName,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? primaryColor : Colors.black87,
                ),
              ),
              subtitle: Text('سورة $place | $versesCount آية'),
              trailing: Icon(Icons.arrow_forward_ios, color: primaryColor, size: 18),
>>>>>>> 9dc7ff7e6cb7fa45d3c21e35a2c259ab21891d03
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
<<<<<<< HEAD
                    builder: (context) => MushafHorizontalViewer(
                      initialPage: startPage,
=======
                    builder: (context) => SurahDetailScreen(
                      surahNumber: surahNumber,
                      surahName: surahName,
>>>>>>> 9dc7ff7e6cb7fa45d3c21e35a2c259ab21891d03
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

<<<<<<< HEAD
// عارض صفحات المصحف: آيات متتالية كنص واحد، تفعيل التحديد بالماوس واللمس، وصوت مستقر
class MushafHorizontalViewer extends StatefulWidget {
  final int initialPage;

  const MushafHorizontalViewer({super.key, required this.initialPage});

  @override
  State<MushafHorizontalViewer> createState() => _MushafHorizontalViewerState();
}

class _MushafHorizontalViewerState extends State<MushafHorizontalViewer> {
  late PageController _pageController;
  int currentPage = 1;
  bool isPlaying = false;
  bool isLoadingAudio = false;
  late AudioPlayer _audioPlayer;
  String selectedReciterUrl = 'https://server8.mp3quran.net/afs/';

  final Map<String, String> reciters = {
    'الشيخ مشاري راشد العفاسي': 'https://server8.mp3quran.net/afs/',
    'الشيخ عبد الباسط عبد الصمد': 'https://server7.mp3quran.net/abdulsamad/',
    'الشيخ محمود خليل الحصري': 'https://server13.mp3quran.net/husr/',
    'الشيخ محمد صديق المنشاوي': 'https://server10.mp3quran.net/minsh/',
  };

  @override
  void initState() {
    super.initState();
    currentPage = widget.initialPage;
    _pageController = PageController(initialPage: 604 - widget.initialPage);
    
    _audioPlayer = AudioPlayer();
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          isPlaying = state == PlayerState.playing;
          if (isPlaying) isLoadingAudio = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatPageNumber(int pageNum) {
    return pageNum.toString().padLeft(3, '0');
  }

  Future<void> _togglePlayAudio() async {
    if (isPlaying) {
      await _audioPlayer.pause();
    } else {
      setState(() => isLoadingAudio = true);
      String audioUrl = '$selectedReciterUrl${_formatPageNumber(currentPage)}.mp3';
      try {
        await _audioPlayer.stop();
        await _audioPlayer.play(UrlSource(audioUrl));
      } catch (e) {
        if (mounted) {
          setState(() => isLoadingAudio = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تعذر تشغيل الصوت، سيعمل تماماً على تطبيق الهاتف (APK)')),
          );
        }
      }
    }
  }

  void _showReciterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('اختر المقرئ الصوتي'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: reciters.length,
            itemBuilder: (context, index) {
              String name = reciters.keys.elementAt(index);
              String url = reciters.values.elementAt(index);
              return ListTile(
                title: Text(name),
                onTap: () async {
                  setState(() => selectedReciterUrl = url);
                  Navigator.pop(context);
                  if (isPlaying) {
                    await _audioPlayer.stop();
                    _togglePlayAudio();
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }

  // بناء النص المتتالي للآيات داخل الصفحة بدون سطور منفصلة
  Widget _buildPageContent(int pageNum, Color primaryColor) {
    List<InlineSpan> spans = [];

    try {
      for (int surah = 1; surah <= 114; surah++) {
        int startPage = quran.getPageNumber(surah, 1);
        
        // فاصل السورة والبسملة في بداية الصفحة حصرياً
        if (startPage == pageNum) {
          String surahName = quran.getSurahNameArabic(surah);
          
          spans.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(vertical: 14),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: primaryColor, width: 1.5),
                ),
                child: Center(
                  child: Text(
                    '✨ سورة $surahName ✨',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor),
                  ),
                ),
              ),
            ),
          );

          if (surah != 9) {
            spans.add(
              const WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 10.0),
                  child: Center(
                    child: Text(
                      'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                      style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            );
          }
        }

        // تجميع الآيات خلف بعضها بدون فصل سطر لكل آية
        int versesCount = quran.getVerseCount(surah);
        for (int ayah = 1; ayah <= versesCount; ayah++) {
          if (quran.getPageNumber(surah, ayah) == pageNum) {
            String ayahText = quran.getVerse(surah, ayah);
            spans.add(
              TextSpan(
                text: '$ayahText ﴿$ayah﴾ ',
                style: const TextStyle(
                  fontSize: 22,
                  fontFamily: 'Amiri',
                  height: 2.2,
                  color: Colors.white,
                ),
              ),
            );
          }
        }
      }
    } catch (_) {}

    if (spans.isEmpty) {
      spans.add(const TextSpan(text: 'صفحة فارغة', style: TextStyle(color: Colors.white)));
    }

    return SelectableText.rich(
      TextSpan(children: spans),
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.justify,
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text('صفحة المصحف رقم ($currentPage) من 604'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.settings_voice, color: primaryColor),
            onPressed: _showReciterDialog,
            tooltip: 'اختر المقرئ',
          ),
          isLoadingAudio
              ? Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(color: primaryColor, strokeWidth: 2),
                  ),
                )
              : IconButton(
                  icon: Icon(
                    isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                    color: primaryColor,
                    size: 32,
                  ),
                  onPressed: _togglePlayAudio,
                  tooltip: 'تشغيل تلاوة الصفحة',
                ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: PageView.builder(
          controller: _pageController,
          itemCount: 604,
          reverse: true,
          onPageChanged: (index) async {
            if (isPlaying) {
              await _audioPlayer.stop();
            }
            setState(() {
              currentPage = 604 - index;
            });
          },
          itemBuilder: (context, index) {
            int pageNum = 604 - index;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Text(
                        '--- صفحة $pageNum ---',
                        style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildPageContent(pageNum, primaryColor),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

=======
>>>>>>> 9dc7ff7e6cb7fa45d3c21e35a2c259ab21891d03
class QuranTask {
  final String surahName;
  final String category;
  final String fromRange;
  final String toRange;
  final int repeatCount;
  bool isCompleted;

  QuranTask({
    required this.surahName,
    required this.category,
    required this.fromRange,
    required this.toRange,
    required this.repeatCount,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() => {
        'surahName': surahName,
        'category': category,
        'fromRange': fromRange,
        'toRange': toRange,
        'repeatCount': repeatCount,
        'isCompleted': isCompleted,
      };

  factory QuranTask.fromJson(Map<String, dynamic> json) => QuranTask(
        surahName: json['surahName'],
        category: json['category'],
        fromRange: json['fromRange'],
        toRange: json['toRange'],
        repeatCount: json['repeatCount'],
        isCompleted: json['isCompleted'],
      );
}

class TasksScreen extends StatefulWidget {
<<<<<<< HEAD
  final String userName;
=======
>>>>>>> 9dc7ff7e6cb7fa45d3c21e35a2c259ab21891d03
  final bool isDarkMode;
  final AppColorTheme currentColorTheme;
  final Function(bool) onDarkModeChanged;
  final Function(AppColorTheme) onColorThemeChanged;

  const TasksScreen({
    super.key,
<<<<<<< HEAD
    required this.userName,
=======
>>>>>>> 9dc7ff7e6cb7fa45d3c21e35a2c259ab21891d03
    required this.isDarkMode,
    required this.currentColorTheme,
    required this.onDarkModeChanged,
    required this.onColorThemeChanged,
  });

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  int dailyScore = 0;
  int weeklyScore = 0;
  int totalScore = 0;

  String selectedCategory = 'الورد الجديد';
  String selectedSurah = quran.getSurahNameArabic(1);
<<<<<<< HEAD
  
  final TextEditingController startPageController = TextEditingController(text: '1');
  final TextEditingController endPageController = TextEditingController(text: '1');
=======
  final TextEditingController _fromController = TextEditingController(text: '1');
  final TextEditingController _toController = TextEditingController(text: '10');
  final TextEditingController _repeatController = TextEditingController(text: '1');
>>>>>>> 9dc7ff7e6cb7fa45d3c21e35a2c259ab21891d03

  List<QuranTask> tasks = [];

  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
    _updateSurahDefaultPages(1);
    _loadData();
  }

  @override
  void dispose() {
    startPageController.dispose();
    endPageController.dispose();
    super.dispose();
  }

  void _updateSurahDefaultPages(int surahNum) {
    int start = quran.getPageNumber(surahNum, 1);
    int end = 1;
    if (surahNum < 114) {
      end = quran.getPageNumber(surahNum + 1, 1);
      if (end > start) {
        end -= 1;
      }
    } else {
      end = 604;
    }
    startPageController.text = start.toString();
    endPageController.text = end.toString();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      dailyScore = prefs.getInt('dailyScore_${widget.userName}') ?? 0;
      weeklyScore = prefs.getInt('weeklyScore_${widget.userName}') ?? 0;
      totalScore = prefs.getInt('totalScore_${widget.userName}') ?? 0;

      String? tasksJson = prefs.getString('savedTasks_${widget.userName}');
      if (tasksJson != null) {
        List<dynamic> decoded = jsonDecode(tasksJson);
        tasks = decoded.map((item) => QuranTask.fromJson(item as Map<String, dynamic>)).toList();
=======
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      dailyScore = prefs.getInt('dailyScore') ?? 0;
      weeklyScore = prefs.getInt('weeklyScore') ?? 0;
      totalScore = prefs.getInt('totalScore') ?? 0;

      String? tasksJson = prefs.getString('savedTasks');
      if (tasksJson != null) {
        List decoded = jsonDecode(tasksJson);
        tasks = decoded.map((item) => QuranTask.fromJson(item)).toList();
>>>>>>> 9dc7ff7e6cb7fa45d3c21e35a2c259ab21891d03
      } else {
        tasks = [
          QuranTask(
            surahName: 'البقرة',
            category: 'الورد الجديد',
<<<<<<< HEAD
            fromRange: '2',
            toRange: '5',
=======
            fromRange: '1',
            toRange: '25',
>>>>>>> 9dc7ff7e6cb7fa45d3c21e35a2c259ab21891d03
            repeatCount: 1,
          ),
        ];
      }
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
<<<<<<< HEAD
    await prefs.setInt('dailyScore_${widget.userName}', dailyScore);
    await prefs.setInt('weeklyScore_${widget.userName}', weeklyScore);
    await prefs.setInt('totalScore_${widget.userName}', totalScore);

    String tasksJson = jsonEncode(tasks.map((t) => t.toJson()).toList());
    await prefs.setString('savedTasks_${widget.userName}', tasksJson);
=======
    await prefs.setInt('dailyScore', dailyScore);
    await prefs.setInt('weeklyScore', weeklyScore);
    await prefs.setInt('totalScore', totalScore);

    String tasksJson = jsonEncode(tasks.map((t) => t.toJson()).toList());
    await prefs.setString('savedTasks', tasksJson);
>>>>>>> 9dc7ff7e6cb7fa45d3c21e35a2c259ab21891d03
  }

  void _toggleTask(int index) {
    setState(() {
      tasks[index].isCompleted = !tasks[index].isCompleted;
      int points = 100 * tasks[index].repeatCount;

      if (tasks[index].isCompleted) {
        dailyScore += points;
        weeklyScore += points;
        totalScore += points;
      } else {
        dailyScore -= points;
        weeklyScore -= points;
        totalScore -= points;
      }
    });
    _saveData();
  }

  void _addNewTask() {
<<<<<<< HEAD
=======
    int repeat = int.tryParse(_repeatController.text.trim()) ?? 1;

>>>>>>> 9dc7ff7e6cb7fa45d3c21e35a2c259ab21891d03
    setState(() {
      tasks.add(QuranTask(
        surahName: selectedSurah,
        category: selectedCategory,
<<<<<<< HEAD
        fromRange: startPageController.text.trim(),
        toRange: endPageController.text.trim(),
        repeatCount: 1,
=======
        fromRange: _fromController.text.trim().isEmpty ? '1' : _fromController.text.trim(),
        toRange: _toController.text.trim().isEmpty ? '1' : _toController.text.trim(),
        repeatCount: repeat,
>>>>>>> 9dc7ff7e6cb7fa45d3c21e35a2c259ab21891d03
      ));
    });
    _saveData();
  }

  void _deleteTask(int index) {
    setState(() {
      if (tasks[index].isCompleted) {
        int points = 100 * tasks[index].repeatCount;
        dailyScore -= points;
        weeklyScore -= points;
        totalScore -= points;
      }
      tasks.removeAt(index);
    });
    _saveData();
  }

  void _resetDailyScore() {
    setState(() {
      dailyScore = 0;
      for (var t in tasks) {
        t.isCompleted = false;
      }
    });
    _saveData();
  }

  void _resetWeeklyScore() {
    setState(() {
      weeklyScore = 0;
    });
    _saveData();
  }

  List<Widget> _getBadges() {
    List<Widget> badges = [];
    if (totalScore >= 500) {
      badges.add(const Chip(avatar: Icon(Icons.shield, color: Colors.amber), label: Text('حافظ مبتدئ 🥉')));
    }
    if (totalScore >= 1500) {
      badges.add(const Chip(avatar: Icon(Icons.workspace_premium, color: Colors.blueAccent), label: Text('المواظب الفضي 🥈')));
    }
    if (totalScore >= 3000) {
      badges.add(const Chip(avatar: Icon(Icons.stars, color: Colors.amber), label: Text('بطل القرآن الذهبي 🥇')));
    }
    if (totalScore >= 5000) {
      badges.add(const Chip(avatar: Icon(Icons.king_bed, color: Colors.purpleAccent), label: Text('خاتم المتقنين 👑')));
    }
    return badges;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    bool allCompleted = tasks.isNotEmpty && tasks.every((t) => t.isCompleted);

    List<String> surahList = List.generate(
      quran.totalSurahCount,
      (index) => quran.getSurahNameArabic(index + 1),
    );
    List<Widget> activeBadges = _getBadges();

    return Scaffold(
      appBar: AppBar(
<<<<<<< HEAD
        title: Text('وِرْدي - مهام السكور لـ ${widget.userName}', style: const TextStyle(fontWeight: FontWeight.bold)),
=======
        title: const Text('المهام والسكور', style: TextStyle(fontWeight: FontWeight.bold)),
>>>>>>> 9dc7ff7e6cb7fa45d3c21e35a2c259ab21891d03
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.wb_sunny : Icons.nightlight_round),
            onPressed: () => widget.onDarkModeChanged(!widget.isDarkMode),
          ),
          ThemePopupMenu(onColorThemeChanged: widget.onColorThemeChanged, isDarkMode: widget.isDarkMode),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
<<<<<<< HEAD
                border: Border.all(color: primaryColor.withValues(alpha: 0.5)),
=======
                border: Border.all(color: primaryColor.withOpacity(0.5)),
>>>>>>> 9dc7ff7e6cb7fa45d3c21e35a2c259ab21891d03
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildScoreItem('سكور اليوم', '$dailyScore 🌟', primaryColor),
                      _buildScoreItem('سكور الأسبوع', '$weeklyScore 🏅', primaryColor),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.stars, color: Colors.amber, size: 28),
                      const SizedBox(width: 8),
                      Text(
<<<<<<< HEAD
                        'السكور الشامل: $totalScore نقطة 👑',
=======
                        'السكور التراكمي الشامل: $totalScore نقطة 👑',
>>>>>>> 9dc7ff7e6cb7fa45d3c21e35a2c259ab21891d03
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor),
                      ),
                    ],
                  ),
                  if (activeBadges.isNotEmpty) ...[
                    const Divider(height: 20),
                    const Text('الأوسمة والشارات المكتسبة:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 6),
                    Wrap(spacing: 8, children: activeBadges),
                  ]
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
<<<<<<< HEAD
                border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
=======
                border: Border.all(color: primaryColor.withOpacity(0.3)),
>>>>>>> 9dc7ff7e6cb7fa45d3c21e35a2c259ab21891d03
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
<<<<<<< HEAD
                  const Text('إضافة ورد / مهمة جديدة:', style: TextStyle(fontWeight: FontWeight.bold)),
=======
                  const Text('تحديد ورد / مهمة جديدة:', style: TextStyle(fontWeight: FontWeight.bold)),
>>>>>>> 9dc7ff7e6cb7fa45d3c21e35a2c259ab21891d03
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
<<<<<<< HEAD
                          initialValue: selectedCategory,
=======
                          value: selectedCategory,
>>>>>>> 9dc7ff7e6cb7fa45d3c21e35a2c259ab21891d03
                          decoration: const InputDecoration(labelText: 'القسم', border: OutlineInputBorder()),
                          items: const [
                            DropdownMenuItem(value: 'الورد الجديد', child: Text('الورد الجديد')),
                            DropdownMenuItem(value: 'الماضي القريب', child: Text('الماضي القريب')),
                            DropdownMenuItem(value: 'الماضي البعيد', child: Text('الماضي البعيد')),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => selectedCategory = val);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<String>(
<<<<<<< HEAD
                          initialValue: selectedSurah,
                          decoration: const InputDecoration(labelText: 'السورة', border: OutlineInputBorder()),
                          items: surahList.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                selectedSurah = val;
                                int sIndex = surahList.indexOf(val) + 1;
                                _updateSurahDefaultPages(sIndex);
                              });
                            }
=======
                          value: selectedSurah,
                          decoration: const InputDecoration(labelText: 'السورة', border: OutlineInputBorder()),
                          items: surahList.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => selectedSurah = val);
>>>>>>> 9dc7ff7e6cb7fa45d3c21e35a2c259ab21891d03
                          },
                        ),
                      ),
                    ],
                  ),
<<<<<<< HEAD
                  const SizedBox(height: 12),
=======
                  const SizedBox(height: 8),
>>>>>>> 9dc7ff7e6cb7fa45d3c21e35a2c259ab21891d03
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
<<<<<<< HEAD
                          controller: startPageController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'صفحة البداية',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: endPageController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'صفحة النهاية',
                            border: OutlineInputBorder(),
                          ),
=======
                          controller: _fromController,
                          decoration: const InputDecoration(labelText: 'من (آية/صفحة)', border: OutlineInputBorder()),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _toController,
                          decoration: const InputDecoration(labelText: 'إلى (آية/صفحة)', border: OutlineInputBorder()),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _repeatController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'التكرار', border: OutlineInputBorder()),
>>>>>>> 9dc7ff7e6cb7fa45d3c21e35a2c259ab21891d03
                        ),
                      ),
                    ],
                  ),
<<<<<<< HEAD
                  const SizedBox(height: 12),
=======
                  const SizedBox(height: 10),
>>>>>>> 9dc7ff7e6cb7fa45d3c21e35a2c259ab21891d03
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: widget.isDarkMode ? Colors.black : Colors.white,
                      ),
                      onPressed: _addNewTask,
                      icon: const Icon(Icons.add),
<<<<<<< HEAD
                      label: const Text('إضافة الورد للقائمة'),
=======
                      label: const Text('إضافة الورد'),
>>>>>>> 9dc7ff7e6cb7fa45d3c21e35a2c259ab21891d03
                    ),
                  )
                ],
              ),
            ),
<<<<<<< HEAD
            
            if (allCompleted)
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
=======
            if (allCompleted)
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
>>>>>>> 9dc7ff7e6cb7fa45d3c21e35a2c259ab21891d03
                  border: Border.all(color: primaryColor, width: 2),
                ),
                child: Column(
                  children: [
<<<<<<< HEAD
                    const Text(
                      'عاش يا وحش، خلصت مهامك كلها النهارده 💪',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'لمست $dailyScore نقطة في سكورك اليومي يا فنان، واصل وماتوقفش!',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: _resetDailyScore,
                          child: const Text('ابدأ يوم جديد 🚀'),
                        ),
                        const SizedBox(width: 10),
                        OutlinedButton(
                          onPressed: _resetWeeklyScore,
                          child: const Text('تصفير الأسبوع'),
                        ),
=======
                    const Text('🎉 مبارك! أتممت جميع مهام اليوم بنجاح 🎉', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text('حصلت اليوم على $dailyScore نقطة وتم إضافتها للسكور التراكمي الشامل!', textAlign: TextAlign.center),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(onPressed: _resetDailyScore, child: const Text('بدء يوم جديد (تصفير اليوم)')),
                        const SizedBox(width: 10),
                        OutlinedButton(onPressed: _resetWeeklyScore, child: const Text('تصفير الأسبوع')),
>>>>>>> 9dc7ff7e6cb7fa45d3c21e35a2c259ab21891d03
                      ],
                    )
                  ],
                ),
              ),
<<<<<<< HEAD

=======
>>>>>>> 9dc7ff7e6cb7fa45d3c21e35a2c259ab21891d03
            _buildCategoryTasks('الورد الجديد', primaryColor),
            _buildCategoryTasks('الماضي القريب', primaryColor),
            _buildCategoryTasks('الماضي البعيد', primaryColor),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreItem(String title, String scoreText, Color primaryColor) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(scoreText, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryColor)),
      ],
    );
  }

  Widget _buildCategoryTasks(String categoryName, Color primaryColor) {
    final categoryList = tasks.where((t) => t.category == categoryName).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 16, left: 16, top: 16, bottom: 6),
          child: Text(categoryName, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor)),
        ),
        if (categoryList.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text('لا توجد مهام حالية في هذه القائمة', style: TextStyle(color: Colors.grey)),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categoryList.length,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemBuilder: (context, index) {
              final task = categoryList[index];
              int originalIndex = tasks.indexOf(task);

              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 4),
<<<<<<< HEAD
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    children: [
                      CheckboxListTile(
                        activeColor: primaryColor,
                        checkColor: widget.isDarkMode ? Colors.black : Colors.white,
                        title: Text(
                          'سورة ${task.surahName} (صفحة ${task.fromRange} إلى ${task.toRange})',
                          style: TextStyle(
                            fontSize: 16,
                            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        subtitle: Text(task.isCompleted ? "تم الإنجاز (+100 نقطة)" : "لم تكتمل بعد"),
                        secondary: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () => _deleteTask(originalIndex),
                        ),
                        value: task.isCompleted,
                        onChanged: (val) => _toggleTask(originalIndex),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: widget.isDarkMode ? Colors.black : Colors.white,
                              minimumSize: const Size(120, 36),
                            ),
                            onPressed: () {
                              int targetPage = int.tryParse(task.fromRange) ?? 1;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MushafHorizontalViewer(
                                    initialPage: targetPage,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.play_arrow, size: 18),
                            label: const Text('بدء'),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                    ],
                  ),
=======
                child: CheckboxListTile(
                  activeColor: primaryColor,
                  checkColor: widget.isDarkMode ? Colors.black : Colors.white,
                  title: Text(
                    'سورة ${task.surahName} (${task.fromRange} - ${task.toRange})',
                    style: TextStyle(
                      fontSize: 17,
                      decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  subtitle: Text('التكرار: ${task.repeatCount} | ${task.isCompleted ? "تم الإنجاز (+${100 * task.repeatCount} نقطة)" : "لم تكتمل بعد"}'),
                  secondary: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => _deleteTask(originalIndex),
                  ),
                  value: task.isCompleted,
                  onChanged: (val) => _toggleTask(originalIndex),
>>>>>>> 9dc7ff7e6cb7fa45d3c21e35a2c259ab21891d03
                ),
              );
            },
          ),
      ],
    );
  }
}

class ThemePopupMenu extends StatelessWidget {
<<<<<<< HEAD
  final void Function(AppColorTheme) onColorThemeChanged;
=======
  final Function(AppColorTheme) onColorThemeChanged;
>>>>>>> 9dc7ff7e6cb7fa45d3c21e35a2c259ab21891d03
  final bool isDarkMode;

  const ThemePopupMenu({super.key, required this.onColorThemeChanged, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    String suffix = isDarkMode ? ' فسفوري' : '';
    return PopupMenuButton<AppColorTheme>(
      icon: const Icon(Icons.palette),
      onSelected: onColorThemeChanged,
      itemBuilder: (context) => [
        PopupMenuItem(value: AppColorTheme.green, child: Text('أخضر$suffix')),
        PopupMenuItem(value: AppColorTheme.pink, child: Text('بينك$suffix')),
        PopupMenuItem(value: AppColorTheme.blue, child: Text('أزرق$suffix')),
        PopupMenuItem(value: AppColorTheme.purple, child: Text('بنفسجي$suffix')),
      ],
    );
  }
<<<<<<< HEAD
=======
}

class SurahDetailScreen extends StatelessWidget {
  final int surahNumber;
  final String surahName;

  const SurahDetailScreen({
    super.key,
    required this.surahNumber,
    required this.surahName,
  });

  @override
  Widget build(BuildContext context) {
    int totalVerses = quran.getVerseCount(surahNumber);
    return Scaffold(
      appBar: AppBar(title: Text(surahName)),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: totalVerses,
        itemBuilder: (context, index) {
          String verseText = quran.getVerse(surahNumber, index + 1, verseEndSymbol: true);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              verseText,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, height: 2.0),
            ),
          );
        },
      ),
    );
  }
>>>>>>> 9dc7ff7e6cb7fa45d3c21e35a2c259ab21891d03
}