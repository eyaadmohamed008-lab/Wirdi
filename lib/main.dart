import 'package:flutter/material.dart';
import 'package:quran/quran.dart' as quran;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:convert';
import 'dart:async';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WirdyApp());
}

enum AppColorTheme { green, pink, blue, purple }

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
      isDarkMode = prefs.getBool('isDarkMode_${widget.userName}') ?? true;
      int themeIndex = prefs.getInt('colorTheme_${widget.userName}') ?? 0;
      currentColorTheme = AppColorTheme.values[themeIndex];
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode_${widget.userName}', isDarkMode);
    await prefs.setInt('colorTheme_${widget.userName}', currentColorTheme.index);
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
    return Theme(
      data: _getThemeData(),
      child: MainNavigationScreen(
        userName: widget.userName,
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
  final String userName;
  final bool isDarkMode;
  final AppColorTheme currentColorTheme;
  final Function(bool) onDarkModeChanged;
  final Function(AppColorTheme) onColorThemeChanged;

  const MainNavigationScreen({
    super.key,
    required this.userName,
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

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    final pages = [
      QuranPagesListScreen(
        userName: widget.userName,
        isDarkMode: widget.isDarkMode,
        currentColorTheme: widget.currentColorTheme,
        onDarkModeChanged: widget.onDarkModeChanged,
        onColorThemeChanged: widget.onColorThemeChanged,
      ),
      TasksScreen(
        userName: widget.userName,
        isDarkMode: widget.isDarkMode,
        currentColorTheme: widget.currentColorTheme,
        onDarkModeChanged: widget.onDarkModeChanged,
        onColorThemeChanged: widget.onColorThemeChanged,
      ),
    ];

    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
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
          BottomNavigationBarItem(icon: Icon(Icons.task_alt), label: 'المهام والسكور'),
        ],
      ),
    );
  }
}

class QuranPagesListScreen extends StatefulWidget {
  final String userName;
  final bool isDarkMode;
  final AppColorTheme currentColorTheme;
  final Function(bool) onDarkModeChanged;
  final Function(AppColorTheme) onColorThemeChanged;

  const QuranPagesListScreen({
    super.key,
    required this.userName,
    required this.isDarkMode,
    required this.currentColorTheme,
    required this.onDarkModeChanged,
    required this.onColorThemeChanged,
  });

  @override
  State<QuranPagesListScreen> createState() => _QuranPagesListScreenState();
}

class _QuranPagesListScreenState extends State<QuranPagesListScreen> {
  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
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
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MushafRestrictedViewer(
                      fromPage: startPage,
                      toPage: endPage,
                      initialPage: startPage,
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

class MushafRestrictedViewer extends StatefulWidget {
  final int fromPage;
  final int toPage;
  final int initialPage;

  const MushafRestrictedViewer({
    super.key,
    required this.fromPage,
    required this.toPage,
    required this.initialPage,
  });

  @override
  State<MushafRestrictedViewer> createState() => _MushafRestrictedViewerState();
}

class _MushafRestrictedViewerState extends State<MushafRestrictedViewer> {
  late PageController _pageController;
  late int currentPage;
  bool isPlaying = false;
  bool isLoadingAudio = false;
  late AudioPlayer _audioPlayer;
  
  // روابط سيرفرات القراء المحدثة والمستقرة 100%
  String selectedReciterUrl = 'https://server8.mp3quran.net/afs/';

  final Map<String, String> reciters = {
    'الشيخ مشاري راشد العفاسي': 'https://server8.mp3quran.net/afs/',
    'الشيخ عبد الباسط عبد الصمد': 'https://server7.mp3quran.net/abdulsamad/Rewayat-Hafs-A-n-Assem/',
    'الشيخ محمود خليل الحصري': 'https://server13.mp3quran.net/husr/',
    'الشيخ محمد صديق المنشاوي': 'https://server10.mp3quran.net/minsh/',
    'الشيخ ماهر المعقيلي': 'https://server12.mp3quran.net/maher/',
    'الشيخ عبد الرحمن السديس': 'https://server11.mp3quran.net/sds/',
    'الشيخ سعد الغامدي': 'https://server7.mp3quran.net/salam/',
    'الشيخ أبو بكر الشاطري': 'https://server11.mp3quran.net/shatri/',
    'الشيخ ياسر الدوسري': 'https://server11.mp3quran.net/yasser/',
  };

  late List<int> pagesList;

  @override
  void initState() {
    super.initState();
    int start = widget.fromPage <= widget.toPage ? widget.fromPage : widget.toPage;
    int end = widget.fromPage <= widget.toPage ? widget.toPage : widget.fromPage;
    
    pagesList = List.generate(end - start + 1, (index) => start + index);
    
    currentPage = pagesList.contains(widget.initialPage) ? widget.initialPage : start;
    int initialIndex = pagesList.indexOf(currentPage);

    _pageController = PageController(initialPage: initialIndex);

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

  String _formatSurahNumber(int surahNum) {
    return surahNum.toString().padLeft(3, '0');
  }

  // تشغيل تلاوة السورة التي تبدأ أو تتواجد في الصفحة الحالية بدقة تامة
  Future<void> _togglePlayAudio() async {
    if (isPlaying) {
      await _audioPlayer.pause();
    } else {
      setState(() => isLoadingAudio = true);
      try {
        final rawPageData = quran.getPageData(currentPage);
        int currentSurah = int.parse(rawPageData[0]['surah'].toString());
        
        String audioUrl = '$selectedReciterUrl${_formatSurahNumber(currentSurah)}.mp3';
        
        await _audioPlayer.stop();
        await _audioPlayer.play(UrlSource(audioUrl));
      } catch (e) {
        if (mounted) {
          setState(() => isLoadingAudio = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تعذر تشغيل الصوت، تأكد من اتصال الإنترنت')),
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

  Widget _buildPageContent(int pageNum, Color primaryColor) {
    List<Widget> pageElements = [];
    
    try {
      final rawPageData = quran.getPageData(pageNum);
      List<Map<String, int>> versesOnPage = rawPageData.map((verse) {
        return {
          'surah': int.parse(verse['surah'].toString()),
          'start': int.parse(verse['start'].toString()),
          'end': int.parse(verse['end'].toString()),
        };
      }).toList();

      int currentSurah = -1;

      for (var verse in versesOnPage) {
        int surah = verse['surah']!;
        int ayah = verse['start']!;

        if (surah != currentSurah) {
          currentSurah = surah;
          String surahName = quran.getSurahNameArabic(surah);
          
          pageElements.add(
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(vertical: 12),
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
          );

          if (surah != 9 && surah != 1 && ayah == 1) {
            pageElements.add(
              const Padding(
                padding: EdgeInsets.only(bottom: 10.0),
                child: Center(
                  child: Text(
                    'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                    style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            );
          }
        }
      }

      StringBuffer pageTextBuffer = StringBuffer();
      for (var verseData in versesOnPage) {
        int surah = verseData['surah']!;
        int startAyah = verseData['start']!;
        int endAyah = verseData['end']!;

        for (int i = startAyah; i <= endAyah; i++) {
          String ayahText = quran.getVerse(surah, i);
          pageTextBuffer.write('$ayahText ﴿$i﴾ ');
        }
      }

      // تحديد النصوص وقراءتها بسلاسة تامة
      pageElements.add(
        SelectableText(
          pageTextBuffer.toString(),
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.justify,
          style: const TextStyle(
            fontSize: 22,
            fontFamily: 'Amiri',
            height: 2.2,
            color: Colors.white,
          ),
        ),
      );

    } catch (e) {
      pageElements.add(const Text('عذراً، حدث خطأ في تحميل هذه الصفحة', style: TextStyle(color: Colors.white)));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: pageElements,
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          tooltip: 'إنهاء الورد والرجوع',
        ),
        title: Text('ورد الصفحات: ($currentPage) [من ${widget.fromPage} إلى ${widget.toPage}]'),
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
                  tooltip: 'تشغيل تلاوة الوجه الحالي',
                ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: pagesList.length,
                key: const PageStorageKey('mushaf_page_view'),
                onPageChanged: (index) async {
                  if (isPlaying) {
                    await _audioPlayer.stop();
                  }
                  setState(() {
                    currentPage = pagesList[index];
                  });
                },
                itemBuilder: (context, index) {
                  int pageNum = pagesList[index];

                  return SingleChildScrollView(
                    key: ValueKey('page_$pageNum'),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
                      ),
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
            Container(
              padding: const EdgeInsets.all(12),
              color: const Color(0xFF1E1E1E),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.exit_to_app),
                  label: const Text('إنهاء جلسة الورد والخروج'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
  final String userName;
  final bool isDarkMode;
  final AppColorTheme currentColorTheme;
  final Function(bool) onDarkModeChanged;
  final Function(AppColorTheme) onColorThemeChanged;

  const TasksScreen({
    super.key,
    required this.userName,
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
  
  final TextEditingController startPageController = TextEditingController(text: '1');
  final TextEditingController endPageController = TextEditingController(text: '1');

  List<QuranTask> tasks = [];

  @override
  void initState() {
    super.initState();
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
    String? lastSavedDate = prefs.getString('last_saved_date_${widget.userName}');

    int loadedDailyScore = prefs.getInt('dailyScore_${widget.userName}') ?? 0;
    int loadedWeeklyScore = prefs.getInt('weeklyScore_${widget.userName}') ?? 0;
    int loadedTotalScore = prefs.getInt('totalScore_${widget.userName}') ?? 0;

    String? tasksJson = prefs.getString('savedTasks_${widget.userName}');
    if (tasksJson != null) {
      List<dynamic> decoded = jsonDecode(tasksJson);
      tasks = decoded.map((item) => QuranTask.fromJson(item as Map<String, dynamic>)).toList();
    } else {
      tasks = [
        QuranTask(
          surahName: 'البقرة',
          category: 'الورد الجديد',
          fromRange: '2',
          toRange: '5',
          repeatCount: 1,
        ),
      ];
    }

    if (lastSavedDate != null) {
      DateTime lastDate = DateTime.parse(lastSavedDate);
      DateTime currentDate = DateTime.now();

      if (currentDate.year != lastDate.year || currentDate.month != lastDate.month || currentDate.day != lastDate.day) {
        loadedDailyScore = 0;
        for (var t in tasks) {
          t.isCompleted = false;
        }
      }

      if (currentDate.difference(lastDate).inDays >= 7) {
        loadedWeeklyScore = 0;
      }
    }

    setState(() {
      dailyScore = loadedDailyScore;
      weeklyScore = loadedWeeklyScore;
      totalScore = loadedTotalScore;
    });

    _saveData();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    String todayStr = DateTime.now().toIso8601String().substring(0, 10);
    
    await prefs.setString('last_saved_date_${widget.userName}', todayStr);
    await prefs.setInt('dailyScore_${widget.userName}', dailyScore);
    await prefs.setInt('weeklyScore_${widget.userName}', weeklyScore);
    await prefs.setInt('totalScore_${widget.userName}', totalScore);

    String tasksJson = jsonEncode(tasks.map((t) => t.toJson()).toList());
    await prefs.setString('savedTasks_${widget.userName}', tasksJson);
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
    setState(() {
      tasks.add(QuranTask(
        surahName: selectedSurah,
        category: selectedCategory,
        fromRange: startPageController.text.trim(),
        toRange: endPageController.text.trim(),
        repeatCount: 1,
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
        title: Text('وِرْدي - مهام السكور لـ ${widget.userName}', style: const TextStyle(fontWeight: FontWeight.bold)),
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
                border: Border.all(color: primaryColor.withValues(alpha: 0.5)),
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
                        'السكور الشامل: $totalScore نقطة 👑',
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
                border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('إضافة ورد / مهمة جديدة:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: selectedCategory,
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
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: widget.isDarkMode ? Colors.black : Colors.white,
                      ),
                      onPressed: _addNewTask,
                      icon: const Icon(Icons.add),
                      label: const Text('إضافة الورد للقائمة'),
                    ),
                  )
                ],
              ),
            ),
            if (allCompleted)
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: primaryColor, width: 2),
                ),
                child: Column(
                  children: [
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
                      ],
                    )
                  ],
                ),
              ),
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
                              int fromP = int.tryParse(task.fromRange) ?? 1;
                              int toP = int.tryParse(task.toRange) ?? fromP;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MushafRestrictedViewer(
                                    fromPage: fromP,
                                    toPage: toP,
                                    initialPage: fromP,
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
                ),
              );
            },
          ),
      ],
    );
  }
}

class ThemePopupMenu extends StatelessWidget {
  final void Function(AppColorTheme) onColorThemeChanged;
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
}