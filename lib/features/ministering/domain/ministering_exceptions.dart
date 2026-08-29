/// Falhas de regra do módulo de ministração.
///
/// Carregam mensagem pronta para o usuário e **nunca** incluem a identificação
/// de um irmão: a mensagem descreve a regra violada, não a pessoa envolvida.
sealed class MinisteringException implements Exception {
  const MinisteringException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Identificação vazia, longa demais ou só com espaços.
class InvalidMinisteringLabelException extends MinisteringException {
  const InvalidMinisteringLabelException(super.message);
}

/// Dupla fora do intervalo de 2 a 3 integrantes.
///
/// O Manual descreve dois companheiros, com um jovem podendo ser o terceiro.
/// Não há caso oficial para quatro.
class InvalidCompanionshipSizeException extends MinisteringException {
  const InvalidCompanionshipSizeException()
    : super('Uma dupla precisa ter dois ou três integrantes.');
}

/// Irmão inativo sendo incluído em nova dupla.
class InactiveBrotherException extends MinisteringException {
  const InactiveBrotherException()
    : super('Há um irmão inativo na seleção. Reative antes de incluí-lo.');
}

/// Entrevista registrada sem nenhum participante.
class InterviewWithoutParticipantsException extends MinisteringException {
  const InterviewWithoutParticipantsException()
    : super('Marque ao menos um participante.');
}

/// Participante que não compõe a dupla entrevistada.
class ParticipantOutsideCompanionshipException extends MinisteringException {
  const ParticipantOutsideCompanionshipException()
    : super('Só é possível registrar participantes que compõem a dupla.');
}

/// Data de entrevista no futuro.
class FutureInterviewDateException extends MinisteringException {
  const FutureInterviewDateException()
    : super('A data da entrevista não pode estar no futuro.');
}

/// Registro não encontrado no chamado informado.
///
/// Também é o que responde a uma tentativa de alcançar dado de outro chamado:
/// do ponto de vista do módulo, o registro simplesmente não existe.
class MinisteringRecordNotFoundException extends MinisteringException {
  const MinisteringRecordNotFoundException()
    : super('Registro não encontrado neste chamado.');
}
