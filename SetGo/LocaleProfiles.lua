local _, ns = ...
local L = ns.L

--------------------------------------------------------------------------------
-- Strings for profiles (0.14 on), and the older strings that said "preset".
--------------------------------------------------------------------------------

local EN = {

	TAB_PRESETS = "Profiles",
	YOUR_PRESETS = "Profiles",
	NEW_PRESET = "New profile",
	CRUMB_PRESET = "Profile: %s",
	PRESET_APPLY = "Apply",
	POPUP_UPRESET_APPLY = "Apply the profile \"%s\" to this character? The interface reloads if settings change.",
	DIFF_LAYOUT_GONE = "Its Edit Mode layout no longer exists. Edit the profile to pick another.",
	DIFF_UI_ON = "%s: on",
	DIFF_UI_OFF = "%s: off",
	DIFF_SKILLS = "%d action bar slots",
	PROFILE_MATCHES = "This character matches the profile.",
	NONE = "None",
	COPY = "Copy",
	COPY_NAME = "%s (copy)",
	MSG_SKILLS_RESTORED = "%d action bar slots put back.",
	MSG_SKILLS_FAILED = "%d action bar slots could not be put back: spells not known here, or macros and items no longer there.",
	MSG_UI_REAPPLIED = "Account-wide elements set as the profile \"%s\" has them.",
	NP_UNDO_DESC = "Puts the form back as it was.",
	MSG_NAME_EMPTY = "The profile needs a name.",
	MSG_NAME_TAKEN = "There is already a profile called \"%s\".",
	MSG_SAVED = "\"%s\" saved.",
	MSG_DELETED = "\"%s\" deleted.",
	MSG_KEYS_IN_PRESET = "Keys saved in the profile \"%s\".",
	POPUP_DELETE = "Delete the profile \"%s\"? Its Edit Mode layout stays.",
	POPUP_DELETE_LAYOUT = "Delete the profile \"%s\"? Its Edit Mode layout \"%s\" is deleted too: SetGo! made it for this profile and no other uses it.",
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
	IMPORTED = "Imported",
	SHORT_LAYOUT = "Layout: %s",
	SHORT_LAYOUT_GONE = "Layout missing",
	SHORT_ON = "%s: on",
	SHORT_OFF = "%s: off",
	SHORT_OPTIONS = "%d options",
	STATE_ON = "On",
	STATE_OFF = "Off",
	SHORT_KEYS = "%d keybinds",
	DIFF_KEYS = "%d keybinds",
}


local PT = {

	TAB_PRESETS = "Perfis",
	YOUR_PRESETS = "Perfis",
	NEW_PRESET = "Novo perfil",
	CRUMB_PRESET = "Perfil: %s",
	PRESET_APPLY = "Aplicar",
	POPUP_UPRESET_APPLY = "Aplicar o perfil \"%s\" a esta personagem? A interface recarrega se mudarem definições.",
	DIFF_LAYOUT_GONE = "O layout do Edit Mode já não existe. Edita o perfil para escolheres outro.",
	DIFF_UI_ON = "%s: ligado",
	DIFF_UI_OFF = "%s: desligado",
	DIFF_SKILLS = "%d espaços das barras de acção",
	PROFILE_MATCHES = "Esta personagem está igual ao perfil.",
	NONE = "Nenhum",
	COPY = "Copiar",
	COPY_NAME = "%s (cópia)",
	MSG_SKILLS_RESTORED = "%d espaços das barras de acção repostos.",
	MSG_SKILLS_FAILED = "%d espaços das barras de acção não foram repostos: feitiços que esta personagem não conhece, ou macros e itens que já não existem.",
	MSG_UI_REAPPLIED = "Elementos da conta acertados pelo perfil \"%s\".",
	NP_UNDO_DESC = "Põe o formulário como estava.",
	MSG_NAME_EMPTY = "O perfil precisa de um nome.",
	MSG_NAME_TAKEN = "Já existe um perfil chamado \"%s\".",
	MSG_SAVED = "\"%s\" guardado.",
	MSG_DELETED = "\"%s\" apagado.",
	POPUP_DELETE = "Apagar o perfil \"%s\"? O layout do Edit Mode fica.",
	POPUP_DELETE_LAYOUT = "Apagar o perfil \"%s\"? O layout do Edit Mode \"%s\" também é apagado: o SetGo! criou-o para este perfil e nenhum outro o usa.",
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
	IMPORTED = "Importado",
	NP_NEW_CELL = "+ Novo",
	EXPORT = "Exportar",
	SHORT_LAYOUT = "Layout: %s",
	SHORT_LAYOUT_GONE = "Layout em falta",
	SHORT_ON = "%s: ligar",
	SHORT_OFF = "%s: desligar",
	SHORT_OPTIONS = "%d opções",
	STATE_ON = "Ligado",
	STATE_OFF = "Desligado",
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
	FORM_TAB_LAYOUT = "Layout",
	FORM_TAB_MODULES = "Modules",
	FORM_TAB_OPTIONS = "Options",
	NP_COPY_PROFILE = "Copy from",
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
	WELCOME_START_DESC = "Opens SetGo! on a new profile, with tips that walk you through it.",
	WELCOME_PICK = "Apply one of your profiles:",
	WELCOME_CHOOSE = "Choose a profile",
	HELLO_FULL_DESC = "Opens SetGo!.",
}

local PT17 = {
	PANEL_DESC = "Configuração rápida da interface da Blizzard: perfis com um layout do Edit Mode, o que ligam, módulos, teclas, barras de acção e, se quiseres, definições próprias da personagem, para usares em todas as tuas personagens.",
	FORM_TAB_LAYOUT = "Layout",
	FORM_TAB_MODULES = "Módulos",
	FORM_TAB_OPTIONS = "Opções",
	NP_COPY_PROFILE = "Copiar de",
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
	WELCOME_START_DESC = "Abre o SetGo! num perfil novo, com dicas que te levam passo a passo.",
	WELCOME_PICK = "Aplica um dos teus perfis:",
	WELCOME_CHOOSE = "Escolhe um perfil",
	HELLO_FULL_DESC = "Abre o SetGo!.",
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
	NP_SAVE_APPLY_DESC = "Saves the profile and puts it on this character. The interface reloads when something needs it.",
	FORM_STEP = "New profile: tab %d of %d",
	POPUP_NP_SAVE_APPLY = "Save the profile \"%s\" and apply it to this character? The interface reloads if something needs it.",
	NP_NEW_FROM = "+ New: %s",
	NP_LAYOUTS_FULL_CELL = "No room for another layout",
	FORM_CUSTOM_MODULES = "Change modules",
	FORM_CUSTOM_MODULES_DESC = "This profile switches the modules on or off and sets their options.",
	FORM_MODULES_OFF = "Tick Change modules to set them for this profile.",
	SHORT_MODULE_OPTIONS = "%d module options",
	MSG_PROFILES_FULL = "There is room for %d profiles. Delete one first.",
	SAVE_TO_PROFILE = "Save to active profile",
	SAVE_TO_PROFILE_NONE = "No profile in use on this character.",
	SAVE_MODULES_DESC = "Saves which modules are on, and their options, into \"%s\" and ticks its Change modules.",
	POPUP_APPLY_GAME = "Apply %d changes to the game? The interface reloads.",
	MSG_SAVED_MODULES = "Modules saved into \"%s\".",
	FORM_CHANGED = "Changes not saved yet",
}

local PT18 = {
	COPY_CURRENT = "Actual",
	NP_COPY_LAYOUT_DESC = "Actual: o layout em uso e o que o jogo mostra agora. Ou o layout de outro perfil e o que ele liga. Nada fica guardado até guardares.",
	NP_COPY_MODULES_DESC = "Actual: os módulos e as suas opções como estão agora. Ou os de outro perfil. Marca Alterar módulos. Nada fica guardado até guardares.",
	NP_COPY_OPTIONS_DESC = "Actual: as definições desta personagem como estão agora. Ou as de outro perfil. Marca Aplicar definições próprias. Nada fica guardado até guardares.",
	NP_SAVE_APPLY_DESC = "Guarda o perfil e põe-no nesta personagem. A interface recarrega quando é preciso.",
	FORM_STEP = "Perfil novo: aba %d de %d",
	POPUP_NP_SAVE_APPLY = "Guardar o perfil \"%s\" e aplicá-lo a esta personagem? A interface recarrega se for preciso.",
	NP_NEW_FROM = "+ Novo: %s",
	NP_LAYOUTS_FULL_CELL = "Não há espaço para mais layouts",
	FORM_CUSTOM_MODULES = "Alterar módulos",
	FORM_CUSTOM_MODULES_DESC = "Este perfil liga ou desliga os módulos e acerta as opções deles.",
	FORM_MODULES_OFF = "Marca Alterar módulos para os definir neste perfil.",
	SHORT_MODULE_OPTIONS = "%d opções de módulos",
	MSG_PROFILES_FULL = "Há espaço para %d perfis. Apaga um primeiro.",
	SAVE_TO_PROFILE = "Guardar no perfil activo",
	SAVE_TO_PROFILE_NONE = "Esta personagem não tem nenhum perfil em uso.",
	SAVE_MODULES_DESC = "Guarda os módulos ligados, e as opções deles, em \"%s\" e marca Alterar módulos.",
	POPUP_APPLY_GAME = "Aplicar %d alterações ao jogo? A interface recarrega.",
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
	MSG_PROFILE_IMPORTED = "Profile \"%s\" read. Go through its tabs, then Save and Apply makes it.",
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
	MSG_PROFILE_IMPORTED = "Perfil \"%s\" lido. Passa pelas abas e Guardar e aplicar cria-o.",
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
	EXIT_NO_SAVE = "Exit Without Saving",
}

local PT20 = {
	POPUP_UNSAVED = "Há alterações por guardar.",
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
	SCOPE_GLOBAL = "Global",
	SCOPE_PROFILE = "Profile",
	SCOPE_GLOBAL_SETTINGS_DESC = "Uses the shared settings.",
	SCOPE_GLOBAL_KEYS_DESC = "Uses the shared keybinds.",
	SCOPE_GLOBAL_BARS_DESC = "Leaves your action bars as they are.",
	SCOPE_PROFILE_SETTINGS_DESC = "Uses settings of its own.",
	SCOPE_PROFILE_KEYS_DESC = "Uses keybinds of its own.",
	SCOPE_PROFILE_BARS_DESC = "Remembers your action bars and puts them back.",
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
	MSG_SETTINGS_IN_PROFILE = "Settings saved into \"%s\".",
	MSG_SETTINGS_SHARED = "Settings saved into the shared ones (\"%s\" uses them).",
	MSG_KEYS_SHARED = "Keybinds saved into the shared ones (\"%s\" uses them).",
}

local PT22 = {
	FORM_TAB_SETTINGS = "Definições",
	SCOPE_SETTINGS = "Definições da personagem",
	SCOPE_KEYS = "Atalhos de teclado",
	SCOPE_GLOBAL = "Global",
	SCOPE_PROFILE = "Perfil",
	SCOPE_GLOBAL_SETTINGS_DESC = "Usa as definições partilhadas.",
	SCOPE_GLOBAL_KEYS_DESC = "Usa os atalhos partilhados.",
	SCOPE_GLOBAL_BARS_DESC = "Deixa as barras de acção como estão.",
	SCOPE_PROFILE_SETTINGS_DESC = "Usa definições próprias.",
	SCOPE_PROFILE_KEYS_DESC = "Usa atalhos próprios.",
	SCOPE_PROFILE_BARS_DESC = "Lembra-se das barras de acção e repõe-nas.",
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
	MSG_SETTINGS_IN_PROFILE = "Definições guardadas em \"%s\".",
	MSG_SETTINGS_SHARED = "Definições guardadas nas partilhadas (\"%s\" usa-as).",
	MSG_KEYS_SHARED = "Atalhos guardados nos partilhados (\"%s\" usa-os).",
	MSG_KEYS_IN_PRESET = "Atalhos guardados no perfil \"%s\".",
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

--------------------------------------------------------------------------------
-- 0.24: the first profile's guide, Import on the profile's header, the
-- reload mark
--------------------------------------------------------------------------------

local EN24 = {
	WIZ_BACK = "Back",
	WIZ_PRESET_TIP = "Click to apply this preset. You are asked first.",
	RELOAD_LEGEND = "* These changes require a reload.",
	IMPORT_PROFILE_DESC = "Paste a profile someone shared with you. It opens as a new profile; nothing is kept until you save.",
}

local PT24 = {
	WIZ_BACK = "Voltar",
	WIZ_PRESET_TIP = "Clica para aplicar este preset. Pergunta primeiro.",
	RELOAD_LEGEND = "* Estas alterações obrigam a recarregar.",
	IMPORT_PROFILE_DESC = "Cola um perfil que alguém partilhou contigo. Abre como um perfil novo; nada fica guardado até guardares.",
}

for key, value in pairs(EN24) do
	L[key] = value
end
if GetLocale() == "ptBR" then
	for key, value in pairs(PT24) do
		L[key] = value
	end
end

--------------------------------------------------------------------------------
-- 0.25: the guide's texts, the presets, Bar Slots, the Quick Menu in the core
--------------------------------------------------------------------------------

local EN25 = {
	WIZ_PRESETS_TITLE = "SetGo! Presets",
	PRESET_FOREVER_DESC = "The classic UI we know and love, two bars wide, enhanced by the SetGo! modules.",
	PRESET_BFA_DESC = "A familiar look, one and a half bars wide, with three bars centered and the bags and the micro menu pushed to the side. A good balance between a minimal look and bar space.",
	PRESET_RETAIL_DESC = "A more minimal-looking UI, one bar wide, for a cleaner and more immersive gameplay experience.",
	SCOPE_BARS = "Bar Slots",
	SHORT_BARS_COPIED = "Copied bar slots",
	POPUP_EXPORT_PROFILE = "The profile \"%s\" as text: name, icon, layout, the action bars and Blizzard frames it shows, and its modules. Character settings, keybinds and bar slots stay with you. Copy it with Ctrl+C:",
	IMPORT_REPLACE_DESC = "Paste a profile someone shared with you. It replaces this profile's layout, what it shows and its modules (its name stays); nothing is kept until you save.",
	POPUP_IMPORT_REPLACE = "The imported profile replaces the layout, what it shows and the modules of \"%s\". Nothing is kept until you save. Continue?",
	MSG_OLD_QUICK = "Quick! is now part of SetGo! (the Quick Menu). The SetGo_Quick folder in your AddOns is no longer used: you can delete it.",
	TOUR_STEP = "%d of %d",
	TOUR_BUTTON = "Show the tour",
	MSG_TOUR_NONE = "The tour can't show here.",
}

local PT25 = {
	WIZ_PRESETS_TITLE = "Presets do SetGo!",
	PRESET_FOREVER_DESC = "A interface clássica que conhecemos e adoramos, com duas barras de largura, melhorada pelos módulos do SetGo!.",
	PRESET_BFA_DESC = "Um visual familiar, com barra e meia de largura: três barras ao centro e os sacos e o micro menu encostados ao lado. Um bom equilíbrio entre um visual minimalista e espaço para barras.",
	PRESET_RETAIL_DESC = "Uma interface mais minimalista, com uma barra de largura, para uma experiência de jogo mais limpa e imersiva.",
	SCOPE_BARS = "Conteúdo das barras",
	SHORT_BARS_COPIED = "Conteúdo das barras copiado",
	POPUP_EXPORT_PROFILE = "O perfil \"%s\" em texto: nome, ícone, layout, as barras de acção e janelas da Blizzard que mostra, e os módulos. As definições da personagem, os atalhos e o conteúdo das barras ficam contigo. Copia com Ctrl+C:",
	IMPORT_REPLACE_DESC = "Cola um perfil que alguém partilhou contigo. Substitui o layout, o que mostra e os módulos deste perfil (o nome fica); nada fica guardado até guardares.",
	POPUP_IMPORT_REPLACE = "O perfil importado substitui o layout, o que mostra e os módulos de \"%s\". Nada fica guardado até guardares. Continuar?",
	MSG_OLD_QUICK = "O Quick! faz agora parte do SetGo! (o Menu rápido). A pasta SetGo_Quick nos teus AddOns já não é usada: podes apagá-la.",
	TOUR_STEP = "%d de %d",
	TOUR_BUTTON = "Ver o tour",
	MSG_TOUR_NONE = "O tour não pode aparecer aqui.",
}

for key, value in pairs(EN25) do
	L[key] = value
end
if GetLocale() == "ptBR" then
	for key, value in pairs(PT25) do
		L[key] = value
	end
end

--------------------------------------------------------------------------------
-- 0.27: a profile keeps its layout; one SetGo! layout per character
--------------------------------------------------------------------------------

local EN27 = {
	DIFF_LAYOUT_TO = "Edit Mode layout: %s",
	MSG_LAYOUT_RECORDED = "Edit Mode layout saved in \"%s\".",
	MSG_SLOT_FULL = "The layout wasn't put on: this character already has %d character layouts. Delete one in Edit Mode.",
	MSG_LAYOUT_MISSING = "The Edit Mode layout of \"%s\" couldn't be read. The rest was applied; edit the profile to pick a layout.",
	POPUP_LAYOUT_UPDATE = "The Edit Mode layout of \"%s\" was changed on another character. Update it here? The interface reloads.",
	LAYOUT_UPDATE_BUTTON = "Update",
	POPUP_NEW_LAYOUT_NOTE = "The interface reloads and Edit Mode opens after it, to place everything.",
	WIZ_POPUP_PRESET = "Apply the preset \"%s\"?\n\nThe interface reloads.",
}

local PT27 = {
	DIFF_LAYOUT_TO = "Layout do Edit Mode: %s",
	MSG_LAYOUT_RECORDED = "Layout do Edit Mode guardado em \"%s\".",
	MSG_SLOT_FULL = "O layout não foi aplicado: esta personagem já tem %d layouts de personagem. Apaga um no Edit Mode.",
	MSG_LAYOUT_MISSING = "Não foi possível ler o layout do Edit Mode de \"%s\". O resto foi aplicado; edita o perfil para escolheres um layout.",
	POPUP_LAYOUT_UPDATE = "O layout do Edit Mode de \"%s\" foi alterado noutra personagem. Actualizar aqui? A interface recarrega.",
	LAYOUT_UPDATE_BUTTON = "Actualizar",
	POPUP_NEW_LAYOUT_NOTE = "A interface recarrega e depois abre o Edit Mode, para arrumares tudo.",
	WIZ_POPUP_PRESET = "Aplicar o preset \"%s\"?\n\nA interface recarrega.",
}

for key, value in pairs(EN27) do
	L[key] = value
end
if GetLocale() == "ptBR" then
	for key, value in pairs(PT27) do
		L[key] = value
	end
end

--------------------------------------------------------------------------------
-- 0.29: the presets menu (a new profile and the guide)
--------------------------------------------------------------------------------

local EN29 = {
	PRESETS_BLIZZARD = "Blizzard layouts",
	PRESETS_SETGO = "SetGo! presets",
	PRESET_BLIZZARD_TIP = "Blizzard's own layout. Your settings, keybinds and bar slots stay Global, and the modules are switched off. You are asked first.",
}

local PT29 = {
	PRESETS_BLIZZARD = "Layouts da Blizzard",
	PRESETS_SETGO = "Presets do SetGo!",
	PRESET_BLIZZARD_TIP = "O layout de origem da Blizzard. As definições, os atalhos e o conteúdo das barras ficam em Global, e os módulos desligados. Pergunta primeiro.",
}

for key, value in pairs(EN29) do
	L[key] = value
end
if GetLocale() == "ptBR" then
	for key, value in pairs(PT29) do
		L[key] = value
	end
end

--------------------------------------------------------------------------------
-- 0.30: export with settings and keybinds; other addons' profiles (Ace3)
--------------------------------------------------------------------------------

local EN30 = {
	MSG_IMPORT_SKIPPED = "%d character settings in this code don't exist in this version of the game and were left out.",
	FORM_TAB_ADDONS = "Addons",
	ACE_KEEP = "Don't change",
	ACE_TIP = "The profile this addon switches to when this profile is applied. Don't change: it keeps the one it has.",
	SHORT_ACE = "%d addon profiles",
	MSG_ACE_MISSING = "%s has no profile called \"%s\" on this character: left as it is.",
}

local PT30 = {
	MSG_IMPORT_SKIPPED = "%d definições da personagem deste código não existem nesta versão do jogo e ficaram de fora.",
	FORM_TAB_ADDONS = "Addons",
	ACE_KEEP = "Não mudar",
	ACE_TIP = "O perfil para onde este addon muda quando este perfil é aplicado. Não mudar: fica com o que tem.",
	SHORT_ACE = "%d perfis de addons",
	MSG_ACE_MISSING = "%s não tem nenhum perfil chamado \"%s\" nesta personagem: ficou como estava.",
}

for key, value in pairs(EN30) do
	L[key] = value
end
if GetLocale() == "ptBR" then
	for key, value in pairs(PT30) do
		L[key] = value
	end
end

--------------------------------------------------------------------------------
-- 0.32: which addons are on, per profile
--------------------------------------------------------------------------------

local EN32 = {
	FORM_CUSTOM_ADDONS = "Change addons *",
	FORM_CUSTOM_ADDONS_DESC = "This profile switches your other addons on or off.",
	ADDON_SWITCH_DESC = "On or off with this profile, on this character.",
	ADDON_DEPS = "Dependencies: ",
	ADDONS_NONE = "No other addons installed.",
	SHORT_ADDONS = "%d addons on or off",
	ADDON_VERSION = "Version %s",
	ADDON_AUTHOR = "by %s",
	ADDON_OUTDATED = "Out of date",
	ADDON_CHILDREN = "%d addons that go with it. Its box switches them too.",
	ADDON_PROFILE = "Profile: %s",
	ADDON_MORE = "%s %d addons",
	MSG_IMPORT_NO_LAYOUT = "The layout in this code doesn't load in this version of the game. Everything else was imported: pick a layout on the Layout tab.",
	IMPORT_PART_DESC = "Ticked: if the code has them, they come in as this profile's own. Unticked: left out, and the profile keeps the ones it uses.",
}

local PT32 = {
	FORM_CUSTOM_ADDONS = "Alterar addons *",
	FORM_CUSTOM_ADDONS_DESC = "Este perfil liga ou desliga os teus outros addons.",
	ADDON_SWITCH_DESC = "Ligado ou desligado com este perfil, nesta personagem.",
	ADDON_DEPS = "Dependências: ",
	ADDONS_NONE = "Não há outros addons instalados.",
	SHORT_ADDONS = "%d addons ligados ou desligados",
	ADDON_VERSION = "Versão %s",
	ADDON_AUTHOR = "por %s",
	ADDON_OUTDATED = "Desactualizado",
	ADDON_CHILDREN = "%d addons que vão com este. A caixa deste também os liga e desliga.",
	ADDON_PROFILE = "Perfil: %s",
	ADDON_MORE = "%s %d addons",
	MSG_IMPORT_NO_LAYOUT = "O layout deste código não carrega nesta versão do jogo. O resto foi importado: escolhe um layout na aba Layout.",
	IMPORT_PART_DESC = "Marcado: se o código as tiver, entram como as próprias deste perfil. Desmarcado: ficam de fora e o perfil fica com as que usa.",
}

for key, value in pairs(EN32) do
	L[key] = value
end
if GetLocale() == "ptBR" then
	for key, value in pairs(PT32) do
		L[key] = value
	end
end

--------------------------------------------------------------------------------
-- 0.11: the presets menu (Current configuration, Apply, Customize), the
-- first profile's tips on the form itself, the info buttons
--------------------------------------------------------------------------------

local EN11 = {
	PRESET_CURRENT = "Current configuration",
	PRESET_CURRENT_DESC = "A profile of your interface as it is now: the layout in use, what shows and your modules. Your settings, keybinds and bars stay Global.",
	MY_PROFILE = "My Profile %d",
	PRESETS_PICK_NOTE = "Pick one, then Apply or Customize.",
	PRESET_APPLY_DESC = "Makes the one picked into a profile and puts it on this character. You are asked first; the interface reloads.",
	CUSTOMIZE_DESC = "Opens the profile's tabs with the one picked filled in, to change it before it is saved.",
	WIZ_CUSTOM = "Customize",
	WIZ_PRESETS_SUB = "Pick a preset, or Current configuration to start from what you have now. Apply makes it a profile at once; Customize lets you change it first.",
	NP_NEXT_DESC = "The next tab. Save and Apply works from any tab.",
	GUIDE_SLOT = "Click here to create a profile.",
	GUIDE_PRESETS = "Choose a preset, then click Apply, or Customize to make it your own.",
	GUIDE_NAME = "Give your profile a name and an icon.",
	GUIDE_LAYOUT = "Choose a layout, or create a new one.",
	GUIDE_BARS = "Choose which action bars are visible in this layout.",
	GUIDE_FRAMES = "Choose which Blizzard frames are visible.",
	GUIDE_TO_SETTINGS = "Click Next to set up your settings.",
	GUIDE_SETTINGS = "For each part, choose Global, one set shared by every profile set to Global, or Profile, a set of this profile's own.",
	GUIDE_TO_MODULES = "Click Next to set up your modules.",
	GUIDE_MODULES = "Choose which modules are active in this profile and set up their options.",
	GUIDE_TO_ADDONS = "Click Next to set up your addons.",
	GUIDE_ADDONS = "Choose which addons are active in this profile and which profile each one uses.",
	TOUR_QUICK = "Click to open the Quick Menu. Right-click to switch between your favorite profiles. Shift+click to open SetGo!.",
	TOUR_BUTTON_DESC = "Blizzard's help tips that walk you through making a profile, one at a time.",
	MSG_GUIDE_FULL = "There is no free profile slot to show the guide on: delete a profile first.",
	INFO_SETTINGS = "Character settings are the options in Blizzard's Options window that belong to this character.\n\nGlobal: one set shared by every profile set to Global. What you change in Blizzard's Options goes into it.\n\nProfile: this profile keeps a set of its own. Applying the profile puts it on, and what you change while it is in use is saved into it.\n\nGoing back to Global doesn't delete the profile's own set.",
	INFO_KEYS = "Keybinds are the keys set in Blizzard's Keybindings menu.\n\nGlobal: one set shared by every profile set to Global. What you save in the Keybindings menu goes into it.\n\nProfile: this profile keeps keys of its own. Applying the profile puts them on, and what you save while it is in use is saved into it.\n\nGoing back to Global doesn't delete the profile's own keys.",
	INFO_BARS = "Bar slots are what sits on your action bars: spells, items and macros.\n\nGlobal: the game's usual way. SetGo! doesn't touch your bars.\n\nProfile: this profile remembers your bars, per character and specialization, and puts them back when it is applied. What you change on the bars while it is in use is saved into it.",
	INFO_MODULES = "Ticked: applying this profile switches the modules on or off and sets their options as shown here.\n\nUnticked: applying it leaves the modules as they are. What the profile had is kept, not deleted.",
	INFO_ADDONS = "Ticked: applying this profile switches your other addons on or off on this character, as the game's addon list does. It takes a reload. Addons installed later are left as they are.\n\nAddons made with Ace3 can also switch to one of their own profiles. Don't change leaves them as they are; this works even with the box unticked.",
}

local PT11 = {
	PRESET_CURRENT = "Configuração actual",
	PRESET_CURRENT_DESC = "Um perfil da tua interface tal como está agora: o layout em uso, o que aparece e os teus módulos. As definições, os atalhos e as barras ficam em Global.",
	MY_PROFILE = "O meu perfil %d",
	PRESETS_PICK_NOTE = "Escolhe um, e depois Aplicar ou Personalizar.",
	PRESET_APPLY_DESC = "Faz do escolhido um perfil e põe-no nesta personagem. Pergunta primeiro; a interface recarrega.",
	CUSTOMIZE_DESC = "Abre as abas do perfil já preenchidas com o escolhido, para o mudares antes de o guardar.",
	WIZ_CUSTOM = "Personalizar",
	WIZ_PRESETS_SUB = "Escolhe um preset, ou Configuração actual para começares do que tens agora. Aplicar faz logo dele um perfil; Personalizar deixa-te mudá-lo primeiro.",
	NP_NEXT_DESC = "A aba seguinte. Guardar e aplicar funciona em qualquer aba.",
	GUIDE_SLOT = "Clica aqui para criar um perfil.",
	GUIDE_PRESETS = "Escolhe um preset e clica em Aplicar, ou em Personalizar para o fazeres teu.",
	GUIDE_NAME = "Dá um nome e um ícone ao teu perfil.",
	GUIDE_LAYOUT = "Escolhe um layout, ou cria um novo.",
	GUIDE_BARS = "Escolhe que barras de acção aparecem neste layout.",
	GUIDE_FRAMES = "Escolhe que janelas da Blizzard aparecem.",
	GUIDE_TO_SETTINGS = "Clica em Seguinte para configurares as definições.",
	GUIDE_SETTINGS = "Para cada parte, escolhe Global, um conjunto partilhado por todos os perfis em Global, ou Perfil, um conjunto só deste perfil.",
	GUIDE_TO_MODULES = "Clica em Seguinte para configurares os módulos.",
	GUIDE_MODULES = "Escolhe que módulos ficam activos neste perfil e configura as opções de cada um.",
	GUIDE_TO_ADDONS = "Clica em Seguinte para configurares os addons.",
	GUIDE_ADDONS = "Escolhe que addons ficam activos neste perfil e que perfil usa cada um.",
	TOUR_QUICK = "Clica para abrir o Quick Menu. Clique direito para trocar entre os teus perfis favoritos. Shift+clique para abrir o SetGo!.",
	TOUR_BUTTON_DESC = "As dicas da Blizzard que te levam, uma a uma, pela criação de um perfil.",
	MSG_GUIDE_FULL = "Não há nenhum espaço livre para mostrar o guia: apaga primeiro um perfil.",
	INFO_SETTINGS = "As definições da personagem são as opções da janela de Opções da Blizzard que pertencem a esta personagem.\n\nGlobal: um conjunto partilhado por todos os perfis em Global. O que mudas nas Opções da Blizzard vai para ele.\n\nPerfil: este perfil tem um conjunto só seu. Aplicar o perfil põe-no, e o que mudas enquanto está em uso fica gravado nele.\n\nVoltar a Global não apaga o conjunto próprio do perfil.",
	INFO_KEYS = "Os atalhos são as teclas do menu de Atalhos de teclado da Blizzard.\n\nGlobal: um conjunto partilhado por todos os perfis em Global. O que guardas no menu de atalhos vai para ele.\n\nPerfil: este perfil tem teclas só suas. Aplicar o perfil põe-nas, e o que guardas enquanto está em uso fica gravado nele.\n\nVoltar a Global não apaga as teclas próprias do perfil.",
	INFO_BARS = "O conteúdo das barras é o que está nas tuas barras de acção: feitiços, itens e macros.\n\nGlobal: o comportamento normal do jogo. O SetGo! não mexe nas tuas barras.\n\nPerfil: este perfil lembra-se das tuas barras, por personagem e especialização, e repõe-nas quando é aplicado. O que mudas nas barras enquanto está em uso fica gravado nele.",
	INFO_MODULES = "Marcado: aplicar este perfil liga ou desliga os módulos e acerta as opções como estão aqui.\n\nDesmarcado: aplicá-lo deixa os módulos como estão. O que o perfil tinha fica guardado, não é apagado.",
	INFO_ADDONS = "Marcado: aplicar este perfil liga ou desliga os outros addons nesta personagem, como a lista de addons do jogo. Obriga a recarregar. Os addons instalados depois ficam como estão.\n\nOs addons feitos com Ace3 também podem mudar para um dos seus perfis. Não mudar deixa-os como estão; isto funciona mesmo com a caixa desmarcada.",
}

for key, value in pairs(EN11) do
	L[key] = value
end
if GetLocale() == "ptBR" then
	for key, value in pairs(PT11) do
		L[key] = value
	end
end

--------------------------------------------------------------------------------
-- 0.11: backup
--------------------------------------------------------------------------------

local ENB = {
	BACKUP_CREATE_DESC = "Keeps a backup of your setup in the game: profiles, SetGo!'s options, account settings, Edit Mode layouts and macros. The game keeps the last five. Your action bars and other addons aren't in it.",
	BACKUP_ENTRY = "%s (%s)",
	BACKUP_LAST = "Last backup: %s",
	BACKUP_NONE = "No backups yet",
	BACKUP_APPLY = "Apply backup",
	BACKUP_APPLY_DESC = "Brings back the ticked parts of the backup picked, in place of what you have now. You are asked first; the interface reloads.",
	BACKUP_EXPORT = "Export backup",
	BACKUP_EXPORT_DESC = "Shows the code of the backup picked, to copy and keep in a file.",
	BACKUP_IMPORT = "Import code",
	BACKUP_IMPORT_DESC = "Paste a backup code: it joins the backups kept in the game, to apply from there.",
	BACKUP_DELETE = "Delete backup",
	BACKUP_DELETE_DESC = "Deletes the backup picked from the game. A code you exported still works.",
	POPUP_BACKUP_DELETE = "Delete the backup %s?",
	MSG_BACKUP_CREATED = "Backup made: %s.",
	MSG_BACKUP_IMPORTED = "Backup imported: %s.",
	BACKUP_TITLE = "Backup",
	BACKUP_NOTE = "Backups of your whole setup, kept in the game: profiles, SetGo!'s options, account settings, Edit Mode layouts and macros. Export one to keep its code in a file.",
	BACKUP_CREATE = "Create backup",
	BACKUP_PART_PROFILES = "Profiles",
	BACKUP_PART_OPTIONS = "SetGo! and Quick Menu options",
	BACKUP_PART_ACCOUNT = "Account settings",
	BACKUP_PART_LAYOUTS = "Account Edit Mode layouts",
	BACKUP_PART_MACROS = "Macros",
	BACKUP_HAS_PROFILES = "%d profiles (they replace yours)",
	BACKUP_HAS_ACCOUNT = "%d account settings",
	BACKUP_HAS_LAYOUTS = "%d account Edit Mode layouts (they replace yours)",
	BACKUP_HAS_MACROS = "%d macros (they replace yours)",
	POPUP_BACKUP_CODE = "SetGo! backup %s. Copy it with Ctrl+C and keep it in a file.",
	POPUP_BACKUP_PASTE = "Paste the backup code:",
	POPUP_BACKUP_RESTORE = "Restore the backup of %s (%s)?\n\n%s\n\nThis affects every character on the account. The interface reloads.",
	MSG_BACKUP_FAILED = "The backup couldn't be made on this version of the game.",
	MSG_BACKUP_BAD = "That isn't a SetGo! backup code.",
	MSG_BACKUP_RESTORED = "Backup restored.",
	MSG_BACKUP_MACROS_SKIPPED = "%d macros didn't fit and were left out.",
}

local PTB = {
	BACKUP_CREATE_DESC = "Guarda no jogo um backup da tua configuração: perfis, opções do SetGo!, definições da conta, layouts do Edit Mode e macros. O jogo guarda os últimos cinco. As tuas barras de acção e os outros addons não vão nele.",
	BACKUP_ENTRY = "%s (%s)",
	BACKUP_LAST = "Último backup: %s",
	BACKUP_NONE = "Ainda não há backups",
	BACKUP_APPLY = "Aplicar backup",
	BACKUP_APPLY_DESC = "Traz de volta as partes marcadas do backup escolhido, em vez do que tens agora. Pergunta primeiro; a interface recarrega.",
	BACKUP_EXPORT = "Exportar backup",
	BACKUP_EXPORT_DESC = "Mostra o código do backup escolhido, para copiares e guardares num ficheiro.",
	BACKUP_IMPORT = "Importar código",
	BACKUP_IMPORT_DESC = "Cola um código de backup: junta-se aos backups guardados no jogo, para o aplicares a partir daí.",
	BACKUP_DELETE = "Apagar backup",
	BACKUP_DELETE_DESC = "Apaga do jogo o backup escolhido. Um código que tenhas exportado continua a funcionar.",
	POPUP_BACKUP_DELETE = "Apagar o backup %s?",
	MSG_BACKUP_CREATED = "Backup feito: %s.",
	MSG_BACKUP_IMPORTED = "Backup importado: %s.",
	BACKUP_TITLE = "Backup",
	BACKUP_NOTE = "Backups de toda a tua configuração, guardados no jogo: perfis, opções do SetGo!, definições da conta, layouts do Edit Mode e macros. Exporta um para guardares o código num ficheiro.",
	BACKUP_CREATE = "Criar backup",
	BACKUP_PART_PROFILES = "Perfis",
	BACKUP_PART_OPTIONS = "Opções do SetGo! e do Quick Menu",
	BACKUP_PART_ACCOUNT = "Definições da conta",
	BACKUP_PART_LAYOUTS = "Layouts de conta do Edit Mode",
	BACKUP_PART_MACROS = "Macros",
	BACKUP_HAS_PROFILES = "%d perfis (substituem os teus)",
	BACKUP_HAS_ACCOUNT = "%d definições da conta",
	BACKUP_HAS_LAYOUTS = "%d layouts de conta do Edit Mode (substituem os teus)",
	BACKUP_HAS_MACROS = "%d macros (substituem as tuas)",
	POPUP_BACKUP_CODE = "Backup do SetGo! %s. Copia-o com Ctrl+C e guarda-o num ficheiro.",
	POPUP_BACKUP_PASTE = "Cola o código do backup:",
	POPUP_BACKUP_RESTORE = "Restaurar o backup de %s (%s)?\n\n%s\n\nIsto afecta todas as personagens da conta. A interface recarrega.",
	MSG_BACKUP_FAILED = "Não foi possível fazer o backup nesta versão do jogo.",
	MSG_BACKUP_BAD = "Isso não é um código de backup do SetGo!.",
	MSG_BACKUP_RESTORED = "Backup restaurado.",
	MSG_BACKUP_MACROS_SKIPPED = "%d macros não couberam e ficaram de fora.",
}

for key, value in pairs(ENB) do
	L[key] = value
end
if GetLocale() == "ptBR" then
	for key, value in pairs(PTB) do
		L[key] = value
	end
end
