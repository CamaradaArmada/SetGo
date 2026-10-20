local _, ns = ...

local L = {
	ADDON = "SetGo!",
	OPEN = "Open SetGo!",

	-- book
	HOME = "Quick settings",
	HOME_SHORT = "Home",
	HOME_DESC = "Back to the first page. Changes not applied yet stay pending.",
	CONTENTS = "Contents",
	PENDING = "%d changes not applied yet.",
	NO_PENDING = "No changes yet.",
	DEFAULTS_BUTTON = "Defaults",
	DEFAULTS_BUTTON_DESC = "Put this page, or every page, back to Blizzard's defaults. Nothing changes until you apply.",
	RESET_PAGE = "Reset this page",
	RESET_ALL = "Reset all pages",
	APPLY_NOTE = "Applies every change waiting on any page and reloads the interface.",
	NO_CHANGES = "Nothing to apply yet.",

	-- landing
	MODULES = "Modules",

	-- paths
	DELETE = "Delete",
	SAVE = "Save",
	EXPORT = "Export",
	POPUP_DISCARD = "Discard %d changes that were not applied?",
	PAGE_LAYOUT = "Layout",
	SEC_EDITMODE = "Edit Mode",
	EDITMODE_LAYOUT = "Edit Mode layout",
	EDITMODE_LAYOUT_DESC = "The layout this character uses. Layouts are created in Edit Mode.",
	NAMEPLATES_ADVANCED = "Advanced Nameplate Options",
	NAMEPLATES_ADVANCED_DESC = "Opens Blizzard's Nameplates menu for sizes, auras, cast bars and colors. Changes made there apply at once.",
	POPUP_BLIZZARD = "This opens Blizzard's Nameplates menu and closes SetGo! for now.\n\nYour changes here are kept, not applied yet. SetGo! opens again on this page when you close Blizzard's menu.",

	-- modules
	MOD_FETCH = "Fetch!",
	MOD_FETCH_DESC = "A bar of up to 12 buttons, each with a six slot flyout for spells, items and macros. It can sit right on top of the bag bar.",
	MOD_LOOK = "Look!",
	MOD_LOOK_DESC = "A key turns the mouse into camera control, with a dot in the middle of the screen and soft targeting, like an action game.",
	MOD_SPEAK = "Speak!",
	MOD_SPEAK_DESC = "A cleaner chat in the style of the new interface, soft or with tooltip borders: Blizzard fonts, fading tabs and one settings button.",
	MOD_HIDE = "Hide!",
	MOD_HIDE_DESC = "Hides Blizzard frames like a macro: always, or only when (or except when) you are in combat, mounted, holding a key and more.",
	MODULE_NO_PROFILE = "This module has no profile options.",
	NO_MODULES = "No modules installed. They come as separate folders (SetGo_Fetch, SetGo_Look, SetGo_Speak, SetGo_Hide) in the AddOns folder.",
	POPUP_RELOAD_MODULES = "Reload the interface now to switch the module on or off?",

	-- keybind profiles
	MSG_KEYS_SKIPPED = "%d key bindings skipped: their addons are not installed.",

	-- key binding rows
	NOT_BOUND = "Not bound",
	PRESS_KEY = "Press a key",

	-- messages
	MSG_COMBAT = "Settings can't be changed in combat.",
	MSG_APPLIED = "%d settings changed.",
	MSG_FAILED = "%d settings could not be changed.",
	MSG_NOT_READY = "The game's settings are still loading. Try again in a moment.",

	-- tabs and our own pages
	TAB_MODULES = "Modules",
	TAB_SETTINGS = "SetGo!",
	DISCARD = "Discard",
	DISCARD_DESC = "Forgets every change not applied yet.",
	SETGO_TITLE = "SetGo! settings",
	SETGO_TAB = "Opening tab",
	SETGO_TAB_DESC = "The tab listed on the first page when SetGo! opens.",
	SETGO_MINIMAP = "Minimap button",
	SETGO_MINIMAP_DESC = "Shows the SetGo! button on the minimap. The addon menu by the minimap always has it.",

	-- profile slots
	RENAME = "Rename",
	POPUP_RENAME = "New name for \"%s\":",
	CONTENTS_DESC = "Click to jump to another page.",
	APPLY = "Apply changes",

	-- SetGo! settings
	SETGO_MUTE = "Mute SetGo! sounds",
	SETGO_MUTE_DESC = "No book, page or checkbox sounds from SetGo!.",
	SETGO_GENERAL = "General",
	SETGO_HELP = "Help",
	SETGO_GITHUB = "GitHub",
	SETGO_GITHUB_DESC = "SetGo!'s page on GitHub: what changed in each version, and where to report a problem.",
	POPUP_GITHUB = "SetGo! on GitHub. Copy the address with Ctrl+C and open it in your browser.",
	SETGO_SCALE = "Window size",
	SETGO_SCALE_DESC = "Makes SetGo!'s windows bigger or smaller: this one and the Quick Menu. The game's own UI scale is in Blizzard's Options.",
	SETGO_KEY = "Key to open SetGo!",
	SETGO_KEY_DESC = "Click, then press a key. Right click clears it.",
	BINDING_TOGGLE = "Open or close SetGo!",

	-- welcome parchment
	WELCOME_HEADLINE = "Welcome to Azeroth",
	WELCOME_SUB = "Let's get you ready to explore",

	-- profile cards and layouts
	SLOT_IN_USE = "In use on this character.",
	SLOT_DATES = "Created %s  |  Modified %s",

	-- presets
	MSG_PRESET_ACTIVE = "\"%s\" is in use on this character. Nothing had to change.",
	MSG_LAYOUT_FAILED = "That Edit Mode layout couldn't be read.",
	NP_NAME = "Name",
	NP_LAYOUT_FULL = "No room for a new layout (%d account layouts)",
	GLOBAL_TAG = "(account)",
	SAVE_AND_APPLY = "Save and apply",
	MSG_BAD_LAYOUT = "That text is not an Edit Mode layout.",
	NP_IMPORT = "Import",
	NP_TEMPLATE_ENTRY = "SetGo!: %s",
	NP_UNDO = "Undo",
	NP_NEW_CELL = "+ New",
	MSG_LAYOUT_DELETED = "Edit Mode layout \"%s\" deleted.",
}

if GetLocale() == "ptBR" then
	L.OPEN = "Abrir SetGo!"

	L.HOME = "Definições rápidas"
	L.HOME_SHORT = "Início"
	L.HOME_DESC = "Volta à primeira página. As alterações por aplicar mantêm-se."
	L.CONTENTS = "Índice"
	L.PENDING = "%d alterações por aplicar."
	L.NO_PENDING = "Sem alterações."
	L.DEFAULTS_BUTTON = "Predefinições"
	L.DEFAULTS_BUTTON_DESC = "Repõe esta página, ou todas, com os valores da Blizzard. Nada muda até aplicares."
	L.RESET_PAGE = "Repor esta página"
	L.RESET_ALL = "Repor todas as páginas"
	L.APPLY_NOTE = "Aplica todas as alterações por aplicar, de qualquer página, e recarrega a interface."
	L.NO_CHANGES = "Ainda não há nada para aplicar."

	L.MODULES = "Módulos"

	L.DELETE = "Apagar"
	L.POPUP_DISCARD = "Descartar %d alterações que não foram aplicadas?"
	L.PAGE_LAYOUT = "Layout"
	L.SEC_EDITMODE = "Edit Mode"
	L.EDITMODE_LAYOUT = "Layout do Edit Mode"
	L.EDITMODE_LAYOUT_DESC = "O layout que esta personagem usa. Os layouts criam-se no Edit Mode."
	L.NAMEPLATES_ADVANCED = "Opções avançadas das placas de nome"
	L.NAMEPLATES_ADVANCED_DESC = "Abre o menu de placas de nome da Blizzard, para tamanhos, auras, barras de cast e cores. O que mudares lá aplica-se logo."
	L.POPUP_BLIZZARD = "Isto abre o menu de placas de nome da Blizzard e fecha o SetGo! por agora.\n\nAs tuas alterações aqui ficam guardadas, por aplicar. O SetGo! volta a abrir nesta página quando fechares o menu da Blizzard."

	L.MOD_FETCH = "Fetch!"
	L.MOD_FETCH_DESC = "Uma barra com até 12 botões, cada um com um menu de seis espaços para feitiços, objectos e macros. Pode ficar mesmo por cima da barra dos sacos."
	L.MOD_LOOK = "Look!"
	L.MOD_LOOK_DESC = "Uma tecla passa o rato a controlar a câmara, com um ponto no centro do ecrã e soft targeting, como num jogo de acção."
	L.MOD_SPEAK = "Speak!"
	L.MOD_SPEAK_DESC = "Um chat mais limpo, no estilo da nova interface, esbatido ou com a moldura das tooltips: fontes da Blizzard, separadores que desvanecem e um só botão de definições."
	L.MOD_HIDE = "Hide!"
	L.MOD_HIDE_DESC = "Esconde frames da Blizzard como uma macro: sempre, ou só quando (ou excepto quando) estás em combate, montado, a carregar numa tecla e mais."
	L.MODULE_NO_PROFILE = "Este módulo não tem opções de perfil."
	L.NO_MODULES = "Não há módulos instalados. Vêm em pastas separadas (SetGo_Fetch, SetGo_Look, SetGo_Speak, SetGo_Hide) na pasta AddOns."
	L.POPUP_RELOAD_MODULES = "Recarregar a interface agora para ligar ou desligar o módulo?"

	L.MSG_KEYS_SKIPPED = "%d teclas ignoradas: os addons delas não estão instalados."


	L.NOT_BOUND = "Sem tecla"
	L.PRESS_KEY = "Carrega numa tecla"


	L.MSG_COMBAT = "Não é possível alterar definições em combate."
	L.MSG_APPLIED = "%d definições alteradas."
	L.MSG_FAILED = "Não foi possível alterar %d definições."
	L.MSG_NOT_READY = "As definições do jogo ainda estão a carregar. Tenta daqui a pouco."


	L.TAB_MODULES = "Módulos"
	L.TAB_SETTINGS = "SetGo!"
	L.DISCARD = "Descartar"
	L.DISCARD_DESC = "Esquece todas as alterações que ainda não aplicaste."
	L.SETGO_TITLE = "Opções do SetGo!"
	L.SETGO_TAB = "Separador inicial"
	L.SETGO_TAB_DESC = "O separador que aparece na primeira página quando o SetGo! abre."
	L.SETGO_MINIMAP = "Botão no minimapa"
	L.SETGO_MINIMAP_DESC = "Mostra o botão do SetGo! no minimapa. O menu de addons junto ao minimapa tem-no sempre."


	L.RENAME = "Mudar o nome"
	L.POPUP_RENAME = "Novo nome para \"%s\":"
	L.CONTENTS_DESC = "Clica para saltar para outra página."
	L.APPLY = "Aplicar alterações"


	L.SETGO_MUTE = "Silenciar os sons do SetGo!"
	L.SETGO_MUTE_DESC = "Sem sons de livro, páginas ou caixas de selecção vindos do SetGo!."
	L.SETGO_GENERAL = "Geral"
	L.SETGO_HELP = "Ajuda"
	L.SETGO_GITHUB_DESC = "A página do SetGo! no GitHub: o que mudou em cada versão e onde reportar um problema."
	L.POPUP_GITHUB = "O SetGo! no GitHub. Copia o endereço com Ctrl+C e abre-o no navegador."
	L.SETGO_SCALE = "Tamanho das janelas"
	L.SETGO_SCALE_DESC = "Aumenta ou diminui as janelas do SetGo!: esta e o Quick Menu. A escala da interface do jogo está nas Opções da Blizzard."
	L.SETGO_KEY = "Tecla para abrir o SetGo!"
	L.SETGO_KEY_DESC = "Clica e carrega numa tecla. O clique direito apaga-a."
	L.BINDING_TOGGLE = "Abrir ou fechar o SetGo!"

	L.WELCOME_HEADLINE = "Bem-vindo a Azeroth"
	L.WELCOME_SUB = "Vamos preparar-te para explorar"

	L.SLOT_IN_USE = "Em uso nesta personagem."
	L.SLOT_DATES = "Criado a %s  |  Alterado a %s"

	L.MSG_PRESET_ACTIVE = "\"%s\" está em uso nesta personagem. Não foi preciso mudar nada."
	L.MSG_LAYOUT_FAILED = "Não foi possível ler esse layout do Edit Mode."
	L.NP_NAME = "Nome"
	L.NP_LAYOUT_FULL = "Não há espaço para um layout novo (%d layouts de conta)"
	L.GLOBAL_TAG = "(conta)"
	L.SAVE_AND_APPLY = "Guardar e aplicar"
	L.MSG_BAD_LAYOUT = "Esse texto não é um layout do Edit Mode."
	L.NP_IMPORT = "Importar"
	L.NP_TEMPLATE_ENTRY = "SetGo!: %s"
	L.NP_UNDO = "Desfazer"
	L.MSG_LAYOUT_DELETED = "Layout do Edit Mode \"%s\" apagado."
end

-- Blizzard's own string when the client has it (already translated),
-- otherwise ours.
function ns.G(key, fallback)
	local v = key and _G[key]
	if type(v) == "string" and v ~= "" then
		return v
	end
	return fallback
end

-- Where SetGo! means what Blizzard's menus mean, Blizzard's own words (the
-- client's, so they match the game in every language)
local BLIZZARD = {
	APPLY = "SETTINGS_APPLY",
	DEFAULTS_BUTTON = "SETTINGS_DEFAULTS",
	SEC_EDITMODE = "HUD_EDIT_MODE_MENU",
	SAVE = "SAVE",
	DELETE = "DELETE",
}
for key, global in pairs(BLIZZARD) do
	L[key] = ns.G(global, L[key])
end

ns.L = L

-- key binding menu
BINDING_HEADER_SETGO = L.ADDON
BINDING_NAME_SETGO_TOGGLE = L.BINDING_TOGGLE
