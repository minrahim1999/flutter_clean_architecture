class ApiConfig {
  static const String newsApiKey = 'YOUR_API_KEY'; // Get from https://newsapi.org/

  static const Map<String, Map<String, String>> baseUrls = {
    'development': {
      'main': 'https://newsapi.org/v2',
      'member': 'https://dev-member-api.example.com/v1',
      'adv': 'https://dev-adv-api.example.com/v1',
    },
    'staging': {
      'main': 'https://newsapi.org/v2',
      'member': 'https://staging-member-api.example.com/v1',
      'adv': 'https://staging-adv-api.example.com/v1',
    },
    'production': {
      'main': 'https://newsapi.org/v2',
      'member': 'https://member-api.example.com/v1',
      'adv': 'https://adv-api.example.com/v1',
    },
  };

  static const Map<String, String> endpoints = {
    'newsletters': '/top-headlines',
    'newsletter_detail': '/everything',
  };
}
