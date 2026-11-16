import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:granio_flutter/core/helpers/datas.dart';
import 'package:granio_flutter/core/helpers/formatador_moeda.dart';
import 'package:granio_flutter/core/ui/styles/granio_colors.dart';
import 'package:granio_flutter/core/ui/styles/granio_icones.dart';
import 'package:granio_flutter/core/ui/widgets/granio/granio_background.dart';
import 'package:granio_flutter/core/ui/widgets/granio/granio_button.dart';
import 'package:granio_flutter/core/ui/widgets/granio/granio_card.dart';
import 'package:granio_flutter/core/ui/widgets/granio/granio_text_field.dart';
import 'package:granio_flutter/features/financas/domain/entities/categoria.dart';
import 'package:granio_flutter/features/financas/domain/entities/conta.dart';
import 'package:granio_flutter/features/financas/domain/entities/tipo_transacao.dart';
import 'package:granio_flutter/features/financas/domain/entities/transacao.dart';
import 'package:granio_flutter/features/financas/domain/repositories/i_financas_repository.dart';
import 'package:granio_flutter/features/financas/presentation/categorias/categoria_sheet.dart';
import 'package:granio_flutter/features/financas/presentation/contas/conta_sheet.dart';
import 'package:granio_flutter/features/financas/presentation/navegacao_financas.dart';
import 'package:granio_flutter/features/financas/presentation/widgets/granio_sheet.dart';

/// Lançar/editar receita, despesa ou transferência.
class TransacaoFormPage extends StatefulWidget {
  final TransacaoFormArgs args;

  const TransacaoFormPage({super.key, required this.args});

  @override
  State<TransacaoFormPage> createState() => _TransacaoFormPageState();
}

class _TransacaoFormPageState extends State<TransacaoFormPage> {
  late final IFinancasRepository _repo = context.read();
  Transacao? get _editando => widget.args.transacao;

  late TipoTransacao _tipo = widget.args.tipo;
  late final _valor = TextEditingController(
    text: _editando == null ? '' : textoDeCentavos(_editando!.valor),
  );
  late final _descricao = TextEditingController(text: _editando?.descricao);
  late final _observacao = TextEditingController(text: _editando?.observacao);
  late DateTime _data = _editando?.data ?? soData(DateTime.now());
  late int? _idCategoria = _editando?.idCategoria;
  late int? _idConta = _editando?.idConta;
  late int? _idDestino = _editando?.idContaDestino;
  bool _mostrarObs = false;

  List<Conta> _contas = [];
  List<Categoria> _categorias = [];
  bool _carregando = true;
  bool _salvando = false;
  String? _erroCarga;

  @override
  void initState() {
    super.initState();
    _mostrarObs = (_editando?.observacao ?? '').isNotEmpty;
    _carregar();
  }

  @override
  void dispose() {
    _valor.dispose();
    _descricao.dispose();
    _observacao.dispose();
    super.dispose();
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _erroCarga = null;
    });
    try {
      final (contas, categorias) =
          await (_repo.listarContas(), _repo.listarCategorias()).wait;
      if (!mounted) return;
      setState(() {
        _contas = contas;
        _categorias = categorias;
        _carregando = false;
        // Conta padrão: a primeira. Destino padrão: a segunda.
        _idConta ??= contas.firstOrNull?.id;
        _idDestino ??= contas.length > 1 ? contas[1].id : null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _carregando = false;
        _erroCarga = mensagemDeErro(e, 'Não foi possível carregar os dados.');
      });
    }
  }

  List<Categoria> get _categoriasDoTipo =>
      _categorias.where((c) => c.tipo == _tipo).toList();

  /// Contas para escolher: ativas + a(s) da transação editada (mesmo que
  /// arquivadas agora).
  List<Conta> get _contasVisiveis => _contas;

  void _trocarTipo(TipoTransacao t) {
    if (t == _tipo) return;
    setState(() {
      _tipo = t;
      // Categoria de receita não serve em despesa (e vice-versa).
      if (!_categoriasDoTipo.any((c) => c.id == _idCategoria)) {
        _idCategoria = null;
      }
    });
  }

  Future<void> _salvar() async {
    FocusScope.of(context).unfocus();
    final valor = centavosDeTexto(_valor.text);
    final transf = _tipo == TipoTransacao.transferencia;
    final erro = switch (true) {
      _ when valor <= 0 => 'Informe um valor maior que zero.',
      _ when !transf && _descricao.text.trim().isEmpty =>
        'Descreva a transação (ex.: Mercado, Salário).',
      _ when !transf && _idCategoria == null => 'Escolha uma categoria.',
      _ when _idConta == null => 'Escolha a conta.',
      _ when transf && _idDestino == null => 'Escolha a conta de destino.',
      _ when transf && _idDestino == _idConta =>
        'Escolha contas diferentes para a transferência.',
      _ => null,
    };
    if (erro != null) {
      avisar(context, erro, erro: true);
      return;
    }

    setState(() => _salvando = true);
    try {
      await _repo.salvarTransacao(Transacao(
        id: _editando?.id,
        tipo: _tipo,
        descricao: _descricao.text.trim().isEmpty && transf
            ? 'Transferência'
            : _descricao.text.trim(),
        valor: valor,
        data: _data,
        idConta: _idConta!,
        idContaDestino: transf ? _idDestino : null,
        idCategoria: transf ? null : _idCategoria,
        observacao:
            _observacao.text.trim().isEmpty ? null : _observacao.text.trim(),
      ));
      if (!mounted) return;
      avisar(context,
          _editando == null ? 'Lançamento salvo!' : 'Alterações salvas.');
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _salvando = false);
      avisar(context, mensagemDeErro(e), erro: true);
    }
  }

  Future<void> _excluir() async {
    final ok = await confirmar(
      context,
      titulo: 'Excluir transação?',
      mensagem: 'Essa ação não pode ser desfeita.',
    );
    if (!ok || !mounted) return;
    setState(() => _salvando = true);
    try {
      await _repo.excluirTransacao(_editando!.id!);
      if (!mounted) return;
      avisar(context, 'Transação excluída.');
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _salvando = false);
      avisar(context, mensagemDeErro(e), erro: true);
    }
  }

  Future<void> _novaCategoria() async {
    final nova = await mostrarCategoriaSheet(context, tipo: _tipo);
    if (nova == null || !mounted) return;
    setState(() {
      _categorias = [..._categorias.where((c) => c.id != nova.id), nova];
      _idCategoria = nova.id;
    });
  }

  Future<void> _novaConta() async {
    final nova = await mostrarContaSheet(context);
    if (nova == null || !mounted) return;
    setState(() => _contas = [..._contas, nova]);
  }

  Future<void> _escolherData() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _data,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      helpText: 'Data da transação',
      cancelText: 'Cancelar',
      confirmText: 'OK',
    );
    if (d != null) setState(() => _data = soData(d));
  }

  @override
  Widget build(BuildContext context) {
    final titulo = _editando == null
        ? switch (_tipo) {
            TipoTransacao.receita => 'Nova receita',
            TipoTransacao.despesa => 'Nova despesa',
            TipoTransacao.transferencia => 'Nova transferência',
          }
        : 'Editar transação';

    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: GranioBackground(
          child: SafeArea(
            child: Column(
              children: [
                GranioPageHeader(
                  titulo: titulo,
                  voltar: true,
                  acoes: [
                    if (_editando != null)
                      GranioIconButton(
                        icone: Icons.delete_outline_rounded,
                        tooltip: 'Excluir',
                        cor: GranioColors.expense,
                        onTap: _salvando ? () {} : _excluir,
                      ),
                  ],
                ),
                Expanded(child: _corpo()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _corpo() {
    if (_carregando) {
      return const Center(
          child: CircularProgressIndicator(color: GranioColors.emerald));
    }
    if (_erroCarga != null) {
      return GranioEmptyState(
        icone: Icons.cloud_off_rounded,
        titulo: 'Não deu para abrir o formulário',
        mensagem: _erroCarga,
        acao: 'Tentar de novo',
        onAcao: _carregar,
      );
    }

    final transf = _tipo == TipoTransacao.transferencia;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            _SeletorTipo(tipo: _tipo, onChanged: _trocarTipo),
            const SizedBox(height: 20),
            _CampoValor(
                controller: _valor,
                cor: _tipo.cor,
                autofocus: _editando == null),
            const SizedBox(height: 24),
            GranioTextField(
              label: transf ? 'Descrição (opcional)' : 'Descrição',
              hint: switch (_tipo) {
                TipoTransacao.receita => 'Ex.: Salário de novembro',
                TipoTransacao.despesa => 'Ex.: Mercado do mês',
                TipoTransacao.transferencia => 'Transferência',
              },
              icon: Icons.short_text_rounded,
              controller: _descricao,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 20),
            if (!transf) ...[
              const RotuloCampo('Categoria'),
              _GradeCategorias(
                categorias: _categoriasDoTipo,
                selecionada: _idCategoria,
                onSelecionar: (id) => setState(() => _idCategoria = id),
                onNova: _novaCategoria,
              ),
              const SizedBox(height: 20),
              const RotuloCampo('Conta'),
              _ListaContas(
                contas: _contasVisiveis,
                selecionada: _idConta,
                onSelecionar: (id) => setState(() => _idConta = id),
                onNova: _novaConta,
              ),
            ] else ...[
              const RotuloCampo('Sai de'),
              _ListaContas(
                contas: _contasVisiveis,
                selecionada: _idConta,
                onSelecionar: (id) => setState(() => _idConta = id),
                onNova: _novaConta,
              ),
              const SizedBox(height: 16),
              const RotuloCampo('Entra em'),
              _ListaContas(
                contas: _contasVisiveis,
                selecionada: _idDestino,
                desabilitada: _idConta,
                onSelecionar: (id) => setState(() => _idDestino = id),
                onNova: _novaConta,
              ),
            ],
            const SizedBox(height: 20),
            const RotuloCampo('Data'),
            _SeletorData(
              data: _data,
              onChanged: (d) => setState(() => _data = d),
              onCalendario: _escolherData,
            ),
            const SizedBox(height: 20),
            if (_mostrarObs)
              GranioTextField(
                label: 'Observação',
                hint: 'Algum detalhe para lembrar depois',
                icon: Icons.notes_rounded,
                controller: _observacao,
                textCapitalization: TextCapitalization.sentences,
              )
            else
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: GranioColors.emerald,
                  ),
                  onPressed: () => setState(() => _mostrarObs = true),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Adicionar observação'),
                ),
              ),
            const SizedBox(height: 28),
            _salvando
                ? const Center(
                    child:
                        CircularProgressIndicator(color: GranioColors.emerald))
                : GranioButton(
                    label: _editando == null ? 'Salvar' : 'Salvar alterações',
                    icon: Icons.check_rounded,
                    onPressed: _salvar,
                  ),
          ],
        ),
      ),
    );
  }
}

class _SeletorTipo extends StatelessWidget {
  final TipoTransacao tipo;
  final ValueChanged<TipoTransacao> onChanged;

  const _SeletorTipo({required this.tipo, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final c = GranioColors.of(context);
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
      ),
      child: Row(
        children: [
          for (final t in TipoTransacao.values)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(t),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  decoration: BoxDecoration(
                    color: t == tipo
                        ? t.cor.withValues(alpha: 0.16)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(t.icone,
                          size: 16, color: t == tipo ? t.cor : c.textMuted),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          t.rotulo,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: t == tipo ? t.cor : c.textMuted,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Valor grande, digitado estilo app de banco (centavos entram pela direita).
class _CampoValor extends StatelessWidget {
  final TextEditingController controller;
  final Color cor;
  final bool autofocus;

  const _CampoValor({
    required this.controller,
    required this.cor,
    required this.autofocus,
  });

  @override
  Widget build(BuildContext context) {
    final c = GranioColors.of(context);
    return Column(
      children: [
        Text('Valor', style: TextStyle(color: c.textMuted, fontSize: 13)),
        const SizedBox(height: 4),
        IntrinsicWidth(
          child: TextField(
            controller: controller,
            autofocus: autofocus,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            inputFormatters: const [CentavosInputFormatter()],
            cursorColor: cor,
            style: TextStyle(
              color: cor,
              fontSize: 40,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: '0,00',
              hintStyle: TextStyle(color: cor.withValues(alpha: 0.35)),
              prefixText: 'R\$ ',
              prefixStyle: TextStyle(
                color: cor,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GradeCategorias extends StatelessWidget {
  final List<Categoria> categorias;
  final int? selecionada;
  final ValueChanged<int> onSelecionar;
  final VoidCallback onNova;

  const _GradeCategorias({
    required this.categorias,
    required this.selecionada,
    required this.onSelecionar,
    required this.onNova,
  });

  @override
  Widget build(BuildContext context) {
    final c = GranioColors.of(context);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final cat in categorias)
          _Chip(
            icone: GranioIcones.categoria(cat.icone),
            rotulo: cat.nome,
            cor: cat.cor,
            selecionado: cat.id == selecionada,
            onTap: () => onSelecionar(cat.id!),
          ),
        _Chip(
          icone: Icons.add_rounded,
          rotulo: 'Nova',
          cor: c.textMuted,
          selecionado: false,
          tracejado: true,
          onTap: onNova,
        ),
      ],
    );
  }
}

class _ListaContas extends StatelessWidget {
  final List<Conta> contas;
  final int? selecionada;
  final int? desabilitada;
  final ValueChanged<int> onSelecionar;
  final VoidCallback onNova;

  const _ListaContas({
    required this.contas,
    required this.selecionada,
    required this.onSelecionar,
    required this.onNova,
    this.desabilitada,
  });

  @override
  Widget build(BuildContext context) {
    final c = GranioColors.of(context);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final conta in contas)
          Opacity(
            opacity: conta.id == desabilitada ? 0.4 : 1,
            child: _Chip(
              icone: GranioIcones.conta(conta.tipo),
              rotulo: conta.nome,
              cor: conta.cor,
              selecionado: conta.id == selecionada,
              onTap: conta.id == desabilitada
                  ? null
                  : () => onSelecionar(conta.id!),
            ),
          ),
        _Chip(
          icone: Icons.add_rounded,
          rotulo: 'Nova conta',
          cor: c.textMuted,
          selecionado: false,
          tracejado: true,
          onTap: onNova,
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icone;
  final String rotulo;
  final Color cor;
  final bool selecionado;
  final bool tracejado;
  final VoidCallback? onTap;

  const _Chip({
    required this.icone,
    required this.rotulo,
    required this.cor,
    required this.selecionado,
    required this.onTap,
    this.tracejado = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = GranioColors.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selecionado ? cor.withValues(alpha: 0.16) : c.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selecionado ? cor : c.border,
            width: selecionado ? 1.6 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, size: 18, color: tracejado ? c.textMuted : cor),
            const SizedBox(width: 8),
            Text(
              rotulo,
              style: TextStyle(
                color: tracejado ? c.textMuted : c.text,
                fontSize: 13,
                fontWeight: selecionado ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SeletorData extends StatelessWidget {
  final DateTime data;
  final ValueChanged<DateTime> onChanged;
  final VoidCallback onCalendario;

  const _SeletorData({
    required this.data,
    required this.onChanged,
    required this.onCalendario,
  });

  @override
  Widget build(BuildContext context) {
    final hoje = soData(DateTime.now());
    final ontem = hoje.subtract(const Duration(days: 1));
    final outra = data != hoje && data != ontem;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _Chip(
          icone: Icons.today_rounded,
          rotulo: 'Hoje',
          cor: GranioColors.emerald,
          selecionado: data == hoje,
          onTap: () => onChanged(hoje),
        ),
        _Chip(
          icone: Icons.history_rounded,
          rotulo: 'Ontem',
          cor: GranioColors.emerald,
          selecionado: data == ontem,
          onTap: () => onChanged(ontem),
        ),
        _Chip(
          icone: Icons.calendar_month_rounded,
          rotulo: outra ? dataRelativa(data) : 'Outra data',
          cor: GranioColors.emerald,
          selecionado: outra,
          onTap: onCalendario,
        ),
      ],
    );
  }
}
