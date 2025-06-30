import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webfeed/webfeed.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:opj_master/screens/premium/premium_benefits_screen.dart';
import 'package:opj_master/screens/ranking/ranking_screen.dart';
import '/widgets/leaderboardBox.dart';



class ActualitesScreen extends StatefulWidget {
  @override
  _ActualitesScreenState createState() => _ActualitesScreenState();
}

class _ActualitesScreenState extends State<ActualitesScreen> {
  List<RssItem> _dallozActualites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDallozActualites();
  }

  Future<void> _fetchDallozActualites() async {
    const url = 'https://www.dalloz-actualite.fr/taxonomy/term/291/feed.xml';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final feed = RssFeed.parse(response.body);
        setState(() {
          _dallozActualites = feed.items ?? [];
          _isLoading = false;
        });
      } else {
        print('Failed to load Dalloz feed');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching Dalloz feed: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _removeHtmlTags(String? text) {
    if (text == null) return 'Pas de description disponible.';
    final RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    return text.replaceAll(exp, '');
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Arrière-plan dégradé
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black, Colors.blueGrey], // Dégradé à ajuster
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Contenu de la page
          _isLoading
              ? Center(
            child: CircularProgressIndicator(color: Theme.of(context).primaryColor),
          )
              : SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              children: [
                _buildHeader(),
                LeaderboardBox(),
                _buildPremiumBox(context),
                _rankingButton(),
                _buildDallozActualitesSection(),


              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _rankingButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RankingScreen()),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.teal],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.teal.withOpacity(0.3),
              blurRadius: 6,
              offset: Offset(-2, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.leaderboard, color: Colors.white, size: 28),
            SizedBox(width: 10),
            Text(
              "Voir le Classement",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        gradient: LinearGradient(
          colors: [Colors.black, Colors.blueGrey],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),

      ),
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/ours12.png',
            height: 270,
            fit: BoxFit.cover,
          ),



          SizedBox(height: 2),
          Text(
            "Testez vos compétences, relevez des défis, et découvrez les dernières actualités juridiques.",
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 15),
        ],
      ),
    );
  }

  Widget _buildPremiumBox(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade400, Colors.black26],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.8),
              blurRadius: 15,
              offset: Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.blueGrey.withOpacity(0.4),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
          border: Border.all(color: Colors.black26.withOpacity(0.8), width: 2),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Titre principal
            Text(
              "Passez à la version Premium",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),

            // Images premium
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPremiumImageBox("assets/images/ours_training.png"),
                _buildPremiumImageBox("assets/images/ours_king.png"),
                _buildPremiumImageBox("assets/images/ours_document.png"),
              ],
            ),
            SizedBox(height: 10),

            // Bouton premium
            ElevatedButton(
              onPressed: () {
                // Afficher le popup
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.8,
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: PremiumBenefitsScreen(), // Contenu des avantages premium
                      ),
                    );
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black26,
                foregroundColor: Colors.white,
                elevation: 5,
                shadowColor: Colors.black12.withOpacity(0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              ),
              child: Text(
                "Découvrir les avantages",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumImageBox(String imagePath) {
    return Container(
      height: 80,
      width: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [Colors.white.withOpacity(0.1), Colors.blueGrey.withOpacity(0.4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(2, 2),
          ),
        ],
        border: Border.all(color: Colors.black26.withOpacity(0.7), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Image.asset(
          imagePath,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildDallozActualitesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
        child:
          Text(
            "Actualités Dalloz",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),),
          SizedBox(height: 10),
          if (_dallozActualites.isEmpty)
            Center(
              child: Text(
                "Aucune actualité disponible pour le moment.",
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _dallozActualites.length,
              itemBuilder: (context, index) {
                final article = _dallozActualites[index];
                return GestureDetector(
                  onTap: () {
                    if (article.link != null) {
                      _launchURL(article.link!);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Lien non disponible")),
                      );
                    }
                  },
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            article.title ?? "Pas de titre",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            _removeHtmlTags(article.description),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}






