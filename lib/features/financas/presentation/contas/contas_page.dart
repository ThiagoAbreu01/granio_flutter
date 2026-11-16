import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:granio_flutter/core/helpers/formatador_moeda.dart';
import 'package:granio_flutter/core/ui/styles/granio_colors.dart';
import 'package:granio_flutter/core/ui/styles/granio_icones.dart';
import 'package:granio_flutter/core/ui/widgets/granio/granio_background.dart';
import 'package:granio_flutter/core/ui/widgets/granio/granio_card.dart';
import 'package:granio_flutter/features/financas/data/financas_sync.dart';
import 'package:granio_flutter/features/financas/domain/entities/conta.dart';
import 'package:granio_flutter/features/financas/domain/entities/tipo_transacao.dart';
import 'package:granio_flutter/features/financas/domain/repositories/i_financas_repository.dart';
import 'package:granio_flutter/features/financas/presentation/contas/conta_sheet.dart';
import 'package:granio_flutter/features/financas/presentation/navegacao_financas.dart';
import 'package:granio_flutter/features/financas/presentation/widgets/granio_sheet.dart';

class ContasPage extends StatefulWidget {
  const ContasPage({super.key});

  @override
  State<ContasPage> createState() => _ContasPageState();
}

class _ContasPageState extends State<ContasPage> {
  late final IFinancasRepository _repo = context.read();
  late final FinancasSync _sync = context.read();
  List<Conta>? _contas;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _sync.addListener(_carregar);
    _carregar();
  }

  @override
  void dispose() {
    _sync.removeListener(_carregar);
    super.dispose();
  }

  Future<void> _carregar() async {
    try {
      final lista = await _repo.listarContas();
      if (mounted) {
        setState(() {
          _contas = lista;
          _erro = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _erro = mensagemDeErro(e));
    }
  }

  Future<void> _remover(Conta conta) async {
    final ok = await confirmar(
      context,
      titulo: 'Remover "${conta.nome}"?',
      mensagem: 'Se a conta já tiver lançamentos, ela é arquivada: '
          'some das opções, mas o histórico continua igual.',
      acao: 'Remover',
    );
    if (!ok || !mounted) return;
    try {
      final msg = await _repo.removerConta(conta.id!);
      if (mounted) avisar(context, msg);
    } catch (e) {
      if (mounted) avisar(context, mensagemDeErro(e), erro: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = GranioColors.of(context);
    final contas = _contas;
    final total = contas?.fold<int>(0, (s, c) => s + c.saldoAtual) ?? 0;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: GranioColors.emerald,
        foregroundColor: Colors.white,
        onPressed: () => mostrarContaSheet(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nova conta',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: GranioBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                children: [
                  GranioPageHeader(
                    titulo: 'Contas',
                    voltar: true,
                    acoes: [
                      GranioIconButton(
                        icone: Icons.swap_horiz_rounded,
                        tooltip: 'Transferir entre contas',
                        cor: GranioColors.teal,
                        onTap: () => abrirNovaTransacao(
                            context, TipoTransacao.transferencia),
                      ),
                    ],
                  ),
                  Expanded(
                    child: contas == null
                        ? (_erro == null
                            ? const Center(
                                child: CircularProgressIndicator(
                                    color: GranioColors.emerald))
                            : GranioEmptyState(
                                icone: Icons.cloud_off_rounded,
                                titulo: 'Não deu para carregar',
                                mensagem: _erro,
                                acao: 'Tentar de novo',
                                onAcao: _carregar,
                              ))
                        : RefreshIndicator(
                            color: GranioColors.emerald,
                            onRefresh: _carregar,
                            child: ListView(
                              padding:
                                  const EdgeInsets.fromLTRB(20, 8, 20, 100),
                              children: [
                                GranioCard(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text('Saldo somado',
                                            style: TextStyle(
                                                color: c.textMuted,
                                                fontSize: 14)),
                                      ),
                                      Text(
                                        formatarCentavos(total),
                                        style: TextStyle(
                                          color: total < 0
                                              ? GranioColors.expense
                                              : c.text,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 14),
                                if (contas.isEmpty)
                                  const GranioEmptyState(
                                    icone:
                                        Icons.account_balance_wallet_outlined,
                                    titulo: 'Nenhuma conta ativa',
                                    mensagem:
                                        'Crie uma conta para começar a lançar.',
                                  ),
                                for (final conta in contas) ...[
                                  _ItemConta(
                                    conta: conta,
                                    onTap: () => mostrarContaSheet(context,
                                        conta: conta),
                                    onRemover: () => _remover(conta),
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ItemConta extends StatelessWidget {
  final Conta conta;
  final VoidCallback onTap;
  final VoidCallback onRemover;

  const _ItemConta({
    required this.conta,
    required this.onTap,
    required this.onRemover,
  });

  @override
  Widget build(BuildContext context) {
    final c = GranioColors.of(context);
    return GranioCard(
      padding: const EdgeInsets.fromLTRB(14, 12, 4, 12),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: conta.cor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(GranioIcones.conta(conta.tipo),
                color: conta.cor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conta.nome,
                  style: TextStyle(
                    color: c.text,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(conta.tipoRotulo,
                    style: TextStyle(color: c.textMuted, fontSize: 12)),
              ],
            ),
          ),
          Text(
            formatarCentavos(conta.saldoAtual),
            style: TextStyle(
              color: conta.saldoAtual < 0 ? GranioColors.expense : c.text,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded, color: c.textMuted),
            color: c.surface,
            onSelected: (v) => v == 'editar' ? onTap() : onRemover(),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'editar',
                child: Text('Editar', style: TextStyle(color: c.text)),
              ),
              const PopupMenuItem(
                value: 'remover',
                child: Text('Remover',
                    style: TextStyle(color: GranioColors.expense)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
