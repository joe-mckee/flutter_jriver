import 'package:xml/xml.dart';
import 'package:http/http.dart' as http;
import './mc_server.dart';

bool checkResponse(http.Response httpResponse) {
  final document = XmlDocument.parse(httpResponse.body);
  final body = document.firstElementChild;

  if (httpResponse.statusCode != 200) return false;

  if (body == null) return false;

  final attr = body.getAttribute('Status');
  if (attr != 'OK') return false;

  return true;
}

bool parseAliveResponse(MCServer server, http.Response response) {
  final document = XmlDocument.parse(response.body);
  final body = document.firstElementChild;

  if (body == null) return false;

  final attr = body.getAttribute('Status');
  if (attr != 'OK') return false;

  for (final elem in body.childElements) {
    final field = elem.getAttribute('Name');
    switch (field) {
      case 'ProductVersion':
        server.productVersion = elem.innerText;
      case 'FriendlyName':
        server.name = elem.innerText;
      case 'LibraryVersion':
        server.libraryVersion = int.parse(elem.innerText);
    }
  }
  return true;
}

bool parseAuthenticate(MCServer server, http.Response response) {
  final document = XmlDocument.parse(response.body);
  final body = document.firstElementChild;

  if (body == null) return false;

  final attr = body.getAttribute('Status');
  if (attr != 'OK') return false;

  for (final elem in body.childElements) {
    final field = elem.getAttribute('Name');
    switch (field) {
      case 'Token':
        server.token = elem.innerText;
      case 'ReadOnly':
        server.readOnly = int.parse(elem.innerText) == 1;
        if (server.readOnly == true) {
          server.status = ServerStatus.readOnly;
        } else {
          server.status = ServerStatus.readWrite;
        }
    }
  }
  return true;
}
