class LogoHelper {
  /// Returns the URL for the service logo based on the issuer name.
  /// Uses SimpleIcons CDN with white color for dark mode.
  static String getLogoUrl(String issuer) {
    if (issuer.isEmpty) return '';
    
    // Normalize logic
    String slug = issuer.toLowerCase().trim();
    
    // Map common names and remove noise
    // Keep alpha-numeric only roughly or specific mappings
    
    // Remove common suffixes
    slug = slug.replaceAll(' services', '').replaceAll(' service', '');
    slug = slug.replaceAll(' technologies', '').replaceAll(' technology', '');
    slug = slug.replaceAll(' accounts', '').replaceAll(' account', '');
    slug = slug.replaceAll(' inc.', '').replaceAll(' inc', '');
    slug = slug.replaceAll(' corp.', '').replaceAll(' corp', '');
    
    // Manual mapping for some popular services if they differ from SimpleIcons slug
    // SimpleIcons usually uses the brand name itself
    final Map<String, String> mappings = {
      'aws': 'amazonaws',
      'amazon web services': 'amazonaws',
      'google': 'google',
      'microsoft': 'microsoft',
      'github': 'github',
      'facebook': 'facebook',
      'twitter': 'twitter',
      'x': 'x',
      'instagram': 'instagram',
      'discord': 'discord',
      'slack': 'slack',
      'dropbox': 'dropbox',
      'paypal': 'paypal',
      'stripe': 'stripe',
      'coinbase': 'coinbase',
      'binance': 'binance',
      'steam': 'steam',
      'twitch': 'twitch',
      'linkedin': 'linkedin',
      'apple': 'apple',
      'gitlab': 'gitlab',
      'bitbucket': 'bitbucket',
      'heroku': 'heroku',
      'digitalocean': 'digitalocean',
      'cloudflare': 'cloudflare',
      'protonmail': 'protonmail',
      'proton': 'proton',
      'reddit': 'reddit',
      'snapchat': 'snapchat',
      'spotify': 'spotify',
      'netflix': 'netflix',
      'adobe': 'adobe',
    };

    if (mappings.containsKey(slug)) {
      slug = mappings[slug]!;
    } else {
       // Just keep letters and numbers for safety if not mapped, 
       // but SimpleIcons often handles dashes. 
       // Regex to replace spaces with dash?
       slug = slug.replaceAll(RegExp(r'\s+'), ''); 
    }

    // Return the CDN URL
    // Format: https://cdn.simpleicons.org/[slug]/[color]
    // Using white (ffffff) for dark theme
    return 'https://cdn.simpleicons.org/$slug/ffffff';
  }
}
