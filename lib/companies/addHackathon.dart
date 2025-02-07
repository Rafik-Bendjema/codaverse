import 'package:flutter/material.dart';
import 'package:gdg_hack/backend/hachathon_db.dart';
import 'package:gdg_hack/models/Hackathon.dart';
import 'package:gdg_hack/models/Team.dart';

class AddHackathon extends StatefulWidget {
  const AddHackathon({super.key});

  @override
  State<AddHackathon> createState() => _AddHackathonState();
}

class _AddHackathonState extends State<AddHackathon> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _maxTeamsController = TextEditingController();
  final HackathonDb _hackathonDb = FirestoreHackathonDb();
  String? companyId = "K8TjpA9J6HogJEXaMLwG";
  String status = "Upcoming";
  List<Team> teams = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _maxTeamsController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      Hackathon hackathon = Hackathon(
        name: _nameController.text,
        companyId: "K8TjpA9J6HogJEXaMLwG",
        maxTeams: int.parse(_maxTeamsController.text),
        status: status,
        teams: teams,
      );
      print("done here is the hackathon ${hackathon.toMap()}");
      //add the hackathon
      bool result = await _hackathonDb.addHackathon(hackathon);
      if (result) {
        print("------------------------------done--------------------------");
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => AddHackathon()));
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Operation Failed"),
            content: const Text("Something went wrong. Please try again."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Hackathon")),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Hackathon Name", style: TextStyle(fontSize: 16)),
              TextFormField(
                controller: _nameController,
                validator: (value) =>
                    value!.isEmpty ? "Enter hackathon name" : null,
              ),
              const SizedBox(height: 10),
              Text("Max Teams", style: TextStyle(fontSize: 16)),
              TextFormField(
                controller: _maxTeamsController,
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? "Enter max teams" : null,
              ),
              const SizedBox(height: 10),
              Text("Status", style: TextStyle(fontSize: 16)),
              DropdownButton<String>(
                value: status,
                items: ["Upcoming", "Ongoing", "Completed"].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newStatus) {
                  setState(() {
                    status = newStatus!;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: Text("Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
