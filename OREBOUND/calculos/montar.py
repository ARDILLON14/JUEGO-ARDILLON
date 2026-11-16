"""Monta un documento a partir de su plantilla: {{nombre}} = tabla generada, {{=nombre}} = cifra calculada."""
import re
def n(x, d=0): return f"{x:,.{d}f}".replace(",", "X").replace(".", ",").replace("X", ".")
def tabla(cab, filas):
    out = ["| " + " | ".join(cab) + " |", "|" + "---|" * len(cab)]
    return "\n".join(out + ["| " + " | ".join(str(c) for c in f) + " |" for f in filas])
def montar(plantilla, salida, frag, kv=None):
    kv = kv or {}
    t = open(plantilla, encoding="utf-8").read()
    faltan = [m for m in re.findall(r"\{\{=?(\w+)\}\}", t) if m not in frag and m not in kv]
    assert not faltan, f"Sin valor en {plantilla}: {sorted(set(faltan))}"
    t = re.sub(r"\{\{=(\w+)\}\}", lambda m: str(kv[m.group(1)]), t)
    t = re.sub(r"\{\{(\w+)\}\}", lambda m: frag[m.group(1)], t)
    open(salida, "w", encoding="utf-8").write(t)
    print(f"[montado] {salida}: {len(t.splitlines())} lineas")
