local _, ns = ...
local L = ns.L

--------------------------------------------------------------------------------
-- Strings for profiles (0.14 on), and the older strings that said "preset".
--------------------------------------------------------------------------------

local EN = {

	PANEL_DESC = "Quick setup for the Blizzard UI: profiles with an Edit Mode layout, what it switches on, keys and action bars, and option profiles with character settings, to use on all your characters, plus optional modules.",
	TAB_PRESETS = "Profiles",
	YOUR_PRESETS = "Profiles",
	NEW_PRESET = "New profile",
	NEW_PRESET_DESC = "Name it, pick its Edit Mode layout, what it switches on and its option profile. It is saved and applied to this character.",
	PRESET_OPEN_DESC = "Shows what this profile holds and what Apply would change on this character.",
	SLOT_MENU_HINT = "Right click or the gear: apply, edit, rename, copy, delete.",
	CRUMB_PRESET = "Profile: %s",
	PRESET_APPLY = "Apply",
	UPRESET_APPLY_DESC = "Puts the profile on this character: its Edit Mode layout, what it switches on, its option profile and, when ticked, its keys and action bars. The interface reloads when settings change.",
	POPUP_UPRESET_APPLY = "Apply the profile \"%s\" to this character? The interface reloads if settings change.",
	DIFF_LAYOUT_GONE = "Its Edit Mode layout no longer exists. Edit the profile to pick another.",
	DIFF_LAYOUT_TO = "Edit Mode layout: %s",
	DIFF_UI_ON = "%s: on",
	DIFF_UI_OFF = "%s: off",
	DIFF_SKILLS = "%d action bar slots",
	PROFILE_MATCHES = "This character matches the profile.",
	PROFILE_UI = "Switches on: %s",
	NONE = "None",
	COPY = "Copy",
	COPY_NAME = "%s (copy)",
	MSG_SKILLS_RESTORED = "%d action bar slots put back.",
	MSG_SKILLS_FAILED = "%d action bar slots could not be put back: spells not known here, or macros and items no longer there.",
	MSG_UI_REAPPLIED = "Account-wide elements set as the profile \"%s\" has them.",
	NP_UNDO_DESC = "Puts the form back as it was.",
	NP_NEW_CELL_TIP = "A new account layout, named after the profile: import one, or copy one of these. The profile is saved with it, and Edit Mode opens to set it up.",
	MSG_NAME_EMPTY = "The profile needs a name.",
	MSG_NAME_TAKEN = "There is already a profile called \"%s\".",
	MSG_SAVED = "\"%s\" saved.",
	MSG_DELETED = "\"%s\" deleted.",
	MSG_KEYS_IN_PRESET = "Keys saved in the profile \"%s\".",
	MSG_LAYOUT_MISSING = "The Edit Mode layout of \"%s\" no longer exists. The rest was applied; edit the profile to pick another layout.",
	POPUP_DELETE = "Delete the profile \"%s\"? Its Edit Mode layout stays.",
	POPUP_DELETE_LAYOUT = "Delete the profile \"%s\"? Its Edit Mode layout \"%s\" is deleted too: SetGo! made it for this profile and no other uses it.",
	HELLO_FULL_DESC = "Opens SetGo! on its Profiles tab, to make a profile of your own.",
	RESET_NOTE = "Character settings include the Edit Mode layout, which goes back to Classic. Action bars and the elements a profile switches on are not touched, nor are modules. The interface reloads afterwards.",
	UI_BAR = "Show Action Bar %d",
	UI_BAR_SHORT = "Bar %d",
	NP_UI = "UI elements",
	NP_BARS = "Action bars",
	BAR1_LOCKED = "Action Bar 1 cannot be disabled.",
	CURRENT_LAYOUT = "Current layout",
	NP_COPY_FROM = "Copy from:",
	NP_ICON = "Icon",
	NP_ICON_DESC = "Pick the profile's icon from the game's icons.",
	PICK_ICON = "Pick an icon",
	FAVORITE = "Favorite",
	FAVORITE_DESC = "Up to three favorites, applied from the minimap button's menu.",
	MSG_FAVORITES_FULL = "There are already %d favorites. Remove one first.",
	MENU_FAVORITE_ACTIVE = "%s (in use)",
	MENU_NO_FAVORITES = "No favorite profiles yet",
	MENU_SETTINGS = "Settings",
	POPUP_EXPORT_PROFILE = "The profile \"%s\" as text (name, icon, layout, action bars and UI elements). Copy it with Ctrl+C:",
	MSG_PROFILE_IMPORTED = "Profile \"%s\" read. Save and Apply makes it, with a new layout.",
	IMPORTED = "Imported",
	FORM_CHANGED = "Changes not saved yet",
	POPUP_NEW_LAYOUT_NOTE = "A new Edit Mode layout is made: the interface reloads and Edit Mode opens after it.",
	SHORT_LAYOUT = "Layout: %s",
	SHORT_LAYOUT_GONE = "Layout missing",
	SHORT_ON = "%s: on",
	SHORT_OFF = "%s: off",
	SHORT_OPTIONS = "%d options",
	STATE_ON = "On",
	STATE_OFF = "Off",
	NP_SAVE_NEWLAYOUT = "With a new layout the game makes it active at once: use Save and Apply.",
	NP_SAVE_DESC = "Saves the profile without applying it. Nothing changes on this character.",
	SHORT_KEYS = "%d keybinds",
	DIFF_KEYS = "%d keybinds",
}


local PT = {

	PANEL_DESC = "Configuração rápida da interface da Blizzard: perfis com um layout do Edit Mode, o que ligam, teclas e barras de acção, e perfis de opções com as definições da personagem, para usares em todas as tuas personagens, e módulos opcionais.",
	TAB_PRESETS = "Perfis",
	YOUR_PRESETS = "Perfis",
	NEW_PRESET = "Novo perfil",
	NEW_PRESET_DESC = "Dá-lhe um nome, escolhe o layout do Edit Mode, o que liga e o perfil de opções. Fica guardado e aplicado a esta personagem.",
	PRESET_OPEN_DESC = "Mostra o que este perfil tem e o que Aplicar mudaria nesta personagem.",
	SLOT_MENU_HINT = "Clique direito ou a roda dentada: aplicar, editar, mudar o nome, copiar, apagar.",
	CRUMB_PRESET = "Perfil: %s",
	PRESET_APPLY = "Aplicar",
	UPRESET_APPLY_DESC = "Põe o perfil nesta personagem: o layout do Edit Mode, o que liga, o perfil de opções e, se estiverem marcadas, as teclas e as barras de acção. A interface recarrega quando mudam definições.",
	POPUP_UPRESET_APPLY = "Aplicar o perfil \"%s\" a esta personagem? A interface recarrega se mudarem definições.",
	DIFF_LAYOUT_GONE = "O layout do Edit Mode já não existe. Edita o perfil para escolheres outro.",
	DIFF_LAYOUT_TO = "Layout do Edit Mode: %s",
	DIFF_UI_ON = "%s: ligado",
	DIFF_UI_OFF = "%s: desligado",
	DIFF_SKILLS = "%d espaços das barras de acção",
	PROFILE_MATCHES = "Esta personagem está igual ao perfil.",
	PROFILE_UI = "Liga: %s",
	NONE = "Nenhum",
	COPY = "Copiar",
	COPY_NAME = "%s (cópia)",
	MSG_SKILLS_RESTORED = "%d espaços das barras de acção repostos.",
	MSG_SKILLS_FAILED = "%d espaços das barras de acção não foram repostos: feitiços que esta personagem não conhece, ou macros e itens que já não existem.",
	MSG_UI_REAPPLIED = "Elementos da conta acertados pelo perfil \"%s\".",
	NP_UNDO_DESC = "Põe o formulário como estava.",
	NP_NEW_CELL_TIP = "Um layout de conta novo, com o nome do perfil: importa um, ou copia um destes. O perfil fica guardado com ele, e o Edit Mode abre para o arranjares.",
	MSG_NAME_EMPTY = "O perfil precisa de um nome.",
	MSG_NAME_TAKEN = "Já existe um perfil chamado \"%s\".",
	MSG_SAVED = "\"%s\" guardado.",
	MSG_DELETED = "\"%s\" apagado.",
	MSG_KEYS_IN_PRESET = "Teclas guardadas no perfil \"%s\".",
	MSG_LAYOUT_MISSING = "O layout do Edit Mode de \"%s\" já não existe. O resto foi aplicado; edita o perfil para escolheres outro layout.",
	POPUP_DELETE = "Apagar o perfil \"%s\"? O layout do Edit Mode fica.",
	POPUP_DELETE_LAYOUT = "Apagar o perfil \"%s\"? O layout do Edit Mode \"%s\" também é apagado: o SetGo! criou-o para este perfil e nenhum outro o usa.",
	HELLO_FULL_DESC = "Abre o SetGo! no separador Perfis, para criares o teu perfil.",
	RESET_NOTE = "As definições da personagem incluem o layout do Edit Mode, que volta ao Classic. As barras de acção e os elementos que um perfil liga não são tocados, nem os módulos. A interface recarrega a seguir.",
	UI_BAR = "Mostrar barra de acção %d",
	UI_BAR_SHORT = "Barra %d",
	NP_UI = "Elementos da interface",
	NP_BARS = "Barras de acção",
	BAR1_LOCKED = "A barra de acção 1 não pode ser desligada.",
	CURRENT_LAYOUT = "Layout actual",
	NP_COPY_FROM = "Copiar de:",
	NP_ICON = "Ícone",
	NP_ICON_DESC = "Escolhe o ícone do perfil entre os ícones do jogo.",
	PICK_ICON = "Escolhe um ícone",
	FAVORITE = "Favorito",
	FAVORITE_DESC = "Até três favoritos, que aplicas a partir do menu do botão do minimapa.",
	MSG_FAVORITES_FULL = "Já há %d favoritos. Retira um primeiro.",
	MENU_FAVORITE_ACTIVE = "%s (em uso)",
	MENU_NO_FAVORITES = "Ainda não há perfis favoritos",
	MENU_SETTINGS = "Definições",
	POPUP_EXPORT_PROFILE = "O perfil \"%s\" em texto (nome, ícone, layout, barras de acção e elementos da interface). Copia-o com Ctrl+C:",
	MSG_PROFILE_IMPORTED = "Perfil \"%s\" lido. Guardar e aplicar cria-o, com um layout novo.",
	IMPORTED = "Importado",
	FORM_CHANGED = "Alterações por guardar",
	POPUP_NEW_LAYOUT_NOTE = "É criado um layout novo do Edit Mode: a interface recarrega e o Edit Mode abre a seguir.",
	NP_NEW_CELL = "+ Novo",
	EXPORT = "Exportar",
	SHORT_LAYOUT = "Layout: %s",
	SHORT_LAYOUT_GONE = "Layout em falta",
	SHORT_ON = "%s: ligar",
	SHORT_OFF = "%s: desligar",
	SHORT_OPTIONS = "%d opções",
	STATE_ON = "Ligado",
	STATE_OFF = "Desligado",
	NP_SAVE_NEWLAYOUT = "Com um layout novo, o jogo põe-no logo activo: usa Guardar e aplicar.",
	NP_SAVE_DESC = "Guarda o perfil sem o aplicar. Nada muda nesta personagem.",
	SHORT_KEYS = "%d keybinds",
	DIFF_KEYS = "%d keybinds",
	SAVE = "Guardar",
}


for key, value in pairs(EN) do
	L[key] = value
end
if GetLocale() == "ptBR" then
	for key, value in pairs(PT) do
		L[key] = value
	end
end

--------------------------------------------------------------------------------
-- 0.17: the profile form with tabs, Game Settings, the guide
--------------------------------------------------------------------------------

local EN17 = {
	PANEL_DESC = "Quick setup for the Blizzard UI: profiles with an Edit Mode layout, what it switches on, modules, keys, action bars and, if you want, their own character settings, to use on all your characters.",
	TAB_GAME = "Game Settings",
	FORM_TAB_LAYOUT = "Layout",
	FORM_TAB_MODULES = "Modules",
	FORM_TAB_OPTIONS = "Options",
	FORM_CUSTOM = "Apply own settings",
	FORM_CUSTOM_DESC = "Ticked: the pages below show and change the profile's own character settings, and Apply puts them on the character. Unticked: the profile neither saves nor applies settings; the ones it had are kept. Ticked on a profile without any, it starts with this character's settings.",
	FORM_OPTIONS_OFF = "This profile doesn't apply settings of its own: the character keeps its own. Tick Apply own settings to give it some.",
	NP_COPY_PROFILE = "Copy from",
	NP_COPY_LAYOUT_DESC = "Takes another profile's layout and what it switches on. Nothing is kept until you save.",
	NP_COPY_MODULES_DESC = "Takes which modules another profile switches on. Nothing is kept until you save.",
	NP_COPY_OPTIONS_DESC = "Takes another profile's own settings, and ticks Apply own settings. Nothing is kept until you save.",
	NP_NAME_DESC = "The profile's name.",
	NEW_PRESET_DESC = "A new profile: its layout, what it switches on, its modules and, if you want, its own settings. Save keeps it; Apply puts it on this character.",
	PRESET_OPEN_DESC = "Opens the profile: what it holds, and Apply.",
	SLOT_MENU_HINT = "Right click: apply, favorite, rename, copy, export, delete.",
	UPRESET_APPLY_DESC = "Puts the profile on this character: its Edit Mode layout, what it switches on, its modules, its own settings when it has them and, when ticked, its keys and action bars. The interface reloads when something needs it.",
	NP_SAVE_DESC = "Saves the profile without applying it. Nothing changes on this character until you apply it.",
	NP_SAVE_NEWLAYOUT = "Saves the profile and makes its new Edit Mode layout (not active yet). Apply puts it on, reloads the interface and opens Edit Mode.",
	GUIDE_NEXT = "Next",
	POPUP_GUIDE_NOTE = "Edit Mode opens after the reload, to set up the layout.",
	PICK_ALL = "All",
	PICK_SPELLS = "Spells",
	PICK_ITEMS = "Items",
	WELCOME_START = "Make your first profile",
	WELCOME_START_DESC = "Opens SetGo! on a guide: layout, modules and settings, then one reload and Edit Mode.",
	WELCOME_PICK = "Apply one of your profiles:",
	WELCOME_CHOOSE = "Choose a profile",
	HELLO_FULL_DESC = "Opens SetGo!.",
	HIDE_GLOBAL_DESC = "Hides the options shared by every character on the account, and the pages that only have those. The search still finds them.",
}

local PT17 = {
	PANEL_DESC = "Configuração rápida da interface da Blizzard: perfis com um layout do Edit Mode, o que ligam, módulos, teclas, barras de acção e, se quiseres, definições próprias da personagem, para usares em todas as tuas personagens.",
	TAB_GAME = "Definições do jogo",
	FORM_TAB_LAYOUT = "Layout",
	FORM_TAB_MODULES = "Módulos",
	FORM_TAB_OPTIONS = "Opções",
	FORM_CUSTOM = "Aplicar definições próprias",
	FORM_CUSTOM_DESC = "Marcada: as páginas abaixo mostram e mudam as definições da personagem guardadas no perfil, e Aplicar põe-nas na personagem. Desmarcada: o perfil não grava nem aplica definições; as que tinha ficam guardadas. Marcada num perfil sem definições, começa com as desta personagem.",
	FORM_OPTIONS_OFF = "Este perfil não aplica definições próprias: a personagem mantém as suas. Marca Aplicar definições próprias para lhe dar algumas.",
	NP_COPY_PROFILE = "Copiar de",
	NP_COPY_LAYOUT_DESC = "Traz o layout de outro perfil e o que ele liga. Nada fica guardado até guardares.",
	NP_COPY_MODULES_DESC = "Traz os módulos que outro perfil liga. Nada fica guardado até guardares.",
	NP_COPY_OPTIONS_DESC = "Traz as definições próprias de outro perfil e marca Aplicar definições próprias. Nada fica guardado até guardares.",
	NP_NAME_DESC = "O nome do perfil.",
	NEW_PRESET_DESC = "Um perfil novo: o layout, o que liga, os módulos e, se quiseres, definições próprias. Guardar fica com ele; Aplicar põe-no nesta personagem.",
	PRESET_OPEN_DESC = "Abre o perfil: o que tem, e Aplicar.",
	SLOT_MENU_HINT = "Clique direito: aplicar, favorito, mudar o nome, copiar, exportar, apagar.",
	UPRESET_APPLY_DESC = "Põe o perfil nesta personagem: o layout do Edit Mode, o que liga, os módulos, as definições próprias quando as tem e, se estiverem marcadas, as teclas e as barras de acção. A interface recarrega quando é preciso.",
	NP_SAVE_DESC = "Guarda o perfil sem o aplicar. Nada muda nesta personagem até o aplicares.",
	NP_SAVE_NEWLAYOUT = "Guarda o perfil e cria o novo layout do Edit Mode (ainda não activo). Aplicar põe-no, recarrega a interface e abre o Edit Mode.",
	GUIDE_NEXT = "Seguinte",
	POPUP_GUIDE_NOTE = "O Edit Mode abre depois do reload, para acertares o layout.",
	PICK_ALL = "Todos",
	PICK_SPELLS = "Feitiços",
	PICK_ITEMS = "Itens",
	WELCOME_START = "Criar o primeiro perfil",
	WELCOME_START_DESC = "Abre o SetGo! num guia: layout, módulos e definições, depois um reload e o Edit Mode.",
	WELCOME_PICK = "Aplica um dos teus perfis:",
	WELCOME_CHOOSE = "Escolhe um perfil",
	HELLO_FULL_DESC = "Abre o SetGo!.",
	HIDE_GLOBAL_DESC = "Esconde as opções partilhadas por todas as personagens da conta, e as páginas que só têm dessas. A pesquisa continua a encontrá-las.",
}

for key, value in pairs(EN17) do
	L[key] = value
end
if GetLocale() == "ptBR" then
	for key, value in pairs(PT17) do
		L[key] = value
	end
end

--------------------------------------------------------------------------------
-- 0.18: the form's new header and footer, module options per profile, Save
-- to active profile
--------------------------------------------------------------------------------

local EN18 = {
	COPY_CURRENT = "Current",
	NP_COPY_LAYOUT_DESC = "Current: the layout in use and what the game shows now. Or another profile's layout and what it switches on. Nothing is kept until you save.",
	NP_COPY_MODULES_DESC = "Current: the modules and their options as they are now. Or another profile's. Ticks Change modules. Nothing is kept until you save.",
	NP_COPY_OPTIONS_DESC = "Current: this character's settings as they are now. Or another profile's. Ticks Apply own settings. Nothing is kept until you save.",
	NP_NEXT_DESC = "The next tab. A new profile goes through all three before it is saved.",
	NP_SAVE_APPLY_DESC = "Saves the profile and puts it on this character. The interface reloads when something needs it.",
	FORM_STEP = "New profile: tab %d of %d",
	FORM_NEW_READY = "Ready: Save and Apply puts it on this character.",
	POPUP_NP_SAVE_APPLY = "Save the profile \"%s\" and apply it to this character? The interface reloads if something needs it.",
	NP_NEW_FROM = "+ New: %s",
	NP_LAYOUTS_FULL_CELL = "No room for another layout",
	NP_NEW_CELL_TIP = "Click: a new account layout, copied from the one in use and named after the profile. Right click: copy another, a template or an import. It is made when you save.",
	FORM_CUSTOM_MODULES = "Change modules",
	FORM_CUSTOM_MODULES_DESC = "Ticked: the profile switches the modules on or off and sets their options when applied. Unticked: it leaves them as they are; what it had is kept.",
	FORM_MODULES_OFF = "Tick Change modules to set them for this profile.",
	SHORT_MODULE_OPTIONS = "%d module options",
	MSG_PROFILES_FULL = "There is room for %d profiles. Delete one first.",
	SHOW_GLOBAL = "Show global options",
	SHOW_GLOBAL_DESC = "Global options are hidden: they are shared by every character on the account. Click to show them.",
	HIDE_GLOBAL = "Hide global options",
	HIDE_GLOBAL_DESC = "Hides the options shared by every character on the account, and the pages that only have those. The search still finds them.",
	SAVE_TO_PROFILE = "Save to active profile",
	SAVE_TO_PROFILE_NONE = "No profile in use on this character.",
	SAVE_OPTIONS_DESC = "Saves this character's settings, with the changes waiting, into \"%s\" and ticks its Apply own settings. Changes waiting are applied too.",
	SAVE_MODULES_DESC = "Saves which modules are on, and their options, into \"%s\" and ticks its Change modules.",
	POPUP_APPLY_GAME = "Apply %d changes to the game? The interface reloads.",
	POPUP_SAVE_APPLY_GAME = "Save the settings into \"%s\" and apply the %d changes waiting? The interface reloads.",
	MSG_SAVED_OPTIONS = "Settings saved into \"%s\".",
	MSG_SAVED_MODULES = "Modules saved into \"%s\".",
	FORM_CHANGED = "Changes not saved yet",
}

local PT18 = {
	COPY_CURRENT = "Actual",
	NP_COPY_LAYOUT_DESC = "Actual: o layout em uso e o que o jogo mostra agora. Ou o layout de outro perfil e o que ele liga. Nada fica guardado até guardares.",
	NP_COPY_MODULES_DESC = "Actual: os módulos e as suas opções como estão agora. Ou os de outro perfil. Marca Alterar módulos. Nada fica guardado até guardares.",
	NP_COPY_OPTIONS_DESC = "Actual: as definições desta personagem como estão agora. Ou as de outro perfil. Marca Aplicar definições próprias. Nada fica guardado até guardares.",
	NP_NEXT_DESC = "A aba seguinte. Um perfil novo passa pelas três antes de ser guardado.",
	NP_SAVE_APPLY_DESC = "Guarda o perfil e põe-no nesta personagem. A interface recarrega quando é preciso.",
	FORM_STEP = "Perfil novo: aba %d de %d",
	FORM_NEW_READY = "Pronto: Guardar e aplicar põe-no nesta personagem.",
	POPUP_NP_SAVE_APPLY = "Guardar o perfil \"%s\" e aplicá-lo a esta personagem? A interface recarrega se for preciso.",
	NP_NEW_FROM = "+ Novo: %s",
	NP_LAYOUTS_FULL_CELL = "Não há espaço para mais layouts",
	NP_NEW_CELL_TIP = "Clique: um layout novo da conta, copiado do que está em uso e com o nome do perfil. Clique direito: copiar outro, um template ou importar. É criado quando guardares.",
	FORM_CUSTOM_MODULES = "Alterar módulos",
	FORM_CUSTOM_MODULES_DESC = "Marcada: o perfil liga ou desliga os módulos e acerta as opções deles ao ser aplicado. Desmarcada: deixa-os como estão; o que tinha fica guardado.",
	FORM_MODULES_OFF = "Marca Alterar módulos para os definir neste perfil.",
	SHORT_MODULE_OPTIONS = "%d opções de módulos",
	MSG_PROFILES_FULL = "Há espaço para %d perfis. Apaga um primeiro.",
	SHOW_GLOBAL = "Mostrar opções globais",
	SHOW_GLOBAL_DESC = "As opções globais estão escondidas: são partilhadas por todas as personagens da conta. Clica para as mostrar.",
	HIDE_GLOBAL = "Esconder opções globais",
	HIDE_GLOBAL_DESC = "Esconde as opções partilhadas por todas as personagens da conta, e as páginas que só têm dessas. A pesquisa continua a encontrá-las.",
	SAVE_TO_PROFILE = "Guardar no perfil activo",
	SAVE_TO_PROFILE_NONE = "Esta personagem não tem nenhum perfil em uso.",
	SAVE_OPTIONS_DESC = "Guarda as definições desta personagem, com as alterações por aplicar, em \"%s\" e marca Aplicar definições próprias. As alterações por aplicar também são aplicadas.",
	SAVE_MODULES_DESC = "Guarda os módulos ligados, e as opções deles, em \"%s\" e marca Alterar módulos.",
	POPUP_APPLY_GAME = "Aplicar %d alterações ao jogo? A interface recarrega.",
	POPUP_SAVE_APPLY_GAME = "Guardar as definições em \"%s\" e aplicar as %d alterações por aplicar? A interface recarrega.",
	MSG_SAVED_OPTIONS = "Definições guardadas em \"%s\".",
	MSG_SAVED_MODULES = "Módulos guardados em \"%s\".",
	FORM_CHANGED = "Alterações por guardar",
}

for key, value in pairs(EN18) do
	L[key] = value
end
if GetLocale() == "ptBR" then
	for key, value in pairs(PT18) do
		L[key] = value
	end
end

--------------------------------------------------------------------------------
-- 0.19
--------------------------------------------------------------------------------

local EN19 = {
	TAB_GAME = "Settings",
	MODULE_SWITCH_DESC = "On or off. The interface reloads to follow.",
	IMPORT_PROFILE = "Import profile",
	POPUP_IMPORT_PROFILE = "Paste a SetGo! profile:",
	POPUP_IMPORT_LAYOUT = "Paste a Blizzard Edit Mode layout:",
	MSG_USE_IMPORT_PROFILE = "That is a SetGo! profile: use Import profile on a free card of the Profiles list.",
	MSG_USE_IMPORT_LAYOUT = "That is a Blizzard layout: import it with right click on + New, on the Layout tab.",
	MSG_BAD_PROFILE = "That text is not a SetGo! profile.",
	MSG_IMPORT_NO_LAYOUT = "There is no room for another account layout: the imported profile uses the layout chosen on its Layout tab.",
	MSG_PROFILE_IMPORTED = "Profile \"%s\" read. Go through its tabs, then Save and Apply makes it.",
	POPUP_EXPORT_PROFILE = "The profile \"%s\" as text (name, icon, layout, action bars, UI elements and, when it changes them, its settings and modules). Copy it with Ctrl+C:",
	NP_NEW_CELL_TIP = "Click: a new account layout, copied from the one in use and named after the profile. Right click: copy another layout, a template, or import a Blizzard layout. It is made when you save.",
}

local PT19 = {
	TAB_GAME = "Definições",
	MODULE_SWITCH_DESC = "Ligado ou desligado. A interface recarrega para acompanhar.",
	IMPORT_PROFILE = "Importar perfil",
	POPUP_IMPORT_PROFILE = "Cola um perfil do SetGo!:",
	POPUP_IMPORT_LAYOUT = "Cola um layout do Edit Mode da Blizzard:",
	MSG_USE_IMPORT_PROFILE = "Isso é um perfil do SetGo!: usa Importar perfil num cartão livre da lista de Perfis.",
	MSG_USE_IMPORT_LAYOUT = "Isso é um layout da Blizzard: importa-o com o clique direito em + Novo, na aba Layout.",
	MSG_BAD_PROFILE = "Esse texto não é um perfil do SetGo!.",
	MSG_IMPORT_NO_LAYOUT = "Não há espaço para mais um layout da conta: o perfil importado usa o layout escolhido na aba Layout.",
	MSG_PROFILE_IMPORTED = "Perfil \"%s\" lido. Passa pelas abas e Guardar e aplicar cria-o.",
	POPUP_EXPORT_PROFILE = "O perfil \"%s\" em texto (nome, ícone, layout, barras de acção, elementos e, quando os altera, as definições e os módulos). Copia com Ctrl+C:",
	NP_NEW_CELL_TIP = "Clique: um layout novo da conta, copiado do que está em uso e com o nome do perfil. Clique direito: copiar outro layout, um template, ou importar um layout da Blizzard. É criado quando guardares.",
}

for key, value in pairs(EN19) do
	L[key] = value
end
if GetLocale() == "ptBR" then
	for key, value in pairs(PT19) do
		L[key] = value
	end
end

--------------------------------------------------------------------------------
-- 0.20: closing with something not saved
--------------------------------------------------------------------------------

local EN20 = {
	POPUP_UNSAVED = "There are changes not saved yet.",
	SAVE_AND_EXIT = "Save and Exit",
	EXIT_NO_SAVE = "Exit Without Saving",
}

local PT20 = {
	POPUP_UNSAVED = "Há alterações por guardar.",
	SAVE_AND_EXIT = "Guardar e sair",
	EXIT_NO_SAVE = "Sair sem guardar",
}

for key, value in pairs(EN20) do
	L[key] = value
end
if GetLocale() == "ptBR" then
	for key, value in pairs(PT20) do
		L[key] = value
	end
end

--------------------------------------------------------------------------------
-- 0.22: the Settings tab (Global or Profile), no more Game Settings
--------------------------------------------------------------------------------

local EN22 = {
	FORM_TAB_SETTINGS = "Settings",
	SCOPE_SETTINGS = "Character settings",
	SCOPE_KEYS = "Keybinds",
	SCOPE_BARS = "Action bars",
	SCOPE_GLOBAL = "Global",
	SCOPE_PROFILE = "Profile",
	SCOPE_GLOBAL_SETTINGS_DESC = "The shared settings: every profile set to Global uses the same ones, and a change made with any of them goes there.",
	SCOPE_GLOBAL_KEYS_DESC = "The shared keybinds: every profile set to Global uses the same ones, and a change made with any of them goes there.",
	SCOPE_GLOBAL_BARS_DESC = "Blizzard's own way: what sits on the action bars stays as it is when you switch profiles.",
	SCOPE_PROFILE_SETTINGS_DESC = "Settings of its own: changes made while it is in use go into this profile only.",
	SCOPE_PROFILE_KEYS_DESC = "Keybinds of its own: changes made while it is in use go into this profile only.",
	SCOPE_PROFILE_BARS_DESC = "Action bars of its own, per character and specialization: applying it puts them back.",
	SCOPE_COPY_SETTINGS_DESC = "Current: this character's settings as they are now. Or what another profile applies. Nothing is kept until you save.",
	SCOPE_COPY_KEYS_DESC = "Current: the keybinds as they are now. Or what another profile applies. Nothing is kept until you save.",
	SCOPE_COPY_BARS_DESC = "Current: the action bars as they are when it is applied. Or another profile's, on this character. Nothing is kept until you save.",
	SCOPE_GLOBAL_SETTINGS_NOTE = "Uses the shared settings.",
	SCOPE_GLOBAL_KEYS_NOTE = "Uses the shared keybinds.",
	SCOPE_GLOBAL_BARS_NOTE = "The action bars are left as they are.",
	SCOPE_PROFILE_SETTINGS_NOTE = "Its own: %d settings.",
	SCOPE_PROFILE_SETTINGS_EMPTY = "Its own: they start as the game has them when it is applied.",
	SCOPE_PROFILE_KEYS_NOTE = "Its own: %d keybinds.",
	SCOPE_PROFILE_BARS_NOTE = "Its own: kept for this character.",
	SCOPE_PROFILE_BARS_NEW = "Its own: they start as the bars are when it is applied.",
	SCOPE_COPIED = "Copied from: %s",
	MSG_SETTINGS_IN_PROFILE = "Settings saved into \"%s\".",
	MSG_SETTINGS_SHARED = "Settings saved into the shared ones (\"%s\" uses them).",
	MSG_KEYS_SHARED = "Keybinds saved into the shared ones (\"%s\" uses them).",
	POPUP_EXPORT_PROFILE = "The profile \"%s\" as text (name, icon, layout, action bars, UI elements and, when it has its own, its settings and modules). Copy it with Ctrl+C:",
	NP_NEXT_DESC = "The next tab. A new profile goes through all three before it is saved.",
}

local PT22 = {
	FORM_TAB_SETTINGS = "Definições",
	SCOPE_SETTINGS = "Definições da personagem",
	SCOPE_KEYS = "Atalhos de teclado",
	SCOPE_BARS = "Barras de acção",
	SCOPE_GLOBAL = "Global",
	SCOPE_PROFILE = "Perfil",
	SCOPE_GLOBAL_SETTINGS_DESC = "As definições partilhadas: todos os perfis em Global usam as mesmas, e uma alteração feita com qualquer um deles fica lá.",
	SCOPE_GLOBAL_KEYS_DESC = "Os atalhos partilhados: todos os perfis em Global usam os mesmos, e uma alteração feita com qualquer um deles fica lá.",
	SCOPE_GLOBAL_BARS_DESC = "Como a Blizzard faz: o que está nas barras de acção fica como está quando trocas de perfil.",
	SCOPE_PROFILE_SETTINGS_DESC = "Definições próprias: as alterações feitas enquanto está em uso ficam só neste perfil.",
	SCOPE_PROFILE_KEYS_DESC = "Atalhos próprios: as alterações feitas enquanto está em uso ficam só neste perfil.",
	SCOPE_PROFILE_BARS_DESC = "Barras de acção próprias, por personagem e especialização: aplicá-lo volta a pô-las.",
	SCOPE_COPY_SETTINGS_DESC = "Actual: as definições desta personagem como estão agora. Ou as que outro perfil aplica. Nada fica guardado até guardares.",
	SCOPE_COPY_KEYS_DESC = "Actual: os atalhos como estão agora. Ou os que outro perfil aplica. Nada fica guardado até guardares.",
	SCOPE_COPY_BARS_DESC = "Actual: as barras de acção como estiverem quando for aplicado. Ou as de outro perfil, nesta personagem. Nada fica guardado até guardares.",
	SCOPE_GLOBAL_SETTINGS_NOTE = "Usa as definições partilhadas.",
	SCOPE_GLOBAL_KEYS_NOTE = "Usa os atalhos partilhados.",
	SCOPE_GLOBAL_BARS_NOTE = "As barras de acção ficam como estão.",
	SCOPE_PROFILE_SETTINGS_NOTE = "Próprias: %d definições.",
	SCOPE_PROFILE_SETTINGS_EMPTY = "Próprias: começam como o jogo as tiver quando for aplicado.",
	SCOPE_PROFILE_KEYS_NOTE = "Próprios: %d atalhos.",
	SCOPE_PROFILE_BARS_NOTE = "Próprias: guardadas para esta personagem.",
	SCOPE_PROFILE_BARS_NEW = "Próprias: começam como as barras estiverem quando for aplicado.",
	SCOPE_COPIED = "Copiado de: %s",
	MSG_SETTINGS_IN_PROFILE = "Definições guardadas em \"%s\".",
	MSG_SETTINGS_SHARED = "Definições guardadas nas partilhadas (\"%s\" usa-as).",
	MSG_KEYS_SHARED = "Atalhos guardados nos partilhados (\"%s\" usa-os).",
	MSG_KEYS_IN_PRESET = "Atalhos guardados no perfil \"%s\".",
	POPUP_EXPORT_PROFILE = "O perfil \"%s\" em texto (nome, ícone, layout, barras de acção, elementos e, quando tem as suas, as definições e os módulos). Copia com Ctrl+C:",
	NP_NEXT_DESC = "A aba seguinte. Um perfil novo passa pelas três antes de ser guardado.",
}

for key, value in pairs(EN22) do
	L[key] = value
end
if GetLocale() == "ptBR" then
	for key, value in pairs(PT22) do
		L[key] = value
	end
end

--------------------------------------------------------------------------------
-- 0.23: page headers, Copy from on Global, the minimap button's click
--------------------------------------------------------------------------------

local EN23 = {
	SETGO_PAGE_DESC = "SetGo!'s own settings: the tab it opens on, the minimap button, its sounds and its key.",
	SCOPE_COPY_DEFAULT = "Copy from...",
	SCOPE_COPY_GLOBAL_NOTE = "On Global it replaces the shared set: every profile using Global gets it.",
	POPUP_COPY_GLOBAL = "This change will apply to all profiles using the Global option. Do you wish to continue?",
	SCOPE_GLOBAL_PENDING = "Uses the shared set: the copy replaces it when you save.",
	SHORT_BARS_COPIED = "Copied action bars",
	SAVE_AND_EXIT = "Apply and Exit",
	MENU_CONFIGURE = "Configure",
	MINIMAP_TIP_MODULE = "Left click: %s\nShift+click: SetGo!\nRight click: menu",
}

local PT23 = {
	SETGO_PAGE_DESC = "As definições do próprio SetGo!: a aba onde abre, o botão do minimapa, os sons e a tecla.",
	SCOPE_COPY_DEFAULT = "Copiar de...",
	SCOPE_COPY_GLOBAL_NOTE = "Em Global substitui o conjunto partilhado: todos os perfis que usam Global ficam com ele.",
	POPUP_COPY_GLOBAL = "Esta alteração aplica-se a todos os perfis que usam a opção Global. Queres continuar?",
	SCOPE_GLOBAL_PENDING = "Usa o conjunto partilhado: a cópia substitui-o quando guardares.",
	SHORT_BARS_COPIED = "Barras de acção copiadas",
	SAVE_AND_EXIT = "Aplicar e sair",
	MENU_CONFIGURE = "Configurar",
	MINIMAP_TIP_MODULE = "Clique esquerdo: %s\nShift+clique: SetGo!\nClique direito: menu",
}

for key, value in pairs(EN23) do
	L[key] = value
end
if GetLocale() == "ptBR" then
	for key, value in pairs(PT23) do
		L[key] = value
	end
end
