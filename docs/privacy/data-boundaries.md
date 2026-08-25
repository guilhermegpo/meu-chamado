# Limites de dados e privacidade

## Princípio

Coletar, armazenar e compartilhar apenas o necessário para a função escolhida
pela pessoa. O fato de um Workspace ser compartilhado não torna todo dado
automaticamente compartilhável.

## Limites

```text
WorkspaceSharedData
PrivateCallingData
```

### WorkspaceSharedData

Pode incluir, conforme consentimento e necessidade:

- configuração e identificador do Workspace;
- perfis dos usuários do aplicativo;
- fotos de perfil desses usuários;
- configuração de chamados;
- preferências compartilhadas;
- indicadores agregados não sensíveis.

### PrivateCallingData

Inclui listas nominais, anotações, agenda e conteúdo específico que possa revelar
informações pessoais, religiosas ou pastorais. Deve permanecer local/protegido
até existir base técnica, autorização e finalidade documentadas para qualquer
tratamento diferente.

## Google Drive futuro

- usar privilégio mínimo, preferindo escopo semelhante a `drive.file`;
- selecionar pasta explicitamente quando possível;
- não pedir acesso indiscriminado ao Drive;
- não colocar SQLite diretamente em pasta sincronizada;
- não tratar Drive como PostgreSQL/MySQL;
- validar acesso e versão do manifesto do Workspace;
- documentar conflitos, criptografia, revogação e recuperação antes de ativar.

## Repositório público

Nunca versionar:

- nomes ou dados reais de membros;
- telefone, endereço ou informações de unidade local;
- exportações, bancos ou backups reais;
- tokens, OAuth secrets ou identificadores de pasta real;
- logs com conteúdo privado;
- screenshots com pessoas ou dados reais.

## Logs

Logs devem usar identificadores técnicos não reversíveis quando possível e não
devem registrar nomes, conteúdo religioso sensível, tokens, caminhos privados ou
credenciais. Mensagens de erro para suporte precisam ser sanitizadas antes do
compartilhamento.

## Exclusão e exportação

Fluxos futuros devem distinguir arquivamento, exclusão local, exclusão
compartilhada e exportação. Cada ação precisa explicar alcance, reversibilidade e
efeito sobre backups.
