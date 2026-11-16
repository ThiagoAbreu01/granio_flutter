/// Dados do cadastro — tipado, em vez de `Map<String, dynamic>` solto.
class RegisterData {
  final String nome;
  final String email;
  final String? telefone;
  final String password;
  final String confirmPassword;

  const RegisterData({
    required this.nome,
    required this.email,
    required this.password,
    required this.confirmPassword,
    this.telefone,
  });

  Map<String, dynamic> toMap() => <String, dynamic>{
        'nome': nome,
        'email': email,
        'telephone': telefone,
        'password': password,
        'confirm_password': confirmPassword,
      };
}
