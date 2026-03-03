import 'package:app_links/app_links.dart';
import 'package:voiceapp/providers/deep_link_provider.dart';

class DeepLinkService {
  final AppLinks _appLinks = AppLinks();
  final DeepLinkProvider _provider;

  DeepLinkService(this._provider);

  Future<void> init() async {
    final initial = await _appLinks.getInitialLink();
    if (initial != null) _handleUri(initial);

    _appLinks.uriLinkStream.listen(_handleUri);
  }

  void _handleUri(Uri uri) {
    final segments = uri.pathSegments;

    if (segments.isNotEmpty && segments[0] == 'profile') {
      _provider.handle(DeepLinkData(
        destination: DeepLinkDestination.profile,
        id: segments.length > 1 ? segments[1] : null,
      ));
      return;
    }

    // sonar://post/postId
    // https://sonarapp.io/post/postId
    if (segments.length >= 2 && segments[0] == 'post') {
      _provider.handle(DeepLinkData(
        destination: DeepLinkDestination.post,
        id: segments[1],
      ));
    }
  }
}
