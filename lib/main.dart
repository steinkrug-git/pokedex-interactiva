import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'pokemon_detail_screen.dart'; 

const pokemonApiUrl = 'https://pokeapi.co/api/v2/pokemon'; 

void main() {
  runApp(PokeDexApp());
}

class PokeDexApp extends StatelessWidget {
  const PokeDexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi pokédex interactiva',
      home: PokemonList(),
    );
  }
}

class PokemonList extends StatefulWidget {
  const PokemonList({super.key});

  @override
  State<PokemonList> createState() => _PokemonListState();
}

class _PokemonListState extends State<PokemonList> {
  List<Map<String, dynamic>> pokemonMapList = [];
  bool isLoading = false;
  int offset = 0;
  final int limit = 20;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    getPokemonList();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !isLoading) {
        getPokemonList();
      }
    });
  }

  Future<void> getPokemonList() async {
    if (isLoading || offset >= 1500) return;

    setState(() {
      isLoading = true;
    });

    final url = Uri.parse('$pokemonApiUrl?limit=$limit&offset=$offset');
    
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List results = data['results'];

        List<Map<String, dynamic>> newPokemons = [];

        for (var i = 0; i < results.length; i++) {
          int realId = offset + i + 1;
          final imageUrl = 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$realId.png';

          newPokemons.add({
            'id': realId,
            'name': results[i]['name'],
            'image': imageUrl,
          });
        }

        setState(() {
          pokemonMapList.addAll(newPokemons);
          offset += limit;
          isLoading = false;
        });
      } else {
        throw Exception('Error al cargar');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error: $e");
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Listado de Pokémones"),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: PokemonSearchDelegate(),
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: pokemonMapList.length + 1,
              itemBuilder: (context, index) {
                if (index == pokemonMapList.length) {
                  return isLoading
                      ? Center(child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ))
                      : SizedBox.shrink();
                }

                final pokemon = pokemonMapList[index];
                
                return ListTile(
                  leading: Image.network(pokemon['image']),
                  title: Text(pokemon['name'].toString()),
                
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PokemonDetailScreen(
                          id: pokemon['id'],
                          name: pokemon['name'],
                          imageUrl: pokemon['image'],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class PokemonSearchDelegate extends SearchDelegate {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = ''; 
        },
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.trim().isEmpty) {
      return Center(child: Text("Escribe un nombre de Pokémon"));
    }

    return FutureBuilder(
      future: http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon/${query.toLowerCase()}')),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || snapshot.data?.statusCode != 200) {
          return Center(child: Text("No se encontraron resultados"));
        }

        final data = jsonDecode(snapshot.data!.body);
        
        return ListView(
          padding: EdgeInsets.all(16),
          children: [
            ListTile(
              leading: Image.network(
                data['sprites']['front_default'] ?? '', 
                errorBuilder: (_,__,___) => Icon(Icons.error),
              ),
              title: Text(
                data['name'].toString().toUpperCase(),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text("#${data['id']}"),
          
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PokemonDetailScreen(
                      id: data['id'],
                      name: data['name'],
                      imageUrl: data['sprites']['front_default'] ?? '',
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Center(
      child: Text("Busca por nombre (ej: pikachu)"),
    );
  }
}