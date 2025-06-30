class DomainHelper {
  static String getDomainFromSubDomain(String subDomain) {

    if (["Circonstances aggravantes",
      "Classification des infractions",
      "Classification des peines",
      "La complicité",
      "Concours d'infraction",
      "Généralités",
      "Les infractions",
      "L'irresponsabilité pénale",
      "Les peines",
      "La récidive",
      "La responsabilité pénale",
      "La tentative"
    ].contains(subDomain)) {
      return 'Droit Pénal Général';


    } else if (["Le vol",
      "L'usurpation de fonctions",
      "Le recel",
      "L'organisation d'insolvabilité",
      "L'extorsion, le chantage",
      "L'escroquerie",
      "Les dégradations ,destructions",
      "L'abus de faiblesse",
      "L'abus de confiance",
      "Les atteintes volontaires à la vie",
      "Homicide involontaire",
      "Atteintes involontaires à l'intégrité de la personne",
      "Risques causés à autrui",
      "Tortures_et_actes_de_barbarie",
      "Violences",
      "Enlèvement et séquestration",
      "Rébellion",
      "Agressions sexuelles",
      "Atteintes au respect dû aux morts",
      "Délaissement de mineurs de 15 ans",
      "Abandon de famille",
      "Atteintes à l'exercice de l'autorité parentale",
      "Atteintes à la filiation",
      "Délaissement de personnes hors d'état de se protéger",
      "Stupefiants",
      "Proxénétisme",
      "Association de malfaiteurs",
      "Traite des êtres humains et dissimulation du visage",
      "Exploitation de la personne",
      "Infractions au régime des armes, poudres et explosifs",
      "Menaces",
      "Menaces et actes d'intimidation commis contre les personnes exerçant une fonction publique",
      "Harcèlement moral",
      "Discriminations",
      "Provocation au suicide",
      "Entraves à la saisine de la justice",
      "Entraves à l'exercice de la justice",
      "Entrave aux mesures d'assistance et omission de porter secours",
      "Évasion",
      "Participation délictueuse à un attroupement",
      "Manifestations illicites et participation délictueuse à une manifestation ou à une réunion publique",
      "Atteintes à la liberté individuelle",
      "Dénonciation calomnieuse",
      "Infractions commises par voie de presse ou par tout autre moyen de publication portant atteinte à l'honneur ou à la considération de la personne",
      "Manquements au devoir de probité",
      "Autres manquements au devoir de probité",
      "Atteinte au secret",
      "Atteintes à l'honneur ou au respect",
      "Atteinte à la vie privée",
      "Atteintes au secret des correspondances commises par des personnes exerçant une fonction publique",
      "Atteintes à l'inviolabilité du domicile",
      "Atteinte à la représentation de la personne",
      "Atteintes à la confiance publique - Faux",
      "Atteintes à la confiance publique",
      "Infractions délictuelles à la circulation routière"
    ].contains(subDomain)) {
      return 'Droit Pénal Spécial';

    } else if (["Les APJA, APJ, OPJ",
      "Les auditions, les confrontations",
      "Les cadres d'enquête",
      "Les constatations, les réquisitions",
      "Les contrôles d’identité",
      "La garde à vue",
      "Les mandats",
      "Les perquisitions, les saisies",
      "La police judiciaire",
      "L'action publique",
      "La faute civile et la faute pénale",
      "L'action civile",
      "Les preuves en matière pénale",
      "Le ministère public",
      "Les juridictions d'instruction"
    ].contains(subDomain)) {
      return 'Procédure Pénale';
    }
    return 'Domaine Inconnu';
  }
}