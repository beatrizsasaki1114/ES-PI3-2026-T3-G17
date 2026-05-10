// Feito por Sofia de Sousa

//  Representa os dados da carteira do usuário dentro do app(flutter)

// Criando a classe da carteira os dados são final pq o valor é imutável
class Wallet {
  final double saldoReais;
  final int tokens;
  final double totalInvested;
  final double investedByOrders;
  final int totalOrders;

//  Construtor da classe
  Wallet({
    required this.saldoReais,
    required this.tokens,
    required this.totalInvested,
    required this.investedByOrders,
    required this.totalOrders,
  });

  // Aqui ele transforma o Map(json) em um objeto dart 
  factory Wallet.fromMap(Map<String, dynamic> map) {

    // Cria o objeto usando os dados do back
    return Wallet(
      saldoReais: (map['saldoReais'] ?? 0).toDouble(),
      tokens: map['tokens'] ?? 0,
      totalInvested: (map['totalInvested'] ?? 0).toDouble(),
      investedByOrders: (map['investedByOrders'] ?? 0).toDouble(),
      totalOrders: map['totalOrders'] ?? 0,
    );
  }
}
