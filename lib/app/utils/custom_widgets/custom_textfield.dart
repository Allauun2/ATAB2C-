import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:travel_app/app/configs/app_colors.dart';
import 'package:travel_app/app/configs/app_size_config.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? textEditingController;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool? readOnly;
  final String hintText;
  final String? labelText;
  final String? errorText;
  final Widget? icon;
  final bool? obscureText;
  final bool isRequired;
  final Function()? onTap;
  final Function(String? value)? onChanged;
  final FocusNode? focusNode;
  final int? maxlength;
  final List<TextInputFormatter>? inputformatter;
  final Color? errorColor;
  final String? prefixText;
  final String? suffixText;
  final int? maxLines;
  final EdgeInsetsGeometry? contentpadding;
  const CustomTextField({
    this.textEditingController,
    this.validator,
    this.readOnly,
    required this.hintText,
    this.labelText = '',
    this.icon,
    this.obscureText,
    this.onTap,
    this.focusNode,
    this.keyboardType,
    this.maxlength,
    this.inputformatter,
    this.errorText,
    this.errorColor,
    this.onChanged,
    this.prefixText,
    this.suffixText,
    this.maxLines = 1,
    this.contentpadding,
    this.isRequired = false,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    var theme = context.theme.colorScheme;
    HeightWidth(context);
    return TextFormField(
      onTapOutside: (_) {
        Get.focusScope!.unfocus();
      },
      onTap: onTap,
      maxLines: maxLines,
      maxLength: maxlength,
      inputFormatters: inputformatter,
      keyboardType: keyboardType,
      controller: textEditingController,
      readOnly: readOnly ?? false,
      focusNode: focusNode,
      validator: validator,
      obscureText: obscureText ?? false,
      cursorColor: AppColors.appColorPrimary,
      onChanged: onChanged,
      // Portal field-box style (srch-v2): bordered 8px box, micro-label,
      // primary border on focus — replaces the template's underlines.
      decoration: InputDecoration(
        prefixText: prefixText,
        suffixText: suffixText,
        prefixStyle: TextStyle(
            fontSize: 15, fontWeight: FontWeight.w400, color: theme.onPrimary),
        suffixStyle: TextStyle(
            fontSize: 15, fontWeight: FontWeight.w400, color: theme.onPrimary),
        contentPadding: contentpadding ??
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        isDense: true,
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: errorColor ?? AppColors.red, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide:
              const BorderSide(color: AppColors.appColorPrimary, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFB9C2D4), width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: errorColor ?? AppColors.red),
          borderRadius: BorderRadius.circular(8),
        ),
        suffixIcon: icon == null
            ? null
            : Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(onTap: onTap, child: icon),
              ),
        suffixIconConstraints:
            const BoxConstraints(minWidth: 28, minHeight: 28),
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFB9C2D4), width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
        fillColor: AppColors.appColorWhite,
        errorStyle: const TextStyle(
          color: AppColors.red,
          fontSize: 11,
        ),
        errorMaxLines: 2,
        floatingLabelAlignment: FloatingLabelAlignment.start,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        hintText: hintText,
        hintStyle: const TextStyle(
            color: AppColors.appColorHint,
            fontSize: 14.0,
            fontWeight: FontWeight.w400),
        filled: true,
        errorText: errorText,
        alignLabelWithHint: false,

        label: RichText(
          text: TextSpan(
            style: const TextStyle(
              color: AppColors.appColorTextDarkGray,
              fontSize: 13.0,
              fontWeight: FontWeight.w600,
            ),
            children: [
              TextSpan(text: labelText!),
              if (isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: AppColors.red),
                ),
            ],
          ),
        ),
        // label: CommonText(text: labelText!),
        // labelStyle: TextStyle(
        //     overflow: TextOverflow.visible,
        //     color: Colors.black,
        //     fontSize: 14.0,
        //     fontWeight: FontWeight.bold),
      ),
    );
  }
}
