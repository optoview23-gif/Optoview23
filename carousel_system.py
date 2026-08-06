"""
OPTOVIEW — SISTEMA DE BUILD DE CARROSSÉIS v2
=============================================
Versão 2.1 | Yuri Optometrista | @optoview23

Como usar:
1. from carousel_system import *
2. assets = load_assets()
3. p = PALETAS["verde_floresta"]
4. slides = [ t3_stat(...), t1_dark(...), cta_dark(...) ]
5. html = html_wrapper(slides, assets, titulo="Meu Carrossel")
6. with open('output.html', 'w') as f: f.write(html)
7. Abra output.html no navegador — visualizador interativo com formato switcher

Dimensões de geração: 1080x1350px (feed 4:5)
Preview interativo: escala CSS para ~390px de largura
Fontes: Barlow Condensed Black (headline, embedded) + system sans-serif (corpo)
"""

import base64, os, glob

# ─── CAMINHOS DOS ASSETS ────────────────────────────────────────────────────
# Tenta scratchpad da sessão, depois /tmp, depois inline vazio (graceful degrade)

def _find_asset(*candidates):
    for p in candidates:
        if p and os.path.exists(p):
            return p
    return None

def _scratchpad_dir():
    """Localiza o scratchpad da sessão atual automaticamente."""
    pattern = '/tmp/claude-0/-home-user-Optoview23/*/scratchpad'
    matches = sorted(glob.glob(pattern), key=os.path.getmtime, reverse=True)
    return matches[0] if matches else None

def load_assets():
    """Carrega fontes e logo. Chame no início de cada build."""
    assets = {}
    sd = _scratchpad_dir()

    # ── Barlow Condensed Black ──────────────────────────────────────────────
    barlow_css_path = _find_asset(
        sd and f'{sd}/barlow_font.css',
        '/tmp/barlow_font.css',
    )
    barlow_ttf_path = _find_asset(
        '/tmp/barlow/BarlowCondensed-Black.ttf',
        '/tmp/BarlowCondensed-Black.ttf',
    )

    if barlow_css_path:
        with open(barlow_css_path, 'r') as f:
            assets['barlow_css'] = f.read().strip()
    elif barlow_ttf_path:
        with open(barlow_ttf_path, 'rb') as f:
            b64 = base64.b64encode(f.read()).decode()
        assets['barlow_css'] = (
            "@font-face {\n"
            "  font-family: 'Barlow Condensed Black';\n"
            f"  src: url(data:font/truetype;base64,{b64}) format('truetype');\n"
            "  font-weight: 900;\n"
            "}"
        )
    else:
        assets['barlow_css'] = ""
        print("[!] Barlow Condensed Black não encontrado — usando fallback")

    # ── Logo Optoview ────────────────────────────────────────────────────────
    logo_path = _find_asset(
        sd and f'{sd}/logo_b64.txt',
        '/tmp/optoview_logo.b64',
        '/tmp/logo_b64.txt',
    )
    if logo_path:
        with open(logo_path, 'r') as f:
            assets['logo_b64'] = f.read().strip()
    else:
        assets['logo_b64'] = ''
        print("[!] Logo não encontrado — imagem vazia")

    # ── Logo Incluse (opcional) ──────────────────────────────────────────────
    incl_path = _find_asset(
        '/tmp/incluse_circle.b64',
        sd and f'{sd}/incluse_circle.b64',
    )
    if incl_path:
        with open(incl_path, 'r') as f:
            assets['incluse_b64'] = f.read().strip()

    return assets


# ─── PALETAS ────────────────────────────────────────────────────────────────
PALETAS = {
    "verde_floresta": {
        "cor": "#52b788", "cor_dark": "#1a4d2e", "cor_mid": "#2d6a4f",
        "grad": "linear-gradient(165deg,#1a4d2e,#2d6a4f,#52b788)",
        "bg_d": "#071a0e", "bg_l": "#f8f9f4", "rgb": "82,183,136",
        "uso": "Clássico Optoview — conteúdo técnico denso (T1, T6)"
    },
    "verde_neon": {
        "cor": "#22c55e", "cor_dark": "#15803d", "cor_mid": "#16a34a",
        "grad": "linear-gradient(165deg,#14532d,#15803d,#22c55e)",
        "bg_d": "#071a0e", "bg_l": "#f0faf3", "rgb": "34,197,94",
        "uso": "Impacto visual alto (T2, T5, T7)"
    },
    "ambar": {
        "cor": "#f59e0b", "cor_dark": "#b45309", "cor_mid": "#d97706",
        "grad": "linear-gradient(165deg,#78350f,#b45309,#f59e0b)",
        "bg_d": "#1c1007", "bg_l": "#fffbeb", "rgb": "245,158,11",
        "uso": "Stat Impact quente (T3)"
    },
    "azul_ceu": {
        "cor": "#38bdf8", "cor_dark": "#0284c7", "cor_mid": "#0ea5e9",
        "grad": "linear-gradient(165deg,#0d4f8f,#0284c7,#38bdf8)",
        "bg_d": "#071828", "bg_l": "#f0f9ff", "rgb": "56,189,248",
        "uso": "Leve, pais (T4)"
    },
    "azul_bebe": {
        "cor": "#7dd3fc", "cor_dark": "#0284c7", "cor_mid": "#38bdf8",
        "grad": "linear-gradient(165deg,#0c4a6e,#0284c7,#7dd3fc)",
        "bg_d": "#071828", "bg_l": "#f0f9ff", "rgb": "125,211,252",
        "uso": "Técnico, optometristas (T8)"
    },
    "roxo": {
        "cor": "#a855f7", "cor_dark": "#7e22ce", "cor_mid": "#9333ea",
        "grad": "linear-gradient(165deg,#3b0764,#7e22ce,#a855f7)",
        "bg_d": "#0f0720", "bg_l": "#faf5ff", "rgb": "168,85,247",
        "uso": "Comparativo mito/verdade (T4)"
    },
    "laranja": {
        "cor": "#fb923c", "cor_dark": "#c2410c", "cor_mid": "#ea580c",
        "grad": "linear-gradient(165deg,#7c2d12,#c2410c,#fb923c)",
        "bg_d": "#0a0a0a", "bg_l": "#fff7ed", "rgb": "251,146,60",
        "uso": "Narrativo emocional (T5)"
    },
    "verde_otica": {
        "cor": "#3a9e3f", "cor_dark": "#166534", "cor_mid": "#16a34a",
        "grad": "linear-gradient(165deg,#14532d,#166534,#3a9e3f)",
        "bg_d": "#071a0e", "bg_l": "#f0faf3", "rgb": "58,158,63",
        "uso": "Ótica Yuri"
    },
}


# ─── FUNÇÕES BASE ─────────────────────────────────────────────────────────────

def make_logo_opto(assets, height=30):
    if not assets.get('logo_b64'):
        return f'<span style="font-family:sans-serif;font-size:{height//2}px;font-weight:700;color:inherit;">⊕ optoview</span>'
    return f'<img src="data:image/png;base64,{assets["logo_b64"]}" style="height:{height}px;width:auto;" />'


def make_logo_incl(assets, height=34):
    if not assets.get('incluse_b64'):
        return ''
    return f'<img src="data:image/png;base64,{assets["incluse_b64"]}" style="height:{height}px;width:auto;border-radius:50%;" />'


def make_logos_juntas(assets, com_incluse=False):
    opto = make_logo_opto(assets)
    if com_incluse and assets.get('incluse_b64'):
        incl = f'<img src="data:image/png;base64,{assets["incluse_b64"]}" style="height:34px;width:auto;border-radius:50%;margin-left:-14px;position:relative;z-index:1;box-shadow:-2px 0 6px rgba(0,0,0,0.40);" />'
        return f'<div style="display:flex;align-items:center;position:relative;"><span style="position:relative;z-index:2;">{opto}</span>{incl}</div>'
    return opto


def acc(p):
    """Accent bar 7px no topo com gradiente da paleta."""
    return f'<div style="position:absolute;top:0;left:0;right:0;height:7px;z-index:30;background:{p["grad"]};"></div>'


def brand(p, assets, dark=True, com_incluse=False, handle_extra=None):
    """Brand bar — logo à esquerda, handle à direita."""
    c = 'rgba(255,255,255,0.38)' if dark else 'rgba(15,13,12,0.35)'
    logos = make_logos_juntas(assets, com_incluse)
    handle_txt = f'@optoview23 / {handle_extra}' if (com_incluse and handle_extra) else '@optoview23 · 2026'
    return (
        f'<div style="position:absolute;top:7px;left:0;right:0;padding:26px 60px 0;'
        f'display:flex;justify-content:space-between;align-items:center;z-index:20;">'
        f'{logos}'
        f'<span style="font-family:\'Plus Jakarta Sans\',system-ui,sans-serif;font-size:12px;'
        f'font-weight:700;letter-spacing:1.5px;text-transform:uppercase;color:{c};">'
        f'{handle_txt}</span></div>'
    )


def prog(idx, total, p, dark=True):
    """Progress bar no rodapé."""
    pct = round((idx + 1) / total * 100)
    track = 'rgba(255,255,255,0.10)' if dark else 'rgba(0,0,0,0.08)'
    fill = f'rgba({p["rgb"]},0.80)' if dark else p["cor"]
    num_c = 'rgba(255,255,255,0.22)' if dark else 'rgba(0,0,0,0.20)'
    return (
        f'<div style="position:absolute;bottom:0;left:0;right:0;padding:0 60px 20px;'
        f'z-index:20;display:flex;align-items:center;gap:14px;">'
        f'<div style="flex:1;height:3px;border-radius:2px;overflow:hidden;background:{track};">'
        f'<div style="height:100%;border-radius:2px;background:{fill};width:{pct}%;"></div></div>'
        f'<span style="font-family:\'Plus Jakarta Sans\',system-ui,sans-serif;font-size:12px;'
        f'font-weight:600;color:{num_c};">{idx+1}/{total}</span></div>'
    )


# ─── HTML WRAPPER — VISUALIZADOR INTERATIVO ──────────────────────────────────

def html_wrapper(slides_list, assets, titulo="Carrossel Optoview"):
    """
    Gera HTML com visualizador interativo:
    - Carousel nav (setas + teclado)
    - Format switcher: Feed 4:5 | Feed 1:1 | Stories
    - CSS scale: slides 1080px → preview ~390px
    - Botão "Ver todos" (stacked, para print)
    - Arquivo auto-contido, sem CDN externo
    """
    barlow_css = assets.get('barlow_css', '')
    slides_html = '\n'.join(slides_list)
    n = len(slides_list)

    # Plus Jakarta Sans — system font stack (CSP-safe; sem CDN)
    jakarta_stack = "'Plus Jakarta Sans', 'Segoe UI', system-ui, -apple-system, sans-serif"

    return f"""<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{titulo}</title>
<style>
{barlow_css}

*, *::before, *::after {{ margin:0; padding:0; box-sizing:border-box; }}

:root {{
  --bg: #0d0d0d;
  --surface: #1a1a1a;
  --border: rgba(255,255,255,0.08);
  --txt: rgba(255,255,255,0.82);
  --txt-dim: rgba(255,255,255,0.38);
  --accent: #52b788;
  --btn-bg: rgba(255,255,255,0.06);
  --btn-hover: rgba(255,255,255,0.12);

  /* Feed 4:5: 1080x1350 → 390x488 (scale = 390/1080 ≈ 0.3611) */
  --scale-feed45: 0.3611;
  --w-feed45: 390px;
  --h-feed45: 488px;

  /* Feed 1:1: 1080x1080 → 390x390 */
  --scale-feed11: 0.3611;
  --w-feed11: 390px;
  --h-feed11: 390px;

  /* Stories 9:16: 1080x1920 → 219x390 (scale = 219/1080 ≈ 0.2028) */
  --scale-story: 0.2028;
  --w-story: 219px;
  --h-story: 390px;
}}

body {{
  background: var(--bg);
  color: var(--txt);
  font-family: {jakarta_stack};
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 32px 16px 64px;
  gap: 24px;
}}

/* ── Header ── */
.header {{
  width: 100%;
  max-width: 600px;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 16px;
}}

.titulo {{
  font-family: 'Barlow Condensed Black', Impact, sans-serif;
  font-size: 22px;
  font-weight: 900;
  text-transform: uppercase;
  letter-spacing: 2px;
  color: var(--txt);
  text-align: center;
}}

/* ── Format switcher ── */
.fmt-bar {{
  display: flex;
  gap: 8px;
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: 10px;
  padding: 4px;
}}

.fmt-btn {{
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 4px;
  padding: 8px 16px;
  border-radius: 7px;
  border: none;
  background: transparent;
  color: var(--txt-dim);
  cursor: pointer;
  transition: all 0.15s;
  font-family: inherit;
}}

.fmt-btn:hover {{ background: var(--btn-hover); color: var(--txt); }}
.fmt-btn.active {{ background: var(--btn-hover); color: var(--accent); }}

.fmt-icon {{
  border: 2px solid currentColor;
  border-radius: 3px;
  opacity: 0.7;
}}

.fmt-btn.active .fmt-icon {{ opacity: 1; }}

.fmt-label {{
  font-size: 10px;
  font-weight: 600;
  letter-spacing: 1px;
  text-transform: uppercase;
}}

/* ── Viewport & slide scaling ── */
.viewer {{
  position: relative;
}}

.slide-viewport {{
  position: relative;
  overflow: hidden;
  border-radius: 12px;
  box-shadow: 0 24px 80px rgba(0,0,0,0.6);
  transition: width 0.25s ease, height 0.25s ease;
}}

/* Default: Feed 4:5 */
.slide-viewport {{
  width: var(--w-feed45);
  height: var(--h-feed45);
}}

.slide-scaler {{
  position: absolute;
  top: 0;
  left: 0;
  transform-origin: top left;
  width: 1080px;      /* slides are generated at 1080px */
  transition: transform 0.25s ease;
}}

/* Feed 4:5 */
body.fmt-feed45 .slide-viewport {{ width: var(--w-feed45); height: var(--h-feed45); }}
body.fmt-feed45 .slide-scaler {{ transform: scale(var(--scale-feed45)); }}
body.fmt-feed45 .slide {{ height: 1350px; }}

/* Feed 1:1 */
body.fmt-feed11 .slide-viewport {{ width: var(--w-feed11); height: var(--h-feed11); }}
body.fmt-feed11 .slide-scaler {{ transform: scale(var(--scale-feed11)); }}
body.fmt-feed11 .slide {{ height: 1080px; }}

/* Stories */
body.fmt-story .slide-viewport {{ width: var(--w-story); height: var(--h-story); }}
body.fmt-story .slide-scaler {{ transform: scale(var(--scale-story)); }}
body.fmt-story .slide {{ height: 1920px; }}

/* Slide visibility */
.slide {{ width:1080px; flex-shrink:0; position:relative; overflow:hidden; display:none; }}
.slide.active {{ display:block; }}

/* ── Navigation ── */
.nav-row {{
  display: flex;
  align-items: center;
  gap: 16px;
  margin-top: 16px;
}}

.nav-btn {{
  width: 44px;
  height: 44px;
  border-radius: 50%;
  border: 1px solid var(--border);
  background: var(--surface);
  color: var(--txt);
  font-size: 18px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.15s;
  font-family: inherit;
}}

.nav-btn:hover:not(:disabled) {{ background: var(--btn-hover); border-color: var(--accent); color: var(--accent); }}
.nav-btn:disabled {{ opacity: 0.25; cursor: not-allowed; }}

.slide-counter {{
  font-size: 13px;
  font-weight: 600;
  color: var(--txt-dim);
  min-width: 60px;
  text-align: center;
  letter-spacing: 1px;
}}

/* ── Dots ── */
.dots {{
  display: flex;
  gap: 6px;
  flex-wrap: wrap;
  justify-content: center;
  max-width: 400px;
}}

.dot {{
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background: var(--border);
  cursor: pointer;
  transition: all 0.15s;
  border: none;
  padding: 0;
}}

.dot.active {{
  background: var(--accent);
  transform: scale(1.4);
}}

/* ── Botão ver todos ── */
.btn-all {{
  margin-top: 8px;
  padding: 10px 24px;
  border-radius: 8px;
  border: 1px solid var(--border);
  background: transparent;
  color: var(--txt-dim);
  font-size: 12px;
  font-weight: 600;
  letter-spacing: 1px;
  text-transform: uppercase;
  cursor: pointer;
  transition: all 0.15s;
  font-family: inherit;
}}

.btn-all:hover {{ background: var(--btn-hover); color: var(--txt); }}

/* ── Print / Ver todos ── */
.all-view {{
  display: none;
  flex-direction: column;
  align-items: center;
  gap: 20px;
  width: 100%;
}}

.all-view.visible {{ display: flex; }}
.all-view .slide {{ display: block; border-radius: 8px; overflow: hidden; }}

@media print {{
  body {{ background: #000; padding: 0; gap: 0; }}
  .header, .viewer, .nav-row, .dots, .btn-all {{ display: none !important; }}
  .all-view {{ display: flex !important; gap: 0; }}
  .all-view .slide-wrap {{ page-break-after: always; }}
}}

/* ── Keyboard hint ── */
.kbd-hint {{
  font-size: 11px;
  color: var(--txt-dim);
  opacity: 0.5;
  text-align: center;
}}
</style>
</head>
<body class="fmt-feed45">

<div class="header">
  <div class="titulo">{titulo}</div>

  <!-- Format switcher -->
  <div class="fmt-bar" role="group" aria-label="Formato">
    <button class="fmt-btn active" data-fmt="feed45" title="Feed 4:5 (1080×1350)">
      <div class="fmt-icon" style="width:18px;height:22px;"></div>
      <span class="fmt-label">4:5</span>
    </button>
    <button class="fmt-btn" data-fmt="feed11" title="Feed 1:1 (1080×1080)">
      <div class="fmt-icon" style="width:20px;height:20px;"></div>
      <span class="fmt-label">1:1</span>
    </button>
    <button class="fmt-btn" data-fmt="story" title="Stories 9:16 (1080×1920)">
      <div class="fmt-icon" style="width:14px;height:24px;border-radius:4px;"></div>
      <span class="fmt-label">9:16</span>
    </button>
  </div>
</div>

<!-- Interactive viewer -->
<div class="viewer">
  <div class="slide-viewport">
    <div class="slide-scaler" id="scaler">
{slides_html}
    </div>
  </div>
</div>

<!-- Navigation -->
<div class="nav-row">
  <button class="nav-btn" id="btn-prev" aria-label="Slide anterior">&#8592;</button>
  <span class="slide-counter" id="counter">1 / {n}</span>
  <button class="nav-btn" id="btn-next" aria-label="Próximo slide">&#8594;</button>
</div>

<!-- Dots -->
<div class="dots" id="dots" role="tablist">
{"".join(f'<button class="dot{"  active" if i == 0 else ""}" data-idx="{i}" aria-label="Slide {i+1}" role="tab"></button>' for i in range(n))}
</div>

<button class="btn-all" id="btn-toggle-all">Ver todos os slides</button>
<div class="kbd-hint">← → para navegar · Esc para voltar ao single</div>

<!-- All slides view (for "ver todos" / print) -->
<div class="all-view" id="all-view">
{"".join(f'<div class="slide-wrap" style="transform:scale(var(--scale-feed45));transform-origin:top center;">{s}</div>' for s in slides_list)}
</div>

<script>
(function() {{
  const slides = Array.from(document.querySelectorAll('#scaler > .slide'));
  const dots = Array.from(document.querySelectorAll('.dot'));
  const counter = document.getElementById('counter');
  const btnPrev = document.getElementById('btn-prev');
  const btnNext = document.getElementById('btn-next');
  const btnToggle = document.getElementById('btn-toggle-all');
  const allView = document.getElementById('all-view');
  let cur = 0;
  let allVisible = false;

  function show(n) {{
    n = Math.max(0, Math.min(slides.length - 1, n));
    slides[cur].classList.remove('active');
    dots[cur].classList.remove('active');
    cur = n;
    slides[cur].classList.add('active');
    dots[cur].classList.add('active');
    counter.textContent = (cur + 1) + ' / ' + slides.length;
    btnPrev.disabled = cur === 0;
    btnNext.disabled = cur === slides.length - 1;
  }}

  // Init
  show(0);

  btnPrev.addEventListener('click', () => show(cur - 1));
  btnNext.addEventListener('click', () => show(cur + 1));

  dots.forEach(d => {{
    d.addEventListener('click', () => show(parseInt(d.dataset.idx)));
  }});

  document.addEventListener('keydown', e => {{
    if (e.key === 'ArrowLeft')  {{ e.preventDefault(); show(cur - 1); }}
    if (e.key === 'ArrowRight') {{ e.preventDefault(); show(cur + 1); }}
    if (e.key === 'Escape' && allVisible) toggleAll();
  }});

  // Format switcher
  const fmtBtns = document.querySelectorAll('.fmt-btn');
  fmtBtns.forEach(b => {{
    b.addEventListener('click', () => {{
      fmtBtns.forEach(x => x.classList.remove('active'));
      b.classList.add('active');
      document.body.className = 'fmt-' + b.dataset.fmt;
    }});
  }});

  // Toggle all
  function toggleAll() {{
    allVisible = !allVisible;
    allView.classList.toggle('visible', allVisible);
    btnToggle.textContent = allVisible ? 'Voltar ao carrossel' : 'Ver todos os slides';
    document.querySelector('.viewer').style.display = allVisible ? 'none' : '';
    document.querySelector('.nav-row').style.display = allVisible ? 'none' : '';
    document.querySelector('.dots').style.display = allVisible ? 'none' : '';
  }}

  btnToggle.addEventListener('click', toggleAll);

  // Touch swipe
  let tx = 0;
  const vp = document.querySelector('.slide-viewport');
  vp.addEventListener('touchstart', e => {{ tx = e.touches[0].clientX; }}, {{passive: true}});
  vp.addEventListener('touchend', e => {{
    const dx = e.changedTouches[0].clientX - tx;
    if (Math.abs(dx) > 40) show(dx < 0 ? cur + 1 : cur - 1);
  }}, {{passive: true}});
}})();
</script>
</body>
</html>"""


# ─── T1 — CLÁSSICO ────────────────────────────────────────────────────────────

def t1_capa(headline, subtitulo, tag, foto_b64, p, assets, idx, total):
    headline_html = headline.replace('\n', '<br>').replace('<em>', f'<em style="color:{p["cor"]};font-style:normal;">')
    logo = make_logo_opto(assets)
    return f'''<div class="slide" style="background:#000;">
{acc(p)}{brand(p, assets, dark=True)}
<img src="data:image/jpeg;base64,{foto_b64}"
  style="position:absolute;inset:0;width:100%;height:100%;object-fit:cover;object-position:center 30%;opacity:0.52;" />
<div style="position:absolute;inset:0;background:linear-gradient(to bottom,transparent 25%,{p["bg_d"]} 62%);"></div>
<div style="position:absolute;bottom:80px;left:60px;right:60px;z-index:5;">
  <div style="display:inline-flex;align-items:center;gap:12px;background:rgba(0,0,0,0.38);border:1.5px solid rgba(255,255,255,0.10);border-radius:60px;padding:10px 24px 10px 12px;margin-bottom:28px;">
    {logo}<span style="font-family:'Plus Jakarta Sans',system-ui,sans-serif;font-size:20px;font-weight:700;color:#fff;margin-left:8px;">@optoview23</span></div>
  <div style="font-family:'Plus Jakarta Sans',system-ui,sans-serif;font-size:11px;font-weight:700;letter-spacing:3px;text-transform:uppercase;color:{p["cor"]};margin-bottom:16px;">{tag}</div>
  <div style="font-family:'Barlow Condensed Black',Impact,sans-serif;font-size:86px;font-weight:900;line-height:0.93;text-transform:uppercase;color:#fff;letter-spacing:-2px;">{headline_html}</div>
  <div style="margin-top:20px;font-family:'Plus Jakarta Sans',system-ui,sans-serif;font-size:24px;font-weight:400;color:rgba(255,255,255,0.42);line-height:1.45;">{subtitulo}</div>
</div>
{prog(idx, total, p, True)}
</div>'''


def t1_dark(titulo, tag, body, p, assets, idx, total):
    titulo_html = titulo.replace('\n', '<br>').replace('<em>', f'<em style="color:{p["cor"]};font-style:normal;">')
    body_html = body.replace('<strong>', '<strong style="color:#fff;font-weight:700;">').replace('<em>', f'<em style="color:{p["cor"]};font-style:normal;">')
    return f'''<div class="slide" style="background:{p["bg_d"]};">
{acc(p)}{brand(p, assets, dark=True)}
<div style="position:absolute;inset:0;background-image:radial-gradient(circle,rgba(255,255,255,0.03) 1px,transparent 1px);background-size:40px 40px;z-index:0;"></div>
<div style="position:absolute;right:-10px;bottom:60px;font-family:'Barlow Condensed Black',Impact,sans-serif;font-size:360px;font-weight:900;color:rgba(255,255,255,0.03);line-height:1;pointer-events:none;z-index:0;">{idx}</div>
<div style="position:absolute;left:4px;top:96px;bottom:60px;width:3px;background:linear-gradient(to bottom,transparent,{p["cor"]} 25%,{p["cor"]} 75%,transparent);opacity:0.25;z-index:2;"></div>
<div style="position:absolute;top:96px;left:60px;right:60px;bottom:60px;display:flex;flex-direction:column;justify-content:flex-end;padding-bottom:32px;padding-left:20px;z-index:5;">
  <div style="font-family:'Plus Jakarta Sans',system-ui,sans-serif;font-size:11px;font-weight:700;letter-spacing:3.5px;text-transform:uppercase;color:{p["cor"]};margin-bottom:24px;">{tag}</div>
  <div style="font-family:'Barlow Condensed Black',Impact,sans-serif;font-size:76px;font-weight:900;line-height:1.0;text-transform:uppercase;color:#fff;letter-spacing:-1px;margin-bottom:36px;">{titulo_html}</div>
  <div style="font-family:'Plus Jakarta Sans',system-ui,sans-serif;font-size:32px;font-weight:400;line-height:1.60;color:rgba(255,255,255,0.55);">{body_html}</div>
</div>
{prog(idx, total, p, True)}
</div>'''


def t1_light(titulo, tag, body, p, assets, idx, total):
    titulo_html = titulo.replace('\n', '<br>').replace('<em>', f'<em style="color:{p["cor"]};font-style:normal;">')
    body_html = body.replace('<strong>', f'<strong style="color:{p["bg_d"]};font-weight:800;">')
    return f'''<div class="slide" style="background:{p["bg_l"]};">
{acc(p)}{brand(p, assets, dark=False)}
<div style="position:absolute;top:96px;left:60px;right:60px;bottom:60px;display:flex;flex-direction:column;justify-content:flex-end;padding-bottom:32px;z-index:5;">
  <div style="font-family:'Plus Jakarta Sans',system-ui,sans-serif;font-size:11px;font-weight:700;letter-spacing:3.5px;text-transform:uppercase;color:{p["cor"]};margin-bottom:24px;">{tag}</div>
  <div style="font-family:'Barlow Condensed Black',Impact,sans-serif;font-size:68px;font-weight:900;line-height:1.0;text-transform:uppercase;color:{p["bg_d"]};letter-spacing:-1px;margin-bottom:32px;">{titulo_html}</div>
  <div style="background:#fff;border-left:6px solid {p["cor"]};border-radius:0 16px 16px 0;padding:36px 44px;">
    <div style="font-family:'Plus Jakarta Sans',system-ui,sans-serif;font-size:32px;font-weight:400;line-height:1.60;color:rgba(15,13,12,0.60);">{body_html}</div>
  </div>
</div>
{prog(idx, total, p, False)}
</div>'''


def t1_cta(titulo, ponte, kword, beneficio, p, assets, idx, total):
    titulo_html = titulo.replace('\n', '<br>').replace('<em>', f'<em style="color:{p["cor"]};font-style:normal;">')
    logo = make_logo_opto(assets)
    return f'''<div class="slide" style="background:{p["bg_l"]};">
{acc(p)}{brand(p, assets, dark=False)}
<div style="position:absolute;top:96px;left:60px;right:60px;bottom:60px;display:flex;flex-direction:column;justify-content:flex-end;padding-bottom:32px;z-index:5;">
  <div style="font-family:'Plus Jakarta Sans',system-ui,sans-serif;font-size:30px;font-weight:500;line-height:1.55;color:rgba(15,13,12,0.55);margin-bottom:40px;">{ponte}</div>
  <div style="font-family:'Barlow Condensed Black',Impact,sans-serif;font-size:68px;font-weight:900;line-height:0.97;text-transform:uppercase;color:{p["bg_d"]};letter-spacing:-1px;margin-bottom:32px;">{titulo_html}</div>
  <div style="background:#fff;border:2px solid rgba({p["rgb"]},0.18);border-radius:18px;padding:32px 40px;margin-bottom:24px;">
    <div style="font-family:'Plus Jakarta Sans',system-ui,sans-serif;font-size:15px;font-weight:500;color:rgba(15,13,12,0.38);margin-bottom:8px;">Compartilha com quem precisa ver</div>
    <div style="font-family:'Barlow Condensed Black',Impact,sans-serif;font-size:68px;font-weight:900;color:{p["cor"]};letter-spacing:-2px;line-height:1;margin-bottom:10px;">{kword}</div>
    <div style="font-family:'Plus Jakarta Sans',system-ui,sans-serif;font-size:18px;color:rgba(15,13,12,0.45);">{beneficio}</div>
  </div>
  <div style="display:flex;align-items:center;gap:12px;">{logo}
    <span style="font-family:'Plus Jakarta Sans',system-ui,sans-serif;font-size:14px;color:rgba(15,13,12,0.28);">Optoview | Optometria Comportamental</span></div>
</div>
{prog(idx, total, p, False)}
</div>'''


# ─── T2 — EDITORIAL ──────────────────────────────────────────────────────────

def t2_capa(pill, label_esq, label_dir, cor_esq, cor_dir, p, assets, idx, total):
    logo = make_logo_opto(assets)
    return f'''<div class="slide" style="background:{p["bg_l"]};">
{acc(p)}
<div style="position:absolute;top:7px;left:0;right:0;padding:28px 60px 0;display:flex;justify-content:center;z-index:20;">{logo}</div>
<div style="position:absolute;top:100px;left:0;right:0;display:flex;flex-direction:column;align-items:center;gap:24px;padding:0 60px;z-index:10;">
  <div style="background:{p["cor"]};border-radius:12px;padding:20px 56px;">
    <span style="font-family:'Barlow Condensed Black',Impact,sans-serif;font-size:54px;font-weight:900;color:#fff;text-transform:uppercase;letter-spacing:-1px;">{pill}</span></div>
  <div style="display:grid;grid-template-columns:1fr 1fr;gap:24px;width:100%;margin-top:8px;">
    <div style="text-align:center;font-family:'Plus Jakarta Sans',system-ui,sans-serif;font-size:40px;font-weight:800;color:{cor_esq};">{label_esq}</div>
    <div style="text-align:center;font-family:'Plus Jakarta Sans',system-ui,sans-serif;font-size:40px;font-weight:800;color:{cor_dir};">{label_dir}</div>
  </div>
</div>
{prog(idx, total, p, False)}
</div>'''


def t2_slide(pill, body, p, assets, idx, total):
    logo = make_logo_opto(assets)
    return f'''<div class="slide" style="background:{p["bg_l"]};">
{acc(p)}
<div style="position:absolute;top:7px;left:0;right:0;padding:28px 60px 0;display:flex;justify-content:center;z-index:20;">{logo}</div>
<div style="position:absolute;top:100px;left:0;right:0;display:flex;flex-direction:column;align-items:center;padding:0 60px;z-index:10;">
  <div style="background:{p["cor"]};border-radius:12px;padding:20px 56px;margin-bottom:52px;">
    <span style="font-family:'Barlow Condensed Black',Impact,sans-serif;font-size:48px;font-weight:900;color:#fff;text-transform:uppercase;letter-spacing:-1px;">{pill}</span></div>
  <div style="font-family:'Plus Jakarta Sans',system-ui,sans-serif;font-size:38px;font-weight:400;line-height:1.60;color:rgba(15,13,12,0.65);text-align:center;max-width:880px;">{body}</div>
</div>
{prog(idx, total, p, False)}
</div>'''


# ─── T3 — STAT IMPACT ────────────────────────────────────────────────────────

def t3_stat(stat, unidade, fonte, tag, body, p, assets, idx, total, dark=True):
    bg = p["bg_d"] if dark else p["bg_l"]
    body_c = 'rgba(255,255,255,0.58)' if dark else 'rgba(15,13,12,0.62)'
    tag_c = p["cor"] if dark else p["cor_dark"]
    card_bg = 'rgba(255,255,255,0.04)' if dark else '#fff'
    uni_c = p["cor_mid"] if dark else p["cor_dark"]
    stat_size = 180 if len(stat) <= 2 else (140 if len(stat) <= 4 else 110)

    return f'''<div class="slide" style="background:{bg};">
{acc(p)}{brand(p, assets, dark=dark)}
<div style="position:absolute;right:-20px;top:60px;font-family:'Barlow Condensed Black',Impact,sans-serif;font-size:480px;font-weight:900;color:rgba({p["rgb"]},0.04);line-height:1;pointer-events:none;z-index:0;">{stat}</div>
<div style="position:absolute;top:96px;left:60px;right:60px;bottom:60px;display:flex;flex-direction:column;justify-content:center;z-index:5;">
  <div style="font-family:'Plus Jakarta Sans',system-ui,sans-serif;font-size:11px;font-weight:700;letter-spacing:3px;text-transform:uppercase;color:{p["cor"]};margin-bottom:18px;">{fonte}</div>
  <div style="display:flex;align-items:flex-end;gap:8px;margin-bottom:14px;">
    <div style="font-family:'Barlow Condensed Black',Impact,sans-serif;font-size:{stat_size}px;font-weight:900;line-height:1;color:{p["cor"]};letter-spacing:-4px;">{stat}</div>
    <div style="font-family:'Barlow Condensed Black',Impact,sans-serif;font-size:72px;font-weight:900;color:{uni_c};padding-bottom:12px;">{unidade}</div>
  </div>
  <div style="height:3px;background:rgba({p["rgb"]},0.30);border-radius:2px;margin-bottom:24px;width:80px;"></div>
  <div style="background:{card_bg};border-left:5px solid {p["cor"]};border-radius:0 16px 16px 0;padding:28px 36px;">
    <div style="font-family:'Plus Jakarta Sans',system-ui,sans-serif;font-size:11px;font-weight:700;letter-spacing:3px;text-transform:uppercase;color:{tag_c};margin-bottom:12px;">{tag}</div>
    <div style="font-family:'Plus Jakarta Sans',system-ui,sans-serif;font-size:28px;font-weight:400;line-height:1.60;color:{body_c};">{body}</div>
  </div>
</div>
{prog(idx, total, p, dark)}
</div>'''


# ─── T4 — COMPARATIVO ────────────────────────────────────────────────────────

def t4_item(titulo, dev, is_esq, p, dark=True):
    if is_esq:
        titulo_c = 'rgba(255,255,255,0.72)' if dark else 'rgba(15,13,12,0.65)'
        dev_c = 'rgba(255,255,255,0.42)' if dark else 'rgba(15,13,12,0.42)'
        sep = 'rgba(255,255,255,0.07)' if dark else 'rgba(0,0,0,0.06)'
    else:
        titulo_c = '#fff' if dark else '#0a1628'
        dev_c = 'rgba(255,255,255,0.60)' if dark else 'rgba(10,22,40,0.58)'
        sep = f'rgba({p["rgb"]},0.15)'

    return f'''<div style="padding:13px 0;border-bottom:1px solid {sep};flex:1;display:flex;flex-direction:column;justify-content:center;">
      <div style="font-family:'Plus Jakarta Sans',system-ui,sans-serif;font-size:21px;font-weight:700;color:{titulo_c};line-height:1.30;margin-bottom:5px;">{titulo}</div>
      <div style="font-family:'Plus Jakarta Sans',system-ui,sans-serif;font-size:18px;font-weight:400;color:{dev_c};line-height:1.52;">{dev}</div>
    </div>'''


def t4_slide(titulo_slide, esq_label, dir_label, esq_items, dir_items, p, assets, idx, total, dark=True):
    bg = p["bg_d"] if dark else p["bg_l"]
    titulo_c = '#fff' if dark else '#0a1628'
    esq_bg = 'rgba(255,255,255,0.04)' if dark else 'rgba(0,0,0,0.03)'
    dir_bg = f'rgba({p["rgb"]},0.08)' if dark else f'rgba({p["rgb"]},0.10)'
    esq_border = 'rgba(255,255,255,0.08)' if dark else 'rgba(0,0,0,0.06)'
    esq_label_c = 'rgba(255,255,255,0.28)' if dark else 'rgba(15,13,12,0.30)'

    esq_html = ''.join(t4_item(t, d, True, p, dark) for t, d in esq_items)
    dir_html = ''.join(t4_item(t, d, False, p, dark) for t, d in dir_items)

    return f'''<div class="slide" style="background:{bg};">
{acc(p)}{brand(p, assets, dark=dark)}
<div style="position:absolute;top:84px;left:40px;right:40px;bottom:54px;display:flex;flex-direction:column;z-index:5;">
  <div style="font-family:'Barlow Condensed Black',Impact,sans-serif;font-size:40px;font-weight:900;text-transform:uppercase;color:{titulo_c};letter-spacing:-0.5px;margin-bottom:10px;text-align:center;flex-shrink:0;">{titulo_slide}</div>
  <div style="display:grid;grid-template-columns:1fr 1fr;gap:10px;flex:1;min-height:0;">
    <div style="background:{esq_bg};border:1.5px solid {esq_border};border-radius:14px;padding:16px 20px;display:flex;flex-direction:column;overflow:hidden;">
      <div style="font-family:'Plus Jakarta Sans',system-ui,sans-serif;font-size:10px;font-weight:700;letter-spacing:2px;text-transform:uppercase;color:{esq_label_c};margin-bottom:8px;padding-bottom:8px;border-bottom:1px solid {esq_border};flex-shrink:0;">{esq_label}</div>
      <div style="flex:1;display:flex;flex-direction:column;justify-content:space-between;">{esq_html}</div>
    </div>
    <div style="background:{dir_bg};border:2px solid rgba({p["rgb"]},0.28);border-radius:14px;padding:16px 20px;display:flex;flex-direction:column;overflow:hidden;">
      <div style="font-family:'Plus Jakarta Sans',system-ui,sans-serif;font-size:10px;font-weight:700;letter-spacing:2px;text-transform:uppercase;color:{p["cor"]};margin-bottom:8px;padding-bottom:8px;border-bottom:1px solid rgba({p["rgb"]},0.18);flex-shrink:0;">{dir_label}</div>
      <div style="flex:1;display:flex;flex-direction:column;justify-content:space-between;">{dir_html}</div>
    </div>
  </div>
</div>
{prog(idx, total, p, dark)}
</div>'''


# ─── T5 — NARRATIVO ──────────────────────────────────────────────────────────

def t5_slide(tag, titulo, body, foto_b64, p, assets, idx, total, foto_pos="center", kword=None):
    titulo_html = titulo.replace('\n', '<br>').replace('<em>', f'<em style="color:{p["cor"]};font-style:normal;">')
    op = min(0.35 + idx * 0.07, 0.70)

    kword_html = ''
    if kword:
        kword_html = (
            f'<div style="margin-top:24px;background:rgba(255,255,255,0.10);border:1.5px solid rgba(255,255,255,0.15);'
            f'border-radius:14px;padding:24px 32px;">'
            f'<div style="font-family:\'Barlow Condensed Black\',Impact,sans-serif;font-size:56px;'
            f'color:{p["cor"]};letter-spacing:-2px;line-height:1;">{kword}</div></div>'
        )

    body_html = (
        f'<div style="font-family:\'Plus Jakarta Sans\',system-ui,sans-serif;font-size:30px;'
        f'font-weight:400;line-height:1.55;color:rgba(255,255,255,0.58);">{body}</div>'
    ) if body else ''

    return f'''<div class="slide" style="background:#000;">
{acc(p)}{brand(p, assets, dark=True)}
<img src="data:image/jpeg;base64,{foto_b64}"
  style="position:absolute;inset:0;width:100%;height:100%;object-fit:cover;object-position:{foto_pos};opacity:{op:.2f};" />
<div style="position:absolute;inset:0;background:linear-gradient(to bottom,rgba(0,0,0,0.15) 0%,rgba(0,0,0,0.05) 20%,rgba(0,0,0,0.65) 55%,rgba(0,0,0,0.95) 80%,#000 100%);"></div>
<div style="position:absolute;bottom:80px;left:60px;right:60px;z-index:10;">
  <div style="font-family:'Plus Jakarta Sans',system-ui,sans-serif;font-size:11px;font-weight:700;letter-spacing:3px;text-transform:uppercase;color:{p["cor"]};margin-bottom:18px;">{tag}</div>
  <div style="font-family:'Barlow Condensed Black',Impact,sans-serif;font-size:82px;font-weight:900;line-height:0.93;text-transform:uppercase;color:#fff;letter-spacing:-2px;margin-bottom:24px;">{titulo_html}</div>
  {body_html}{kword_html}
</div>
{prog(idx, total, p, True)}
</div>'''


# ─── T6 — PASSO A PASSO ──────────────────────────────────────────────────────

def t6_capa(titulo, subtitulo, total_passos, p, assets, idx, total):
    titulo_html = titulo.replace('\n', '<br>').replace('<em>', f'<em style="color:{p["cor"]};font-style:normal;">')
    return f'''<div class="slide" style="background:{p["bg_l"]};">
{acc(p)}{brand(p, assets, dark=False)}
<div style="position:absolute;right:-20px;bottom:60px;font-family:'Barlow Condensed Black',Impact,sans-serif;font-size:480px;font-weight:900;color:rgba(0,0,0,0.04);line-height:1;pointer-events:none;">{total_passos}</div>
<div style="position:absolute;top:96px;left:60px;right:60px;bottom:60px;display:flex;flex-direction:column;justify-content:flex-end;padding-bottom:32px;z-index:5;">
  <div style="display:inline-flex;align-items:center;gap:16px;margin-bottom:32px;">
    <div style="background:{p["grad"]};width:64px;height:64px;border-radius:50%;display:flex;align-items:center;justify-content:center;flex-shrink:0;">
      <span style="font-family:'Plus Jakarta Sans',system-ui,sans-serif;font-size:28px;font-weight:900;color:#fff;">{total_passos}</span></div>
    <span style="font-family:'Plus Jakarta Sans',system-ui,sans-serif;font-size:14px;font-weight:700;letter-spacing:2px;text-transform:uppercase;color:{p["cor"]};">passos · protocolo clínico</span>
  </div>
  <div style="font-family:'Barlow Condensed Black',Impact,sans-serif;font-size:80px;font-weight:900;line-height:0.95;text-transform:uppercase;color:{p["bg_d"]};letter-spacing:-2px;margin-bottom:24px;">{titulo_html}</div>
  <div style="font-family:'Plus Jakarta Sans',system-ui,sans-serif;font-size:26px;font-weight:400;color:rgba(15,13,12,0.45);">{subtitulo}</div>
</div>
{prog(idx, total, p, False)}
</div>'''


def t6_passo(num_passo, total_passos, titulo, body, p, assets, idx, total):
    titulo_html = titulo.replace('\n', '<br>').replace('<em>', f'<em style="color:{p["cor"]};font-style:normal;">')
    return f'''<div class="slide" style="background:{p["bg_l"]};">
{acc(p)}{brand(p, assets, dark=False)}
<div style="position:absolute;right:-20px;bottom:60px;font-family:'Barlow Condensed Black',Impact,sans-serif;font-size:480px;font-weight:900;color:rgba(0,0,0,0.04);line-height:1;pointer-events:none;">{num_passo}</div>
<div style="position:absolute;top:96px;left:60px;right:60px;bottom:60px;display:flex;flex-direction:column;justify-content:flex-end;padding-bottom:32px;z-index:5;">
  <div style="display:inline-flex;align-items:center;gap:20px;margin-bottom:32px;">
    <div style="background:{p["grad"]};width:72px;height:72px;border-radius:50%;display:flex;align-items:center;justify-content:center;flex-shrink:0;box-shadow:0 4px 20px rgba(0,0,0,0.15);">
      <span style="font-family:'Barlow Condensed Black',Impact,sans-serif;font-size:36px;font-weight:900;color:#fff;">{num_passo}</span></div>
    <span style="font-family:'Plus Jakarta Sans',system-ui,sans-serif;font-size:13px;font-weight:700;letter-spacing:2px;text-transform:uppercase;color:{p["cor"]};">Passo {num_passo} de {total_passos}</span>
  </div>
  <div style="font-family:'Barlow Condensed Black',Impact,sans-serif;font-size:76px;font-weight:900;line-height:1.0;text-transform:uppercase;color:{p["bg_d"]};letter-spacing:-1px;margin-bottom:32px;">{titulo_html}</div>
  <div style="background:#fff;border-left:6px solid {p["cor"]};border-radius:0 16px 16px 0;padding:32px 40px;">
    <div style="font-family:'Plus Jakarta Sans',system-ui,sans-serif;font-size:32px;font-weight:400;line-height:1.60;color:rgba(15,13,12,0.58);">{body}</div>
  </div>
</div>
{prog(idx, total, p, False)}
</div>'''


# ─── T7 — REVELAÇÃO ──────────────────────────────────────────────────────────

def t7_capa(pergunta, subtitulo, p, assets, idx, total):
    pergunta_html = pergunta.replace('\n', '<br>')
    return f'''<div class="slide" style="background:{p["bg_d"]};">
{acc(p)}{brand(p, assets, dark=True)}
<div style="position:absolute;top:50%;left:50%;transform:translate(-50%,-55%);z-index:2;">
  <div style="width:560px;height:560px;border-radius:50%;border:2px solid rgba(255,255,255,0.06);display:flex;align-items:center;justify-content:center;">
    <div style="width:380px;height:380px;border-radius:50%;background:radial-gradient(circle,rgba(255,255,255,0.04) 0%,transparent 70%);display:flex;align-items:center;justify-content:center;">
      <div style="font-family:'Barlow Condensed Black',Impact,sans-serif;font-size:150px;color:rgba(255,255,255,0.05);">?</div>
    </div>
  </div>
</div>
<div style="position:absolute;top:96px;left:60px;right:60px;z-index:10;">
  <div style="font-family:'Plus Jakarta Sans',system-ui,sans-serif;font-size:11px;font-weight:700;letter-spacing:3px;text-transform:uppercase;color:{p["cor"]};margin-bottom:24px;">A pergunta que ninguém faz</div>
  <div style="font-family:'Barlow Condensed Black',Impact,sans-serif;font-size:92px;font-weight:900;line-height:0.92;text-transform:uppercase;color:#fff;letter-spacing:-2px;">{pergunta_html}</div>
</div>
<div style="position:absolute;bottom:80px;left:60px;right:60px;z-index:10;">
  <div style="font-family:'Plus Jakarta Sans',system-ui,sans-serif;font-size:26px;font-weight:400;color:rgba(255,255,255,0.38);line-height:1.5;">{subtitulo}</div>
</div>
{prog(idx, total, p, True)}
</div>'''


def t7_revelacao(num, revelacao, body, p, assets, idx, total):
    revelacao_html = revelacao.replace('\n', '<br>')
    return f'''<div class="slide" style="background:{p["bg_d"]};">
{acc(p)}{brand(p, assets, dark=True)}
<div style="position:absolute;right:-10px;bottom:60px;font-family:'Barlow Condensed Black',Impact,sans-serif;font-size:360px;font-weight:900;color:rgba(255,255,255,0.03);line-height:1;pointer-events:none;">{num}</div>
<div style="position:absolute;top:96px;left:60px;right:60px;bottom:60px;display:flex;flex-direction:column;justify-content:center;z-index:5;">
  <div style="font-family:'Plus Jakarta Sans',system-ui,sans-serif;font-size:11px;font-weight:700;letter-spacing:3px;text-transform:uppercase;color:{p["cor"]};margin-bottom:18px;">Revelação {num}</div>
  <div style="font-family:'Barlow Condensed Black',Impact,sans-serif;font-size:96px;font-weight:900;line-height:0.92;text-transform:uppercase;color:{p["cor"]};letter-spacing:-2px;margin-bottom:36px;">{revelacao_html}</div>
  <div style="height:3px;background:rgba(255,255,255,0.08);margin-bottom:36px;"></div>
  <div style="font-family:'Plus Jakarta Sans',system-ui,sans-serif;font-size:32px;font-weight:400;line-height:1.60;color:rgba(255,255,255,0.55);">{body}</div>
</div>
{prog(idx, total, p, True)}
</div>'''


# ─── T8 — LISTA VISUAL ───────────────────────────────────────────────────────

def t8_slide(nomes_curtos, idx_destaque, titulo_dest, body_dest, fonte_dest, tag, p, assets, idx, total, dark=True):
    bg = p["bg_d"] if dark else p["bg_l"]
    items_html = ''

    for j, nome in enumerate(nomes_curtos):
        is_d = (j == idx_destaque)
        nome_c = nome[:48] + '...' if len(nome) > 48 else nome

        if dark:
            bg_item = f'background:rgba({p["rgb"]},0.10);border-left:5px solid {p["cor"]};' if is_d else 'background:rgba(255,255,255,0.03);border-left:5px solid rgba(255,255,255,0.06);'
            nc = p["cor"] if is_d else 'rgba(255,255,255,0.14)'
            tc = '#fff' if is_d else 'rgba(255,255,255,0.28)'
        else:
            bg_item = f'background:rgba({p["rgb"]},0.10);border-left:5px solid {p["cor_mid"]};' if is_d else 'background:rgba(0,0,0,0.03);border-left:5px solid rgba(0,0,0,0.06);'
            nc = p["cor_mid"] if is_d else 'rgba(0,0,0,0.14)'
            tc = p["bg_d"] if is_d else 'rgba(15,13,12,0.28)'

        tw = '600' if is_d else '400'
        items_html += (
            f'<div style="{bg_item}border-radius:0 8px 8px 0;padding:9px 18px;display:flex;align-items:center;gap:14px;">'
            f'<span style="font-family:\'Barlow Condensed Black\',Impact,sans-serif;font-size:24px;font-weight:900;color:{nc};min-width:26px;line-height:1;">{j+1}</span>'
            f'<span style="font-family:\'Plus Jakarta Sans\',system-ui,sans-serif;font-size:17px;font-weight:{tw};color:{tc};line-height:1.20;">{nome_c}</span></div>'
        )

    dest_c = p["cor"] if dark else p["cor_mid"]
    body_c = 'rgba(255,255,255,0.62)' if dark else 'rgba(15,13,12,0.65)'
    fonte_c = 'rgba(255,255,255,0.25)' if dark else 'rgba(15,13,12,0.28)'
    card_bg = f'rgba({p["rgb"]},0.07)' if dark else '#fff'
    tag_c = p["cor"] if dark else p["cor_dark"]
    dot_c = f'rgba({p["rgb"]},0.04)'

    return f'''<div class="slide" style="background:{bg};">
{acc(p)}{brand(p, assets, dark=dark)}
<div style="position:absolute;right:-10px;bottom:50px;font-family:'Barlow Condensed Black',Impact,sans-serif;font-size:320px;font-weight:900;color:{dot_c};line-height:1;pointer-events:none;z-index:0;">{idx_destaque+1}</div>
<div style="position:absolute;top:84px;left:60px;right:60px;bottom:54px;display:flex;flex-direction:column;z-index:5;">
  <div style="font-family:'Plus Jakarta Sans',system-ui,sans-serif;font-size:10px;font-weight:700;letter-spacing:3px;text-transform:uppercase;color:{tag_c};margin-bottom:10px;">{tag}</div>
  <div style="display:flex;flex-direction:column;gap:6px;margin-bottom:12px;flex-shrink:0;">{items_html}</div>
  <div style="background:{card_bg};border-left:5px solid {dest_c};border-radius:0 16px 16px 0;padding:20px 28px;flex:1;display:flex;flex-direction:column;justify-content:space-between;min-height:0;">
    <div>
      <div style="font-family:'Barlow Condensed Black',Impact,sans-serif;font-size:36px;font-weight:900;color:{dest_c};line-height:1.05;letter-spacing:-0.5px;margin-bottom:10px;">{titulo_dest}</div>
      <div style="width:36px;height:2px;background:{dest_c};opacity:0.35;margin-bottom:12px;"></div>
      <div style="font-family:'Plus Jakarta Sans',system-ui,sans-serif;font-size:22px;font-weight:400;line-height:1.58;color:{body_c};">{body_dest}</div>
    </div>
    <div style="font-family:'Plus Jakarta Sans',system-ui,sans-serif;font-size:11px;font-weight:700;letter-spacing:1.5px;text-transform:uppercase;color:{fonte_c};margin-top:10px;">{fonte_dest}</div>
  </div>
</div>
{prog(idx, total, p, dark)}
</div>'''


# ─── CTAs UNIVERSAIS ─────────────────────────────────────────────────────────

def cta_dark(ponte, titulo_cta, kword, beneficio, p, assets, idx, total,
             com_incluse=False, handle_incluse=None):
    titulo_html = titulo_cta.replace('\n', '<br>').replace('<em>', f'<em style="color:{p["cor"]};font-style:normal;">')
    logos = make_logos_juntas(assets, com_incluse)
    footer_handle = f'Em contribuição · @optoview23 · {handle_incluse}' if (com_incluse and handle_incluse) else 'Optoview | Optometria Comportamental'
    kword_label = 'Entre em contato' if com_incluse else 'Compartilha com quem precisa ver'

    return f'''<div class="slide" style="background:{p["bg_d"]};">
{acc(p)}{brand(p, assets, dark=True, com_incluse=com_incluse, handle_extra=handle_incluse)}
<div style="position:absolute;inset:0;background-image:radial-gradient(circle,rgba({p["rgb"]},0.04) 1px,transparent 1px);background-size:40px 40px;z-index:0;"></div>
<div style="position:absolute;top:96px;left:60px;right:60px;bottom:60px;display:flex;flex-direction:column;justify-content:flex-end;padding-bottom:28px;z-index:5;">
  <div style="font-family:'Plus Jakarta Sans',system-ui,sans-serif;font-size:28px;font-weight:500;line-height:1.55;color:rgba(255,255,255,0.50);margin-bottom:32px;">{ponte}</div>
  <div style="font-family:'Barlow Condensed Black',Impact,sans-serif;font-size:64px;font-weight:900;line-height:0.95;text-transform:uppercase;color:#fff;letter-spacing:-1px;margin-bottom:22px;">{titulo_html}</div>
  <div style="background:rgba(255,255,255,0.05);border:1.5px solid rgba({p["rgb"]},0.28);border-radius:14px;padding:24px 36px;margin-bottom:20px;">
    <div style="font-family:'Plus Jakarta Sans',system-ui,sans-serif;font-size:13px;font-weight:500;color:rgba(255,255,255,0.28);margin-bottom:6px;">{kword_label}</div>
    <div style="font-family:'Barlow Condensed Black',Impact,sans-serif;font-size:60px;font-weight:900;color:{p["cor"]};letter-spacing:-2px;line-height:1;margin-bottom:6px;">{kword}</div>
    <div style="font-family:'Plus Jakarta Sans',system-ui,sans-serif;font-size:17px;color:rgba(255,255,255,0.28);">{beneficio}</div>
  </div>
  <div style="display:flex;align-items:center;justify-content:space-between;">
    {logos}
    <span style="font-family:'Plus Jakarta Sans',system-ui,sans-serif;font-size:13px;color:rgba(255,255,255,0.20);">{footer_handle}</span>
  </div>
</div>
{prog(idx, total, p, True)}
</div>'''


def cta_light(ponte, titulo_cta, kword, beneficio, p, assets, idx, total):
    titulo_html = titulo_cta.replace('\n', '<br>').replace('<em>', f'<em style="color:{p["cor"]};font-style:normal;">')
    logo = make_logo_opto(assets)
    return f'''<div class="slide" style="background:{p["bg_l"]};">
{acc(p)}{brand(p, assets, dark=False)}
<div style="position:absolute;top:96px;left:60px;right:60px;bottom:60px;display:flex;flex-direction:column;justify-content:flex-end;padding-bottom:28px;z-index:5;">
  <div style="font-family:'Plus Jakarta Sans',system-ui,sans-serif;font-size:28px;font-weight:500;line-height:1.55;color:rgba(15,13,12,0.55);margin-bottom:36px;">{ponte}</div>
  <div style="font-family:'Barlow Condensed Black',Impact,sans-serif;font-size:68px;font-weight:900;line-height:0.97;text-transform:uppercase;color:{p["bg_d"]};letter-spacing:-1px;margin-bottom:28px;">{titulo_html}</div>
  <div style="background:#fff;border:2px solid rgba({p["rgb"]},0.18);border-radius:18px;padding:32px 40px;margin-bottom:22px;">
    <div style="font-family:'Plus Jakarta Sans',system-ui,sans-serif;font-size:15px;font-weight:500;color:rgba(15,13,12,0.38);margin-bottom:8px;">Compartilha com quem precisa ver</div>
    <div style="font-family:'Barlow Condensed Black',Impact,sans-serif;font-size:64px;font-weight:900;color:{p["cor"]};letter-spacing:-2px;line-height:1;margin-bottom:10px;">{kword}</div>
    <div style="font-family:'Plus Jakarta Sans',system-ui,sans-serif;font-size:18px;color:rgba(15,13,12,0.45);">{beneficio}</div>
  </div>
  <div style="display:flex;align-items:center;gap:12px;">{logo}
    <span style="font-family:'Plus Jakarta Sans',system-ui,sans-serif;font-size:14px;color:rgba(15,13,12,0.28);">Optoview | Optometria Comportamental</span></div>
</div>
{prog(idx, total, p, False)}
</div>'''


# ─── DEMO ────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Optoview Carousel System v2")
    print(f"Paletas: {list(PALETAS.keys())}")
    print("Templates: T1 Clássico · T2 Editorial · T3 Stat · T4 Comparativo")
    print("           T5 Narrativo · T6 Passo a Passo · T7 Revelação · T8 Lista")
    print()

    assets = load_assets()
    p = PALETAS["verde_floresta"]
    total = 5

    slides = [
        t3_stat("81", "%", "20 centros europeus · 2024",
                "Diagnóstico por padrões oculomotores",
                "Em estudo multicêntrico europeu, padrões oculomotores identificaram "
                "disfunções visuais com <strong>81% de precisão</strong> — superando "
                "triagens convencionais.",
                p, assets, 0, total, dark=True),

        t1_dark("VISÃO\nNÃO É SÓ\n<em>ACUIDADE</em>",
                "Optometria Comportamental",
                "A maioria das crianças passa na triagem escolar. "
                "E mesmo assim luta para ler, copiar da lousa ou manter foco. "
                "Por quê? Porque a triagem mede só o que é mais simples.",
                p, assets, 1, total),

        t6_passo(1, 4, "ANAMNESE\nCOMPORTAMENTAL",
                 "Avalie queixas de leitura, cefaleia, diplopia e comportamento escolar. "
                 "Perguntas direcionadas revelam padrões que o exame convencional não capta.",
                 p, assets, 2, total),

        t8_slide(
            ["Convergência insuficiente", "Acomodação em excesso", "Motilidade ocular", "Estrabismo"],
            1,
            "ACOMODAÇÃO EM EXCESSO",
            "Causa astenopia, cefaleia frontal e dificuldade de foco ao mudar distâncias. "
            "Prevalente em escolares em fase de leitura intensa.",
            "Scheiman & Wick · Clinical Management, 5ª ed.",
            "Disfunções mais comuns na clínica",
            p, assets, 3, total, dark=True
        ),

        cta_dark(
            "O dado existe. A conduta muda com o diagnóstico certo.",
            "SALVA ESSE\nPOST PARA\n<em>CONSULTAR</em>",
            "PROCESSAMENTO VISUAL",
            "Conteúdo clínico toda semana",
            p, assets, 4, total
        ),
    ]

    out = '/tmp/carousel_demo.html'
    html = html_wrapper(slides, assets, titulo="Demo — Optometria Comportamental")
    with open(out, 'w') as f:
        f.write(html)
    print(f"Demo gerado: {out}")
