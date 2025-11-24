
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PokemonDetailScreen extends StatefulWidget {
  final int id;
  final String name;
  final String imageUrl;

  const PokemonDetailScreen({
    super.key,
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  @override
  State<PokemonDetailScreen> createState() => _PokemonDetailScreenState();
}

class _PokemonDetailScreenState extends State<PokemonDetailScreen> {
  Map<String, dynamic>? pokemonDetails;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDetails();
  }

  Future<void> fetchDetails() async {
    final url = Uri.parse('https://pokeapi.co/api/v2/pokemon/${widget.id}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          pokemonDetails = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Error API');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name.toUpperCase()),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : pokemonDetails == null
              ? Center(child: Text("Error al cargar detalles"))
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      Container(
                        height: 200,
                        width: 200,
                        color: Colors.grey[200],
                        child: Image.network(
                          widget.imageUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Icon(Icons.person, size: 50),
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        "#${widget.id} ${widget.name.toUpperCase()}",
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20),
                      Wrap(
                        spacing: 10,
                        children: (pokemonDetails!['types'] as List).map((t) {
                          return Chip(
                            label: Text(t['type']['name'].toUpperCase()),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              Text("Altura", style: TextStyle(color: Colors.grey)),
                              Text("${pokemonDetails!['height'] / 10} m",
                                  style: TextStyle(fontSize: 18)),
                            ],
                          ),
                          Column(
                            children: [
                              Text("Peso", style: TextStyle(color: Colors.grey)),
                              Text("${pokemonDetails!['weight'] / 10} kg",
                                  style: TextStyle(fontSize: 18)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
    );
  }
}