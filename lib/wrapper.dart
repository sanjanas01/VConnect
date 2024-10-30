
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sls/about.dart';
import 'package:sls/login.dart';

class Wrapper extends StatefulWidget{
  const Wrapper({super.key});
  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper>
{
  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      body:StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context,snapshot){
          if(snapshot.hasData){
            return AboutUsPage();
          }
          else{
            return LoginPage();
          };
        })
      );
    
  }
}
