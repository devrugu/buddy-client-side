import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:email_validator/email_validator.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../widgets/custom_text_form_field.dart';
import '../widgets/custom_button.dart';
import '../widgets/warning_messages.dart';

class SignUpTouristScreen extends StatefulWidget {
  const SignUpTouristScreen({Key? key}) : super(key: key);

  @override
  _SignUpTouristScreenState createState() => _SignUpTouristScreenState();
}

class _SignUpTouristScreenState extends State<SignUpTouristScreen> {
  final phoneMaskFormatter = MaskTextInputFormatter(
    mask: '+## (###) ###-##-##',
    filter: {"#": RegExp(r'[0-9]')},
  );
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedCountry;
  List<String> _countries = [];

  @override
  void initState() {
    super.initState();
    _fetchCountries();
  }

  Future<void> _fetchCountries() async {
    try {
      var url = Uri.parse(
          'https://057038bb-3c86-407f-8e4a-9e92b14e8f47-00-2l9mz0a4krqw9.kirk.replit.dev/utilities/countries.php');
      var response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          _countries = List<String>.from(json.decode(response.body));
        });
      } else {
        throw Exception('Failed to load countries');
      }
    } catch (e) {
      _showErrorDialog('Unable to fetch countries: $e');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  bool _isValidUsername(String username) {
    return username.isNotEmpty && !username.contains(' ');
  }

  bool _isValidPassword(String password) {
    RegExp passwordExp =
        RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[\W_]).{8,}$');
    return passwordExp.hasMatch(password);
  }

  bool _isValidPhoneNumber(String phone) {
    RegExp phoneExp = RegExp(r'^\+\d+\s\(\d{3}\)\s\d{3}-\d{2}-\d{2}$');
    return phoneExp.hasMatch(phone);
  }

  // bool _isValidDateOfBirth(DateTime? date) {
  //   if (date == null) return false;
  //   DateTime eighteenYearsAgo =
  //       DateTime.now().subtract(const Duration(days: 6570));
  //   return date.isBefore(DateTime.now()) &&
  //       date.isBefore(eighteenYearsAgo) &&
  //       date.year > 1900;
  // }

  Future<void> _register() async {
    if (_nameController.text.isEmpty ||
        _surnameController.text.isEmpty ||
        !_isValidUsername(_usernameController.text) ||
        !EmailValidator.validate(_emailController.text) ||
        !_isValidPassword(_passwordController.text) ||
        !_isValidPhoneNumber(_phoneNumberController.text) ||
        //!_isValidDateOfBirth(_selectedDate) ||
        _selectedCountry == null) {
      _showErrorDialog('Please fill in all fields correctly.');
      return;
    }

    try {
      var url = Uri.parse(
          'https://057038bb-3c86-407f-8e4a-9e92b14e8f47-00-2l9mz0a4krqw9.kirk.replit.dev/user/tourist/register_tourist.php');
      var response = await http.post(url, body: {
        'name': _nameController.text,
        'surname': _surnameController.text,
        'username': _usernameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'phoneNumber': _phoneNumberController.text,
        'dateOfBirth': _selectedDate?.toIso8601String().split('T')[0],
        'country': _selectedCountry,
      });

      if (response.statusCode == 200) {
        // Handle successful registration
        WarningMessages.success(context, 'Registration successful');
      } else {
        WarningMessages.error(context, 'Registration failed');
        throw Exception('Registration failed');
      }
    } catch (e) {
      _showErrorDialog('Registration error: $e');
    }
  }

  void _showErrorDialog(String message) {
    WarningMessages.error(context, message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up as Tourist'),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0466C8)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            CustomTextFormField(
              labelText: 'Name',
              hintText: 'Enter your name',
              controller: _nameController,
            ),
            const SizedBox(height: 16),
            CustomTextFormField(
              labelText: 'Surname',
              hintText: 'Enter your surname',
              controller: _surnameController,
            ),
            const SizedBox(height: 16),
            CustomTextFormField(
              labelText: 'Username',
              hintText: 'Choose a username',
              controller: _usernameController,
            ),
            const SizedBox(height: 16),
            CustomTextFormField(
              labelText: 'Email',
              hintText: 'Enter your email',
              keyboardType: TextInputType.emailAddress,
              controller: _emailController,
            ),
            const SizedBox(height: 16),
            CustomTextFormField(
              labelText: 'Password',
              hintText: 'Create a password',
              obscureText: true,
              controller: _passwordController,
            ),
            const SizedBox(height: 16),
            CustomTextFormField(
              labelText: 'Phone Number',
              hintText: 'Enter your phone number',
              keyboardType: TextInputType.phone,
              controller: _phoneNumberController,
              phoneMaskFormatter: phoneMaskFormatter,
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: AbsorbPointer(
                child: CustomTextFormField(
                  controller: TextEditingController(
                      text: _selectedDate == null
                          ? 'Select your date of birth'
                          : "${_selectedDate!.toLocal()}".split(' ')[0]),
                  labelText: 'Date of Birth',
                  hintText: 'Enter your date of birth',
                ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCountry,
              items: _countries.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedCountry = newValue;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Country',
              ),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Register',
              onPressed: _register,
            ),
          ],
        ),
      ),
    );
  }
}
