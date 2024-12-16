import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';

class BackgroundSelectionScreen extends StatelessWidget {
  final List<String> availableBackgrounds = [
    "assets/backgrounds/Sunny2.png",
    "assets/backgrounds/Cloudy2.png",
    "assets/backgrounds/Rainy2.png",
    "assets/backgrounds/Snowy2.png",
    "assets/backgrounds/Lightning2.png",
    "assets/backgrounds/Blue.png",
    "assets/backgrounds/Grey.png",
    "assets/backgrounds/Sunrise.png",
    "assets/backgrounds/Mountain.png",
    "assets/backgrounds/Ocean.png",
  ];

  /// Upload a custom background from the gallery
  Future<void> _uploadBackground(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

      // Avoid redundant updates if the same background is already set
      if (themeProvider.currentBackground != pickedFile.path) {
        await themeProvider.setCustomBackground(pickedFile.path);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Background uploaded successfully!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("This background is already set!")),
        );
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text("Select Background")),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: availableBackgrounds.length,
              itemBuilder: (context, index) {
                final background = availableBackgrounds[index];
                return GestureDetector(
                  onTap: () async {
                    // Avoid redundant updates if the same background is already set
                    if (themeProvider.currentBackground != background) {
                      await themeProvider.setCustomBackground(background);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Background updated!")),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("This background is already set!")),
                      );
                    }
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(background),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () => _uploadBackground(context),
            child: const Text("Upload Background"),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () async {
              // Reset background only if it's not already default
              if (themeProvider.currentBackground.isNotEmpty) {
                await themeProvider.resetBackground();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Background reset to default!")),
                );
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Background is already default!")),
                );
              }
            },
            child: const Text("Reset to Default Theme"),
          ),
        ],
      ),
    );
  }
}
