import 'package:flutter/material.dart';
import 'package:gdg_hack/backend/hachathon_db.dart';
import 'package:gdg_hack/companyHackathons.dart';
import 'package:gdg_hack/models/Hackathon.dart';
import 'package:gdg_hack/models/Team.dart';
import 'package:gdg_hack/models/UserModel.dart'; // Import UserModel

import '../auth/authService.dart';

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
  String? companyId;
  String status = "Upcoming";
  List<Team> teams = [];
  List<UserModel> _availableMentors = []; // Use UserModel here
  final List<String> _selectedMentorIds = [];
  bool _isLoadingMentors = true;

  @override
  void initState() {
    super.initState();
    _loadMentors();
  }

  Future<void> _loadMentors() async {
    setState(() {
      _isLoadingMentors = true;
    });
    try {
      List<UserModel> mentors = await _hackathonDb
          .getUsersByType("mentor"); // Fetch UserModel mentors
      setState(() {
        _availableMentors = mentors;
        _isLoadingMentors = false;
      });
    } catch (e) {
      print("Error loading mentors: $e");
      setState(() {
        _isLoadingMentors = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _maxTeamsController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? uid = prefs.getString("uid");
      Hackathon hackathon = Hackathon(
        name: _nameController.text,
        mentors: _selectedMentorIds,
        companyId: uid ?? "unknown",
        maxTeams: int.parse(_maxTeamsController.text),
        status: status,
        teams: teams,
      );
      print("done here is the hackathon ${hackathon.toMap()}");
      //add the hackathon
      bool result = await _hackathonDb.addHackathon(hackathon);
      if (result) {
        print("------------------------------done--------------------------");
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => const CompanyHackathonsPage()));
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

  void _onMentorSelectionChanged(String mentorId, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedMentorIds.add(mentorId);
      } else {
        _selectedMentorIds.remove(mentorId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Hackathon"),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CompanyHackathonsPage()));
              },
              child: const Text("Your hackathons"))
        ],
      ),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                    onPressed: () async {
                      BaseAuthService authService = AuthService();
                      await authService.logout();
                    },
                    child: const Text("logout")),
              ),
            ),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Hackathon Name", style: TextStyle(fontSize: 16)),
                  TextFormField(
                    controller: _nameController,
                    validator: (value) =>
                        value!.isEmpty ? "Enter hackathon name" : null,
                  ),
                  const SizedBox(height: 10),
                  const Text("Max Teams", style: TextStyle(fontSize: 16)),
                  TextFormField(
                    controller: _maxTeamsController,
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value!.isEmpty ? "Enter max teams" : null,
                  ),
                  const SizedBox(height: 10),
                  const Text("Status", style: TextStyle(fontSize: 16)),
                  DropdownButton<String>(
                    value: status,
                    items: ["Upcoming", "Ongoing", "Completed"]
                        .map((String value) {
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
                  const Text("Assign Mentors", style: TextStyle(fontSize: 16)),
                  _isLoadingMentors
                      ? const CircularProgressIndicator()
                      : _availableMentors.isEmpty
                          ? const Text("No mentors available.")
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _availableMentors.length,
                              itemBuilder: (context, index) {
                                final mentor = _availableMentors[index];
                                return CheckboxListTile(
                                  title: Text(mentor.name),
                                  value: _selectedMentorIds.contains(mentor.id),
                                  onChanged: (bool? newValue) {
                                    if (newValue != null) {
                                      _onMentorSelectionChanged(
                                          mentor.id, newValue);
                                    }
                                  },
                                );
                              },
                            ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _submit,
                    child: const Text("Submit"),
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
