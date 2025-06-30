import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/statistics_service.dart';

class StatistiquesScreen extends StatefulWidget {
  final StatisticsService statisticsService;

  StatistiquesScreen({required this.statisticsService});

  @override
  _StatistiquesScreenState createState() => _StatistiquesScreenState();
}

class _StatistiquesScreenState extends State<StatistiquesScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Statistiques',
          style: GoogleFonts.lato(
            textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
        elevation: 8,
      ),
      body: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(seconds: 2),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black,
                  Colors.blueGrey,
                  Colors.black,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          FutureBuilder<Map<String, dynamic>>(
            future: widget.statisticsService.getAllStatistics(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator(color: Colors.white));
              } else if (snapshot.hasError) {
                return _buildErrorState(snapshot.error.toString());
              } else if (!snapshot.hasData || snapshot.data == null) {
                return _buildEmptyState();
              }

              final stats = snapshot.data!;
              final globalStats = stats['globalStats'] ?? {};
              final domainStats = stats['domainStats'] ?? {};
              final allSubDomains = _extractSubDomainStats(domainStats);

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGlobalStatisticsCard(globalStats, screenWidth),
                    _buildDomainAndSubDomainStatistics(domainStats, screenHeight, screenWidth),
                    _buildTopAndBottomSubDomains(allSubDomains, screenWidth),
                    _buildResetButton(screenWidth),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGlobalStatisticsCard(Map<String, dynamic> globalStats, double screenWidth) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      width: screenWidth * 0.9,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.black26],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart_rounded, color: Colors.white, size: 28),
              SizedBox(width: 10),
              Text(
                'Statistiques Globales',
                style: GoogleFonts.poppins(
                  textStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Divider(color: Colors.white.withOpacity(0.5), thickness: 1),
          SizedBox(height: 10),
          _buildStatRow('Temps moyen de réponse :', '${globalStats['averageResponseTime']?.toStringAsFixed(2) ?? "N/A"} sec.'),
          SizedBox(height: 8),
          _buildStatRow('% de bonnes réponses :', '${globalStats['globalAccuracy']?.toStringAsFixed(2) ?? "N/A"}%'),
        ],
      ),
    );
  }
  Widget _buildStatRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          Text(
            value,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildDomainAndSubDomainStatistics(
      Map<String, dynamic> domainStats, double screenHeight, double screenWidth) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [


          SizedBox(height: 2),
          ...domainStats.entries.map((entry) {
            final domainName = entry.key;
            final domainData = entry.value;
            final domainAccuracy = domainData['accuracy']?.toStringAsFixed(2) ?? 'N/A';
            final subDomains = (domainData['subDomains'] ?? {}) as Map<String, dynamic>;

            final sortedSubDomains = subDomains.entries.toList()
              ..sort((a, b) => (b.value['accuracy'] ?? 0.0).compareTo(a.value['accuracy'] ?? 0.0));

            return Card(
              elevation: 5,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ExpansionTile(
                title: Text(
                  domainName,
                  style: GoogleFonts.openSans(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Précision : $domainAccuracy%'),
                children: sortedSubDomains.map<Widget>((subEntry) {
                  final subDomainName = subEntry.key;
                  final subAccuracy = subEntry.value['accuracy']?.toStringAsFixed(2) ?? 'N/A';

                  return ListTile(
                    title: Text(subDomainName),
                    trailing: Text('$subAccuracy%'),
                  );
                }).toList(),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTopAndBottomSubDomains(List<Map<String, dynamic>> allSubDomains, double screenWidth) {
    allSubDomains.sort((a, b) => b['accuracy'].compareTo(a['accuracy']));

    final topSubDomains = allSubDomains.take(5).toList();
    final bottomSubDomains = allSubDomains.reversed.take(5).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildExpandableTile('Sujets maitrisés', topSubDomains, Colors.green, screenWidth),
          SizedBox(height: 16),
          _buildExpandableTile('Sujets à améliorer', bottomSubDomains, Colors.red, screenWidth),
        ],
      ),
    );
  }

  Widget _buildExpandableTile(
      String title, List<Map<String, dynamic>> subDomains, Color color, double screenWidth) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 1),
      child: ExpansionTile(
        title: Text(
          title,
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: color),
        ),
        children: subDomains.map((subDomain) {
          return ListTile(
            title: Text(
              subDomain['name'],
              style: TextStyle(color: Colors.black),
            ),
            trailing: Text(
              '${subDomain['accuracy'].toStringAsFixed(2)}%',
              style: TextStyle(color: Colors.black),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildResetButton(double screenWidth) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 70.0, vertical: 10.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            backgroundColor: Colors.redAccent,
            elevation: 8,
            shadowColor: Colors.black54,
          ),
          onPressed: () async {
            final confirm = await _showResetConfirmationDialog();
            if (confirm) {
              await widget.statisticsService.resetStatistics();
              setState(() {});
            }
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.refresh, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Réinitialiser',
                style: GoogleFonts.lato(
                  textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Future<bool> _showResetConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Réinitialisation'),
        content: Text('Voulez-vous réinitialiser toutes les statistiques ?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text('Annuler')),
          ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: Text('Confirmer')),
        ],
      ),
    ) ??
        false;
  }

  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, color: Colors.red, size: 60),
          SizedBox(height: 10),
          Text(
            'Erreur lors du chargement.',
            style: GoogleFonts.lato(color: Colors.red, fontSize: 18),
          ),
          Text(
            errorMessage,
            style: TextStyle(color: Colors.grey, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart, color: Colors.grey, size: 80),
          SizedBox(height: 10),
          Text(
            'Aucune statistique disponible.',
            style: GoogleFonts.lato(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _extractSubDomainStats(Map<String, dynamic> domainStats) {
    final subDomainList = <Map<String, dynamic>>[];

    domainStats.forEach((domain, data) {
      final subDomains = data['subDomains'] ?? {};
      subDomains.forEach((subDomainName, subDomainData) {
        final accuracy = subDomainData['accuracy'] ?? 0.0;
        subDomainList.add({'name': subDomainName, 'accuracy': accuracy});
      });
    });

    return subDomainList;
  }
}