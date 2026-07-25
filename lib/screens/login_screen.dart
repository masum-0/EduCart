import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/error_helper.dart';
import 'register_screen.dart';
import 'home_screen.dart';

const Color primaryBlue = Color(0xFF2100C4);
const Color lightGrey = Color(0xFFF2F2F2);
const Color pinkColor = Color(0xFFFF7D8B);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final AuthService _authService = AuthService();
  bool _isSubmitting = false;

  Future<void> loginUser() async {
    if (emailController.text.trim().isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your email and password")),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await _authService.login(emailController.text, passwordController.text);

      // Navigate explicitly rather than relying solely on the reactive
      // AuthGate stream at the app root — on some devices that stream can
      // lag a moment behind the actual sign-in, which was leaving this
      // screen looking "frozen" even though sign-in had already succeeded.
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(friendlyErrorMessage(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> resetPassword() async {
    if (emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter your email above first, then tap Forgot Password")),
      );
      return;
    }
    try {
      await _authService.resetPassword(emailController.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password reset email sent")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(friendlyErrorMessage(e))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBlue,
      // Prevents the keyboard from resizing/shifting this layout, which was
      // previously pushing the white card up over the "EduCart" heading.
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned(
              top: 40,
              left: 40,
              child: Text(
                "EduCart",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 56,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.68,
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
                    children: [
                      const SizedBox(height: 40),

                      const Icon(
                        Icons.menu_book_rounded,
                        size: 100,
                        color: Colors.brown,
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 30),

                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
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
                            borderSide: const BorderSide(
                              color: primaryBlue,
                              width: 2,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

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
                            borderSide: const BorderSide(
                              color: primaryBlue,
                              width: 2,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 35,
                            vertical: 16,
                          ),
                        ),
                        onPressed: _isSubmitting ? null : loginUser,
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

                      const SizedBox(height: 16),

                      TextButton(
                        onPressed: _isSubmitting ? null : resetPassword,
                        child: const Text(
                          "Forgot Password?",
                          style: TextStyle(
                            color: Colors.black,
                            decoration: TextDecoration.underline,
                            fontSize: 18,
                          ),
                        ),
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have account? ",
                            style: TextStyle(fontSize: 18),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const RegisterScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              "Sign Up",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}