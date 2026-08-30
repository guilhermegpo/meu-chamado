import 'package:meu_chamado/features/ministering/domain/ministering_models.dart';

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

/// Líder inativo sendo escolhido como entrevistador.
class InactiveInterviewerException extends MinisteringException {
  const InactiveInterviewerException()
    : super(
        'A liderança escolhida está inativa. Reative-a ou escolha outra para '
        'conduzir a entrevista.',
      );
}

/// Nenhuma liderança ativa cadastrada quando uma entrevista precisa de um
/// entrevistador. O entrevistador nunca é inferido: sem liderança não há quem
/// registrar.
class NoActiveInterviewerException extends MinisteringException {
  const NoActiveInterviewerException()
    : super(
        'Cadastre a liderança responsável pelas entrevistas antes de agendar '
        'ou registrar.',
      );
}

/// Segunda tentativa de agendar para uma dupla que já tem agendamento aberto.
class CompanionshipAlreadyScheduledException extends MinisteringException {
  const CompanionshipAlreadyScheduledException()
    : super(
        'Esta dupla já tem uma entrevista agendada. Reagende ou cancele a '
        'existente.',
      );
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

/// Exclusão recusada porque o cadastro é citado por outros registros.
///
/// A mensagem diz o que existe, não quem: o secretário precisa entender por
/// que a ação não está disponível sem que o app aponte uma pessoa.
class MinisteringRecordInUseException extends MinisteringException {
  const MinisteringRecordInUseException(super.message);

  factory MinisteringRecordInUseException.brother(
    MinisteringRemovalCheck check,
  ) => MinisteringRecordInUseException(
    check.hasHistory
        ? 'Este irmão já participou de entrevistas registradas. Desative-o '
              'em vez de excluir, para não apagar o histórico.'
        : 'Este irmão compõe uma dupla. Remova-o da dupla ou desative-o.',
  );

  factory MinisteringRecordInUseException.companionship(
    MinisteringRemovalCheck check,
  ) {
    if (check.interviews > 0) {
      return MinisteringRecordInUseException(
        'Esta dupla tem ${check.interviews} '
        'entrevista${check.interviews == 1 ? '' : 's'} registrada'
        '${check.interviews == 1 ? '' : 's'}. Desative-a em vez de excluir, '
        'para não apagar o histórico.',
      );
    }
    return const MinisteringRecordInUseException(
      'Esta dupla tem uma entrevista agendada. Cancele o agendamento antes de '
      'excluir a dupla.',
    );
  }

  factory MinisteringRecordInUseException.leader(
    MinisteringRemovalCheck check,
  ) {
    if (check.hasHistory) {
      return const MinisteringRecordInUseException(
        'Esta liderança consta no histórico de entrevistas. Desative-a em vez '
        'de excluir, para não apagar o histórico.',
      );
    }
    return const MinisteringRecordInUseException(
      'Esta liderança tem entrevistas agendadas. Reatribua ou cancele os '
      'agendamentos, ou desative a liderança.',
    );
  }
}

/// Registro não encontrado no chamado informado.
///
/// Também é o que responde a uma tentativa de alcançar dado de outro chamado:
/// do ponto de vista do módulo, o registro simplesmente não existe.
class MinisteringRecordNotFoundException extends MinisteringException {
  const MinisteringRecordNotFoundException()
    : super('Registro não encontrado neste chamado.');
}
