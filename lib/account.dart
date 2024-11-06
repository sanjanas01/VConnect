import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sls/info.dart';

class CreateAccountForm extends StatefulWidget {
  @override
  _CreateAccountFormState createState() => _CreateAccountFormState();
}

class _CreateAccountFormState extends State<CreateAccountForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController skillController = TextEditingController();
  final TextEditingController interestController = TextEditingController();

  String? userType;
  String? branch;
  String? yearOfStudy;
  List<String> skills = [];
  List<String> interests = [];
  String? futureS; // For Students
  String? futureA; // For Alumni

  void addSkill() {
    if (skillController.text.isNotEmpty) {
      setState(() {
        skills.add(skillController.text);
        skillController.clear();
      });
    }
  }

  void addInterest() {
    if (interestController.text.isNotEmpty) {
      setState(() {
        interests.add(interestController.text);
        interestController.clear();
      });
    }
  }

  void removeSkill(int index) {
    setState(() {
      skills.removeAt(index);
    });
  }

  void removeInterest(int index) {
    setState(() {
      interests.removeAt(index);
    });
  }

  Future<void> signUp(BuildContext context) async {
    try {
      if (_formKey.currentState!.validate()) {
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        await FirebaseFirestore.instance
            .collection('uservc')
            .doc(userCredential.user!.uid)
            .set({
          'name': nameController.text,
          'email': emailController.text,
          'phone': phoneController.text,
          'userType': userType,
          'branch': branch,
          'yearOfStudy': yearOfStudy,
          'skills': skills,
          'interests': interests,
          'futureS': futureS,
          'futureA': futureA,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Account created successfully!'),
            duration: Duration(seconds: 3),
          ),
        );

        // Clear form fields
        nameController.clear();
        emailController.clear();
        phoneController.clear();
        passwordController.clear();
        confirmPasswordController.clear();
        setState(() {
          userType = null;
          branch = null;
          yearOfStudy = null;
          skills.clear();
          interests.clear();
          futureS = null; 
          futureA = null; 
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => InfoPage()),
        );
      }
    } catch (e) {
      print('Error creating account: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create account. Error: $e'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Account'),
        backgroundColor: Color.fromARGB(255, 216, 228, 243),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(height: 20.0),
                Center(
                  child: Image.asset('assets/logo2.png', height: 150.0, width: 150.0),
                ),
                SizedBox(height: 20.0),
                _buildTextField(nameController, 'Name *'),
                SizedBox(height: 16.0),
                _buildTextField(emailController, 'Email *', keyboardType: TextInputType.emailAddress),
                SizedBox(height: 16.0),
                _buildTextField(phoneController, 'Phone Number *', keyboardType: TextInputType.phone),
                SizedBox(height: 16.0),
                _buildTextField(passwordController, 'Password *', obscureText: true),
                SizedBox(height: 16.0),
                _buildTextField(confirmPasswordController, 'Confirm Password *', obscureText: true),
                SizedBox(height: 20.0),
                Text('Skills *', style: TextStyle(fontSize: 16.0)),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(skillController, 'Enter skill', isMandatory: false),
                    ),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: addSkill,
                      color: Colors.blue,
                    ),
                  ],
                ),
                Wrap(
                  spacing: 8.0,
                  children: List<Widget>.generate(skills.length, (index) {
                    return Chip(
                      label: Text(skills[index]),
                      onDeleted: () => removeSkill(index),
                      backgroundColor: Color.fromARGB(255, 216, 228, 243),
                    );
                  }),
                ),
                SizedBox(height: 20.0),
                Text('Interests *', style: TextStyle(fontSize: 16.0)),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(interestController, 'Enter interest', isMandatory: false),
                    ),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: addInterest,
                      color: Colors.blue,
                    ),
                  ],
                ),
                Wrap(
                  spacing: 8.0,
                  children: List<Widget>.generate(interests.length, (index) {
                    return Chip(
                      label: Text(interests[index]),
                      onDeleted: () => removeInterest(index),
                      backgroundColor: Color.fromARGB(255, 216, 228, 243),
                    );
                  }),
                ),
                SizedBox(height: 20.0),
                _buildTextField(null, 'Branch *', onChanged: (value) {
                  setState(() {
                    branch = value;
                  });
                }),
                SizedBox(height: 20.0),
                Text('I am a', style: TextStyle(fontSize: 16.0)),
                Row(
                  children: <Widget>[
                    Radio<String>(
                      value: 'Student',
                      groupValue: userType,
                      onChanged: (value) {
                        setState(() {
                          userType = value;
                          futureS = null; 
                          futureA = null; 
                        });
                      },
                    ),
                    Text('Student'),
                    Radio<String>(
                      value: 'Alumni',
                      groupValue: userType,
                      onChanged: (value) {
                        setState(() {
                          userType = value;
                          futureS = null; 
                          futureA = null;
                        });
                      },
                    ),
                    Text('Alumni'),
                  ],
                ),
                if (userType != null) ...[
                  if (userType == 'Student') ...[
                    _buildTextField(null, 'Year of Study *', onChanged: (value) {
                      setState(() {
                        yearOfStudy = value;
                      });
                    }),
                    SizedBox(height: 15.0),
                    Text('Are you interested in *', style: TextStyle(fontSize: 16.0)),
                    Row(
                      children: <Widget>[
                        Radio<String>(
                          value: 'Working',
                          groupValue: futureS,
                          onChanged: (value) {
                            setState(() {
                              futureS = value;
                            });
                          },
                        ),
                        Text('Working'),
                        Radio<String>(
                          value: 'Pursuing Higher Studies',
                          groupValue: futureS,
                          onChanged: (value) {
                            setState(() {
                              futureS = value;
                            });
                          },
                        ),
                        Text('Pursuing Higher Studies'),
                      ],
                    ),
                  ],
                  if (userType == 'Alumni') ...[
                    Text('Are you', style: TextStyle(fontSize: 16.0)),
                    Row(
                      children: <Widget>[
                        Radio<String>(
                          value: 'Working',
                          groupValue: futureA,
                          onChanged: (value) {
                            setState(() {
                              futureA = value;
                            });
                          },
                        ),
                        Text('Working'),
                        Radio<String>(
                          value: 'Pursuing Higher Studies',
                          groupValue: futureA,
                          onChanged: (value) {
                            setState(() {
                              futureA = value;
                            });
                          },
                        ),
                        Text('Pursuing Higher Studies'),
                      ],
                    ),
                  ],
                ],
                SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () => signUp(context),
                  child: Text('Create Account'),
                  style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF818FB4)), // Button color set here
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController? controller, String label, {
    bool isMandatory = true,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        fillColor: Color.fromARGB(255, 255, 255, 255), // Text box color set here
        filled: true,
      ),
      validator: (value) {
        if (isMandatory && (value == null || value.isEmpty)) {
          return 'Please enter $label';
        }
        return null; 
      },
    );
  }
}
