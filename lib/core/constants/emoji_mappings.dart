/// Emoji mappings for expense categories based on keywords
class EmojiMappings {
  // Keyword to emoji mapping (lowercase keywords)
  static const Map<String, String> _mappings = {
    // Food & Dining
    'food': '🍔',
    'lunch': '🍔',
    'dinner': '🍔',
    'breakfast': '🍳',
    'snack': '🍪',
    'restaurant': '🍽️',
    'pizza': '🍕',
    'burger': '🍔',
    'coffee': '☕',
    'tea': '☕',
    'drink': '🥤',
    'bar': '🍺',
    'beer': '🍺',
    'ice-cream': '🍨',
    'ice cream': '🍨',
    'cake': '🎂',
    
    // Transportation
    'travel': '🚕',
    'taxi': '🚕',
    'uber': '🚕',
    'ola': '🚕',
    'rapido': '🚕',
    'transport': '🚌',
    'bus': '🚌',
    'train': '🚂',
    'metro': '🚇',
    'flight': '✈️',
    'petrol': '⛽',
    'fuel': '⛽',
    'gas': '⛽',
    'parking': '🅿️',
    
    // Shopping
    'shopping': '🛒',
    'shop': '🛍️',
    'mall': '🛍️',
    'clothes': '👕',
    'clothing': '👕',
    'shoes': '👟',
    'grocery': '🛒',
    'groceries': '🛒',
    'market': '🛒',
    'supermarket': '🛒',
    
    // Housing
    'rent': '🏠',
    'house': '🏠',
    'home': '🏠',
    'electricity': '💡',
    'water': '💧',
    'maintenance': '🔧',
    
    // Entertainment
    'movie': '🎬',
    'cinema': '🎬',
    'game': '🎮',
    'gaming': '🎮',
    'music': '🎵',
    'concert': '🎤',
    'party': '🎉',
    'event': '🎪',
    
    // Health & Fitness
    'hospital': '🏥',
    'doctor': '⚕️',
    'medicine': '💊',
    'pharmacy': '💊',
    'gym': '💪',
    'fitness': '💪',
    'yoga': '🧘',
    
    // Education
    'book': '📚',
    'books': '📚',
    'education': '📚',
    'course': '📖',
    'school': '🏫',
    'college': '🎓',
    'university': '🎓',
    
    // Bills & Utilities
    'bill': '📄',
    'bills': '📄',
    'phone': '📱',
    'mobile': '📱',
    'internet': '🌐',
    'subscription': '💳',
    
    // Gifts & Donations
    'gift': '🎁',
    'present': '🎁',
    'donation': '💝',
    'charity': '💝',
    
    // Personal Care
    'salon': '💇',
    'haircut': '💇',
    'spa': '💆',
    'beauty': '💄',
    
    // Miscellaneous
    'atm': '🏧',
    'bank': '🏦',
    'cash': '💵',
    'invest': '📈',
    'investment': '📈',
    'savings': '💰',
    'insurance': '🛡️',
  };
  
  /// Default emoji when no match is found
  static const String defaultEmoji = '💰';
  
  /// Get emoji for a given title/keyword
  /// Searches through all words in the title for matches
  static String getEmoji(String title) {
    if (title.isEmpty) return defaultEmoji;
    
    final lowerTitle = title.toLowerCase();
    
    // Check each word in the title
    final words = lowerTitle.split(RegExp(r'\s+'));
    
    for (var word in words) {
      // Direct match
      if (_mappings.containsKey(word)) {
        return _mappings[word]!;
      }
      
      // Partial match (word contains keyword)
      for (var entry in _mappings.entries) {
        if (word.contains(entry.key) || entry.key.contains(word)) {
          return entry.value;
        }
      }
    }
    
    return defaultEmoji;
  }
  
  /// Get all available emojis (for manual selection)
  static List<String> getAllEmojis() {
    final emojis = _mappings.values.toSet().toList();
    emojis.sort();
    emojis.insert(0, defaultEmoji);
    return emojis;
  }
}
