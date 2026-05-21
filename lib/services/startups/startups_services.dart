// Beatriz Naomi (uma parte por Sofia de Souza)

import 'package:cloud_functions/cloud_functions.dart';
import 'package:projeto_integrador_3_grupo_17/models/startups.dart';

class StartupService {
  Future<List<Startup>> fetchStartups() async {
    final result = await FirebaseFunctions.instanceFor(
      region: 'southamerica-east1',
    ).httpsCallable('listStartups').call();
    final response = Map<String, dynamic>.from(result.data);
    final List data = response['data'];
    return data.map((item) {
      return Startup.fromJson(Map<String, dynamic>.from(item as Map));
    }).toList();
  }

  Future<Startup> fetchStartupDetails(String id) async {
  final result = await FirebaseFunctions.instanceFor(
    region: 'southamerica-east1',
  ).httpsCallable('getStartupDetails').call({
    'startupId': id,
  });

  final response = Map<String, dynamic>.from(result.data);
  final data = Map<String, dynamic>.from(response['data']);

  return Startup.fromJson(data);
}
}
