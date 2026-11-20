import 'package:flutter/material.dart';
import 'package:travel_app/app/configs/app_colors.dart';

class CustomButton extends StatelessWidget {
  final double? height;
  final double? width;
  final String text;

  final Function() onPress;
  CustomButton({
    super.key,
    required this.text,
    required this.onPress,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 50.0,
      width: width ?? 250.0,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.appColorPrimary,
            AppColors.appColorPrimary
            // AppColors.appColorPrimary.withOpacity(0.8)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(2.0),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(2.0),
          onTap: onPress,
          child: Center(
            // child: CommonText(
            // text: text,
            // color: Colors.white,
            // weight: FontWeight.w500,
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CustomLoginButton extends StatelessWidget {
  final double? height;
  final double? width;
  final String text;

  final Function() onPress;
  const CustomLoginButton({
    super.key,
    required this.text,
    required this.onPress,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 50.0,
      width: width ?? 150.0,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.appColorPrimary,
            AppColors.appColorPrimary,
          ],
        ),
        borderRadius: BorderRadius.circular(2.0),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(2.0),
          onTap: onPress,
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CustomCancelButton extends StatelessWidget {
  final double? height;
  final double? width;
  final String text;

  final Function() onPress;
  const CustomCancelButton({
    super.key,
    required this.text,
    required this.onPress,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 50.0,
      width: width ?? 150.0,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey.shade100,
            Colors.grey.shade100,
          ],
        ),
        borderRadius: BorderRadius.circular(2.0),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(2.0),
          onTap: onPress,
          child: Center(
            // child: CommonText(
            //   text: text,
            //   color: Colors.white,
            //   weight: FontWeight.w500,
            // ),
            child: Text(
              text,
              style: const TextStyle(
                // color: Colors.white,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
