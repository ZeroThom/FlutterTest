import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'modalGPT.dart' as modal;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Word App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  var favorites = <WordPair>[];
  var history = <WordPair>[];
  var results = <WordPair>[];
  
  void getNext() {
    history.add(current);
    results = history;
    current = WordPair.random();
    notifyListeners();
  }

  void getPrev() {
    if(history.isEmpty) return;
    current = history[history.length -1];
    history.removeAt(history.length-1);
    notifyListeners();
  }
  
  void toggleFavorites(){
    if(favorites.contains(current)){
      favorites.remove(current);
    }else{
      favorites.add(current);
    }
    notifyListeners();
  }
  
  void removeFavorite(WordPair pair) {
    favorites.remove(pair);
    notifyListeners();
  }

  void changeSearch(value){
    results = history;

    if(history.isEmpty) {
      results=history;
    } else {
      results=history.where((word) =>word.asLowerCase.contains(value.toLowerCase())).toList();
    }
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  var selectedIndex = 0;
  var isSmall = false;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
      case 1:
        page = FavoritesPage();
      case 2:
        page = HistoryPage();
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
    return LayoutBuilder(
      builder: (context,constraints) {
        if(constraints.maxWidth <= 600){
          return Scaffold(
            body: Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: page,
            ),
            bottomNavigationBar:  BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home), 
                  label: "Home"
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.favorite), 
                  label: "Favorites"
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.history),
                  label: "History"
                )
              ],
              currentIndex: selectedIndex,
              onTap: (index) {
                setState(() {
                  selectedIndex = index;
                });
              },
            ),
          );
        }else{
          return Scaffold(
            body: Row(
              children: [
                SafeArea(
                  child: NavigationRail(
                    extended: (constraints.maxWidth<=750)? false:true,
                    destinations: [
                      NavigationRailDestination(
                        icon: Icon(Icons.home), 
                        label: Text("Home")
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.favorite), 
                        label: Text("Favorites")
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.history),
                        label: Text("History")
                      )
                    ],
                    selectedIndex: selectedIndex,
                    onDestinationSelected:(value) {
                      setState(() {
                        selectedIndex = value;
                      });
                    },
                  )
                ),
                Expanded(
                  child: Container(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: page,
                  )
                )
              ],
            ),
          );
        }
      }
    );
  }
}

class GeneratorPage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(  
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Generate your word:'),
          BigCard(pair: pair),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  appState.getPrev();
                }, 
                child: Text('Previous'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorites();
                }, 
                icon: Icon(icon),
                label: Text('Like'),
              ),
              ElevatedButton(
                onPressed: () {
                  appState.getNext(); 
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    var appState = context.watch<MyAppState>();

    if(appState.favorites.isEmpty){
      return Center(child: Text("You have nothing in your favorites."));
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have ${appState.favorites.length} favorites:'),
        ),
        for (var pair in appState.favorites)
          ListTile(
            leading: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () { 
                appState.removeFavorite(pair);
              },
              tooltip: "Delete",
            ),
            title: Text(pair.asLowerCase),
          ),
      ],
    );
  } 
}

class HistoryPage extends StatelessWidget{

void modalDialog(BuildContext context, WordPair pair) async{//jsonDecode((await http.get(Uri.parse("https://api.dictionaryapi.dev/api/v2/entries/en/${pair.second}"))).body);
    showDialog<void>(
      context: context, 
      builder: (context) {
        return AlertDialog(
          title: Text("Definition"),
          content: SizedBox(
            width: 300.0,
            height: 300.0,
            child: ListView.builder(
              itemCount: 2,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(
                    (index==0)?pair.first:pair.second,
                    //"${(index == 0)?firstDefinition[0]['word']:secondDefinition[0]['word']}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    )
                  ),
                  subtitle: Text("Hello")//Text("${(index==0)?firstDefinition[0]['meanings'][0]['definitions'][0]['definition']:secondDefinition[0]['meanings'][0]['definitions'][0]['definition']}"),
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: TextField(
            onChanged: (value) => appState.changeSearch(value),
            decoration: InputDecoration(
              labelText: 'Search',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Expanded(
          child:(appState.results.isNotEmpty) ? ListView.builder(
            itemCount: appState.results.length,
            itemBuilder: (BuildContext context, int index) {
              final pair = appState.results[index];
              return ListTile(
                leading: IconButton(
                  icon: Icon(Icons.info_outline),
                  onPressed: () => modal.modalDialog(context,pair),
                  tooltip: "Info",
                ),
                title: Text(pair.asLowerCase),
              );
            },
          )
          : Center(child: Text("You have nothing in your history."))
        ),
      ],
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,  
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onSecondary,
    );
    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}