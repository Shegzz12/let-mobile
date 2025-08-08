import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../models/product.dart';
import '/utils/app_textstyles.dart';

class CustomSearchBar extends StatefulWidget {
  final String bearerToken;
  final void Function(List<Product>)? onSearchResults;
  final VoidCallback? onSearchStart;
  final VoidCallback? onSearchClosed;
  final ValueChanged<bool>? onExpandedChanged; // Callback for expansion state

  const CustomSearchBar({
    super.key,
    required this.onSearchResults,
    this.onSearchStart,
    this.onSearchClosed,
    this.onExpandedChanged,
    required this.bearerToken,
  });

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
    // Immediately request focus when the search bar is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    // If search bar loses focus, collapse it
    if (!_focusNode.hasFocus) {
      _collapseSearchBar();
    }
  }

  void _collapseSearchBar() {
    _controller.clear(); // Clear text when collapsing
    _focusNode.unfocus(); // Unfocus when collapsing
    widget.onSearchClosed?.call(); // Notify parent that search is closed
    widget.onExpandedChanged?.call(false); // Notify parent about collapse
  }

  void _submitSearch() {
    final query = _controller.text.trim();
    if (query.isNotEmpty) {
      widget.onSearchStart
          ?.call(); // Only call onSearchStart when search is submitted
      searchProductsByName(query);
      _focusNode.unfocus(); // Unfocus after submitting
    } else {
      _collapseSearchBar(); // If empty, just collapse
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // This widget always renders as the expanded search bar
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: 48, // Fixed height for the search bar
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800]! : Colors.grey[100]!,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).primaryColor, width: 1),
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        onSubmitted: (_) => _submitSearch(), // Trigger search on Enter
        textAlign: TextAlign.center, // Center the hint text
        style: AppTextStyle.withColor(
          AppTextStyle.buttonMedium,
          Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
        ),
        decoration: InputDecoration(
          hintText: 'Search',
          hintStyle: AppTextStyle.withColor(
            AppTextStyle.buttonMedium,
            isDark ? Colors.grey[400]! : Colors.grey[600]!,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          suffixIcon: IconButton(
            // Search icon inside the bar, to the right
            icon: Icon(
              Icons.search,
              color: isDark ? Colors.grey[300]! : Colors.grey[800]!,
            ),
            onPressed: _submitSearch, // Trigger search on icon click
          ),
        ),
      ),
    );
  }

  Future<void> searchProductsByName(String keyword) async {
    final url = Uri.https(
      'let-commerce.onrender.com',
      '/api/products/search/name',
      {'q': keyword},
    );
    // print(url.toString());
    final token = widget.bearerToken;
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        // print('Search result: $body');
        final List<dynamic> productList = body is List
            ? body
            : (body['products'] ?? []);
        final results = productList
            .map((json) => Product.fromJson(json, widget.bearerToken))
            .toList();
        widget.onSearchResults?.call(results);
      } else {
        // print('Search failed. Status: ${response.statusCode}');
        widget.onSearchResults?.call([]); // Clear results on failure
      }
    } catch (e) {
      // print(e);
      widget.onSearchResults?.call([]); // Clear results on error
    }
  }
}
