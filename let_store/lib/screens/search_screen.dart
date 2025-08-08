import 'package:flutter/material.dart';
import 'package:let_store/features/widgets/product_grid.dart';

import '../features/widgets/custom_search_bar.dart';
import '../models/product.dart';

class SearchScreen extends StatefulWidget {
  final List<Product> searchResults;
  final String bearerToken;
  const SearchScreen({
    super.key,
    required this.searchResults,
    required this.bearerToken,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Product> _searchResults = [];

  bool _isLoading = false;
  bool _hasSearched = false;

  void _handleSearch(List<Product> products) {
    setState(() {
      _searchResults = products;
      _hasSearched = true;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CustomSearchBar(
              bearerToken: widget.bearerToken,
              onSearchStart: () {
                setState(() {
                  _isLoading = true;
                  _hasSearched = false;
                });
              },
              onSearchResults: _handleSearch,
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _searchResults.isNotEmpty
                  ? ProductGrid(
                      allProducts: _searchResults,
                      bearerToken: widget.bearerToken,
                    )
                  : _hasSearched
                  ? const Center(child: Text('No results found.'))
                  : const Center(child: Text('Search for a product')),
            ),
          ],
        ),
      ),
    );
  }
}
