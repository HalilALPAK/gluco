import 'package:flutter/material.dart';

class InitialInfoDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Bilgileriniz'),
      content: Text('Profil bilgileri burada düzenlenebilir.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Kapat'),
        ),
      ],
    );
  }
}
