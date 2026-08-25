import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meu_chamado/features/workspace/application/workspace_providers.dart';
import 'package:meu_chamado/features/workspace/data/workspace_repository.dart';
import 'package:meu_chamado/shared/widgets/apps_meu_mark.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _workspaceController = TextEditingController();
  final _administratorController = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _workspaceController.dispose();
    _administratorController.dispose();
    super.dispose();
  }

  Future<void> _createWorkspace() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await ref
          .read(workspaceRepositoryProvider)
          .createLocalWorkspace(
            workspaceName: _workspaceController.text,
            administratorName: _administratorController.text,
          );
      ref.invalidate(workspaceBootstrapProvider);
    } on WorkspaceValidationException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'Não foi possível criar o Workspace. Tente novamente.',
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String? _required(String? value) => value == null || value.trim().isEmpty
      ? 'Este campo é obrigatório.'
      : null;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: AppsMeuMark(size: 72),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Organize seus chamados no seu ritmo.',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Comece com um Workspace local. Seus dados ficam neste dispositivo e nenhuma conta externa é necessária.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 28),
                    Card(
                      color: colors.secondaryContainer,
                      child: const Padding(
                        padding: EdgeInsets.all(18),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.offline_bolt_outlined),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Modo Local selecionado\nFunciona offline e poderá ser convertido em compartilhado em uma versão futura.',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      key: const Key('workspace-name-field'),
                      controller: _workspaceController,
                      decoration: const InputDecoration(
                        labelText: 'Nome do Workspace',
                        hintText: 'Ex.: Meu Workspace',
                        prefixIcon: Icon(Icons.workspaces_outline),
                      ),
                      textInputAction: TextInputAction.next,
                      maxLength: 80,
                      validator: _required,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      key: const Key('administrator-name-field'),
                      controller: _administratorController,
                      decoration: const InputDecoration(
                        labelText: 'Seu nome',
                        hintText: 'Ex.: Administrador Demo',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      textInputAction: TextInputAction.done,
                      maxLength: 80,
                      validator: _required,
                      onFieldSubmitted: (_) =>
                          _saving ? null : _createWorkspace(),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _error!,
                        key: const Key('onboarding-error'),
                        style: TextStyle(color: colors.error),
                      ),
                    ],
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      key: const Key('create-workspace-button'),
                      onPressed: _saving ? null : _createWorkspace,
                      icon: _saving
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.arrow_forward),
                      label: Text(
                        _saving ? 'Criando…' : 'Criar Workspace local',
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Projeto independente e não oficial.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
