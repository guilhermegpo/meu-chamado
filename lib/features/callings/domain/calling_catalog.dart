class CallingDefinition {
  const CallingDefinition({
    required this.moduleKey,
    required this.title,
    required this.description,
    this.hasModule = false,
  });

  final String moduleKey;
  final String title;
  final String description;

  /// Se já existe tela para as rotinas próprias deste chamado.
  ///
  /// Fonte única para as telas decidirem entre abrir o módulo e sinalizar que
  /// ele ainda não existe. A decisão nunca olha o título, que é texto livre.
  final bool hasModule;
}

abstract final class CallingCatalog {
  static const ministeringSecretary = CallingDefinition(
    moduleKey: 'ministering-secretary',
    title: 'Secretário da Ministração do Quórum de Élderes',
    description:
        'Irmãos, duplas e entrevistas do trimestre. Agendamento e relatórios '
        'chegam nas próximas versões da série 0.2.x.',
    hasModule: true,
  );

  static const sundaySchoolSecretary = CallingDefinition(
    moduleKey: 'sunday-school-secretary',
    title: 'Secretário da Escola Dominical',
    description:
        'Estrutura inicial; módulo completo previsto para a série 0.3.x.',
  );

  static const values = [ministeringSecretary, sundaySchoolSecretary];

  static CallingDefinition? byModuleKey(String moduleKey) {
    for (final definition in values) {
      if (definition.moduleKey == moduleKey) return definition;
    }
    return null;
  }
}
