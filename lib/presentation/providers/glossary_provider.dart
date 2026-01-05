import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/term.dart';
import '../../data/models/glossary_model.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

/// Provider لتحميل مصطلحات القاموس
final glossaryProvider = FutureProvider<List<Term>>((ref) async {
  try {
    final String response = await rootBundle.loadString('assets/data/glossary.json');
    final List<dynamic> data = json.decode(response);
    return GlossaryModel.fromJsonList(data);
  } catch (e) {
    return [];
  }
});

/// Provider للبحث في القاموس - يدعم البحث في جميع اللغات
final glossarySearchProvider = FutureProvider.family<List<Term>, String>((ref, query) async {
  final glossaryAsync = await ref.watch(glossaryProvider.future);
  
  if (query.isEmpty) return glossaryAsync;
  
  final lowerQuery = query.toLowerCase();
  return glossaryAsync.where((term) {
    // البحث في المصطلح الألماني
    if (term.term.toLowerCase().contains(lowerQuery)) return true;
    
    // البحث في جميع التعريفات (جميع اللغات)
    for (final definition in term.definition.values) {
      if (definition.toLowerCase().contains(lowerQuery)) return true;
    }
    
    // البحث في الكلمات المفتاحية
    if (term.keywords.any((keyword) => keyword.toLowerCase().contains(lowerQuery))) {
      return true;
    }
    
    return false;
  }).toList();
});

