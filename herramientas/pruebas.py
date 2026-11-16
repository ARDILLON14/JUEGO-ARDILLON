#!/usr/bin/env python3
"""Ejecuta tests/*.spec.luau fuera de Roblox.   Uso:  python3 herramientas/pruebas.py [filtro]

Necesita `pip install lupa`. Usa Lua 5.1 (la base de Luau) con un entorno mínimo que imita lo que el
código usa de Roblox: `script`, `game:GetService`, `require` por instancia, `typeof` y las funciones de
Luau que Lua 5.1 no trae (math.clamp, math.round, table.find, table.clone, table.freeze...).

Por eso el código que se prueba aquí (Shared/Config, Shared/Formulas, Shared/Net, Server/Net, Server/Datos)
está escrito en el subconjunto común de Lua 5.1 y Luau: sin anotaciones de tipo, sin `+=` y sin `continue`.
Lo que depende del motor (servicios con DataStoreService, Players, RemoteEvent) no se ejecuta aquí."""
import glob, os, sys
from lupa import lua51

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PRELUDIO = r"""
local leer, existe = ...
math.clamp = function(x, a, b) if x < a then return a elseif x > b then return b end return x end
math.round = function(x) return math.floor(x + 0.5) end
math.sign = function(x) if x > 0 then return 1 elseif x < 0 then return -1 end return 0 end
table.find = function(t, v) for i, x in ipairs(t) do if x == v then return i end end return nil end
table.clone = function(t) local c = {} for k, v in pairs(t) do c[k] = v end return c end
table.freeze = function(t) return t end
table.create = function() return {} end
table.unpack = unpack
table.pack = function(...) return { n = select("#", ...), ... } end
string.split = function(s, sep)
	local out, pos = {}, 1
	while true do
		local a, b = string.find(s, sep, pos, true)
		if not a then table.insert(out, string.sub(s, pos)) break end
		table.insert(out, string.sub(s, pos, a - 1)); pos = b + 1
	end
	return out
end
typeof = function(v)
	if type(v) == "table" and rawget(v, "__typeof") then return rawget(v, "__typeof") end
	return type(v)
end
warn = function(...) end

local RAICES = {
	ReplicatedStorage = { Shared = "src/shared" },
	ServerScriptService = { Server = "src/server", Tests = "tests" },
}
local nodoMeta = {}
local function nodo(ruta) return setmetatable({ __ruta = ruta }, nodoMeta) end
nodoMeta.__index = function(self, clave)
	local ruta = rawget(self, "__ruta")
	if clave == "Parent" then return nodo((string.gsub(ruta, "/[^/]+$", ""))) end
	if clave == "Name" then return string.match(ruta, "[^/]+$") end
	return nodo(ruta .. "/" .. clave)
end
game = { JobId = "prueba-local", PlaceId = 0 }
function game:GetService(nombre)
	local hijos = RAICES[nombre]
	if not hijos then error("servicio no disponible fuera de Roblox: " .. tostring(nombre)) end
	local s = {}
	for k, ruta in pairs(hijos) do s[k] = nodo(ruta) end
	return s
end

local cargados = {}
function require(n)
	local ruta = rawget(n, "__ruta")
	if cargados[ruta] ~= nil then return cargados[ruta] end
	local archivo = ruta .. ".luau"
	if not existe(archivo) then archivo = ruta .. "/init.luau" end
	if not existe(archivo) then error("módulo no encontrado: " .. ruta, 2) end
	local trozo, err = loadstring(leer(archivo), "@" .. archivo)
	if not trozo then error(err, 0) end
	setfenv(trozo, setmetatable({ script = nodo(ruta) }, { __index = _G }))
	local valor = trozo()
	cargados[ruta] = valor
	return valor
end
"""

def main():
    filtro = sys.argv[1] if len(sys.argv) > 1 else ""
    lua = lua51.LuaRuntime(unpack_returned_tuples=True)
    leer = lambda ruta: open(os.path.join(RAIZ, ruta), encoding="utf-8").read()
    existe = lambda ruta: os.path.isfile(os.path.join(RAIZ, ruta))
    lua.execute(PRELUDIO, leer, existe)
    nombres = sorted(os.path.basename(p)[:-5] for p in glob.glob(os.path.join(RAIZ, "tests", "*.spec.luau")) if filtro in p)
    correr = lua.eval("""function(nombres)
        local tests = game:GetService("ServerScriptService").Tests
        local specs = {}
        for _, nombre in ipairs(nombres) do
            local ok, valor = pcall(require, tests[nombre])
            if ok then table.insert(specs, { Name = nombre, Run = valor })
            else table.insert(specs, { Name = nombre, Run = function() error(valor, 0) end }) end
        end
        local r = require(tests.Ejecutor).run(specs, print)
        return r.Failed
    end""")
    fallidas = correr(lua.table_from(nombres))
    sys.exit(1 if fallidas else 0)

if __name__ == "__main__":
    main()
