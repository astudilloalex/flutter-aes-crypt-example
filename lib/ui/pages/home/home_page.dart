import 'package:aes_screen/app/services/aes_crypt_service.dart';
import 'package:aes_screen/src/common/domain/aes_mode_enum.dart';
import 'package:aes_screen/src/common/domain/padding_enum.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController keyController = TextEditingController();
  final TextEditingController encryptedController = TextEditingController();
  final TextEditingController plainController = TextEditingController();

  final AesCryptService cryptService = const AesCryptService();

  AesModeEnum? aesModeEnum = AesModeEnum.gcm;
  PaddingEnum? paddingEnum;

  @override
  void dispose() {
    keyController.dispose();
    encryptedController.dispose();
    plainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Encryption'),
      ),
      body: Form(
        key: formKey,
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: DropdownButtonFormField<AesModeEnum>(
                items: AesModeEnum.values.map(
                  (e) {
                    return DropdownMenuItem(
                      value: e,
                      child: Text(e.name.toUpperCase()),
                    );
                  },
                ).toList(),
                onChanged: (value) {
                  setState(() {
                    aesModeEnum = value;
                  });
                },
                value: aesModeEnum,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Mode',
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: DropdownButtonFormField<PaddingEnum>(
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: const Text('No padding'),
                  ),
                  ...PaddingEnum.values.map(
                    (e) {
                      return DropdownMenuItem(
                        value: e,
                        child: Text(e.name.toUpperCase()),
                      );
                    },
                  )
                ],
                onChanged: (value) {
                  setState(() {
                    paddingEnum = value;
                  });
                },
                value: paddingEnum,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Padding',
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextFormField(
                controller: keyController,
                decoration: const InputDecoration(
                  labelText: 'Secret Key',
                ),
                minLines: 1,
                maxLines: 2,
              ),
            ),
            const SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextFormField(
                controller: encryptedController,
                decoration: const InputDecoration(
                  labelText: 'Encrypted text',
                ),
                minLines: 1,
                maxLines: 5,
              ),
            ),
            const SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextFormField(
                controller: plainController,
                decoration: const InputDecoration(
                  labelText: 'Plain text',
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _encrypt();
                  },
                  child: const Text('Encrypt'),
                ),
                const SizedBox(width: 16.0),
                ElevatedButton(
                  onPressed: () {
                    _decrypt();
                  },
                  child: const Text('Decrypt'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _decrypt() async {
    try {
      final String plainText = await cryptService.decrypt(
        key: keyController.text.trim(),
        cipherText: encryptedController.text.trim(),
        mode: aesModeEnum ?? AesModeEnum.gcm,
      );
      plainController.text = plainText;
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showMaterialBanner(MaterialBanner(
        content: Text('Error: $e'),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
            },
            icon: const Icon(Icons.close),
          ),
        ],
      ));
    }
  }

  Future<void> _encrypt() async {
    try {
      final String encryptedText = await cryptService.encrypt(
        key: keyController.text.trim(),
        plainText: plainController.text.trim(),
        padding: paddingEnum,
        mode: aesModeEnum ?? AesModeEnum.gcm,
      );
      encryptedController.text = encryptedText;
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showMaterialBanner(MaterialBanner(
        content: Text('Error: $e'),
        
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
            },
            icon: const Icon(Icons.close),
          ),
        ],
      ));
    }
  }
}
