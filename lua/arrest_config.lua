--[[-------------------------------------------------------------------------
Скрипт был написан давно
---------------------------------------------------------------------------]]

// Chat command
ARREST_COMMAND = {"!bail", "/bail"}	

// Enable chat command?
ARREST_ENABLE_CHATCOMMAND = false

// Allow to use bail command anywhere? 
ARREST_RESTRICT = false

// Minimum distance to the arrested player so that you can redeem him
ARREST_RESTRICTDIST = 300

// Prefix
ARREST_PREFIX = "[АРЕСТ]" -- prefix
ARREST_PREFIXCOLOR = Color(255,0,0) -- color

// Text
ARREST_TEXT1 = " был арестован " -- Player will be arrested by player2
ARREST_TEXT2 = ". Цена залога " -- Player will be arrested by player2 bail price 200
ARREST_MONEYPREFIX = "$" -- Player will be arrested by player2 bail price 200$
ARREST_TEXTCOLOR = Color(255,255,255) -- color

// Players nick color
ARREST_NICKCOLOR = Color(255,0,0)

// Bail price color
ARREST_BAILCOLOR = Color(0,255,0)

// Reason color
ARREST_REASONCOLOR = Color(255,0,0)

// Arrest reasons list
ARREST_REASONS = {
	--['reason_name'] = price,
	["Убийство"] = 6000,
	["Попытка суицида"] = 500,
	["Ком. час"] = 1000,
	["Криминал"] = 5000,
	["Нелегал"] = 3500,
}

// NPC name
ARREST_NPC_NAME = "Адвокат"

// NPC name color
ARREST_NPC_NAMECOLOR = Color(255,255,255)

// NPC model
ARREST_NPC_MODEL = "models/gman_high.mdl"

// Panel title
ARREST_NPC_PANELTITLE = "Арестованные игроки"

// Panel buy bail
ARREST_NPC_PAILBUY = "Заплатить залог"






// Don't touch this!
ARREST_BAILLIST = ARREST_BAILLIST or {}