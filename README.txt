DUO TASK — APP iPHONE + WIDGET

O que este projeto faz:
- Cria um app nativo iOS chamado DUO Task.
- O app usa o mesmo login Luisa / Enzo do DUO Task atual.
- Depois do login, abre o DUO Task existente dentro do app.
- Salva a sessão em um App Group compartilhado.
- O widget lê o mesmo token e busca as tarefas diretamente no backend do Supabase.
- Widget pequeno e médio mostram as tarefas de hoje do usuário logado.
- Ao tocar no widget, abre o DUO Task.

IMPORTANTE
Um widget real do iPhone precisa ser compilado e assinado pela Apple. O GitHub Pages/PWA sozinho não consegue criar WidgetKit.
Você precisará de um Mac com Xcode para gerar/instalar esta versão nativa.

PASSO A PASSO NO MAC
1. Instale Xcode pela App Store.
2. Instale XcodeGen:
   brew install xcodegen
3. Nesta pasta, execute:
   xcodegen generate
4. Abra DUOTask.xcodeproj no Xcode.
5. Em Signing & Capabilities:
   - escolha sua Apple ID/Team para DUOTaskApp e DUOTaskWidget;
   - mantenha o App Group `group.com.duotask.shared` nos dois targets.
   Se o identificador estiver ocupado, altere os Bundle IDs e o App Group no project.yml e nos arquivos Swift.
6. Conecte o iPhone ao Mac e execute o target DUOTaskApp.
7. Entre como Luisa ou Enzo no app.
8. No iPhone: toque e segure a Tela de Início > Editar > Adicionar Widget > procure DUO Task.
9. Escolha o widget pequeno ou médio.

Atualização
O WidgetKit controla quando widgets atualizam. O projeto pede nova leitura aproximadamente a cada 15 minutos e também atualiza quando o app faz login.
