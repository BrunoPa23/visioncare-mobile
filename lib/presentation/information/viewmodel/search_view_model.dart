import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final searchViewModelProvider =
    ChangeNotifierProvider.autoDispose<SearchViewModel>(
  (ref) => SearchViewModel(),
);

class SearchViewModel extends ChangeNotifier {
  final TextEditingController searchController = TextEditingController();
}