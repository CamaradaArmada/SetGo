local _, ns = ...

local L = {
	ADDON = "SetGo!",
	OPEN = "Open SetGo!",
	PANEL_DESC = "Quick setup for the Blizzard UI: presets with this character's settings, Edit Mode layout and keys, to use on your other characters, plus optional modules.",

	-- book
	STEP = "Page %d of %d",
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
	RESET_TITLE = "Blizzard defaults",
	RESET_WHAT = "What do you want to reset?",
	RESET_EVERYTHING = "Everything",
	RESET_GLOBAL = "Global settings only",
	RESET_CHARACTER = "This character's settings only",
	RESET_NOTE = "Character settings include the Edit Mode layout, which goes back to Classic, and action bars 2 to 8, which are hidden, as on a new character. Modules are not touched. The interface reloads afterwards.",
	RESET_BUTTON = "Reset",
	POPUP_RESET = "Reset the chosen settings to Blizzard's defaults? The interface will reload.",

	-- paths
	CURRENT = "Current settings",
	DELETE = "Delete",
	SAVE = "Save",
	EXPORT = "Export",
	IMPORT = "Import",
	POPUP_DELETE = "Delete the preset \"%s\"? Its Edit Mode layout stays.",
	POPUP_EXPORT = "Copy this text with Ctrl+C and share it:",
	POPUP_IMPORT = "Paste a preset text with Ctrl+V:",
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
	MOD_QUICK = "Quick!",
	MOD_QUICK_DESC = "A small menu by the minimap for the settings you change in the moment: nameplates, NPC names, volume and Quiet!, which hides the world channels from the chat. Nothing changed there goes into your profiles.",
	MODULE_NO_PROFILE = "This module has no profile options.",
	NO_MODULES = "No modules installed. They come as separate folders (SetGo_Fetch, SetGo_Look, SetGo_Speak, SetGo_Hide) in the AddOns folder.",
	POPUP_RELOAD_MODULES = "Reload the interface now to switch the module on or off?",

	-- keybind profiles
	MSG_KEYS_SKIPPED = "%d key bindings skipped: their addons are not installed.",

	-- minimap button
	MINIMAP_TIP = "Left click: open or close\nRight click: menu",
	MENU_QUICK = "Quick!",
	ADVENTURE_ON = "Adventure Mode",

	-- key binding rows
	NOT_BOUND = "Not bound",
	PRESS_KEY = "Press a key",

	-- first login popup
	HELLO_NONE = "No presets yet",
	HELLO_APPLY = "Apply",

	-- messages
	MSG_SAVED = "Preset \"%s\" saved.",
	MSG_DELETED = "Preset \"%s\" deleted.",
	MSG_BAD_IMPORT = "That text is not a SetGo! preset.",
	MSG_COMBAT = "Settings can't be changed in combat.",
	MSG_APPLIED = "%d settings changed.",
	MSG_FAILED = "%d settings could not be changed.",
	MSG_NOT_READY = "The game's settings are still loading. Try again in a moment.",
	MSG_FOUND = "%d options found for \"%s\".",
	SEARCH = "Search",
	SEARCH_HINT = "Search options",
	SEARCH_TITLE = "Results: %d",
	SEARCH_NONE = "Nothing matches. Try another word, in the game's language.",

	-- presets and the preset editor
	YOUR_PRESETS = "Your presets",
	NEW_PRESET = "New preset",
	NEW_PRESET_DESC = "Name it, pick its Edit Mode layout, its starting settings and its keys. It is saved and applied to this character.",
	PRESET_OPEN_DESC = "Shows what this preset holds and, if this character uses it, what changed since you saved it.",
	PRESET_HOLDS = "What it holds",
	PRESET_KEYS_KEEP = "Keys: not kept, they stay as they are",
	UPRESET_APPLY_DESC = "Applies the preset to this character: its character settings, its Edit Mode layout and its keys. The interface reloads when settings change.",
	POPUP_UPRESET_APPLY = "Apply the preset \"%s\" to this character? The interface reloads if settings change.",
	HIDE_GLOBAL = "Hide global options",
	HIDE_GLOBAL_DESC = "Hides the options shared by every character on the account, and the pages that only have those. Presets keep character options only. The search still finds them.",
	POPUP_PRESET_NAME = "Name for the preset:",

	-- tabs and our own pages
	TAB_PRESETS = "Presets",
	TAB_MODULES = "Modules",
	TAB_SETTINGS = "SetGo!",
	DISCARD = "Discard",
	DISCARD_DESC = "Forgets every change not applied yet.",
	SETGO_TITLE = "SetGo! settings",
	SETGO_TAB = "Opening tab",
	SETGO_TAB_DESC = "The tab listed on the first page when SetGo! opens.",
	SETGO_MINIMAP = "Minimap button",
	SETGO_MINIMAP_DESC = "Shows the SetGo! button on the minimap. The addon menu by the minimap always has it.",

	-- quick settings
	QUICK_TITLE = "Quick settings",
	QUICK_NOTE = "The options you change most often. They apply at once, with no reload.",
	QUICK_TOGGLES = "Switches",
	QS_ENEMY_PLATES = "Enemy nameplates",
	QS_ENEMY_PLATES_DESC = "Shows nameplates over enemies.",
	QS_FRIEND_PLATES = "Friendly player nameplates",
	QS_FRIEND_PLATES_DESC = "Shows nameplates over friendly players.",
	QS_LOCK_BARS = "Lock action bars",
	QS_LOCK_BARS_DESC = "Stops spells from being dragged off the action bars by accident.",
	QS_SELF_CAST = "Auto self cast",
	QS_SELF_CAST_DESC = "Helpful spells land on you when you have no friendly target.",
	QS_SELF_HIGHLIGHT = "Self highlight",
	QS_SELF_HIGHLIGHT_DESC = "An outline shows where your character is, even behind scenery.",
	QS_MUSIC = "Music",
	QS_MUSIC_DESC = "Turns the game's music on or off.",
	QS_SOUND = "Sound",
	QS_SOUND_DESC = "Turns all game sound on or off.",
	QUICK_INTERFACE = "Interface",
	QS_UI_SCALE = "UI scale",
	QS_UI_SCALE_DESC = "Makes the whole interface bigger or smaller. Can't change in combat.",
	QUICK_PERFORMANCE = "Performance",
	QS_FPS = "Max frame rate",
	QS_FPS_DESC = "Caps the frame rate, to save power and heat.",
	QS_FPS_BG = "Background frame rate",
	QS_FPS_BG_DESC = "Caps the frame rate while the game is in the background.",
	QS_RENDER = "Render scale",
	QS_RENDER_DESC = "Draws the 3D world at a lower or higher resolution than the screen. Lower is faster; the interface stays sharp.",
	QUICK_SOUND = "Sound",
	QS_VOL_MASTER = "Master volume",
	QS_VOL_MUSIC = "Music volume",
	QS_VOL_SFX = "Effects volume",
	QS_VOL_AMBIENCE = "Ambience volume",
	QS_VOL_DIALOG = "Dialog volume",
	QS_SOUND_BG = "Sound in background",
	QS_SOUND_BG_DESC = "Keeps the sound on when you switch to another window.",

	-- profile slots
	SLOT_IMPORT_HINT = "Right click: import a preset text.",
	SLOT_MENU_HINT = "Right click: rename, export, delete.",
	SLOT_SAVE_DESC = "Saves this character's settings, Edit Mode layout and keys, as they are now, into the preset.",
	REVERT = "Revert",
	SLOT_REVERT_DESC = "Applies the preset again, undoing what changed since you saved it.",
	RENAME = "Rename",
	POPUP_RENAME = "New name for \"%s\":",
	MSG_NAME_TAKEN = "There is already a preset called \"%s\".",
	CONTENTS_DESC = "Click to jump to another page.",
	APPLY = "Apply changes",

	-- Blizzard tools
	QUICK_TOOLS = "Blizzard tools",
	CDM = "Cooldown Manager",
	CDM_DESC = "Opens Blizzard's Cooldown Manager settings. SetGo! opens again when you close it.",
	QUICK_KEYBIND = "Quick Keybind",
	QUICK_KEYBIND_DESC = "Hover a button and press a key to bind it. SetGo! opens again when you leave.",
	ALL_KEYBINDS = "All key bindings",
	ALL_KEYBINDS_DESC = "Opens Blizzard's key bindings menu. SetGo! opens again when you close it.",
	MSG_NO_CDM = "The Cooldown Manager isn't available here.",

	-- SetGo! settings
	SETGO_MUTE = "Mute SetGo! sounds",
	SETGO_MUTE_DESC = "No book, page or checkbox sounds from SetGo!.",
	SETGO_KEY = "Key to open SetGo!",
	SETGO_KEY_DESC = "Click, then press a key. Right click clears it.",
	BINDING_TOGGLE = "Open or close SetGo!",

	-- welcome parchment
	WELCOME_HEADLINE = "Welcome to Azeroth",
	WELCOME_SUB = "Let's get you ready to explore",
	WELCOME_PRESETS = "Start with a layout:",
	WELCOME_PROFILES = "Or use one of your own presets:",
	HELLO_APPLY_DESC = "Applies the preset to this character: settings, Edit Mode layout and keys.",
	HELLO_FULL_DESC = "Opens SetGo! on its Presets tab, to make a preset of your own.",

	-- profile cards and layouts
	SLOT_IN_USE = "In use on this character.",
	SLOT_DATES = "Created %s  |  Modified %s",
	MSG_LAYOUT_CREATED = "Edit Mode layout \"%s\" created.",
	MSG_LAYOUT_FULL = "The Edit Mode layout wasn't created: you already have %d account layouts. Delete one in Edit Mode, or use a layout you have.",

	-- presets
	PRESET_SETTINGS = "%d settings changed from Blizzard's defaults",
	PRESET_TEST_LABEL = "%s (test)",
	PRESET_APPLY = "Apply preset",
	CRUMB_PRESET = "Preset: %s",
	MSG_LAYOUT_MISSING = "The Edit Mode layout of \"%s\" no longer exists. Its settings and keys were applied; pick another layout on its page.",
	MSG_PRESET_ACTIVE = "\"%s\" is in use on this character. Nothing had to change.",
	MSG_LAYOUT_FAILED = "That Edit Mode layout couldn't be read.",
	MSG_TEMPLATE_SAVED = "Layout template \"%s\" saved from the active layout. /reload to write it to disk.",
	TEMPLATE_USAGE = "To save a layout template: /setgo template <name>, with the layout active.",
	PRESET_LAYOUT = "Edit Mode layout: %s",
	PRESET_LAYOUT_GONE = "Edit Mode layout: \"%s\" no longer exists",
	PRESET_NO_LAYOUT = "No Edit Mode layout",
	PRESET_KEYS_N = "Keys: %d bindings",
	MODULES_OWN = "This character has its own modules",
	MODULES_OWN_DESC = "Off: the modules below are switched on or off for every character on the account. On: this character keeps its own switches.",
	SLOT_ACTIVE = "In use here",
	SLOT_ACTIVE_DIFF = "In use here  |  %d changes not saved",
	SLOT_LAYOUT_GONE = "Its Edit Mode layout no longer exists",
	SLOT_LAYOUT = "Layout: %s",
	PICK_LAYOUT = "Edit Mode layout for this preset",
	DIFF_TITLE = "Changed since you saved it",
	DIFF_KEYS = "%d keys changed",
	DIFF_SETTINGS = "%d character options changed",
	DIFF_MORE = " and %d more",
	DIFF_LAYOUT_OTHER = "Another Edit Mode layout is active: %s",
	DIFF_LAYOUT_GONE = "Its Edit Mode layout no longer exists. Pick another below, or Save to use the active one.",
	DIFF_STAGED = "%d changes waiting on the pages (Save applies them too)",
	DIFF_NONE = "Nothing. The game matches the preset.",
	SAVE_AS_NEW = "Save as new",
	SAVE_AS_NEW_DESC = "Saves this character's settings, layout and keys, as they are now, into a new preset, which this character then uses.",
	CHANGE_LAYOUT = "Change layout",
	CHANGE_LAYOUT_DESC = "Picks another Edit Mode layout for this preset. It is used the next time the preset is applied.",
	PRESET_DATES = "Created %s. Last saved %s.",
	PRESET_CREATED = "Created %s.",
	NP_INTRO = "A preset keeps this character's options, an Edit Mode layout and your keys, to use on your other characters.",
	NP_NAME = "Name",
	NP_LAYOUT = "Edit Mode layout",
	NP_LAYOUT_FULL = "No room for a new layout (%d account layouts)",
	NP_LAYOUT_USE_NOTE = "Other presets can use the same layout. What you move in Edit Mode changes it for all of them.",
	NP_LAYOUT_COPY_NOTE = "A new account layout, named after the preset. The Fetch! bar is copied with it.",
	NP_LAYOUT_NEW_NOTE = "A new account layout, named after the preset.",
	NP_KEYS = "Keys",
	MSG_NAME_EMPTY = "The preset needs a name.",
	POPUP_NP_CREATE = "Create the preset \"%s\" and apply it to this character? The interface reloads if settings change.",
	POPUP_SAVE = "Save this character's settings, Edit Mode layout and keys into \"%s\"?",
	POPUP_SAVE_APPLY = "%d changes are waiting on the pages. Apply them and save everything into \"%s\"? The interface will reload.",
	POPUP_REVERT = "Apply \"%s\" again, undoing what changed since you saved it?",
	MENU_SAVE = "Save \"%s\"",
	MENU_SAVE_DIFF = "Save \"%s\" (%d changes)",
	MENU_SAVE_NEW = "Save as new preset...",
	GLOBAL_TAG = "(account)",
	NO_PRESET = "No preset in use",
	NO_PRESET_DESC = "Changes to character options aren't kept anywhere. Make a preset from the free card in the Presets tab.",
	STATUS_HINT = "Its card on the left saves or reverts; right click it for more.",
	STATUS_LAYOUT_GONE = "%s  |  its Edit Mode layout no longer exists",
	STATUS_DIFF = "%s  |  %d changes not saved",
	STATUS_SAVED = "%s  |  saved",
	OPTIONS_TITLE = "Options",
	SAVE_AND_APPLY = "Save and apply",
	SAVE_AND_APPLY_DESC = "Saves the character options into \"%s\", applies every change and reloads the interface. Global options are applied, never saved in the preset.",
	WELCOME_CREATE = "Create",
	WELCOME_CREATE_DESC = "Makes your first preset from it, with this character's settings and keys, and applies it.",
	POPUP_NP_CANCEL = "Leave this preset? The changes waiting on the pages are dropped.",
	SAVE_OPTIONS = "Save options",
	SAVE_OPTIONS_DESC = "Back to the preset, with these options. Nothing is applied until you press Apply there.",
	STATUS_EDITING = "Editing \"%s\"  |  Save options goes back to it",
	STATUS_NEW = "New preset  |  Save options goes back to it",
	STATUS_FORM_DESC = "Change what you want on these pages. Save options takes you back to the preset, where Apply saves and applies it all, with one reload.",
	POPUP_IMPORT_LAYOUT = "Paste an Edit Mode layout text (in Edit Mode: Share, Copy to Clipboard):",
	MSG_BAD_LAYOUT = "That text is not an Edit Mode layout.",
	NP_IMPORT = "Import",
	NP_COPY_FROM = "Copy from",
	NP_TEMPLATE_ENTRY = "SetGo!: %s",
	NP_CURRENT = "As they are now",
	NP_OPTIONS = "Options",
	NP_OPTIONS_GEAR = "Set the options",
	NP_OPTIONS_GEAR_DESC = "Opens the options pages. Save options, at the bottom, brings you back here.",
	NP_KEYS_GEAR_DESC = "Opens Blizzard's key bindings menu (Quick Keybind Mode is in there too). SetGo! comes back here when you close it, and keys you changed go into the preset.",
	NP_APPLY = "Apply",
	NP_APPLY_DESC = "Saves the preset with this layout, options and keys, and applies it to this character. The interface reloads when settings change.",
	NP_SAVE = "Save and apply",
	POPUP_NP_SAVE = "Save \"%s\" and apply it to this character? The interface reloads if settings change.",
	NP_UNDO = "Undo",
	NP_UNDO_DESC = "Puts this page back as it was, and drops the changes waiting on the options pages.",
	POPUP_NP_UNDO = "Drop the changes made here and on the options pages?",
	NP_EDIT_DIFF = "In use on this character  |  %d changes not saved",
	NP_EDIT_INFO = "In use on this character",
	NP_NEW_FROM = "New: %s",
	NP_NEW_CELL = "+ New",
	NP_NEW_CELL_TIP = "A new account layout, named after the preset: import one, or copy one of these. The preset is saved with it, and Edit Mode opens to set it up.",
	NP_PENDING = "%d options set on the pages",
	MSG_LAYOUT_DELETED = "Edit Mode layout \"%s\" deleted.",
	MSG_NAME_FIRST = "Name the preset first: the new layout takes its name.",
	POPUP_DELETE_LAYOUT = "Delete the preset \"%s\"? Its Edit Mode layout \"%s\" is deleted too: SetGo! made it for this preset and no other uses it.",
	NP_EDIT_LAYOUT = "Open in Edit Mode",
	NP_EDIT_LAYOUT_DESC = "Makes the chosen layout the active one and opens Edit Mode. SetGo! comes back here when you close it.",
	NP_KEYS_UNDO = "Undo the keys",
	NP_KEYS_UNDO_DESC = "Puts back the keys you had before opening the key bindings menu, in the game and in the preset.",
	MSG_KEYS_IN_PRESET = "Keys saved in \"%s\".",
}

if GetLocale() == "ptBR" then
	L.OPEN = "Abrir SetGo!"
	L.PANEL_DESC = "Configuração rápida da interface da Blizzard: presets com as definições da personagem, o layout do Edit Mode e as teclas, para usares nas tuas outras personagens, e módulos opcionais."

	L.STEP = "Página %d de %d"
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
	L.RESET_TITLE = "Valores da Blizzard"
	L.RESET_WHAT = "O que queres repor?"
	L.RESET_EVERYTHING = "Tudo"
	L.RESET_GLOBAL = "Só as definições globais"
	L.RESET_CHARACTER = "Só as definições desta personagem"
	L.RESET_NOTE = "As definições da personagem incluem o layout do Edit Mode, que volta ao Classic, e as barras de acção 2 a 8, que ficam escondidas, como numa personagem nova. Os módulos não são tocados. A interface recarrega a seguir."
	L.RESET_BUTTON = "Repor"
	L.POPUP_RESET = "Repor as definições escolhidas com os valores da Blizzard? A interface vai recarregar."

	L.CURRENT = "Definições actuais"
	L.DELETE = "Apagar"
	L.SAVE = "Guardar"
	L.EXPORT = "Exportar"
	L.IMPORT = "Importar"
	L.POPUP_DELETE = "Apagar o preset \"%s\"? O layout do Edit Mode fica."
	L.POPUP_EXPORT = "Copia este texto com Ctrl+C e partilha-o:"
	L.POPUP_IMPORT = "Cola o texto de um preset com Ctrl+V:"
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
	L.MOD_QUICK = "Quick!"
	L.MOD_QUICK_DESC = "Um menu pequeno junto do minimapa para as definições que mudas no momento: placas de nome, nomes dos NPCs, volume e o Quiet!, que esconde os canais do mundo do chat. Nada do que mudares lá vai para os perfis."
	L.MODULE_NO_PROFILE = "Este módulo não tem opções de perfil."
	L.NO_MODULES = "Não há módulos instalados. Vêm em pastas separadas (SetGo_Fetch, SetGo_Look, SetGo_Speak, SetGo_Hide) na pasta AddOns."
	L.POPUP_RELOAD_MODULES = "Recarregar a interface agora para ligar ou desligar o módulo?"

	L.MSG_KEYS_SKIPPED = "%d teclas ignoradas: os addons delas não estão instalados."

	L.MINIMAP_TIP = "Clique esquerdo: abrir ou fechar\nClique direito: menu"
	L.ADVENTURE_ON = "Adventure Mode"

	L.NOT_BOUND = "Sem tecla"
	L.PRESS_KEY = "Carrega numa tecla"

	L.HELLO_NONE = "Ainda não há presets"
	L.HELLO_APPLY = "Aplicar"

	L.MSG_SAVED = "Preset \"%s\" guardado."
	L.MSG_DELETED = "Preset \"%s\" apagado."
	L.MSG_BAD_IMPORT = "Esse texto não é um preset do SetGo!"
	L.MSG_COMBAT = "Não é possível alterar definições em combate."
	L.MSG_APPLIED = "%d definições alteradas."
	L.MSG_FAILED = "Não foi possível alterar %d definições."
	L.MSG_NOT_READY = "As definições do jogo ainda estão a carregar. Tenta daqui a pouco."
	L.MSG_FOUND = "%d opções encontradas para \"%s\"."
	L.SEARCH = "Pesquisa"
	L.SEARCH_HINT = "Pesquisar opções"
	L.SEARCH_TITLE = "Resultados: %d"
	L.SEARCH_NONE = "Nada corresponde. Experimenta outra palavra, na língua do jogo."

	L.YOUR_PRESETS = "Os teus presets"
	L.NEW_PRESET = "Novo preset"
	L.NEW_PRESET_DESC = "Dá-lhe um nome, escolhe o layout do Edit Mode, as definições de partida e as teclas. Fica guardado e aplicado a esta personagem."
	L.PRESET_OPEN_DESC = "Mostra o que este preset guarda e, se esta personagem o usa, o que mudou desde que o guardaste."
	L.PRESET_HOLDS = "O que tem"
	L.PRESET_KEYS_KEEP = "Teclas: não guarda, ficam como estão"
	L.UPRESET_APPLY_DESC = "Aplica o preset a esta personagem: as definições da personagem, o layout do Edit Mode e as teclas. A interface recarrega quando mudam definições."
	L.POPUP_UPRESET_APPLY = "Aplicar o preset \"%s\" a esta personagem? A interface recarrega se mudarem definições."
	L.HIDE_GLOBAL = "Esconder opções globais"
	L.HIDE_GLOBAL_DESC = "Esconde as opções partilhadas por todas as personagens da conta, e as páginas que só têm dessas. Os presets só guardam opções da personagem. A pesquisa continua a encontrá-las."
	L.POPUP_PRESET_NAME = "Nome do preset:"

	L.TAB_PRESETS = "Presets"
	L.TAB_MODULES = "Módulos"
	L.TAB_SETTINGS = "SetGo!"
	L.DISCARD = "Descartar"
	L.DISCARD_DESC = "Esquece todas as alterações que ainda não aplicaste."
	L.SETGO_TITLE = "Opções do SetGo!"
	L.SETGO_TAB = "Separador inicial"
	L.SETGO_TAB_DESC = "O separador que aparece na primeira página quando o SetGo! abre."
	L.SETGO_MINIMAP = "Botão no minimapa"
	L.SETGO_MINIMAP_DESC = "Mostra o botão do SetGo! no minimapa. O menu de addons junto ao minimapa tem-no sempre."

	L.QUICK_TITLE = "Definições rápidas"
	L.QUICK_NOTE = "As opções que mais mudas. Aplicam-se logo, sem recarregar."
	L.QUICK_TOGGLES = "Ligar e desligar"
	L.QS_ENEMY_PLATES = "Placas de nome dos inimigos"
	L.QS_ENEMY_PLATES_DESC = "Mostra as placas de nome por cima dos inimigos."
	L.QS_FRIEND_PLATES = "Placas de nome dos jogadores aliados"
	L.QS_FRIEND_PLATES_DESC = "Mostra as placas de nome por cima dos jogadores aliados."
	L.QS_LOCK_BARS = "Trancar as barras de acção"
	L.QS_LOCK_BARS_DESC = "Impede que arrastes feitiços para fora das barras sem querer."
	L.QS_SELF_CAST = "Lançar em ti automaticamente"
	L.QS_SELF_CAST_DESC = "Os feitiços de ajuda vão para ti quando não tens um alvo aliado."
	L.QS_SELF_HIGHLIGHT = "Destacar a personagem"
	L.QS_SELF_HIGHLIGHT_DESC = "Um contorno mostra onde está a tua personagem, mesmo atrás do cenário."
	L.QS_MUSIC = "Música"
	L.QS_MUSIC_DESC = "Liga ou desliga a música do jogo."
	L.QS_SOUND = "Som"
	L.QS_SOUND_DESC = "Liga ou desliga todo o som do jogo."
	L.QUICK_INTERFACE = "Interface"
	L.QS_UI_SCALE = "Escala da interface"
	L.QS_UI_SCALE_DESC = "Aumenta ou diminui toda a interface. Não muda em combate."
	L.QUICK_PERFORMANCE = "Desempenho"
	L.QS_FPS = "Limite de FPS"
	L.QS_FPS_DESC = "Limita os fotogramas por segundo, para poupar energia e calor."
	L.QS_FPS_BG = "Limite de FPS em segundo plano"
	L.QS_FPS_BG_DESC = "Limita os fotogramas por segundo quando o jogo está em segundo plano."
	L.QS_RENDER = "Escala de renderização"
	L.QS_RENDER_DESC = "Desenha o mundo 3D numa resolução menor ou maior do que a do ecrã. Menor é mais rápido; a interface continua nítida."
	L.QUICK_SOUND = "Som"
	L.QS_VOL_MASTER = "Volume geral"
	L.QS_VOL_MUSIC = "Volume da música"
	L.QS_VOL_SFX = "Volume dos efeitos"
	L.QS_VOL_AMBIENCE = "Volume do ambiente"
	L.QS_VOL_DIALOG = "Volume dos diálogos"
	L.QS_SOUND_BG = "Som em segundo plano"
	L.QS_SOUND_BG_DESC = "Mantém o som ligado quando mudas para outra janela."

	L.SLOT_IMPORT_HINT = "Clique direito: importar o texto de um preset."
	L.SLOT_MENU_HINT = "Clique direito: mudar o nome, exportar, apagar."
	L.SLOT_SAVE_DESC = "Guarda no preset as definições desta personagem, o layout do Edit Mode e as teclas, tal como estão agora."
	L.REVERT = "Reverter"
	L.SLOT_REVERT_DESC = "Aplica o preset outra vez e desfaz o que mudou desde que o guardaste."
	L.RENAME = "Mudar o nome"
	L.POPUP_RENAME = "Novo nome para \"%s\":"
	L.MSG_NAME_TAKEN = "Já existe um preset chamado \"%s\"."
	L.CONTENTS_DESC = "Clica para saltar para outra página."
	L.APPLY = "Aplicar alterações"

	L.QUICK_TOOLS = "Ferramentas da Blizzard"
	L.CDM = "Gestor de Recargas"
	L.CDM_DESC = "Abre as definições do Gestor de Recargas da Blizzard. O SetGo! volta a abrir quando o fechares."
	L.QUICK_KEYBIND = "Teclas rápidas"
	L.QUICK_KEYBIND_DESC = "Passa o rato por um botão e carrega numa tecla para a atribuir. O SetGo! volta a abrir quando saíres."
	L.ALL_KEYBINDS = "Todas as teclas"
	L.ALL_KEYBINDS_DESC = "Abre o menu de teclas da Blizzard. O SetGo! volta a abrir quando o fechares."
	L.MSG_NO_CDM = "O Gestor de Recargas não está disponível aqui."

	L.SETGO_MUTE = "Silenciar os sons do SetGo!"
	L.SETGO_MUTE_DESC = "Sem sons de livro, páginas ou caixas de selecção vindos do SetGo!."
	L.SETGO_KEY = "Tecla para abrir o SetGo!"
	L.SETGO_KEY_DESC = "Clica e carrega numa tecla. O clique direito apaga-a."
	L.BINDING_TOGGLE = "Abrir ou fechar o SetGo!"

	L.WELCOME_HEADLINE = "Bem-vindo a Azeroth"
	L.WELCOME_SUB = "Vamos preparar-te para explorar"
	L.WELCOME_PRESETS = "Começa com um layout:"
	L.WELCOME_PROFILES = "Ou usa um dos teus presets:"
	L.HELLO_APPLY_DESC = "Aplica o preset a esta personagem: definições, layout do Edit Mode e teclas."
	L.HELLO_FULL_DESC = "Abre o SetGo! no separador Presets, para criares o teu preset."

	L.SLOT_IN_USE = "Em uso nesta personagem."
	L.SLOT_DATES = "Criado a %s  |  Alterado a %s"
	L.MSG_LAYOUT_CREATED = "Layout do Edit Mode \"%s\" criado."
	L.MSG_LAYOUT_FULL = "O layout do Edit Mode não foi criado: já tens %d layouts de conta. Apaga um no Edit Mode ou usa um layout que já tenhas."

	L.PRESET_SETTINGS = "%d definições diferentes dos valores da Blizzard"
	L.PRESET_TEST_LABEL = "%s (teste)"
	L.PRESET_APPLY = "Aplicar preset"
	L.CRUMB_PRESET = "Preset: %s"
	L.MSG_LAYOUT_MISSING = "O layout do Edit Mode de \"%s\" já não existe. As definições e as teclas foram aplicadas; escolhe outro layout na página do preset."
	L.MSG_PRESET_ACTIVE = "\"%s\" está em uso nesta personagem. Não foi preciso mudar nada."
	L.MSG_LAYOUT_FAILED = "Não foi possível ler esse layout do Edit Mode."
	L.MSG_TEMPLATE_SAVED = "Modelo de layout \"%s\" guardado a partir do layout activo. Faz /reload para o gravar no disco."
	L.TEMPLATE_USAGE = "Para guardar um modelo de layout: /setgo template <nome>, com o layout activo."
	L.PRESET_LAYOUT = "Layout do Edit Mode: %s"
	L.PRESET_LAYOUT_GONE = "Layout do Edit Mode: \"%s\" já não existe"
	L.PRESET_NO_LAYOUT = "Sem layout do Edit Mode"
	L.PRESET_KEYS_N = "Teclas: %d atribuições"
	L.MODULES_OWN = "Esta personagem tem os seus próprios módulos"
	L.MODULES_OWN_DESC = "Desligado: os módulos em baixo ligam-se ou desligam-se para todas as personagens da conta. Ligado: esta personagem tem os seus."
	L.SLOT_ACTIVE = "Em uso aqui"
	L.SLOT_ACTIVE_DIFF = "Em uso aqui  |  %d alterações por guardar"
	L.SLOT_LAYOUT_GONE = "O layout do Edit Mode já não existe"
	L.SLOT_LAYOUT = "Layout: %s"
	L.PICK_LAYOUT = "Layout do Edit Mode para este preset"
	L.DIFF_TITLE = "Mudou desde que o guardaste"
	L.DIFF_KEYS = "%d teclas alteradas"
	L.DIFF_SETTINGS = "%d opções da personagem alteradas"
	L.DIFF_MORE = " e mais %d"
	L.DIFF_LAYOUT_OTHER = "Está activo outro layout do Edit Mode: %s"
	L.DIFF_LAYOUT_GONE = "O layout do Edit Mode já não existe. Escolhe outro em baixo, ou Guarda para usar o activo."
	L.DIFF_STAGED = "%d alterações por aplicar nas páginas (Guardar também as aplica)"
	L.DIFF_NONE = "Nada. O jogo está igual ao preset."
	L.SAVE_AS_NEW = "Guardar como novo"
	L.SAVE_AS_NEW_DESC = "Guarda as definições desta personagem, o layout e as teclas, tal como estão agora, num preset novo, que esta personagem passa a usar."
	L.CHANGE_LAYOUT = "Mudar o layout"
	L.CHANGE_LAYOUT_DESC = "Escolhe outro layout do Edit Mode para este preset. É usado da próxima vez que o preset for aplicado."
	L.PRESET_DATES = "Criado a %s. Guardado pela última vez a %s."
	L.PRESET_CREATED = "Criado a %s."
	L.NP_INTRO = "Um preset guarda as opções desta personagem, um layout do Edit Mode e as tuas teclas, para usares nas outras personagens."
	L.NP_NAME = "Nome"
	L.NP_LAYOUT = "Layout do Edit Mode"
	L.NP_LAYOUT_FULL = "Não há espaço para um layout novo (%d layouts de conta)"
	L.NP_LAYOUT_USE_NOTE = "Outros presets podem usar o mesmo layout. O que mexeres no Edit Mode muda-o para todos."
	L.NP_LAYOUT_COPY_NOTE = "Um layout de conta novo, com o nome do preset. A barra do Fetch! é copiada com ele."
	L.NP_LAYOUT_NEW_NOTE = "Um layout de conta novo, com o nome do preset."
	L.NP_KEYS = "Teclas"
	L.MSG_NAME_EMPTY = "O preset precisa de um nome."
	L.POPUP_NP_CREATE = "Criar o preset \"%s\" e aplicá-lo a esta personagem? A interface recarrega se mudarem definições."
	L.POPUP_SAVE = "Guardar em \"%s\" as definições desta personagem, o layout do Edit Mode e as teclas?"
	L.POPUP_SAVE_APPLY = "Há %d alterações por aplicar nas páginas. Aplicá-las e guardar tudo em \"%s\"? A interface vai recarregar."
	L.POPUP_REVERT = "Aplicar \"%s\" outra vez e desfazer o que mudou desde que o guardaste?"
	L.MENU_SAVE = "Guardar \"%s\""
	L.MENU_SAVE_DIFF = "Guardar \"%s\" (%d alterações)"
	L.MENU_SAVE_NEW = "Guardar como preset novo..."
	L.GLOBAL_TAG = "(conta)"
	L.NO_PRESET = "Sem preset em uso"
	L.NO_PRESET_DESC = "As alterações às opções da personagem não ficam guardadas em lado nenhum. Cria um preset no cartão livre do separador Presets."
	L.STATUS_HINT = "O cartão dele, à esquerda, guarda ou reverte; clique direito para mais."
	L.STATUS_LAYOUT_GONE = "%s  |  o layout do Edit Mode já não existe"
	L.STATUS_DIFF = "%s  |  %d alterações por guardar"
	L.STATUS_SAVED = "%s  |  guardado"
	L.OPTIONS_TITLE = "Opções"
	L.SAVE_AND_APPLY = "Guardar e aplicar"
	L.SAVE_AND_APPLY_DESC = "Guarda as opções da personagem em \"%s\", aplica todas as alterações e recarrega a interface. As opções globais são aplicadas, nunca guardadas no preset."
	L.WELCOME_CREATE = "Criar"
	L.WELCOME_CREATE_DESC = "Cria o teu primeiro preset a partir dele, com as definições e as teclas desta personagem, e aplica-o."
	L.POPUP_NP_CANCEL = "Sair deste preset? As alterações por aplicar nas páginas são descartadas."
	L.SAVE_OPTIONS = "Guardar opções"
	L.SAVE_OPTIONS_DESC = "Volta ao preset, com estas opções. Nada se aplica até carregares em Aplicar lá."
	L.STATUS_EDITING = "A editar \"%s\"  |  Guardar opções volta a ele"
	L.STATUS_NEW = "Preset novo  |  Guardar opções volta a ele"
	L.STATUS_FORM_DESC = "Muda o que quiseres nestas páginas. Guardar opções leva-te de volta ao preset, onde Aplicar guarda e aplica tudo, com um só reload."
	L.POPUP_IMPORT_LAYOUT = "Cola o texto de um layout do Edit Mode (no Edit Mode: Partilhar, Copiar para a área de transferência):"
	L.MSG_BAD_LAYOUT = "Esse texto não é um layout do Edit Mode."
	L.NP_IMPORT = "Importar"
	L.NP_COPY_FROM = "Copiar de"
	L.NP_TEMPLATE_ENTRY = "SetGo!: %s"
	L.NP_CURRENT = "Como estão agora"
	L.NP_OPTIONS = "Opções"
	L.NP_OPTIONS_GEAR = "Definir as opções"
	L.NP_OPTIONS_GEAR_DESC = "Abre as páginas de opções. Guardar opções, em baixo, traz-te de volta aqui."
	L.NP_KEYS_GEAR_DESC = "Abre o menu de teclas da Blizzard (o Quick Keybind Mode também está lá). O SetGo! volta aqui quando o fechares, e as teclas que mudaste entram no preset."
	L.NP_APPLY = "Aplicar"
	L.NP_APPLY_DESC = "Guarda o preset com este layout, estas opções e estas teclas, e aplica-o a esta personagem. A interface recarrega quando mudam definições."
	L.NP_SAVE = "Guardar e aplicar"
	L.POPUP_NP_SAVE = "Guardar \"%s\" e aplicá-lo a esta personagem? A interface recarrega se mudarem definições."
	L.NP_UNDO = "Desfazer"
	L.NP_UNDO_DESC = "Põe esta página como estava e descarta as alterações por aplicar nas páginas de opções."
	L.POPUP_NP_UNDO = "Descartar o que mudaste aqui e nas páginas de opções?"
	L.NP_EDIT_DIFF = "Em uso nesta personagem  |  %d alterações por guardar"
	L.NP_EDIT_INFO = "Em uso nesta personagem"
	L.NP_NEW_FROM = "Novo: %s"
	L.NP_NEW_CELL = "+ Novo"
	L.NP_NEW_CELL_TIP = "Um layout de conta novo, com o nome do preset: importa um, ou copia um destes. O preset fica guardado com ele, e o Edit Mode abre para o arranjares."
	L.NP_PENDING = "%d opções definidas nas páginas"
	L.MSG_LAYOUT_DELETED = "Layout do Edit Mode \"%s\" apagado."
	L.MSG_NAME_FIRST = "Dá primeiro um nome ao preset: o layout novo fica com esse nome."
	L.POPUP_DELETE_LAYOUT = "Apagar o preset \"%s\"? O layout do Edit Mode \"%s\" também é apagado: o SetGo! criou-o para este preset e nenhum outro o usa."
	L.NP_EDIT_LAYOUT = "Abrir no Edit Mode"
	L.NP_EDIT_LAYOUT_DESC = "Põe o layout escolhido como activo e abre o Edit Mode. O SetGo! volta aqui quando o fechares."
	L.NP_KEYS_UNDO = "Desfazer as teclas"
	L.NP_KEYS_UNDO_DESC = "Repõe as teclas que tinhas antes de abrir o menu de teclas, no jogo e no preset."
	L.MSG_KEYS_IN_PRESET = "Teclas guardadas em \"%s\"."
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
	RESET_TITLE = "SETTINGS_DEFAULTS",
	QUICK_KEYBIND = "QUICK_KEYBIND_MODE",
	ALL_KEYBINDS = "SETTINGS_KEYBINDINGS_LABEL",
	SEARCH = "SETTINGS_SEARCH_RESULTS",
	SEARCH_NONE = "SETTINGS_SEARCH_NOTHING_FOUND",
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
