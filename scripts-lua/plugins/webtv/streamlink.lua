-- 30/12/2025 by jokel
-- Version 0.2.0

local json = require "json"

-- Hilfsfunktion: Shell-Befehl ausführen und Ausgabe zurückgeben
local function pop(cmd)
    local f = assert(io.popen(cmd, "r"))
    local s = f:read("*a")
    f:close()
    return s
end

-------------------------------------- Streamlink ------------------------------------------

local url = arg[1]
if not url then
    print("Keine URL übergeben")
    return nil
end

local final_url = url

-- stvp-Links auflösen
if url:match("stvp") then
    local cmd = string.format(
        "curl -kLs -o /dev/null -w %%{url_effective} %q",
        url
    )
    final_url = pop(cmd)
    final_url = final_url:gsub("%s+$", "")
end

-- Wenn nach dem curl nichts übrig ist → abbrechen
if not final_url or final_url == "" then
    return nil
end

-- Streamlink: beste spielbare URL holen
local qualities = "1080p,720p,3300k,2300k,2100k,best"
local cmd = string.format(
    "streamlink %q %s --stream-url",
    final_url,
    qualities
)

local stream_url = pop(cmd)
stream_url = stream_url:gsub("%s+$", "")   -- \n, \r, Leerzeichen entfernen

-- Wenn Streamlink nichts liefert → abbrechen
if not stream_url or stream_url == "" then
    return nil
end

-- JSON-Ausgabe
local entry = { url = stream_url }
return json:encode(entry)

