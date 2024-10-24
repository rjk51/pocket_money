import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart' as f;
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart'; // For image selection

class Page1 extends StatefulWidget {
  const Page1({super.key});

  @override
  _Page1State createState() => _Page1State();
}

class _Page1State extends State<Page1> with SingleTickerProviderStateMixin {
  DateTime? selectedDOB;
  String? _selectedGender;
  File? _profileImage;
  final TextEditingController _nameController = TextEditingController();

  final picker = ImagePicker();

  // Animation properties
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _startAnimation();
  }

  void _startAnimation() {
    _controller.forward();
    setState(() {
      _visible = true;
    });
    Timer(const Duration(seconds: 3), () {
      _controller.reverse();
      setState(() {
        _visible = false;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // Function to handle gender selection
  void _selectGender(String gender) {
    setState(() {
      _selectedGender = gender;
    });
  }

  // Function to pick image from gallery
  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  // Function to submit form data to the server
  Future<void> _submitForm() async {
    if (_nameController.text.isEmpty || _selectedGender == null || selectedDOB == null || _profileImage == null) {
      // Ensure all fields are filled
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all the details')),
      );
      return;
    }

    // Create form data to send to the backend
    var request = http.MultipartRequest('POST', Uri.parse('http://localhost:8000/submit-form'));
    request.fields['name'] = _nameController.text;
    request.fields['dob'] = selectedDOB!.toIso8601String();
    request.fields['gender'] = _selectedGender!;

    // Attach profile image
    request.files.add(await http.MultipartFile.fromPath('profileImage', _profileImage!.path));

    // Send request to backend
    var response = await request.send();

    if (response.statusCode == 200) {
      // Handle successful response
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Form submitted successfully')),
      );
    } else {
      // Handle error response
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error submitting form')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: f.FluentApp(
        debugShowCheckedModeBanner: false,
        home: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  Card(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          f.Center(
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.grey[300],
                                backgroundImage: _profileImage != null
                                    ? FileImage(_profileImage!)
                                    : null,
                                child: _profileImage == null
                                    ? const Icon(
                                        Icons.add,
                                        size: 60,
                                        color: Colors.black,
                                      )
                                    : null,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          f.InfoLabel(
                            label: 'Name',
                            labelStyle: const TextStyle(
                                color: Colors.black,
                                fontWeight: f.FontWeight.bold),
                            child: f.TextBox(
                              controller: _nameController,
                              placeholder: 'Enter full name',
                            ),
                          ),
                          const SizedBox(height: 10),
                          f.DatePicker(
                            header: 'Date Of Birth (DOB)',
                            headerStyle: const TextStyle(
                                color: Colors.black,
                                fontWeight: f.FontWeight.bold),
                            selected: selectedDOB,
                            onChanged: (time) {
                              setState(() {
                                selectedDOB = time;
                              });
                            },
                          ),
                          const SizedBox(height: 10),
                          const Text('Gender',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              ElevatedButton(
                                onPressed: () => _selectGender('Male'),
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: _selectedGender == 'Male'
                                      ? Colors.white
                                      : Colors.black,
                                  backgroundColor: _selectedGender == 'Male'
                                      ? Colors.black
                                      : Colors.white,
                                  side: const BorderSide(
                                      color: Colors.black, width: 1),
                                ),
                                child: const Text('Male'),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: () => _selectGender('Female'),
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: _selectedGender == 'Female'
                                      ? Colors.white
                                      : Colors.black,
                                  backgroundColor: _selectedGender == 'Female'
                                      ? Colors.black
                                      : Colors.white,
                                  side: const BorderSide(
                                      color: Colors.black, width: 1),
                                ),
                                child: const Text('Female'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _submitForm,
                            child: const Text('Submit'),
                          ),
                        ],
                      ),
                    ),
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
