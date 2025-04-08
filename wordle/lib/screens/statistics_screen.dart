/// ===============================================================================================
/// File: statistics_screen.dart
///
/// Author: Emmanuel Taylor
/// Created: April 8, 2025
///
/// Description:
///  - Displays gameplay statistics and a calendar view of the user’s puzzle streak.
///  - Moved all stat-related data from the Profile screen to this dedicated screen.
///
/// Dependencies:
///  - dart:convert: Conversion between JSON and other data representations.
///  - flutter/material.dart: Core Flutter UI toolkit.
///  - flutter_dotenv/flutter_dotenv.dart: Loads environment variables from a `.env` file.
///  - http/http.dart: Handles network requests to backend.
///  - provider/provider.dart: State management for settings and authentication.
///  - wordle/providers/auth_provider.dart: Authentication implementations.
///  - wordle/utils/*: Implementations for navigation, settings and snackbar helpers.
///  - wordle/widgets/app_bar.dart: Implementation for app bar.
/// ===============================================================================================
library;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:wordle/providers/auth_provider.dart';
import 'package:wordle/utils/auth_helper.dart';
import 'package:wordle/utils/settings_helper.dart';
import 'package:wordle/utils/snackbar_helper.dart';
import 'package:wordle/widgets/app_bar.dart';

/// [StatisticScreen] is a widget that is used to display user statistics
/// and a calendar streak overview.
class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

/// [_StatisticsScreenState] is a state class that manages statistics fetching,
/// loading state, and UI rendering.
class _StatisticsScreenState extends State<StatisticsScreen> {
  // Statistics that are pulled from the backend.
  int? _totalGames;
  int? _wins;
  int? _maxStreak;
  double? _winRate;
  double? _avgGuesses;

  // Calendar streak data.
  Set<DateTime> _streakDates = {};

  // Flag for showing the loading spinner.
  bool _isLoading = true;

  // Base API URL loaded from the .env file.
  final  baseUrl = dotenv.env['API_BASE_URL'];

  /// Triggers data fetch on widget mount.
  @override
  void initState() {
    super.initState();
    _fetchStats();
    _fetchCalendarStreak();
  }

  /// Calls the /api/auth/profile endpoint to retrieve statistical 
  /// data for current user.
  Future<void> _fetchStats() async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    final uri = Uri.parse("$baseUrl:3000/api/auth/profile");

    try {
      final res = await http.get(uri, headers: {
        'Authorization': 'Bearer $token',
      });

      if (res.statusCode == 200) {
        // Parse statistical data from backend server response and updates the state.
        final data = jsonDecode(res.body);
        setState(() {
          _totalGames = data['totalGames'];
          _wins = data['wins'];
          _winRate = double.tryParse(data['winRate'].toString()) ?? 0.0;
          _avgGuesses = double.tryParse(data['avgGuesses'].toString()) ?? 0.0;
          _maxStreak = data['maxStreak'];
          _isLoading = false;
        });
      } else {
        debugPrint('[STATISTICS] Failed Loading Statistics');
        if (!mounted) return;
        showSnackBar(context, "Failed to Load Statistics", isError: true);
      }
    } catch (e) {
      debugPrint('[STATISTICS] Error Loading Statistics: $e');
      if (!mounted) return;
      showSnackBar(context, "Error Loading Statistics", isError: true);
    }
  }

  Future<void> _fetchCalendarStreak() async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    final uri = Uri.parse("$baseUrl:3000/api/puzzle/calendar");

    try {
      final res = await http.get(uri, headers: {
        'Authorization': 'Bearer $token',
      });

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final List<dynamic> dateStrings = data['streakDates'];
        final parsedDates = dateStrings.map((d) => DateTime.parse(d)).toSet();
        setState(() {
          _streakDates = parsedDates;
        });
      } else {
        debugPrint("[CALENDAR] Response Code: ${res.statusCode}");
        debugPrint("[CALENDAR] Body: ${res.body}");
        if (!mounted) return;
        showSnackBar(context, "Failed to Load Streak Calendar", isError: true);
      }
    } catch (e) {
      debugPrint("[CALENDAR] Fetch Error: $e");
      if (!mounted) return;
      showSnackBar(context, "Network Error", isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Builds UI.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Reusable AppBar widget.
      appBar: buildAppBar(
        context: context,
        title: "Statistics",
        onSettingsPressed: () => showModalBottomSheet(
          context: context,
          builder: (_) => buildSettingsSheet(context),
        ),
        onLogoutPressed: () => handleLogout(context),
      ),

      // Shows spinner or screen content.
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.bar_chart_rounded, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            "Your Statistics",
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),                      
                      const SizedBox(height: 16),

                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          _buildStatCard("Games Played", _totalGames?.toString() ?? "0"),
                          _buildStatCard("Wins", _wins?.toString() ?? "0"),
                          _buildStatCard("Win Rate", "${_winRate?.toStringAsFixed(1)}%"),
                          _buildStatCard("Avg Guesses", _avgGuesses?.toStringAsFixed(1) ?? "0.0"),
                          _buildStatCard("Max Streak", _maxStreak?.toString() ?? "0"),
                        ],
                      ),

                      const SizedBox(height: 32),

                      Row(
                        children: [
                          const Icon(Icons.calendar_month_outlined, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            "Streak Calendar",
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      _buildHeatmapCalendar(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  /// Builds a reusable statistics card with labels and values.
  Widget _buildStatCard(String label, String value) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            blurRadius: 4,
            color: Colors.black12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildHeatmapCalendar() {
    final now = DateTime.now();
    final firstOfMonth = DateTime(now.year, now.month, 1);
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final startWeekday = firstOfMonth.weekday % 7; // Sunday = 0
    final totalCells = ((startWeekday + daysInMonth) / 7).ceil() * 7;

    List<Widget> daySquares = [];

    for (int i = 0; i < totalCells; i++) {
      DateTime? currentDate;
      if (i >= startWeekday && i < startWeekday + daysInMonth) {
        final day = i - startWeekday + 1;
        currentDate = DateTime(now.year, now.month, day);
      }

      final iso = currentDate != null
        ? currentDate.toIso8601String().split("T")[0]
        : null;

      final isActive = currentDate != null && _streakDates.any(
        (d) => d.year == currentDate!.year && d.month == currentDate.month && d.day == currentDate.day
      );
      final level = isActive ? (currentDate.day % 4) + 1 : 0;

      Color getColor(int level) {
        switch (level) {
          case 1: return Colors.green.shade200;
          case 2: return Colors.green.shade400;
          case 3: return Colors.green.shade600;
          case 4: return Colors.green.shade800;
          default: return Colors.grey.shade300;
        }
      }

      daySquares.add(
        Tooltip(
          message: iso ?? '',
          child: Container(
            width: 30,
            height: 30,
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: getColor(level),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(
                currentDate?.day.toString() ?? '',
                style: TextStyle(
                  fontSize: 20,
                  color: level > 0 ? Colors.white : Colors.black54,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${_monthName(now.month)} ${now.year}",
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'].map((d) {
            return Expanded(
              child: Center(child: Text(d, style: TextStyle(fontWeight: FontWeight.bold))),
            );
          }).toList(),
        ),
        const SizedBox(height: 4),
        GridView.count(
          shrinkWrap: true,
          crossAxisCount: 7,
          physics: const NeverScrollableScrollPhysics(),
          children: daySquares,
        ),
      ],
    );
  }

  String _monthName(int month) {
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month];
  }
}