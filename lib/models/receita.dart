
class Receita {
  final int? id;
  final String nome;
  final int tempoPreparo;
  final int porcoes;

  Receita({
    this.id,
    required this.nome,
    required this.tempoPreparo,
    required this.porcoes,
  });

  factory Receita.fromMap(Map<String, dynamic> map) {
    return Receita(
      id: map['id'] as int,
      nome: map['nome'] as String,
      tempoPreparo: map['tempoPreparo'] as int,
      porcoes: map['porcoes'] as int,
    );
  }
}
