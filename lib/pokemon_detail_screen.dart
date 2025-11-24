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
  bool isError = false;

  @override
  void initState() {
    super.initState();
    fetchPokemonDetails();
  }

  Future<void> fetchPokemonDetails() async {
    final url = Uri.parse('https://pokeapi.co/api/v2/pokemon/${widget.id}');
    
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          pokemonDetails = data;
          isLoading = false;
        });
      } else {
        throw Exception('Error API');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        isError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name.toUpperCase()),
        backgroundColor: Colors.redAccent,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : isError
              ? Center(child: Text("Error al cargar detalles"))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.all(20),
                        height: 200,
                        width: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Hero(
                          tag: widget.id,
                          child: Image.network(
                            widget.imageUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Icon(Icons.person, size: 80),
                          ),
                        ),
                      ),

                      Text(
                        "#${widget.id} ${widget.name.toUpperCase()}",
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      
                      SizedBox(height: 20),

                      Wrap(
                        spacing: 10,
                        children: (pokemonDetails!['types'] as List).map((t) {
                          return Chip(
                            label: Text(
                              t['type']['name'].toUpperCase(),
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.redAccent,
                          );
                        }).toList(),
                      ),

                      SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatCard("Altura", "${pokemonDetails!['height'] / 10} m"),
                          _buildStatCard("Peso", "${pokemonDetails!['weight'] / 10} kg"),
                        ],
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(label, style: TextStyle(color: Colors.grey, fontSize: 16)),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
