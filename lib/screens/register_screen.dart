import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';

const Color primaryBlue = Color(0xFF2100C4);
const Color lightGrey = Color(0xFFF2F2F2);
const Color pinkColor = Color(0xFFFF7D8B);

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController dobController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isSubmitting = false;

  Future<void> registerUser() async {
    // Basic client-side validation. Firestore/Auth rules are the real
    // enforcement layer, but catching obvious mistakes early = better UX.
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your name")),
      );
      return;
    }
    if (passwordController.text.trim().length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password must be at least 6 characters")),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      String uid = userCredential.user!.uid;

      await _firestore.collection("users").doc(uid).set({
        "name": nameController.text.trim(),
        "email": emailController.text.trim(),
        "dob": dobController.text.trim(),
        "uid": uid,
        "role": "user", // Admin role must be set manually in Firestore console
        "createdAt": FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBlue,
      body: SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.9,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: lightGrey,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(45),
                    topRight: Radius.circular(45),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 35),

                      const Text(
                        "Sign Up",
                        style: TextStyle(
                          fontSize: 60,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 60),

                      const Center(
                        child: Text(
                          "Educart",
                          style: TextStyle(
                            fontSize: 52,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      const SizedBox(height: 60),

                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.person_outline),
                          hintText: "Name",
                          hintStyle: const TextStyle(
                            color: pinkColor,
                            fontSize: 20,
                          ),
                          filled: true,
                          fillColor: lightGrey,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 22),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide:
                                const BorderSide(color: Colors.black54),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide:
                                const BorderSide(color: primaryBlue, width: 2),
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.email_outlined),
                          hintText: "Email",
                          hintStyle: const TextStyle(
                            color: pinkColor,
                            fontSize: 20,
                          ),
                          filled: true,
                          fillColor: lightGrey,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 22),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide:
                                const BorderSide(color: Colors.black54),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide:
                                const BorderSide(color: primaryBlue, width: 2),
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock_outline),
                          hintText: "Password",
                          hintStyle: const TextStyle(
                            color: pinkColor,
                            fontSize: 20,
                          ),
                          filled: true,
                          fillColor: lightGrey,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 22),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide:
                                const BorderSide(color: Colors.black54),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide:
                                const BorderSide(color: primaryBlue, width: 2),
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      GestureDetector(
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime(2005),
                            firstDate: DateTime(1950),
                            lastDate: DateTime.now(),
                          );

                          if (pickedDate != null) {
                            setState(() {
                              dobController.text =
                                  "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                            });
                          }
                        },
                        child: AbsorbPointer(
                          child: TextField(
                            controller: dobController,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(
                                Icons.calendar_month_outlined,
                              ),
                              hintText: "Date of Birth",
                              hintStyle: const TextStyle(
                                color: pinkColor,
                                fontSize: 20,
                              ),
                              suffixIcon: const Padding(
                                padding: EdgeInsets.all(12),
                                child: CircleAvatar(
                                  backgroundColor: pinkColor,
                                  child: Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                              filled: true,
                              fillColor: lightGrey,
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 22),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide:
                                    const BorderSide(color: Colors.black54),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: const BorderSide(
                                    color: primaryBlue, width: 2),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 45),

                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 35,
                              vertical: 16,
                            ),
                          ),
                          onPressed: _isSubmitting ? null : registerUser,
                          child: _isSubmitting
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Text(
                                      "Continue",
                                      style: TextStyle(
                                        fontSize: 24,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(width: 18),
                                    Icon(
                                      Icons.arrow_forward,
                                      color: Colors.white,
                                      size: 34,
                                    ),
                                  ],
                                ),
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              top: 40,
              right: 25,
              child: CircleAvatar(
                radius: 24,
                backgroundColor: pinkColor,
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
