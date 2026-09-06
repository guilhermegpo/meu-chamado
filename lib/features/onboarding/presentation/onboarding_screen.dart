import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meu_chamado/app/theme/app_tokens.dart';
import 'package:meu_chamado/features/workspace/application/workspace_providers.dart';
import 'package:meu_chamado/features/workspace/data/workspace_repository.dart';
import 'package:meu_chamado/shared/widgets/app_surfaces.dart';
import 'package:meu_chamado/shared/widgets/apps_meu_mark.dart';

typedef OnboardingWorkspaceCreator = Future<void> Function({
  required String workspaceName,
  required String administratorName,
  String? photoPath,
});

typedef OnboardingPhotoSelector = Future<String?> Function();

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({
    this.onCreateWorkspace,
    this.onSelectPhoto,
    super.key,
  });

  /// Optional seam for flows that also persist the selected profile photo.
  ///
  /// When omitted, onboarding keeps using [WorkspaceRepository] directly.
  final OnboardingWorkspaceCreator? onCreateWorkspace;

  /// Optional seam for a platform photo picker. The presentation layer does
  /// not depend on a picker package and only retains the returned local path.
  final OnboardingPhotoSelector? onSelectPhoto;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const _stepCount = 3;

  final _workspaceController = TextEditingController();
  final _administratorController = TextEditingController();

  int _step = 0;
  bool _saving = false;
  bool _selectingPhoto = false;
  String? _photoPath;
  String? _workspaceError;
  String? _administratorError;
  String? _error;

  @override
  void dispose() {
    _workspaceController.dispose();
    _administratorController.dispose();
    super.dispose();
  }

  bool _validateWorkspace() {
    final error = _required(_workspaceController.text);
    setState(() => _workspaceError = error);
    return error == null;
  }

  bool _validateAdministrator() {
    final error = _required(_administratorController.text);
    setState(() => _administratorError = error);
    return error == null;
  }

  void _nextStep() {
    FocusScope.of(context).unfocus();
    if (_step == 1 && !_validateWorkspace()) return;
    setState(() {
      _error = null;
      _step += 1;
    });
  }

  void _previousStep() {
    FocusScope.of(context).unfocus();
    if (_step == 0 || _saving) return;
    setState(() {
      _error = null;
      _step -= 1;
    });
  }

  Future<void> _selectPhoto() async {
    final selector = widget.onSelectPhoto;
    if (selector == null || _selectingPhoto) return;

    setState(() {
      _selectingPhoto = true;
      _error = null;
    });

    try {
      final selectedPath = await selector();
      if (mounted && selectedPath != null && selectedPath.trim().isNotEmpty) {
        setState(() => _photoPath = selectedPath);
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'Não foi possível selecionar a foto. Você pode continuar sem ela.',
        );
      }
    } finally {
      if (mounted) setState(() => _selectingPhoto = false);
    }
  }

  Future<void> _createWorkspace() async {
    FocusScope.of(context).unfocus();
    if (!_validateWorkspace() || !_validateAdministrator()) return;

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final creator = widget.onCreateWorkspace;
      if (creator != null) {
        await creator(
          workspaceName: _workspaceController.text.trim(),
          administratorName: _administratorController.text.trim(),
          photoPath: _photoPath,
        );
      } else {
        await ref
            .read(workspaceRepositoryProvider)
            .createLocalWorkspace(
              workspaceName: _workspaceController.text,
              administratorName: _administratorController.text,
              administratorPhotoPath: _photoPath,
            );
      }
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
    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _previousStep();
      },
      child: Scaffold(
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                Spacing.screenGutter,
                Spacing.lg,
                Spacing.screenGutter,
                Spacing.xl,
              ),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 560,
                    minHeight: constraints.maxHeight > 44
                        ? constraints.maxHeight - 44
                        : 0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _OnboardingHeader(step: _step, stepCount: _stepCount),
                      const SizedBox(height: Spacing.section),
                      AnimatedSwitcher(
                        duration: Motion.adaptive(context, Motion.component),
                        switchInCurve: Motion.enter,
                        switchOutCurve: Motion.exit,
                        transitionBuilder: (child, animation) => FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.04, 0),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        ),
                        child: KeyedSubtree(
                          key: ValueKey(_step),
                          child: switch (_step) {
                            0 => const _IntroductionStep(),
                            1 => _WorkspaceStep(
                              controller: _workspaceController,
                              errorText: _workspaceError,
                              onChanged: (_) {
                                if (_workspaceError != null) {
                                  setState(() => _workspaceError = null);
                                }
                              },
                              onSubmitted: (_) => _nextStep(),
                            ),
                            _ => _AdministratorStep(
                              controller: _administratorController,
                              errorText: _administratorError,
                              photoSelected: _photoPath != null,
                              selectingPhoto: _selectingPhoto,
                              photoSelectionAvailable:
                                  widget.onSelectPhoto != null,
                              onChanged: (_) {
                                if (_administratorError != null) {
                                  setState(() => _administratorError = null);
                                }
                              },
                              onSubmitted: (_) =>
                                  _saving ? null : _createWorkspace(),
                              onSelectPhoto: _selectPhoto,
                            ),
                          },
                        ),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: Spacing.md),
                        Semantics(
                          liveRegion: true,
                          child: Text(
                            _error!,
                            key: const Key('onboarding-error'),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: Spacing.section),
                      _OnboardingNavigation(
                        step: _step,
                        saving: _saving,
                        onBack: _previousStep,
                        onNext: _step == _stepCount - 1
                            ? _createWorkspace
                            : _nextStep,
                      ),
                      const SizedBox(height: Spacing.lg),
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
      ),
    );
  }
}

class _OnboardingHeader extends StatelessWidget {
  const _OnboardingHeader({required this.step, required this.stepCount});

  final int step;
  final int stepCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const AppsMeuMark(size: 48, shadow: true),
        const SizedBox(width: Spacing.md),
        Expanded(
          child: Semantics(
            label: 'Etapa ${step + 1} de $stepCount',
            child: ExcludeSemantics(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'MEU CHAMADO · ETAPA ${step + 1} DE $stepCount',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: Spacing.xs),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(end: (step + 1) / stepCount),
                      duration: Motion.adaptive(context, Motion.component),
                      curve: Motion.enter,
                      builder: (context, value, _) =>
                          LinearProgressIndicator(value: value, minHeight: 6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _IntroductionStep extends StatelessWidget {
  const _IntroductionStep();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSurface(
          gradient: AppGradients.darkHero,
          border: const Border(),
          shadow: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(
                  'Organize seus chamados no seu ritmo.',
                  key: const Key('onboarding-title'),
                  style: Theme.of(context).textTheme.headlineSmall
                      ?.copyWith(color: Colors.white),
                ),
              ),
              const SizedBox(height: Spacing.sm),
              Text(
                'Reúna pessoas e responsabilidades em um lugar simples de '
                'consultar.',
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: Colors.white.withValues(alpha: 0.78)),
              ),
            ],
          ),
        ),
        const SizedBox(height: Spacing.section),
        const _FeatureTile(
          icon: Icons.view_list_outlined,
          title: 'Organize',
          description: 'Registre chamados sem depender de planilhas soltas.',
        ),
        const SizedBox(height: Spacing.sm),
        const _FeatureTile(
          icon: Icons.track_changes_outlined,
          title: 'Acompanhe',
          description:
              'Consulte o que está ativo e mantenha o histórico claro.',
        ),
        const SizedBox(height: Spacing.sm),
        const _FeatureTile(
          icon: Icons.phone_android_outlined,
          title: 'Comece local',
          description:
              'Nesta versão, seus dados ficam neste dispositivo. O '
              'compartilhamento poderá chegar no futuro.',
        ),
      ],
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      padding: const EdgeInsets.all(Spacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppIconTile(icon: icon, size: 44),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: Spacing.xxs),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkspaceStep extends StatelessWidget {
  const _WorkspaceStep({
    required this.controller,
    required this.errorText,
    required this.onChanged,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final String? errorText;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(
            'Crie seu Workspace',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        const SizedBox(height: Spacing.sm),
        Text(
          'O Workspace reúne as pessoas e os chamados que você administra.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: Spacing.lg),
        AppSurface(
          padding: const EdgeInsets.all(Spacing.md),
          color: colors.secondaryContainer,
          border: const Border(),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.offline_bolt_outlined,
                color: colors.onSecondaryContainer,
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Workspace LOCAL',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: colors.onSecondaryContainer,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: Spacing.xxs),
                    Text(
                      'Funciona sem conta externa. Os dados ficam somente neste dispositivo e o compartilhamento ainda não está disponível.',
                      style: TextStyle(color: colors.onSecondaryContainer),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Spacing.lg),
        TextField(
          key: const Key('workspace-name-field'),
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'Nome do Workspace',
            hintText: 'Ex.: Minha comunidade',
            helperText: 'Você poderá alterar esse nome depois.',
            errorText: errorText,
            prefixIcon: const Icon(Icons.workspaces_outline),
          ),
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.next,
          maxLength: 80,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
        ),
      ],
    );
  }
}

class _AdministratorStep extends StatelessWidget {
  const _AdministratorStep({
    required this.controller,
    required this.errorText,
    required this.photoSelected,
    required this.selectingPhoto,
    required this.photoSelectionAvailable,
    required this.onChanged,
    required this.onSubmitted,
    required this.onSelectPhoto,
  });

  final TextEditingController controller;
  final String? errorText;
  final bool photoSelected;
  final bool selectingPhoto;
  final bool photoSelectionAvailable;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onSelectPhoto;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(
            'Crie o primeiro usuário',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        const SizedBox(height: Spacing.sm),
        Text(
          'Esse perfil começa como ADMIN para configurar o Workspace e gerenciar os demais usuários.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: Spacing.md),
        Align(
          alignment: Alignment.centerLeft,
          child: Semantics(
            label: 'Perfil Administrador, acesso completo',
            child: Chip(
              avatar: const Icon(Icons.admin_panel_settings_outlined, size: 20),
              label: const Text('ADMIN · acesso completo'),
              backgroundColor: colors.tertiaryContainer,
              side: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: Spacing.lg),
        TextField(
          key: const Key('administrator-name-field'),
          controller: controller,
          autofocus: true,
          autofillHints: const [AutofillHints.name],
          decoration: InputDecoration(
            labelText: 'Seu nome',
            hintText: 'Ex.: Alex Silva',
            errorText: errorText,
            prefixIcon: const Icon(Icons.person_outline),
          ),
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.done,
          maxLength: 80,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
        ),
        const SizedBox(height: Spacing.sm),
        if (photoSelectionAvailable)
          OutlinedButton.icon(
            key: const Key('select-profile-photo-button'),
            onPressed: selectingPhoto ? null : onSelectPhoto,
            icon: selectingPhoto
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    photoSelected
                        ? Icons.check_circle_outline
                        : Icons.add_a_photo_outlined,
                  ),
            label: Text(
              selectingPhoto
                  ? 'Abrindo fotos…'
                  : photoSelected
                  ? 'Foto selecionada · alterar'
                  : 'Adicionar foto (opcional)',
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
          )
        else
          Semantics(
            label: 'Foto de perfil opcional. Pode ser adicionada depois.',
            child: AppSurface(
              padding: const EdgeInsets.all(Spacing.md),
              child: Row(
                children: [
                  Icon(
                    Icons.add_a_photo_outlined,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: Text(
                      'Foto opcional · você poderá adicionar depois.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _OnboardingNavigation extends StatelessWidget {
  const _OnboardingNavigation({
    required this.step,
    required this.saving,
    required this.onBack,
    required this.onNext,
  });

  final int step;
  final bool saving;
  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final isLastStep = step == _OnboardingScreenState._stepCount - 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          key: isLastStep
              ? const Key('create-workspace-button')
              : const Key('onboarding-next-button'),
          onPressed: saving ? null : onNext,
          icon: saving
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(isLastStep ? Icons.check : Icons.arrow_forward),
          label: Text(
            saving
                ? 'Criando…'
                : isLastStep
                ? 'Criar Workspace local'
                : step == 0
                ? 'Começar'
                : 'Continuar',
          ),
        ),
        if (step > 0) ...[
          const SizedBox(height: Spacing.xs),
          TextButton.icon(
            key: const Key('onboarding-back-button'),
            onPressed: saving ? null : onBack,
            icon: const Icon(Icons.arrow_back),
            label: const Text('Voltar'),
          ),
        ],
      ],
    );
  }
}
