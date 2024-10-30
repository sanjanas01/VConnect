import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sls/info.dart';
import 'about.dart'; // Assuming HomePage is your home page widget


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
  final TextEditingController confirmPasswordController =
      TextEditingController();
  String? userType; // Added field to track user type
  String? branch;
  String? yearOfStudy;
  String? skills;
  bool? isWillingToGuide;

  Future<void> signUp(BuildContext context) async {
    try {
      if (_formKey.currentState!.validate()) {
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'name': nameController.text,
          'email': emailController.text,
          'phone': phoneController.text,
          'userType': userType,
          'branch': branch,
          'yearOfStudy': yearOfStudy,
          'skills': skills,
          'isWillingToGuide': isWillingToGuide,
        });

        // Show success message
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
          skills = null;
          isWillingToGuide = null;
        });

        // Navigate to home page after successful registration
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => InfoPage()),
        );
      }
    } catch (e) {
      // Handle registration errors here
      print('Error creating account: $e');
      // Show error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create account. Please try again.'),
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
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Name *',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email *',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone Number *',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password *',
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password *',
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20.0),
                Text(
                  'I am a',
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
                Row(
                  children: <Widget>[
                    Radio<String>(
                      value: 'Student',
                      groupValue: userType,
                      onChanged: (value) {
                        setState(() {
                          userType = value;
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
                        });
                      },
                    ),
                    Text('Alumni'),
                  ],
                ),
                if (userType == 'Alumni') ...[
                  SizedBox(height: 20.0),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Branch *',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your branch';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        branch = value;
                      });
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Are you working or pursuing higher studies? *',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your status';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        yearOfStudy = value;
                      });
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Will you be willing to guide students? *',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your willingness';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        isWillingToGuide = value.toLowerCase() == 'yes';
                      });
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'What subject skills do you have? *',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your skills';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        skills = value;
                      });
                    },
                  ),
                ],
                if (userType == 'Student') ...[
                  SizedBox(height: 20.0),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Branch *',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your branch';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        branch = value;
                      });
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Year of Study *',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your year of study';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        yearOfStudy = value;
                      });
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'What subject skills do you have? *',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your skills';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        skills = value;
                      });
                    },
                  ),
                ],
                SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () => signUp(context),
                  child: Text('Sign Up'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}