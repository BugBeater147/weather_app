import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class CommunityInsightsScreen extends StatefulWidget {
  const CommunityInsightsScreen({Key? key}) : super(key: key);

  @override
  State<CommunityInsightsScreen> createState() =>
      _CommunityInsightsScreenState();
}

class _CommunityInsightsScreenState extends State<CommunityInsightsScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedCondition = 'Clear';
  File? _selectedImage;
  bool _isLoading = false;

  final List<String> conditions = ['Clear', 'Rainy', 'Cloudy', 'Stormy', 'Snow'];

  final picker = ImagePicker();

  // Pick Image from Gallery
  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // Upload Data to Firestore
  Future<void> _submitReport() async {
    if (_descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a description')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String imageUrl = '';
      if (_selectedImage != null) {
        // Upload image to Firebase Storage
        final storageRef = FirebaseStorage.instance
            .ref('community_reports/${DateTime.now().toIso8601String()}');
        await storageRef.putFile(_selectedImage!);
        imageUrl = await storageRef.getDownloadURL();
      }

      // Save to Firestore
      await FirebaseFirestore.instance.collection('community_reports').add({
        'condition': _selectedCondition,
        'description': _descriptionController.text,
        'image_url': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report submitted successfully!')));
      _descriptionController.clear();
      setState(() {
        _selectedImage = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Insights'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Condition Dropdown
            DropdownButtonFormField<String>(
              value: _selectedCondition,
              items: conditions
                  .map((condition) => DropdownMenuItem(
                        value: condition,
                        child: Text(condition),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCondition = value!;
                });
              },
              decoration: const InputDecoration(labelText: 'Weather Condition'),
            ),

            // Description Field
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),

            // Image Picker
            const SizedBox(height: 10),
            _selectedImage != null
                ? Image.file(_selectedImage!, height: 150)
                : const Text('No Image Selected'),
            TextButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: const Text('Pick Image'),
            ),

            // Submit Button
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                    onPressed: _submitReport,
                    icon: const Icon(Icons.cloud_upload),
                    label: const Text('Submit Report'),
                  ),

            // Display Submitted Reports
            const SizedBox(height: 20),
            const Text(
              "Recent Community Reports",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('community_reports')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                        child: Text('No reports available yet.'));
                  }

                  return ListView(
                    children: snapshot.data!.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: data['image_url'] != null &&
                                  data['image_url'] != ''
                              ? Image.network(data['image_url'],
                                  width: 50, height: 50, fit: BoxFit.cover)
                              : const Icon(Icons.cloud),
                          title: Text(data['condition']),
                          subtitle: Text(data['description']),
                          trailing: Text(data['timestamp'] != null
                              ? data['timestamp'].toDate().toString()
                              : ''),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
