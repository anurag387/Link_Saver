import 'package:flutter/material.dart';

class BrandHelper {
  BrandHelper._();

  /// Returns the real high-res favicon URL for any website domain
  static String getFaviconUrl(String domainOrUrl) {
    var domain = domainOrUrl.trim().toLowerCase();
    if (domain.startsWith('http://') || domain.startsWith('https://')) {
      final uri = Uri.tryParse(domain);
      if (uri != null && uri.host.isNotEmpty) {
        domain = uri.host;
      }
    }
    // Clean trailing slashes or paths
    domain = domain.split('/')[0].replaceAll('www.', '');
    return 'https://icons.duckduckgo.com/ip3/$domain.ico';
  }

  static Widget buildBrandLogo(String domainOrUrl, {double size = 38, String? fallbackEmoji}) {
    var domain = domainOrUrl.trim().toLowerCase();
    if (domain.startsWith('http://') || domain.startsWith('https://')) {
      final uri = Uri.tryParse(domain);
      if (uri != null && uri.host.isNotEmpty) {
        domain = uri.host;
      }
    }
    domain = domain.replaceAll('www.', '');

    // 1. YouTube Authentic Badge
    if (domain.contains('youtube.com') || domain.contains('youtu.be')) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFFFF0000),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF0000).withValues(alpha: 0.4),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
        ),
      );
    }

    // 2. GitHub Authentic Octocat Badge
    if (domain.contains('github.com') || domain.contains('github.io')) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFF181717),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white24, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: CustomPaint(
            size: Size(22, 22),
            painter: GithubLogoPainter(color: Colors.white),
          ),
        ),
      );
    }

    // 3. Facebook Authentic Badge
    if (domain.contains('facebook.com') || domain.contains('fb.com')) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFF1877F2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(
          child: Text('f', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, fontFamily: 'sans-serif')),
        ),
      );
    }

    // 4. X / Twitter
    if (domain.contains('twitter.com') || domain.contains('x.com')) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFF0F1419),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white24, width: 1),
        ),
        child: const Center(
          child: Text('𝕏', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      );
    }

    // 5. LinkedIn
    if (domain.contains('linkedin.com')) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFF0A66C2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(
          child: Text('in', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
        ),
      );
    }

    // 6. Reddit
    if (domain.contains('reddit.com')) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFFFF4500),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(
          child: Icon(Icons.reddit_rounded, color: Colors.white, size: 22),
        ),
      );
    }

    // 7. Instagram
    if (domain.contains('instagram.com')) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF833AB4), Color(0xFFFD1D1D), Color(0xFFFCB045)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(
          child: Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
        ),
      );
    }

    // 8. Google
    if (domain.contains('google.com')) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF4285F4), width: 1.5),
        ),
        child: const Center(
          child: Text('G', style: TextStyle(color: Color(0xFF4285F4), fontSize: 20, fontWeight: FontWeight.w900)),
        ),
      );
    }

    // 9. Spotify
    if (domain.contains('spotify.com')) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFF1DB954),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(
          child: Icon(Icons.graphic_eq_rounded, color: Colors.white, size: 20),
        ),
      );
    }

    // Real Favicon loader for all other domains
    final primaryFavicon = 'https://www.google.com/s2/favicons?sz=64&domain=$domain';
    final fallbackFavicon = 'https://icons.duckduckgo.com/ip3/$domain.ico';

    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: Image.network(
        primaryFavicon,
        width: size - 12,
        height: size - 12,
        errorBuilder: (_, __, ___) => Image.network(
          fallbackFavicon,
          width: size - 12,
          height: size - 12,
          errorBuilder: (_, __, ___) => Center(
            child: Text(
              fallbackEmoji != null && fallbackEmoji.isNotEmpty ? fallbackEmoji : (domain.isNotEmpty ? domain[0].toUpperCase() : '🌐'),
              style: TextStyle(fontSize: size * 0.45, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  /// Returns authentic brand colors for major websites, or a pleasant palette for others
  static BrandColorInfo getBrandColor(String domainOrUrl) {
    var domain = domainOrUrl.trim().toLowerCase();
    if (domain.startsWith('http://') || domain.startsWith('https://')) {
      final uri = Uri.tryParse(domain);
      if (uri != null && uri.host.isNotEmpty) {
        domain = uri.host;
      }
    }
    domain = domain.replaceAll('www.', '');

    if (domain.contains('youtube.com') || domain.contains('youtu.be')) {
      return const BrandColorInfo(
        brandColor: Color(0xFFFF0000),
        accentColor: Color(0xFFE50914),
        cardGradientStart: Color(0xFF2A0808),
        name: 'YouTube',
      );
    }
    if (domain.contains('facebook.com') || domain.contains('fb.com')) {
      return const BrandColorInfo(
        brandColor: Color(0xFF1877F2),
        accentColor: Color(0xFF0E5FC7),
        cardGradientStart: Color(0xFF081830),
        name: 'Facebook',
      );
    }
    if (domain.contains('github.com')) {
      return const BrandColorInfo(
        brandColor: Color(0xFF8B5CF6),
        accentColor: Color(0xFF6D28D9),
        cardGradientStart: Color(0xFF191428),
        name: 'GitHub',
      );
    }
    if (domain.contains('twitter.com') || domain.contains('x.com')) {
      return const BrandColorInfo(
        brandColor: Color(0xFF1DA1F2),
        accentColor: Color(0xFF0C85D0),
        cardGradientStart: Color(0xFF0A1C2C),
        name: 'X (Twitter)',
      );
    }
    if (domain.contains('instagram.com')) {
      return const BrandColorInfo(
        brandColor: Color(0xFFE1306C),
        accentColor: Color(0xFFC13584),
        cardGradientStart: Color(0xFF290818),
        name: 'Instagram',
      );
    }
    if (domain.contains('linkedin.com')) {
      return const BrandColorInfo(
        brandColor: Color(0xFF0A66C2),
        accentColor: Color(0xFF084E96),
        cardGradientStart: Color(0xFF07192C),
        name: 'LinkedIn',
      );
    }
    if (domain.contains('reddit.com')) {
      return const BrandColorInfo(
        brandColor: Color(0xFFFF4500),
        accentColor: Color(0xFFCC3700),
        cardGradientStart: Color(0xFF2D1005),
        name: 'Reddit',
      );
    }
    if (domain.contains('notion.so') || domain.contains('notion.site')) {
      return const BrandColorInfo(
        brandColor: Color(0xFF6B7280),
        accentColor: Color(0xFF374151),
        cardGradientStart: Color(0xFF1F242D),
        name: 'Notion',
      );
    }
    if (domain.contains('figma.com')) {
      return const BrandColorInfo(
        brandColor: Color(0xFFF24E1E),
        accentColor: Color(0xFFA259FF),
        cardGradientStart: Color(0xFF2B1008),
        name: 'Figma',
      );
    }
    if (domain.contains('spotify.com')) {
      return const BrandColorInfo(
        brandColor: Color(0xFF1DB954),
        accentColor: Color(0xFF169C46),
        cardGradientStart: Color(0xFF082412),
        name: 'Spotify',
      );
    }
    if (domain.contains('medium.com')) {
      return const BrandColorInfo(
        brandColor: Color(0xFF00AB6C),
        accentColor: Color(0xFF008F5A),
        cardGradientStart: Color(0xFF062015),
        name: 'Medium',
      );
    }
    if (domain.contains('stackoverflow.com')) {
      return const BrandColorInfo(
        brandColor: Color(0xFFF48024),
        accentColor: Color(0xFFC76210),
        cardGradientStart: Color(0xFF281505),
        name: 'StackOverflow',
      );
    }
    if (domain.contains('google.com')) {
      return const BrandColorInfo(
        brandColor: Color(0xFF4285F4),
        accentColor: Color(0xFF3367D6),
        cardGradientStart: Color(0xFF091932),
        name: 'Google',
      );
    }

    // Dynamic color generation based on domain hash
    final hash = domain.codeUnits.fold<int>(0, (prev, elem) => prev + elem);
    final hues = [
      const Color(0xFF3B82F6), // Blue
      const Color(0xFF10B981), // Emerald
      const Color(0xFF8B5CF6), // Purple
      const Color(0xFFF59E0B), // Amber
      const Color(0xFFEC4899), // Pink
      const Color(0xFF06B6D4), // Cyan
      const Color(0xFF6366F1), // Indigo
      const Color(0xFF14B8A6), // Teal
    ];
    final color = hues[hash % hues.length];
    return BrandColorInfo(
      brandColor: color,
      accentColor: color,
      cardGradientStart: color.withValues(alpha: 0.15),
      name: domain,
    );
  }
}

class BrandColorInfo {
  final Color brandColor;
  final Color accentColor;
  final Color cardGradientStart;
  final String name;

  const BrandColorInfo({
    required this.brandColor,
    required this.accentColor,
    required this.cardGradientStart,
    required this.name,
  });
}

class GithubLogoPainter extends CustomPainter {
  final Color color;
  const GithubLogoPainter({this.color = Colors.white});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final scale = size.width / 24.0;
    canvas.scale(scale, scale);

    final path = Path();
    path.moveTo(12, 0);
    path.cubicTo(5.37, 0, 0, 5.37, 0, 12);
    path.cubicTo(0, 17.31, 3.435, 21.795, 8.205, 23.385);
    path.cubicTo(8.805, 23.49, 9.03, 23.13, 9.03, 22.815);
    path.cubicTo(9.03, 22.53, 9.015, 21.585, 9.015, 20.58);
    path.cubicTo(6.0, 21.135, 5.22, 19.845, 4.98, 19.17);
    path.cubicTo(4.845, 18.825, 4.26, 17.76, 3.75, 17.475);
    path.cubicTo(3.33, 17.25, 2.73, 16.695, 3.735, 16.68);
    path.cubicTo(4.68, 16.665, 5.355, 17.55, 5.58, 17.91);
    path.cubicTo(6.66, 19.725, 8.385, 19.215, 9.075, 18.9);
    path.cubicTo(9.18, 18.12, 9.495, 17.595, 9.84, 17.295);
    path.cubicTo(7.17, 16.995, 4.38, 15.96, 4.38, 11.37);
    path.cubicTo(4.38, 10.065, 4.845, 8.985, 5.61, 8.145);
    path.cubicTo(5.49, 7.845, 5.07, 6.615, 5.73, 4.965);
    path.cubicTo(5.73, 4.965, 6.735, 4.65, 9.03, 6.195);
    path.cubicTo(9.99, 5.925, 11.01, 5.79, 12.03, 5.79);
    path.cubicTo(13.05, 5.79, 14.07, 5.925, 15.03, 6.195);
    path.cubicTo(17.325, 4.635, 18.33, 4.965, 18.33, 4.965);
    path.cubicTo(18.99, 6.615, 18.57, 7.845, 18.45, 8.145);
    path.cubicTo(19.215, 8.985, 19.68, 10.05, 19.68, 11.37);
    path.cubicTo(19.68, 15.975, 16.875, 16.995, 14.205, 17.295);
    path.cubicTo(14.64, 17.67, 15.015, 18.39, 15.015, 19.515);
    path.cubicTo(15.015, 21.12, 15.0, 22.41, 15.0, 22.815);
    path.cubicTo(15.0, 23.13, 15.225, 23.505, 15.825, 23.385);
    path.cubicTo(20.595, 21.795, 24.03, 17.31, 24.03, 12);
    path.cubicTo(24.03, 5.37, 18.66, 0, 12, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
