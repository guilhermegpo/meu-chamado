import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Onde o banco vive: `meu_chamado.sqlite` no diretório de documentos do app —
/// mesmo nome e pasta que a `drift_flutter` usava na `alpha.2`, agora
/// criptografado.
Future<File> resolveDatabaseFile() async {
  final directory = await getApplicationDocumentsDirectory();
  return File('${directory.path}${Platform.pathSeparator}meu_chamado.sqlite');
}
