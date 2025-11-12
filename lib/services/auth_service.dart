import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = "http://127.0.0.1:8000"; // For Android Emulator
  static const String tokenKey = "auth_token";
  static const String userKey = "user_data";

  Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // return prefs.containsKey('auth_token');
    return prefs.containsKey(AuthService.tokenKey);
  }


  // ------------------- LOGIN -------------------
  Future<bool> login(String username, String password) async {
    final resp = await http.post(
      Uri.parse("$baseUrl/api/auth/login/"),
      body: {
        "username": username,
        "password": password,
      },
    );

    // if (resp.statusCode == 200) {
    //   final data = jsonDecode(resp.body);
    //   // final token = data["access"];

    //   final prefs = await SharedPreferences.getInstance();
    //   prefs.setString(tokenKey, token);

    //   // ✅ Also store user info locally
    //   if (data["user"] != null) {
    //     await saveUser(data["user"]);
    //   }

    //   return true;

    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);

      // final token = data["token"];        // ✅ NOT data["access"]
      final access = data["token"]["access"];  
      final refresh = data["token"]["refresh"]; 
      final user = data["user"];          // ✅ user info

      final prefs = await SharedPreferences.getInstance();
      prefs.setString(tokenKey, access);                // ✅ store access only
      prefs.setString("refresh_token", refresh); 
      prefs.setString(userKey, jsonEncode(user));

      return true;
    }

    return false;
  }

  // // ------------------- REGISTER -------------------
  // Future<bool> register(String username, String password) async {
  //   final resp = await http.post(
  //     Uri.parse("$baseUrl/api/auth/register/"),
  //     body: {
  //       "username": username,
  //       "password": password,
  //     },
  //   );

  //   return resp.statusCode == 201;
  // }

  Future<bool> register(String username, String password) async {
    final resp = await http.post(
      Uri.parse("$baseUrl/api/auth/register/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "password": password,
      }),
    );

    if (resp.statusCode == 201) {
      final data = jsonDecode(resp.body);

      final access = data["token"]["access"];
      final refresh = data["token"]["refresh"];
      final user = data["user"];

      final prefs = await SharedPreferences.getInstance();
      prefs.setString(AuthService.tokenKey, access);
      prefs.setString("refresh_token", refresh);
      prefs.setString(AuthService.userKey, jsonEncode(user));

      return true;
    }

    return false;
  }


  // ------------------- LOGOUT -------------------
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(tokenKey);
    prefs.remove(userKey);
  }

  // ------------------- AUTH HEADERS -------------------
  Future<Map<String, String>> authHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(tokenKey);
    return {
      "Authorization": "Bearer $token",
    };
  }

  // ------------------- FETCH PROFILE (formerly getUser) -------------------
  Future<Map<String, dynamic>?> fetchProfile() async {
    final headers = await authHeaders();
    final resp = await http.get(
      Uri.parse("$baseUrl/api/auth/me/"),
      headers: headers,
    );

    if (resp.statusCode == 200) {
      final user = jsonDecode(resp.body);
      await saveUser(user);
      return user;
    }
    return null;
  }

  // ------------------- UPDATE PROFILE (formerly updateUser) -------------------
  // Future<bool> updateProfile({
  //   required String username,
  //   required String bio,
  //   File? profilePic,
  // }) async {
  //   final headers = await authHeaders();

  //   // If profilePic not supported in backend yet, send only text
  //   final resp = await http.put(
  //     Uri.parse("$baseUrl/api/auth/me/"),
  //     headers: {
  //       ...headers,
  //       "Content-Type": "application/json",
  //     },
  //     body: jsonEncode({
  //       "username": username,
  //       "bio": bio,
  //     }),
  //   );

  //   return resp.statusCode == 200;
  // }

  Future<bool> updateProfile({
    required String username,
    required String bio,
    File? profilePic,
  }) async {
    final headers = await authHeaders();
    final uri = Uri.parse("$baseUrl/api/auth/me/update/");

    var request = http.MultipartRequest("PUT", uri);
    request.headers.addAll(headers);

    request.fields['username'] = username;
    request.fields['bio'] = bio;

    if (profilePic != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'profilePic',
        profilePic.path,
      ));
    }

    final resp = await request.send();
    final respBody = await resp.stream.bytesToString();

    print("PROFILE UPDATE STATUS → ${resp.statusCode}");
    print("PROFILE UPDATE BODY → $respBody");

    if (resp.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString(userKey, respBody);
      return true;
    }

    return false;
  }

  // ------------------- SAVE & GET LOCAL USER -------------------
  Future<void> saveUser(Map<String, dynamic> user) async {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString(userKey, jsonEncode(user));
    }

    Future<Map<String, dynamic>?> getUserFromLocal() async {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(userKey);
      if (jsonString != null) {
        return jsonDecode(jsonString);
      }
      return null;
    }
  }


  
