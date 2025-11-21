import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const pokemonApiUrl = 'https://pokeapi.co/api/v2/pokemon?limit=1500';
const pokemonImageBaseUrl =
    'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/';
const frontImageExtension = '.png';

void main() {
  runApp(PokeDexApp());
}

class PokeDexApp extends StatelessWidget {
  const PokeDexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Mi pokédex interactiva', home: PokemonList());
  }
}

class PokemonList extends StatefulWidget {
  const PokemonList({super.key});

  @override
  State<PokemonList> createState() => _PokemonListState();
}

class _PokemonListState extends State<PokemonList> {
  List<Map<String, dynamic>> pokemonMapList = [];

  @override
  void initState() {
    super.initState();
    getPokemonList();
  }

  Future<void> getPokemonList() async {
    final response = await http.get(Uri.parse(pokemonApiUrl));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List results = data['results'];

      List<Map<String, dynamic>> retrievedPokemons = [];

      var id = 1;

      for (var pokemon in results) {
        final pokemonName = pokemon['name'];
        final pokemonId = id;
        final imageUrl = '$pokemonImageBaseUrl$id$frontImageExtension';

        retrievedPokemons.add({
          'id': pokemonId,
          'name': pokemonName,
          'image': imageUrl,
        });

        id++;
      }

      setState(() {
        pokemonMapList = retrievedPokemons;
      });
    } else {
      throw Exception('Failed to retrieve data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Listado de Pokémones"),),
      body: pokemonMapList.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Scrollbar(child: ListView.builder(
              itemCount: pokemonMapList.length,
              itemBuilder: (context, index) {
                final pokemon = pokemonMapList[index];
                return ListTile(
                  leading: Image.network(pokemon['image']),
                  title: Text(
                    pokemon['name'].toString(),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),)
    );
  }
}
