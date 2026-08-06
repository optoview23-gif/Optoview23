"""
Gera PDF: Ambliopia — Abordagem Comportamental
Público: Optometristas não familiarizados com optometria comportamental
Referência: Leonard J. Press — Optometric Management of Learning Dysfunction (2008)
"""
import sys
sys.path.insert(0, '/home/user/Optoview23')
from carousel_system import *

assets = load_assets()
p = PALETAS["verde_floresta"]
total = 12

slides = []

# ─── SLIDE 1 — CAPA (T7 estilo: pergunta provocadora) ───────────────────────
slides.append(t7_capa(
    pergunta="SEU PACIENTE\nAMBLÍOPE\nESTÁ SENDO\nBEM AVALIADO?",
    subtitulo=(
        "A abordagem comportamental enxerga uma síndrome visual completa "
        "onde a triagem convencional vê apenas uma linha de acuidade."
    ),
    p=p, assets=assets, idx=0, total=total
))

# ─── SLIDE 2 — STAT IMPACTO ──────────────────────────────────────────────────
slides.append(t3_stat(
    stat="2–3", unidade="%",
    fonte="Prevalência populacional · Press, Optometric Management, 2008",
    tag="Um em cada 40 pacientes que passam pelo seu consultório",
    body=(
        "A maioria passa na triagem escolar de AV. O problema é que "
        "<strong>ambliopia não é só acuidade reduzida</strong> — "
        "é uma síndrome que envolve processamento visual ativo, binocularidade "
        "e plasticidade cortical. Tratar apenas a linha é tratar só a superfície."
    ),
    p=p, assets=assets, idx=1, total=total, dark=True
))

# ─── SLIDE 3 — COMPARATIVO: Tradicional vs Comportamental ───────────────────
slides.append(t4_slide(
    titulo_slide="AMBLIOPIA: DUAS ABORDAGENS",
    esq_label="Modelo Tradicional",
    dir_label="Optometria Comportamental",
    esq_items=[
        ("Acuidade visual",
         "Único parâmetro de progresso e alta clínica."),
        ("Oclusão passiva",
         "Tratamento padrão. Compliance é o maior desafio."),
        ("Limite de 9 anos",
         "Sem indicação após o período crítico. Célula morta = sem retorno."),
        ("Olho isolado",
         "Foco monocular: olho amblíope tratado sem integração binocular."),
    ],
    dir_items=[
        ("Síndrome visual",
         "AV + contraste + crowding + supressão + binocularidade + acomodação."),
        ("Terapia ativa",
         "VT binocular, feedback, engajamento. Paciente é agente do processo."),
        ("Neuroplasticidade",
         "Press documenta melhora clínica em adolescentes e adultos. Período crítico é ponto de partida, não fim."),
        ("Integração binocular",
         "Objetivo final: usar os dois olhos juntos com eficiência real."),
    ],
    p=p, assets=assets, idx=2, total=total, dark=True
))

# ─── SLIDE 4 — REVELAÇÃO: Além do período crítico ───────────────────────────
slides.append(t7_revelacao(
    num="01",
    revelacao="PERÍODO\nCRÍTICO NÃO\nÉ SENTENÇA",
    body=(
        "Press (2008) documenta casos de melhora em pacientes acima de 9 anos. "
        "Quando o olho dominante adquire doença após essa idade, o amblíope "
        "melhora espontaneamente — prova de que a plasticidade persiste. "
        "Terapia ativa e direcionada explora esse potencial residual."
    ),
    p=p, assets=assets, idx=3, total=total
))

# ─── SLIDE 5 — REVELAÇÃO: Além da acuidade ───────────────────────────────────
slides.append(t7_revelacao(
    num="02",
    revelacao="AV 20/20\nNÃO É\nCURA",
    body=(
        "Mesmo após recuperar AV com oclusão, o paciente pode manter "
        "supressão ativa, estereopsia reduzida, sensibilidade ao contraste "
        "comprometida e acomodação disfuncional no olho ex-amblíope. "
        "Sem alta binocular, o resultado é parcial."
    ),
    p=p, assets=assets, idx=4, total=total
))

# ─── SLIDE 6 — CAPA DO PROTOCOLO ─────────────────────────────────────────────
slides.append(t6_capa(
    titulo="AVALIAÇÃO\nCOMPOR-\nTAMENTAL\nEM AMBLIOPIA",
    subtitulo=(
        "4 passos para um diagnóstico além da acuidade — "
        "aplicável no exame de rotina."
    ),
    total_passos=4,
    p=p, assets=assets, idx=5, total=total
))

# ─── SLIDE 7 — PASSO 1: Anamnese ─────────────────────────────────────────────
slides.append(t6_passo(
    num_passo=1, total_passos=4,
    titulo="ANAMNESE\nDIRIGIDA",
    body=(
        "Pergunte além da AV: cefaleia após leitura, sensação de cansaço "
        "monocular, dificuldade de copiar da lousa, confusão de letras. "
        "Investigue história de oclusão anterior — compliance, duração, "
        "resposta. Queixas que o paciente não associa à visão revelam "
        "o peso comportamental do caso."
    ),
    p=p, assets=assets, idx=6, total=total
))

# ─── SLIDE 8 — PASSO 2: Fixação e motilidade ─────────────────────────────────
slides.append(t6_passo(
    num_passo=2, total_passos=4,
    titulo="FIXAÇÃO E\nMOTILIDADE",
    body=(
        "Avalie fixação direta com visuoscopia (ou oftalmoscópio direto): "
        "fixação central estável, excêntrica ou instável? "
        "Observe motilidade ocular em ambos os olhos — nistagmo latente "
        "pode aparecer só ao ocluir o olho dominante. "
        "Fixação excêntrica muda o planejamento terapêutico inteiramente."
    ),
    p=p, assets=assets, idx=7, total=total
))

# ─── SLIDE 9 — PASSO 3: Binocularidade e supressão ──────────────────────────
slides.append(t6_passo(
    num_passo=3, total_passos=4,
    titulo="BINOCU-\nLARIDADE E\nSUPRESSÃO",
    body=(
        "Worth 4 luzes (perto e longe), estereopsia quantitativa "
        "(Randot, Titmus ou TNO) e avaliação de supressão no sinoptoforo. "
        "Ambliopia sem avaliação binocular é diagnóstico incompleto. "
        "O grau de supressão define a profundidade da disfunção "
        "e a complexidade do protocolo de VT."
    ),
    p=p, assets=assets, idx=8, total=total
))

# ─── SLIDE 10 — PASSO 4: Acomodação ──────────────────────────────────────────
slides.append(t6_passo(
    num_passo=4, total_passos=4,
    titulo="AVALIAÇÃO\nACOMO-\nDATIVA",
    body=(
        "Amplitude e flexibilidade acomodativa no olho amblíope "
        "frequentemente estão reduzidas mesmo após melhora de AV. "
        "Retinoscopia dinâmica (MEM) e flipper monocular (±2.00 D) "
        "revelam lag e inflexibilidade que comprometem leitura e "
        "resposta ao tratamento. Trate a acomodação junto com a AV."
    ),
    p=p, assets=assets, idx=9, total=total
))

# ─── SLIDE 11 — LISTA VISUAL: Sinais de alerta ───────────────────────────────
slides.append(t8_slide(
    nomes_curtos=[
        "Fixação excêntrica ou instável",
        "Supressão persistente ao Worth",
        "Estereopsia ausente ou muito reduzida",
        "Acomodação disfuncional monocular",
        "Crowding positivo (AV pior em contexto)",
        "AV instável entre medidas",
    ],
    idx_destaque=0,
    titulo_dest="FIXAÇÃO EXCÊNTRICA",
    body_dest=(
        "É o sinal mais crítico: indica que o olho amblíope "
        "desenvolveu um locus de fixação preferencial fora da fóvea. "
        "A oclusão simples não resolve — é preciso VT ativa para "
        "retreinar a fixação central antes de qualquer ganho de AV "
        "ser sustentável a longo prazo."
    ),
    fonte_dest="Press · Optometric Management of Amblyopia · Cap. 7 e 15",
    tag="Achados que mudam o plano de tratamento",
    p=p, assets=assets, idx=10, total=total, dark=True
))

# ─── SLIDE 12 — CTA ──────────────────────────────────────────────────────────
slides.append(cta_dark(
    ponte=(
        "Ambliopia tratada só com oclusão passiva deixa ganhos funcionais "
        "na mesa — e retornos ao consultório na agenda."
    ),
    titulo_cta="AVALIE\nALÉM DO\n<em>20/20</em>",
    kword="OPTOMETRIA COMPORTAMENTAL",
    beneficio="Diagnóstico completo · Terapia ativa · Resultados duradouros",
    p=p, assets=assets, idx=11, total=total
))

# ─── GERAR HTML ──────────────────────────────────────────────────────────────
SCRATCHPAD = '/tmp/claude-0/-home-user-Optoview23/92813e28-90c1-5df0-b131-85ba0c9812d3/scratchpad'
out = f'{SCRATCHPAD}/pdf-ambliopia.html'

html = html_wrapper(slides, assets, titulo="Ambliopia — Abordagem Comportamental")
with open(out, 'w') as f:
    f.write(html)

print(f"Gerado: {out}")
print(f"Slides: {total}")
print(f"Tamanho: {len(html) // 1024} KB")
