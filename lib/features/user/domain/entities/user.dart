import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int? id;
  final String nome;
  final String email;
  final String? telefone;
  final DateTime? dataCriacao;

  const User({
    this.id,
    required this.nome,
    required this.email,
    this.telefone,
    this.dataCriacao,
  });

  String get primeiroNome => nome.trim().split(' ').first;

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: _toInt(map['id']),
      nome: map['nome'] as String? ?? '',
      email: map['email'] as String? ?? '',
      telefone: map['telefone'] as String?,
      dataCriacao: _toDateTime(map['data_criacao']),
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'nome': nome,
        'email': email,
        'telefone': telefone,
        'data_criacao': dataCriacao?.toUtc().toIso8601String(),
      };

  static int? _toInt(dynamic v) =>
      v is int ? v : (v == null ? null : int.tryParse('$v'));

  static DateTime? _toDateTime(dynamic v) =>
      v is DateTime ? v : (v is String ? DateTime.tryParse(v) : null);

  @override
  List<Object?> get props => [id, nome, email, telefone, dataCriacao];
}
