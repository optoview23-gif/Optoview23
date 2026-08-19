# CLAUDE.md — OptoView23 / FoveaFlow
> Lido automaticamente pelo Claude Code a cada sessão. Trate este arquivo como lei.

---

## 1. Identidade do Projeto

**Nome:** MICALUMA · OPTOVIEW23  
**Tipo:** Aplicativo PWA de terapia visual clínica para optometria comportamental  
**Autor:** Yuri Teixeira Queiroz — optoview23@gmail.com  
**Arquivo principal:** `index.html` (~5 000 linhas) — HTML + CSS + JS inline, zero dependências externas  
**Suporte:** Tablets Android/Chrome e iPad/Safari, orientação paisagem, TV passiva 3D + óculos polarizados  
**Branch de dev:** `claude/visual-therapy-software-prompt-yqge6s`

---

## 2. Stack e Arquitetura

| Aspecto | Detalhe |
|---|---|
| Linguagem | HTML5 + CSS3 + Vanilla JS (ES6+) |
| Renderização | Canvas 2D API (todos os gráficos) |
| Áudio | Web Audio API (metrônomo bilateral) |
| Persistência | `localStorage` — chaves abaixo |
| Build | Nenhum — arquivo único, abrir direto no browser |
| Dependências externas | Zero |
| PWA | `manifest.json` + `sw.js` (cache `optoview-v16`) |

### Chaves de localStorage
| Chave | Conteúdo |
|---|---|
| `optoview_vecto` | Estado do vectógrafo (cores, escala, offset, imagem) |
| `optoview_auth` | `'1'` quando autenticado |
| `tabelaPolarizada_calibration` | Calibração da TV (diagonal, resolução, distância, offsets SBS) |
| `tabelaPolarizada_stereoCal` | Calibração da estereopsia |

### Paleta de cores (CSS vars em `:root`)
```css
--lime: #B5F03C   /* verde-limão — cor primária de ação */
--black: #0A0A0A
--dark:  #181818
--mid:   #2C2C2C
--gray:  #555
--muted: #888
--white: #F0F0F0
```
**Nunca alterar essas variáveis sem pedido explícito.**

---

## 3. Módulos e Funcionalidades

### 3.1 FoveaFlow — Treino de Perseguição Visual (canvas principal)
**Estado global:** objeto `S` (linha ~1526)

| Campo | Tipo | Descrição |
|---|---|---|
| `S.drill` | string | `'smooth'` `'jump'` `'mot'` `'lilac'` |
| `S.path` | string | 21 padrões de trajetória (ver §3.1.1) |
| `S.speedPxSec` | number | velocidade em px/s |
| `S.mode` | string | `'shape'` `'word'` |
| `S.shape` | string | `'circle'` `'square'` `'star'` `'triangle'` `'diamond'` `'cross'` `'ring'` |
| `S.size` | number | tamanho do alvo em px |
| `S.mode3d` | string | `'none'` `'sbs'` `'conv'` `'div'` |
| `S.off3d` | number | offset anaglifo em px |
| `S.distCount` | number | distrações no MOT (3/5/8/12) |
| `S.labelMode` | string | `'none'` `'letter'` `'number'` `'custom'` |

#### 3.1.1 Padrões de Trajetória (21)
`circle` · `ellipse` · `figure8` · `lissajous` · `wave` · `hourglass` · `clover` · `bounce` · `diagonal` · `hsweep` · `vsweep` · `dsweep` · `perimeter` · `diamond` · `zigzag` · `staircase` · `corners` · `rw` (random walk) · `ht` (hard turn) · `teleport` · `mot` (multi-object)

#### 3.1.2 Funções críticas do loop
- `loop(ts)` — game loop principal (linha ~2091); **nunca remover ou duplicar**
- `samplePattern(id, travelPx, radiusPx, rng)` — posição do alvo (linha ~1799)
- `drawStimulus(x, y, alpha)` — renderiza alvo + anaglifo (linha ~2001)
- `drawLilac()` — efeito Lilac Chaser (linha ~2039)
- `getBounds(radiusPx)` — limites de tela com margem (linha ~1575)

#### 3.1.3 RNG Determinístico
Engine seeded (`seededRandom`, `createRng`) — **nunca substituir por `Math.random()` direto** no pattern engine. Sessões repetem se o mesmo seed for usado.

---

### 3.2 Vectógrafo
**Estado global:** objeto `VECTO` (linha ~3842)

| Campo | Padrão | Descrição |
|---|---|---|
| `colorL` | `#FF0000` | Canal olho esquerdo |
| `colorR` | `#00FFFF` | Canal olho direito |
| `scale` | `1.0` | Escala da imagem |
| `offset` | `0` | Offset de disparidade em px (positivo = convergência) |
| `dispMode` | `'conv'` | `'conv'` ou `'div'` |
| `currentImg` | `'vimg-fractal'` | ID do elemento `<img>` no DOM |
| `bgColor` | `#000000` | Fundo da composição |

**Função de renderização:** `drawVectoToCanvas(targetCanvas, targetWidth)` (linha ~3867)  
Usa dois offscreen canvas (oL, oR) e composição por `multiply` / colorização RGBA pixel-a-pixel.  
As imagens ficam em `#vecto-img-store` (elementos `<img>` ocultos no HTML, **não em strings JS**).

---

### 3.3 Integração Bilateral
**Estado global:** objeto `BIL` (linha ~4191)

Modos: `metro` · `alt` · `seq` · `dual`  
Áudio: Web Audio API (`playClick(side)`) — oscilador com frequência diferente para L e R  
Alvos: canvas HTML dentro de `#bil-arena`  
Score: `BIL.scoreL` / `BIL.scoreR` / `BIL.totalHits` / `BIL.missCount`

---

### 3.4 Espelhamento
**Estado global:** objeto `MIR` (linha ~4795)

Modos: `mirror` · `copy`  
Tipos: `dots` · `tangram`  
Grade: 4×4 (padrão), preenchimento aleatório  
`mirrorIndex(idx)` — espelha índice de célula horizontalmente

---

### 3.5 App Bola
Wrapper `#app-bola-wrap` com classe `.show`. Módulo separado na mesma página.

---

### 3.6 Home Screen
`#home-screen` com cards de navegação para cada módulo. Remove-se com classe `.gone`.

---

## 4. Regras de Interface

### Painel de Controle
- Posição: topo da tela, desliza para baixo
- Colapsado: `#panel.collapsed` → `translateY(calc(-100% + 46px))`
- Oculto: `#panel.hidden`
- Long-press (2s) no handle → oculta completamente
- `#reveal-zone` (30px no topo) → toque longo de 2s restaura o painel oculto

### Touch e Gestos
- Double-tap no canvas → play/pause
- Swipe no vectógrafo → ajuste de offset
- Double-tap no vectógrafo → fullscreen expand
- `touch-action: none` em todos os elementos interativos que não devem scroll

### Fullscreen
- `toggleFullscreen()` — botão global `#btn-fs-global`
- `#vecto-fullscreen-layer` — overlay exclusivo do vectógrafo

---

## 5. Regras de Código (OBEDECER SEMPRE)

### 5.1 Antes de qualquer mudança
1. Identificar exatamente qual módulo e quais linhas serão afetados
2. Verificar se a mudança impacta o loop principal (`loop()`)
3. Verificar se a mudança afeta `localStorage` (checar migração de chave)
4. Verificar se a mudança quebra o suporte touch

### 5.2 Proibições absolutas
- ❌ Não adicionar frameworks, bibliotecas ou CDNs
- ❌ Não dividir o arquivo em múltiplos arquivos sem pedido explícito
- ❌ Não usar `Math.random()` dentro do pattern engine (usar `S.rng`)
- ❌ Não alterar CSS vars de cor sem pedido explícito
- ❌ Não adicionar `requestAnimationFrame` paralelos ao loop principal
- ❌ Não usar `innerHTML` para construir HTML com input do usuário (XSS)
- ❌ Não remover `touch-action: none` de elementos interativos
- ❌ Não alterar as chaves de localStorage sem migração explícita
- ❌ Não usar `document.write()`
- ❌ Não fazer push em branch diferente de `claude/visual-therapy-software-prompt-yqge6s`

### 5.3 Obrigações
- ✅ Manter zero dependências externas
- ✅ Testar mentalmente o fluxo touch antes de entregar
- ✅ Preservar suporte a iOS Safari (evitar APIs não suportadas)
- ✅ Manter compatibilidade com Android Chrome
- ✅ Todo elemento interativo novo deve ter `-webkit-tap-highlight-color: transparent`
- ✅ Toda cor nova deve usar as CSS vars existentes (--lime, --dark, etc.)
- ✅ Qualquer novo modal deve ter z-index compatível com a hierarquia existente

### 5.4 Hierarquia de z-index
| Valor | Elemento |
|---|---|
| 9999 | `#btn-fs-global` |
| 600 | `#home-screen` |
| 500 | `#vecto-fullscreen-layer`, `#vimg-modal` |
| 300 | `#app-bola-wrap` |
| 100 | `#word-modal` |
| 30 | `#longpress-bar` |
| 29 | `#reveal-zone` |
| 20 | `#panel` |

---

## 6. Checklist de Qualidade (rodar mentalmente antes de cada entrega)

### Lógica
- [ ] A mudança pode causar loop infinito ou memory leak?
- [ ] O estado (`S`, `VECTO`, `BIL`, `MIR`) foi atualizado corretamente?
- [ ] O `localStorage` foi lido/escrito com try-catch?
- [ ] Eventos foram adicionados com `removeEventListener` correspondente quando necessário?

### Visual
- [ ] A mudança funciona com o painel colapsado E expandido?
- [ ] A mudança funciona em modo fullscreen?
- [ ] Elementos novos respeitam o overflow do container?
- [ ] Textos novos usam unidades relativas (em, rem, vw)?

### Touch
- [ ] Funciona com toque (não apenas mouse)?
- [ ] Não interfere com gestos existentes (swipe, long-press, double-tap)?
- [ ] `touch-action` correto aplicado?

### Canvas
- [ ] O canvas é limpo (`clearRect` ou `fillRect`) antes de redesenhar?
- [ ] Operações de canvas estão dentro do loop correto (não criando novo RAF)?
- [ ] Offscreen canvas são destruídos após uso (não acumulam em memória)?

### Compatibilidade
- [ ] `AudioContext` criado com fallback `webkitAudioContext`?
- [ ] APIs usadas existem no Safari iOS 15+?
- [ ] APIs usadas existem no Chrome Android 90+?

---

## 7. Padrões de Escrita de Código

```js
// Bom — elementById cacheado, arrow function
const el = document.getElementById('meu-id');
el.addEventListener('click', () => { /* ... */ });

// Bom — localStorage com proteção
try {
  localStorage.setItem('chave', JSON.stringify(dado));
} catch(e) {}

// Bom — canvas limpo antes de desenhar
ctx.clearRect(0, 0, canvas.width, canvas.height);

// Ruim — não usar no pattern engine
const x = Math.random() * W;  // ← usar S.rng.rangeAt(i, 0, W)
```

**Nomes:** português ou inglês consistente com o contexto do módulo. Não misturar idiomas no mesmo bloco.  
**Comentários:** apenas quando o "por quê" não é óbvio.  
**Funções:** pequenas, com uma responsabilidade. Se passar de 40 linhas, considerar extração.

---

## 8. Fluxo de Deploy

1. Editar `index.html` (único arquivo de app)
2. Incrementar `CACHE_NAME` em `sw.js` (ex.: `optoview-v16` → `optoview-v17`) se mudar assets cached
3. Commit com mensagem clara em português ou inglês
4. Push para `claude/visual-therapy-software-prompt-yqge6s`
5. GitHub Pages serve direto de `main` — merge via PR quando aprovado

---

## 9. Contexto Clínico (ler antes de implementar qualquer feature visual)

- **Dissociação binocular:** esquerdo/direito são isolados por polarização ou anaglifo — erros de cor ou offset causam diplopia no paciente
- **Disparidade:** offset em pixels deve respeitar a calibração de tela (diagonal + resolução + distância)
- **Latência:** o loop de animação deve manter 60 fps — evitar operações síncronas pesadas dentro de `loop()`
- **Segurança:** nenhum dado clínico é enviado para servidor — tudo fica no `localStorage` do dispositivo
- **Usuários:** optometristas em consultório, usando tablet conectado à TV 3D passiva

---

## 10. Prompt-Padrão para Início de Sessão

Quando abrir uma nova sessão para trabalhar neste projeto, cole o seguinte:

```
Você está trabalhando no OptoView23 / FoveaFlow, um PWA de terapia visual clínica.
Arquivo principal: index.html (~5000 linhas, HTML+CSS+JS inline, zero dependências).
Leia o CLAUDE.md antes de qualquer ação.
Branch de trabalho: claude/visual-therapy-software-prompt-yqge6s

TAREFA: [descreva aqui o que precisa]

Exigências:
- Zero bugs introduzidos
- Zero dependências externas adicionadas
- Testar mentalmente cada fluxo touch antes de entregar
- Rodar o checklist de qualidade do CLAUDE.md antes de responder
- Commits em português com mensagem descritiva
```
