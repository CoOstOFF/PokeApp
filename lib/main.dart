import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:pockemon_app/pockemon.dart';
import 'package:pockemon_app/pockemondetail.dart';

Future<PokeHub> getPokemonRequest() async {
  final response = await http.get(
      'https://raw.githubusercontent.com/Biuni/PokemonGO-Pokedex/master/pokedex.json');

  if (response.statusCode == 200) {
    // If the call to the server was successful, parse the JSON
    return PokeHub.fromJson(json.decode(response.body));
  } else {
    // If that call was not successful, throw an error.
    throw Exception('Failed to load pokemons');
  }
}

void main() => runApp(MaterialApp(
    title: "Poke App", home: HomePage(pokeHub: getPokemonRequest())));

class HomePage extends StatefulWidget {
  final Future<PokeHub> pokeHub;

  HomePage({Key key, this.pokeHub}) : super(key: key);

  @override
  HomePageState createState() {
    return new HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("PokeApp"),
          backgroundColor: Colors.cyan,
        ),
        body: _coreWidget());
  }

  Widget _coreWidget() {
    return OrientationBuilder(builder: (context, orientation) {
      return Center(
        child: Center(
            child: FutureBuilder<PokeHub>(
          future: getPokemonRequest(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return _mainDisplayWidget(orientation, snapshot.data);
            } else if (snapshot.hasError) {
              return _notNetworkConnect();
            }
            return CircularProgressIndicator();
          },
        )),
      );
    });
  }

  Widget _mainDisplayWidget(Orientation orientation, PokeHub pokeHub) {
    final double shortestSide = MediaQuery.of(context).size.shortestSide;
    final bool useMobileLayout = shortestSide <= 600;
    double itemImageHeight;
    double itemImageWidth;
    double cardFontSize;
    int itemsInRow;

    if (useMobileLayout) {
      itemsInRow = orientation == Orientation.portrait ? 2 : 3;
      itemImageHeight = 100.0;
      itemImageWidth = 100.0;
      cardFontSize = 20.0;
    } else {
      itemsInRow = orientation == Orientation.portrait ? 3 : 4;
      itemImageHeight = 150.0;
      itemImageWidth = 150.0;
      cardFontSize = 26.0;
    }

    return GridView.count(
      crossAxisCount: itemsInRow,
      children: pokeHub.pokemon
          .map((pokeHub) => Padding(
              padding: const EdgeInsets.all(2.0),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PokeDetail(
                                pokemon: pokeHub,
                              )));
                },
                child: Hero(
                  tag: pokeHub.img,
                  child: Card(
                    elevation: 3.0,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Container(
                          height: itemImageHeight,
                          width: itemImageWidth,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  fit: BoxFit.fill,
                                  image: NetworkImage(pokeHub.img))),
                        ),
                        Text(pokeHub.name,
                            style: TextStyle(
                                fontSize: cardFontSize,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              )))
          .toList(),
    );
  }

  Widget _notNetworkConnect() {
    return Text("Internet error");
  }
}
