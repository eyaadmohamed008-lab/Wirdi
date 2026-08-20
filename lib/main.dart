import 'package:flutter/material.dart';
import 'package:quran/quran.dart' as quran;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const QuranApp());
}

enum AppColorTheme { green, pink, blue, purple }

class QuranApp extends StatefulWidget {
  const QuranApp({super.key});

  @override
  State<QuranApp> createState() => _QuranAppState();
}

class _QuranAppState extends State<QuranApp> {
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
      isDarkMode = prefs.getBool('isDarkMode') ?? true;
      int themeIndex = prefs.getInt('colorTheme') ?? 0;
      currentColorTheme = AppColorTheme.values[themeIndex];
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode);
    await prefs.setInt('colorTheme', currentColorTheme.index);
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'تطبيق القرآن والمهام',
      theme: _getThemeData(),
      home: MainNavigationScreen(
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
  final bool isDarkMode;
  final AppColorTheme currentColorTheme;
  final Function(bool) onDarkModeChanged;
  final Function(AppColorTheme) onColorThemeChanged;

  const MainNavigationScreen({
    super.key,
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

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    final pages = [
      QuranListScreen(
        isDarkMode: widget.isDarkMode,
        currentColorTheme: widget.currentColorTheme,
        onDarkModeChanged: widget.onDarkModeChanged,
        onColorThemeChanged: widget.onColorThemeChanged,
      ),
      TasksScreen(
        isDarkMode: widget.isDarkMode,
        currentColorTheme: widget.currentColorTheme,
        onDarkModeChanged: widget.onDarkModeChanged,
        onColorThemeChanged: widget.onColorThemeChanged,
      ),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'المصحف'),
          BottomNavigationBarItem(icon: Icon(Icons.task_alt), label: 'المهام والسكور'),
        ],
      ),
    );
  }
}

class QuranListScreen extends StatelessWidget {
  final bool isDarkMode;
  final AppColorTheme currentColorTheme;
  final Function(bool) onDarkModeChanged;
  final Function(AppColorTheme) onColorThemeChanged;

  const QuranListScreen({
    super.key,
    required this.isDarkMode,
    required this.currentColorTheme,
    required this.onDarkModeChanged,
    required this.onColorThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
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
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SurahDetailScreen(
                      surahNumber: surahNumber,
                      surahName: surahName,
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
  final bool isDarkMode;
  final AppColorTheme currentColorTheme;
  final Function(bool) onDarkModeChanged;
  final Function(AppColorTheme) onColorThemeChanged;

  const TasksScreen({
    super.key,
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
  final TextEditingController _fromController = TextEditingController(text: '1');
  final TextEditingController _toController = TextEditingController(text: '10');
  final TextEditingController _repeatController = TextEditingController(text: '1');

  List<QuranTask> tasks = [];

  @override
  void initState() {
    super.initState();
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
      } else {
        tasks = [
          QuranTask(
            surahName: 'البقرة',
            category: 'الورد الجديد',
            fromRange: '1',
            toRange: '25',
            repeatCount: 1,
          ),
        ];
      }
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('dailyScore', dailyScore);
    await prefs.setInt('weeklyScore', weeklyScore);
    await prefs.setInt('totalScore', totalScore);

    String tasksJson = jsonEncode(tasks.map((t) => t.toJson()).toList());
    await prefs.setString('savedTasks', tasksJson);
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
    int repeat = int.tryParse(_repeatController.text.trim()) ?? 1;

    setState(() {
      tasks.add(QuranTask(
        surahName: selectedSurah,
        category: selectedCategory,
        fromRange: _fromController.text.trim().isEmpty ? '1' : _fromController.text.trim(),
        toRange: _toController.text.trim().isEmpty ? '1' : _toController.text.trim(),
        repeatCount: repeat,
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
        title: const Text('المهام والسكور', style: TextStyle(fontWeight: FontWeight.bold)),
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
                border: Border.all(color: primaryColor.withOpacity(0.5)),
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
                        'السكور التراكمي الشامل: $totalScore نقطة 👑',
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
                border: Border.all(color: primaryColor.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('تحديد ورد / مهمة جديدة:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedCategory,
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
                          value: selectedSurah,
                          decoration: const InputDecoration(labelText: 'السورة', border: OutlineInputBorder()),
                          items: surahList.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => selectedSurah = val);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
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
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: widget.isDarkMode ? Colors.black : Colors.white,
                      ),
                      onPressed: _addNewTask,
                      icon: const Icon(Icons.add),
                      label: const Text('إضافة الورد'),
                    ),
                  )
                ],
              ),
            ),
            if (allCompleted)
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: primaryColor, width: 2),
                ),
                child: Column(
                  children: [
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
                ),
              );
            },
          ),
      ],
    );
  }
}

class ThemePopupMenu extends StatelessWidget {
  final Function(AppColorTheme) onColorThemeChanged;
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
}