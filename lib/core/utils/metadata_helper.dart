import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;

class LinkMetadata {
  final String title;
  final String description;
  final String? imageUrl;
  final String? faviconUrl;
  final String domain;

  const LinkMetadata({
    required this.title,
    required this.description,
    this.imageUrl,
    this.faviconUrl,
    required this.domain,
  });
}

class MetadataHelper {
  MetadataHelper._();

  static String extractDomain(String url) {
    try {
      final uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');
      return uri.host.replaceFirst('www.', '');
    } catch (_) {
      return url;
    }
  }

  static Future<LinkMetadata> fetchMetadata(String url) async {
    final domain = extractDomain(url);
    final targetUrl = url.startsWith('http') ? url : 'https://$url';

    try {
      final uri = Uri.parse(targetUrl);
      final response = await http.get(
        uri,
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36',
          'Accept':
              'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
          'Accept-Language': 'en-US,en;q=0.5',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final document = html_parser.parse(response.body);

        // 1. Extract Title
        String? title = document
            .querySelector('meta[property="og:title"]')
            ?.attributes['content']
            ?.trim();
        title ??= document
            .querySelector('meta[name="twitter:title"]')
            ?.attributes['content']
            ?.trim();
        title ??= document.querySelector('title')?.text.trim();
        if (title == null || title.isEmpty) {
          title = domain;
        }

        // 2. Extract Description
        String? description = document
            .querySelector('meta[property="og:description"]')
            ?.attributes['content']
            ?.trim();
        description ??= document
            .querySelector('meta[name="description"]')
            ?.attributes['content']
            ?.trim();
        description ??= document
            .querySelector('meta[name="twitter:description"]')
            ?.attributes['content']
            ?.trim();
        description ??= '';

        // 3. Extract Image
        String? image = document
            .querySelector('meta[property="og:image"]')
            ?.attributes['content']
            ?.trim();
        image ??= document
            .querySelector('meta[name="twitter:image"]')
            ?.attributes['content']
            ?.trim();
        if (image != null && image.isNotEmpty && !image.startsWith('http')) {
          if (image.startsWith('//')) {
            image = 'https:$image';
          } else {
            image = uri.resolve(image).toString();
          }
        }

        // 4. Extract Favicon
        String? favicon = document
            .querySelector('link[rel="apple-touch-icon"]')
            ?.attributes['href']
            ?.trim();
        favicon ??= document
            .querySelector('link[rel="icon"]')
            ?.attributes['href']
            ?.trim();
        favicon ??= document
            .querySelector('link[rel="shortcut icon"]')
            ?.attributes['href']
            ?.trim();
        if (favicon != null && favicon.isNotEmpty && !favicon.startsWith('http')) {
          if (favicon.startsWith('//')) {
            favicon = 'https:$favicon';
          } else {
            favicon = uri.resolve(favicon).toString();
          }
        }

        return LinkMetadata(
          title: title,
          description: description,
          imageUrl: image,
          faviconUrl: favicon,
          domain: domain,
        );
      }
    } catch (_) {}

    return LinkMetadata(
      title: domain,
      description: '',
      domain: domain,
    );
  }
}
