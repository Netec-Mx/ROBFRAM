-- Pandoc Lua filter: al exportar a typst (PDF), elimina los bloques de
-- código ```mermaid``` — quedan solo para quien lea el .md directamente
-- (GitHub, VS Code, etc.). El PDF usa el diagrama nativo Typst que va
-- justo después (bloque {=typst}).
function CodeBlock(block)
  if FORMAT == "typst" then
    for _, class in ipairs(block.classes) do
      if class == "mermaid" then
        return {}
      end
    end
  end
  return block
end
