import 'package:flutter/material.dart';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bataille de robots',
      routes: {
        '/': (context) => const MyHomePage(title: 'Bataille de robots'),
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController controller = TextEditingController();
  var monrobot = ' ';
  var robotemenie = ' ';
  Robot? createdRobot;
  Robot? enemyRobot;

  Map<String, Robot> listeRobot = {
    'robot1': Robot('robot1', 100, 15, 20, 100),
    'robot2': Robot('robot2', 100, 10, 10, 150),
    'robot3': Robot('robot3', 80, 40, 30, 200),
  };

  void allerarobot() {
    int random = Random().nextInt(listeRobot.length);
    String nomrobotemenie = listeRobot.keys.elementAt(random);
    enemyRobot = listeRobot[nomrobotemenie];
    robotemenie = enemyRobot!.getNom();
  }

  void createRobot() {
    setState(() {
      String input = controller.text.trim();
      createdRobot = Robot(input, 100, 15, 20, 100);
      monrobot = createdRobot!.getNom();
      allerarobot();
      
      // Stocker le robot ennemi sélectionné
      enemyRobot = listeRobot[robotemenie];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bienvenue dans la bataille des robots',
          style: GoogleFonts.roboto(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/robot.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: ListView(
          children: [
            Column(
              children: [
                Text(
                  'Nom du robot : $monrobot',
                  style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  'Nom du robot ennemi : $robotemenie',
                  style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: 'Entrez le nom du robot',
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: createRobot,
                  icon: const Icon(Icons.check),
                  label: const Text('Valider'),
                ),
                
                    ElevatedButton.icon(
                      onPressed: () {
                        if (createdRobot != null && enemyRobot != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AchatobjectPage(
                                robot: createdRobot!,
                                enemyRobot: enemyRobot!, 
                              ),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.shopping_cart),
                      label: const Text('Shop'),
                    ),
                                  ],
            ),
          ],
        ),
      ),
    );
  }
}

class AchatobjectPage extends StatelessWidget {
  final Robot robot;
  final Robot enemyRobot;

  const AchatobjectPage({super.key, required this.robot, required this.enemyRobot});

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    String message = '';
    return StatefulBuilder(
      builder: (context, setState) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Achat d\'un objet'),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Le crédit est de ${robot.getBudget()}'),
                Text('Liste des objets achetés : ${robot.getPurchasedObjects().map((obj) => obj.getNom()).join(', ')}'),
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: 'Entrez le nom de l\'objet ',
                  ),
                ),
                Column(
                  children: Object.getEquipements().values.map((obj) {
                    return Text('Le ${obj.getNom()} coûte ${obj.getPrix()} crédits.');
                  }).toList(),
                ),
                Text(message, style: const TextStyle(color: Colors.red)),
                ElevatedButton.icon(
                  onPressed: () {
                    String input = controller.text.trim().toLowerCase();
                    if (Object.getEquipements().containsKey(input)) {
                      final selectedObject = Object.getEquipements()[input]!;
                      if (robot.getBudget() >= selectedObject.getPrix()) {
                        robot.acheteobject(selectedObject);
                        setState(() {
                          message = 'Achat réussi.';
                        });
                      } else {
                        setState(() {
                          message = 'Budget insuffisant.';
                        });
                      }
                    } else {
                      setState(() {
                        message = 'Objet "$input" non trouvé.';
                      });
                    }
                  },
                  icon: const Icon(Icons.shopping_cart),
                  label: const Text('Acheter'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Customize(robot: robot),
                      ),
                    );
                  },
                  icon: const Icon(Icons.settings),
                  label: const Text('Personnaliser le robot'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CombatPage(
                          robotJoueur: robot,
                          robotEnnemi: enemyRobot, 
                        ),
                      ),
                    );
                  },
                  child: const Text('Aller au combat'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Retour'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class Customize extends StatefulWidget {
  final Robot robot;

  const Customize({super.key, required this.robot});

  @override
  State<Customize> createState() => _CustomizeState();
}

class _CustomizeState extends State<Customize> {
  int points = 10;
  int sante = 0;
  int attaque = 0;
  int defense = 0;

  void increment(String category) {
    if (points > 0) {
      setState(() {
        points--;
        if (category == 'sante') sante++;
        if (category == 'attaque') attaque++;
        if (category == 'defense') defense++;
      });
    }
  }

  void decrement(String category) {
    setState(() {
      if (category == 'sante' && sante > 0) {
        sante--;
        points++;
      }
      if (category == 'attaque' && attaque > 0) {
        attaque--;
        points++;
      }
      if (category == 'defense' && defense > 0) {
        defense--;
        points++;
      }
    });
  }

  void applyChanges() {
    setState(() {
      widget.robot.setSante(widget.robot.getSante() + sante);
      widget.robot.setAttaque(widget.robot.getAttaque() + attaque);
      widget.robot.setDefense(widget.robot.getDefense() + defense);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Les points ont été appliqués au robot ${widget.robot.getNom()}')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customize Robot'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(''),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Points restants: $points'),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Santé: '),
                IconButton(
                  onPressed: () => decrement('sante'),
                  icon: const Icon(Icons.remove),
                ),
                Text('$sante'),
                IconButton(
                  onPressed: () => increment('sante'),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Attaque: '),
                IconButton(
                  onPressed: () => decrement('attaque'),
                  icon: const Icon(Icons.remove),
                ),
                Text('$attaque'),
                IconButton(
                  onPressed: () => increment('attaque'),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Défense: '),
                IconButton(
                  onPressed: () => decrement('defense'),
                  icon: const Icon(Icons.remove),
                ),
                Text('$defense'),
                IconButton(
                  onPressed: () => increment('defense'),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: points == 0 ? applyChanges : null,
              child: const Text('Appliquer les changements'),
            ),
          ],
        ),
      ),
    );
  }
}


class _CombatPageState extends State<CombatPage> {
  List<String> logCombat = [];
  bool combatTermine = false;

  final ScrollController _scrollController = ScrollController(); 
  // Ajout du contrôleur

  @override
  void initState() {
    super.initState();
    _startCombat();
  }

  void _startCombat() {
    logCombat.add("Début du combat !");
    logCombat.add("${widget.robotJoueur.getNom()} (PV: ${widget.robotJoueur.getSante()})");
    logCombat.add("VS");
    logCombat.add("${widget.robotEnnemi.getNom()} (PV: ${widget.robotEnnemi.getSante()})");

    // Scroll automatique en bas
    _scrollToBottom();
  }

  void _attaque() {
    if (combatTermine) return;

    setState(() {
      // Attaque du joueur
      int degatsJoueur = max(0, widget.robotJoueur.getAttaque() - widget.robotEnnemi.getDefense());
      widget.robotEnnemi.setSante(widget.robotEnnemi.getSante() - degatsJoueur);
      logCombat.add("${widget.robotJoueur.getNom()} attaque → ${degatsJoueur} dégâts");

      // Vérification mort ennemi
      if (widget.robotEnnemi.getSante() <= 0) {
        logCombat.add("${widget.robotEnnemi.getNom()} est détruit !");
        combatTermine = true;
        _scrollToBottom(); // Défilement
        return;
      }

      // Contre-attaque
      int degatsEnnemi = max(0, widget.robotEnnemi.getAttaque() - widget.robotJoueur.getDefense());
      widget.robotJoueur.setSante(widget.robotJoueur.getSante() - degatsEnnemi);
      logCombat.add("${widget.robotEnnemi.getNom()} contre-attaque → ${degatsEnnemi} dégâts");

      // Vérification mort joueur
      if (widget.robotJoueur.getSante() <= 0) {
        logCombat.add("${widget.robotJoueur.getNom()} est détruit !");
        combatTermine = true;
      }

      // Scroll automatique en bas
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Combat')),
      body: Column(
        children: [
          // Affichage des stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildRobotStats(widget.robotJoueur),
              _buildRobotStats(widget.robotEnnemi),
            ],
          ),

          // Log de combat avec Scrollbar
          Expanded(
            child: Scrollbar(
              controller: _scrollController, // Liaison avec le ScrollController
              thumbVisibility: true, // Optionnel
              child: ListView.builder(
                controller: _scrollController, // Utilisation du ScrollController
                itemCount: logCombat.length,
                itemBuilder: (context, index) => ListTile(
                  title: Text(logCombat[index]),
                ),
              ),
            ),
          ),

          // Bouton d'attaque
          ElevatedButton(
            onPressed: combatTermine ? null : _attaque,
            child: Text(combatTermine ? 'Fin du combat' : 'Attaquer'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Nettoyage
    super.dispose();
  }

  Widget _buildRobotStats(Robot robot) {
    return Column(
      children: [
        Text(robot.getNom(), style: const TextStyle(fontSize: 20)),
        Text('PV: ${robot.getSante()}'),
        Text('Attaque: ${robot.getAttaque()}'),
        Text('Défense: ${robot.getDefense()}'),
      ],
    );
  }
}


class CombatPage extends StatefulWidget {
  final Robot robotJoueur;
  final Robot robotEnnemi;

  const CombatPage({super.key, required this.robotJoueur, required this.robotEnnemi});

  @override
  State<CombatPage> createState() => _CombatPageState();
}

class Robot {
  String _mon;
  int _sante;
  int _attaque;
  int _defense;
  int _budget;
  final List<Object> _purchasedObjects = [];

  Robot(this._mon, this._sante, this._attaque, this._defense, this._budget);

  String getNom() {
    return _mon;
  }

  void setNom(String nom) {
    _mon = nom;
  }

  int getSante() {
    return _sante;
  }

  void setSante(int sante) {
    _sante = sante;
  }

  int getAttaque() {
    return _attaque;
  }

  void setAttaque(int attaque) {
    _attaque = attaque;
  }

  int getDefense() {
    return _defense;
  }

  void setDefense(int defense) {
    _defense = defense;
  }

  int getBudget() {
    return _budget;
  }

  void setBudget(int budget) {
    _budget = budget;
  }

  List<Object> getPurchasedObjects() {
    return _purchasedObjects;
  }

  void acheteobject(Object object) {
    if (_budget >= object.getPrix()) {
      _budget -= object.getPrix();
      _purchasedObjects.add(object);
      print("${_mon} a acheté ${object.getNom()} pour ${object.getPrix()} crédits.");
    } else {
      print("${_mon} n'a pas assez de budget pour acheter ${object.getNom()}.");
    }
  }

 
  void soigne() {
    if (_sante <= 0) {
      print("${_mon} ne peut pas se soigner car il est mort.");
    } else {
      _sante += 50;
      print("${_mon} se soigne et récupère 50 points de vie.");
    }
  }
}


class Object {
  static final Map<String, Object> _equipements = {
    "epee": Object("epee", 10, 0, 50, 0, 1),
    "bouclier": Object("bouclier", 0, 10, 60, 0, 2),
    "potion": Object("potion", 0, 0, 50, 50, 3),
  };

  final String _nom;
  final int _bonusAttaque;
  final int _bonusDefense;
  final int _prix;
  final int _pointsDeVie;
  final int _type;

  Object(
    this._nom,
    this._bonusAttaque,
    this._bonusDefense,
    this._prix,
    this._pointsDeVie,
    this._type,
  );

  static Map<String, Object> getEquipements() {
    return _equipements;
  }

  String getNom() {
    return _nom;
  }

  int getBonusAttaque() {
    return _bonusAttaque;
  }

  int getBonusDefense() {
    return _bonusDefense;
  }

  int getPrix() {
    return _prix;
  }

  int getPointsDeVie() {
    return _pointsDeVie;
  }

  int getType() {
    return _type;
  }
}

class Arena {
  String listeObjects() {
    Map<String, Object> equipements = Object.getEquipements();
    String liste = "Liste des objets disponibles :\n";
    for (String nom in equipements.keys) {
      var equipement = equipements[nom];
      if (equipement != null) {
        liste += "- $nom : ${equipement.getPrix()} crédits\n";
      }
    }
    return liste;
  }

  void combatsrobot(Robot robot1, Robot robot2) {
    while (robot1.getSante() > 0 && robot2.getSante() > 0) {
      int degats1 = robot1.getAttaque() - robot2.getDefense();
      if (degats1 > 0) {
        robot2.setSante(robot2.getSante() - degats1);
        print("${robot1.getNom()} attaque ${robot2.getNom()} et inflige $degats1 dégâts.");
      }
      if (robot2.getSante() <= 0) break;

      int degats2 = robot2.getAttaque() - robot1.getDefense();
      if (degats2 > 0) {
        robot1.setSante(robot1.getSante() - degats2);
        print("${robot2.getNom()} contre-attaque et inflige $degats2 dégâts.");
      }
      if (robot1.getSante() <= 0) break;
    }
    if (robot1.getSante() <= 0) {
      print("${robot1.getNom()} est mort!");
    } else {
      print("${robot2.getNom()} est mort!");
    }
  }
} 