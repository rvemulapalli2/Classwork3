import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    theme: ThemeData(
      primarySwatch: Colors.blue,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
    home: DigitalPetApp(),
  ));
}

class DigitalPetApp extends StatefulWidget {
  @override
  _DigitalPetAppState createState() => _DigitalPetAppState();
}

class _DigitalPetAppState extends State<DigitalPetApp> {
  String petName = "Your Pet";
  int happinessLevel = 50;
  int hungerLevel = 50;
  int secondsLeft = 30; // Timer for the next hunger increase
  Timer? hungerTimer;
  Timer? countdownTimer;
  bool gameOver = false;

  @override
  void initState() {
    super.initState();
    _startHungerTimer();
    _startCountdown();
  }

  @override
  void dispose() {
    hungerTimer?.cancel();
    countdownTimer?.cancel();
    super.dispose();
  }

  void _startHungerTimer() {
    hungerTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      if (!gameOver) {
        setState(() {
          hungerLevel = (hungerLevel + 5).clamp(0, 100);
          if (hungerLevel >= 100 && happinessLevel <= 10) {
            _showGameOverDialog();
          }
        });
      }
    });
  }

  void _startCountdown() {
    countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (secondsLeft > 0) {
          secondsLeft--;
        } else {
          secondsLeft = 30;
        }
      });
    });
  }

  void _playWithPet() {
    setState(() {
      happinessLevel = (happinessLevel + 10).clamp(0, 100);
      _updateHunger();
    });
  }

  void _feedPet() {
    setState(() {
      hungerLevel = (hungerLevel - 10).clamp(0, 100);
      _updateHappiness();
    });
  }

  void _updateHappiness() {
    if (hungerLevel < 30) {
      happinessLevel = (happinessLevel - 20).clamp(0, 100);
    } else {
      happinessLevel = (happinessLevel + 10).clamp(0, 100);
    }
    if (hungerLevel >= 100 && happinessLevel <= 10) {
      _showGameOverDialog();
    }
  }

  void _updateHunger() {
    hungerLevel = (hungerLevel + 5).clamp(0, 100);
    if (hungerLevel >= 100) {
      happinessLevel = (happinessLevel - 20).clamp(0, 100);
      if (hungerLevel >= 100 && happinessLevel <= 10) {
        _showGameOverDialog();
      }
    }
  }

  void _showGameOverDialog() {
    gameOver = true;
    hungerTimer?.cancel();
    countdownTimer?.cancel();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Game Over"),
          content: Text("Your pet is too hungry and unhappy!"),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetGame();
              },
              child: Text("Restart"),
            ),
          ],
        );
      },
    );
  }

  void _resetGame() {
    setState(() {
      petName = "Your Pet";
      happinessLevel = 50;
      hungerLevel = 50;
      gameOver = false;
      secondsLeft = 30;
    });
    _startHungerTimer();
    _startCountdown();
  }

  Color _getPetColor() {
    if (happinessLevel > 70) {
      return Colors.green;
    } else if (happinessLevel >= 30 && happinessLevel <= 70) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
  }

  String _getMoodEmoji() {
    if (happinessLevel > 70) {
      return "😊"; // Happy
    } else if (happinessLevel >= 30 && happinessLevel <= 70) {
      return "😐"; // Neutral
    } else {
      return "😢"; // Unhappy
    }
  }

  void _setCustomName(String name) {
    setState(() {
      petName = name.isNotEmpty ? name : "Your Pet";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Digital Pet'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              AnimatedContainer(
                width: 200,
                height: 200,
                color: _getPetColor(),
                duration: Duration(milliseconds: 500),
                child: Center(
                  child: Text(
                    _getMoodEmoji(),
                    style: TextStyle(fontSize: 50),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Name: $petName',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 20),
              Text(
                'Mood: ${_getMoodEmoji()}',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 20),
              Text(
                'Happiness Level: $happinessLevel',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 20),
              Text(
                'Hunger Level: $hungerLevel',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 40),
              Text(
                'Next hunger increase in: $secondsLeft seconds',
                style: TextStyle(fontSize: 20, color: Colors.red),
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: _playWithPet,
                child: Text('Play with Your Pet'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _feedPet,
                child: Text('Feed Your Pet'),
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  _showNameInputDialog(context);
                },
                child: Text('Set Custom Name'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNameInputDialog(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Set Pet Name"),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(hintText: "Enter pet name"),
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                _setCustomName(nameController.text);
                Navigator.of(context).pop();
              },
              child: Text("Confirm"),
            ),
          ],
        );
      },
    );
  }
}
