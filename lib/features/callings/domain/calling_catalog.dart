class CallingDefinition {
  const CallingDefinition({
    required this.moduleKey,
    required this.title,
    required this.description,
  });

  final String moduleKey;
  final String title;
  final String description;
}

abstract final class CallingCatalog {
  static const ministeringSecretary = CallingDefinition(
    moduleKey: 'ministering-secretary',
    title: 'Secretário da Ministração do Quórum de Élderes',
    description:
        'Estrutura inicial; módulo completo previsto para a série 0.2.x.',
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
