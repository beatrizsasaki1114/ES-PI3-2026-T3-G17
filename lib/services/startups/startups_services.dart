import 'package:cloud_functions/cloud_functions.dart';
import 'package:projeto_integrador_3_grupo_17/models/startups.dart';
// nao terminado, não sei se o jeito que estou montando vai funcionar
// ainda nao aplicado na tela flutter
class StartupService {
  Future<List<StartupList?>> displayStartups() async {
    final result = await FirebaseFunctions
    .instanceFor(region: 'southamerica-east1')
    .httpsCallable('listStartups')
    .call();
  final List data = result.data['data'];
  }
}
