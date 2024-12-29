import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart'; // Add this package in pubspec.yaml
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("ScoreDash"),
          centerTitle: true,
        ),
        body: MYSCORER(),
      ),
    );
  }
}

class MYSCORER extends StatefulWidget {
  @override
  Counter createState() => Counter();
}

class Counter extends State<MYSCORER> {
  TextEditingController Team1 = TextEditingController();
  TextEditingController Team2 = TextEditingController();
  TextEditingController emailController = TextEditingController(); // Email controller

  void navigateToScoreBoard(BuildContext context) {
    String team1Name = Team1.text;
    String team2Name = Team2.text;
    String email = emailController.text; // Get email from controller

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScoreBoardPage(
          team1Name: team1Name,
          team2Name: team2Name,
          email: email, // Pass email to ScoreBoardPage
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage('https://media.istockphoto.com/id/1468296537/vector/seamless-camouflaged-black-grunge-textures-wallpaper-background.jpg?s=612x612&w=0&k=20&c=Sc3auzDoYX7wt01KphLYfWqIvtRpyzfjvAB6PPZRK0U='),
          fit: BoxFit.cover,
        ),
      ),
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 20),
          TextField(
            controller: Team1,
            decoration: InputDecoration(
              labelText: "Team 1",
              hintText: "Enter Your First Team name",
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16),
          TextField(
            controller: Team2,
            decoration: InputDecoration(
              labelText: "Team 2",
              hintText: "Enter Your Second Team name",
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16),
          TextField(
            controller: emailController, // Email text field
            decoration: InputDecoration(
              labelText: "Email Address",
              hintText: "Enter Your Email to Receive Match Results",
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => navigateToScoreBoard(context),
            child: Text("Let's Start"),
          ),
        ],
      ),
    );
  }
}

class ScoreBoardPage extends StatefulWidget {
  final String team1Name;
  final String team2Name;
  final String email; // Add email parameter

  ScoreBoardPage({required this.team1Name, required this.team2Name, required this.email});

  @override
  _ScoreBoardPageState createState() => _ScoreBoardPageState();
}

class _ScoreBoardPageState extends State<ScoreBoardPage> {
  int team1Score = 0;
  int team2Score = 0;

  // Confetti controller for celebration
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: Duration(seconds: 3));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  // Function to send email after match is finished
  void sendEmail(String winner) async {
    String username = 'sivagurusepak@gmail.com'; // Replace with your email
    String password = 'mpwr sazn dbtz yvna'; // Replace with your App Password (not your email password)

    final smtpServer = gmail(username, password);

    final message = Message()
      ..from = Address(username, 'ScoreDash')
      ..recipients.add(widget.email) // Send to entered email
      ..subject = 'Match Result: ${widget.team1Name} vs ${widget.team2Name}'
      ..text = 'Match Result:\n\n${widget.team1Name}: $team1Score\n${widget.team2Name}: $team2Score\n\nWinner: $winner';

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
    } catch (e) {
      print('Message not sent.');
      print('Error: $e');
    }
  }

  void checkWinner() {
    String winner = '';
    if (team1Score == 15 && team2Score < 14) {
      winner = "${widget.team1Name} Wins!";
    } else if (team2Score == 15 && team1Score < 14) {
      winner = "${widget.team2Name} Wins!";
    } else if (team1Score == 17 && team2Score >= 14) {
      winner = "${widget.team1Name} Wins!";
    } else if (team2Score == 17 && team1Score >= 14) {
      winner = "${widget.team2Name} Wins!";
    }

    if (winner.isNotEmpty) {
      _showWinnerDialog(winner);
      sendEmail(winner); // Send email when a winner is declared
    }
  }

  void _showWinnerDialog(String winner) {
    _confettiController.play(); // Play confetti when winner is announced

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        content: Stack(
          children: [
            Positioned.fill(
              child: Image.network(
                '', // Add an image URL here
                fit: BoxFit.cover,
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    winner,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Congratulations on your win",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _confettiController.stop(); // Stop confetti after dialog is dismissed
            },
            child: Text("OK", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void resetScores() {
    setState(() {
      team1Score = 0;
      team2Score = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Score Board"),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage('https://t3.ftcdn.net/jpg/08/68/63/94/240_F_868639441_p8jNHlxVrAz81wkej1V3gtbFVQkPAHYb.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  Text(
                    "Teams",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        "${widget.team1Name}: $team1Score",
                        style: TextStyle(fontSize: 18),
                      ),
                      Text(
                        "${widget.team2Name}: $team2Score",
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                  SizedBox(height: 32),
                  Text(
                    "Points Dashboard",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            team1Score++;
                            checkWinner(); // Check winner after increment
                          });
                        },
                        child: Text("POINT TO TEAM A"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            team2Score++;
                            checkWinner(); // Check winner after increment
                          });
                        },
                        child: Text("POINT TO TEAM B"),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: resetScores,
                    child: Text("Reset Scores"),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: [Colors.red, Colors.blue, Colors.green, Colors.yellow],
              ),
            ),
          ],
        ),
      ),
    );
  }
}