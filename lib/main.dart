import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

    // Listener para detectar el fin de la lista
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !isLoading) {
        getPokemonList();
      }
    });
  }

  Future<void> getPokemonList() async {
    // Tope de seguridad de 1500 
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
      appBar: AppBar(title: Text("Listado de Pokémones")),
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
                
                // Diseño básico temporal (Catalina lo mejorará después)
                return ListTile(
                  leading: Image.network(pokemon['image']),
                  title: Text(pokemon['name'].toString()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
