import 'package:flutter/material.dart';
import '../widgets/time_display.dart';
import '../services/auth_service.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String protectedMessage = "Loading...";

  @override
  void initState() {
    super.initState();
    fetchProtectedData();
  }

  Future<void> fetchProtectedData() async {
    try {
      final headers = await AuthService().authHeaders();

      final uri = Uri.parse("${AuthService.baseUrl}/api/protected/");
      print("REQ → $uri");
      print("HEADERS → $headers");

      final resp = await http.get(
        uri,
        headers: headers,               // ✅ correct
      );
      print("STATUS → ${resp.statusCode}");
      print("BODY → ${resp.body}");

      setState(() {
        // protectedMessage = resp.body;
        protectedMessage = "Status: ${resp.statusCode}\nBody: ${resp.body}";
      });
    } catch (e) {
      setState(() {
        protectedMessage = "Error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        children: [
          Row(
            children: const [
              Expanded(flex: 2, child: TimeDisplay()),
              Expanded(flex: 1, child: SizedBox()),
            ],
          ),

          const SizedBox(height: 20),

          /// ✅ show API response at top
          Text(
            protectedMessage,
            style: const TextStyle(color: Colors.white),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 1.6,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: const [
                PlaceholderTile(title: 'Recent Activity'),
                PlaceholderTile(title: 'News Headlines'),
                PlaceholderTile(title: 'Shortcuts'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PlaceholderTile extends StatelessWidget {
  final String title;
  const PlaceholderTile({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const Spacer(),
          const Text('Coming soon', style: TextStyle(color: Colors.white54)),
        ],
      ),
    );
  }
}
