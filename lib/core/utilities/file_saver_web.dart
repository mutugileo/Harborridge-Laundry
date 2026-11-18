import 'dart:js_interop';

import 'package:web/web.dart' as web;

void downloadCsvFile(String filename, String csvContent) {
  final parts = [csvContent.toJS].toJS;
  final blobOptions = web.BlobPropertyBag(type: 'text/csv;charset=utf-8');
  final blob = web.Blob(parts, blobOptions);
  final url = web.URL.createObjectURL(blob);
  final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
  anchor.href = url;
  anchor.download = filename;
  anchor.style.display = 'none';
  web.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  web.URL.revokeObjectURL(url);
}

void printHtmlDocument(String title, String htmlContent) {
  final iframe = web.document.createElement('iframe') as web.HTMLIFrameElement;
  iframe.style.position = 'fixed';
  iframe.style.right = '0';
  iframe.style.bottom = '0';
  iframe.style.width = '0';
  iframe.style.height = '0';
  iframe.style.border = '0';
  web.document.body?.append(iframe);

  final iframeDoc = iframe.contentDocument;
  if (iframeDoc != null) {
    iframeDoc.open();
    iframeDoc.write(htmlContent.toJS);
    iframeDoc.close();
    iframe.contentWindow?.focus();
    iframe.contentWindow?.print();
    web.window.setTimeout(
      (() {
        iframe.remove();
      }).toJS,
      1000.toJS,
    );
  }
}
