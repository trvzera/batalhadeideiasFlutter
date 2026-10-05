# Batalha de Ideias — instalação

O pacote contém a pasta lib, regras do Firestore e este guia. Use um projeto Flutter recente.
Se ainda não tem um projeto, execute `flutter create batalha_ideias` e entre nele.

## 1. Copiar os arquivos

Substitua a pasta lib do seu projeto pela pasta lib deste pacote.
Não substitua o pubspec.yaml: instale os pacotes abaixo pelo terminal na raiz do projeto.

```bash
flutter pub add firebase_core cloud_firestore firebase_auth device_preview
```

## 2. Preparar o Firebase

1. Acesse https://console.firebase.google.com/ e crie ou escolha um projeto.
2. Em Build > Firestore Database, crie o banco padrão (default), em modo de produção.
3. Em Build > Authentication > Get started > Sign-in method, habilite Anonymous (Anônimo).
4. Na aba Rules (Regras) do Firestore, substitua as regras pelo conteúdo de firestore.rules e clique em Publish (Publicar).

O login anônimo é automático: o aplicativo não precisa de tela de login. Todos os usuários
autenticados podem ler, cadastrar, votar e excluir, como solicitado na atividade.
O exercício não limita votos por pessoa: cada clique confirmado acrescenta um voto.
Estas permissões são adequadas à atividade, na qual a exclusão está disponível a todos.

## 3. Conectar Flutter e Firebase

Instale Node.js LTS se não tiver npm. Execute:

```bash
npm install -g firebase-tools
firebase login
dart pub global activate flutterfire_cli
flutterfire configure
```

Escolha O MESMO projeto Firebase em todos os dispositivos e marque Web e as outras
plataformas que pretende usar. O comando gera lib/firebase_options.dart, necessário
para compilar. Ele não vem no ZIP porque depende do seu próprio projeto Firebase.

Se flutterfire não for reconhecido no Windows, adicione ao PATH a pasta
%LOCALAPPDATA%\Pub\Cache\bin, reabra o terminal e tente novamente.

## 4. Executar

```bash
dart format lib
flutter analyze lib
flutter run -d chrome
```

O Device Preview aparece no modo de desenvolvimento. Você pode desativá-lo pelo painel
para usar a tela inteira. Em release ele é desativado automaticamente.

Se o projeto ainda tiver o teste padrão test/widget_test.dart, atualize-o para o aplicativo
novo ou remova esse teste de exemplo: ele faz referência ao contador/MyApp antigo.

## 5. Teste obrigatório em dois navegadores

Uma alternativa para abrir o mesmo aplicativo no Chrome e no Edge:

```bash
flutter run -d web-server --web-hostname localhost --web-port 8080
```

Abra http://localhost:8080 nos dois navegadores, mantendo o terminal aberto.
1. Cadastre uma ideia no Chrome: ela deve aparecer também no Edge com zero votos.
2. Vote no Edge: o Chrome deve mostrar mais um voto, sem atualizar a página.
3. Cadastre e vote em outras ideias: confira a ordenação e o ranking (inclui empates).
4. Exclua uma ideia: ela deve desaparecer nos dois navegadores.
5. Feche e abra novamente: os dados devem permanecer no Firestore.

Para testar em computadores diferentes, execute o app em cada um, ambos conectados
ao mesmo projeto Firebase. Não use localhost do primeiro computador no segundo.

## Arquivos

- lib/main.dart: inicialização, autenticação e Device Preview.
- lib/models/ideia.dart: modelo dos quatro campos exigidos.
- lib/services/ideias_service.dart: cadastro, snapshots, incremento atômico e exclusão.
- lib/screens/ideias_page.dart: formulário, listagem e ranking em tempo real.
- lib/firebase_options.dart: gerado por flutterfire configure.
- firestore.rules: regras para publicar no console Firebase.

As listas exibidas são derivadas dos snapshots do Firestore; não simulam um banco local.
A classificação é feita sobre os documentos recebidos, sem precisar de índice composto.

## Erros comuns

- Target of URI doesn't exist firebase_options.dart: execute flutterfire configure.
- operation-not-allowed: habilite o provedor Anonymous em Authentication.
- permission-denied: publique as regras no mesmo projeto/banco utilizado pelo app.
- Nenhuma ideia aparece: confira se os dispositivos usam o mesmo projeto Firebase.
- Erro ao ler campos: a coleção ideias deve usar titulo, descricao, autor como strings
  e votos como inteiro. Não cadastre manualmente documentos com campos diferentes.

## Validação

O código foi revisado, mas não foi compilado neste ambiente, que não possui Flutter/Dart.
A compilação e o teste compartilhado precisam ser executados após a configuração
do seu Firebase. Não foram feitos testes em um banco Firebase real.

Referências oficiais:
- https://firebase.google.com/docs/flutter/setup
- https://firebase.google.com/docs/firestore/query-data/listen
