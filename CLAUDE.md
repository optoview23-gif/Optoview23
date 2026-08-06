# OPTOVIEW23 — Projeto de Conteúdo Clínico
**Dr. Yuri | Optometria Comportamental | @optoview23 | SP/RJ**

---

## Quem sou eu

Sou optometrista especializado em **Optometria Comportamental** — a abordagem que entende a visão como comportamento aprendido, não apenas como óptica. Atendo em SP e RJ, com foco em:

- Disfunções visuais em crianças e adultos (convergência, acomodação, binocularidade)
- Ambliopia e estrabismo com abordagem funcional e ativa
- Aprendizagem e desempenho escolar ligados à visão
- Terapia visual (VT) comportamental
- Miopia — controle e progressão

Meu perfil público é `@optoview23` no Instagram. Produzo conteúdo para **dois públicos distintos**: profissionais de saúde (optometristas, oftalmologistas, pedagogos) e leigos (pais, pacientes, educadores).

---

## Referência principal

**Leonard J. Press — *Optometric Management of Learning Dysfunction* (2008)**

O arquivo com o conteúdo extraído do livro está em:
`vision_therapy_full.txt` (no scratchpad da sessão)

Sempre que escrever sobre temas clínicos, busque referências nesse arquivo antes de escrever. Cite como: *Press, 2008* ou *Press, Optometric Management, Cap. X*.

Outras referências válidas:
- Scheiman & Wick — *Clinical Management of Binocular Vision* (5ª ed.)
- Skeffington — fundamentos da optometria comportamental
- OEP (Optometric Extension Program) — publicações clínicas

---

## Nomenclatura obrigatória (PT-BR)

| ❌ Nunca usar | ✅ Usar sempre |
|---|---|
| Optometria Funcional | **Optometria Comportamental** |
| CBVT / HBVT | **TVC / TVD** (Treino de Vergência Convergente/Divergente) |
| Pencil Push-Up | **Aproximação com Lápis** |
| Lazy eye | **Ambliopia** |
| Crossed eyes | **Estrabismo convergente / Esotropia** |
| VT | **Terapia Visual** (escrever por extenso na primeira ocorrência) |
| PPC | **PPC** (manter sigla, mas explicar: Ponto Próximo de Convergência) |

---

## Como escrever — Minha Voz

### Para profissionais de saúde (optometristas, médicos)
- Linguagem técnica com vocabulário da área
- Dados e referências científicas com fonte explícita
- Tom de **colega experiente num café** — direto, sem didatismo excessivo
- Questionar o paradigma convencional com evidência, não com opinião
- Exemplo de abertura: *"Press (2008) documenta casos de melhora em pacientes acima de 9 anos — o que coloca em xeque a rigidez do período crítico como limite terapêutico."*

### Para leigos (pais, pacientes, público geral)
- Sem jargão técnico na abertura — entrar pelo problema do dia a dia
- Validar o que os pais já percebem: *"seu filho reclama que a cabeça dói depois de ler — isso não é frescura"*
- Analogias simples e concretas
- Dados científicos como âncora, não como argumento principal
- Tom acolhedor, empático, sem ser condescendente
- Exemplo de abertura: *"Seu filho passou na triagem da escola. A visão está 'normal'. Mas ele continua tendo dificuldade para ler. Por quê?"*

### Regras de estilo sempre aplicáveis
1. **Dado primeiro** — abra com um número, uma pesquisa ou um fato clínico concreto
2. **Contexto depois** — explique o que aquele dado significa na prática
3. **Ponte para ação** — termine com o que o leitor pode fazer, perguntar ou buscar
4. **Uma ideia por parágrafo** — textos densos para Instagram ou PDF perdem o leitor
5. **Verbos no ativo** — *"o optometrista avalia"*, não *"é avaliado pelo optometrista"*
6. **Sem hedging excessivo** — não usar *"talvez", "pode ser que", "em alguns casos"* quando há evidência clara

---

## Formatos de conteúdo disponíveis

### Carrosséis / PDFs (Instagram + impressão)
Script principal: `carousel_system.py`
Gerador de exemplo: `gera_pdf_ambliopia.py`

**Templates disponíveis:**
| Código | Nome | Melhor para |
|---|---|---|
| T1 | Clássico | Conteúdo técnico denso para profissionais |
| T2 | Editorial | Comparações visuais, público geral |
| T3 | Stat Impact | Quando um dado é o coração do slide |
| T4 | Comparativo | Mito vs verdade, antes vs depois |
| T5 | Narrativo | Histórias emocionais com foto |
| T6 | Passo a Passo | Protocolos clínicos |
| T7 | Revelação | Tensão progressiva, swipe forçado |
| T8 | Lista Visual | Alta taxa de save |

**Paletas disponíveis:** `verde_floresta`, `verde_neon`, `ambar`, `azul_ceu`, `azul_bebe`, `roxo`, `laranja`, `verde_otica`

Para gerar um PDF: rodar o script Python correspondente → abrir HTML → "Ver todos" → Ctrl+P

### Roteiro de post (texto + carrossel)
Estrutura recomendada:
1. **Gancho** (1 frase — stat ou pergunta)
2. **Desenvolvimento** (2–3 slides de conteúdo)
3. **Virada** (o que a optometria comportamental oferece)
4. **CTA** (salvar, compartilhar, marcar colega)

---

## Tópicos que já trabalhei

- [x] Ambliopia — abordagem comportamental (`gera_pdf_ambliopia.py`)
- [x] Estrabismo — carrossel T3 Forest Canopy (`carousel-t03-estrabismo.html`)
- [ ] Convergência Insuficiente
- [ ] Acomodação — disfunções e diagnóstico
- [ ] Visão e aprendizagem escolar
- [ ] Miopia — controle comportamental
- [ ] Terapia Visual — o que é e como funciona
- [ ] Triagem escolar — limitações e o que ela não detecta

---

## Workflow para criar novo conteúdo

1. Me diz o **tema** e o **público-alvo**
2. Eu busco referências no arquivo do Press (`vision_therapy_full.txt`)
3. Proponho estrutura (slides + textos) para aprovação
4. Gero o script Python e o HTML interativo
5. Você visualiza, pede ajustes, e exporta como PDF ou salva

---

## Arquivos do projeto

```
Optoview23/
├── CLAUDE.md                    ← este arquivo (lido automaticamente)
├── carousel_system.py           ← sistema de build de carrosséis
├── template_selector.html       ← guia visual dos 8 templates
├── gera_pdf_ambliopia.py        ← PDF: ambliopia comportamental
├── escrita/
│   ├── estilo.md                ← guia de estilo detalhado
│   ├── glossario.md             ← glossário PT-BR da optometria comportamental
│   └── temas.md                 ← banco de temas e ângulos por público
└── index.html                   ← site do projeto
```
