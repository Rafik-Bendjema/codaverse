import 'package:flutter/material.dart';
import 'package:gdg_hack/backend/hachathon_db.dart';
import 'package:gdg_hack/models/Hackathon.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CompanyHackathonsPage extends StatefulWidget {
  const CompanyHackathonsPage({super.key});

  @override
  State<CompanyHackathonsPage> createState() => _CompanyHackathonsPageState();
}

class _CompanyHackathonsPageState extends State<CompanyHackathonsPage> {
  final HackathonDb _hackathonDb = FirestoreHackathonDb();
  String? companyId;
  List<Hackathon> hackathons = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCompanyHackathons();
  }

  Future<void> _fetchCompanyHackathons() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uid = prefs.getString("uid");
    print("here is the current uid of the company $uid");

    if (uid != null) {
      companyId = uid;
      hackathons = await _hackathonDb.getHackathonsByCompany(uid);
      print("here is the hackathons ${hackathons.length}");
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Your Hackathons")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hackathons.isEmpty
              ? const Center(child: Text("No hackathons found"))
              : ListView.builder(
                  itemCount: hackathons.length,
                  itemBuilder: (context, index) {
                    Hackathon hackathon = hackathons[index];
                    return ListTile(
                      title: Text(hackathon.name),
                      subtitle: Text("Status: ${hackathon.status}"),
                      trailing: hackathon.status != "running"
                          ? TextButton(
                              onPressed: () async {
                                HackathonDb hackathonDb =
                                    FirestoreHackathonDb();
                                await hackathonDb.startHackathon(hackathon.id!);
                                setState(() {});
                              },
                              child: Text("start"))
                          : SizedBox(),
                      onTap: () {},
                    );
                  },
                ),
    );
  }
}
