import 'package:flutter/material.dart';
import '../../shared/constants/colors.dart';

class GlassAuthField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscure;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final void Function(String)? onChanged;

  const GlassAuthField({
    Key? key,
    required this.controller,
    required this.label,
    required this.icon,
    this.obscure = false,
    this.validator,
    this.keyboardType,
    this.onChanged,
  }) : super(key: key);

  @override
  State<GlassAuthField> createState() => _GlassAuthFieldState();
}

class _GlassAuthFieldState extends State<GlassAuthField> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscure;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscure,
      validator: widget.validator,
      keyboardType: widget.keyboardType,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon: Icon(widget.icon, color: AppColors.primary),
        suffixIcon: widget.obscure
            ? IconButton(
          icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off, color: AppColors.primary),
          onPressed: () => setState(() => _obscure = !_obscure),
        )
            : null,
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      ),
      style: const TextStyle(color: Colors.white),
    );
  }
}
