import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:mparticle_flutter_sdk/mparticle_flutter_sdk.dart';
import 'package:mparticle_flutter_sdk/identity/identity_type.dart';
import 'package:mparticle_flutter_sdk/kits/kits.dart';

class RoktLayoutsScreen extends StatefulWidget {
  final MparticleFlutterSdk? mpInstance;

  const RoktLayoutsScreen({Key? key, required this.mpInstance})
      : super(key: key);

  @override
  _RoktLayoutsScreenState createState() => _RoktLayoutsScreenState();
}

class _RoktLayoutsScreenState extends State<RoktLayoutsScreen> {
  final TextEditingController _placementIdController =
      TextEditingController(text: 'readmorelayout');

  Map<String, String> _getAttributesForPlatform() {
    if (kIsWeb) {
      return {
        'email': 'web-user@example.com',
        'platform': 'web',
        'userId': 'web-12345'
      };
    }
    if (Platform.isAndroid) {
      return {
        'email': 'android-user@example.com',
        'platform': 'android',
        'userId': 'android-67890',
        'deviceType': 'mobile'
      };
    }
    if (Platform.isIOS) {
      return {
        'email': 'ios-user@example.com',
        'platform': 'ios',
        'userId': 'ios-54321',
        'deviceType': 'mobile'
      };
    }
    return {};
  }

  String _getPlatform() {
    if (kIsWeb) {
      return 'Web';
    } else if (Platform.isAndroid) {
      return 'Android';
    } else if (Platform.isIOS) {
      return 'iOS';
    }
    return 'Unknown';
  }

  String _getIdentityValue() {
    String platform;
    if (kIsWeb) {
      platform = 'web';
    } else if (Platform.isAndroid) {
      platform = 'android';
    } else if (Platform.isIOS) {
      platform = 'ios';
    } else {
      platform = 'unknown';
    }
    return '$platform-test-user-${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  void dispose() {
    _placementIdController.dispose();
    super.dispose();
  }

  Widget buildButton(String text, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rokt Layouts'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(
                child: Text('ROKT', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _placementIdController,
                decoration: const InputDecoration(
                  labelText: 'Placement ID',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              buildButton('is Rokt kit active?', () async {
                print(await widget.mpInstance?.isKitActive(kit: Kits['Rokt']!));
              }),
              const SizedBox(height: 20),
              buildButton('Select Placements', () async {
                var identityRequest = MparticleFlutterSdk.identityRequest;
                identityRequest.setIdentity(
                    identityType: IdentityType.CustomerId,
                    value: _getIdentityValue());

                try {
                  await widget.mpInstance?.identity
                      .identify(identityRequest: identityRequest);

                  widget.mpInstance?.rokt.selectPlacements(
                      placementId: _placementIdController.text,
                      attributes: _getAttributesForPlatform());
                  print('${_getPlatform()} Rokt selectPlacements called');
                } catch (e) {
                  print('Error calling Rokt selectPlacements: $e');
                }
              }),
              Center(
                child: Text("Location1", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              const RoktLayout(
                  key: ValueKey('layout1'),
                  placeholderName: "Location1"
              ),
              Center(
                child: Text("Location2", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              const RoktLayout(
                  key: ValueKey('layout2'),
                  placeholderName: "Location2"
              ),
            ],
          ),
        ),
      ),
    );
  }
}
