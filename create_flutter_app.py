import os
import subprocess
import shutil

APP_NAME = "smart_mirror_flutter"

print("🚀 Creating Flutter Smart Mirror App...")

# 1. Check flutter exists
try:
    subprocess.run(["flutter", "--version"], check=True)
except Exception:
    print("❌ Flutter not installed or not in PATH")
    exit(1)

# 2. Create flutter project
if os.path.exists(APP_NAME):
    print(f"⚠️ Project folder '{APP_NAME}' already exists. Skipping creation.")
else:
    print("📦 Creating Flutter project...")
    subprocess.run(["flutter", "create", APP_NAME], check=True)

# 3. Clean default lib folder
lib_path = os.path.join(APP_NAME, "lib")
print("🧹 Cleaning default lib folder...")
shutil.rmtree(lib_path)
os.makedirs(lib_path)

# 4. Create folder structure
print("📁 Creating Smart Mirror folder structure...")

folders = [
    "api/models",
    "api",
    "services",
    "screens",
    "state",
    "utils",
    "widgets"
]

for folder in folders:
    os.makedirs(os.path.join(lib_path, folder), exist_ok=True)

# 5. Write an empty main.dart temporarily
main_dart = os.path.join(lib_path, "main.dart")
with open(main_dart, "w") as f:
    f.write(
        """import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: SmartMirrorApp()));
}

class SmartMirrorApp extends StatelessWidget {
  const SmartMirrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Smart Mirror",
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(child: Text("Smart Mirror App Initialized")),
      ),
    );
  }
}
"""
    )

print("✅ Flutter project structure ready.")
print("➡️ Next step: install required dependencies inside the Flutter app.")
print(f"cd {APP_NAME}")
print("flutter pub add flutter_riverpod dio qr_code_scanner")
print("\n🎉 Done!")
