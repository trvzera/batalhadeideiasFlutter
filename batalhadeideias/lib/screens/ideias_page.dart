import 'package:flutter/material.dart';
import '../models/ideia.dart';
import '../services/ideias_service.dart';

class IdeiasPage extends StatefulWidget {
  const IdeiasPage({super.key});

  @override
  State<IdeiasPage> createState() => _IdeiasPageState();
}

class _IdeiasPageState extends State<IdeiasPage> {
  final _service = IdeiasService();
  late final Stream<List<Ideia>> _stream;
  final Set<String> _ocupadas = {};

  @override
  void initState() {
    super.initState();
    _stream = _service.acompanhar();
  }

  void _mensagem(String texto) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  Future<void> _votar(Ideia ideia) async {
    if (_ocupadas.contains(ideia.id)) return;
    setState(() => _ocupadas.add(ideia.id));
    try {
      await _service.votar(ideia.id);
    } catch (_) {
      _mensagem(
          'Não foi possível votar. Confira sua conexão e as regras do Firebase.');
    } finally {
      if (mounted) setState(() => _ocupadas.remove(ideia.id));
    }
  }

  Future<void> _excluir(Ideia ideia) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir ideia?'),
        content:
            Text('“${ideia.titulo}” será removida para todos os usuários.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Excluir')),
        ],
      ),
    );
    if (confirmar != true || !mounted || _ocupadas.contains(ideia.id)) return;
    setState(() => _ocupadas.add(ideia.id));
    try {
      await _service.excluir(ideia.id);
      _mensagem('Ideia excluída.');
    } catch (_) {
      _mensagem('Não foi possível excluir a ideia.');
    } finally {
      if (mounted) setState(() => _ocupadas.remove(ideia.id));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Batalha de Ideias')),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (_) => _CadastroDialog(service: _service),
          ),
          icon: const Icon(Icons.add),
          label: const Text('Nova ideia'),
        ),
        body: Center(
            child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: StreamBuilder<List<Ideia>>(
            stream: _stream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                        'Não foi possível carregar as ideias. Confira a conexão, o Cloud Firestore '
                        'e suas regras de acesso.'));
              }
              if (!snapshot.hasData)
                return const Center(child: CircularProgressIndicator());
              final ideias = snapshot.data!;
              if (ideias.isEmpty) {
                return const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lightbulb_outline, size: 64),
                      SizedBox(height: 16),
                      Text('Nenhuma ideia cadastrada.'),
                      Text('Toque em Nova ideia para começar.'),
                    ]);
              }
              final lideres =
                  ideias.where((i) => i.votos == ideias.first.votos).toList();
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                children: [
                  Card(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                lideres.length > 1
                                    ? '🏆 EMPATE NO PRIMEIRO LUGAR'
                                    : '🏆 IDEIA MAIS VOTADA',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text(lideres.map((i) => i.titulo).join(' • '),
                                style: Theme.of(context).textTheme.titleLarge),
                            Text('${ideias.first.votos} votos'),
                          ],
                        )),
                  ),
                  Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                          '${ideias.length} ideias • Ranking em tempo real')),
                  for (final ideia in ideias)
                    Card(
                        child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                          child: Text(ideia.titulo,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge)),
                                      IconButton(
                                          tooltip: 'Excluir ideia',
                                          onPressed:
                                              _ocupadas.contains(ideia.id)
                                                  ? null
                                                  : () => _excluir(ideia),
                                          icon:
                                              const Icon(Icons.delete_outline)),
                                    ]),
                                Text('Por ${ideia.autor}'),
                                const SizedBox(height: 12),
                                Text(ideia.descricao),
                                const SizedBox(height: 16),
                                Row(children: [
                                  const Icon(Icons.favorite, size: 18),
                                  const SizedBox(width: 6),
                                  Expanded(child: Text('${ideia.votos} votos')),
                                  FilledButton.icon(
                                      onPressed: _ocupadas.contains(ideia.id)
                                          ? null
                                          : () => _votar(ideia),
                                      icon: const Icon(Icons.thumb_up_outlined,
                                          size: 18),
                                      label: const Text('VOTAR')),
                                ]),
                              ],
                            ))),
                ],
              );
            },
          ),
        )),
      );
}

class _CadastroDialog extends StatefulWidget {
  final IdeiasService service;
  const _CadastroDialog({required this.service});

  @override
  State<_CadastroDialog> createState() => _CadastroDialogState();
}

class _CadastroDialogState extends State<_CadastroDialog> {
  final _form = GlobalKey<FormState>();
  final _titulo = TextEditingController();
  final _descricao = TextEditingController();
  final _autor = TextEditingController();
  bool _salvando = false;
  String? _erro;

  @override
  void dispose() {
    _titulo.dispose();
    _descricao.dispose();
    _autor.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (_salvando || !_form.currentState!.validate()) return;
    setState(() {
      _salvando = true;
      _erro = null;
    });
    try {
      await widget.service
          .cadastrar(_titulo.text, _descricao.text, _autor.text);
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted)
        setState(() => _erro =
            'Erro ao salvar. Confira a conexão e as regras do Firestore.');
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  Widget _campo(TextEditingController controller, String nome, int limite,
          {int linhas = 1}) =>
      Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TextFormField(
            controller: controller,
            enabled: !_salvando,
            maxLength: limite,
            maxLines: linhas,
            decoration: InputDecoration(labelText: nome),
            validator: (value) =>
                value == null || value.trim().isEmpty ? 'Informe $nome.' : null,
          ));

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: !_salvando,
        child: AlertDialog(
          title: const Text('Cadastrar ideia'),
          content: SizedBox(
              width: 480,
              child: SingleChildScrollView(
                  child: Form(
                key: _form,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  _campo(_titulo, 'Título', 100),
                  _campo(_descricao, 'Descrição', 1000, linhas: 4),
                  _campo(_autor, 'Autor', 80),
                  if (_erro != null)
                    Text(_erro!,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error)),
                ]),
              ))),
          actions: [
            TextButton(
                onPressed: _salvando ? null : () => Navigator.pop(context),
                child: const Text('Cancelar')),
            FilledButton(
                onPressed: _salvando ? null : _salvar,
                child: Text(_salvando ? 'Salvando...' : 'Cadastrar')),
          ],
        ),
      );
}
