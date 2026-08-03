# Ótica Yuri — App de Gestão (Design Spec)

**Data:** 2026-08-03
**Status:** Aprovado pelo usuário
**Sistema:** OptoView para Ótica Yuri

---

## 1. Visão Geral

App mobile de gestão completa para ótica, desenvolvido em Flutter para Android. Cobre atendimento clínico, ponto de venda e gestão interna. Funciona offline com sincronização automática via Firebase.

**Nome do produto:** OptoView
**Loja:** Ótica Yuri
**Plataforma:** Android (tablet)
**Dispositivos:** 2 tablets Android simultâneos (dados sincronizados em tempo real)

---

## 2. Arquitetura

### Stack
- **App:** Flutter (Dart) — Android
- **Banco de dados:** Firebase Firestore (offline nativo)
- **Autenticação:** Firebase Auth (email/senha)
- **Arquivos:** Firebase Storage (fotos de clientes, scans de receitas)

### Camadas
```
UI (telas Flutter / Widgets)
    ↓
Repositórios (lógica de negócio, validações)
    ↓
Firebase SDK (Firestore + Auth + Storage)
    ↓
Cache local (offline automático do Firestore)
```

### Offline
- Firestore persiste todos os dados localmente no dispositivo
- Escritas offline são enfileiradas e sincronizadas quando a internet volta
- Conflitos resolvidos por timestamp (último a salvar vence)
- Nenhuma configuração extra necessária — comportamento padrão do SDK

### Multi-dispositivo
- 2 tablets logam com a mesma conta Firebase
- Dados sincronizados em tempo real entre os dispositivos
- Uso sugerido: Tablet 1 = balcão (vendas/agenda), Tablet 2 = consultório (prontuário)

---

## 3. Identidade Visual

### Co-branding
- **Tela de login / splash:** Logo da Ótica Yuri centralizado
- **Menu lateral:** Logo da Ótica Yuri no topo
- **Rodapé / tela "Sobre":** "Powered by OptoView"

### Paleta de Cores
| Elemento | Cor | Hex |
|---|---|---|
| Primária (botões, destaques) | Verde vibrante | `#4CAF50` |
| Secundária (menu, cabeçalhos) | Verde escuro | `#1B5E20` |
| Fundo | Branco | `#FFFFFF` |
| Texto principal | Verde escuro | `#1B5E20` |
| Texto secundário | Cinza médio | `#757575` |

### Layout
- Drawer lateral (menu sanduíche) com os 6 módulos
- Fundo do drawer: verde escuro `#1B5E20`, ícones e texto brancos
- Cards com fundo branco, sombra suave, bordas arredondadas
- Campos de formulário grandes (otimizados para toque em tablet)
- Tema claro (light mode)

---

## 4. Navegação

### Tela Inicial (Dashboard)
- Resumo do dia:
  - Consultas agendadas para hoje
  - Pedidos prontos para entrega
  - Total de vendas do dia
- Atalhos rápidos: Novo cliente, Nova consulta, Novo pedido

### Menu Lateral (Drawer)
```
[Logo Ótica Yuri]
─────────────────
🏠 Início
👤 Clientes
👁️  Prontuário
📦 Pedidos
🗃️  Estoque
💰 Caixa
📅 Agenda
─────────────────
⚙️  Configurações
ℹ️  Sobre
```

---

## 5. Módulos

### 5.1 Clientes
**Funcionalidades:**
- Cadastro: nome completo, CPF, RG, telefone, WhatsApp, data de nascimento, endereço
- Foto do cliente (câmera ou galeria)
- Busca por nome, CPF ou telefone
- Perfil do cliente com histórico completo: consultas, receitas, pedidos, pagamentos

**Coleção Firestore:** `clientes/{clienteId}`

### 5.2 Prontuário Ótico
**Funcionalidades:**
- Receita por olho (OD e OE): ESF, CIL, EIXO, ADD, DNP (distância pupilar)
- Data da consulta e nome do optometrista responsável
- Campo de observações livres
- Histórico de receitas anteriores (ordenado por data)
- Vinculado ao cadastro do cliente
- Scan/foto da receita em papel (opcional)

**Coleção Firestore:** `clientes/{clienteId}/receitas/{receitaId}`

### 5.3 Pedidos de Óculos
**Funcionalidades:**
- Vinculado ao cliente e à receita
- Dados da armação: marca, modelo, cor, código, valor
- Dados das lentes: tipo, tratamento, laboratório, valor
- Valor total do pedido
- Status do pedido:
  - `Aguardando` → `Em produção` → `Pronto` → `Entregue`
- Data de entrada e data de entrega prevista
- Observações (ex: pedido de urgência, ajustes)
- Notificação quando o pedido ficar pronto

**Coleção Firestore:** `pedidos/{pedidoId}`

### 5.4 Estoque
**Funcionalidades:**
- Cadastro de armações: código, marca, modelo, cor, quantidade, preço de custo, preço de venda
- Cadastro de lentes: tipo, tratamento, quantidade, preço de custo, preço de venda
- Cadastro de acessórios: nome, quantidade, preço
- Alerta visual quando estoque abaixo do mínimo configurado
- Baixa automática no estoque ao fechar um pedido
- Filtros por categoria, marca, disponibilidade

**Coleção Firestore:** `estoque/{itemId}`

### 5.5 Caixa / Financeiro
**Funcionalidades:**
- Registro de venda vinculado ao pedido
- Formas de pagamento: Dinheiro, Cartão de crédito, Cartão de débito, PIX, Parcelamento
- Parcelamento: número de parcelas e valor por parcela
- Controle de entrada (vendas) e saída (despesas) por dia
- Relatório de vendas por período (dia, semana, mês)
- Resumo: total recebido, total a receber (parcelas futuras), total de despesas

**Coleção Firestore:** `financeiro/{transacaoId}`

### 5.6 Agenda
**Funcionalidades:**
- Calendário mensal/semanal/diário
- Agendamento vinculado ao cliente
- Dados do agendamento: data, hora, tipo (consulta, entrega, retorno), observações
- Status: `Agendado` · `Confirmado` · `Realizado` · `Cancelado`
- Notificação de lembrete (push notification via Firebase Messaging)
- Lista do dia na tela inicial

**Coleção Firestore:** `agenda/{agendamentoId}`

---

## 6. Autenticação

- Login com email e senha (Firebase Auth)
- Tela de login com logo da Ótica Yuri
- Uma única conta para os 2 tablets
- Sessão persistente (não precisa logar toda vez)
- Tela de recuperação de senha via email

---

## 7. Configurações

- Nome da ótica (exibido no app)
- Dados da ótica (endereço, telefone, CNPJ)
- Estoque mínimo por categoria (threshold para alertas)
- Versão do app / tela "Sobre"

---

## 8. Estrutura de Dados (Firestore)

```
/clientes/{clienteId}
  nome, cpf, telefone, whatsapp, dataNascimento, endereco, fotoUrl, criadoEm

/clientes/{clienteId}/receitas/{receitaId}
  data, optometrista, od{esf,cil,eixo,add,dnp}, oe{esf,cil,eixo,add,dnp}, observacoes, fotoUrl

/pedidos/{pedidoId}
  clienteId, receitaId, armacao{marca,modelo,cor,codigo,valor},
  lentes{tipo,tratamento,laboratorio,valor}, valorTotal, status,
  dataEntrada, dataEntregaPrevista, observacoes

/estoque/{itemId}
  categoria, marca, modelo, cor, quantidade, quantidadeMinima,
  precoCusto, precoVenda, ativo

/financeiro/{transacaoId}
  tipo (entrada|saida), pedidoId, valor, formaPagamento,
  parcelas, valorParcela, data, descricao

/agenda/{agendamentoId}
  clienteId, data, hora, tipo, status, observacoes
```

---

## 9. Custos de Infraestrutura

| Serviço | Custo |
|---|---|
| Firebase (Firestore + Auth + Storage) | Gratuito (plano Spark — suficiente para uma ótica) |
| Google Play Store (publicação) | $25 USD — taxa única |
| **Total para começar** | **~R$ 130** |

---

## 10. Fora do Escopo (v1)

Os itens abaixo **não entram na primeira versão** para manter o escopo executável:

- Módulo para múltiplas lojas
- Integração com laboratórios óticos externos
- App para cliente final (acompanhar pedido)
- Módulo de nota fiscal / NF-e
- Relatórios avançados com gráficos
- Backup manual / exportação CSV

Podem entrar em versões futuras.
