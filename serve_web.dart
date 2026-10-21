import 'dart:io';

void main() async {
  final port = 8080;
  final webDir = Directory('build/web');

  if (!webDir.existsSync()) {
    print('build/web does not exist!');
    exit(1);
  }

  final server = await HttpServer.bind(InternetAddress.anyIPv4, port);
  print('SERVER_STARTED: http://localhost:$port (and http://192.168.1.6:$port)');

  await for (HttpRequest request in server) {
    var path = request.uri.path;
    if (path == '/' || path.isEmpty) {
      path = '/index.html';
    }

    // sanitize path
    final file = File('${webDir.path}$path');
    if (await file.exists()) {
      final ext = file.path.split('.').last.toLowerCase();
      switch (ext) {
        case 'html':
          request.response.headers.contentType = ContentType.html;
          break;
        case 'js':
          request.response.headers.contentType = ContentType('application', 'javascript');
          break;
        case 'json':
          request.response.headers.contentType = ContentType.json;
          break;
        case 'wasm':
          request.response.headers.contentType = ContentType('application', 'wasm');
          break;
        case 'png':
          request.response.headers.contentType = ContentType('image', 'png');
          break;
        case 'jpg':
        case 'jpeg':
          request.response.headers.contentType = ContentType('image', 'jpeg');
          break;
        case 'css':
          request.response.headers.contentType = ContentType('text', 'css');
          break;
        case 'otf':
          request.response.headers.contentType = ContentType('font', 'otf');
          break;
        case 'ttf':
          request.response.headers.contentType = ContentType('font', 'ttf');
          break;
        default:
          request.response.headers.contentType = ContentType.binary;
      }
      request.response.headers.add('Access-Control-Allow-Origin', '*');
      await request.response.addStream(file.openRead());
    } else {
      // SPA fallback
      final indexFile = File('${webDir.path}/index.html');
      request.response.headers.contentType = ContentType.html;
      await request.response.addStream(indexFile.openRead());
    }
    await request.response.close();
  }
}
