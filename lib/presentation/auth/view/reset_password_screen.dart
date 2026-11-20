import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travel_app/app/configs/app_colors.dart';
// import 'package:travel_app/app/configs/app_size_config.dart';
import 'package:travel_app/app/utils/custom_widgets/common_text.dart';
import 'package:travel_app/app/utils/custom_widgets/custom_button.dart';
import 'package:travel_app/app/utils/custom_widgets/custom_textfield_required.dart';

import '../controller/login_controller.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final LoginController loginController = Get.put(LoginController());
  final userController = TextEditingController();
  final _formkey = GlobalKey<FormState>();
  bool isButton1Selected = true;
  bool isValidForm = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.blue.withOpacity(0.5),
                BlendMode.srcATop,
              ),
              child: const Image(
                image: AssetImage("assets/images/onboard_background.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Foreground content
          Column(
            children: [
              const SizedBox(height: 80),
              const CommonText(
                text: "Forgot Password",
                color: Colors.white,
                fontSize: 25,
                weight: FontWeight.w600,
              ),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: CommonText(
                  text:
                      "You will receive an email with instructions to reset your password",
                  textAlign: TextAlign.center,
                  color: Colors.white,
                  fontSize: 15,
                  weight: FontWeight.w400,
                ),
              ),
              // 0.1.ph,
              const SizedBox(height: 16),
              Center(
                // child: CircleAvatar(
                //   radius: 50,
                //   backgroundImage: AssetImage('assets/1000.png'),
                // ),
                // child: CircleAvatar(
                //   radius: 60,
                //   backgroundColor: Colors.transparent,
                //   child: ClipOval(
                //     child: Image.asset(
                //       'assets/1003.png',
                //       width: 150,
                //       height: 150,
                //       fit: BoxFit.contain,
                //     ),
                //   ),
                // ),
                child: Container(
                  width: 150, // match 2 * desired radius
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage('assets/1003.png'),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              // White container for the form
              Container(
                padding: const EdgeInsets.symmetric(vertical: 30),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(25.0),
                    topLeft: Radius.circular(25.0),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Form(
                    key: _formkey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 20),
                        Custom_textfield_required(
                          requiredLabel: "Enter your email or username",
                          hint: "Enter your email or username",
                          controller: userController,
                          validator: (inputValue) {
                            if (inputValue!.isEmpty) {
                              return "Enter a valid email or username";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 30),
                        Obx(
                          () {
                            return loginController.isLoading.value
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      color: AppColors.appColorPrimary,
                                    ),
                                  )
                                : Row(
                                    children: [
                                      Expanded(
                                        child: CustomLoginButton(
                                          onPress: () {
                                            if (_formkey.currentState!
                                                .validate()) {
                                              setState(
                                                () {
                                                  isValidForm = true;
                                                  loginController.resetPassword(
                                                    userController.text.trim(),
                                                  );
                                                },
                                              );
                                            } else {
                                              setState(() {
                                                isValidForm = false;
                                              });
                                            }
                                          },
                                          text: "Continue",
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: CustomCancelButton(
                                          onPress: () {
                                            Get.back();
                                          },
                                          text: "Cancel",
                                        ),
                                      ),
                                    ],
                                  );
                          },
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
