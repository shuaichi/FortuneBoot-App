// Web-only download helper using dart:html
import 'dart:typed_data';
import 'dart:html' as html;

Future<bool> downloadBytes(String name, Uint8List bytes, String mimeType) async {
  try {
    final blob = html.Blob([bytes], mimeType);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url);
    anchor.download = name;
    anchor.style.display = 'none';
    html.document.body?.append(anchor);
    anchor.click();
    anchor.remove();
    html.Url.revokeObjectUrl(url);
    return true;
  } catch (_) {
    return false;
  }
}