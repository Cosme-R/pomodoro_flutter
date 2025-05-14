import 'dart:async';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

void main() {
  runApp(PomodoroApp());
}

class PomodoroApp extends StatefulWidget {
  @override
  _PomodoroAppState createState() => _PomodoroAppState();
}

class _PomodoroAppState extends State<PomodoroApp> {
  bool isDarkTheme = false;

  void _toggleTheme(bool value) {
    setState(() {
      isDarkTheme = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pomodoro',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: isDarkTheme ? ThemeMode.dark : ThemeMode.light,
      home: PomodoroTimer(
        isDarkTheme: isDarkTheme,
        onThemeToggle: _toggleTheme,
      ),
    );
  }
}

class PomodoroTimer extends StatefulWidget {
  final bool isDarkTheme;
  final Function(bool) onThemeToggle;

  PomodoroTimer({required this.isDarkTheme, required this.onThemeToggle});

  @override
  _PomodoroTimerState createState() => _PomodoroTimerState();
}

class _PomodoroTimerState extends State<PomodoroTimer> {
  bool isRunning = false;
  int totalDuration = 25 * 60;
  int currentDuration = 25 * 60;

  Timer? timer;
  Timer? flashingTimer;
  bool isFlashing = false;
  Color backgroundColor = Colors.white;

  @override
  void dispose() {
    timer?.cancel();
    flashingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double percent = 1 - (currentDuration / totalDuration);

    return GestureDetector(
      onTap: () {
        if (isFlashing) {
          stopFlashing();
        }
      },
      child: Scaffold(
        backgroundColor:
            isFlashing
                ? backgroundColor
                : Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text('Pomodoro'),
          actions: [
            Row(
              children: [
                Icon(Icons.light_mode),
                Switch(
                  value: widget.isDarkTheme,
                  onChanged: widget.onThemeToggle,
                ),
                Icon(Icons.dark_mode),
                SizedBox(width: 12),
              ],
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircularPercentIndicator(
                radius: 200.0,
                lineWidth: 10.0,
                percent: percent.clamp(0.0, 1.0),
                center: Text(
                  formatDuration(currentDuration),
                  style: TextStyle(fontSize: 24.0),
                ),
                progressColor: const Color.fromARGB(255, 0, 38, 255),
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  if (isRunning) {
                    resetTimer();
                  } else {
                    startTimer();
                  }
                },
                child: Text(isRunning ? 'Resetar' : 'Iniciar'),
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () => _selectTime(context),
                child: Text('Definir Tempo'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void startTimer() {
    setState(() {
      isRunning = true;
    });

    timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      if (currentDuration < 1) {
        t.cancel();
        startFlashing();
      } else {
        setState(() {
          currentDuration -= 1;
        });
      }
    });
  }

  void resetTimer() {
    timer?.cancel();
    stopFlashing();
    setState(() {
      isRunning = false;
      currentDuration = totalDuration;
    });
  }

  void startFlashing() {
    setState(() {
      isFlashing = true;
    });

    flashingTimer = Timer.periodic(Duration(milliseconds: 500), (Timer t) {
      setState(() {
        backgroundColor =
            backgroundColor == Colors.red ? Colors.white : Colors.red;
      });
    });
  }

  void stopFlashing() {
    flashingTimer?.cancel();
    setState(() {
      isFlashing = false;
      backgroundColor = Colors.white;
    });
  }

  String formatDuration(int durationInSeconds) {
    int minutes = durationInSeconds ~/ 60;
    int seconds = durationInSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 0, minute: 25),
    );

    if (picked != null) {
      final int seconds = picked.hour * 3600 + picked.minute * 60;
      if (seconds > 0) {
        setState(() {
          totalDuration = seconds;
          currentDuration = seconds;
        });
      }
    }
  }
}
