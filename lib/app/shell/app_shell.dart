import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meu_chamado/features/callings/presentation/manage_callings_screen.dart';
import 'package:meu_chamado/features/home/presentation/home_screen.dart';
import 'package:meu_chamado/features/profile/presentation/profile_screen.dart';
import 'package:meu_chamado/features/settings/presentation/more_screen.dart';
import 'package:meu_chamado/features/workspace/domain/workspace_models.dart';

/// Casca do app depois que um perfil é escolhido.
///
/// Os quatro destinos são telas que já existem hoje. Não há botão central: a
/// única ação global candidata seria adicionar um chamado, que se faz uma vez
/// e já vive na aba Chamados — um botão permanente para isso seria decoração.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({
    required this.dashboard,
    required this.currentUser,
    super.key,
  });

  final WorkspaceDashboard dashboard;
  final UserProfile currentUser;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  late WorkspaceDashboard _dashboard = widget.dashboard;
  late UserProfile _currentUser = widget.currentUser;
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Voltar de uma aba interna leva ao Início antes de sair do Workspace:
      // sair direto do meio do app surpreenderia quem só queria voltar.
      canPop: _index == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(() => _index = 0);
      },
      child: Scaffold(
        body: IndexedStack(
          index: _index,
          children: [
            HomeScreen(
              dashboard: _dashboard,
              currentUser: _currentUser,
              onOpenCallings: () => _select(1),
              onReloaded: _adopt,
            ),
            ManageCallingsScreen(
              dashboard: _dashboard,
              actorId: _currentUser.id,
              targetUserId: _currentUser.id,
              showBackButton: false,
            ),
            ProfileScreen(
              dashboard: _dashboard,
              currentUser: _currentUser,
              onReloaded: _adopt,
            ),
            MoreScreen(dashboard: _dashboard, currentUser: _currentUser),
          ],
        ),
        bottomNavigationBar: _ShellNavigationBar(
          index: _index,
          onSelected: _select,
        ),
      ),
    );
  }

  void _select(int index) {
    if (index == _index) return;
    setState(() => _index = index);
  }

  /// Adota o estado recarregado por uma aba, para as outras não continuarem
  /// mostrando o Workspace anterior.
  void _adopt(WorkspaceDashboard dashboard, UserProfile user) {
    if (!mounted) return;
    setState(() {
      _dashboard = dashboard;
      _currentUser = user;
    });
  }
}

class _ShellNavigationBar extends StatelessWidget {
  const _ShellNavigationBar({required this.index, required this.onSelected});

  final int index;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        border: Border(top: BorderSide(color: scheme.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: onSelected,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          height: 68,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              key: Key('shell-tab-inicio'),
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Início',
            ),
            NavigationDestination(
              key: Key('shell-tab-chamados'),
              icon: Icon(Icons.assignment_outlined),
              selectedIcon: Icon(Icons.assignment_rounded),
              label: 'Chamados',
            ),
            NavigationDestination(
              key: Key('shell-tab-perfil'),
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Perfil',
            ),
            NavigationDestination(
              key: Key('shell-tab-mais'),
              icon: Icon(Icons.more_horiz_outlined),
              selectedIcon: Icon(Icons.more_horiz_rounded),
              label: 'Mais',
            ),
          ],
        ),
      ),
    );
  }
}
