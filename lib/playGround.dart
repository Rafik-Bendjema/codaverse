import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:gdg_hack/game.dart';

import 'models/Hackathon.dart';

class Playground extends StatefulWidget {
  Hackathon hackathon;
  Playground({super.key, required this.hackathon});

  @override
  State<Playground> createState() => _PlaygroundState();
}

class _PlaygroundState extends State<Playground> {
  late Hackathon _hackathon;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _hackathon = widget.hackathon;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              SizedBox(
                height: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Center(child: Text(_hackathon.name)),
                    IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.notifications,
                          color: Colors.purpleAccent,
                        ))
                  ],
                ),
              ),
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GameWidget(game: Codavers(hackathon: _hackathon)),
              ))
            ],
          ),
        ),
      ),
    );
  }
}
