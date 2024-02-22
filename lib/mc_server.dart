import 'dart:convert';

import 'package:http/http.dart' as http;
import './server_utils.dart' as su;
import 'package:xml/xml.dart';

enum ServerStatus { readOnly, readWrite, notConnected, unreachable, error }

class MCServer {
  final String accessKey;
  String? name;
  String? publicDNS;
  List<String> addresses = [];
  int? port;
  String? userName;
  String? password;
  bool validated = false;
  bool readOnly = false;
  String? preferredAddress;
  int? libraryVersion;
  String? productVersion;
  String? token;
  ServerStatus status = ServerStatus.notConnected;

  MCServer(this.accessKey, this.userName, this.password);

  Future<bool> ping() async {
    final strPort = port.toString();
    for (final address in addresses) {
      final url = Uri.http("$address:$strPort", '/MCWS/v1/Alive');
      var response = await http.get(url);

      if (su.checkResponse(response) == false) {
        continue;
      }

      if (su.parseAliveResponse(this, response)) {
        preferredAddress = address;
        return true;
      }
    }
    return false;
  }

  Future<ServerStatus> connect() async {
    if (await getServerInfo() == false) return ServerStatus.error;

    assert(port != null);

    if (addresses.isEmpty && publicDNS == null) {
      return ServerStatus.error;
    }

    if (await ping() == false) {
      return ServerStatus.unreachable;
    }

    final status = await authenticate();
    if (status == ServerStatus.error) return ServerStatus.error;

    return status;
  }

  Future<ServerStatus> authenticate() async {
    final strPort = port.toString();
    final url = Uri.http("$preferredAddress:$strPort", '/MCWS/v1/Authenticate');

    http.Response? response;

    if (userName != null && password != null) {
      final basicAuth =
          'Basic ${base64.encode(utf8.encode('$userName:$password'))}';
      response = await http
          .get(url, headers: <String, String>{'authorization': basicAuth});
    } else {
      response = await http.get(url);
    }

    if (su.checkResponse(response) == false) return ServerStatus.error;

    if (su.parseAuthenticate(this, response) == false) {
      return ServerStatus.error;
    }

    return status;
  }

  Future<bool> getServerInfo() async {
    var url = Uri.https(
        'webplay.jriver.com', 'libraryserver/lookup', {'id': accessKey});
    var response = await http.get(url);
    if (response.statusCode == 200) {
      final document = XmlDocument.parse(response.body);
      final body = document.firstElementChild;

      if (body == null) return false;

      final attr = body.getAttribute('Status');
      if (attr != 'OK') return false;

      for (final elem in body.childElements) {
        switch (elem.qualifiedName) {
          case 'ip':
            publicDNS = elem.innerText;
          case 'port':
            port = int.parse(elem.innerText);
          case 'localiplist':
            addresses.addAll(elem.innerText.split(','));
        }
      }
      // status = server.connect();
      return true;
    }
    return false;
  }
}
