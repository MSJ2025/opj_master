import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import pour rootBundle
import 'package:rounded_expansion_tile/rounded_expansion_tile.dart'; // Import pour RoundedExpansionTile
import 'dart:convert'; // Import pour json.decode
import 'quiz_screen.dart';
import 'package:opj_master/services/statistics_service.dart';

class QuizSettingsScreen extends StatefulWidget {
  final StatisticsService statisticsService;

  QuizSettingsScreen({required this.statisticsService});

  @override
  _QuizSettingsScreenState createState() => _QuizSettingsScreenState();
}

class _QuizSettingsScreenState extends State<QuizSettingsScreen> {
  final List<String> _domains = ['Droit Pénal Général', 'Droit Pénal Spécial', 'Procédure Pénale'];
  Map<String, List<String>> _subDomains = {};
  Map<String, bool> _selectedDomains = {};
  Map<String, Map<String, bool>> _selectedSubDomains = {};
  int _numberOfQuestions = 10;

  @override
  void initState() {
    super.initState();
    _initializeSelection();
    _loadSubDomains();
  }

  void _initializeSelection() {
    _selectedDomains = {for (var domain in _domains) domain: false};
    _selectedSubDomains = {for (var domain in _domains) domain: {}};
  }

  Future<void> _loadSubDomains() async {
    Map<String, String> files = {
      'Droit Pénal Général': 'dpg_questions.json',
      'Droit Pénal Spécial': 'dps_questions.json',
      'Procédure Pénale': 'pp_questions.json',
    };

    for (var domain in files.keys) {
      String data = await rootBundle.loadString('assets/questions/${files[domain]}');
      Map<String, dynamic> jsonData = jsonDecode(data);
      _subDomains[domain] = jsonData.keys.toList();
    }

    setState(() {
      _selectedSubDomains = {
        for (var domain in _domains)
          domain: {for (var subDomain in _subDomains[domain] ?? []) subDomain: false}
      };
    });
  }
  Future<Map<String, dynamic>> _getSubDomainsFromJson(String fileName) async {
    String data = await rootBundle.loadString('assets/questions/$fileName');
    return json.decode(data);
  }

  void _toggleDomainSelection(String domain, bool isSelected) {
    setState(() {
      _selectedDomains[domain] = isSelected;
      _selectedSubDomains[domain] = {
        for (var subDomain in _subDomains[domain] ?? []) subDomain: isSelected
      };
    });
  }

  void _toggleSubDomainSelection(String domain, String subDomain, bool isSelected) {
    setState(() {
      _selectedSubDomains[domain]?[subDomain] = isSelected;

      bool allSelected = _selectedSubDomains[domain]!.values.every((isSelected) => isSelected);
      bool noneSelected = _selectedSubDomains[domain]!.values.every((isSelected) => !isSelected);

      if (allSelected) {
        _selectedDomains[domain] = true;
      } else if (noneSelected) {
        _selectedDomains[domain] = false;
      } else {
        _selectedDomains[domain] = false;
      };
    });
  }

  void _startQuiz() {
    List<String> selectedSubDomains = [];
    _selectedSubDomains.forEach((domain, subDomains) {
      subDomains.forEach((subDomain, isSelected) {
        if (isSelected) {
          selectedSubDomains.add(subDomain);
        }
      });
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizScreen(
          selectedSubDomains: selectedSubDomains,
          numberOfQuestions: _numberOfQuestions,
          statisticsService: widget.statisticsService, // Passez ici
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.blueGrey],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: CustomScrollView(
          slivers: [
            // En-tête
            SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                  gradient: LinearGradient(
                    colors: [Colors.black, Colors.blueGrey],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                padding: EdgeInsets.only(top: 2, bottom: 20),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/ours_training.png',
                      height: 220,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(height: 0),
                    Text(
                      'Entrainement',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Configurez votre quiz en sélectionnant les domaines et le nombre de questions.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Liste des domaines et sous-domaines
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: _domains.map((domain) {
                    return Container(
                      margin: EdgeInsets.only(bottom: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade400, Colors.black26],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueAccent.withOpacity(0.3),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: RoundedExpansionTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          tileColor: Colors.transparent,
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                domain,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Switch(
                                activeColor: Colors.white,
                                value: _selectedDomains[domain]!,
                                onChanged: (value) {
                                  _toggleDomainSelection(domain, value);
                                },
                              ),
                            ],
                          ),
                          children: (_subDomains[domain] ?? []).map((subDomain) {
                            return ListTile(
                              title: Text(
                                subDomain,
                                style: TextStyle(fontSize: 14, color: Colors.white70),
                              ),
                              trailing: Switch(
                                activeColor: Colors.white,
                                value: _selectedSubDomains[domain]?[subDomain] ?? false,
                                onChanged: (value) {
                                  _toggleSubDomainSelection(domain, subDomain, value);
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            // Nombre de questions et bouton démarrer
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Text(
                    'Nombre de questions :',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Slider(
                    activeColor: Colors.lightBlueAccent ,
                    inactiveColor: Colors.grey[300],
                    value: _numberOfQuestions.toDouble(),
                    min: 5,
                    max: 50,
                    divisions: 9,
                    label: _numberOfQuestions.toString(),
                    onChanged: (value) {
                      setState(() {
                        _numberOfQuestions = value.toInt();
                      });
                    },
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      backgroundColor: Colors.blue.shade800,
                    ),
                    onPressed: _startQuiz,
                    child: Text(
                      'Commencer le Quiz',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}