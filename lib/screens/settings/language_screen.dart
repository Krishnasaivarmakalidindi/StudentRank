import 'package:flutter/material.dart';
import 'package:studentrank/widgets/student_rank_app_bar.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String _selectedLanguage = 'English';

  final List<String> _languages = [
    'English',
    'Spanish',
    'French',
    'German',
    'Chinese',
    'Japanese',
    'Hindi',
    'Portuguese',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const StudentRankAppBar(title: 'Language'),
      body: ListView.builder(
        itemCount: _languages.length,
        itemBuilder: (context, index) {
          final language = _languages[index];
          final isSelected = language == _selectedLanguage;
          
          return ListTile(
            title: Text(language),
            trailing: isSelected 
                ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary) 
                : null,
            onTap: () {
              setState(() => _selectedLanguage = language);
            },
          );
        },
      ),
    );
  }
}
