-- NeverYield v6.4.2 - edited by kas
-- Based on Infinite Yield by Edge, Zwolf, Moon, Toon, Peyton and ATP

if IY_LOADED and not _G.IY_DEBUG then
	if getgenv and getgenv().IY_CUSTOM_LOADED then
		-- error("Infinite Yield is already running!", 0)
		return
	end
	-- The stock Infinite Yield is running (it re-queues itself on every teleport).
	-- Remove it and load this version instead.
	local guiRoots = {}
	pcall(function() if gethui then table.insert(guiRoots, gethui()) end end)
	pcall(function() table.insert(guiRoots, game:GetService("CoreGui")) end)
	for _, guiRoot in ipairs(guiRoots) do
		pcall(function()
			for _, label in ipairs(guiRoot:GetDescendants()) do
				if label:IsA("TextLabel") and string.find(label.Text, "Infinite Yield FE v", 1, true) then
					local screen = label:FindFirstAncestorOfClass("ScreenGui")
					if screen and screen.Name ~= "RobloxGui" then
						screen:Destroy()
					end
				end
			end
		end)
	end
	pcall(function()
		local localPlayer = game:GetService("Players").LocalPlayer
		-- only switch off listeners made by executor scripts (stock IY), not the game's own chat scripts
		local isExecutor = isexecutorclosure or checkclosure or isourclosure or is_synapse_function
		for _, signal in ipairs({localPlayer.OnTeleport, localPlayer.Chatted}) do
			for _, conn in ipairs(getconnections(signal)) do
				pcall(function()
					local fn = conn.Function
					if not isExecutor or not fn or isExecutor(fn) then
						conn:Disable()
					end
				end)
			end
		end
	end)
end

pcall(function()
	getgenv().IY_LOADED = true
	getgenv().IY_CUSTOM_LOADED = true
end)
if not game:IsLoaded() then game.Loaded:Wait() end

function missing(t, f, fallback)
	if type(f) == t then return f end
	return fallback
end

cloneref = missing("function", cloneref, function(...) return ... end)
gethui = missing("function", gethui or get_hidden_gui)
syn = missing("table", syn)
syn_protect_gui = missing("function", syn and syn.protect_gui)
sethidden =  missing("function", sethiddenproperty or set_hidden_property or set_hidden_prop)
gethidden =  missing("function", gethiddenproperty or get_hidden_property or get_hidden_prop)
queueteleport =  missing("function", queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport))
httprequest =  missing("function", request or http_request or (syn and syn.request) or (http and http.request) or (fluxus and fluxus.request))
everyClipboard = missing("function", setclipboard or toclipboard or set_clipboard or (Clipboard and Clipboard.set))
firetouchinterest = missing("function", firetouchinterest)
waxwritefile, waxreadfile = writefile, readfile
writefile = missing("function", waxwritefile) and function(file, data, safe)
	if safe == true then return pcall(waxwritefile, file, data) end
	waxwritefile(file, data)
end
readfile = missing("function", waxreadfile) and function(file, safe)
	if safe == true then return pcall(waxreadfile, file) end
	return waxreadfile(file)
end
isfile = missing("function", isfile, readfile and function(file)
	local success, result = pcall(function()
		return readfile(file)
	end)
	return success and result ~= nil and result ~= ""
end)
makefolder = missing("function", makefolder)
isfolder = missing("function", isfolder)
waxgetcustomasset = missing("function", getcustomasset or getsynasset)
hookfunction = missing("function", hookfunction)
hookmetamethod = missing("function", hookmetamethod)
getnamecallmethod = missing("function", getnamecallmethod or get_namecall_method)
checkcaller = missing("function", checkcaller, function() return false end)
newcclosure = missing("function", newcclosure, function(f, ...) return f(...) end)
getgc = missing("function", getgc or get_gc_objects)
setthreadidentity = missing("function", setthreadidentity or (syn and syn.set_thread_identity) or syn_context_set or setthreadcontext)
replicatesignal = missing("function", replicatesignal)
getconnections = missing("function", getconnections or get_signal_cons)

Services = setmetatable({}, {
	__index = function(self, name)
		local success, cache = pcall(function()
			return cloneref(game:GetService(name))
		end)
		if success then
			rawset(self, name, cache)
			return cache
		else
			error("Invalid Service: " .. tostring(name))
		end
	end
})

Players = Services.Players
UserInputService = Services.UserInputService
TweenService = Services.TweenService
HttpService = Services.HttpService
ExperienceService = Services.ExperienceService
MarketplaceService = Services.MarketplaceService
RunService = Services.RunService
TeleportService = Services.TeleportService
StarterGui = Services.StarterGui
GuiService = Services.GuiService
Lighting = Services.Lighting
ContextActionService = Services.ContextActionService
ReplicatedStorage = Services.ReplicatedStorage
GroupService = Services.GroupService
PathService = Services.PathfindingService
SoundService = Services.SoundService
Teams = Services.Teams
StarterPlayer = Services.StarterPlayer
InsertService = Services.InsertService
ChatService = Services.Chat
ProximityPromptService = Services.ProximityPromptService
ContentProvider = Services.ContentProvider
StatsService = Services.Stats
MaterialService = Services.MaterialService
AvatarEditorService = Services.AvatarEditorService
TextService = Services.TextService
TextChatService = Services.TextChatService
CaptureService = Services.CaptureService
VoiceChatService = Services.VoiceChatService
SocialService = Services.SocialService

PlayerGui = cloneref(Players.LocalPlayer:FindFirstChildWhichIsA("PlayerGui"))
COREGUI = Services.CoreGui or PlayerGui
IYMouse = cloneref(Players.LocalPlayer:GetMouse())
PlaceId, JobId = game.PlaceId, game.JobId
xpcall(function()
	IsOnMobile = table.find({Enum.Platform.Android, Enum.Platform.IOS}, UserInputService:GetPlatform())
end, function()
	IsOnMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end)
isLegacyChat = TextChatService.ChatVersion == Enum.ChatVersion.LegacyChatService
--[[rcdEnabled = select(2, pcall(function()
    return gethidden(workspace, "RejectCharacterDeletions") ~= Enum.RejectCharacterDeletions.Disabled
end)) or false]]

-- xylex & europa
local iyassets = {
	["infiniteyield/assets/bindsandplugins.png"] = "rbxassetid://5147695474",
	["infiniteyield/assets/close.png"] = "rbxassetid://5054663650",
	["infiniteyield/assets/editaliases.png"] = "rbxassetid://5147488658",
	["infiniteyield/assets/editkeybinds.png"] = "rbxassetid://129697930",
	["infiniteyield/assets/edittheme.png"] = "rbxassetid://4911962991",
	["infiniteyield/assets/editwaypoints.png"] = "rbxassetid://5147488592",
	["infiniteyield/assets/imgstudiopluginlogo.png"] = "rbxassetid://4113050383",
	["infiniteyield/assets/logo.png"] = "rbxassetid://1352543873",
	["infiniteyield/assets/minimize.png"] = "rbxassetid://2406617031",
	["infiniteyield/assets/pin.png"] = "rbxassetid://6234691350",
	["infiniteyield/assets/reference.png"] = "rbxassetid://3523243755",
	["infiniteyield/assets/settings.png"] = "rbxassetid://1204397029",
	["infiniteyield/assets/scrollbar.png"] = "rbxassetid://75024581433929"
}

local function getcustomasset(asset)
	if waxgetcustomasset then
		local success, result = pcall(function()
			return waxgetcustomasset(asset)
		end)
		if success and result ~= nil and result ~= "" then
			return result
		end
	end
	return iyassets[asset]
end

if makefolder and isfolder and writefile and isfile then
	pcall(function() -- good executor trust
		local assets = "https://raw.githubusercontent.com/infyiff/backup/refs/heads/main/"
		for _, folder in {"infiniteyield", "infiniteyield/assets"} do
			if not isfolder(folder) then
				makefolder(folder)
			end
		end
		for path in iyassets do
			if not isfile(path) and path ~= 'infiniteyield/assets/scrollbar.png' then
				writefile(path, game:HttpGet((path:gsub("infiniteyield/", assets))))
			end
		end
		-- honestly just blame your phone if the assets appear in your gallery
		if IsOnMobile then writefile("infiniteyield/assets/.nomedia", "") end
	end)
end

currentVersion = "6.4.2"

ScaledHolder = Instance.new("Frame")
Scale = Instance.new("UIScale")
Holder = Instance.new("Frame")
Title = Instance.new("TextLabel")
Dark = Instance.new("Frame")
Cmdbar = Instance.new("TextBox")
CMDsF = Instance.new("ScrollingFrame")
cmdListLayout = Instance.new("UIListLayout")
SettingsButton = Instance.new("ImageButton")
ColorsButton = Instance.new("ImageButton")
Settings = Instance.new("Frame")
Prefix = Instance.new("TextLabel")
PrefixBox = Instance.new("TextBox")
Keybinds = Instance.new("TextLabel")
StayOpen = Instance.new("TextLabel")
Button = Instance.new("Frame")
On = Instance.new("TextButton")
Positions = Instance.new("TextLabel")
EventBind = Instance.new("TextLabel")
Plugins = Instance.new("TextLabel")
Example = Instance.new("TextButton")
Notification = Instance.new("Frame")
Title_2 = Instance.new("TextLabel")
Text_2 = Instance.new("TextLabel")
CloseButton = Instance.new("TextButton")
CloseImage = Instance.new("ImageLabel")
PinButton = Instance.new("TextButton")
PinImage = Instance.new("ImageLabel")
Tooltip = Instance.new("Frame")
Title_3 = Instance.new("TextLabel")
Description = Instance.new("TextLabel")
IntroBackground = Instance.new("Frame")
Logo = Instance.new("ImageLabel")
Credits = Instance.new("TextBox")
KeybindsFrame = Instance.new("Frame")
Close = Instance.new("TextButton")
Add = Instance.new("TextButton")
Delete = Instance.new("TextButton")
Holder_2 = Instance.new("ScrollingFrame")
Example_2 = Instance.new("Frame")
Text_3 = Instance.new("TextLabel")
Delete_2 = Instance.new("TextButton")
KeybindEditor = Instance.new("Frame")
background_2 = Instance.new("Frame")
Dark_3 = Instance.new("Frame")
Directions = Instance.new("TextLabel")
BindTo = Instance.new("TextButton")
TriggerLabel = Instance.new("TextLabel")
BindTriggerSelect = Instance.new("TextButton")
Add_2 = Instance.new("TextButton")
Toggles = Instance.new("ScrollingFrame")
ClickTP  = Instance.new("TextLabel")
Select = Instance.new("TextButton")
ClickDelete = Instance.new("TextLabel")
Select_2 = Instance.new("TextButton")
Cmdbar_2 = Instance.new("TextBox")
Cmdbar_3 = Instance.new("TextBox")
CreateToggle = Instance.new("TextLabel")
Button_2 = Instance.new("Frame")
On_2 = Instance.new("TextButton")
shadow_2 = Instance.new("Frame")
PopupText_2 = Instance.new("TextLabel")
Exit_2 = Instance.new("TextButton")
ExitImage_2 = Instance.new("ImageLabel")
PositionsFrame = Instance.new("Frame")
Close_3 = Instance.new("TextButton")
Delete_5 = Instance.new("TextButton")
Part = Instance.new("TextButton")
Holder_4 = Instance.new("ScrollingFrame")
Example_4 = Instance.new("Frame")
Text_5 = Instance.new("TextLabel")
Delete_6 = Instance.new("TextButton")
TP = Instance.new("TextButton")
AliasesFrame = Instance.new("Frame")
Close_2 = Instance.new("TextButton")
Delete_3 = Instance.new("TextButton")
Holder_3 = Instance.new("ScrollingFrame")
Example_3 = Instance.new("Frame")
Text_4 = Instance.new("TextLabel")
Delete_4 = Instance.new("TextButton")
Aliases = Instance.new("TextLabel")
PluginsFrame = Instance.new("Frame")
Close_4 = Instance.new("TextButton")
Add_3 = Instance.new("TextButton")
Holder_5 = Instance.new("ScrollingFrame")
Example_5 = Instance.new("Frame")
Text_6 = Instance.new("TextLabel")
Delete_7 = Instance.new("TextButton")
PluginEditor = Instance.new("Frame")
background_3 = Instance.new("Frame")
Dark_2 = Instance.new("Frame")
Img = Instance.new("ImageButton")
AddPlugin = Instance.new("TextButton")
FileName = Instance.new("TextBox")
About = Instance.new("TextLabel")
Directions_2 = Instance.new("TextLabel")
shadow_3 = Instance.new("Frame")
PopupText_3 = Instance.new("TextLabel")
Exit_3 = Instance.new("TextButton")
ExitImage_3 = Instance.new("ImageLabel")
AliasHint = Instance.new("TextLabel")
PluginsHint = Instance.new("TextLabel")
PositionsHint = Instance.new("TextLabel")
ToPartFrame = Instance.new("Frame")
background_4 = Instance.new("Frame")
ChoosePart = Instance.new("TextButton")
CopyPath = Instance.new("TextButton")
Directions_3 = Instance.new("TextLabel")
Path = Instance.new("TextLabel")
shadow_4 = Instance.new("Frame")
PopupText_5 = Instance.new("TextLabel")
Exit_4 = Instance.new("TextButton")
ExitImage_5 = Instance.new("ImageLabel")
logs = Instance.new("Frame")
shadow = Instance.new("Frame")
Hide = Instance.new("TextButton")
ImageLabel = Instance.new("ImageLabel")
PopupText = Instance.new("TextLabel")
Exit = Instance.new("TextButton")
ImageLabel_2 = Instance.new("ImageLabel")
background = Instance.new("Frame")
chat = Instance.new("Frame")
Clear = Instance.new("TextButton")
SaveChatlogs = Instance.new("TextButton")
Toggle = Instance.new("TextButton")
scroll_2 = Instance.new("ScrollingFrame")
join = Instance.new("Frame")
Toggle_2 = Instance.new("TextButton")
Clear_2 = Instance.new("TextButton")
scroll_3 = Instance.new("ScrollingFrame")
listlayout = Instance.new("UIListLayout",scroll_3)
selectChat = Instance.new("TextButton")
selectJoin = Instance.new("TextButton")

function randomString()
	local length = math.random(10,20)
	local array = {}
	for i = 1, length do
		array[i] = string.char(math.random(32, 126))
	end
	return table.concat(array)
end

PARENT = nil
MAX_DISPLAY_ORDER = 1.7976931348623157e308
if gethui then
    local Main = Instance.new("ScreenGui")
    Main.Name = randomString()
    Main.ResetOnSpawn = false
    Main.DisplayOrder = MAX_DISPLAY_ORDER
    Main.Parent = gethui()
    PARENT = Main
elseif (not is_sirhurt_closure) and syn_protect_gui then
    local Main = Instance.new("ScreenGui")
    Main.Name = randomString()
    Main.ResetOnSpawn = false
    Main.DisplayOrder = MAX_DISPLAY_ORDER
    syn_protect_gui(Main)
    Main.Parent = COREGUI
    PARENT = Main
elseif COREGUI:FindFirstChild("RobloxGui") then
    PARENT = COREGUI.RobloxGui
else
    local Main = Instance.new("ScreenGui")
    Main.Name = randomString()
    Main.ResetOnSpawn = false
    Main.DisplayOrder = MAX_DISPLAY_ORDER
    Main.Parent = COREGUI
    PARENT = Main
end

shade1 = {}
shade2 = {}
shade3 = {}
text1 = {}
text2 = {}
scroll = {}

ScaledHolder.Name = randomString()
ScaledHolder.Size = UDim2.fromScale(1, 1)
ScaledHolder.BackgroundTransparency = 1
ScaledHolder.Parent = PARENT
Scale.Name = randomString()

Holder.Name = randomString()
Holder.Parent = ScaledHolder
Holder.Active = true
Holder.BackgroundColor3 = Color3.fromRGB(32, 18, 64)
Holder.BorderSizePixel = 0
Holder.Position = UDim2.new(1, -250, 1, -220)
Holder.Size = UDim2.new(0, 250, 0, 220)
Holder.ZIndex = 10
table.insert(shade2,Holder)

Title.Name = "Title"
Title.Parent = Holder
Title.Active = true
Title.BackgroundColor3 = Color3.fromRGB(16, 10, 34)
Title.BorderSizePixel = 0
Title.Size = UDim2.new(0, 250, 0, 20)
Title.Font = Enum.Font.SourceSans
Title.TextSize = 18
Title.RichText = true
Title.Text = "NeverYield v" .. currentVersion .. ' <font size="13" color="#C9A6FF">edited by kas</font>'

do
	local emoji = ({
		["01 01"] = "🎆",
		["02 14"] = "💝",
		["03 17"] = "☘️",
		[(function(Year)
			local A = math.floor(Year/100)
			local B = math.floor((13+8*A)/25)
			local C = (15-B+A-math.floor(A/4))%30
			local D = (4+A-math.floor(A/4))%7
			local E = (19*(Year%19)+C)%30
			local F = (2*(Year%4)+4*(Year%7)+6*E+D)%7
			local G = (22+E+F)
			if E == 29 and F == 6 then
				return "04 19"
			elseif E == 28 and F == 6 then
				return "04 18"
			elseif 31 < G then
				return ("04 %02d"):format(G-31)
			end
			return ("03 %02d"):format(G)
		end)(tonumber(os.date"%Y"))] = "🥚",
		["10 31"] = "🎃",
		["12 25"] = "🎄"
	})[os.date("%m %d")]
	if emoji then
		Title.Text = ("%s %s %s"):format(emoji, Title.Text, emoji)
	end
end

Title.TextColor3 = Color3.new(1, 1, 1)
Title.ZIndex = 10
table.insert(shade1,Title)
table.insert(text1,Title)

Dark.Name = "Dark"
Dark.Parent = Holder
Dark.Active = true
Dark.BackgroundColor3 = Color3.fromRGB(16, 10, 34)
Dark.BorderSizePixel = 0
Dark.Position = UDim2.new(0, 0, 0, 45)
Dark.Size = UDim2.new(0, 250, 0, 175)
Dark.ZIndex = 10
table.insert(shade1,Dark)

Cmdbar.Name = "Cmdbar"
Cmdbar.Parent = Holder
Cmdbar.BackgroundTransparency = 1
Cmdbar.BorderSizePixel = 0
Cmdbar.Position = UDim2.new(0, 5, 0, 20)
Cmdbar.Size = UDim2.new(0, 240, 0, 25)
Cmdbar.Font = Enum.Font.SourceSans
Cmdbar.TextSize = 18
Cmdbar.TextXAlignment = Enum.TextXAlignment.Left
Cmdbar.TextColor3 = Color3.new(1, 1, 1)
Cmdbar.Text = ""
Cmdbar.ZIndex = 10
Cmdbar.PlaceholderText = "Command Bar"

CMDsF.Name = "CMDs"
CMDsF.Parent = Holder
CMDsF.BackgroundTransparency = 1
CMDsF.BorderSizePixel = 0
CMDsF.Position = UDim2.new(0, 5, 0, 45)
CMDsF.Size = UDim2.new(0, 245, 0, 175)
CMDsF.ScrollBarImageColor3 = Color3.fromRGB(86, 50, 160)
CMDsF.BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
CMDsF.CanvasSize = UDim2.new(0, 0, 0, 0)
CMDsF.MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
CMDsF.ScrollBarThickness = 8
CMDsF.TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
CMDsF.VerticalScrollBarInset = 'Always'
CMDsF.ZIndex = 10
table.insert(scroll,CMDsF)

cmdListLayout.Parent = CMDsF

SettingsButton.Name = "SettingsButton"
SettingsButton.Parent = Holder
SettingsButton.BackgroundTransparency = 1
SettingsButton.Position = UDim2.new(0, 230, 0, 0)
SettingsButton.Size = UDim2.new(0, 20, 0, 20)
SettingsButton.Image = getcustomasset("infiniteyield/assets/settings.png")
SettingsButton.ZIndex = 10

ReferenceButton = Instance.new("ImageButton")
ReferenceButton.Name = "ReferenceButton"
ReferenceButton.Parent = Holder
ReferenceButton.BackgroundTransparency = 1
ReferenceButton.Position = UDim2.new(0, 212, 0, 2)
ReferenceButton.Size = UDim2.new(0, 16, 0, 16)
ReferenceButton.Image = getcustomasset("infiniteyield/assets/reference.png")
ReferenceButton.ZIndex = 10

Settings.Name = "Settings"
Settings.Parent = Holder
Settings.Active = true
Settings.BackgroundColor3 = Color3.fromRGB(16, 10, 34)
Settings.BorderSizePixel = 0
Settings.Position = UDim2.new(0, 0, 0, 220)
Settings.Size = UDim2.new(0, 250, 0, 175)
Settings.ZIndex = 10
table.insert(shade1,Settings)

SettingsHolder = Instance.new("ScrollingFrame")
SettingsHolder.Name = "Holder"
SettingsHolder.Parent = Settings
SettingsHolder.BackgroundTransparency = 1
SettingsHolder.BorderSizePixel = 0
SettingsHolder.Size = UDim2.new(1,0,1,0)
SettingsHolder.ScrollBarImageColor3 = Color3.fromRGB(86, 50, 160)
SettingsHolder.BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
SettingsHolder.CanvasSize = UDim2.new(0, 0, 0, 235)
SettingsHolder.MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
SettingsHolder.ScrollBarThickness = 8
SettingsHolder.TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
SettingsHolder.VerticalScrollBarInset = 'Always'
SettingsHolder.ZIndex = 10
table.insert(scroll,SettingsHolder)

Prefix.Name = "Prefix"
Prefix.Parent = SettingsHolder
Prefix.BackgroundColor3 = Color3.fromRGB(32, 18, 64)
Prefix.BorderSizePixel = 0
Prefix.BackgroundTransparency = 1
Prefix.Position = UDim2.new(0, 5, 0, 5)
Prefix.Size = UDim2.new(1, -10, 0, 20)
Prefix.Font = Enum.Font.SourceSans
Prefix.TextSize = 14
Prefix.Text = "Prefix"
Prefix.TextColor3 = Color3.new(1, 1, 1)
Prefix.TextXAlignment = Enum.TextXAlignment.Left
Prefix.ZIndex = 10
table.insert(shade2,Prefix)
table.insert(text1,Prefix)

PrefixBox.Name = "PrefixBox"
PrefixBox.Parent = Prefix
PrefixBox.BackgroundColor3 = Color3.fromRGB(86, 50, 160)
PrefixBox.BorderSizePixel = 0
PrefixBox.Position = UDim2.new(1, -20, 0, 0)
PrefixBox.Size = UDim2.new(0, 20, 0, 20)
PrefixBox.Font = Enum.Font.SourceSansBold
PrefixBox.TextSize = 14
PrefixBox.Text = ''
PrefixBox.TextColor3 = Color3.new(0, 0, 0)
PrefixBox.ZIndex = 10
table.insert(shade3,PrefixBox)
table.insert(text2,PrefixBox)

function makeSettingsButton(name,iconID,off)
	local button = Instance.new("TextButton")
	button.BackgroundColor3 = Color3.fromRGB(32, 18, 64)
	button.BorderSizePixel = 0
	button.Position = UDim2.new(0,0,0,0)
	button.Size = UDim2.new(1,0,0,25)
	button.Text = ""
	button.ZIndex = 10
	local icon = Instance.new("ImageLabel")
	icon.Name = "Icon"
	icon.Parent = button
	icon.Position = UDim2.new(0,5,0,5)
	icon.Size = UDim2.new(0,16,0,16)
	icon.BackgroundTransparency = 1
	icon.Image = iconID
	icon.ZIndex = 10
	if off then
		icon.ScaleType = Enum.ScaleType.Crop
		icon.ImageRectSize = Vector2.new(16,16)
		icon.ImageRectOffset = Vector2.new(off,0)
	end
	local label = Instance.new("TextLabel")
	label.Name = "ButtonLabel"
	label.Parent = button
	label.BackgroundTransparency = 1
	label.Text = name
	label.Position = UDim2.new(0,28,0,0)
	label.Size = UDim2.new(1,-28,1,0)
	label.Font = Enum.Font.SourceSans
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextSize = 14
	label.ZIndex = 10
	label.TextXAlignment = Enum.TextXAlignment.Left
	table.insert(shade2,button)
	table.insert(text1,label)
	return button
end

ColorsButton = makeSettingsButton("Theme Studio",getcustomasset("infiniteyield/assets/edittheme.png"))
ColorsButton.Position = UDim2.new(0, 5, 0, 55)
ColorsButton.Size = UDim2.new(1, -10, 0, 25)
ColorsButton.Name = "Colors"
ColorsButton.Parent = SettingsHolder

Keybinds = makeSettingsButton("Edit Keybinds",getcustomasset("infiniteyield/assets/editkeybinds.png"))
Keybinds.Position = UDim2.new(0, 5, 0, 85)
Keybinds.Size = UDim2.new(1, -10, 0, 25)
Keybinds.Name = "Keybinds"
Keybinds.Parent = SettingsHolder

Aliases = makeSettingsButton("Edit Aliases",getcustomasset("infiniteyield/assets/editaliases.png"))
Aliases.Position = UDim2.new(0, 5, 0, 115)
Aliases.Size = UDim2.new(1, -10, 0, 25)
Aliases.Name = "Aliases"
Aliases.Parent = SettingsHolder

StayOpen.Name = "StayOpen"
StayOpen.Parent = SettingsHolder
StayOpen.BackgroundColor3 = Color3.fromRGB(32, 18, 64)
StayOpen.BorderSizePixel = 0
StayOpen.BackgroundTransparency = 1
StayOpen.Position = UDim2.new(0, 5, 0, 30)
StayOpen.Size = UDim2.new(1, -10, 0, 20)
StayOpen.Font = Enum.Font.SourceSans
StayOpen.TextSize = 14
StayOpen.Text = "Keep Menu Open"
StayOpen.TextColor3 = Color3.new(1, 1, 1)
StayOpen.TextXAlignment = Enum.TextXAlignment.Left
StayOpen.ZIndex = 10
table.insert(shade2,StayOpen)
table.insert(text1,StayOpen)

Button.Name = "Button"
Button.Parent = StayOpen
Button.BackgroundColor3 = Color3.fromRGB(86, 50, 160)
Button.BorderSizePixel = 0
Button.Position = UDim2.new(1, -20, 0, 0)
Button.Size = UDim2.new(0, 20, 0, 20)
Button.ZIndex = 10
table.insert(shade3,Button)

On.Name = "On"
On.Parent = Button
On.BackgroundColor3 = Color3.fromRGB(150, 150, 151)
On.BackgroundTransparency = 1
On.BorderSizePixel = 0
On.Position = UDim2.new(0, 2, 0, 2)
On.Size = UDim2.new(0, 16, 0, 16)
On.Font = Enum.Font.SourceSans
On.FontSize = Enum.FontSize.Size14
On.Text = ""
On.TextColor3 = Color3.new(0, 0, 0)
On.ZIndex = 10

Positions = makeSettingsButton("Edit/Goto Waypoints",getcustomasset("infiniteyield/assets/editwaypoints.png"))
Positions.Position = UDim2.new(0, 5, 0, 145)
Positions.Size = UDim2.new(1, -10, 0, 25)
Positions.Name = "Waypoints"
Positions.Parent = SettingsHolder

EventBind = makeSettingsButton("Edit Event Binds",getcustomasset("infiniteyield/assets/bindsandplugins.png"),759)
EventBind.Position = UDim2.new(0, 5, 0, 205)
EventBind.Size = UDim2.new(1, -10, 0, 25)
EventBind.Name = "EventBinds"
EventBind.Parent = SettingsHolder

Plugins = makeSettingsButton("Manage Plugins",getcustomasset("infiniteyield/assets/bindsandplugins.png"),743)
Plugins.Position = UDim2.new(0, 5, 0, 175)
Plugins.Size = UDim2.new(1, -10, 0, 25)
Plugins.Name = "Plugins"
Plugins.Parent = SettingsHolder

Example.Name = "Example"
Example.Parent = Holder
Example.BackgroundTransparency = 1
Example.BorderSizePixel = 0
Example.Size = UDim2.new(0, 190, 0, 20)
Example.Visible = false
Example.Font = Enum.Font.SourceSans
Example.TextSize = 18
Example.Text = "Example"
Example.TextColor3 = Color3.new(1, 1, 1)
Example.TextXAlignment = Enum.TextXAlignment.Left
Example.ZIndex = 10
table.insert(text1,Example)

Notification.Name = randomString()
Notification.Parent = ScaledHolder
Notification.BackgroundColor3 = Color3.fromRGB(16, 10, 34)
Notification.BorderSizePixel = 0
Notification.Position = UDim2.new(1, -500, 1, 20)
Notification.Size = UDim2.new(0, 250, 0, 100)
Notification.ZIndex = 10
table.insert(shade1,Notification)

Title_2.Name = "Title"
Title_2.Parent = Notification
Title_2.BackgroundColor3 = Color3.fromRGB(32, 18, 64)
Title_2.BorderSizePixel = 0
Title_2.Size = UDim2.new(0, 250, 0, 20)
Title_2.Font = Enum.Font.SourceSans
Title_2.TextSize = 14
Title_2.Text = "Notification Title"
Title_2.TextColor3 = Color3.new(1, 1, 1)
Title_2.ZIndex = 10
table.insert(shade2,Title_2)
table.insert(text1,Title_2)

Text_2.Name = "Text"
Text_2.Parent = Notification
Text_2.BackgroundTransparency = 1
Text_2.BorderSizePixel = 0
Text_2.Position = UDim2.new(0, 5, 0, 25)
Text_2.Size = UDim2.new(0, 240, 0, 75)
Text_2.Font = Enum.Font.SourceSans
Text_2.TextSize = 16
Text_2.Text = "Notification Text"
Text_2.TextColor3 = Color3.new(1, 1, 1)
Text_2.TextWrapped = true
Text_2.ZIndex = 10
table.insert(text1,Text_2)

CloseButton.Name = "CloseButton"
CloseButton.Parent = Notification
CloseButton.BackgroundTransparency = 1
CloseButton.Position = UDim2.new(1, -20, 0, 0)
CloseButton.Size = UDim2.new(0, 20, 0, 20)
CloseButton.Text = ""
CloseButton.ZIndex = 10

CloseImage.Parent = CloseButton
CloseImage.BackgroundColor3 = Color3.new(1, 1, 1)
CloseImage.BackgroundTransparency = 1
CloseImage.Position = UDim2.new(0, 5, 0, 5)
CloseImage.Size = UDim2.new(0, 10, 0, 10)
CloseImage.Image = getcustomasset("infiniteyield/assets/close.png")
CloseImage.ZIndex = 10

PinButton.Name = "PinButton"
PinButton.Parent = Notification
PinButton.BackgroundTransparency = 1
PinButton.Size = UDim2.new(0, 20, 0, 20)
PinButton.ZIndex = 10
PinButton.Text = ""

PinImage.Parent = PinButton
PinImage.BackgroundColor3 = Color3.new(1, 1, 1)
PinImage.BackgroundTransparency = 1
PinImage.Position = UDim2.new(0, 3, 0, 3)
PinImage.Size = UDim2.new(0, 14, 0, 14)
PinImage.ZIndex = 10
PinImage.Image = getcustomasset("infiniteyield/assets/pin.png")

Tooltip.Name = randomString()
Tooltip.Parent = ScaledHolder
Tooltip.Active = true
Tooltip.BackgroundColor3 = Color3.fromRGB(16, 10, 34)
Tooltip.BackgroundTransparency = 0.1
Tooltip.BorderSizePixel = 0
Tooltip.Size = UDim2.new(0, 200, 0, 96)
Tooltip.Visible = false
Tooltip.ZIndex = 10
table.insert(shade1,Tooltip)

Title_3.Name = "Title"
Title_3.Parent = Tooltip
Title_3.BackgroundColor3 = Color3.fromRGB(32, 18, 64)
Title_3.BackgroundTransparency = 0.1
Title_3.BorderSizePixel = 0
Title_3.Size = UDim2.new(0, 200, 0, 20)
Title_3.Font = Enum.Font.SourceSans
Title_3.TextSize = 14
Title_3.Text = ""
Title_3.TextColor3 = Color3.new(1, 1, 1)
Title_3.TextTransparency = 0.1
Title_3.ZIndex = 10
table.insert(shade2,Title_3)
table.insert(text1,Title_3)

Description.Name = "Description"
Description.Parent = Tooltip
Description.BackgroundTransparency = 1
Description.BorderSizePixel = 0
Description.Size = UDim2.new(0,180,0,72)
Description.Position = UDim2.new(0,10,0,18)
Description.Font = Enum.Font.SourceSans
Description.TextSize = 16
Description.Text = ""
Description.TextColor3 = Color3.new(1, 1, 1)
Description.TextTransparency = 0.1
Description.TextWrapped = true
Description.ZIndex = 10
table.insert(text1,Description)

IntroBackground.Name = "IntroBackground"
IntroBackground.Parent = Holder
IntroBackground.Active = true
IntroBackground.BackgroundColor3 = Color3.fromRGB(16, 10, 34)
IntroBackground.BorderSizePixel = 0
IntroBackground.Position = UDim2.new(0, 0, 0, 45)
IntroBackground.Size = UDim2.new(0, 250, 0, 175)
IntroBackground.ZIndex = 10

Logo.Name = "Logo"
Logo.Parent = Holder
Logo.BackgroundTransparency = 1
Logo.BorderSizePixel = 0
Logo.Position = UDim2.new(0, 125, 0, 127)
Logo.Size = UDim2.new(0, 10, 0, 10)
Logo.Image = getcustomasset("infiniteyield/assets/logo.png")
Logo.ImageTransparency = 0
Logo.ImageColor3 = Color3.fromRGB(200, 165, 255)
Logo.ZIndex = 10

Credits.Name = "Credits"
Credits.Parent = Holder
Credits.BackgroundTransparency = 1
Credits.BorderSizePixel = 0
Credits.Position = UDim2.new(0, 0, 0.9, 30)
Credits.Size = UDim2.new(0, 250, 0, 20)
Credits.Font = Enum.Font.SourceSansLight
Credits.FontSize = Enum.FontSize.Size14
Credits.Text = "NeverYield // edited by kas"
Credits.TextColor3 = Color3.fromRGB(201, 166, 255)
Credits.ZIndex = 10

-- NeverYield: space look
NeverYieldGradients = {}
for _, frame in ipairs({Holder, Title, IntroBackground}) do
	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 200, 255)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(195, 170, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 190, 255)),
	})
	gradient.Rotation = 45
	gradient.Parent = frame
	table.insert(NeverYieldGradients, gradient)
end
for i = 1, 45 do
	local star = Instance.new("Frame")
	local size = math.random(1, 3)
	star.Name = "Star"
	star.BorderSizePixel = 0
	star.BackgroundColor3 = (i % 4 == 0) and Color3.fromRGB(210, 170, 255) or Color3.new(1, 1, 1)
	star.BackgroundTransparency = math.random() * 0.5
	star.Size = UDim2.new(0, size, 0, size)
	star.Position = UDim2.new(math.random(), 0, math.random(), 0)
	star.ZIndex = 10
	star.Parent = IntroBackground
	TweenService:Create(star, TweenInfo.new(0.6 + math.random() * 1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {BackgroundTransparency = 1}):Play()
end
task.spawn(function()
	while task.wait(0.05) do
		local alive = false
		for _, gradient in ipairs(NeverYieldGradients) do
			if gradient.Parent then
				alive = true
				gradient.Rotation = (gradient.Rotation + 1) % 360
			end
		end
		if not alive then break end
	end
end)

-- NeverYield: portal UI
NeverYieldPortal = {rings = {}, sparks = {}, scale = 0, fade = 1, lastPulse = 0}

NeverYieldPortal.swirl = function()
	return ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(170, 90, 255)),
		ColorSequenceKeypoint.new(0.25, Color3.fromRGB(255, 120, 230)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(110, 200, 255)),
		ColorSequenceKeypoint.new(0.75, Color3.fromRGB(255, 120, 230)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(170, 90, 255)),
	})
end

NeverYieldPortal.corner = function(obj, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = radius or UDim.new(0, 12)
	corner.Parent = obj
	return corner
end

NeverYieldPortal.stroke = function(obj, thickness, transparency)
	local stroke = Instance.new("UIStroke")
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Color = Color3.new(1, 1, 1)
	stroke.Thickness = thickness
	stroke.Transparency = transparency or 0
	stroke.Parent = obj
	local gradient = Instance.new("UIGradient")
	gradient.Color = NeverYieldPortal.swirl()
	gradient.Parent = stroke
	return stroke, gradient
end

-- point on the outline of a w x h box grown by pad, t in [0, 1)
NeverYieldPortal.perimeter = function(t, w, h, pad)
	local W, H = w + pad * 2, h + pad * 2
	local d = (t % 1) * (2 * W + 2 * H)
	if d < W then return d - pad, -pad end
	d = d - W
	if d < H then return w + pad, d - pad end
	d = d - H
	if d < W then return w + pad - d, h + pad end
	d = d - W
	return -pad, h + pad - d
end

-- rounded panel with a swirling portal rim
for _, obj in ipairs({Holder, Title, Dark, IntroBackground}) do
	NeverYieldPortal.corner(obj)
end
for _, obj in ipairs({Notification, Tooltip}) do
	pcall(function()
		NeverYieldPortal.corner(obj, UDim.new(0, 8))
		NeverYieldPortal.stroke(obj, 1.5, 0.2)
	end)
end
NeverYieldPortal.rim, NeverYieldPortal.rimGradient = NeverYieldPortal.stroke(Holder, 2.5, 0)

-- the panel starts closed; NeverYieldPortal.open() pulls it out of the portal
NeverYieldPortal.uiScale = Instance.new("UIScale")
NeverYieldPortal.uiScale.Scale = 0
NeverYieldPortal.uiScale.Parent = Holder

-- outer energy rings behind the panel
for i, pad in ipairs({7, 15}) do
	local ring = Instance.new("Frame")
	ring.Name = randomString()
	ring.BackgroundTransparency = 1
	ring.BorderSizePixel = 0
	ring.ZIndex = 9
	NeverYieldPortal.corner(ring, UDim.new(0, 12 + pad))
	local stroke, gradient = NeverYieldPortal.stroke(ring, i == 1 and 3 or 2, 1)
	ring.Parent = ScaledHolder
	table.insert(NeverYieldPortal.rings, {frame = ring, pad = pad, stroke = stroke, gradient = gradient, base = i == 1 and 0.45 or 0.7, dir = i == 1 and -1 or 1})
end

-- sparks orbiting the rim
for i = 1, 10 do
	local spark = Instance.new("Frame")
	spark.Name = randomString()
	spark.AnchorPoint = Vector2.new(0.5, 0.5)
	spark.Size = UDim2.new(0, 4, 0, 4)
	spark.BorderSizePixel = 0
	spark.BackgroundColor3 = (i % 2 == 0) and Color3.fromRGB(255, 140, 235) or Color3.fromRGB(150, 210, 255)
	spark.BackgroundTransparency = 1
	spark.ZIndex = 11
	NeverYieldPortal.corner(spark, UDim.new(0.5, 0))
	spark.Parent = ScaledHolder
	table.insert(NeverYieldPortal.sparks, spark)
end

NeverYieldPortal.conn = RunService.RenderStepped:Connect(function()
	if Holder.Parent == nil then
		NeverYieldPortal.conn:Disconnect()
		for _, ring in ipairs(NeverYieldPortal.rings) do ring.frame:Destroy() end
		for _, spark in ipairs(NeverYieldPortal.sparks) do spark:Destroy() end
		return
	end
	local t = tick()
	local s = NeverYieldPortal.scale
	local w, h = Holder.Size.X.Offset * s, Holder.Size.Y.Offset * s
	local xs, x = Holder.Position.X.Scale, Holder.Position.X.Offset
	local ys, y = Holder.Position.Y.Scale, Holder.Position.Y.Offset
	local visible = Holder.Visible and s > 0.05
	local last = NeverYieldPortal.lastLayout
	local moved = not last or last[1] ~= xs or last[2] ~= x or last[3] ~= ys or last[4] ~= y or last[5] ~= s or last[6] ~= visible
	if moved then
		NeverYieldPortal.lastLayout = {xs, x, ys, y, s, visible}
	end
	if not visible then
		if moved then
			for _, ring in ipairs(NeverYieldPortal.rings) do ring.frame.Visible = false end
			for _, spark in ipairs(NeverYieldPortal.sparks) do spark.Visible = false end
		end
		return
	end
	NeverYieldPortal.rimGradient.Rotation = (t * 140) % 360
	for _, ring in ipairs(NeverYieldPortal.rings) do
		if moved then
			ring.frame.Visible = visible
			ring.frame.Position = UDim2.new(xs, x - ring.pad, ys, y - ring.pad)
			ring.frame.Size = UDim2.new(0, w + ring.pad * 2, 0, h + ring.pad * 2)
		end
		ring.gradient.Rotation = (t * 90 * ring.dir) % 360
		ring.stroke.Transparency = math.clamp(ring.base + math.sin(t * 2.5 + ring.pad) * 0.15 + NeverYieldPortal.fade, 0, 1)
	end
	for i, spark in ipairs(NeverYieldPortal.sparks) do
		local px, py = NeverYieldPortal.perimeter(t * 0.12 + i / #NeverYieldPortal.sparks, w, h, 4)
		if moved then
			spark.Visible = visible
		end
		spark.Position = UDim2.new(xs, x + px, ys, y + py)
		spark.BackgroundTransparency = math.clamp(0.2 + math.sin(t * 6 + i) * 0.2 + NeverYieldPortal.fade, 0, 1)
	end
end)

NeverYieldPortal.pulse = function()
	if tick() - NeverYieldPortal.lastPulse < 0.4 then return end
	NeverYieldPortal.lastPulse = tick()
	NeverYieldPortal.rim.Thickness = 6
	TweenService:Create(NeverYieldPortal.rim, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Thickness = 2.5}):Play()
end

NeverYieldPortal.finishOpen = function(base)
	NeverYieldPortal.uiScale.Scale = 1
	NeverYieldPortal.scale = 1
	NeverYieldPortal.fade = 0
	Holder.Rotation = 0
	Holder.Position = base
end

-- vortex opens, then the panel spins out of it
NeverYieldPortal.open = function()
	if NeverYieldPortal.opening then return end
	NeverYieldPortal.opening = true
	local base = Holder.Position
	local w, h = Holder.Size.X.Offset, Holder.Size.Y.Offset
	local cx, cy = base.X.Offset + w / 2, base.Y.Offset + h / 2
	local center = UDim2.new(base.X.Scale, cx, base.Y.Scale, cy)
	local vortex = {}
	local ok = pcall(function()
		for i = 1, 5 do
			local ring = Instance.new("Frame")
			ring.Name = randomString()
			ring.AnchorPoint = Vector2.new(0.5, 0.5)
			ring.Position = center
			ring.Size = UDim2.new(0, 0, 0, 0)
			ring.BackgroundTransparency = 1
			ring.ZIndex = 12
			NeverYieldPortal.corner(ring, UDim.new(0.5, 0))
			local stroke, gradient = NeverYieldPortal.stroke(ring, 6 - i, 0)
			ring.Parent = ScaledHolder
			table.insert(vortex, {frame = ring, stroke = stroke, gradient = gradient, dir = (i % 2 == 0) and 1 or -1, delay = i * 0.06, max = 60 + i * 55})
		end
		local core = Instance.new("Frame")
		core.Name = randomString()
		core.AnchorPoint = Vector2.new(0.5, 0.5)
		core.Position = center
		core.Size = UDim2.new(0, 0, 0, 0)
		core.BackgroundColor3 = Color3.new(1, 1, 1)
		core.BorderSizePixel = 0
		core.ZIndex = 12
		NeverYieldPortal.corner(core, UDim.new(0.5, 0))
		local coreGradient = Instance.new("UIGradient")
		coreGradient.Color = NeverYieldPortal.swirl()
		coreGradient.Parent = core
		core.Parent = ScaledHolder
		table.insert(vortex, {frame = core})

		local start = tick()
		while Holder.Parent ~= nil do
			local e = tick() - start
			if e >= 1.6 then break end
			for _, v in ipairs(vortex) do
				if v.stroke then
					local p = math.clamp((e - v.delay) / 0.7, 0, 1)
					local size = v.max * (1 - (1 - p) ^ 3)
					v.frame.Size = UDim2.new(0, size, 0, size)
					v.gradient.Rotation = (e * 500 * v.dir) % 360
					v.stroke.Transparency = math.clamp((e - 1) / 0.6, 0, 1)
				end
			end
			local cp = math.clamp(e / 0.5, 0, 1)
			local coreSize = 120 * (1 - (1 - cp) ^ 2)
			core.Size = UDim2.new(0, coreSize, 0, coreSize)
			coreGradient.Rotation = (e * 300) % 360
			core.BackgroundTransparency = math.clamp(0.2 + (e - 0.5) / 0.6, 0.2, 1)

			local hp = math.clamp((e - 0.45) / 0.7, 0, 1)
			local back = 1 + 2.70158 * (hp - 1) ^ 3 + 1.70158 * (hp - 1) ^ 2
			local s = math.max(back, 0.001)
			NeverYieldPortal.uiScale.Scale = s
			NeverYieldPortal.scale = s
			NeverYieldPortal.fade = 1 - hp
			Holder.Rotation = -120 * (1 - hp) ^ 2
			Holder.Position = UDim2.new(base.X.Scale, cx - w * s / 2, base.Y.Scale, cy - h * s / 2)
			RunService.RenderStepped:Wait()
		end
	end)
	for _, v in ipairs(vortex) do
		pcall(function() v.frame:Destroy() end)
	end
	NeverYieldPortal.finishOpen(base)
	NeverYieldPortal.opening = false
	if ok then
		NeverYieldPortal.pulse()
	end
end

KeybindsFrame.Name = "KeybindsFrame"
KeybindsFrame.Parent = Settings
KeybindsFrame.Active = true
KeybindsFrame.BackgroundColor3 = Color3.fromRGB(16, 10, 34)
KeybindsFrame.BorderSizePixel = 0
KeybindsFrame.Position = UDim2.new(0, 0, 0, 175)
KeybindsFrame.Size = UDim2.new(0, 250, 0, 175)
KeybindsFrame.ZIndex = 10
table.insert(shade1,KeybindsFrame)

Close.Name = "Close"
Close.Parent = KeybindsFrame
Close.BackgroundColor3 = Color3.fromRGB(32, 18, 64)
Close.BorderSizePixel = 0
Close.Position = UDim2.new(0, 205, 0, 150)
Close.Size = UDim2.new(0, 40, 0, 20)
Close.Font = Enum.Font.SourceSans
Close.TextSize = 14
Close.Text = "Close"
Close.TextColor3 = Color3.new(1, 1, 1)
Close.ZIndex = 10
table.insert(shade2,Close)
table.insert(text1,Close)

Add.Name = "Add"
Add.Parent = KeybindsFrame
Add.BackgroundColor3 = Color3.fromRGB(32, 18, 64)
Add.BorderSizePixel = 0
Add.Position = UDim2.new(0, 5, 0, 150)
Add.Size = UDim2.new(0, 40, 0, 20)
Add.Font = Enum.Font.SourceSans
Add.TextSize = 14
Add.Text = "Add"
Add.TextColor3 = Color3.new(1, 1, 1)
Add.ZIndex = 10
table.insert(shade2,Add)
table.insert(text1,Add)

Delete.Name = "Delete"
Delete.Parent = KeybindsFrame
Delete.BackgroundColor3 = Color3.fromRGB(32, 18, 64)
Delete.BorderSizePixel = 0
Delete.Position = UDim2.new(0, 50, 0, 150)
Delete.Size = UDim2.new(0, 40, 0, 20)
Delete.Font = Enum.Font.SourceSans
Delete.TextSize = 14
Delete.Text = "Clear"
Delete.TextColor3 = Color3.new(1, 1, 1)
Delete.ZIndex = 10
table.insert(shade2,Delete)
table.insert(text1,Delete)

Holder_2.Name = "Holder"
Holder_2.Parent = KeybindsFrame
Holder_2.BackgroundTransparency = 1
Holder_2.BorderSizePixel = 0
Holder_2.Position = UDim2.new(0, 0, 0, 0)
Holder_2.Size = UDim2.new(0, 250, 0, 145)
Holder_2.ScrollBarImageColor3 = Color3.fromRGB(86, 50, 160)
Holder_2.BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
Holder_2.CanvasSize = UDim2.new(0, 0, 0, 0)
Holder_2.MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
Holder_2.ScrollBarThickness = 0
Holder_2.TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
Holder_2.VerticalScrollBarInset = 'Always'
Holder_2.ZIndex = 10

Example_2.Name = "Example"
Example_2.Parent = KeybindsFrame
Example_2.BackgroundColor3 = Color3.fromRGB(32, 18, 64)
Example_2.BorderSizePixel = 0
Example_2.Size = UDim2.new(0, 10, 0, 20)
Example_2.Visible = false
Example_2.ZIndex = 10
table.insert(shade2,Example_2)

Text_3.Name = "Text"
Text_3.Parent = Example_2
Text_3.BackgroundColor3 = Color3.fromRGB(32, 18, 64)
Text_3.BorderSizePixel = 0
Text_3.Position = UDim2.new(0, 10, 0, 0)
Text_3.Size = UDim2.new(0, 240, 0, 20)
Text_3.Font = Enum.Font.SourceSans
Text_3.TextSize = 14
Text_3.Text = "nom"
Text_3.TextColor3 = Color3.new(1, 1, 1)
Text_3.TextXAlignment = Enum.TextXAlignment.Left
Text_3.ZIndex = 10
table.insert(shade2,Text_3)
table.insert(text1,Text_3)

Delete_2.Name = "Delete"
Delete_2.Parent = Text_3
Delete_2.BackgroundColor3 = Color3.fromRGB(86, 50, 160)
Delete_2.BorderSizePixel = 0
Delete_2.Position = UDim2.new(0, 200, 0, 0)
Delete_2.Size = UDim2.new(0, 40, 0, 20)
Delete_2.Font = Enum.Font.SourceSans
Delete_2.TextSize = 14
Delete_2.Text = "Delete"
Delete_2.TextColor3 = Color3.new(0, 0, 0)
Delete_2.ZIndex = 10
table.insert(shade3,Delete_2)
table.insert(text2,Delete_2)

KeybindEditor.Name = randomString()
KeybindEditor.Parent = ScaledHolder
KeybindEditor.Active = true
KeybindEditor.BackgroundTransparency = 1
KeybindEditor.Position = UDim2.new(0.5, -180, 0, -500)
KeybindEditor.Size = UDim2.new(0, 360, 0, 20)
KeybindEditor.ZIndex = 10

background_2.Name = "background"
background_2.Parent = KeybindEditor
background_2.Active = true
background_2.BackgroundColor3 = Color3.fromRGB(16, 10, 34)
background_2.BorderSizePixel = 0
background_2.Position = UDim2.new(0, 0, 0, 20)
background_2.Size = UDim2.new(0, 360, 0, 185)
background_2.ZIndex = 10
table.insert(shade1,background_2)

Dark_3.Name = "Dark"
Dark_3.Parent = background_2
Dark_3.Active = true
Dark_3.BackgroundColor3 = Color3.fromRGB(32, 18, 64)
Dark_3.BorderSizePixel = 0
Dark_3.Position = UDim2.new(0, 135, 0, 0)
Dark_3.Size = UDim2.new(0, 2, 0, 185)
Dark_3.ZIndex = 10
table.insert(shade2,Dark_3)

Directions.Name = "Directions"
Directions.Parent = background_2
Directions.BackgroundTransparency = 1
Directions.BorderSizePixel = 0
Directions.Position = UDim2.new(0, 10, 0, 15)
Directions.Size = UDim2.new(0, 115, 0, 90)
Directions.ZIndex = 10
Directions.Font = Enum.Font.SourceSans
Directions.Text = "Click the button below and press a key/mouse button. Then select what you want to bind it to."
Directions.TextColor3 = Color3.fromRGB(255, 255, 255)
Directions.TextSize = 14.000
Directions.TextWrapped = true
Directions.TextYAlignment = Enum.TextYAlignment.Top
table.insert(text1,Directions)

BindTo.Name = "BindTo"
BindTo.Parent = background_2
BindTo.BackgroundColor3 = Color3.fromRGB(32, 18, 64)
BindTo.BorderSizePixel = 0
BindTo.Position = UDim2.new(0, 10, 0, 95)
BindTo.Size = UDim2.new(0, 115, 0, 50)
BindTo.ZIndex = 10
BindTo.Font = Enum.Font.SourceSans
BindTo.Text = "Click to bind"
BindTo.TextColor3 = Color3.fromRGB(255, 255, 255)
BindTo.TextSize = 16.000
table.insert(shade2,BindTo)
table.insert(text1,BindTo)

TriggerLabel.Name = "TriggerLabel"
TriggerLabel.Parent = background_2
TriggerLabel.BackgroundTransparency = 1
TriggerLabel.Position = UDim2.new(0, 10, 0, 155)
TriggerLabel.Size = UDim2.new(0, 45, 0, 20)
TriggerLabel.ZIndex = 10
TriggerLabel.Font = Enum.Font.SourceSans
TriggerLabel.Text = "Trigger:"
TriggerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TriggerLabel.TextSize = 14.000
TriggerLabel.TextXAlignment = Enum.TextXAlignment.Left
table.insert(text1,TriggerLabel)

BindTriggerSelect.Name = "BindTo"
BindTriggerSelect.Parent = background_2
BindTriggerSelect.BackgroundColor3 = Color3.fromRGB(32, 18, 64)
BindTriggerSelect.BorderSizePixel = 0
BindTriggerSelect.Position = UDim2.new(0, 60, 0, 155)
BindTriggerSelect.Size = UDim2.new(0, 65, 0, 20)
BindTriggerSelect.ZIndex = 10
BindTriggerSelect.Font = Enum.Font.SourceSans
BindTriggerSelect.Text = "KeyDown"
BindTriggerSelect.TextColor3 = Color3.fromRGB(255, 255, 255)
BindTriggerSelect.TextSize = 16.000
table.insert(shade2,BindTriggerSelect)
table.insert(text1,BindTriggerSelect)

Add_2.Name = "Add"
Add_2.Parent = background_2
Add_2.BackgroundColor3 = Color3.fromRGB(32, 18, 64)
Add_2.BorderSizePixel = 0
Add_2.Position = UDim2.new(0, 310, 0, 35)
Add_2.Size = UDim2.new(0, 40, 0, 20)
Add_2.ZIndex = 10
Add_2.Font = Enum.Font.SourceSans
Add_2.Text = "Add"
Add_2.TextColor3 = Color3.fromRGB(255, 255, 255)
Add_2.TextSize = 14.000
table.insert(shade2,Add_2)
table.insert(text1,Add_2)

Toggles.Name = "Toggles"
Toggles.Parent = background_2
Toggles.BackgroundTransparency = 1
Toggles.BorderSizePixel = 0
Toggles.Position = UDim2.new(0, 150, 0, 125)
Toggles.Size = UDim2.new(0, 200, 0, 50)
Toggles.ZIndex = 10
Toggles.BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
Toggles.CanvasSize = UDim2.new(0, 0, 0, 50)
Toggles.ScrollBarThickness = 8
Toggles.TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
Toggles.VerticalScrollBarInset = Enum.ScrollBarInset.Always
table.insert(scroll,Toggles)

ClickTP.Name = "Click TP (Hold Key & Click)"
ClickTP.Parent = Toggles
ClickTP.BackgroundColor3 = Color3.fromRGB(32, 18, 64)
ClickTP.BorderSizePixel = 0
ClickTP.Size = UDim2.new(0, 200, 0, 20)
ClickTP.ZIndex = 10
ClickTP.Font = Enum.Font.SourceSans
ClickTP.Text = "    Click TP (Hold Key & Click)"
ClickTP.TextColor3 = Color3.fromRGB(255, 255, 255)
ClickTP.TextSize = 14.000
ClickTP.TextXAlignment = Enum.TextXAlignment.Left
table.insert(shade2,ClickTP)
table.insert(text1,ClickTP)

Select.Name = "Select"
Select.Parent = ClickTP
Select.BackgroundColor3 = Color3.fromRGB(86, 50, 160)
Select.BorderSizePixel = 0
Select.Position = UDim2.new(0, 160, 0, 0)
Select.Size = UDim2.new(0, 40, 0, 20)
Select.ZIndex = 10
Select.Font = Enum.Font.SourceSans
Select.Text = "Add"
Select.TextColor3 = Color3.fromRGB(0, 0, 0)
Select.TextSize = 14.000
table.insert(shade3,Select)
table.insert(text2,Select)

ClickDelete.Name = "Click Delete (Hold Key & Click)"
ClickDelete.Parent = Toggles
ClickDelete.BackgroundColor3 = Color3.fromRGB(32, 18, 64)
ClickDelete.BorderSizePixel = 0
ClickDelete.Position = UDim2.new(0, 0, 0, 25)
ClickDelete.Size = UDim2.new(0, 200, 0, 20)
ClickDelete.ZIndex = 10
ClickDelete.Font = Enum.Font.SourceSans
ClickDelete.Text = "    Click Delete (Hold Key & Click)"
ClickDelete.TextColor3 = Color3.fromRGB(255, 255, 255)
ClickDelete.TextSize = 14.000
ClickDelete.TextXAlignment = Enum.TextXAlignment.Left
table.insert(shade2,ClickDelete)
table.insert(text1,ClickDelete)

Select_2.Name = "Select"
Select_2.Parent = ClickDelete
Select_2.BackgroundColor3 = Color3.fromRGB(86, 50, 160)
Select_2.BorderSizePixel = 0
Select_2.Position = UDim2.new(0, 160, 0, 0)
Select_2.Size = UDim2.new(0, 40, 0, 20)
Select_2.ZIndex = 10
Select_2.Font = Enum.Font.SourceSans
Select_2.Text = "Add"
Select_2.TextColor3 = Color3.fromRGB(0, 0, 0)
Select_2.TextSize = 14.000
table.insert(shade3,Select_2)
table.insert(text2,Select_2)

Cmdbar_2.Name = "Cmdbar_2"
Cmdbar_2.Parent = background_2
Cmdbar_2.BackgroundColor3 = Color3.fromRGB(32, 18, 64)
Cmdbar_2.BorderSizePixel = 0
Cmdbar_2.Position = UDim2.new(0, 150, 0, 35)
Cmdbar_2.Size = UDim2.new(0, 150, 0, 20)
Cmdbar_2.ZIndex = 10
Cmdbar_2.Font = Enum.Font.SourceSans
Cmdbar_2.PlaceholderText = "Command"
Cmdbar_2.Text = ""
Cmdbar_2.TextColor3 = Color3.fromRGB(255, 255, 255)
Cmdbar_2.TextSize = 14.000
Cmdbar_2.TextXAlignment = Enum.TextXAlignment.Left

Cmdbar_3.Name = "Cmdbar_3"
Cmdbar_3.Parent = background_2
Cmdbar_3.BackgroundColor3 = Color3.fromRGB(32, 18, 64)
Cmdbar_3.BorderSizePixel = 0
Cmdbar_3.Position = UDim2.new(0, 150, 0, 60)
Cmdbar_3.Size = UDim2.new(0, 150, 0, 20)
Cmdbar_3.ZIndex = 10
Cmdbar_3.Font = Enum.Font.SourceSans
Cmdbar_3.PlaceholderText = "Command 2"
Cmdbar_3.Text = ""
Cmdbar_3.TextColor3 = Color3.fromRGB(255, 255, 255)
Cmdbar_3.TextSize = 14.000
Cmdbar_3.TextXAlignment = Enum.TextXAlignment.Left

CreateToggle.Name = "CreateToggle"
CreateToggle.Parent = background_2
CreateToggle.BackgroundColor3 = Color3.fromRGB(32, 18, 64)
CreateToggle.BackgroundTransparency = 1
CreateToggle.BorderSizePixel = 0
CreateToggle.Position = UDim2.new(0, 152, 0, 10)
CreateToggle.Size = UDim2.new(0, 198, 0, 20)
CreateToggle.ZIndex = 10
CreateToggle.Font = Enum.Font.SourceSans
CreateToggle.Text = "Create Toggle"
CreateToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
CreateToggle.TextSize = 14.000
CreateToggle.TextXAlignment = Enum.TextXAlignment.Left
table.insert(text1,CreateToggle)

Button_2.Name = "Button"
Button_2.Parent = CreateToggle
Button_2.BackgroundColor3 = Color3.fromRGB(86, 50, 160)
Button_2.BorderSizePixel = 0
Button_2.Position = UDim2.new(1, -20, 0, 0)
Button_2.Size = UDim2.new(0, 20, 0, 20)
Button_2.ZIndex = 10
table.insert(shade3,Button_2)

On_2.Name = "On"
On_2.Parent = Button_2
On_2.BackgroundColor3 = Color3.fromRGB(150, 150, 151)
On_2.BackgroundTransparency = 1
On_2.BorderSizePixel = 0
On_2.Position = UDim2.new(0, 2, 0, 2)
On_2.Size = UDim2.new(0, 16, 0, 16)
On_2.ZIndex = 10
On_2.Font = Enum.Font.SourceSans
On_2.Text = ""
On_2.TextColor3 = Color3.fromRGB(0, 0, 0)
On_2.TextSize = 14.000

shadow_2.Name = "shadow"
shadow_2.Parent = KeybindEditor
shadow_2.BackgroundColor3 = Color3.fromRGB(32, 18, 64)
shadow_2.BorderSizePixel = 0
shadow_2.Size = UDim2.new(0, 360, 0, 20)
shadow_2.ZIndex = 10
table.insert(shade2,shadow_2)

PopupText_2.Name = "PopupText_2"
PopupText_2.Parent = shadow_2
PopupText_2.BackgroundTransparency = 1
PopupText_2.Size = UDim2.new(1, 0, 0.949999988, 0)
PopupText_2.ZIndex = 10
PopupText_2.Font = Enum.Font.SourceSans
PopupText_2.Text = "Set Keybinds"
PopupText_2.TextColor3 = Color3.fromRGB(255, 255, 255)
PopupText_2.TextSize = 14.000
PopupText_2.TextWrapped = true
table.insert(text1,PopupText_2)

Exit_2.Name = "Exit_2"
Exit_2.Parent = shadow_2
Exit_2.BackgroundTransparency = 1
Exit_2.Position = UDim2.new(1, -20, 0, 0)
Exit_2.Size = UDim2.new(0, 20, 0, 20)
Exit_2.ZIndex = 10
Exit_2.Text = ""

ExitImage_2.Parent = Exit_2
ExitImage_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ExitImage_2.BackgroundTransparency = 1
ExitImage_2.Position = UDim2.new(0, 5, 0, 5)
ExitImage_2.Size = UDim2.new(0, 10, 0, 10)
ExitImage_2.ZIndex = 10
ExitImage_2.Image = getcustomasset("infiniteyield/assets/close.png")

PositionsFrame.Name = "PositionsFrame"
PositionsFrame.Parent = Settings
PositionsFrame.Active = true
PositionsFrame.BackgroundColor3 = Color3.fromRGB(16, 10, 34)
PositionsFrame.BorderSizePixel = 0
PositionsFrame.Size = UDim2.new(0, 250, 0, 175)
PositionsFrame.Position = UDim2.new(0, 0, 0, 175)
PositionsFrame.ZIndex = 10
table.insert(shade1,PositionsFrame)

Close_3.Name = "Close"
Close_3.Parent = PositionsFrame
Close_3.BackgroundColor3 = Color3.fromRGB(32, 18, 64)
Close_3.BorderSizePixel = 0
Close_3.Position = UDim2.new(0, 205, 0, 150)
Close_3.Size = UDim2.new(0, 40, 0, 20)
Close_3.Font = Enum.Font.SourceSans
Close_3.TextSize = 14
Close_3.Text = "Close"
Close_3.TextColor3 = Color3.new(1, 1, 1)
Close_3.ZIndex = 10
table.insert(shade2,Close_3)
table.insert(text1,Close_3)

Delete_5.Name = "Delete"
Delete_5.Parent = PositionsFrame
Delete_5.BackgroundColor3 = Color3.fromRGB(32, 18, 64)
Delete_5.BorderSizePixel = 0
Delete_5.Position = UDim2.new(0, 50, 0, 150)
Delete_5.Size = UDim2.new(0, 40, 0, 20)
Delete_5.Font = Enum.Font.SourceSans
Delete_5.TextSize = 14
Delete_5.Text = "Clear"
Delete_5.TextColor3 = Color3.new(1, 1, 1)
Delete_5.ZIndex = 10
table.insert(shade2,Delete_5)
table.insert(text1,Delete_5)

Part.Name = "PartGoto"
Part.Parent = PositionsFrame
Part.BackgroundColor3 = Color3.fromRGB(32, 18, 64)
Part.BorderSizePixel = 0
Part.Position = UDim2.new(0, 5, 0, 150)
Part.Size = UDim2.new(0, 40, 0, 20)
Part.Font = Enum.Font.SourceSans
Part.TextSize = 14
Part.Text = "Part"
Part.TextColor3 = Color3.new(1, 1, 1)
Part.ZIndex = 10
table.insert(shade2,Part)
table.insert(text1,Part)

Holder_4.Name = "Holder"
Holder_4.Parent = PositionsFrame
Holder_4.BackgroundTransparency = 1
Holder_4.BorderSizePixel = 0
Holder_4.Position = UDim2.new(0, 0, 0, 0)
Holder_4.Selectable = false
Holder_4.Size = UDim2.new(0, 250, 0, 145)
Holder_4.ScrollBarImageColor3 = Color3.fromRGB(86, 50, 160)
Holder_4.BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
Holder_4.CanvasSize = UDim2.new(0, 0, 0, 0)
Holder_4.MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
Holder_4.ScrollBarThickness = 0
Holder_4.TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
Holder_4.VerticalScrollBarInset = 'Always'
Holder_4.ZIndex = 10

Example_4.Name = "Example"
Example_4.Parent = PositionsFrame
Example_4.BackgroundColor3 = Color3.fromRGB(32, 18, 64)
Example_4.BorderSizePixel = 0
Example_4.Size = UDim2.new(0, 10, 0, 20)
Example_4.Visible = false
Example_4.Position = UDim2.new(0, 0, 0, -5)
Example_4.ZIndex = 10
table.insert(shade2,Example_4)

Text_5.Name = "Text"
Text_5.Parent = Example_4
Text_5.BackgroundColor3 = Color3.fromRGB(32, 18, 64)
Text_5.BorderSizePixel = 0
Text_5.Position = UDim2.new(0, 10, 0, 0)
Text_5.Size = UDim2.new(0, 240, 0, 20)
Text_5.Font = Enum.Font.SourceSans
Text_5.TextSize = 14
Text_5.Text = "Position"
Text_5.TextColor3 = Color3.new(1, 1, 1)
Text_5.TextXAlignment = Enum.TextXAlignment.Left
Text_5.ZIndex = 10
table.insert(shade2,Text_5)
table.insert(text1,Text_5)

Delete_6.Name = "Delete"
Delete_6.Parent = Text_5
Delete_6.BackgroundColor3 = Color3.fromRGB(86, 50, 160)
Delete_6.BorderSizePixel = 0
Delete_6.Position = UDim2.new(0, 200, 0, 0)
Delete_6.Size = UDim2.new(0, 40, 0, 20)
Delete_6.Font = Enum.Font.SourceSans
Delete_6.TextSize = 14
Delete_6.Text = "Delete"
Delete_6.TextColor3 = Color3.new(0, 0, 0)
Delete_6.ZIndex = 10
table.insert(shade3,Delete_6)
table.insert(text2,Delete_6)

TP.Name = "TP"
TP.Parent = Text_5
TP.BackgroundColor3 = Color3.fromRGB(86, 50, 160)
TP.BorderSizePixel = 0
TP.Position = UDim2.new(0, 155, 0, 0)
TP.Size = UDim2.new(0, 40, 0, 20)
TP.Font = Enum.Font.SourceSans
TP.TextSize = 14
TP.Text = "Goto"
TP.TextColor3 = Color3.new(0, 0, 0)
TP.ZIndex = 10
table.insert(shade3,TP)
table.insert(text2,TP)

AliasesFrame.Name = "AliasesFrame"
AliasesFrame.Parent = Settings
AliasesFrame.Active = true
AliasesFrame.BackgroundColor3 = Color3.fromRGB(16, 10, 34)
AliasesFrame.BorderSizePixel = 0
AliasesFrame.Position = UDim2.new(0, 0, 0, 175)
AliasesFrame.Size = UDim2.new(0, 250, 0, 175)
AliasesFrame.ZIndex = 10
table.insert(shade1,AliasesFrame)

Close_2.Name = "Close"
Close_2.Parent = AliasesFrame
Close_2.BackgroundColor3 = Color3.fromRGB(32, 18, 64)
Close_2.BorderSizePixel = 0
Close_2.Position = UDim2.new(0, 205, 0, 150)
Close_2.Size = UDim2.new(0, 40, 0, 20)
Close_2.Font = Enum.Font.SourceSans
Close_2.TextSize = 14
Close_2.Text = "Close"
Close_2.TextColor3 = Color3.new(1, 1, 1)
Close_2.ZIndex = 10
table.insert(shade2,Close_2)
table.insert(text1,Close_2)

Delete_3.Name = "Delete"
Delete_3.Parent = AliasesFrame
Delete_3.BackgroundColor3 = Color3.fromRGB(32, 18, 64)
Delete_3.BorderSizePixel = 0
Delete_3.Position = UDim2.new(0, 5, 0, 150)
Delete_3.Size = UDim2.new(0, 40, 0, 20)
Delete_3.Font = Enum.Font.SourceSans
Delete_3.TextSize = 14
Delete_3.Text = "Clear"
Delete_3.TextColor3 = Color3.new(1, 1, 1)
Delete_3.ZIndex = 10
table.insert(shade2,Delete_3)
table.insert(text1,Delete_3)

Holder_3.Name = "Holder"
Holder_3.Parent = AliasesFrame
Holder_3.BackgroundTransparency = 1
Holder_3.BorderSizePixel = 0
Holder_3.Position = UDim2.new(0, 0, 0, 0)
Holder_3.Size = UDim2.new(0, 250, 0, 145)
Holder_3.ScrollBarImageColor3 = Color3.fromRGB(86, 50, 160)
Holder_3.BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
Holder_3.CanvasSize = UDim2.new(0, 0, 0, 0)
Holder_3.MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
Holder_3.ScrollBarThickness = 0
Holder_3.TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
Holder_3.VerticalScrollBarInset = 'Always'
Holder_3.ZIndex = 10

Example_3.Name = "Example"
Example_3.Parent = AliasesFrame
Example_3.BackgroundColor3 = Color3.fromRGB(32, 18, 64)
Example_3.BorderSizePixel = 0
Example_3.Size = UDim2.new(0, 10, 0, 20)
Example_3.Visible = false
Example_3.ZIndex = 10
table.insert(shade2,Example_3)

Text_4.Name = "Text"
Text_4.Parent = Example_3
Text_4.BackgroundColor3 = Color3.fromRGB(32, 18, 64)
Text_4.BorderSizePixel = 0
Text_4.Position = UDim2.new(0, 10, 0, 0)
Text_4.Size = UDim2.new(0, 240, 0, 20)
Text_4.Font = Enum.Font.SourceSans
Text_4.TextSize = 14
Text_4.Text = "honk"
Text_4.TextColor3 = Color3.new(1, 1, 1)
Text_4.TextXAlignment = Enum.TextXAlignment.Left
Text_4.ZIndex = 10
table.insert(shade2,Text_4)
table.insert(text1,Text_4)

Delete_4.Name = "Delete"
Delete_4.Parent = Text_4
Delete_4.BackgroundColor3 = Color3.fromRGB(86, 50, 160)
Delete_4.BorderSizePixel = 0
Delete_4.Position = UDim2.new(0, 200, 0, 0)
Delete_4.Size = UDim2.new(0, 40, 0, 20)
Delete_4.Font = Enum.Font.SourceSans
Delete_4.TextSize = 14
Delete_4.Text = "Delete"
Delete_4.TextColor3 = Color3.new(0, 0, 0)
Delete_4.ZIndex = 10
table.insert(shade3,Delete_4)
table.insert(text2,Delete_4)

PluginsFrame.Name = "PluginsFrame"
PluginsFrame.Parent = Settings
PluginsFrame.Active = true
PluginsFrame.BackgroundColor3 = Color3.fromRGB(16, 10, 34)
PluginsFrame.BorderSizePixel = 0
PluginsFrame.Position = UDim2.new(0, 0, 0, 175)
PluginsFrame.Size = UDim2.new(0, 250, 0, 175)
PluginsFrame.ZIndex = 10
table.insert(shade1,PluginsFrame)

Close_4.Name = "Close"
Close_4.Parent = PluginsFrame
Close_4.BackgroundColor3 = Color3.fromRGB(32, 18, 64)
Close_4.BorderSizePixel = 0
Close_4.Position = UDim2.new(0, 205, 0, 150)
Close_4.Size = UDim2.new(0, 40, 0, 20)
Close_4.Font = Enum.Font.SourceSans
Close_4.TextSize = 14
Close_4.Text = "Close"
Close_4.TextColor3 = Color3.new(1, 1, 1)
Close_4.ZIndex = 10
table.insert(shade2,Close_4)
table.insert(text1,Close_4)

Add_3.Name = "Add"
Add_3.Parent = PluginsFrame
Add_3.BackgroundColor3 = Color3.fromRGB(32, 18, 64)
Add_3.BorderSizePixel = 0
Add_3.Position = UDim2.new(0, 5, 0, 150)
Add_3.Size = UDim2.new(0, 40, 0, 20)
Add_3.Font = Enum.Font.SourceSans
Add_3.TextSize = 14
Add_3.Text = "Add"
Add_3.TextColor3 = Color3.new(1, 1, 1)
Add_3.ZIndex = 10
table.insert(shade2,Add_3)
table.insert(text1,Add_3)

Holder_5.Name = "Holder"
Holder_5.Parent = PluginsFrame
Holder_5.BackgroundTransparency = 1
Holder_5.BorderSizePixel = 0
Holder_5.Position = UDim2.new(0, 0, 0, 0)
Holder_5.Selectable = false
Holder_5.Size = UDim2.new(0, 250, 0, 145)
Holder_5.ScrollBarImageColor3 = Color3.fromRGB(86, 50, 160)
Holder_5.BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
Holder_5.CanvasSize = UDim2.new(0, 0, 0, 0)
Holder_5.MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
Holder_5.ScrollBarThickness = 0
Holder_5.TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
Holder_5.VerticalScrollBarInset = 'Always'
Holder_5.ZIndex = 10

Example_5.Name = "Example"
Example_5.Parent = PluginsFrame
Example_5.BackgroundColor3 = Color3.fromRGB(32, 18, 64)
Example_5.BorderSizePixel = 0
Example_5.Size = UDim2.new(0, 10, 0, 20)
Example_5.Visible = false
Example_5.ZIndex = 10
table.insert(shade2,Example_5)

Text_6.Name = "Text"
Text_6.Parent = Example_5
Text_6.BackgroundColor3 = Color3.fromRGB(32, 18, 64)
Text_6.BorderSizePixel = 0
Text_6.Position = UDim2.new(0, 10, 0, 0)
Text_6.Size = UDim2.new(0, 240, 0, 20)
Text_6.Font = Enum.Font.SourceSans
Text_6.TextSize = 14
Text_6.Text = "F4 > Toggle Fly"
Text_6.TextColor3 = Color3.new(1, 1, 1)
Text_6.TextXAlignment = Enum.TextXAlignment.Left
Text_6.ZIndex = 10
table.insert(shade2,Text_6)
table.insert(text1,Text_6)

Delete_7.Name = "Delete"
Delete_7.Parent = Text_6
Delete_7.BackgroundColor3 = Color3.fromRGB(86, 50, 160)
Delete_7.BorderSizePixel = 0
Delete_7.Position = UDim2.new(0, 200, 0, 0)
Delete_7.Size = UDim2.new(0, 40, 0, 20)
Delete_7.Font = Enum.Font.SourceSans
Delete_7.TextSize = 14
Delete_7.Text = "Delete"
Delete_7.TextColor3 = Color3.new(0, 0, 0)
Delete_7.ZIndex = 10
table.insert(shade3,Delete_7)
table.insert(text2,Delete_7)

PluginEditor.Name = randomString()
PluginEditor.Parent = ScaledHolder
PluginEditor.BorderSizePixel = 0
PluginEditor.Active = true
PluginEditor.BackgroundTransparency = 1
PluginEditor.Position = UDim2.new(0.5, -180, 0, -500)
PluginEditor.Size = UDim2.new(0, 360, 0, 20)
PluginEditor.ZIndex = 10

background_3.Name = "background"
background_3.Parent = PluginEditor
background_3.Active = true
background_3.BackgroundColor3 = Color3.fromRGB(16, 10, 34)
background_3.BorderSizePixel = 0
background_3.Position = UDim2.new(0, 0, 0, 20)
background_3.Size = UDim2.new(0, 360, 0, 160)
background_3.ZIndex = 10
table.insert(shade1,background_3)

Dark_2.Name = "Dark"
Dark_2.Parent = background_3
Dark_2.Active = true
Dark_2.BackgroundColor3 = Color3.fromRGB(32, 18, 64)
Dark_2.BorderSizePixel = 0
Dark_2.Position = UDim2.new(0, 222, 0, 0)
Dark_2.Size = UDim2.new(0, 2, 0, 160)
Dark_2.ZIndex = 10
table.insert(shade2,Dark_2)

Img.Name = "Img"
Img.Parent = background_3
Img.BackgroundTransparency = 1
Img.Position = UDim2.new(0, 242, 0, 3)
Img.Size = UDim2.new(0, 100, 0, 95)
Img.Image = getcustomasset("infiniteyield/assets/imgstudiopluginlogo.png")
Img.ZIndex = 10

AddPlugin.Name = "AddPlugin"
AddPlugin.Parent = background_3
AddPlugin.BackgroundColor3 = Color3.fromRGB(32, 18, 64)
AddPlugin.BorderSizePixel = 0
AddPlugin.Position = UDim2.new(0, 235, 0, 100)
AddPlugin.Size = UDim2.new(0, 115, 0, 50)
AddPlugin.Font = Enum.Font.SourceSans
AddPlugin.TextSize = 14
AddPlugin.Text = "Add Plugin"
AddPlugin.TextColor3 = Color3.new(1, 1, 1)
AddPlugin.ZIndex = 10
table.insert(shade2,AddPlugin)
table.insert(text1,AddPlugin)

FileName.Name = "FileName"
FileName.Parent = background_3
FileName.BackgroundColor3 = Color3.fromRGB(32, 18, 64)
FileName.BorderSizePixel = 0
FileName.Position = UDim2.new(0.028, 0, 0.625, 0)
FileName.Size = UDim2.new(0, 200, 0, 50)
FileName.Font = Enum.Font.SourceSans
FileName.TextSize = 14
FileName.Text = "Plugin File Name"
FileName.TextColor3 = Color3.new(1, 1, 1)
FileName.ZIndex = 10
table.insert(shade2,FileName)
table.insert(text1,FileName)

About.Name = "About"
About.Parent = background_3
About.BackgroundTransparency = 1
About.BorderSizePixel = 0
About.Position = UDim2.new(0, 17, 0, 10)
About.Size = UDim2.new(0, 187, 0, 49)
About.Font = Enum.Font.SourceSans
About.TextSize = 14
About.Text = "Plugins are .iy files and should be located in the 'workspace' folder of your exploit."
About.TextColor3 = Color3.fromRGB(255, 255, 255)
About.TextWrapped = true
About.TextYAlignment = Enum.TextYAlignment.Top
About.ZIndex = 10
table.insert(text1,About)

Directions_2.Name = "Directions"
Directions_2.Parent = background_3
Directions_2.BackgroundTransparency = 1
Directions_2.BorderSizePixel = 0
Directions_2.Position = UDim2.new(0, 17, 0, 60)
Directions_2.Size = UDim2.new(0, 187, 0, 49)
Directions_2.Font = Enum.Font.SourceSans
Directions_2.TextSize = 14
Directions_2.Text = "Type the name of the plugin file you want to add below."
Directions_2.TextColor3 = Color3.fromRGB(255, 255, 255)
Directions_2.TextWrapped = true
Directions_2.TextYAlignment = Enum.TextYAlignment.Top
Directions_2.ZIndex = 10
table.insert(text1,Directions_2)

shadow_3.Name = "shadow"
shadow_3.Parent = PluginEditor
shadow_3.BackgroundColor3 = Color3.fromRGB(32, 18, 64)
shadow_3.BorderSizePixel = 0
shadow_3.Size = UDim2.new(0, 360, 0, 20)
shadow_3.ZIndex = 10
table.insert(shade2,shadow_3)

PopupText_3.Name = "PopupText"
PopupText_3.Parent = shadow_3
PopupText_3.BackgroundTransparency = 1
PopupText_3.Size = UDim2.new(1, 0, 0.95, 0)
PopupText_3.ZIndex = 10
PopupText_3.Font = Enum.Font.SourceSans
PopupText_3.TextSize = 14
PopupText_3.Text = "Add Plugins"
PopupText_3.TextColor3 = Color3.new(1, 1, 1)
PopupText_3.TextWrapped = true
table.insert(text1,PopupText_3)

Exit_3.Name = "Exit"
Exit_3.Parent = shadow_3
Exit_3.BackgroundTransparency = 1
Exit_3.Position = UDim2.new(1, -20, 0, 0)
Exit_3.Size = UDim2.new(0, 20, 0, 20)
Exit_3.Text = ""
Exit_3.ZIndex = 10

ExitImage_3.Parent = Exit_3
ExitImage_3.BackgroundColor3 = Color3.new(1, 1, 1)
ExitImage_3.BackgroundTransparency = 1
ExitImage_3.Position = UDim2.new(0, 5, 0, 5)
ExitImage_3.Size = UDim2.new(0, 10, 0, 10)
ExitImage_3.Image = getcustomasset("infiniteyield/assets/close.png")
ExitImage_3.ZIndex = 10

AliasHint.Name = "AliasHint"
AliasHint.Parent = AliasesFrame
AliasHint.BackgroundTransparency = 1
AliasHint.BorderSizePixel = 0
AliasHint.Position = UDim2.new(0, 25, 0, 40)
AliasHint.Size = UDim2.new(0, 200, 0, 50)
AliasHint.Font = Enum.Font.SourceSansItalic
AliasHint.TextSize = 16
AliasHint.Text = "Add aliases by using the 'addalias' command"
AliasHint.TextColor3 = Color3.new(1, 1, 1)
AliasHint.TextStrokeColor3 = Color3.new(1, 1, 1)
AliasHint.TextWrapped = true
AliasHint.ZIndex = 10
table.insert(text1,AliasHint)

PluginsHint.Name = "PluginsHint"
PluginsHint.Parent = PluginsFrame
PluginsHint.BackgroundTransparency = 1
PluginsHint.BorderSizePixel = 0
PluginsHint.Position = UDim2.new(0, 25, 0, 40)
PluginsHint.Size = UDim2.new(0, 200, 0, 50)
PluginsHint.Font = Enum.Font.SourceSansItalic
PluginsHint.TextSize = 16
PluginsHint.Text = "Download plugins from the IY Discord (discord.gg/78ZuWSq)"
PluginsHint.TextColor3 = Color3.new(1, 1, 1)
PluginsHint.TextStrokeColor3 = Color3.new(1, 1, 1)
PluginsHint.TextWrapped = true
PluginsHint.ZIndex = 10
table.insert(text1,PluginsHint)

PositionsHint.Name = "PositionsHint"
PositionsHint.Parent = PositionsFrame
PositionsHint.BackgroundTransparency = 1
PositionsHint.BorderSizePixel = 0
PositionsHint.Position = UDim2.new(0, 25, 0, 40)
PositionsHint.Size = UDim2.new(0, 200, 0, 70)
PositionsHint.Font = Enum.Font.SourceSansItalic
PositionsHint.TextSize = 16
PositionsHint.Text = "Use the 'swp' or 'setwaypoint' command to add a position using your character (NOTE: Part teleports will not save)"
PositionsHint.TextColor3 = Color3.new(1, 1, 1)
PositionsHint.TextStrokeColor3 = Color3.new(1, 1, 1)
PositionsHint.TextWrapped = true
PositionsHint.ZIndex = 10
table.insert(text1,PositionsHint)

ToPartFrame.Name = randomString()
ToPartFrame.Parent = ScaledHolder
ToPartFrame.Active = true
ToPartFrame.BackgroundTransparency = 1
ToPartFrame.Position = UDim2.new(0.5, -180, 0, -500)
ToPartFrame.Size = UDim2.new(0, 360, 0, 20)
ToPartFrame.ZIndex = 10

background_4.Name = "background"
background_4.Parent = ToPartFrame
background_4.Active = true
background_4.BackgroundColor3 = Color3.fromRGB(16, 10, 34)
background_4.BorderSizePixel = 0
background_4.Position = UDim2.new(0, 0, 0, 20)
background_4.Size = UDim2.new(0, 360, 0, 117)
background_4.ZIndex = 10
table.insert(shade1,background_4)

ChoosePart.Name = "ChoosePart"
ChoosePart.Parent = background_4
ChoosePart.BackgroundColor3 = Color3.fromRGB(32, 18, 64)
ChoosePart.BorderSizePixel = 0
ChoosePart.Position = UDim2.new(0, 100, 0, 55)
ChoosePart.Size = UDim2.new(0, 75, 0, 30)
ChoosePart.Font = Enum.Font.SourceSans
ChoosePart.TextSize = 14
ChoosePart.Text = "Select Part"
ChoosePart.TextColor3 = Color3.new(1, 1, 1)
ChoosePart.ZIndex = 10
table.insert(shade2,ChoosePart)
table.insert(text1,ChoosePart)

CopyPath.Name = "CopyPath"
CopyPath.Parent = background_4
CopyPath.BackgroundColor3 = Color3.fromRGB(32, 18, 64)
CopyPath.BorderSizePixel = 0
CopyPath.Position = UDim2.new(0, 185, 0, 55)
CopyPath.Size = UDim2.new(0, 75, 0, 30)
CopyPath.Font = Enum.Font.SourceSans
CopyPath.TextSize = 14
CopyPath.Text = "Copy Path"
CopyPath.TextColor3 = Color3.new(1, 1, 1)
CopyPath.ZIndex = 10
table.insert(shade2,CopyPath)
table.insert(text1,CopyPath)

Directions_3.Name = "Directions"
Directions_3.Parent = background_4
Directions_3.BackgroundTransparency = 1
Directions_3.BorderSizePixel = 0
Directions_3.Position = UDim2.new(0, 51, 0, 17)
Directions_3.Size = UDim2.new(0, 257, 0, 32)
Directions_3.Font = Enum.Font.SourceSans
Directions_3.TextSize = 14
Directions_3.Text = 'Click on a part and then click the "Select Part" button below to set it as a teleport location'
Directions_3.TextColor3 = Color3.new(1, 1, 1)
Directions_3.TextWrapped = true
Directions_3.TextYAlignment = Enum.TextYAlignment.Top
Directions_3.ZIndex = 10
table.insert(text1,Directions_3)

Path.Name = "Path"
Path.Parent = background_4
Path.BackgroundTransparency = 1
Path.BorderSizePixel = 0
Path.Position = UDim2.new(0, 0, 0, 94)
Path.Size = UDim2.new(0, 360, 0, 16)
Path.Font = Enum.Font.SourceSansItalic
Path.TextSize = 14
Path.Text = ""
Path.TextColor3 = Color3.new(1, 1, 1)
Path.TextScaled = true
Path.TextWrapped = true
Path.TextYAlignment = Enum.TextYAlignment.Top
Path.ZIndex = 10
table.insert(text1,Path)

shadow_4.Name = "shadow"
shadow_4.Parent = ToPartFrame
shadow_4.BackgroundColor3 = Color3.fromRGB(32, 18, 64)
shadow_4.BorderSizePixel = 0
shadow_4.Size = UDim2.new(0, 360, 0, 20)
shadow_4.ZIndex = 10
table.insert(shade2,shadow_4)

PopupText_5.Name = "PopupText"
PopupText_5.Parent = shadow_4
PopupText_5.BackgroundTransparency = 1
PopupText_5.Size = UDim2.new(1, 0, 0.95, 0)
PopupText_5.ZIndex = 10
PopupText_5.Font = Enum.Font.SourceSans
PopupText_5.TextSize = 14
PopupText_5.Text = "Teleport to Part"
PopupText_5.TextColor3 = Color3.new(1, 1, 1)
PopupText_5.TextWrapped = true
table.insert(text1,PopupText_5)

Exit_4.Name = "Exit"
Exit_4.Parent = shadow_4
Exit_4.BackgroundTransparency = 1
Exit_4.Position = UDim2.new(1, -20, 0, 0)
Exit_4.Size = UDim2.new(0, 20, 0, 20)
Exit_4.Text = ""
Exit_4.ZIndex = 10

ExitImage_5.Parent = Exit_4
ExitImage_5.BackgroundColor3 = Color3.new(1, 1, 1)
ExitImage_5.BackgroundTransparency = 1
ExitImage_5.Position = UDim2.new(0, 5, 0, 5)
ExitImage_5.Size = UDim2.new(0, 10, 0, 10)
ExitImage_5.Image = getcustomasset("infiniteyield/assets/close.png")
ExitImage_5.ZIndex = 10

logs.Name = randomString()
logs.Parent = ScaledHolder
logs.Active = true
logs.BackgroundTransparency = 1
logs.Position = UDim2.new(0, 0, 1, 10)
logs.Size = UDim2.new(0, 338, 0, 20)
logs.ZIndex = 10

shadow.Name = "shadow"
shadow.Parent = logs
shadow.BackgroundColor3 = Color3.new(0.180392, 0.180392, 0.184314)
shadow.BorderSizePixel = 0
shadow.Position = UDim2.new(0, 0, 0.00999999978, 0)
shadow.Size = UDim2.new(0, 338, 0, 20)
shadow.ZIndex = 10
table.insert(shade2,shadow)

Hide.Name = "Hide"
Hide.Parent = shadow
Hide.BackgroundTransparency = 1
Hide.Position = UDim2.new(1, -40, 0, 0)
Hide.Size = UDim2.new(0, 20, 0, 20)
Hide.ZIndex = 10
Hide.Text = ""

ImageLabel.Parent = Hide
ImageLabel.BackgroundColor3 = Color3.new(1, 1, 1)
ImageLabel.BackgroundTransparency = 1
ImageLabel.Position = UDim2.new(0, 3, 0, 3)
ImageLabel.Size = UDim2.new(0, 14, 0, 14)
ImageLabel.Image = getcustomasset("infiniteyield/assets/minimize.png")
ImageLabel.ZIndex = 10

PopupText.Name = "PopupText"
PopupText.Parent = shadow
PopupText.BackgroundTransparency = 1
PopupText.Size = UDim2.new(1, 0, 0.949999988, 0)
PopupText.ZIndex = 10
PopupText.Font = Enum.Font.SourceSans
PopupText.FontSize = Enum.FontSize.Size14
PopupText.Text = "Logs"
PopupText.TextColor3 = Color3.new(1, 1, 1)
PopupText.TextWrapped = true
table.insert(text1,PopupText)

Exit.Name = "Exit"
Exit.Parent = shadow
Exit.BackgroundTransparency = 1
Exit.Position = UDim2.new(1, -20, 0, 0)
Exit.Size = UDim2.new(0, 20, 0, 20)
Exit.ZIndex = 10
Exit.Text = ""

ImageLabel_2.Parent = Exit
ImageLabel_2.BackgroundColor3 = Color3.new(1, 1, 1)
ImageLabel_2.BackgroundTransparency = 1
ImageLabel_2.Position = UDim2.new(0, 5, 0, 5)
ImageLabel_2.Size = UDim2.new(0, 10, 0, 10)
ImageLabel_2.Image = getcustomasset("infiniteyield/assets/close.png")
ImageLabel_2.ZIndex = 10

background.Name = "background"
background.Parent = logs
background.Active = true
background.BackgroundColor3 = Color3.new(0.141176, 0.141176, 0.145098)
background.BorderSizePixel = 0
background.ClipsDescendants = true
background.Position = UDim2.new(0, 0, 1, 0)
background.Size = UDim2.new(0, 338, 0, 245)
background.ZIndex = 10

chat.Name = "chat"
chat.Parent = background
chat.Active = true
chat.BackgroundColor3 = Color3.new(0.141176, 0.141176, 0.145098)
chat.BorderSizePixel = 0
chat.ClipsDescendants = true
chat.Size = UDim2.new(0, 338, 0, 245)
chat.ZIndex = 10
table.insert(shade1,chat)

Clear.Name = "Clear"
Clear.Parent = chat
Clear.BackgroundColor3 = Color3.new(0.180392, 0.180392, 0.184314)
Clear.BorderSizePixel = 0
Clear.Position = UDim2.new(0, 5, 0, 220)
Clear.Size = UDim2.new(0, 50, 0, 20)
Clear.ZIndex = 10
Clear.Font = Enum.Font.SourceSans
Clear.FontSize = Enum.FontSize.Size14
Clear.Text = "Clear"
Clear.TextColor3 = Color3.new(1, 1, 1)
table.insert(shade2,Clear)
table.insert(text1,Clear)

SaveChatlogs.Name = "SaveChatlogs"
SaveChatlogs.Parent = chat
SaveChatlogs.BackgroundColor3 = Color3.new(0.180392, 0.180392, 0.184314)
SaveChatlogs.BorderSizePixel = 0
SaveChatlogs.Position = UDim2.new(0, 258, 0, 220)
SaveChatlogs.Size = UDim2.new(0, 75, 0, 20)
SaveChatlogs.ZIndex = 10
SaveChatlogs.Font = Enum.Font.SourceSans
SaveChatlogs.FontSize = Enum.FontSize.Size14
SaveChatlogs.Text = "Save To .txt"
SaveChatlogs.TextColor3 = Color3.new(1, 1, 1)
table.insert(shade2,SaveChatlogs)
table.insert(text1,SaveChatlogs)

Toggle.Name = "Toggle"
Toggle.Parent = chat
Toggle.BackgroundColor3 = Color3.new(0.180392, 0.180392, 0.184314)
Toggle.BorderSizePixel = 0
Toggle.Position = UDim2.new(0, 60, 0, 220)
Toggle.Size = UDim2.new(0, 66, 0, 20)
Toggle.ZIndex = 10
Toggle.Font = Enum.Font.SourceSans
Toggle.FontSize = Enum.FontSize.Size14
Toggle.Text = "Disabled"
Toggle.TextColor3 = Color3.new(1, 1, 1)
table.insert(shade2,Toggle)
table.insert(text1,Toggle)

scroll_2.Name = "scroll"
scroll_2.Parent = chat
scroll_2.BackgroundColor3 = Color3.new(0.180392, 0.180392, 0.184314)
scroll_2.BorderSizePixel = 0
scroll_2.Position = UDim2.new(0, 5, 0, 25)
scroll_2.Size = UDim2.new(0, 328, 0, 190)
scroll_2.ZIndex = 10
scroll_2.BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
scroll_2.CanvasSize = UDim2.new(0, 0, 0, 10)
scroll_2.ScrollBarThickness = 8
scroll_2.TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
table.insert(scroll,scroll_2)
table.insert(shade2,scroll_2)

join.Name = "join"
join.Parent = background
join.Active = true
join.BackgroundColor3 = Color3.new(0.141176, 0.141176, 0.145098)
join.BorderSizePixel = 0
join.ClipsDescendants = true
join.Size = UDim2.new(0, 338, 0, 245)
join.Visible = false
join.ZIndex = 10
table.insert(shade1,join)

Toggle_2.Name = "Toggle"
Toggle_2.Parent = join
Toggle_2.BackgroundColor3 = Color3.new(0.180392, 0.180392, 0.184314)
Toggle_2.BorderSizePixel = 0
Toggle_2.Position = UDim2.new(0, 60, 0, 220)
Toggle_2.Size = UDim2.new(0, 66, 0, 20)
Toggle_2.ZIndex = 10
Toggle_2.Font = Enum.Font.SourceSans
Toggle_2.FontSize = Enum.FontSize.Size14
Toggle_2.Text = "Disabled"
Toggle_2.TextColor3 = Color3.new(1, 1, 1)
table.insert(shade2,Toggle_2)
table.insert(text1,Toggle_2)

Clear_2.Name = "Clear"
Clear_2.Parent = join
Clear_2.BackgroundColor3 = Color3.new(0.180392, 0.180392, 0.184314)
Clear_2.BorderSizePixel = 0
Clear_2.Position = UDim2.new(0, 5, 0, 220)
Clear_2.Size = UDim2.new(0, 50, 0, 20)
Clear_2.ZIndex = 10
Clear_2.Font = Enum.Font.SourceSans
Clear_2.FontSize = Enum.FontSize.Size14
Clear_2.Text = "Clear"
Clear_2.TextColor3 = Color3.new(1, 1, 1)
table.insert(shade2,Clear_2)
table.insert(text1,Clear_2)

scroll_3.Name = "scroll"
scroll_3.Parent = join
scroll_3.BackgroundColor3 = Color3.new(0.180392, 0.180392, 0.184314)
scroll_3.BorderSizePixel = 0
scroll_3.Position = UDim2.new(0, 5, 0, 25)
scroll_3.Size = UDim2.new(0, 328, 0, 190)
scroll_3.ZIndex = 10
scroll_3.BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
scroll_3.CanvasSize = UDim2.new(0, 0, 0, 10)
scroll_3.ScrollBarThickness = 8
scroll_3.TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
table.insert(scroll,scroll_3)
table.insert(shade2,scroll_3)

selectChat.Name = "selectChat"
selectChat.Parent = background
selectChat.BackgroundColor3 = Color3.new(0.180392, 0.180392, 0.184314)
selectChat.BorderSizePixel = 0
selectChat.Position = UDim2.new(0, 5, 0, 5)
selectChat.Size = UDim2.new(0, 164, 0, 20)
selectChat.ZIndex = 10
selectChat.Font = Enum.Font.SourceSans
selectChat.FontSize = Enum.FontSize.Size14
selectChat.Text = "Chat Logs"
selectChat.TextColor3 = Color3.new(1, 1, 1)
table.insert(shade2,selectChat)
table.insert(text1,selectChat)

selectJoin.Name = "selectJoin"
selectJoin.Parent = background
selectJoin.BackgroundColor3 = Color3.new(0.305882, 0.305882, 0.309804)
selectJoin.BorderSizePixel = 0
selectJoin.Position = UDim2.new(0, 169, 0, 5)
selectJoin.Size = UDim2.new(0, 164, 0, 20)
selectJoin.ZIndex = 10
selectJoin.Font = Enum.Font.SourceSans
selectJoin.FontSize = Enum.FontSize.Size14
selectJoin.Text = "Join Logs"
selectJoin.TextColor3 = Color3.new(1, 1, 1)
table.insert(shade3,selectJoin)
table.insert(text1,selectJoin)

function create(data)
	local insts = {}
	for i,v in pairs(data) do insts[v[1]] = Instance.new(v[2]) end

	for _,v in pairs(data) do
		for prop,val in pairs(v[3]) do
			if type(val) == "table" then
				insts[v[1]][prop] = insts[val[1]]
			else
				insts[v[1]][prop] = val
			end
		end
	end

	return insts[1]
end

ViewportTextBox = (function()

	local funcs = {}
	funcs.Update = function(self)
		local cursorPos = self.TextBox.CursorPosition
		local text = self.TextBox.Text
		if text == "" then self.TextBox.Position = UDim2.new(0,2,0,0) return end
		if cursorPos == -1 then return end

		local cursorText = text:sub(1,cursorPos-1)
		local pos = nil
		local leftEnd = -self.TextBox.Position.X.Offset
		local rightEnd = leftEnd + self.View.AbsoluteSize.X

		local totalTextSize = TextService:GetTextSize(text,self.TextBox.TextSize,self.TextBox.Font,Vector2.new(999999999,100)).X
		local cursorTextSize = TextService:GetTextSize(cursorText,self.TextBox.TextSize,self.TextBox.Font,Vector2.new(999999999,100)).X

		if cursorTextSize > rightEnd then
			pos = math.max(-2,cursorTextSize - self.View.AbsoluteSize.X + 2)
		elseif cursorTextSize < leftEnd then
			pos = math.max(-2,cursorTextSize-2)
		elseif totalTextSize < rightEnd then
			pos = math.max(-2,totalTextSize - self.View.AbsoluteSize.X + 2)
		end

		if pos then
			self.TextBox.Position = UDim2.new(0,-pos,0,0)
			self.TextBox.Size = UDim2.new(1,pos,1,0)
		end
	end

	local mt = {}
	mt.__index = funcs

	local function convert(textbox)
		local obj = setmetatable({OffsetX = 0, TextBox = textbox},mt)

		local view = Instance.new("Frame")
		view.BackgroundTransparency = textbox.BackgroundTransparency
		view.BackgroundColor3 = textbox.BackgroundColor3
		view.BorderSizePixel = textbox.BorderSizePixel
		view.BorderColor3 = textbox.BorderColor3
		view.Position = textbox.Position
		view.Size = textbox.Size
		view.ClipsDescendants = true
		view.Name = textbox.Name
		view.ZIndex = 10
		textbox.BackgroundTransparency = 1
		textbox.Position = UDim2.new(0,4,0,0)
		textbox.Size = UDim2.new(1,-8,1,0)
		textbox.TextXAlignment = Enum.TextXAlignment.Left
		textbox.Name = "Input"
		table.insert(text1,textbox)
		table.insert(shade2,view)

		obj.View = view

		textbox.Changed:Connect(function(prop)
			if prop == "Text" or prop == "CursorPosition" or prop == "AbsoluteSize" then
				obj:Update()
			end
		end)

		obj:Update()

		view.Parent = textbox.Parent
		textbox.Parent = view

		return obj
	end

	return {convert = convert}
end)()

ViewportTextBox.convert(Cmdbar).View.ZIndex = 10
ViewportTextBox.convert(Cmdbar_2).View.ZIndex = 10
ViewportTextBox.convert(Cmdbar_3).View.ZIndex = 10

function writefileExploit()
	if writefile then
		return true
	end
end

function readfileExploit()
	if readfile then
		return true
	end
end

function isNumber(str)
	if tonumber(str) ~= nil or str == "inf" then
		return true
	end
end

function vtype(o, t)
	if o == nil then return false end
	if type(o) == "userdata" then return typeof(o) == t end
	return type(o) == t
end

function getRoot(char)
	if char and char:FindFirstChildOfClass("Humanoid") then
		return char:FindFirstChildOfClass("Humanoid").RootPart
	else
		return nil
	end
end

function tools(plr)
	if plr:FindFirstChildOfClass("Backpack"):FindFirstChildOfClass("Tool") or plr.Character:FindFirstChildOfClass("Tool") then
		return true
	end
end

function r15(plr)
	if plr.Character:FindFirstChildOfClass("Humanoid").RigType == Enum.HumanoidRigType.R15 then
		return true
	end
end

function breakVelocity()
    local V3 = Vector3.new(0, 0, 0)
    for _, v in ipairs(Players.LocalPlayer.Character:GetDescendants()) do
        if v:IsA("BasePart") then
            v.Velocity, v.RotVelocity = V3, V3
        end
    end
end

function toClipboard(txt)
	if everyClipboard then
		everyClipboard(tostring(txt)) -- some executor errored without tostring btw so dont call me out for this
		notify("Clipboard", "Copied to clipboard")
	else
		notify("Clipboard", "Your exploit doesn't have the ability to use the clipboard")
	end
end

function chatMessage(str)
	str = tostring(str)
	if not isLegacyChat then
		TextChatService.TextChannels.RBXGeneral:SendAsync(str)
	else
		ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(str, "All")
	end
end

function getHierarchy(obj)
	local fullname
	local period

	if string.find(obj.Name,' ') then
		fullname = '["'..obj.Name..'"]'
		period = false
	else
		fullname = obj.Name
		period = true
	end

	local getS = obj
	local parent = obj
	local service = ''

	if getS.Parent ~= game then
		repeat
			getS = getS.Parent
			service = getS.ClassName
		until getS.Parent == game
	end

	if parent.Parent ~= getS then
		repeat
			parent = parent.Parent
			if string.find(tostring(parent),' ') then
				if period then
					fullname = '["'..parent.Name..'"].'..fullname
				else
					fullname = '["'..parent.Name..'"]'..fullname
				end
				period = false
			else
				if period then
					fullname = parent.Name..'.'..fullname
				else
					fullname = parent.Name..''..fullname
				end
				period = true
			end
		until parent.Parent == getS
	elseif string.find(tostring(parent),' ') then
		fullname = '["'..parent.Name..'"]'
		period = false
	end

	if period then
		return 'game:GetService("'..service..'").'..fullname
	else
		return 'game:GetService("'..service..'")'..fullname
	end
end

AllWaypoints = {}

local cooldown = false
function writefileCooldown(name,data)
	task.spawn(function()
		if not cooldown then
			cooldown = true
			writefile(name, data, true)
		else
			repeat wait() until cooldown == false
			writefileCooldown(name,data)
		end
		wait(3)
		cooldown = false
	end)
end

function dragGUI(gui)
	task.spawn(function()
		local dragging
		local dragInput
		local dragStart = Vector3.new(0,0,0)
		local startPos
		local function update(input)
			local delta = input.Position - dragStart
			local Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			TweenService:Create(gui, TweenInfo.new(.20), {Position = Position}):Play()
		end
		gui.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = input.Position
				startPos = gui.Position

				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						dragging = false
					end
				end)
			end
		end)
		gui.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				dragInput = input
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if input == dragInput and dragging then
				update(input)
			end
		end)
	end)
end

dragGUI(logs)
dragGUI(KeybindEditor)
dragGUI(PluginEditor)
dragGUI(ToPartFrame)

eventEditor = (function()
	local events = {}

	local function registerEvent(name,sets)
		events[name] = {
			commands = {},
			sets = sets or {}
		}
	end

	local onEdited = nil

	local function fireEvent(name,...)
		local args = {...}
		local event = events[name]
		if event then
			for i,cmd in pairs(event.commands) do
				local metCondition = true
				for idx,set in pairs(event.sets) do
					local argVal = args[idx]
					local cmdSet = cmd[2][idx]
					local condType = set.Type
					if condType == "Player" then
						if cmdSet == 0 then
							metCondition = metCondition and (tostring(Players.LocalPlayer) == argVal)
						elseif cmdSet ~= 1 then
							metCondition = metCondition and table.find(getPlayer(cmdSet,Players.LocalPlayer),argVal)
						end
					elseif condType == "String" then
						if cmdSet ~= 0 then
							metCondition = metCondition and string.find(argVal:lower(),cmdSet:lower())
						end
					elseif condType == "Number" then
						if cmdSet ~= 0 then
							metCondition = metCondition and tonumber(argVal)<=tonumber(cmdSet)
						end
					end
					if not metCondition then break end
				end

				if metCondition then
					pcall(task.spawn(function()
						local cmdStr = cmd[1]
						for count,arg in pairs(args) do
							cmdStr = cmdStr:gsub("%$"..count,arg)
						end
						if cmdStr:lower():match("plugin") then return end
						wait(cmd[3] or 0)
						execCmd(cmdStr)
					end))
				end
			end
		end
	end

	local main = create({
		{1,"Frame",{BackgroundColor3=Color3.new(0.14117647707462,0.14117647707462,0.14509804546833),BackgroundTransparency=1,BorderSizePixel=0,Name="EventEditor",Position=UDim2.new(0.5,-175,0,-500),Size=UDim2.new(0,350,0,20),ZIndex=10,}},
		{2,"Frame",{BackgroundColor3=currentShade2,BorderSizePixel=0,Name="TopBar",Parent={1},Size=UDim2.new(1,0,0,20),ZIndex=10,}},
		{3,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Title",Parent={2},Position=UDim2.new(0,0,0,0),Size=UDim2.new(1,0,0.95,0),Text="Event Editor",TextColor3=Color3.new(1,1,1),TextSize=14,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=10,}},
		{4,"TextButton",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Close",Parent={2},Position=UDim2.new(1,-20,0,0),Size=UDim2.new(0,20,0,20),Text="",TextColor3=Color3.new(1,1,1),TextSize=14,ZIndex=10,}},
		{5,"ImageLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Image=getcustomasset("infiniteyield/assets/close.png"),Parent={4},Position=UDim2.new(0,5,0,5),Size=UDim2.new(0,10,0,10),ZIndex=10,}},
		{6,"Frame",{BackgroundColor3=currentShade1,BorderSizePixel=0,Name="Content",Parent={1},Position=UDim2.new(0,0,0,20),Size=UDim2.new(1,0,0,202),ZIndex=10,}},
		{7,"ScrollingFrame",{BackgroundColor3=Color3.new(0.14117647707462,0.14117647707462,0.14509804546833),BackgroundTransparency=1,BorderColor3=Color3.new(0.15686275064945,0.15686275064945,0.15686275064945),BorderSizePixel=0,BottomImage="rbxasset://textures/ui/Scroll/scroll-middle.png",CanvasSize=UDim2.new(0,0,0,100),Name="List",Parent={6},Position=UDim2.new(0,5,0,5),ScrollBarImageColor3=Color3.new(0.30588236451149,0.30588236451149,0.3098039329052),ScrollBarThickness=8,Size=UDim2.new(1,-10,1,-10),TopImage="rbxasset://textures/ui/Scroll/scroll-middle.png",ZIndex=10,}},
		{8,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Name="Holder",Parent={7},Size=UDim2.new(1,0,1,0),ZIndex=10,}},
		{9,"UIListLayout",{Parent={8},SortOrder=2,}},
		{10,"Frame",{BackgroundColor3=Color3.new(0.14117647707462,0.14117647707462,0.14509804546833),BackgroundTransparency=1,BorderColor3=Color3.new(0.3137255012989,0.3137255012989,0.3137255012989),BorderSizePixel=0,ClipsDescendants=true,Name="Settings",Parent={6},Position=UDim2.new(1,0,0,0),Size=UDim2.new(0,150,1,0),ZIndex=10,}},
		{11,"Frame",{BackgroundColor3=Color3.new(0.14117647707462,0.14117647707462,0.14509804546833),Name="Slider",Parent={10},Position=UDim2.new(0,-150,0,0),Size=UDim2.new(1,0,1,0),ZIndex=10,}},
		{12,"Frame",{BackgroundColor3=Color3.new(0.23529413342476,0.23529413342476,0.23529413342476),BorderColor3=Color3.new(0.3137255012989,0.3137255012989,0.3137255012989),BorderSizePixel=0,Name="Line",Parent={11},Size=UDim2.new(0,1,1,0),ZIndex=10,}},
		{13,"ScrollingFrame",{BackgroundColor3=Color3.new(0.14117647707462,0.14117647707462,0.14509804546833),BackgroundTransparency=1,BorderColor3=Color3.new(0.15686275064945,0.15686275064945,0.15686275064945),BorderSizePixel=0,BottomImage="rbxasset://textures/ui/Scroll/scroll-middle.png",CanvasSize=UDim2.new(0,0,0,100),Name="List",Parent={11},Position=UDim2.new(0,0,0,25),ScrollBarImageColor3=Color3.new(0.30588236451149,0.30588236451149,0.3098039329052),ScrollBarThickness=8,Size=UDim2.new(1,0,1,-25),TopImage="rbxasset://textures/ui/Scroll/scroll-middle.png",ZIndex=10,}},
		{14,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Name="Holder",Parent={13},Size=UDim2.new(1,0,1,0),ZIndex=10,}},
		{15,"UIListLayout",{Parent={14},SortOrder=2,}},
		{16,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Title",Parent={11},Size=UDim2.new(1,0,0,20),Text="Event Settings",TextColor3=Color3.new(1,1,1),TextSize=14,ZIndex=10,}},
		{17,"TextButton",{BackgroundColor3=Color3.new(0.14117647707462,0.14117647707462,0.14509804546833),BorderColor3=Color3.new(0.15686275064945,0.15686275064945,0.15686275064945),Font=3,Name="Close",BorderSizePixel=0,Parent={11},Position=UDim2.new(1,-20,0,0),Size=UDim2.new(0,20,0,20),Text="<",TextColor3=Color3.new(1,1,1),TextSize=18,ZIndex=10,}},
		{18,"Folder",{Name="Templates",Parent={10},}},
		{19,"Frame",{BackgroundColor3=Color3.new(0.19607844948769,0.19607844948769,0.19607844948769),BackgroundTransparency=1,BorderColor3=Color3.new(0.15686275064945,0.15686275064945,0.15686275064945),Name="Players",Parent={18},Position=UDim2.new(0,0,0,25),Size=UDim2.new(1,0,0,86),Visible=false,ZIndex=10,}},
		{20,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Title",Parent={19},Size=UDim2.new(1,0,0,20),Text="Choose Players",TextColor3=Color3.new(1,1,1),TextSize=14,ZIndex=10,}},
		{21,"TextLabel",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="Any",Parent={19},Position=UDim2.new(0,5,0,42),Size=UDim2.new(1,-10,0,20),Text="Any Player",TextColor3=Color3.new(1,1,1),TextSize=14,TextXAlignment=0,ZIndex=10,}},
		{22,"Frame",{BackgroundColor3=Color3.new(0.30588236451149,0.30588236451149,0.3098039329052),BorderSizePixel=0,Name="Button",Parent={21},Position=UDim2.new(1,-20,0,0),Size=UDim2.new(0,20,0,20),ZIndex=10,}},
		{23,"TextButton",{BackgroundColor3=Color3.new(0.58823531866074,0.58823531866074,0.59215688705444),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="On",Parent={22},Position=UDim2.new(0,2,0,2),Size=UDim2.new(0,16,0,16),Text="",TextColor3=Color3.new(0,0,0),TextSize=14,ZIndex=10,}},
		{24,"TextLabel",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="Me",Parent={19},Position=UDim2.new(0,5,0,20),Size=UDim2.new(1,-10,0,20),Text="Me Only",TextColor3=Color3.new(1,1,1),TextSize=14,TextXAlignment=0,ZIndex=10,}},
		{25,"Frame",{BackgroundColor3=Color3.new(0.30588236451149,0.30588236451149,0.3098039329052),BorderSizePixel=0,Name="Button",Parent={24},Position=UDim2.new(1,-20,0,0),Size=UDim2.new(0,20,0,20),ZIndex=10,}},
		{26,"TextButton",{BackgroundColor3=Color3.new(0.58823531866074,0.58823531866074,0.59215688705444),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="On",Parent={25},Position=UDim2.new(0,2,0,2),Size=UDim2.new(0,16,0,16),Text="",TextColor3=Color3.new(0,0,0),TextSize=14,ZIndex=10,}},
		{27,"TextBox",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BorderColor3=Color3.new(0.15686275064945,0.15686275064945,0.15686275064945),BorderSizePixel=0,ClearTextOnFocus=false,Font=3,Name="Custom",Parent={19},PlaceholderColor3=Color3.new(0.47058826684952,0.47058826684952,0.47058826684952),PlaceholderText="Custom Player Set",Position=UDim2.new(0,5,0,64),Size=UDim2.new(1,-35,0,20),Text="",TextColor3=Color3.new(1,1,1),TextSize=14,TextXAlignment=0,ZIndex=10,}},
		{28,"Frame",{BackgroundColor3=Color3.new(0.30588236451149,0.30588236451149,0.3098039329052),BorderSizePixel=0,Name="CustomButton",Parent={19},Position=UDim2.new(1,-25,0,64),Size=UDim2.new(0,20,0,20),ZIndex=10,}},
		{29,"TextButton",{BackgroundColor3=Color3.new(0.58823531866074,0.58823531866074,0.59215688705444),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="On",Parent={28},Position=UDim2.new(0,2,0,2),Size=UDim2.new(0,16,0,16),Text="",TextColor3=Color3.new(0,0,0),TextSize=14,ZIndex=10,}},
		{30,"Frame",{BackgroundColor3=Color3.new(0.19607844948769,0.19607844948769,0.19607844948769),BackgroundTransparency=1,BorderColor3=Color3.new(0.15686275064945,0.15686275064945,0.15686275064945),Name="Strings",Parent={18},Position=UDim2.new(0,0,0,25),Size=UDim2.new(1,0,0,64),Visible=false,ZIndex=10,}},
		{31,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Title",Parent={30},Size=UDim2.new(1,0,0,20),Text="Choose String",TextColor3=Color3.new(1,1,1),TextSize=14,ZIndex=10,}},
		{32,"TextLabel",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="Any",Parent={30},Position=UDim2.new(0,5,0,20),Size=UDim2.new(1,-10,0,20),Text="Any String",TextColor3=Color3.new(1,1,1),TextSize=14,TextXAlignment=0,ZIndex=10,}},
		{33,"Frame",{BackgroundColor3=Color3.new(0.30588236451149,0.30588236451149,0.3098039329052),BorderSizePixel=0,Name="Button",Parent={32},Position=UDim2.new(1,-20,0,0),Size=UDim2.new(0,20,0,20),ZIndex=10,}},
		{34,"TextButton",{BackgroundColor3=Color3.new(0.58823531866074,0.58823531866074,0.59215688705444),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="On",Parent={33},Position=UDim2.new(0,2,0,2),Size=UDim2.new(0,16,0,16),Text="",TextColor3=Color3.new(0,0,0),TextSize=14,ZIndex=10,}},
		{54,"Frame",{BackgroundColor3=Color3.new(0.19607844948769,0.19607844948769,0.19607844948769),BackgroundTransparency=1,BorderColor3=Color3.new(0.15686275064945,0.15686275064945,0.15686275064945),Name="Numbers",Parent={18},Position=UDim2.new(0,0,0,25),Size=UDim2.new(1,0,0,64),Visible=false,ZIndex=10,}},
		{55,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Title",Parent={54},Size=UDim2.new(1,0,0,20),Text="Choose String",TextColor3=Color3.new(1,1,1),TextSize=14,ZIndex=10,}},
		{56,"TextLabel",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="Any",Parent={54},Position=UDim2.new(0,5,0,20),Size=UDim2.new(1,-10,0,20),Text="Any Number",TextColor3=Color3.new(1,1,1),TextSize=14,TextXAlignment=0,ZIndex=10,}},
		{57,"Frame",{BackgroundColor3=Color3.new(0.30588236451149,0.30588236451149,0.3098039329052),BorderSizePixel=0,Name="Button",Parent={56},Position=UDim2.new(1,-20,0,0),Size=UDim2.new(0,20,0,20),ZIndex=10,}},
		{58,"TextButton",{BackgroundColor3=Color3.new(0.58823531866074,0.58823531866074,0.59215688705444),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="On",Parent={57},Position=UDim2.new(0,2,0,2),Size=UDim2.new(0,16,0,16),Text="",TextColor3=Color3.new(0,0,0),TextSize=14,ZIndex=10,}},
		{59,"TextBox",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BorderColor3=Color3.new(0.15686275064945,0.15686275064945,0.15686275064945),BorderSizePixel=0,ClearTextOnFocus=false,Font=3,Name="Custom",Parent={54},PlaceholderColor3=Color3.new(0.47058826684952,0.47058826684952,0.47058826684952),PlaceholderText="Number",Position=UDim2.new(0,5,0,42),Size=UDim2.new(1,-35,0,20),Text="",TextColor3=Color3.new(1,1,1),TextSize=14,TextXAlignment=0,ZIndex=10,}},
		{60,"Frame",{BackgroundColor3=Color3.new(0.30588236451149,0.30588236451149,0.3098039329052),BorderSizePixel=0,Name="CustomButton",Parent={54},Position=UDim2.new(1,-25,0,42),Size=UDim2.new(0,20,0,20),ZIndex=10,}},
		{61,"TextButton",{BackgroundColor3=Color3.new(0.58823531866074,0.58823531866074,0.59215688705444),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="On",Parent={60},Position=UDim2.new(0,2,0,2),Size=UDim2.new(0,16,0,16),Text="",TextColor3=Color3.new(0,0,0),TextSize=14,ZIndex=10,}},
		{35,"TextBox",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BorderColor3=Color3.new(0.15686275064945,0.15686275064945,0.15686275064945),BorderSizePixel=0,ClearTextOnFocus=false,Font=3,Name="Custom",Parent={30},PlaceholderColor3=Color3.new(0.47058826684952,0.47058826684952,0.47058826684952),PlaceholderText="Match String",Position=UDim2.new(0,5,0,42),Size=UDim2.new(1,-35,0,20),Text="",TextColor3=Color3.new(1,1,1),TextSize=14,TextXAlignment=0,ZIndex=10,}},
		{36,"Frame",{BackgroundColor3=Color3.new(0.30588236451149,0.30588236451149,0.3098039329052),BorderSizePixel=0,Name="CustomButton",Parent={30},Position=UDim2.new(1,-25,0,42),Size=UDim2.new(0,20,0,20),ZIndex=10,}},
		{37,"TextButton",{BackgroundColor3=Color3.new(0.58823531866074,0.58823531866074,0.59215688705444),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="On",Parent={36},Position=UDim2.new(0,2,0,2),Size=UDim2.new(0,16,0,16),Text="",TextColor3=Color3.new(0,0,0),TextSize=14,ZIndex=10,}},
		{38,"Frame",{BackgroundColor3=Color3.new(0.19607844948769,0.19607844948769,0.19607844948769),BackgroundTransparency=1,BorderColor3=Color3.new(0.15686275064945,0.15686275064945,0.15686275064945),Name="DelayEditor",Parent={18},Position=UDim2.new(0,0,0,25),Size=UDim2.new(1,0,0,24),Visible=false,ZIndex=10,}},
		{39,"TextBox",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BorderColor3=Color3.new(0.15686275064945,0.15686275064945,0.15686275064945),BorderSizePixel=0,Font=3,Name="Secs",Parent={38},PlaceholderColor3=Color3.new(0.47058826684952,0.47058826684952,0.47058826684952),Position=UDim2.new(0,60,0,2),Size=UDim2.new(1,-65,0,20),Text="",TextColor3=Color3.new(1,1,1),TextSize=14,TextXAlignment=0,ZIndex=10,}},
		{40,"TextLabel",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="Label",Parent={39},Position=UDim2.new(0,-55,0,0),Size=UDim2.new(1,0,1,0),Text="Delay (s):",TextColor3=Color3.new(1,1,1),TextSize=14,TextXAlignment=0,ZIndex=10,}},
		{41,"Frame",{BackgroundColor3=currentShade1,BorderSizePixel=0,ClipsDescendants=true,Name="EventTemplate",Parent={6},Size=UDim2.new(1,0,0,20),Visible=false,ZIndex=10,}},
		{42,"TextButton",{BackgroundColor3=currentText1,BackgroundTransparency=1,Font=3,Name="Expand",Parent={41},Size=UDim2.new(0,20,0,20),Text=">",TextColor3=Color3.new(1,1,1),TextSize=18,ZIndex=10,}},
		{43,"TextLabel",{BackgroundColor3=currentText1,BackgroundTransparency=1,Font=3,Name="EventName",Parent={41},Position=UDim2.new(0,25,0,0),Size=UDim2.new(1,-25,0,20),Text="OnSpawn",TextColor3=Color3.new(1,1,1),TextSize=14,TextXAlignment=0,ZIndex=10,}},
		{44,"Frame",{BackgroundColor3=Color3.new(0.19607844948769,0.19607844948769,0.19607844948769),BorderSizePixel=0,BackgroundTransparency=1,ClipsDescendants=true,Name="Cmds",Parent={41},Position=UDim2.new(0,0,0,20),Size=UDim2.new(1,0,1,-20),ZIndex=10,}},
		{45,"Frame",{BackgroundColor3=Color3.new(0.14117647707462,0.14117647707462,0.14509804546833),BorderColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),Name="Add",Parent={44},Position=UDim2.new(0,0,1,-20),Size=UDim2.new(1,0,0,20),ZIndex=10,}},
		{46,"TextBox",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,ClearTextOnFocus=false,Font=3,Parent={45},PlaceholderColor3=Color3.new(0.7843137383461,0.7843137383461,0.7843137383461),PlaceholderText="Add new command",Position=UDim2.new(0,5,0,0),Size=UDim2.new(1,-10,1,0),Text="",TextColor3=Color3.new(1,1,1),TextSize=14,TextXAlignment=0,ZIndex=10,}},
		{47,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Name="Holder",Parent={44},Size=UDim2.new(1,0,1,-20),ZIndex=10,}},
		{48,"UIListLayout",{Parent={47},SortOrder=2,}},
		{49,"Frame",{currentShade1,BorderSizePixel=0,ClipsDescendants=true,Name="CmdTemplate",Parent={6},Size=UDim2.new(1,0,0,20),Visible=false,ZIndex=10,}},
		{50,"TextBox",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,ClearTextOnFocus=false,Font=3,Parent={49},PlaceholderColor3=Color3.new(1,1,1),Position=UDim2.new(0,5,0,0),Size=UDim2.new(1,-45,0,20),Text="a\\b\\c\\d",TextColor3=currentText1,TextSize=14,TextXAlignment=0,ZIndex=10,}},
		{51,"TextButton",{BackgroundColor3=currentShade1,BorderSizePixel=0,Font=3,Name="Delete",Parent={49},Position=UDim2.new(1,-20,0,0),Size=UDim2.new(0,20,0,20),Text="X",TextColor3=Color3.new(1,1,1),TextSize=18,ZIndex=10,}},
		{52,"TextButton",{BackgroundColor3=currentShade1,BorderSizePixel=0,Font=3,Name="Settings",Parent={49},Position=UDim2.new(1,-40,0,0),Size=UDim2.new(0,20,0,20),Text="",TextColor3=Color3.new(1,1,1),TextSize=18,ZIndex=10,}},
		{53,"ImageLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Image=getcustomasset("infiniteyield/assets/settings.png"),Parent={52},Position=UDim2.new(0,2,0,2),Size=UDim2.new(0,16,0,16),ZIndex=10,}},
	})
	main.Name = randomString()
	local mainFrame = main:WaitForChild("Content")
	local eventList = mainFrame:WaitForChild("List")
	local eventListHolder = eventList:WaitForChild("Holder")
	local cmdTemplate = mainFrame:WaitForChild("CmdTemplate")
	local eventTemplate = mainFrame:WaitForChild("EventTemplate")
	local settingsFrame = mainFrame:WaitForChild("Settings"):WaitForChild("Slider")
	local settingsTemplates = mainFrame.Settings:WaitForChild("Templates")
	local settingsList = settingsFrame:WaitForChild("List"):WaitForChild("Holder")
	table.insert(shade2,main.TopBar) table.insert(shade1,mainFrame) table.insert(shade2,eventTemplate)
	table.insert(text1,eventTemplate.EventName) table.insert(shade1,eventTemplate.Cmds.Add) table.insert(shade1,cmdTemplate)
	table.insert(text1,cmdTemplate.TextBox) table.insert(shade2,cmdTemplate.Delete) table.insert(shade2,cmdTemplate.Settings)
	table.insert(scroll,mainFrame.List) table.insert(shade1,settingsFrame) table.insert(shade2,settingsFrame.Line)
	table.insert(shade2,settingsFrame.Close) table.insert(scroll,settingsFrame.List) table.insert(shade2,settingsTemplates.DelayEditor.Secs)
	table.insert(text1,settingsTemplates.DelayEditor.Secs) table.insert(text1,settingsTemplates.DelayEditor.Secs.Label) table.insert(text1,settingsTemplates.Players.Title)
	table.insert(shade3,settingsTemplates.Players.CustomButton) table.insert(shade2,settingsTemplates.Players.Custom) table.insert(text1,settingsTemplates.Players.Custom)
	table.insert(shade3,settingsTemplates.Players.Any.Button) table.insert(shade3,settingsTemplates.Players.Me.Button) table.insert(text1,settingsTemplates.Players.Any)
	table.insert(text1,settingsTemplates.Players.Me) table.insert(text1,settingsTemplates.Strings.Title) table.insert(text1,settingsTemplates.Strings.Any)
	table.insert(shade3,settingsTemplates.Strings.Any.Button) table.insert(shade3,settingsTemplates.Strings.CustomButton) table.insert(text1,settingsTemplates.Strings.Custom)
	table.insert(shade2,settingsTemplates.Strings.Custom)
	table.insert(text1,settingsTemplates.Players.Me) table.insert(text1,settingsTemplates.Numbers.Title) table.insert(text1,settingsTemplates.Numbers.Any)
	table.insert(shade3,settingsTemplates.Numbers.Any.Button) table.insert(shade3,settingsTemplates.Numbers.CustomButton) table.insert(text1,settingsTemplates.Numbers.Custom)
	table.insert(shade2,settingsTemplates.Numbers.Custom)

	local tweenInf = TweenInfo.new(0.25,Enum.EasingStyle.Quart,Enum.EasingDirection.Out)

	local currentlyEditingCmd = nil

	settingsFrame:WaitForChild("Close").MouseButton1Click:Connect(function()
		settingsFrame:TweenPosition(UDim2.new(0,-150,0,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.25,true)
	end)

	local function resizeList()
		local size = 0

		for i,v in pairs(eventListHolder:GetChildren()) do
			if v.Name == "EventTemplate" then
				size = size + 20
				if v.Expand.Rotation == 90 then
					size = size + 20*(1+(#events[v.EventName:GetAttribute("RawName")].commands or 0))
				end
			end
		end

		TweenService:Create(eventList,tweenInf,{CanvasSize = UDim2.new(0,0,0,size)}):Play()

		if size > eventList.AbsoluteSize.Y then
			eventListHolder.Size = UDim2.new(1,-8,1,0)
		else
			eventListHolder.Size = UDim2.new(1,0,1,0)
		end
	end

	local function resizeSettingsList()
		local size = 0

		for i,v in pairs(settingsList:GetChildren()) do
			if v:IsA("Frame") then
				size = size + v.AbsoluteSize.Y
			end
		end

		settingsList.Parent.CanvasSize = UDim2.new(0,0,0,size)

		if size > settingsList.Parent.AbsoluteSize.Y then
			settingsList.Size = UDim2.new(1,-8,1,0)
		else
			settingsList.Size = UDim2.new(1,0,1,0)
		end
	end

	local function setupCheckbox(button,callback)
		local enabled = button.On.BackgroundTransparency == 0

		local function update()
			button.On.BackgroundTransparency = (enabled and 0 or 1)
		end

		button.On.MouseButton1Click:Connect(function()
			enabled = not enabled
			update()
			if callback then callback(enabled) end
		end)

		return {
			Toggle = function(nocall) enabled = not enabled update() if not nocall and callback then callback(enabled) end end,
			Enable = function(nocall) if enabled then return end enabled = true update()if not nocall and callback then callback(enabled) end end,
			Disable = function(nocall) if not enabled then return end enabled = false update()if not nocall and callback then callback(enabled) end end,
			IsEnabled = function() return enabled end
		}
	end

	local function openSettingsEditor(event,cmd)
		currentlyEditingCmd = cmd

		for i,v in pairs(settingsList:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end

		local delayEditor = settingsTemplates.DelayEditor:Clone()
		delayEditor.Secs.FocusLost:Connect(function()
			cmd[3] = tonumber(delayEditor.Secs.Text) or 0
			delayEditor.Secs.Text = cmd[3]
			if onEdited then onEdited() end
		end)
		delayEditor.Secs.Text = cmd[3]
		delayEditor.Visible = true
		table.insert(shade2,delayEditor.Secs)
		table.insert(text1,delayEditor.Secs)
		table.insert(text1,delayEditor.Secs.Label)
		delayEditor.Parent = settingsList

		for i,v in pairs(event.sets) do
			if v.Type == "Player" then
				local template = settingsTemplates.Players:Clone()
				template.Title.Text = v.Name or "Player"

				local me,any,custom

				me = setupCheckbox(template.Me.Button,function(on)
					if not on then return end
					any.Disable()
					custom.Disable()
					cmd[2][i] = 0
					if onEdited then onEdited() end
				end)

				any = setupCheckbox(template.Any.Button,function(on)
					if not on then return end
					me.Disable()
					custom.Disable()
					cmd[2][i] = 1
					if onEdited then onEdited() end
				end)

				local customTextBox = template.Custom
				custom = setupCheckbox(template.CustomButton,function(on)
					if not on then return end
					me.Disable()
					any.Disable()
					cmd[2][i] = customTextBox.Text
					if onEdited then onEdited() end
				end)

				ViewportTextBox.convert(customTextBox)
				customTextBox.FocusLost:Connect(function()
					if custom:IsEnabled() then
						cmd[2][i] = customTextBox.Text
						if onEdited then onEdited() end
					end
				end)

				local cVal = cmd[2][i]
				if cVal == 0 then
					me:Enable()
				elseif cVal == 1 then
					any:Enable()
				else
					custom:Enable()
					customTextBox.Text = cVal
				end

				template.Visible = true
				table.insert(text1,template.Title)
				table.insert(shade3,template.CustomButton)
				table.insert(shade3,template.Any.Button)
				table.insert(shade3,template.Me.Button)
				table.insert(text1,template.Any)
				table.insert(text1,template.Me)
				template.Parent = settingsList
			elseif v.Type == "String" then
				local template = settingsTemplates.Strings:Clone()
				template.Title.Text = v.Name or "String"

				local any,custom

				any = setupCheckbox(template.Any.Button,function(on)
					if not on then return end
					custom.Disable()
					cmd[2][i] = 0
					if onEdited then onEdited() end
				end)

				local customTextBox = template.Custom
				custom = setupCheckbox(template.CustomButton,function(on)
					if not on then return end
					any.Disable()
					cmd[2][i] = customTextBox.Text
					if onEdited then onEdited() end
				end)

				ViewportTextBox.convert(customTextBox)
				customTextBox.FocusLost:Connect(function()
					if custom:IsEnabled() then
						cmd[2][i] = customTextBox.Text
						if onEdited then onEdited() end
					end
				end)

				local cVal = cmd[2][i]
				if cVal == 0 then
					any:Enable()
				else
					custom:Enable()
					customTextBox.Text = cVal
				end

				template.Visible = true
				table.insert(text1,template.Title)
				table.insert(text1,template.Any)
				table.insert(shade3,template.Any.Button)
				table.insert(shade3,template.CustomButton)
				template.Parent = settingsList
			elseif v.Type == "Number" then
				local template = settingsTemplates.Numbers:Clone()
				template.Title.Text = v.Name or "Number"

				local any,custom

				any = setupCheckbox(template.Any.Button,function(on)
					if not on then return end
					custom.Disable()
					cmd[2][i] = 0
					if onEdited then onEdited() end
				end)

				local customTextBox = template.Custom
				custom = setupCheckbox(template.CustomButton,function(on)
					if not on then return end
					any.Disable()
					cmd[2][i] = customTextBox.Text
					if onEdited then onEdited() end
				end)

				ViewportTextBox.convert(customTextBox)
				customTextBox.FocusLost:Connect(function()
					cmd[2][i] = tonumber(customTextBox.Text) or 0
					customTextBox.Text = cmd[2][i]
					if custom:IsEnabled() then
						if onEdited then onEdited() end
					end
				end)

				local cVal = cmd[2][i]
				if cVal == 0 then
					any:Enable()
				else
					custom:Enable()
					customTextBox.Text = cVal
				end

				template.Visible = true
				table.insert(text1,template.Title)
				table.insert(text1,template.Any)
				table.insert(shade3,template.Any.Button)
				table.insert(shade3,template.CustomButton)
				template.Parent = settingsList
			end
		end
		resizeSettingsList()
		settingsFrame:TweenPosition(UDim2.new(0,0,0,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.25,true)
	end

	local function defaultSettings(ev)
		local res = {}

		for i,v in pairs(ev.sets) do
			if v.Type == "Player" then
				res[#res+1] = v.Default or 0
			elseif v.Type == "String" then
				res[#res+1] = v.Default or 0
			elseif v.Type == "Number" then
				res[#res+1] = v.Default or 0
			end
		end

		return res
	end

	local function refreshList()
		for i,v in pairs(eventListHolder:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end

		for name,event in pairs(events) do
			local eventF = eventTemplate:Clone()
			eventF.EventName.Text = name
			eventF.Visible = true
			eventF.EventName:SetAttribute("RawName", name)
			table.insert(shade2,eventF)
			table.insert(text1,eventF.EventName)
			table.insert(shade1,eventF.Cmds.Add)

			local expanded = false
			eventF.Expand.MouseButton1Down:Connect(function()
				expanded = not expanded
				eventF:TweenSize(UDim2.new(1,0,0,20 + (expanded and 20*#eventF.Cmds.Holder:GetChildren() or 0)),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.25,true)
				eventF.Expand.Rotation = expanded and 90 or 0
				resizeList()
			end)

			local function refreshCommands()
				for i,v in pairs(eventF.Cmds.Holder:GetChildren()) do
					if v.Name == "CmdTemplate" then
						v:Destroy()
					end
				end

				eventF.EventName.Text = name..(#event.commands > 0 and " ("..#event.commands..")" or "")

				for i,cmd in pairs(event.commands) do
					local cmdF = cmdTemplate:Clone()
					local cmdTextBox = cmdF.TextBox
					ViewportTextBox.convert(cmdTextBox)
					cmdTextBox.Text = cmd[1]
					cmdF.Visible = true
					table.insert(shade1,cmdF)
					table.insert(shade2,cmdF.Delete)
					table.insert(shade2,cmdF.Settings)

					cmdTextBox.FocusLost:Connect(function()
						event.commands[i] = {cmdTextBox.Text,cmd[2],cmd[3]}
						if onEdited then onEdited() end
					end)

					cmdF.Settings.MouseButton1Click:Connect(function()
						openSettingsEditor(event,cmd)
					end)

					cmdF.Delete.MouseButton1Click:Connect(function()
						table.remove(event.commands,i)
						refreshCommands()
						resizeList()

						if currentlyEditingCmd == cmd then
							settingsFrame:TweenPosition(UDim2.new(0,-150,0,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.25,true)
						end
						if onEdited then onEdited() end
					end)

					cmdF.Parent = eventF.Cmds.Holder
				end

				eventF:TweenSize(UDim2.new(1,0,0,20 + (expanded and 20*#eventF.Cmds.Holder:GetChildren() or 0)),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.25,true)
			end

			local newBox = eventF.Cmds.Add.TextBox
			ViewportTextBox.convert(newBox)
			newBox.FocusLost:Connect(function(enter)
				if enter then
					event.commands[#event.commands+1] = {newBox.Text,defaultSettings(event),0}
					newBox.Text = ""

					refreshCommands()
					resizeList()
					if onEdited then onEdited() end
				end
			end)

			--eventF:GetPropertyChangedSignal("AbsoluteSize"):Connect(resizeList)

			eventF.Parent = eventListHolder

			refreshCommands()
		end

		resizeList()
	end

	local function saveData()
		local result = {}
		for i,v in pairs(events) do
			result[i] = v.commands
		end
		return HttpService:JSONEncode(result)
	end

	local function loadData(str)
		local data = HttpService:JSONDecode(str)
		for i,v in pairs(data) do
			if events[i] then
				events[i].commands = v
			end
		end
	end

	local function addCmd(event,data)
		table.insert(events[event].commands,data)
	end

	local function setOnEdited(f)
		if type(f) == "function" then
			onEdited = f
		end
	end

	main.TopBar.Close.MouseButton1Click:Connect(function()
		main:TweenPosition(UDim2.new(0.5,-175,0,-500), "InOut", "Quart", 0.5, true, nil)
	end)
	dragGUI(main)
	main.Parent = ScaledHolder

	return {
		RegisterEvent = registerEvent,
		FireEvent = fireEvent,
		Refresh = refreshList,
		SaveData = saveData,
		LoadData = loadData,
		AddCmd = addCmd,
		Frame = main,
		SetOnEdited = setOnEdited
	}
end)()

reference = (function()
	local main = create({
		{1,"Frame",{BackgroundColor3=Color3.new(0.14117647707462,0.14117647707462,0.14509804546833),BackgroundTransparency=1,BorderColor3=Color3.new(0.15686275064945,0.15686275064945,0.15686275064945),BorderSizePixel=0,Name="Main",Position=UDim2.new(0.5,-250,0,-500),Size=UDim2.new(0,500,0,20),ZIndex=10,}},
		{2,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BorderSizePixel=0,Name="TopBar",Parent={1},Size=UDim2.new(1,0,0,20),ZIndex=10,}},
		{3,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Title",Parent={2},Size=UDim2.new(1,0,0.94999998807907,0),Text="Reference",TextColor3=Color3.new(1,1,1),TextSize=14,ZIndex=10,}},
		{4,"TextButton",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Close",Parent={2},Position=UDim2.new(1,-20,0,0),Size=UDim2.new(0,20,0,20),Text="",TextColor3=Color3.new(1,1,1),TextSize=14,ZIndex=10,}},
		{5,"ImageLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Image=getcustomasset("infiniteyield/assets/close.png"),Parent={4},Position=UDim2.new(0,5,0,5),Size=UDim2.new(0,10,0,10),ZIndex=10,}},
		{6,"Frame",{BackgroundColor3=Color3.new(0.14117647707462,0.14117647707462,0.14509804546833),BorderSizePixel=0,Name="Content",Parent={1},Position=UDim2.new(0,0,0,20),Size=UDim2.new(1,0,0,300),ZIndex=10,}},
		{7,"ScrollingFrame",{BackgroundColor3=Color3.new(0.14117647707462,0.14117647707462,0.14509804546833),BackgroundTransparency=1,BorderColor3=Color3.new(0.15686275064945,0.15686275064945,0.15686275064945),BorderSizePixel=0,BottomImage="rbxasset://textures/ui/Scroll/scroll-middle.png",CanvasSize=UDim2.new(0,0,0,1313),Name="List",Parent={6},ScrollBarImageColor3=Color3.new(0.30588236451149,0.30588236451149,0.3098039329052),ScrollBarThickness=8,Size=UDim2.new(1,0,1,0),TopImage="rbxasset://textures/ui/Scroll/scroll-middle.png",VerticalScrollBarInset=2,ZIndex=10,}},
		{8,"UIListLayout",{Parent={7},SortOrder=2,}},
		{9,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Name="Section",Parent={7},Size=UDim2.new(1,0,0,429),ZIndex=10,}},
		{10,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="Header",Parent={9},Position=UDim2.new(0,8,0,5),Size=UDim2.new(1,-8,0,20),Text="Special Player Cases",TextColor3=Color3.new(1,1,1),TextSize=20,TextXAlignment=0,ZIndex=10,}},
		{11,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Text",Parent={9},Position=UDim2.new(0,8,0,25),Size=UDim2.new(1,-8,0,20),Text="These keywords can be used to quickly select groups of players in commands:",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{12,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BorderSizePixel=0,Name="Line",Parent={9},Position=UDim2.new(0,10,1,-1),Size=UDim2.new(1,-20,0,1),ZIndex=10,}},
		{13,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Cases",Parent={9},Position=UDim2.new(0,8,0,55),Size=UDim2.new(1,-16,0,342),ZIndex=10,}},
		{14,"UIListLayout",{Parent={13},SortOrder=2,}},
		{15,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,LayoutOrder=-4,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{16,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={15},Size=UDim2.new(1,0,1,0),Text="all",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{17,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={15},Position=UDim2.new(0,15,0,0),Size=UDim2.new(1,0,1,0),Text="- includes everyone",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{18,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,LayoutOrder=-3,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{19,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={18},Size=UDim2.new(1,0,1,0),Text="others",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{20,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={18},Position=UDim2.new(0,37,0,0),Size=UDim2.new(1,0,1,0),Text="- includes everyone except you",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{21,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,LayoutOrder=-2,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{22,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={21},Size=UDim2.new(1,0,1,0),Text="me",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{23,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={21},Position=UDim2.new(0,19,0,0),Size=UDim2.new(1,0,1,0),Text="- includes your player only",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{24,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{25,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={24},Size=UDim2.new(1,0,1,0),Text="#[number]",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{26,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={24},Position=UDim2.new(0,59,0,0),Size=UDim2.new(1,0,1,0),Text="- gets a specified amount of random players",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{27,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{28,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={27},Size=UDim2.new(1,0,1,0),Text="random",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{29,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={27},Position=UDim2.new(0,44,0,0),Size=UDim2.new(1,0,1,0),Text="- affects a random player",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{30,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{31,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={30},Size=UDim2.new(1,0,1,0),Text="%[team name]",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{32,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={30},Position=UDim2.new(0,78,0,0),Size=UDim2.new(1,0,1,0),Text="- includes everyone on a given team",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{33,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{34,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={33},Size=UDim2.new(1,0,1,0),Text="allies / team",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{35,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={33},Position=UDim2.new(0,63,0,0),Size=UDim2.new(1,0,1,0),Text="- players who are on your team",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{36,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{37,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={36},Size=UDim2.new(1,0,1,0),Text="enemies / nonteam",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{38,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={36},Position=UDim2.new(0,101,0,0),Size=UDim2.new(1,0,1,0),Text="- players who are not on your team",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{39,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{40,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={39},Size=UDim2.new(1,0,1,0),Text="friends",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{41,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={39},Position=UDim2.new(0,40,0,0),Size=UDim2.new(1,0,1,0),Text="- anyone who is friends with you",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{42,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{43,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={42},Size=UDim2.new(1,0,1,0),Text="nonfriends",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{44,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={42},Position=UDim2.new(0,61,0,0),Size=UDim2.new(1,0,1,0),Text="- anyone who is not friends with you",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{45,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{46,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={45},Size=UDim2.new(1,0,1,0),Text="guests",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{47,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={45},Position=UDim2.new(0,36,0,0),Size=UDim2.new(1,0,1,0),Text="- guest players (obsolete)",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{48,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{49,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={48},Size=UDim2.new(1,0,1,0),Text="bacons",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{50,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={48},Position=UDim2.new(0,40,0,0),Size=UDim2.new(1,0,1,0),Text="- anyone with the \"bacon\" or pal hair",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{51,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{52,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={51},Size=UDim2.new(1,0,1,0),Text="age[number]",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{53,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={51},Position=UDim2.new(0,71,0,0),Size=UDim2.new(1,0,1,0),Text="- includes anyone below or at the given age",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{54,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{55,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={54},Size=UDim2.new(1,0,1,0),Text="rad[number]",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{56,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={54},Position=UDim2.new(0,70,0,0),Size=UDim2.new(1,0,1,0),Text="- includes anyone within the given radius",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{57,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{58,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={57},Size=UDim2.new(1,0,1,0),Text="nearest",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{59,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={57},Position=UDim2.new(0,43,0,0),Size=UDim2.new(1,0,1,0),Text="- gets the closest player to you",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{60,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{61,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={60},Size=UDim2.new(1,0,1,0),Text="farthest",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{62,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={60},Position=UDim2.new(0,46,0,0),Size=UDim2.new(1,0,1,0),Text="- gets the farthest player from you",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{63,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{64,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={63},Size=UDim2.new(1,0,1,0),Text="group[ID]",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{65,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={63},Position=UDim2.new(0,55,0,0),Size=UDim2.new(1,0,1,0),Text="- gets players who are in a certain group",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{66,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{67,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={66},Size=UDim2.new(1,0,1,0),Text="alive",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{68,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={66},Position=UDim2.new(0,27,0,0),Size=UDim2.new(1,0,1,0),Text="- gets players who are alive",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{69,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{70,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={69},Size=UDim2.new(1,0,1,0),Text="dead",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{71,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={69},Position=UDim2.new(0,29,0,0),Size=UDim2.new(1,0,1,0),Text="- gets players who are dead",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{72,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,LayoutOrder=-1,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{73,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={72},Size=UDim2.new(1,0,1,0),Text="@username",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{74,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={72},Position=UDim2.new(0,66,0,0),Size=UDim2.new(1,0,1,0),Text="- searches for players by username only (ignores displaynames)",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{75,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Name="Section",Parent={7},Size=UDim2.new(1,0,0,180),ZIndex=10,}},
		{76,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="Header",Parent={75},Position=UDim2.new(0,8,0,5),Size=UDim2.new(1,-8,0,20),Text="Various Operators",TextColor3=Color3.new(1,1,1),TextSize=20,TextXAlignment=0,ZIndex=10,}},
		{77,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BorderSizePixel=0,Name="Line",Parent={75},Position=UDim2.new(0,10,1,-1),Size=UDim2.new(1,-20,0,1),ZIndex=10,}},
		{78,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="Text",Parent={75},Position=UDim2.new(0,8,0,30),Size=UDim2.new(1,-8,0,16),Text="Use commas to separate multiple expressions:",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,TextYAlignment=0,ZIndex=10,}},
		{79,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="Text",Parent={75},Position=UDim2.new(0,8,0,75),Size=UDim2.new(1,-8,0,16),Text="Use - to exclude, and + to include players in your expression:",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,TextYAlignment=0,ZIndex=10,}},
		{80,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Text",Parent={75},Position=UDim2.new(0,8,0,91),Size=UDim2.new(1,-8,0,16),Text=";locate %blue-friends (gets players in blue team who aren't your friends)",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,TextYAlignment=0,ZIndex=10,}},
		{81,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Text",Parent={75},Position=UDim2.new(0,8,0,46),Size=UDim2.new(1,-8,0,16),Text=";locate noob,noob2,bob",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,TextYAlignment=0,ZIndex=10,}},
		{82,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="Text",Parent={75},Position=UDim2.new(0,8,0,120),Size=UDim2.new(1,-8,0,16),Text="Put ! before a command to run it with the last arguments it was ran with:",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,TextYAlignment=0,ZIndex=10,}},
		{83,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Text",Parent={75},Position=UDim2.new(0,8,0,136),Size=UDim2.new(1,-8,0,32),Text="After running ;offset 0 100 0,  you can run !offset anytime to repeat that command with the same arguments that were used to run it last time",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,TextYAlignment=0,ZIndex=10,}},
		{84,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Name="Section",Parent={7},Size=UDim2.new(1,0,0,154),ZIndex=10,}},
		{85,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="Header",Parent={84},Position=UDim2.new(0,8,0,5),Size=UDim2.new(1,-8,0,20),Text="Command Looping",TextColor3=Color3.new(1,1,1),TextSize=20,TextXAlignment=0,ZIndex=10,}},
		{86,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="Text",Parent={84},Position=UDim2.new(0,8,0,30),Size=UDim2.new(1,-8,0,20),Text="Form: [How many times it loops]^[delay (optional)]^[command]",TextColor3=Color3.new(1,1,1),TextSize=15,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{87,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BorderSizePixel=0,Name="Line",Parent={84},Position=UDim2.new(0,10,1,-1),Size=UDim2.new(1,-20,0,1),ZIndex=10,}},
		{88,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Text",Parent={84},Position=UDim2.new(0,8,0,50),Size=UDim2.new(1,-8,0,20),Text="Use the 'breakloops' command to stop all running loops.",TextColor3=Color3.new(1,1,1),TextSize=15,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{89,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="Text",Parent={84},Position=UDim2.new(0,8,0,80),Size=UDim2.new(1,-8,0,16),Text="Examples:",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,TextYAlignment=0,ZIndex=10,}},
		{90,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Text",Parent={84},Position=UDim2.new(0,8,0,98),Size=UDim2.new(1,-8,0,42),Text=";5^btools - gives you 5 sets of btools\n;10^3^drophats - drops your hats every 3 seconds 10 times\n;inf^0.1^animspeed 100 - infinitely loops your animation speed to 100",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,TextYAlignment=0,ZIndex=10,}},
		{91,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Name="Section",Parent={7},Size=UDim2.new(1,0,0,120),ZIndex=10,}},
		{92,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="Header",Parent={91},Position=UDim2.new(0,8,0,5),Size=UDim2.new(1,-8,0,20),Text="Execute Multiple Commands at Once",TextColor3=Color3.new(1,1,1),TextSize=20,TextXAlignment=0,ZIndex=10,}},
		{93,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="Text",Parent={91},Position=UDim2.new(0,8,0,30),Size=UDim2.new(1,-8,0,20),Text="You can execute multiple commands at once using \"\\\"",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{94,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BorderSizePixel=0,Name="Line",Parent={91},Position=UDim2.new(0,10,1,-1),Size=UDim2.new(1,-20,0,1),ZIndex=10,}},
		{95,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="Text",Parent={91},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,-8,0,16),Text="Examples:",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,TextYAlignment=0,ZIndex=10,}},
		{96,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Text",Parent={91},Position=UDim2.new(0,8,0,78),Size=UDim2.new(1,-8,0,32),Text=";drophats\\respawn - drops your hats and respawns you\n;enable inventory\\enable playerlist\\refresh - enables those coregui items and refreshes you",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,TextYAlignment=0,ZIndex=10,}},
		{97,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Name="Section",Parent={7},Size=UDim2.new(1,0,0,75),ZIndex=10,}},
		{98,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="Header",Parent={97},Position=UDim2.new(0,8,0,5),Size=UDim2.new(1,-8,0,20),Text="Browse Command History",TextColor3=Color3.new(1,1,1),TextSize=20,TextXAlignment=0,ZIndex=10,}},
		{99,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Text",Parent={97},Position=UDim2.new(0,8,0,30),Size=UDim2.new(1,-8,0,32),Text="While focused on the command bar, you can use the up and down arrow keys to browse recently used commands",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{100,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BorderSizePixel=0,Name="Line",Parent={97},Position=UDim2.new(0,10,1,-1),Size=UDim2.new(1,-20,0,1),ZIndex=10,}},
		{101,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Name="Section",Parent={7},Size=UDim2.new(1,0,0,75),ZIndex=10,}},
		{102,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="Header",Parent={101},Position=UDim2.new(0,8,0,5),Size=UDim2.new(1,-8,0,20),Text="Autocomplete in the Command Bar",TextColor3=Color3.new(1,1,1),TextSize=20,TextXAlignment=0,ZIndex=10,}},
		{103,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Text",Parent={101},Position=UDim2.new(0,8,0,30),Size=UDim2.new(1,-8,0,32),Text="While focused on the command bar, you can use the tab key to insert the top suggested command into the command bar.",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{104,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BorderSizePixel=0,Name="Line",Parent={101},Position=UDim2.new(0,10,1,-1),Size=UDim2.new(1,-20,0,1),ZIndex=10,}},
		{105,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Name="Section",Parent={7},Size=UDim2.new(1,0,0,175),ZIndex=10,}},
		{106,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="Header",Parent={105},Position=UDim2.new(0,8,0,5),Size=UDim2.new(1,-8,0,20),Text="Using Event Binds",TextColor3=Color3.new(1,1,1),TextSize=20,TextXAlignment=0,ZIndex=10,}},
		{107,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Text",Parent={105},Position=UDim2.new(0,8,0,30),Size=UDim2.new(1,-8,0,32),Text="Use event binds to set up commands that get executed when certain events happen. You can edit the conditions for an event command to run (such as which player triggers it).",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{108,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BorderSizePixel=0,Name="Line",Parent={105},Position=UDim2.new(0,10,1,-1),Size=UDim2.new(1,-20,0,1),ZIndex=10,}},
		{109,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Text",Parent={105},Position=UDim2.new(0,8,0,70),Size=UDim2.new(1,-8,0,48),Text="Some events may send arguments; you can use them in your event command by using $ followed by the argument number ($1, $2, etc). You can find out the order and types of these arguments by looking at the settings of the event command.",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{110,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="Text",Parent={105},Position=UDim2.new(0,8,0,130),Size=UDim2.new(1,-8,0,16),Text="Example:",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,TextYAlignment=0,ZIndex=10,}},
		{111,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Text",Parent={105},Position=UDim2.new(0,8,0,148),Size=UDim2.new(1,-8,0,16),Text="Setting up 'goto $1' on the OnChatted event will teleport you to any player that chats.",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,TextYAlignment=0,ZIndex=10,}},
		{112,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Name="Section",Parent={7},Size=UDim2.new(1,0,0,105),ZIndex=10,}},
		{113,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="Header",Parent={112},Position=UDim2.new(0,8,0,5),Size=UDim2.new(1,-8,0,20),Text="Get Further Help",TextColor3=Color3.new(1,1,1),TextSize=20,TextXAlignment=0,ZIndex=10,}},
		{114,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Text",Parent={112},Position=UDim2.new(0,8,0,30),Size=UDim2.new(1,-8,0,32),Text="You can join the Discord server to get support with IY,  and read up on more documentation such as the Plugin API.",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{115,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BorderSizePixel=0,Name="Line",Parent={112},Position=UDim2.new(0,10,1,-1),Size=UDim2.new(1,-20,0,1),Visible=false,ZIndex=10,}},
		{116,"TextButton",{BackgroundColor3=Color3.new(0.48627451062202,0.61960786581039,0.85098040103912),BorderColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),Font=4,Name="InviteButton",Parent={112},Position=UDim2.new(0,5,0,75),Size=UDim2.new(1,-10,0,25),Text="Copy Discord Invite Link (https://discord.gg/78ZuWSq)",TextColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),TextSize=16,ZIndex=10,}},
	})
	for i,v in pairs(main.Content.List:GetDescendants()) do
		if v:IsA("TextLabel") then
			table.insert(text1,v)
		end
	end
	table.insert(scroll,main.Content.List)
	table.insert(shade1,main.Content)
	table.insert(shade2,main.TopBar)
	main.Name = randomString()
	main.TopBar.Close.MouseButton1Click:Connect(function()
		main:TweenPosition(UDim2.new(0.5,-250,0,-500), "InOut", "Quart", 0.5, true, nil)
	end)
	local inviteButton = main:FindFirstChild("InviteButton",true)
	local lastPress = nil
	inviteButton.MouseButton1Click:Connect(function()
		if everyClipboard then
			toClipboard("https://discord.gg/78ZuWSq")
			inviteButton.Text = "Copied"
		else
			inviteButton.Text = "No Clipboard Function, type out the link"
		end
		local pressTime = tick()
		lastPress = pressTime
		wait(2)
		if lastPress ~= pressTime then return end
		inviteButton.Text = "Copy Discord Invite Link (https://discord.gg/78ZuWSq)"
	end)
	dragGUI(main)
	main.Parent = ScaledHolder

	ReferenceButton.MouseButton1Click:Connect(function()
		main:TweenPosition(UDim2.new(0.5,-250,0.5,-150), "InOut", "Quart", 0.5, true, nil)
	end)
end)()

currentShade1 = Color3.fromRGB(16, 10, 34)
currentShade2 = Color3.fromRGB(32, 18, 64)
currentShade3 = Color3.fromRGB(86, 50, 160)
currentText1 = Color3.fromRGB(236, 224, 255)
currentText2 = Color3.new(0, 0, 0)
currentScroll = Color3.fromRGB(140, 90, 235)

defaultGuiScale = IsOnMobile and 0.9 or 1
defaultsettings = {
	prefix = ';';
	StayOpen = false;
	guiScale = defaultGuiScale;
	espTransparency = 0.3;
	keepIY = true;
	logsEnabled = false;
	jLogsEnabled = false;
	aliases = {};
	binds = {};
	WayPoints = {};
	PluginsTable = {};
	currentShade1 = {currentShade1.R,currentShade1.G,currentShade1.B};
	currentShade2 = {currentShade2.R,currentShade2.G,currentShade2.B};
	currentShade3 = {currentShade3.R,currentShade3.G,currentShade3.B};
	currentText1 = {currentText1.R,currentText1.G,currentText1.B};
	currentText2 = {currentText2.R,currentText2.G,currentText2.B};
	currentScroll = {currentScroll.R,currentScroll.G,currentScroll.B};
	eventBinds = eventEditor.SaveData()
}

defaults = HttpService:JSONEncode(defaultsettings)
nosaves = false
useFactorySettings = function()
	prefix = ';'
	StayOpen = false
	guiScale = defaultGuiScale
	KeepInfYield = true
	espTransparency = 0.3
	logsEnabled = false
	jLogsEnabled = false
	logsWebhook = nil
	aliases = {}
	binds = {}
	WayPoints = {}
	PluginsTable = {}
end

function createPopup(title, text)
	local Popup = Instance.new("Frame")
	local background = Instance.new("Frame")
	local Directions = Instance.new("TextLabel")
	local shadow = Instance.new("Frame")
	local PopupText = Instance.new("TextLabel")
	local Exit = Instance.new("TextButton")
	local ExitImage = Instance.new("ImageLabel")

	Popup.Name = randomString()
	Popup.Parent = ScaledHolder
	Popup.Active = true
	Popup.BackgroundTransparency = 1
	Popup.Position = UDim2.new(0.5, -180, 0, -500)
	Popup.Size = UDim2.new(0, 360, 0, 20)
	Popup.ZIndex = 10

	background.Name = "background"
	background.Parent = Popup
	background.Active = true
	background.BackgroundColor3 = Color3.fromRGB(16, 10, 34)
	background.BorderSizePixel = 0
	background.Position = UDim2.new(0, 0, 0, 20)
	background.Size = UDim2.new(0, 360, 0, 205)
	background.ZIndex = 10

	Directions.Name = "Directions"
	Directions.Parent = background
	Directions.BackgroundTransparency = 1
	Directions.BorderSizePixel = 0
	Directions.Position = UDim2.new(0, 10, 0, 10)
	Directions.Size = UDim2.new(0, 340, 0, 185)
	Directions.Font = Enum.Font.SourceSans
	Directions.TextSize = 14
	Directions.Text = text
	Directions.TextColor3 = Color3.new(1, 1, 1)
	Directions.TextWrapped = true
	Directions.TextXAlignment = Enum.TextXAlignment.Left
	Directions.TextYAlignment = Enum.TextYAlignment.Top
	Directions.ZIndex = 10

	shadow.Name = "shadow"
	shadow.Parent = Popup
	shadow.BackgroundColor3 = Color3.fromRGB(32, 18, 64)
	shadow.BorderSizePixel = 0
	shadow.Size = UDim2.new(0, 360, 0, 20)
	shadow.ZIndex = 10

	PopupText.Name = "PopupText"
	PopupText.Parent = shadow
	PopupText.BackgroundTransparency = 1
	PopupText.Size = UDim2.new(1, 0, 0.95, 0)
	PopupText.ZIndex = 10
	PopupText.Font = Enum.Font.SourceSans
	PopupText.TextSize = 14
	PopupText.Text = title
	PopupText.TextColor3 = Color3.new(1, 1, 1)
	PopupText.TextWrapped = true

	Exit.Name = "Exit"
	Exit.Parent = shadow
	Exit.BackgroundTransparency = 1
	Exit.Position = UDim2.new(1, -20, 0, 0)
	Exit.Size = UDim2.new(0, 20, 0, 20)
	Exit.Text = ""
	Exit.ZIndex = 10

	ExitImage.Parent = Exit
	ExitImage.BackgroundColor3 = Color3.new(1, 1, 1)
	ExitImage.BackgroundTransparency = 1
	ExitImage.Position = UDim2.new(0, 5, 0, 5)
	ExitImage.Size = UDim2.new(0, 10, 0, 10)
	ExitImage.Image = getcustomasset("infiniteyield/assets/close.png")
	ExitImage.ZIndex = 10

	Popup:TweenPosition(UDim2.new(0.5, -180, 0, 150), "InOut", "Quart", 0.5, true, nil)

	Exit.MouseButton1Click:Connect(function()
		Popup:TweenPosition(UDim2.new(0.5, -180, 0, -500), "InOut", "Quart", 0.5, true, nil)
		task.wait(0.6)
		Popup:Destroy()
	end)
end

local loadedEventData = nil
local jsonAttempts = 0
function saves()
	if writefileExploit() and readfileExploit() and jsonAttempts < 10 then
		local readSuccess, out = readfile("IY_FE.iy", true)
		if readSuccess then
			if out ~= nil and tostring(out):gsub("%s", "") ~= "" then
				local success, response = pcall(function()
					local json = HttpService:JSONDecode(out)
					if vtype(json.prefix, "string") then prefix = json.prefix else prefix = ';' end
					if vtype(json.StayOpen, "boolean") then StayOpen = json.StayOpen else StayOpen = false end
					if vtype(json.guiScale, "number") then guiScale = json.guiScale else guiScale = defaultGuiScale end
					if vtype(json.keepIY, "boolean") then KeepInfYield = json.keepIY else KeepInfYield = true end
					if vtype(json.espTransparency, "number") then espTransparency = json.espTransparency else espTransparency = 0.3 end
					if vtype(json.logsEnabled, "boolean") then logsEnabled = json.logsEnabled else logsEnabled = false end
					if vtype(json.jLogsEnabled, "boolean") then jLogsEnabled = json.jLogsEnabled else jLogsEnabled = false end
					if vtype(json.logsWebhook, "string") then logsWebhook = json.logsWebhook else logsWebhook = nil end
					if vtype(json.aliases, "table") then aliases = json.aliases else aliases = {} end
					if vtype(json.binds, "table") then binds = json.binds else binds = {} end
					if vtype(json.spawnCmds, "table") then spawnCmds = json.spawnCmds end
					if vtype(json.WayPoints, "table") then AllWaypoints = json.WayPoints else WayPoints = {} AllWaypoints = {} end
					if vtype(json.PluginsTable, "table") then PluginsTable = json.PluginsTable else PluginsTable = {} end
					if vtype(json.currentShade1, "table") then currentShade1 = Color3.new(json.currentShade1[1],json.currentShade1[2],json.currentShade1[3]) end
					if vtype(json.currentShade2, "table") then currentShade2 = Color3.new(json.currentShade2[1],json.currentShade2[2],json.currentShade2[3]) end
					if vtype(json.currentShade3, "table") then currentShade3 = Color3.new(json.currentShade3[1],json.currentShade3[2],json.currentShade3[3]) end
					if vtype(json.currentText1, "table") then currentText1 = Color3.new(json.currentText1[1],json.currentText1[2],json.currentText1[3]) end
					if vtype(json.currentText2, "table") then currentText2 = Color3.new(json.currentText2[1],json.currentText2[2],json.currentText2[3]) end
					if vtype(json.currentScroll, "table") then currentScroll = Color3.new(json.currentScroll[1],json.currentScroll[2],json.currentScroll[3]) end
					-- NeverYield: saves still using the stock grey theme get the space purple theme
					if math.abs(currentShade1.R - 36/255) < 0.01 and math.abs(currentShade1.G - 36/255) < 0.01 and math.abs(currentShade1.B - 37/255) < 0.01 then
						currentShade1 = Color3.fromRGB(16, 10, 34)
						currentShade2 = Color3.fromRGB(32, 18, 64)
						currentShade3 = Color3.fromRGB(86, 50, 160)
						currentText1 = Color3.fromRGB(236, 224, 255)
						currentScroll = Color3.fromRGB(140, 90, 235)
					end
					if vtype(json.eventBinds, "string") then loadedEventData = json.eventBinds end
				end)
				if not success then
					jsonAttempts = jsonAttempts + 1
					warn("Save Json Error:", response)
					warn("Overwriting Save File")
					writefile("IY_FE.iy", defaults, true)
					wait()
					saves()
				end
			else
				writefile("IY_FE.iy", defaults, true)
				wait()
				local dReadSuccess, dOut = readfile("IY_FE.iy", true)
				if dReadSuccess and dOut ~= nil and tostring(dOut):gsub("%s", "") ~= "" then
					saves()
				else
					nosaves = true
					useFactorySettings()
					createPopup("File Error", "There was a problem writing a save file to your PC.\n\nPlease contact the developer/support team for your exploit and tell them writefile/readfile is not working.\n\nYour settings, keybinds, waypoints, and aliases will not save if you continue.\n\nThings to try:\n> Make sure a 'workspace' folder is located in the same folder as your exploit\n> If your exploit is inside of a zip/rar file, extract it.\n> Rejoin the game and try again or restart your PC and try again.")
				end
			end
		else
			writefile("IY_FE.iy", defaults, true)
			wait()
			local dReadSuccess, dOut = readfile("IY_FE.iy", true)
			if dReadSuccess and dOut ~= nil and tostring(dOut):gsub("%s", "") ~= "" then
				saves()
			else
				nosaves = true
				useFactorySettings()
				createPopup("File Error", "There was a problem writing a save file to your PC.\n\nPlease contact the developer/support team for your exploit and tell them writefile/readfile is not working.\n\nYour settings, keybinds, waypoints, and aliases will not save if you continue.\n\nThings to try:\n> Make sure a 'workspace' folder is located in the same folder as your exploit\n> If your exploit is inside of a zip/rar file, extract it.\n> Rejoin the game and try again or restart your PC and try again.")
			end
		end
	else
		if jsonAttempts >= 10 then
			nosaves = true
			useFactorySettings()
			createPopup("File Error", "Sorry, we have attempted to parse your save file, but it is unreadable!\n\nNeverYield is now using factory settings until your exploit's file system works.\n\nYour save file has not been deleted.")
		else
			nosaves = true
			useFactorySettings()
		end
	end
end

saves()

function updatesaves()
	if nosaves == false and writefileExploit() then
		local update = {
			prefix = prefix;
			StayOpen = StayOpen;
			guiScale = guiScale;
			keepIY = KeepInfYield;
			espTransparency = espTransparency;
			logsEnabled = logsEnabled;
			jLogsEnabled = jLogsEnabled;
			logsWebhook = logsWebhook;
			aliases = aliases;
			binds = binds or {};
			WayPoints = AllWaypoints;
			PluginsTable = PluginsTable;
			currentShade1 = {currentShade1.R,currentShade1.G,currentShade1.B};
			currentShade2 = {currentShade2.R,currentShade2.G,currentShade2.B};
			currentShade3 = {currentShade3.R,currentShade3.G,currentShade3.B};
			currentText1 = {currentText1.R,currentText1.G,currentText1.B};
			currentText2 = {currentText2.R,currentText2.G,currentText2.B};
			currentScroll = {currentScroll.R,currentScroll.G,currentScroll.B};
			eventBinds = eventEditor.SaveData()
		}
		writefileCooldown("IY_FE.iy", HttpService:JSONEncode(update))
	end
end

eventEditor.SetOnEdited(updatesaves)

pWayPoints = {}
WayPoints = {}

if #AllWaypoints > 0 then
	for i = 1, #AllWaypoints do
		if not AllWaypoints[i].GAME or AllWaypoints[i].GAME == PlaceId then
			WayPoints[#WayPoints + 1] = {NAME = AllWaypoints[i].NAME, COORD = {AllWaypoints[i].COORD[1], AllWaypoints[i].COORD[2], AllWaypoints[i].COORD[3]}, GAME = AllWaypoints[i].GAME}
		end
	end
end

if type(binds) ~= "table" then binds = {} end

if type(PluginsTable) == "table" then
	for i = #PluginsTable, 1, -1 do
		if string.sub(PluginsTable[i], -3) ~= ".iy" then
			table.remove(PluginsTable, i)
		end
	end
end

function Time()
	local HOUR = math.floor((tick() % 86400) / 3600)
	local MINUTE = math.floor((tick() % 3600) / 60)
	local SECOND = math.floor(tick() % 60)
	local AP = HOUR > 11 and 'PM' or 'AM'
	HOUR = (HOUR % 12 == 0 and 12 or HOUR % 12)
	HOUR = HOUR < 10 and '0' .. HOUR or HOUR
	MINUTE = MINUTE < 10 and '0' .. MINUTE or MINUTE
	SECOND = SECOND < 10 and '0' .. SECOND or SECOND
	return HOUR .. ':' .. MINUTE .. ':' .. SECOND .. ' ' .. AP
end

PrefixBox.Text = prefix
local SettingsOpen = false
local isHidden = false

if StayOpen == false then
	On.BackgroundTransparency = 1
else
	On.BackgroundTransparency = 0
end

if logsEnabled then
	Toggle.Text = 'Enabled'
else
	Toggle.Text = 'Disabled'
end

if jLogsEnabled then
	Toggle_2.Text = 'Enabled'
else
	Toggle_2.Text = 'Disabled'
end

function maximizeHolder()
	if StayOpen == false then
		Holder:TweenPosition(UDim2.new(1, Holder.Position.X.Offset, 1, -220), "InOut", "Quart", 0.2, true, nil)
	end
end

minimizeNum = -20
function minimizeHolder()
	if StayOpen == false then
		Holder:TweenPosition(UDim2.new(1, Holder.Position.X.Offset, 1, minimizeNum), "InOut", "Quart", 0.5, true, nil)
	end
end

function cmdbarHolder()
	if StayOpen == false then
		Holder:TweenPosition(UDim2.new(1, Holder.Position.X.Offset, 1, -45), "InOut", "Quart", 0.5, true, nil)
	end
end

pinNotification = nil
local notifyCount = 0
function notify(text,text2,length)
	task.spawn(function()
		local LnotifyCount = notifyCount+1
		local notificationPinned = false
		notifyCount = notifyCount+1
		if pinNotification then pinNotification:Disconnect() end
		pinNotification = PinButton.MouseButton1Click:Connect(function()
			task.spawn(function()
				pinNotification:Disconnect()
				notificationPinned = true
				Title_2.BackgroundTransparency = 1
				wait(0.5)
				Title_2.BackgroundTransparency = 0
			end)
		end)
		Notification:TweenPosition(UDim2.new(1, Notification.Position.X.Offset, 1, 0), "InOut", "Quart", 0.5, true, nil)
		wait(0.6)
		local closepressed = false
		if text2 then
			Title_2.Text = text
			Text_2.Text = text2
		else
			Title_2.Text = 'Notification'
			Text_2.Text = text
		end
		Notification:TweenPosition(UDim2.new(1, Notification.Position.X.Offset, 1, -100), "InOut", "Quart", 0.5, true, nil)
		CloseButton.MouseButton1Click:Connect(function()
			Notification:TweenPosition(UDim2.new(1, Notification.Position.X.Offset, 1, 0), "InOut", "Quart", 0.5, true, nil)
			closepressed = true
			pinNotification:Disconnect()
		end)
		if length and isNumber(length) then
			wait(length)
		else
			wait(10)
		end
		if LnotifyCount == notifyCount then
			if closepressed == false and notificationPinned == false then
				pinNotification:Disconnect()
				Notification:TweenPosition(UDim2.new(1, Notification.Position.X.Offset, 1, 0), "InOut", "Quart", 0.5, true, nil)
			end
			notifyCount = 0
		end
	end)
end

local lastMessage = nil
local lastLabel = nil
local dupeCount = 1
function CreateLabel(Name, Text)
	if lastMessage == Name..Text then
		dupeCount = dupeCount+1
		lastLabel.Text = Time()..' - ['..Name..']: '..Text..' (x'..dupeCount..')'
	else
		if dupeCount > 1 then dupeCount = 1 end
		if #scroll_2:GetChildren() >= 2546 then
			scroll_2:ClearAllChildren()
		end
		local alls = 0
		for i,v in pairs(scroll_2:GetChildren()) do
			if v then
				alls = v.Size.Y.Offset + alls
			end
			if not v then
				alls = 0
			end
		end
		local tl = Instance.new('TextLabel')
		lastMessage = Name..Text
		lastLabel = tl
		tl.Name = Name
		tl.Parent = scroll_2
		tl.ZIndex = 10
		tl.RichText = true
		tl.Text = Time().." - ["..Name.."]: "..Text
		tl.Text = tl.ContentText
		tl.Size = UDim2.new(0,322,0,84)
		tl.BackgroundTransparency = 1
		tl.BorderSizePixel = 0
		tl.Font = "SourceSans"
		tl.Position = UDim2.new(-1,0,0,alls)
		tl.TextTransparency = 1
		tl.TextScaled = false
		tl.TextSize = 14
		tl.TextWrapped = true
		tl.TextXAlignment = "Left"
		tl.TextYAlignment = "Top"
		tl.TextColor3 = currentText1
		tl.Size = UDim2.new(0,322,0,tl.TextBounds.Y)
		table.insert(text1,tl)
		scroll_2.CanvasSize = UDim2.new(0,0,0,alls+tl.TextBounds.Y)
		scroll_2.CanvasPosition = Vector2.new(0,scroll_2.CanvasPosition.Y+tl.TextBounds.Y)
		tl:TweenPosition(UDim2.new(0,3,0,alls), 'In', 'Quint', 0.5)
		TweenService:Create(tl, TweenInfo.new(1.25, Enum.EasingStyle.Linear), { TextTransparency = 0 }):Play()
	end
end

function CreateJoinLabel(player, userId)
    if #scroll_3:GetChildren() >= 2546 then
        scroll_3:ClearAllChildren()
    end
    local infoFrame = Instance.new("Frame")
    local info1 = Instance.new("TextLabel")
    local info2 = Instance.new("TextLabel")
    local ImageLabel_3 = Instance.new("ImageLabel")
    infoFrame.Name = randomString()
    infoFrame.Parent = scroll_3
    infoFrame.BackgroundColor3 = Color3.new(1, 1, 1)
    infoFrame.BackgroundTransparency = 1
    infoFrame.BorderColor3 = Color3.new(0.105882, 0.164706, 0.207843)
    infoFrame.Size = UDim2.new(1, 0, 0, 50)
    info1.Name = randomString()
    info1.Parent = infoFrame
    info1.BackgroundTransparency = 1
    info1.BorderSizePixel = 0
    info1.Position = UDim2.new(0, 45, 0, 0)
    info1.Size = UDim2.new(0, 135, 1, 0)
    info1.ZIndex = 10
    info1.Font = Enum.Font.SourceSans
    info1.FontSize = Enum.FontSize.Size14
    info1.Text = "Username: " .. player.Name .. "\nJoined Server: " .. Time()
    info1.TextColor3 = Color3.new(1, 1, 1)
    info1.TextWrapped = true
    info1.TextXAlignment = Enum.TextXAlignment.Left
    info2.Name = randomString()
    info2.Parent = infoFrame
    info2.BackgroundTransparency = 1
    info2.BorderSizePixel = 0
    info2.Position = UDim2.new(0, 185, 0, 0)
    info2.Size = UDim2.new(0, 140, 1, -5)
    info2.ZIndex = 10
    info2.Font = Enum.Font.SourceSans
    info2.FontSize = Enum.FontSize.Size14
    info2.Text = "User ID: " .. userId .. "\nAccount Age: " .. player.AccountAge .. "\nJoined Roblox: Loading..."
    info2.TextColor3 = Color3.new(1, 1, 1)
    info2.TextWrapped = true
    info2.TextXAlignment = Enum.TextXAlignment.Left
    info2.TextYAlignment = Enum.TextYAlignment.Center
    ImageLabel_3.Parent = infoFrame
    ImageLabel_3.BackgroundTransparency = 1
    ImageLabel_3.BorderSizePixel = 0
    ImageLabel_3.Size = UDim2.new(0, 45, 1, 0)
    ImageLabel_3.Image = Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.AvatarThumbnail, Enum.ThumbnailSize.Size420x420)
    scroll_3.CanvasSize = UDim2.new(0, 0, 0, listlayout.AbsoluteContentSize.Y)
    scroll_3.CanvasPosition = Vector2.new(0, scroll_2.CanvasPosition.Y + infoFrame.AbsoluteSize.Y)
    local date = os.date("!%Y-%m-%d", os.time() - (player.AccountAge * 86400))
    local splitDates = string.split(date, "-")
    info2.Text = string.gsub(info2.Text, "Loading...", splitDates[2] .. "/" .. splitDates[3] .. "/" .. splitDates[1])
end

IYMouse.KeyDown:Connect(function(Key)
	if (Key==prefix) then
		RunService.RenderStepped:Wait()
		Cmdbar:CaptureFocus()
		maximizeHolder()
	end
end)

local lastMinimizeReq = 0
Holder.MouseEnter:Connect(function()
	lastMinimizeReq = 0
	maximizeHolder()
end)

Holder.MouseLeave:Connect(function()
	if not Cmdbar:IsFocused() then
		local reqTime = tick()
		lastMinimizeReq = reqTime
		wait(1)
		if lastMinimizeReq ~= reqTime then return end
		if not Cmdbar:IsFocused() then
			minimizeHolder()
		end
	end
end)

function updateColors(color,ctype)
	if ctype == shade1 then
		for i,v in pairs(shade1) do
			v.BackgroundColor3 = color
		end
		currentShade1 = color
	elseif ctype == shade2 then
		for i,v in pairs(shade2) do
			v.BackgroundColor3 = color
		end
		currentShade2 = color
	elseif ctype == shade3 then
		for i,v in pairs(shade3) do
			v.BackgroundColor3 = color
		end
		currentShade3 = color
	elseif ctype == text1 then
		for i,v in pairs(text1) do
			v.TextColor3 = color
			if v:IsA("TextBox") then
				v.PlaceholderColor3 = color	
			end
		end
		currentText1 = color
	elseif ctype == text2 then
		for i,v in pairs(text2) do
			v.TextColor3 = color
		end
		currentText2 = color
	elseif ctype == scroll then
		for i,v in pairs(scroll) do
			v.ScrollBarImageColor3 = color
		end
		currentScroll = color
	end
end

local colorpickerOpen = false
function NeverYieldOpenColorPicker()
	cache_currentShade1 = currentShade1
	cache_currentShade2 = currentShade2
	cache_currentShade3 = currentShade3
	cache_currentText1 = currentText1
	cache_currentText2 = currentText2
	cache_currentScroll = currentScroll
	if not colorpickerOpen then
		colorpickerOpen = true
		picker = game:GetObjects("rbxassetid://4908465318")[1]
		picker.Name = randomString()
		picker.Parent = ScaledHolder

		local ColorPicker do
			ColorPicker = {}

			ColorPicker.new = function()
				local newMt = setmetatable({},{})

				local pickerGui = picker.ColorPicker
				local pickerTopBar = pickerGui.TopBar
				local pickerExit = pickerTopBar.Exit
				local pickerFrame = pickerGui.Content
				local colorSpace = pickerFrame.ColorSpaceFrame.ColorSpace
				local colorStrip = pickerFrame.ColorStrip
				local previewFrame = pickerFrame.Preview
				local basicColorsFrame = pickerFrame.BasicColors
				local customColorsFrame = pickerFrame.CustomColors
				local defaultButton = pickerFrame.Default
				local cancelButton = pickerFrame.Cancel
				local shade1Button = pickerFrame.Shade1
				local shade2Button = pickerFrame.Shade2
				local shade3Button = pickerFrame.Shade3
				local text1Button = pickerFrame.Text1
				local text2Button = pickerFrame.Text2
				local scrollButton = pickerFrame.Scroll

				local colorScope = colorSpace.Scope
				local colorArrow = pickerFrame.ArrowFrame.Arrow

				local hueInput = pickerFrame.Hue.Input
				local satInput = pickerFrame.Sat.Input
				local valInput = pickerFrame.Val.Input

				local redInput = pickerFrame.Red.Input
				local greenInput = pickerFrame.Green.Input
				local blueInput = pickerFrame.Blue.Input

				local mouse = IYMouse

				local hue,sat,val = 0,0,1
				local red,green,blue = 1,1,1
				local chosenColor = Color3.new(0,0,0)

				local basicColors = {Color3.new(0,0,0),Color3.new(0.66666668653488,0,0),Color3.new(0,0.33333334326744,0),Color3.new(0.66666668653488,0.33333334326744,0),Color3.new(0,0.66666668653488,0),Color3.new(0.66666668653488,0.66666668653488,0),Color3.new(0,1,0),Color3.new(0.66666668653488,1,0),Color3.new(0,0,0.49803924560547),Color3.new(0.66666668653488,0,0.49803924560547),Color3.new(0,0.33333334326744,0.49803924560547),Color3.new(0.66666668653488,0.33333334326744,0.49803924560547),Color3.new(0,0.66666668653488,0.49803924560547),Color3.new(0.66666668653488,0.66666668653488,0.49803924560547),Color3.new(0,1,0.49803924560547),Color3.new(0.66666668653488,1,0.49803924560547),Color3.new(0,0,1),Color3.new(0.66666668653488,0,1),Color3.new(0,0.33333334326744,1),Color3.new(0.66666668653488,0.33333334326744,1),Color3.new(0,0.66666668653488,1),Color3.new(0.66666668653488,0.66666668653488,1),Color3.new(0,1,1),Color3.new(0.66666668653488,1,1),Color3.new(0.33333334326744,0,0),Color3.new(1,0,0),Color3.new(0.33333334326744,0.33333334326744,0),Color3.new(1,0.33333334326744,0),Color3.new(0.33333334326744,0.66666668653488,0),Color3.new(1,0.66666668653488,0),Color3.new(0.33333334326744,1,0),Color3.new(1,1,0),Color3.new(0.33333334326744,0,0.49803924560547),Color3.new(1,0,0.49803924560547),Color3.new(0.33333334326744,0.33333334326744,0.49803924560547),Color3.new(1,0.33333334326744,0.49803924560547),Color3.new(0.33333334326744,0.66666668653488,0.49803924560547),Color3.new(1,0.66666668653488,0.49803924560547),Color3.new(0.33333334326744,1,0.49803924560547),Color3.new(1,1,0.49803924560547),Color3.new(0.33333334326744,0,1),Color3.new(1,0,1),Color3.new(0.33333334326744,0.33333334326744,1),Color3.new(1,0.33333334326744,1),Color3.new(0.33333334326744,0.66666668653488,1),Color3.new(1,0.66666668653488,1),Color3.new(0.33333334326744,1,1),Color3.new(1,1,1)}
				local customColors = {}

				dragGUI(picker)

				local function updateColor(noupdate)
					local relativeX,relativeY,relativeStripY = 219 - hue*219, 199 - sat*199, 199 - val*199
					local hsvColor = Color3.fromHSV(hue,sat,val)

					if noupdate == 2 or not noupdate then
						hueInput.Text = tostring(math.ceil(359*hue))
						satInput.Text = tostring(math.ceil(255*sat))
						valInput.Text = tostring(math.floor(255*val))
					end
					if noupdate == 1 or not noupdate then
						redInput.Text = tostring(math.floor(255*red))
						greenInput.Text = tostring(math.floor(255*green))
						blueInput.Text = tostring(math.floor(255*blue))
					end

					chosenColor = Color3.new(red,green,blue)

					colorScope.Position = UDim2.new(0,relativeX-9,0,relativeY-9)
					colorStrip.ImageColor3 = Color3.fromHSV(hue,sat,1)
					colorArrow.Position = UDim2.new(0,-2,0,relativeStripY-4)
					previewFrame.BackgroundColor3 = chosenColor

					newMt.Color = chosenColor
					if newMt.Changed then newMt:Changed(chosenColor) end
				end

				local function colorSpaceInput()
					local relativeX = mouse.X - colorSpace.AbsolutePosition.X
					local relativeY = mouse.Y - colorSpace.AbsolutePosition.Y

					if relativeX < 0 then relativeX = 0 elseif relativeX > 219 then relativeX = 219 end
					if relativeY < 0 then relativeY = 0 elseif relativeY > 199 then relativeY = 199 end

					hue = (219 - relativeX)/219
					sat = (199 - relativeY)/199

					local hsvColor = Color3.fromHSV(hue,sat,val)
					red,green,blue = hsvColor.r,hsvColor.g,hsvColor.b

					updateColor()
				end

				local function colorStripInput()
					local relativeY = mouse.Y - colorStrip.AbsolutePosition.Y

					if relativeY < 0 then relativeY = 0 elseif relativeY > 199 then relativeY = 199 end	

					val = (199 - relativeY)/199

					local hsvColor = Color3.fromHSV(hue,sat,val)
					red,green,blue = hsvColor.r,hsvColor.g,hsvColor.b

					updateColor()
				end

				local function hookButtons(frame,func)
					frame.ArrowFrame.Up.InputBegan:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseMovement then
							frame.ArrowFrame.Up.BackgroundTransparency = 0.5
						elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
							local releaseEvent,runEvent

							local startTime = tick()
							local pressing = true
							local startNum = tonumber(frame.Text)

							if not startNum then return end

							releaseEvent = UserInputService.InputEnded:Connect(function(input)
								if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
								releaseEvent:Disconnect()
								pressing = false
							end)

							startNum = startNum + 1
							func(startNum)
							while pressing do
								if tick()-startTime > 0.3 then
									startNum = startNum + 1
									func(startNum)
								end
								wait(0.1)
							end
						end
					end)

					frame.ArrowFrame.Up.InputEnded:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseMovement then
							frame.ArrowFrame.Up.BackgroundTransparency = 1
						end
					end)

					frame.ArrowFrame.Down.InputBegan:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseMovement then
							frame.ArrowFrame.Down.BackgroundTransparency = 0.5
						elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
							local releaseEvent,runEvent

							local startTime = tick()
							local pressing = true
							local startNum = tonumber(frame.Text)

							if not startNum then return end

							releaseEvent = UserInputService.InputEnded:Connect(function(input)
								if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
								releaseEvent:Disconnect()
								pressing = false
							end)

							startNum = startNum - 1
							func(startNum)
							while pressing do
								if tick()-startTime > 0.3 then
									startNum = startNum - 1
									func(startNum)
								end
								wait(0.1)
							end
						end
					end)

					frame.ArrowFrame.Down.InputEnded:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseMovement then
							frame.ArrowFrame.Down.BackgroundTransparency = 1
						end
					end)
				end

				colorSpace.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						local releaseEvent,mouseEvent

						releaseEvent = UserInputService.InputEnded:Connect(function(input)
							if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
							releaseEvent:Disconnect()
							mouseEvent:Disconnect()
						end)

						mouseEvent = UserInputService.InputChanged:Connect(function(input)
							if input.UserInputType == Enum.UserInputType.MouseMovement then
								colorSpaceInput()
							end
						end)

						colorSpaceInput()
					end
				end)

				colorStrip.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						local releaseEvent,mouseEvent

						releaseEvent = UserInputService.InputEnded:Connect(function(input)
							if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
							releaseEvent:Disconnect()
							mouseEvent:Disconnect()
						end)

						mouseEvent = UserInputService.InputChanged:Connect(function(input)
							if input.UserInputType == Enum.UserInputType.MouseMovement then
								colorStripInput()
							end
						end)

						colorStripInput()
					end
				end)

				local function updateHue(str)
					local num = tonumber(str)
					if num then
						hue = math.clamp(math.floor(num),0,359)/359
						local hsvColor = Color3.fromHSV(hue,sat,val)
						red,green,blue = hsvColor.r,hsvColor.g,hsvColor.b
						hueInput.Text = tostring(hue*359)
						updateColor(1)
					end
				end
				hueInput.FocusLost:Connect(function() updateHue(hueInput.Text) end) hookButtons(hueInput,updateHue)

				local function updateSat(str)
					local num = tonumber(str)
					if num then
						sat = math.clamp(math.floor(num),0,255)/255
						local hsvColor = Color3.fromHSV(hue,sat,val)
						red,green,blue = hsvColor.r,hsvColor.g,hsvColor.b
						satInput.Text = tostring(sat*255)
						updateColor(1)
					end
				end
				satInput.FocusLost:Connect(function() updateSat(satInput.Text) end) hookButtons(satInput,updateSat)

				local function updateVal(str)
					local num = tonumber(str)
					if num then
						val = math.clamp(math.floor(num),0,255)/255
						local hsvColor = Color3.fromHSV(hue,sat,val)
						red,green,blue = hsvColor.r,hsvColor.g,hsvColor.b
						valInput.Text = tostring(val*255)
						updateColor(1)
					end
				end
				valInput.FocusLost:Connect(function() updateVal(valInput.Text) end) hookButtons(valInput,updateVal)

				local function updateRed(str)
					local num = tonumber(str)
					if num then
						red = math.clamp(math.floor(num),0,255)/255
						local newColor = Color3.new(red,green,blue)
						hue,sat,val = Color3.toHSV(newColor)
						redInput.Text = tostring(red*255)
						updateColor(2)
					end
				end
				redInput.FocusLost:Connect(function() updateRed(redInput.Text) end) hookButtons(redInput,updateRed)

				local function updateGreen(str)
					local num = tonumber(str)
					if num then
						green = math.clamp(math.floor(num),0,255)/255
						local newColor = Color3.new(red,green,blue)
						hue,sat,val = Color3.toHSV(newColor)
						greenInput.Text = tostring(green*255)
						updateColor(2)
					end
				end
				greenInput.FocusLost:Connect(function() updateGreen(greenInput.Text) end) hookButtons(greenInput,updateGreen)

				local function updateBlue(str)
					local num = tonumber(str)
					if num then
						blue = math.clamp(math.floor(num),0,255)/255
						local newColor = Color3.new(red,green,blue)
						hue,sat,val = Color3.toHSV(newColor)
						blueInput.Text = tostring(blue*255)
						updateColor(2)
					end
				end
				blueInput.FocusLost:Connect(function() updateBlue(blueInput.Text) end) hookButtons(blueInput,updateBlue)

				local colorChoice = Instance.new("TextButton")
				colorChoice.Name = "Choice"
				colorChoice.Size = UDim2.new(0,25,0,18)
				colorChoice.BorderColor3 = Color3.new(96/255,96/255,96/255)
				colorChoice.Text = ""
				colorChoice.AutoButtonColor = false
				colorChoice.ZIndex = 10

				local row = 0
				local column = 0
				for i,v in pairs(basicColors) do
					local newColor = colorChoice:Clone()
					newColor.BackgroundColor3 = v
					newColor.Position = UDim2.new(0,1 + 30*column,0,21 + 23*row)

					newColor.MouseButton1Click:Connect(function()
						red,green,blue = v.r,v.g,v.b
						local newColor = Color3.new(red,green,blue)
						hue,sat,val = Color3.toHSV(newColor)
						updateColor()
					end)	

					newColor.Parent = basicColorsFrame
					column = column + 1
					if column == 6 then row = row + 1 column = 0 end
				end

				row = 0
				column = 0
				for i = 1,12 do
					local color = customColors[i] or Color3.new(0,0,0)
					local newColor = colorChoice:Clone()
					newColor.BackgroundColor3 = color
					newColor.Position = UDim2.new(0,1 + 30*column,0,20 + 23*row)

					newColor.MouseButton1Click:Connect(function()
						local curColor = customColors[i] or Color3.new(0,0,0)
						red,green,blue = curColor.r,curColor.g,curColor.b
						hue,sat,val = Color3.toHSV(curColor)
						updateColor()
					end)

					newColor.MouseButton2Click:Connect(function()
						customColors[i] = chosenColor
						newColor.BackgroundColor3 = chosenColor
					end)

					newColor.Parent = customColorsFrame
					column = column + 1
					if column == 6 then row = row + 1 column = 0 end
				end

				shade1Button.MouseButton1Click:Connect(function() if newMt.Confirm then newMt:Confirm(chosenColor,shade1) end end)
				shade1Button.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then shade1Button.BackgroundTransparency = 0.4 end end)
				shade1Button.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then shade1Button.BackgroundTransparency = 0 end end)

				shade2Button.MouseButton1Click:Connect(function() if newMt.Confirm then newMt:Confirm(chosenColor,shade2) end end)
				shade2Button.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then shade2Button.BackgroundTransparency = 0.4 end end)
				shade2Button.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then shade2Button.BackgroundTransparency = 0 end end)

				shade3Button.MouseButton1Click:Connect(function() if newMt.Confirm then newMt:Confirm(chosenColor,shade3) end end)
				shade3Button.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then shade3Button.BackgroundTransparency = 0.4 end end)
				shade3Button.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then shade3Button.BackgroundTransparency = 0 end end)

				text1Button.MouseButton1Click:Connect(function() if newMt.Confirm then newMt:Confirm(chosenColor,text1) end end)
				text1Button.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then text1Button.BackgroundTransparency = 0.4 end end)
				text1Button.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then text1Button.BackgroundTransparency = 0 end end)

				text2Button.MouseButton1Click:Connect(function() if newMt.Confirm then newMt:Confirm(chosenColor,text2) end end)
				text2Button.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then text2Button.BackgroundTransparency = 0.4 end end)
				text2Button.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then text2Button.BackgroundTransparency = 0 end end)

				scrollButton.MouseButton1Click:Connect(function() if newMt.Confirm then newMt:Confirm(chosenColor,scroll) end end)
				scrollButton.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then scrollButton.BackgroundTransparency = 0.4 end end)
				scrollButton.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then scrollButton.BackgroundTransparency = 0 end end)

				cancelButton.MouseButton1Click:Connect(function() if newMt.Cancel then newMt:Cancel() end end)
				cancelButton.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then cancelButton.BackgroundTransparency = 0.4 end end)
				cancelButton.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then cancelButton.BackgroundTransparency = 0 end end)

				defaultButton.MouseButton1Click:Connect(function() if newMt.Default then newMt:Default() end end)
				defaultButton.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then defaultButton.BackgroundTransparency = 0.4 end end)
				defaultButton.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then defaultButton.BackgroundTransparency = 0 end end)

				pickerExit.MouseButton1Click:Connect(function()
					picker:TweenPosition(UDim2.new(0.5, -219, 0, -500), "InOut", "Quart", 0.5, true, nil)
				end)

				updateColor()

				newMt.SetColor = function(self,color)
					red,green,blue = color.r,color.g,color.b
					hue,sat,val = Color3.toHSV(color)
					updateColor()
				end

				return newMt
			end
		end

		picker:TweenPosition(UDim2.new(0.5, -219, 0, 100), "InOut", "Quart", 0.5, true, nil)

		local Npicker = ColorPicker.new()
		Npicker.Confirm = function(self,color,ctype) updateColors(color,ctype) pcall(function() NeverYieldTheme.selected = "custom" NeverYieldTheme.active = nil writefile("NeverYield_theme.txt", "custom", true) end) wait() updatesaves() end
		Npicker.Cancel = function(self)
			updateColors(cache_currentShade1,shade1)
			updateColors(cache_currentShade2,shade2)
			updateColors(cache_currentShade3,shade3)
			updateColors(cache_currentText1,text1)
			updateColors(cache_currentText2,text2)
			updateColors(cache_currentScroll,scroll)
			wait()
			updatesaves()
		end
		Npicker.Default = function(self)
			updateColors(Color3.fromRGB(16, 10, 34),shade1)
			updateColors(Color3.fromRGB(32, 18, 64),shade2)
			updateColors(Color3.fromRGB(86, 50, 160),shade3)
			updateColors(Color3.new(1, 1, 1),text1)
			updateColors(Color3.new(0, 0, 0),text2)
			updateColors(Color3.fromRGB(86, 50, 160),scroll)
			wait()
			updatesaves()
		end
	else
		picker:TweenPosition(UDim2.new(0.5, -219, 0, 100), "InOut", "Quart", 0.5, true, nil)
	end
end

ColorsButton.MouseButton1Click:Connect(function()
	local ok, err = pcall(function() NeverYieldTheme.openStudio() end)
	if not ok then
		pcall(NeverYieldTheme.closeStudio)
		notify('Theme Studio', 'Could not open: ' .. tostring(err))
	end
end)


SettingsButton.MouseButton1Click:Connect(function()
	if SettingsOpen == false then SettingsOpen = true
		Settings:TweenPosition(UDim2.new(0, 0, 0, 45), "InOut", "Quart", 0.5, true, nil)
		CMDsF.Visible = false
	else SettingsOpen = false
		CMDsF.Visible = true
		Settings:TweenPosition(UDim2.new(0, 0, 0, 220), "InOut", "Quart", 0.5, true, nil)
	end
end)

On.MouseButton1Click:Connect(function()
	if isHidden == false then
		if StayOpen == false then
			StayOpen = true
			On.BackgroundTransparency = 0
		else
			StayOpen = false
			On.BackgroundTransparency = 1
		end
		updatesaves()
	end
end)

Clear.MouseButton1Down:Connect(function()
	for _, child in pairs(scroll_2:GetChildren()) do
		child:Destroy()
	end
	scroll_2.CanvasSize = UDim2.new(0, 0, 0, 10)
end)

Clear_2.MouseButton1Down:Connect(function()
	for _, child in pairs(scroll_3:GetChildren()) do
		child:Destroy()
	end
	scroll_3.CanvasSize = UDim2.new(0, 0, 0, 10)
end)

Toggle.MouseButton1Down:Connect(function()
	if logsEnabled then
		logsEnabled = false
		Toggle.Text = 'Disabled'
		updatesaves()
	else
		logsEnabled = true
		Toggle.Text = 'Enabled'
		updatesaves()
	end
end)

Toggle_2.MouseButton1Down:Connect(function()
	if jLogsEnabled then
		jLogsEnabled = false
		Toggle_2.Text = 'Disabled'
		updatesaves()
	else
		jLogsEnabled = true
		Toggle_2.Text = 'Enabled'
		updatesaves()
	end
end)

selectChat.MouseButton1Down:Connect(function()
	join.Visible = false
	chat.Visible = true
	table.remove(shade3,table.find(shade3,selectChat))
	table.remove(shade2,table.find(shade2,selectJoin))
	table.insert(shade2,selectChat)
	table.insert(shade3,selectJoin)
	selectJoin.BackgroundColor3 = currentShade3
	selectChat.BackgroundColor3 = currentShade2
end)

selectJoin.MouseButton1Down:Connect(function()
	chat.Visible = false
	join.Visible = true	
	table.remove(shade3,table.find(shade3,selectJoin))
	table.remove(shade2,table.find(shade2,selectChat))
	table.insert(shade2,selectJoin)
	table.insert(shade3,selectChat)
	selectChat.BackgroundColor3 = currentShade3
	selectJoin.BackgroundColor3 = currentShade2
end)

if not writefileExploit() then
	notify("Saves", "Your exploit does not support read/write file. Your settings will not save.")
end

avatarcache = {}
function sendChatWebhook(player, message)
	if httprequest and vtype(logsWebhook, "string") then
		local id = player.UserId
		local avatar = avatarcache[id]
		if not avatar then
			local d = HttpService:JSONDecode(httprequest({
				Url = "https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=" .. id .. "&size=420x420&format=Png&isCircular=false",
				Method = "GET"
			}).Body)["data"]
			avatar = d and d[1].state == "Completed" and d[1].imageUrl or "https://files.catbox.moe/i968v2.jpg"
			avatarcache[id] = avatar
		end
		local log = HttpService:JSONEncode({
			content = message,
			avatar_url = avatar,
			username = formatUsername(player),
			allowed_mentions = {parse = {}}
		})
		httprequest({
			Url = logsWebhook,
			Method = "POST",
			Headers = {["Content-Type"] = "application/json"},
			Body = log
		})
	end
end

ChatLog = function(player)
	player.Chatted:Connect(function(message)
		if logsEnabled == true then
			CreateLabel(player.Name, message)
			sendChatWebhook(player, message)
		end
	end)
end

JoinLog = function(plr)
	if jLogsEnabled == true then
		CreateJoinLabel(plr,plr.UserId)
	end
end

CleanFileName = function(name)
	return tostring(name):gsub("[*\\?:<>|]+", ""):sub(1, 175)
end

SaveChatlogs.MouseButton1Down:Connect(function()
	if writefileExploit() then
		if #scroll_2:GetChildren() > 0 then
			notify("Loading",'Hold on a sec')
			local placeName = CleanFileName(MarketplaceService:GetProductInfo(PlaceId).Name)
			local writelogs = '-- NeverYield Chat logs for "'..placeName..'"\n'
			for _, child in pairs(scroll_2:GetChildren()) do
				writelogs = writelogs..'\n'..child.Text
			end
			local writelogsFile = tostring(writelogs)
			local fileext = 0
			local function nameFile()
				local file
				pcall(function() file = readfile(placeName..' Chat Logs ('..fileext..').txt') end)
				if file then
					fileext = fileext+1
					nameFile()
				else
					writefileCooldown(placeName..' Chat Logs ('..fileext..').txt', writelogsFile)
				end
			end
			nameFile()
			notify('Chat Logs','Saved chat logs to the workspace folder within your exploit folder.')
		end
	else
		notify('Chat Logs','Your exploit does not support write file. You cannot save chat logs.')
	end
end)

if isLegacyChat then
	for _, plr in pairs(Players:GetPlayers()) do
		ChatLog(plr)
	end
end

Players.PlayerRemoving:Connect(function(player)
	if ESPenabled or CHMSenabled or COREGUI:FindFirstChild(player.Name..'_LC') then
		for i,v in pairs(COREGUI:GetChildren()) do
			if v.Name == player.Name..'_ESP' or v.Name == player.Name..'_LC' or v.Name == player.Name..'_CHMS' then
				v:Destroy()
			end
		end
	end
	if viewing ~= nil and player == viewing then
		workspace.CurrentCamera.CameraSubject = Players.LocalPlayer.Character
		viewing = nil
		if viewDied then
			viewDied:Disconnect()
			viewChanged:Disconnect()
		end
		notify('Spectate','View turned off (player left)')
	end
	eventEditor.FireEvent("OnLeave", player.Name)
end)

Exit.MouseButton1Down:Connect(function()
	logs:TweenPosition(UDim2.new(0, 0, 1, 10), "InOut", "Quart", 0.3, true, nil)
end)

Hide.MouseButton1Down:Connect(function()
	if logs.Position ~= UDim2.new(0, 0, 1, -20) then
		logs:TweenPosition(UDim2.new(0, 0, 1, -20), "InOut", "Quart", 0.3, true, nil)
	else
		logs:TweenPosition(UDim2.new(0, 0, 1, -265), "InOut", "Quart", 0.3, true, nil)
	end
end)

EventBind.MouseButton1Click:Connect(function()
	eventEditor.Frame:TweenPosition(UDim2.new(0.5,-175,0.5,-101), "InOut", "Quart", 0.5, true, nil)
end)

Keybinds.MouseButton1Click:Connect(function()
	KeybindsFrame:TweenPosition(UDim2.new(0, 0, 0, 0), "InOut", "Quart", 0.5, true, nil)
	wait(0.5)
	SettingsHolder.Visible = false
end)

Close.MouseButton1Click:Connect(function()
	SettingsHolder.Visible = true
	KeybindsFrame:TweenPosition(UDim2.new(0, 0, 0, 175), "InOut", "Quart", 0.5, true, nil)
end)

Keybinds.MouseButton1Click:Connect(function()
	KeybindsFrame:TweenPosition(UDim2.new(0, 0, 0, 0), "InOut", "Quart", 0.5, true, nil)
	wait(0.5)
	SettingsHolder.Visible = false
end)

Add.MouseButton1Click:Connect(function()
	KeybindEditor:TweenPosition(UDim2.new(0.5, -180, 0, 260), "InOut", "Quart", 0.5, true, nil)
end)

Delete.MouseButton1Click:Connect(function()
	binds = {}
	refreshbinds()
	updatesaves()
	notify('Keybinds Updated','Removed all keybinds')
end)

Close_2.MouseButton1Click:Connect(function()
	SettingsHolder.Visible = true
	AliasesFrame:TweenPosition(UDim2.new(0, 0, 0, 175), "InOut", "Quart", 0.5, true, nil)
end)

Aliases.MouseButton1Click:Connect(function()
	AliasesFrame:TweenPosition(UDim2.new(0, 0, 0, 0), "InOut", "Quart", 0.5, true, nil)
	wait(0.5)
	SettingsHolder.Visible = false
end)

Close_3.MouseButton1Click:Connect(function()
	SettingsHolder.Visible = true
	PositionsFrame:TweenPosition(UDim2.new(0, 0, 0, 175), "InOut", "Quart", 0.5, true, nil)
end)

Positions.MouseButton1Click:Connect(function()
	PositionsFrame:TweenPosition(UDim2.new(0, 0, 0, 0), "InOut", "Quart", 0.5, true, nil)
	wait(0.5)
	SettingsHolder.Visible = false
end)

local selectionBox = Instance.new("SelectionBox")
selectionBox.Name = randomString()
selectionBox.Color3 = Color3.new(255,255,255)
selectionBox.Adornee = nil
selectionBox.Parent = PARENT

local selected = Instance.new("SelectionBox")
selected.Name = randomString()
selected.Color3 = Color3.new(0,166,0)
selected.Adornee = nil
selected.Parent = PARENT

local ActivateHighlight = nil
local ClickSelect = nil
function selectPart()
	ToPartFrame:TweenPosition(UDim2.new(0.5, -180, 0, 335), "InOut", "Quart", 0.5, true, nil)
	local function HighlightPart()
		if selected.Adornee ~= IYMouse.Target then
			selectionBox.Adornee = IYMouse.Target
		else
			selectionBox.Adornee = nil
		end
	end
	ActivateHighlight = IYMouse.Move:Connect(HighlightPart)
	local function SelectPart()
		if IYMouse.Target ~= nil then
			selected.Adornee = IYMouse.Target
			Path.Text = getHierarchy(IYMouse.Target)
		end
	end
	ClickSelect = IYMouse.Button1Down:Connect(SelectPart)
end

Part.MouseButton1Click:Connect(function()
	selectPart()
end)

Exit_4.MouseButton1Click:Connect(function()
	ToPartFrame:TweenPosition(UDim2.new(0.5, -180, 0, -500), "InOut", "Quart", 0.5, true, nil)
	if ActivateHighlight then
		ActivateHighlight:Disconnect()
	end
	if ClickSelect then
		ClickSelect:Disconnect()
	end
	selectionBox.Adornee = nil
	selected.Adornee = nil
	Path.Text = ""
end)

CopyPath.MouseButton1Click:Connect(function()
	if Path.Text ~= "" then
		toClipboard(Path.Text)
	else
		notify('Copy Path','Select a part to copy its path')
	end
end)

ChoosePart.MouseButton1Click:Connect(function()
	if Path.Text ~= "" then
		local tpNameExt = ''
		local function handleWpNames()
			local FoundDupe = false
			for i,v in pairs(pWayPoints) do
				if v.NAME:lower() == selected.Adornee.Name:lower()..tpNameExt then
					FoundDupe = true
				end
			end
			if not FoundDupe then
				notify('Modified Waypoints',"Created waypoint: "..selected.Adornee.Name..tpNameExt)
				pWayPoints[#pWayPoints + 1] = {NAME = selected.Adornee.Name..tpNameExt, COORD = {selected.Adornee}}
			else
				if isNumber(tpNameExt) then
					tpNameExt = tpNameExt+1
				else
					tpNameExt = 1
				end
				handleWpNames()
			end
		end
		handleWpNames()
		refreshwaypoints()
	else
		notify('Part Selection','Select a part first')
	end
end)

cmds={}
customAlias = {}
Delete_3.MouseButton1Click:Connect(function()
	customAlias = {}
	aliases = {}
	notify('Aliases Modified','Removed all aliases')
	updatesaves()
	refreshaliases()
end)

PrefixBox:GetPropertyChangedSignal("Text"):Connect(function()
	prefix = PrefixBox.Text
	Cmdbar.PlaceholderText = "Command Bar ("..prefix..")"
	updatesaves()
end)

function CamViewport()
	if workspace.CurrentCamera then
		return workspace.CurrentCamera.ViewportSize.X
	end
end

function UpdateToViewport()
	if Holder.Position.X.Offset < -CamViewport() then
		Holder:TweenPosition(UDim2.new(1, -CamViewport(), Holder.Position.Y.Scale, Holder.Position.Y.Offset), "InOut", "Quart", 0.04, true, nil)
		Notification:TweenPosition(UDim2.new(1, -CamViewport() + 250, Notification.Position.Y.Scale, Notification.Position.Y.Offset), "InOut", "Quart", 0.04, true, nil)
	end
end
CameraChanged = workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateToViewport)

function updateCamera(child, parent)
	if parent ~= workspace then
		CamMoved:Disconnect()
		CameraChanged:Disconnect()
		repeat wait() until workspace.CurrentCamera
		CameraChanged = workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateToViewport)
		CamMoved = workspace.CurrentCamera.AncestryChanged:Connect(updateCamera)
	end
end
CamMoved = workspace.CurrentCamera.AncestryChanged:Connect(updateCamera)

function dragMain(dragpoint,gui)
	task.spawn(function()
		local dragging
		local dragInput
		local dragStart = Vector3.new(0,0,0)
		local startPos
		local function update(input)
			local pos = -250
			local delta = input.Position - dragStart
			if startPos.X.Offset + delta.X <= -500 then
				local Position = UDim2.new(1, -250, Notification.Position.Y.Scale, Notification.Position.Y.Offset)
				TweenService:Create(Notification, TweenInfo.new(.20), {Position = Position}):Play()
				pos = 250
			else
				local Position = UDim2.new(1, -500, Notification.Position.Y.Scale, Notification.Position.Y.Offset)
				TweenService:Create(Notification, TweenInfo.new(.20), {Position = Position}):Play()
				pos = -250
			end
			if startPos.X.Offset + delta.X <= -250 and -CamViewport() <= startPos.X.Offset + delta.X then
				local Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, gui.Position.Y.Scale, gui.Position.Y.Offset)
				TweenService:Create(gui, TweenInfo.new(.20), {Position = Position}):Play()
				local Position2 = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X + pos, Notification.Position.Y.Scale, Notification.Position.Y.Offset)
				TweenService:Create(Notification, TweenInfo.new(.20), {Position = Position2}):Play()
			elseif startPos.X.Offset + delta.X > -500 then
				local Position = UDim2.new(1, -250, gui.Position.Y.Scale, gui.Position.Y.Offset)
				TweenService:Create(gui, TweenInfo.new(.20), {Position = Position}):Play()
			elseif -CamViewport() > startPos.X.Offset + delta.X then
				gui:TweenPosition(UDim2.new(1, -CamViewport(), gui.Position.Y.Scale, gui.Position.Y.Offset), "InOut", "Quart", 0.04, true, nil)
				local Position = UDim2.new(1, -CamViewport(), gui.Position.Y.Scale, gui.Position.Y.Offset)
				TweenService:Create(gui, TweenInfo.new(.20), {Position = Position}):Play()
				local Position2 = UDim2.new(1, -CamViewport() + 250, Notification.Position.Y.Scale, Notification.Position.Y.Offset)
				TweenService:Create(Notification, TweenInfo.new(.20), {Position = Position2}):Play()
			end
		end
		dragpoint.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = input.Position
				startPos = gui.Position

				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						dragging = false
					end
				end)
			end
		end)
		dragpoint.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				dragInput = input
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if input == dragInput and dragging then
				update(input)
			end
		end)
	end)
end

dragMain(Title,Holder)

Match = function(name,str)
	str = str:gsub("%W", "%%%1")
	return name:lower():find(str:lower()) and true
end

local canvasPos = Vector2.new(0,0)
local topCommand = nil
local function updateCommandCanvasSize(frame)
	local scale = (Scale and Scale.Scale) or 1
	if scale <= 0 then scale = 1 end
	local contentY = cmdListLayout.AbsoluteContentSize.Y
	local unscaledY = math.ceil(contentY / scale)
	frame.CanvasSize = UDim2.new(0, 0, 0, math.max(0, unscaledY))
end
cmdListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	updateCommandCanvasSize(CMDsF)
end)
IndexContents = function(str,bool,cmdbar,Ianim)
	CMDsF.CanvasPosition = Vector2.new(0,0)
	local SizeY = 0
	local indexnum = 0
	local frame = CMDsF
	topCommand = nil
	local chunks = {}
	if str:sub(#str,#str) == "\\" then str = "" end
	for w in string.gmatch(str,"[^\\]+") do
		table.insert(chunks,w)
	end
	if #chunks > 0 then str = chunks[#chunks] end
	if str:sub(1,1) == "!" then str = str:sub(2) end
	for i,v in next, frame:GetChildren() do
		if v:IsA("TextButton") then
			if bool then
				if Match(v.Text,str) then
					indexnum = indexnum + 1
					v.Visible = true
					if topCommand == nil then
						topCommand = v.Text
					end
				else
					v.Visible = false
				end
			else
				v.Visible = true
				if topCommand == nil then
					topCommand = v.Text
				end
			end
		end
	end
	updateCommandCanvasSize(frame)
	if not Ianim then
		if indexnum == 0 or string.find(str, " ") then
			if not cmdbar then
				minimizeHolder()
			elseif cmdbar then
				cmdbarHolder()
			end
		else
			maximizeHolder()
		end
	else
		minimizeHolder()
	end
end

task.spawn(function()
	if not isLegacyChat then return end
	local chatbox
	local success, result = pcall(function() chatbox = PlayerGui:WaitForChild("Chat").Frame.ChatBarParentFrame.Frame.BoxFrame.Frame.ChatBar end)
	if success then
		local function chatboxFocused()
			canvasPos = CMDsF.CanvasPosition
		end
		local chatboxFocusedC = chatbox.Focused:Connect(chatboxFocused)

		local function Index()
			if chatbox.Text:lower():sub(1,1) == prefix then
				if SettingsOpen == true then
					wait(0.2)
					CMDsF.Visible = true
					Settings:TweenPosition(UDim2.new(0, 0, 0, 220), "InOut", "Quart", 0.2, true, nil)
				end
				IndexContents(PlayerGui.Chat.Frame.ChatBarParentFrame.Frame.BoxFrame.Frame.ChatBar.Text:lower():sub(2),true)
			else
				minimizeHolder()
				if SettingsOpen == true then
					wait(0.2)
					Settings:TweenPosition(UDim2.new(0, 0, 0, 45), "InOut", "Quart", 0.2, true, nil)
					CMDsF.Visible = false
				end
			end
		end
		local chatboxFunc = chatbox:GetPropertyChangedSignal("Text"):Connect(Index)

		local function chatboxFocusLost(enterpressed)
			if not enterpressed or chatbox.Text:lower():sub(1,1) ~= prefix then
				IndexContents('',true)
			end
			CMDsF.CanvasPosition = canvasPos
			minimizeHolder()
		end
		local chatboxFocusLostC = chatbox.FocusLost:Connect(chatboxFocusLost)

		PlayerGui:WaitForChild("Chat").Frame.ChatBarParentFrame.ChildAdded:Connect(function(newbar)
			wait()
			if newbar:FindFirstChild('BoxFrame') then
				chatbox = PlayerGui:WaitForChild("Chat").Frame.ChatBarParentFrame.Frame.BoxFrame.Frame.ChatBar
				if chatboxFocusedC then chatboxFocusedC:Disconnect() end
				chatboxFocusedC = chatbox.Focused:Connect(chatboxFocused)
				if chatboxFunc then chatboxFunc:Disconnect() end
				chatboxFunc = chatbox:GetPropertyChangedSignal("Text"):Connect(Index)
				if chatboxFocusLostC then chatboxFocusLostC:Disconnect() end
				chatboxFocusLostC = chatbox.FocusLost:Connect(chatboxFocusLost)
			end
		end)
		--else
		--print('Custom chat detected. Will not provide suggestions for commands typed in the chat.')
	end
end)

function autoComplete(str,curText)
	local endingChar = {"[", "/", "(", " "}
	local stop = 0
	for i=1,#str do
		local c = str:sub(i,i)
		if table.find(endingChar, c) then
			stop = i
			break
		end
	end
	curText = curText or Cmdbar.Text
	local subPos = 0
	local pos = 1
	local findRes = string.find(curText,"\\",pos)
	while findRes do
		subPos = findRes
		pos = findRes+1
		findRes = string.find(curText,"\\",pos)
	end
	if curText:sub(subPos+1,subPos+1) == "!" then subPos = subPos + 1 end
	Cmdbar.Text = curText:sub(1,subPos) .. str:sub(1, stop - 1)..' '
	RunService.RenderStepped:Wait()
	Cmdbar.Text = Cmdbar.Text:gsub( '\t', '' )
	Cmdbar.CursorPosition = #Cmdbar.Text+1--1020
end

CMDs = {}
CMDs[#CMDs + 1] = {NAME = 'discord / support / help', DESC = 'Invite to the Infinite Yield discord server.'}
CMDs[#CMDs + 1] = {NAME = 'guiscale [number]', DESC = 'Changes the size of the gui. [number] accepts decimals and whole numbers. Min is 0.4 and Max is 2'}
CMDs[#CMDs + 1] = {NAME = 'console', DESC = 'Opens the Roblox console'}
CMDs[#CMDs + 1] = {NAME = 'oldconsole', DESC = 'Loads an old-themed Roblox console'}
CMDs[#CMDs + 1] = {NAME = 'explorer / dex', DESC = 'Opens Dex++ by Chillz'}
CMDs[#CMDs + 1] = {NAME = 'moondex / mdex', DESC = 'Opens DEX by Moon'}
CMDs[#CMDs + 1] = {NAME = 'remotespy / rspy', DESC = 'Opens Cobalt to intercept incoming and outgoing network traffic'}
CMDs[#CMDs + 1] = {NAME = 'simplespy / sspy', DESC = 'Opens Simple Spy V3 to intercept remote calls from the client to the server'}
CMDs[#CMDs + 1] = {NAME = 'audiologger / alogger', DESC = 'Opens Edges audio logger'}
CMDs[#CMDs + 1] = {NAME = 'serverinfo / info', DESC = 'Gives you info about the server'}
CMDs[#CMDs + 1] = {NAME = 'jobid', DESC = 'Copies the games JobId to your clipboard'}
CMDs[#CMDs + 1] = {NAME = 'notifyjobid', DESC = 'Notifies you the games JobId'}
CMDs[#CMDs + 1] = {NAME = 'rejoin / rj [reposition]', DESC = 'Makes you rejoin the game'}
CMDs[#CMDs + 1] = {NAME = 'inviteprompt', DESC = 'Prompts the user of your choice that they had invited you. Requires a rejoin to function.'}
CMDs[#CMDs + 1] = {NAME = 'autorejoin / autorj', DESC = 'Automatically rejoins the server if you get kicked/disconnected'}
CMDs[#CMDs + 1] = {NAME = 'serverhop / shop', DESC = 'Teleports you to a different server'}
CMDs[#CMDs + 1] = {NAME = 'gameteleport / gametp [place ID]', DESC = 'Joins a game by ID'}
CMDs[#CMDs + 1] = {NAME = 'antiidle / antiafk', DESC = 'Prevents the game from kicking you for being idle/afk'}
CMDs[#CMDs + 1] = {NAME = 'datalimit [num]', DESC = 'Set outgoing KBPS limit'}
CMDs[#CMDs + 1] = {NAME = 'replicationlag / backtrack [num]', DESC = 'Set IncomingReplicationLag'}
CMDs[#CMDs + 1] = {NAME = 'creatorid / creator', DESC = 'Notifies you the creators ID'}
CMDs[#CMDs + 1] = {NAME = 'copycreatorid / copycreator', DESC = 'Copies the creators ID to your clipboard'}
CMDs[#CMDs + 1] = {NAME = 'setcreatorid / setcreator', DESC = 'Sets your userid to the creators ID'}
CMDs[#CMDs + 1] = {NAME = 'noprompts', DESC = 'Prevents the game from showing you purchase/premium prompts'}
CMDs[#CMDs + 1] = {NAME = 'showprompts', DESC = 'Allows the game to show purchase/premium prompts again'}
CMDs[#CMDs + 1] = {NAME = 'enable [inventory/playerlist/chat/reset/emotes/all]', DESC = 'Toggles visibility of coregui items'}
CMDs[#CMDs + 1] = {NAME = 'disable [inventory/playerlist/chat/reset/emotes/all]', DESC = 'Toggles visibility of coregui items'}
CMDs[#CMDs + 1] = {NAME = 'showguis', DESC = 'Shows any invisible GUIs'}
CMDs[#CMDs + 1] = {NAME = 'unshowguis', DESC = 'Undoes showguis'}
CMDs[#CMDs + 1] = {NAME = 'hideguis', DESC = 'Hides any GUIs in PlayerGui'}
CMDs[#CMDs + 1] = {NAME = 'unhideguis', DESC = 'Undoes hideguis'}
CMDs[#CMDs + 1] = {NAME = 'guidelete', DESC = 'Enables backspace to delete GUI'}
CMDs[#CMDs + 1] = {NAME = 'unguidelete / noguidelete', DESC = 'Disables guidelete'}
CMDs[#CMDs + 1] = {NAME = 'hideiy', DESC = 'Hides the main IY GUI'}
CMDs[#CMDs + 1] = {NAME = 'showiy / unhideiy', DESC = 'Shows IY again'}
CMDs[#CMDs + 1] = {NAME = 'keepiy', DESC = 'Auto execute IY when you teleport through servers'}
CMDs[#CMDs + 1] = {NAME = 'unkeepiy', DESC = 'Disable keepiy'}
CMDs[#CMDs + 1] = {NAME = 'togglekeepiy', DESC = 'Toggles keepiy'}
CMDs[#CMDs + 1] = {NAME = 'removeads / adblock', DESC = 'Automatically removes ad billboards'}
CMDs[#CMDs + 1] = {NAME = 'savegame / saveplace', DESC = 'Uses saveinstance to save the game'}
CMDs[#CMDs + 1] = {NAME = 'clearerror', DESC = 'Clears the annoying box and blur when a game kicks you'}
CMDs[#CMDs + 1] = {NAME = 'antigameplaypaused', DESC = 'Clears the annoying box shown when a game is loading assets due to network lag'}
CMDs[#CMDs + 1] = {NAME = 'unantigameplaypaused', DESC = 'Disables antigameplaypaused'}
CMDs[#CMDs + 1] = {NAME = 'clientantikick / antikick (CLIENT)', DESC = 'Prevents localscripts from kicking you'}
CMDs[#CMDs + 1] = {NAME = 'clientantiteleport / antiteleport (CLIENT)', DESC = 'Prevents localscripts from teleporting you'}
CMDs[#CMDs + 1] = {NAME = 'allowrejoin / allowrj (CLIENT)', DESC = 'Toggles if antiteleport allows you to rejoin or not'}
CMDs[#CMDs + 1] = {NAME = 'cancelteleport / canceltp', DESC = 'Cancels teleports in progress'}
CMDs[#CMDs + 1] = {NAME = 'volume / vol [0-10]', DESC = 'Adjusts your game volume on a scale of 0 to 10'}
CMDs[#CMDs + 1] = {NAME = 'antilag / boostfps / lowgraphics', DESC = 'Lowers game quality to boost FPS'}
CMDs[#CMDs + 1] = {NAME = 'record / rec', DESC = 'Starts Roblox recorder'}
CMDs[#CMDs + 1] = {NAME = 'screenshot / scrnshot', DESC = 'Takes a screenshot'}
CMDs[#CMDs + 1] = {NAME = 'togglefullscreen / togglefs', DESC = 'Toggles fullscreen'}
CMDs[#CMDs + 1] = {NAME = 'notify [text]', DESC = 'Sends you a notification with the provided text'}
CMDs[#CMDs + 1] = {NAME = 'lastcommand / lastcmd', DESC = 'Executes the previous command used'}
CMDs[#CMDs + 1] = {NAME = 'notifyping / ping', DESC = 'Notify yourself your ping'}
CMDs[#CMDs + 1] = {NAME = 'norender', DESC = 'Disable 3d Rendering to decrease the amount of CPU the client uses'}
CMDs[#CMDs + 1] = {NAME = 'render', DESC = 'Enable 3d Rendering'}
CMDs[#CMDs + 1] = {NAME = 'use2022materials / 2022materials', DESC = 'Enables 2022 material textures'}
CMDs[#CMDs + 1] = {NAME = 'unuse2022materials / un2022materials', DESC = 'Disables 2022 material textures'}
CMDs[#CMDs + 1] = {NAME = 'alignmentkeys', DESC = 'Enables the left and right alignment keys (comma and period)'}
CMDs[#CMDs + 1] = {NAME = 'unalignmentkeys / noalignmentkeys', DESC = 'Disables the alignment keys'}
CMDs[#CMDs + 1] = {NAME = 'ctrllock', DESC = 'Binds Shiftlock to LeftControl'}
CMDs[#CMDs + 1] = {NAME = 'unctrllock', DESC = 'Re-binds Shiftlock to LeftShift'}
CMDs[#CMDs + 1] = {NAME = 'exit / shutdown / leave', DESC = 'Exits the game'}
CMDs[#CMDs + 1] = {NAME = 'removecmd / deletecmd', DESC = 'Removes a command until the script is reloaded'}
CMDs[#CMDs + 1] = {NAME = 'breakloops / break (cmd loops)', DESC = 'Stops any cmd loops (;100^1^cmd)'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'noclip', DESC = 'Go through objects'}
CMDs[#CMDs + 1] = {NAME = 'unnoclip / clip', DESC = 'Disables noclip'}
CMDs[#CMDs + 1] = {NAME = 'fly [speed]', DESC = 'Makes you fly'}
CMDs[#CMDs + 1] = {NAME = 'unfly', DESC = 'Disables fly'}
CMDs[#CMDs + 1] = {NAME = 'flyspeed [num]', DESC = 'Set fly speed (default is 20)'}
CMDs[#CMDs + 1] = {NAME = 'vehiclefly / vfly [speed]', DESC = 'Makes you fly in a vehicle'}
CMDs[#CMDs + 1] = {NAME = 'unvehiclefly / unvfly', DESC = 'Disables vehicle fly'}
CMDs[#CMDs + 1] = {NAME = 'vehicleflyspeed  / vflyspeed [num]', DESC = 'Set vehicle fly speed'}
CMDs[#CMDs + 1] = {NAME = 'cframefly / cfly [speed]', DESC = 'Makes you fly, bypassing some anti cheats (works on mobile)'}
CMDs[#CMDs + 1] = {NAME = 'uncframefly / uncfly', DESC = 'Disables cfly'}
CMDs[#CMDs + 1] = {NAME = 'cframeflyspeed  / cflyspeed [num]', DESC = 'Sets cfly speed'}
CMDs[#CMDs + 1] = {NAME = 'qefly [true / false]', DESC = 'Enables or disables the Q and E hotkeys for fly'}
CMDs[#CMDs + 1] = {NAME = 'vehiclenoclip / vnoclip', DESC = 'Turns off vehicle collision'}
CMDs[#CMDs + 1] = {NAME = 'vehicleclip / vclip / unvnoclip', DESC = 'Enables vehicle collision'}
CMDs[#CMDs + 1] = {NAME = 'float /  platform', DESC = 'Spawns a platform beneath you causing you to float'}
CMDs[#CMDs + 1] = {NAME = 'unfloat / noplatform', DESC = 'Removes the platform'}
CMDs[#CMDs + 1] = {NAME = 'swim', DESC = 'Allows you to swim in the air'}
CMDs[#CMDs + 1] = {NAME = 'unswim / noswim', DESC = 'Stops you from swimming everywhere'}
CMDs[#CMDs + 1] = {NAME = 'toggleswim', DESC = 'Toggles swimming'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'setwaypoint / swp [name]', DESC = 'Sets a waypoint at your position'}
CMDs[#CMDs + 1] = {NAME = 'waypointpos / wpp [name] [X Y Z]', DESC = 'Sets a waypoint with specified coordinates'}
CMDs[#CMDs + 1] = {NAME = 'waypoints', DESC = 'Shows a list of currently active waypoints'}
CMDs[#CMDs + 1] = {NAME = 'showwaypoints / showwp', DESC = 'Shows all currently set waypoints'}
CMDs[#CMDs + 1] = {NAME = 'hidewaypoints / hidewp', DESC = 'Hides shown waypoints'}
CMDs[#CMDs + 1] = {NAME = 'waypoint / wp [name]', DESC = 'Teleports player to a waypoint'}
CMDs[#CMDs + 1] = {NAME = 'tweenwaypoint / twp [name]', DESC = 'Tweens player to a waypoint'}
CMDs[#CMDs + 1] = {NAME = 'walktowaypoint / wtwp [name]', DESC = 'Walks player to a waypoint'}
CMDs[#CMDs + 1] = {NAME = 'deletewaypoint / dwp [name]', DESC = 'Deletes a waypoint'}
CMDs[#CMDs + 1] = {NAME = 'clearwaypoints / cwp', DESC = 'Clears all waypoints'}
CMDs[#CMDs + 1] = {NAME = 'cleargamewaypoints / cgamewp', DESC = 'Clears all waypoints for the game you are in'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'goto [player] [request stream]', DESC = 'Go to a player'}
CMDs[#CMDs + 1] = {NAME = 'tweengoto / tgoto [player]', DESC = 'Tween to a player (bypasses some anti cheats)'}
CMDs[#CMDs + 1] = {NAME = 'tweenspeed / tspeed [num]', DESC = 'Sets how fast all tween commands go (default is 1)'}
CMDs[#CMDs + 1] = {NAME = 'vehiclegoto / vgoto [player]', DESC = 'Go to a player while in a vehicle'}
CMDs[#CMDs + 1] = {NAME = 'loopgoto [player] [distance] [delay]', DESC = 'Loop teleport to a player'}
CMDs[#CMDs + 1] = {NAME = 'unloopgoto', DESC = 'Stops teleporting you to a player'}
CMDs[#CMDs + 1] = {NAME = 'pulsetp / ptp [player] [seconds]', DESC = 'Teleports you to a player for a specified amount of time'}
CMDs[#CMDs + 1] = {NAME = 'clientbring / cbring [player] (CLIENT)', DESC = 'Bring a player'}
CMDs[#CMDs + 1] = {NAME = 'loopbring [player] [distance] [delay] (CLIENT)', DESC = 'Loop brings a player to you (useful for killing)'}
CMDs[#CMDs + 1] = {NAME = 'unloopbring [player]', DESC = 'Undoes loopbring'}
CMDs[#CMDs + 1] = {NAME = 'freeze / fr [player] (CLIENT)', DESC = 'Freezes a player'}
CMDs[#CMDs + 1] = {NAME = 'freezeanims', DESC = 'Freezes your animations / pauses your animations - Does not work on default animations'}
CMDs[#CMDs + 1] = {NAME = 'unfreezeanims', DESC = 'Unfreezes your animations / plays your animations'}
CMDs[#CMDs + 1] = {NAME = 'thaw / unfr [player] (CLIENT)', DESC = 'Unfreezes a player'}
CMDs[#CMDs + 1] = {NAME = 'anchor', DESC = 'Anchors your characters RootPart'}
CMDs[#CMDs + 1] = {NAME = 'unanchor', DESC = 'Unanchors your characters RootPart'}
CMDs[#CMDs + 1] = {NAME = 'tpposition / tppos [X Y Z]', DESC = 'Teleports you to certain coordinates'}
CMDs[#CMDs + 1] = {NAME = 'tweentpposition / ttppos [X Y Z]', DESC = 'Tween to coordinates (bypasses some anti cheats)'}
CMDs[#CMDs + 1] = {NAME = 'offset [X Y Z]', DESC = 'Offsets you by certain coordinates'}
CMDs[#CMDs + 1] = {NAME = 'tweenoffset / toffset [X Y Z]', DESC = 'Tween offset (bypasses some anti cheats)'}
CMDs[#CMDs + 1] = {NAME = 'thru [num]', DESC = 'Teleports you [num] studs ahead of where your character is facing'}
CMDs[#CMDs + 1] = {NAME = 'notifyposition / notifypos [player]', DESC = 'Notifies you the coordinates of a character'}
CMDs[#CMDs + 1] = {NAME = 'copyposition / copypos [player]', DESC = 'Copies the coordinates of a character to your clipboard'}
CMDs[#CMDs + 1] = {NAME = 'walktoposition / walktopos [X Y Z]', DESC = 'Makes you walk to a coordinate'}
CMDs[#CMDs + 1] = {NAME = 'spawnpoint / spawn [delay]', DESC = 'Sets a position where you will spawn'}
CMDs[#CMDs + 1] = {NAME = 'nospawnpoint / nospawn', DESC = 'Removes your custom spawn point'}
CMDs[#CMDs + 1] = {NAME = 'flashback / diedtp', DESC = 'Teleports you to where you last died'}
CMDs[#CMDs + 1] = {NAME = 'walltp', DESC = 'Teleports you above/over any wall you run into'}
CMDs[#CMDs + 1] = {NAME = 'nowalltp / unwalltp', DESC = 'Disables walltp'}
CMDs[#CMDs + 1] = {NAME = 'teleporttool / tptool', DESC = 'Gives you a teleport tool'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'logs', DESC = 'Opens the logs GUI'}
CMDs[#CMDs + 1] = {NAME = 'chatlogs / clogs', DESC = 'Log what people say or whisper'}
CMDs[#CMDs + 1] = {NAME = 'joinlogs / jlogs', DESC = 'Log when people join'}
CMDs[#CMDs + 1] = {NAME = 'chatlogswebhook / logswebhook [url]', DESC = 'Set a discord webhook for chatlogs to go to (provide no url to disable this)'}
CMDs[#CMDs + 1] = {NAME = 'chat / say [text]', DESC = 'Makes you chat a string (possible mute bypass)'}
CMDs[#CMDs + 1] = {NAME = 'spam [text]', DESC = 'Makes you spam the chat'}
CMDs[#CMDs + 1] = {NAME = 'unspam', DESC = 'Turns off spam'}
CMDs[#CMDs + 1] = {NAME = 'whisper / pm [player] [text]', DESC = 'Makes you whisper a string to someone (possible mute bypass)'}
CMDs[#CMDs + 1] = {NAME = 'pmspam [player] [text]', DESC = 'Makes you spam a players whispers'}
CMDs[#CMDs + 1] = {NAME = 'unpmspam [player]', DESC = 'Turns off pm spam'}
CMDs[#CMDs + 1] = {NAME = 'spamspeed [num]', DESC = 'How quickly you spam (default is 1)'}
CMDs[#CMDs + 1] = {NAME = 'bubblechat (CLIENT)', DESC = 'Enables bubble chat for your client'}
CMDs[#CMDs + 1] = {NAME = 'unbubblechat / nobubblechat', DESC = 'Disables the bubblechat command'}
CMDs[#CMDs + 1] = {NAME = 'chatwindow', DESC = 'Enables the chat window for your client'}
CMDs[#CMDs + 1] = {NAME = 'unchatwindow / nochatwindow', DESC = 'Disables the chat window for your client'}
CMDs[#CMDs + 1] = {NAME = 'darkchat', DESC = 'Makes the chat window dark for your client'}
CMDs[#CMDs + 1] = {NAME = 'listento [player]', DESC = 'Listens to the area around a player. Can also eavesdrop with vc'}
CMDs[#CMDs + 1] = {NAME = 'unlistento', DESC = 'Disables listento'}
CMDs[#CMDs + 1] = {NAME = 'muteallvoices / muteallvcs', DESC = 'Mutes voice chat for all players'}
CMDs[#CMDs + 1] = {NAME = 'unmuteallvoices / unmuteallvcs', DESC = 'Unmutes voice chat for all players'}
CMDs[#CMDs + 1] = {NAME = 'mutevc [player]', DESC = 'Mutes the voice chat of a player'}
CMDs[#CMDs + 1] = {NAME = 'unmutevc [player]', DESC = 'Unmutes the voice chat of a player'}
CMDs[#CMDs + 1] = {NAME = 'phonebook / call', DESC = 'Prompts the Roblox phonebook UI to let you call your friends. Needs voice chat enabled'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'esp', DESC = 'View all players and their status'}
CMDs[#CMDs + 1] = {NAME = 'espteam', DESC = 'ESP but teammates are green and bad guys are red'}
CMDs[#CMDs + 1] = {NAME = 'noesp / unesp / unespteam', DESC = 'Removes ESP'}
CMDs[#CMDs + 1] = {NAME = 'esptransparency [number]', DESC = 'Changes the transparency of ESP related commands'}
CMDs[#CMDs + 1] = {NAME = 'partesp [part name]', DESC = 'Highlights a part'}
CMDs[#CMDs + 1] = {NAME = 'unpartesp / nopartesp [part name]', DESC = 'removes partesp'}
CMDs[#CMDs + 1] = {NAME = 'chams', DESC = 'ESP but without text in the way'}
CMDs[#CMDs + 1] = {NAME = 'nochams / unchams', DESC = 'Removes chams'}
CMDs[#CMDs + 1] = {NAME = 'locate [player]', DESC = 'View a single player and their status'}
CMDs[#CMDs + 1] = {NAME = 'unlocate / nolocate [player]', DESC = 'Removes locate'}
CMDs[#CMDs + 1] = {NAME = 'xray', DESC = 'Makes all parts in workspace transparent'}
CMDs[#CMDs + 1] = {NAME = 'unxray / noxray', DESC = 'Restores transparency to all parts in workspace'}
CMDs[#CMDs + 1] = {NAME = 'loopxray', DESC = 'Makes all parts in workspace transparent but looped'}
CMDs[#CMDs + 1] = {NAME = 'unloopxray', DESC = 'Unloops xray'}
CMDs[#CMDs + 1] = {NAME = 'togglexray', DESC = 'Toggles xray'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'spectate / view [player]', DESC = 'View a player'}
CMDs[#CMDs + 1] = {NAME = 'viewpart / viewp [part name]', DESC = 'View a part'}
CMDs[#CMDs + 1] = {NAME = 'unspectate / unview', DESC = 'Stops viewing player'}
CMDs[#CMDs + 1] = {NAME = 'freecam / fc', DESC = 'Allows you to freely move camera around the game'}
CMDs[#CMDs + 1] = {NAME = 'freecampos / fcpos [X Y Z]', DESC = 'Moves / opens freecam in a certain position'}
CMDs[#CMDs + 1] = {NAME = 'freecamwaypoint / fcwp [name]', DESC = 'Moves / opens freecam to a waypoint'}
CMDs[#CMDs + 1] = {NAME = 'freecamgoto / fcgoto / fctp [player]', DESC = 'Moves / opens freecam to a player'}
CMDs[#CMDs + 1] = {NAME = 'unfreecam / unfc', DESC = 'Disables freecam'}
CMDs[#CMDs + 1] = {NAME = 'freecamspeed / fcspeed [num]', DESC = 'Adjusts freecam speed (default is 1)'}
CMDs[#CMDs + 1] = {NAME = 'notifyfreecamposition / notifyfcpos', DESC = 'Noitifies you your freecam coordinates'}
CMDs[#CMDs + 1] = {NAME = 'copyfreecamposition / copyfcpos', DESC = 'Copies your freecam coordinates to your clipboard'}
CMDs[#CMDs + 1] = {NAME = 'gotocamera / gotocam', DESC = 'Teleports you to the location of your camera'}
CMDs[#CMDs + 1] = {NAME = 'tweengotocam / tgotocam', DESC = 'Tweens you to the location of your camera'}
CMDs[#CMDs + 1] = {NAME = 'firstp', DESC = 'Forces camera to go into first person'}
CMDs[#CMDs + 1] = {NAME = 'thirdp', DESC = 'Allows camera to go into third person'}
CMDs[#CMDs + 1] = {NAME = 'noclipcam / nccam', DESC = 'Allows camera to go through objects like walls'}
CMDs[#CMDs + 1] = {NAME = 'maxzoom [num]', DESC = 'Maximum camera zoom'}
CMDs[#CMDs + 1] = {NAME = 'minzoom [num]', DESC = 'Minimum camera zoom'}
CMDs[#CMDs + 1] = {NAME = 'camdistance [num]', DESC = 'Changes camera distance from your player'}
CMDs[#CMDs + 1] = {NAME = 'fov [num]', DESC = 'Adjusts field of view (default is 70)'}
CMDs[#CMDs + 1] = {NAME = 'fixcam / restorecam', DESC = 'Fixes camera'}
CMDs[#CMDs + 1] = {NAME = 'enableshiftlock / enablesl', DESC = 'Enables the shift lock option'}
CMDs[#CMDs + 1] = {NAME = 'lookat [player]', DESC = 'Moves your camera view to a player'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'btools (CLIENT)', DESC = 'Gives you building tools (DOES NOT REPLICATE)'}
CMDs[#CMDs + 1] = {NAME = 'f3x (CLIENT)', DESC = 'Gives you F3X building tools (DOES NOT REPLICATE)'}
CMDs[#CMDs + 1] = {NAME = 'partname / partpath', DESC = 'Allows you to click a part to see its path & name'}
CMDs[#CMDs + 1] = {NAME = 'delete [instance name] (CLIENT)', DESC = 'Removes any part with a certain name from the workspace (DOES NOT REPLICATE)'}
CMDs[#CMDs + 1] = {NAME = 'deleteclass / dc [class name] (CLIENT)', DESC = 'Removes any part with a certain classname from the workspace (DOES NOT REPLICATE)'}
CMDs[#CMDs + 1] = {NAME = 'lockworkspace / lockws', DESC = 'Locks the whole workspace'}
CMDs[#CMDs + 1] = {NAME = 'unlockworkspace / unlockws', DESC = 'Unlocks the whole workspace'}
CMDs[#CMDs + 1] = {NAME = 'invisibleparts / invisparts (CLIENT)', DESC = 'Shows invisible parts'}
CMDs[#CMDs + 1] = {NAME = 'uninvisibleparts / uninvisparts (CLIENT)', DESC = 'Makes parts affected by invisparts return to normal'}
CMDs[#CMDs + 1] = {NAME = 'deleteinvisparts / dip (CLIENT)', DESC = 'Deletes invisible parts'}
CMDs[#CMDs + 1] = {NAME = 'gotopart [part name]', DESC = 'Moves your character to a part or multiple parts'}
CMDs[#CMDs + 1] = {NAME = 'tweengotopart / tgotopart [part name]', DESC = 'Tweens your character to a part or multiple parts'}
CMDs[#CMDs + 1] = {NAME = 'gotopartclass / gpc [class name]', DESC = 'Moves your character to a part or multiple parts based on classname'}
CMDs[#CMDs + 1] = {NAME = 'tweengotopartclass / tgpc [class name]', DESC = 'Tweens your character to a part or multiple parts based on classname'}
CMDs[#CMDs + 1] = {NAME = 'gotomodel [part name]', DESC = 'Moves your character to a model or multiple models'}
CMDs[#CMDs + 1] = {NAME = 'tweengotomodel / tgotomodel [part name]', DESC = 'Tweens your character to a model or multiple models'}
CMDs[#CMDs + 1] = {NAME = 'gotopartdelay / gotomodeldelay [num]', DESC = 'Adjusts how quickly you teleport to each part (default is 0.1)'}
CMDs[#CMDs + 1] = {NAME = 'bringpart [part name] (CLIENT)', DESC = 'Moves a part or multiple parts to your character'}
CMDs[#CMDs + 1] = {NAME = 'bringpartclass / bpc [class name] (CLIENT)', DESC = 'Moves a part or multiple parts to your character based on classname'}
CMDs[#CMDs + 1] = {NAME = 'noclickdetectorlimits / nocdlimits', DESC = 'Sets all click detectors MaxActivationDistance to math.huge'}
CMDs[#CMDs + 1] = {NAME = 'fireclickdetectors / firecd [name]', DESC = 'Uses all click detectors in a game or uses the optional name'}
CMDs[#CMDs + 1] = {NAME = 'firetouchinterests / touchinterests [name]', DESC = 'Uses all touchinterests in a game or uses the optional name'}
CMDs[#CMDs + 1] = {NAME = 'noproximitypromptlimits / nopplimits', DESC = 'Sets all proximity prompts MaxActivationDistance to math.huge'}
CMDs[#CMDs + 1] = {NAME = 'fireproximityprompts / firepp [name]', DESC = 'Uses all proximity prompts in a game or uses the optional name'}
CMDs[#CMDs + 1] = {NAME = 'instantproximityprompts / instantpp', DESC = 'Disable the cooldown for proximity prompts'}
CMDs[#CMDs + 1] = {NAME = 'uninstantproximityprompts / uninstantpp', DESC = 'Undo the cooldown removal'}
CMDs[#CMDs + 1] = {NAME = 'tpunanchored / tpua [player]', DESC = 'Teleports unanchored parts to a player'}
CMDs[#CMDs + 1] = {NAME = 'animsunanchored / freezeua', DESC = 'Freezes unanchored parts'}
CMDs[#CMDs + 1] = {NAME = 'thawunanchored / thawua / unfreezeua', DESC = 'Thaws unanchored parts'}
CMDs[#CMDs + 1] = {NAME = 'removeterrain / rterrain / noterrain', DESC = 'Removes all terrain'}
CMDs[#CMDs + 1] = {NAME = 'clearnilinstances / nonilinstances / cni', DESC = 'Removes nil instances'}
CMDs[#CMDs + 1] = {NAME = 'destroyheight / dh [num]', DESC = 'Sets FallenPartsDestroyHeight'}
CMDs[#CMDs + 1] = {NAME = 'fakeout', DESC = 'Tp to the void and then back (useful to kill people attached to you)'}
CMDs[#CMDs + 1] = {NAME = 'antivoid', DESC = 'Prevents you from falling into the void by launching you upwards'}
CMDs[#CMDs + 1] = {NAME = 'unantivoid / noantivoid', DESC = 'Disables antivoid'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'fullbright / fb (CLIENT)', DESC = 'Makes the map brighter / more visible'}
CMDs[#CMDs + 1] = {NAME = 'loopfullbright / loopfb (CLIENT)', DESC = 'Makes the map brighter / more visible but looped'}
CMDs[#CMDs + 1] = {NAME = 'unloopfullbright / unloopfb', DESC = 'Unloops fullbright'}
CMDs[#CMDs + 1] = {NAME = 'ambient [num] [num] [num] (CLIENT)', DESC = 'Changes ambient'}
CMDs[#CMDs + 1] = {NAME = 'day (CLIENT)', DESC = 'Changes the time to day for the client'}
CMDs[#CMDs + 1] = {NAME = 'night (CLIENT)', DESC = 'Changes the time to night for the client'}
CMDs[#CMDs + 1] = {NAME = 'nofog (CLIENT)', DESC = 'Removes fog'}
CMDs[#CMDs + 1] = {NAME = 'brightness [num] (CLIENT)', DESC = 'Changes the brightness lighting property'}
CMDs[#CMDs + 1] = {NAME = 'globalshadows / gshadows (CLIENT)', DESC = 'Enables global shadows'}
CMDs[#CMDs + 1] = {NAME = 'noglobalshadows / nogshadows (CLIENT)', DESC = 'Disables global shadows'}
CMDs[#CMDs + 1] = {NAME = 'restorelighting / rlighting', DESC = 'Restores Lighting properties'}
CMDs[#CMDs + 1] = {NAME = 'light [radius] [brightness] (CLIENT)', DESC = 'Gives your player dynamic light'}
CMDs[#CMDs + 1] = {NAME = 'nolight / unlight', DESC = 'Removes dynamic light from your player'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'inspect / examine [player]', DESC = 'Opens InspectMenu for a certain player'}
CMDs[#CMDs + 1] = {NAME = 'age [player]', DESC = 'Tells you the age of a player'}
CMDs[#CMDs + 1] = {NAME = 'chatage [player]', DESC = 'Chats the age of a player'}
CMDs[#CMDs + 1] = {NAME = 'joindate / jd [player]', DESC = 'Tells you the date the player joined Roblox'}
CMDs[#CMDs + 1] = {NAME = 'chatjoindate / cjd [player]', DESC = 'Chats the date the player joined Roblox'}
CMDs[#CMDs + 1] = {NAME = 'copyname / copyuser [player]', DESC = 'Copies a players full username to your clipboard'}
CMDs[#CMDs + 1] = {NAME = 'userid / id [player]', DESC = 'Notifies a players user ID'}
CMDs[#CMDs + 1] = {NAME = 'copyplaceid / placeid', DESC = 'Copies the current place id to your clipboard'}
CMDs[#CMDs + 1] = {NAME = 'copygameid / gameid', DESC = 'Copies the current game id to your clipboard'}
CMDs[#CMDs + 1] = {NAME = 'copyuserid / copyid [player]', DESC = 'Copies a players user ID to your clipboard'}
CMDs[#CMDs + 1] = {NAME = 'appearanceid / aid [player]', DESC = 'Notifies a players appearance ID'}
CMDs[#CMDs + 1] = {NAME = 'copyappearanceid / caid [player]', DESC = 'Copies a players appearance ID to your clipboard'}
CMDs[#CMDs + 1] = {NAME = 'bang [player] [speed]', DESC = 'owo'}
CMDs[#CMDs + 1] = {NAME = 'unbang', DESC = 'uwu'}
CMDs[#CMDs + 1] = {NAME = 'jerk', DESC = 'Makes you jork it'}
CMDs[#CMDs + 1] = {NAME = 'scare / spook [player]', DESC = 'Teleports in front of a player for half a second'}
CMDs[#CMDs + 1] = {NAME = 'carpet [player]', DESC = 'Be someones carpet'}
CMDs[#CMDs + 1] = {NAME = 'uncarpet', DESC = 'Undoes carpet'}
CMDs[#CMDs + 1] = {NAME = 'friend [player]', DESC = 'Sends a friend request to certain players'}
CMDs[#CMDs + 1] = {NAME = 'unfriend [player]', DESC = 'Unfriends certain players'}
CMDs[#CMDs + 1] = {NAME = 'headsit [player]', DESC = 'Sit on a players head'}
CMDs[#CMDs + 1] = {NAME = 'walkto / follow [player]', DESC = 'Follow a player'}
CMDs[#CMDs + 1] = {NAME = 'pathfindwalkto / pathfindfollow [player]', DESC = 'Follow a player using pathfinding'}
CMDs[#CMDs + 1] = {NAME = 'pathfindwalktowaypoint / pathfindwalktowp [waypoint]', DESC = 'Walk to a waypoint using pathfinding'}
CMDs[#CMDs + 1] = {NAME = 'unwalkto / unfollow', DESC = 'Stops following a player'}
CMDs[#CMDs + 1] = {NAME = 'orbit [player] [speed] [distance]', DESC = 'Makes your character orbit around a player with an optional speed and an optional distance'}
CMDs[#CMDs + 1] = {NAME = 'unorbit', DESC = 'Disables orbit'}
CMDs[#CMDs + 1] = {NAME = 'stareat / stare [player]', DESC = 'Stare / look at a player'}
CMDs[#CMDs + 1] = {NAME = 'unstareat / unstare [player]', DESC = 'Disables stareat'}
CMDs[#CMDs + 1] = {NAME = 'rolewatch [group id] [role name]', DESC = 'Notify if someone from a watched group joins the server'}
CMDs[#CMDs + 1] = {NAME = 'rolewatchstop / unrolewatch', DESC = 'Disable Rolewatch'}
CMDs[#CMDs + 1] = {NAME = 'rolewatchleave', DESC = 'Toggle if you should leave the game if someone from a watched group joins the server'}
CMDs[#CMDs + 1] = {NAME = 'staffwatch', DESC = 'Notify if a staff member of the game joins the server'}
CMDs[#CMDs + 1] = {NAME = 'unstaffwatch', DESC = 'Disable Staffwatch'}
CMDs[#CMDs + 1] = {NAME = 'findfriendgroups', DESC = 'Notifies you if any players are friends with each other'}
CMDs[#CMDs + 1] = {NAME = 'handlekill / hkill [player] [radius] (TOOL)', DESC = 'Kills a player using tool damage (YOU NEED A TOOL)'}
CMDs[#CMDs + 1] = {NAME = 'fling', DESC = 'Flings anyone you touch'}
CMDs[#CMDs + 1] = {NAME = 'unfling', DESC = 'Disables the fling command'}
CMDs[#CMDs + 1] = {NAME = 'flyfling [speed]', DESC = 'Basically the invisfling command but not invisible'}
CMDs[#CMDs + 1] = {NAME = 'unflyfling', DESC = 'Disables the flyfling command'}
CMDs[#CMDs + 1] = {NAME = 'walkfling', DESC = 'Basically fling but no spinning'}
CMDs[#CMDs + 1] = {NAME = 'unwalkfling / nowalkfling', DESC = 'Disables walkfling'}
CMDs[#CMDs + 1] = {NAME = 'invisfling', DESC = 'Enables invisible fling (the invis part is patched, try using the god command before using this)'}
CMDs[#CMDs + 1] = {NAME = 'antifling', DESC = 'Disables player collisions to prevent you from being flung'}
CMDs[#CMDs + 1] = {NAME = 'unantifling', DESC = 'Disables antifling'}
CMDs[#CMDs + 1] = {NAME = 'loopoof', DESC = 'Loops everyones character sounds (everyone can hear)'}
CMDs[#CMDs + 1] = {NAME = 'unloopoof', DESC = 'Stops the oof chaos'}
CMDs[#CMDs + 1] = {NAME = 'muteboombox [player]', DESC = 'Mutes someones boombox'}
CMDs[#CMDs + 1] = {NAME = 'unmuteboombox [player]', DESC = 'Unmutes someones boombox'}
CMDs[#CMDs + 1] = {NAME = 'hitboxes', DESC = 'Shows all rendered bounding boxes'}
CMDs[#CMDs + 1] = {NAME = 'unhitboxes', DESC = 'Stops showing all rendered bounding boxes'}
CMDs[#CMDs + 1] = {NAME = 'hitbox [player] [size] [transparency]', DESC = 'Expands the hitbox for players HumanoidRootPart (default is 1)'}
CMDs[#CMDs + 1] = {NAME = 'headsize [player] [size]', DESC = 'Expands the head size for players Head (default is 1)'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'reset', DESC = 'Resets your character normally'}
CMDs[#CMDs + 1] = {NAME = 'respawn', DESC = 'Respawns you'}
CMDs[#CMDs + 1] = {NAME = 'refresh / re', DESC = 'Respawns and brings you back to the same position'}
CMDs[#CMDs + 1] = {NAME = 'god', DESC = 'Makes your character difficult to kill in most games'}
CMDs[#CMDs + 1] = {NAME = 'invisible / invis', DESC = 'Makes you invisible to other players'}
CMDs[#CMDs + 1] = {NAME = 'visible / vis', DESC = 'Makes you visible to other players'}
CMDs[#CMDs + 1] = {NAME = 'toolinvisible / toolinvis / tinvis', DESC = 'Makes you invisible to other players and able to use tools'}
CMDs[#CMDs + 1] = {NAME = 'speed / ws / walkspeed [num]', DESC = 'Change your walkspeed (default is 16)'}
CMDs[#CMDs + 1] = {NAME = 'spoofspeed / spoofws [num]', DESC = 'Spoofs your WalkSpeed on the Client'}
CMDs[#CMDs + 1] = {NAME = 'loopspeed / loopws [num]', DESC = 'Loops your walkspeed'}
CMDs[#CMDs + 1] = {NAME = 'unloopspeed / unloopws', DESC = 'Turns off loopspeed'}
CMDs[#CMDs + 1] = {NAME = 'hipheight / hheight [num]', DESC = 'Adjusts hip height'}
CMDs[#CMDs + 1] = {NAME = 'jumppower / jpower / jp [num]', DESC = 'Change a players jump height (default is 50)'}
CMDs[#CMDs + 1] = {NAME = 'spoofjumppower / spoofjp [num]', DESC = 'Spoofs your JumpPower on the Client'}
CMDs[#CMDs + 1] = {NAME = 'loopjumppower / loopjp [num]', DESC = 'Loops your jump height'}
CMDs[#CMDs + 1] = {NAME = 'unloopjumppower / unloopjp', DESC = 'Turns off loopjumppower'}
CMDs[#CMDs + 1] = {NAME = 'maxslopeangle / msa [num]', DESC = 'Adjusts MaxSlopeAngle'}
CMDs[#CMDs + 1] = {NAME = 'gravity / grav [num] (CLIENT)', DESC = 'Change your gravity'}
CMDs[#CMDs + 1] = {NAME = 'sit', DESC = 'Makes your character sit'}
CMDs[#CMDs + 1] = {NAME = 'lay / laydown', DESC = 'Makes your character lay down'}
CMDs[#CMDs + 1] = {NAME = 'sitwalk', DESC = 'Makes your character sit while still being able to walk'}
CMDs[#CMDs + 1] = {NAME = 'nosit', DESC = 'Prevents your character from sitting'}
CMDs[#CMDs + 1] = {NAME = 'unnosit', DESC = 'Disables nosit'}
CMDs[#CMDs + 1] = {NAME = 'jump', DESC = 'Makes your character jump'}
CMDs[#CMDs + 1] = {NAME = 'infinitejump / infjump', DESC = 'Allows you to jump before hitting the ground'}
CMDs[#CMDs + 1] = {NAME = 'uninfinitejump / uninfjump', DESC = 'Disables infjump'}
CMDs[#CMDs + 1] = {NAME = 'flyjump', DESC = 'Allows you to hold space to fly up'}
CMDs[#CMDs + 1] = {NAME = 'unflyjump', DESC = 'Disables flyjump'}
CMDs[#CMDs + 1] = {NAME = 'autojump / ajump', DESC = 'Automatically jumps when you run into an object'}
CMDs[#CMDs + 1] = {NAME = 'unautojump / unajump', DESC = 'Disables autojump'}
CMDs[#CMDs + 1] = {NAME = 'edgejump / ejump', DESC = 'Automatically jumps when you get to the edge of an object'}
CMDs[#CMDs + 1] = {NAME = 'unedgejump / unejump', DESC = 'Disables edgejump'}
CMDs[#CMDs + 1] = {NAME = 'platformstand / stun', DESC = 'Enables PlatformStand'}
CMDs[#CMDs + 1] = {NAME = 'unplatformstand / unstun', DESC = 'Disables PlatformStand'}
CMDs[#CMDs + 1] = {NAME = 'norotate / noautorotate', DESC = 'Disables AutoRotate'}
CMDs[#CMDs + 1] = {NAME = 'unnorotate / autorotate', DESC = 'Enables AutoRotate'}
CMDs[#CMDs + 1] = {NAME = 'enablestate [StateType]', DESC = 'Enables a humanoid state type'}
CMDs[#CMDs + 1] = {NAME = 'disablestate [StateType]', DESC = 'Disables a humanoid state type'}
CMDs[#CMDs + 1] = {NAME = 'team [team name] (CLIENT)', DESC = 'Changes your team. Sometimes fools localscripts.'}
CMDs[#CMDs + 1] = {NAME = 'nobillboardgui / nobgui / noname', DESC = 'Removes billboard and surface GUIs from your players (i.e. name GUIs at cafes)'}
CMDs[#CMDs + 1] = {NAME = 'loopnobgui / loopnoname', DESC = 'Loop removes billboard and surface GUIs from your players (i.e. name GUIs at cafes)'}
CMDs[#CMDs + 1] = {NAME = 'unloopnobgui / unloopnoname', DESC = 'Disables loopnobgui'}
CMDs[#CMDs + 1] = {NAME = 'noarms', DESC = 'Removes your arms'}
CMDs[#CMDs + 1] = {NAME = 'nolegs', DESC = 'Removes your legs'}
CMDs[#CMDs + 1] = {NAME = 'nolimbs', DESC = 'Removes your limbs'}
CMDs[#CMDs + 1] = {NAME = 'naked (CLIENT)', DESC = 'Removes your clothing'}
CMDs[#CMDs + 1] = {NAME = 'noface / removeface', DESC = 'Removes your face'}
CMDs[#CMDs + 1] = {NAME = 'blockhead', DESC = 'Turns your head into a block'}
CMDs[#CMDs + 1] = {NAME = 'blockhats', DESC = 'Turns your hats into blocks'}
CMDs[#CMDs + 1] = {NAME = 'blocktool', DESC = 'Turns the currently selected tool into a block'}
CMDs[#CMDs + 1] = {NAME = 'creeper', DESC = 'Makes you look like a creeper'}
CMDs[#CMDs + 1] = {NAME = 'drophats', DESC = 'Drops your hats'}
CMDs[#CMDs + 1] = {NAME = 'nohats / deletehats / rhats', DESC = 'Deletes your hats'}
CMDs[#CMDs + 1] = {NAME = 'hatspin / spinhats', DESC = 'Spins your characters accessories'}
CMDs[#CMDs + 1] = {NAME = 'unhatspin / unspinhats', DESC = 'Undoes spinhats'}
CMDs[#CMDs + 1] = {NAME = 'clearhats / cleanhats', DESC = 'Clears hats in the workspace'}
CMDs[#CMDs + 1] = {NAME = 'chardelete / cd [instance name]', DESC = 'Removes any part with a certain name from your character'}
CMDs[#CMDs + 1] = {NAME = 'chardeleteclass / cdc [class name]', DESC = 'Removes any part with a certain classname from your character'}
CMDs[#CMDs + 1] = {NAME = 'deletevelocity / dv / removeforces', DESC = 'Removes any velocity / force instances in your character'}
CMDs[#CMDs + 1] = {NAME = 'weaken [num]', DESC = 'Makes your character less dense'}
CMDs[#CMDs + 1] = {NAME = 'unweaken', DESC = 'Sets your characters CustomPhysicalProperties to default'}
CMDs[#CMDs + 1] = {NAME = 'strengthen [num]', DESC = 'Makes your character more dense (CustomPhysicalProperties)'}
CMDs[#CMDs + 1] = {NAME = 'unstrengthen', DESC = 'Sets your characters CustomPhysicalProperties to default'}
CMDs[#CMDs + 1] = {NAME = 'breakvelocity', DESC = 'Sets your characters velocity to 0'}
CMDs[#CMDs + 1] = {NAME = 'spin [speed]', DESC = 'Spins your character'}
CMDs[#CMDs + 1] = {NAME = 'unspin', DESC = 'Disables spin'}
CMDs[#CMDs + 1] = {NAME = 'split', DESC = 'Splits your character in half'}
CMDs[#CMDs + 1] = {NAME = 'nilchar', DESC = 'Sets your characters parent to nil'}
CMDs[#CMDs + 1] = {NAME = 'unnilchar / nonilchar', DESC = 'Sets your characters parent to workspace'}
CMDs[#CMDs + 1] = {NAME = 'noroot / removeroot / rroot', DESC = 'Removes your characters HumanoidRootPart'}
CMDs[#CMDs + 1] = {NAME = 'replaceroot', DESC = 'Replaces your characters HumanoidRootPart'}
CMDs[#CMDs + 1] = {NAME = 'clearcharappearance / clearchar / clrchar', DESC = 'Removes all accessory, shirt, pants, charactermesh, and bodycolors'}
CMDs[#CMDs + 1] = {NAME = 'tpwalk / teleportwalk [num]', DESC = 'Teleports you to your move direction'}
CMDs[#CMDs + 1] = {NAME = 'untpwalk / unteleportwalk', DESC = 'Undoes tpwalk / teleportwalk'}
CMDs[#CMDs + 1] = {NAME = 'trip', DESC = 'Makes your character fall over'}
CMDs[#CMDs + 1] = {NAME = 'wallwalk / walkonwalls', DESC = 'Walk on walls'}
CMDs[#CMDs + 1] = {NAME = 'promptr6', DESC = 'Prompts the game to switch your rig type to R6'}
CMDs[#CMDs + 1] = {NAME = 'promptr15', DESC = 'Prompts the game to switch your rig type to R15'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'animation / anim [ID] [speed]', DESC = 'Makes your character perform an animation (must be an animation on the marketplace or by roblox/stickmasterluke to replicate)'}
CMDs[#CMDs + 1] = {NAME = 'emote / em [ID] [speed]', DESC = 'Makes your character perform an emote (must be on the marketplace or by roblox/stickmasterluke to replicate)'}
CMDs[#CMDs + 1] = {NAME = 'dance', DESC = 'Makes you  d a n c e'}
CMDs[#CMDs + 1] = {NAME = 'undance', DESC = 'Stops dance animations'}
CMDs[#CMDs + 1] = {NAME = 'spasm', DESC = 'Makes you  c r a z y'}
CMDs[#CMDs + 1] = {NAME = 'unspasm', DESC = 'Stops spasm'}
CMDs[#CMDs + 1] = {NAME = 'headthrow', DESC = 'Simply makes you throw your head'}
CMDs[#CMDs + 1] = {NAME = 'noanim', DESC = 'Disables your animations'}
CMDs[#CMDs + 1] = {NAME = 'reanim', DESC = 'Restores your animations'}
CMDs[#CMDs + 1] = {NAME = 'animspeed [num]', DESC = 'Changes the speed of your current animation'}
CMDs[#CMDs + 1] = {NAME = 'copyanimation / copyanim / copyemote [player]', DESC = 'Copies someone elses animation'}
CMDs[#CMDs + 1] = {NAME = 'copyanimationid / copyanimid / copyemoteid [player]', DESC = 'Copies your animation id or someone elses to your clipboard'}
CMDs[#CMDs + 1] = {NAME = 'loopanimation / loopanim', DESC = 'Loops your current animation'}
CMDs[#CMDs + 1] = {NAME = 'stopanimations / stopanims', DESC = 'Stops running animations'}
CMDs[#CMDs + 1] = {NAME = 'refreshanimations / refreshanims', DESC = 'Refreshes animations'}
CMDs[#CMDs + 1] = {NAME = 'allowcustomanim / allowcustomanimations', DESC = 'Lets you use custom animation packs instead'}
CMDs[#CMDs + 1] = {NAME = 'unallowcustomanim / unallowcustomanimations', DESC = 'Doesn\'t let you use custom animation packs instead'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'autoclick [click delay] [release delay]', DESC = 'Automatically clicks your mouse with a set delay'}
CMDs[#CMDs + 1] = {NAME = 'unautoclick / noautoclick', DESC = 'Turns off autoclick'}
CMDs[#CMDs + 1] = {NAME = 'autokeypress [key] [down delay] [up delay]', DESC = 'Automatically presses a key with a set delay'}
CMDs[#CMDs + 1] = {NAME = 'unautokeypress', DESC = 'Stops autokeypress'}
CMDs[#CMDs + 1] = {NAME = 'hovername', DESC = 'Shows a players username when your mouse is hovered over them'}
CMDs[#CMDs + 1] = {NAME = 'unhovername / nohovername', DESC = 'Turns off hovername'}
CMDs[#CMDs + 1] = {NAME = 'mousesensitivity / ms [0-10]', DESC = 'Sets your mouse sensitivity (affects first person and right click drag) (default is 1)'}
CMDs[#CMDs + 1] = {NAME = 'clickdelete', DESC = 'Go to Settings > Keybinds > Add for click delete'}
CMDs[#CMDs + 1] = {NAME = 'clickteleport', DESC = 'Go to Settings > Keybinds > Add for click teleport'}
CMDs[#CMDs + 1] = {NAME = 'mouseteleport / mousetp', DESC = 'Teleports your character to your mouse. This is recommended as a keybind'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'tools', DESC = 'Copies tools from ReplicatedStorage and Lighting'}
CMDs[#CMDs + 1] = {NAME = 'notools / removetools / deletetools', DESC = 'Removes tools from character and backpack'}
CMDs[#CMDs + 1] = {NAME = 'deleteselectedtool / dst', DESC = 'Removes any currently selected tools'}
CMDs[#CMDs + 1] = {NAME = 'grabtools', DESC = 'Automatically get tools that are dropped'}
CMDs[#CMDs + 1] = {NAME = 'ungrabtools / nograbtools', DESC = 'Disables grabtools'}
CMDs[#CMDs + 1] = {NAME = 'copytools [player] (CLIENT)', DESC = 'Copies a players tools'}
CMDs[#CMDs + 1] = {NAME = 'dupetools / clonetools [num]', DESC = 'Duplicates your inventory tools a set amount of times'}
CMDs[#CMDs + 1] = {NAME = 'droptools', DESC = 'Drops your tools'}
CMDs[#CMDs + 1] = {NAME = 'droppabletools', DESC = 'Makes your tools droppable'}
CMDs[#CMDs + 1] = {NAME = 'equiptools', DESC = 'Equips every tool in your inventory at once'}
CMDs[#CMDs + 1] = {NAME = 'unequiptools', DESC = 'Unequips every tool you are currently holding at once'}
CMDs[#CMDs + 1] = {NAME = 'removespecifictool [name]', DESC = 'Automatically remove a specific tool from your inventory'}
CMDs[#CMDs + 1] = {NAME = 'unremovespecifictool [name]', DESC = 'Stops removing a specific tool from your inventory'}
CMDs[#CMDs + 1] = {NAME = 'clearremovespecifictool', DESC = 'Stop removing all specific tools from your inventory'}
CMDs[#CMDs + 1] = {NAME = 'reach [num]', DESC = 'Increases the hitbox of your held tool'}
CMDs[#CMDs + 1] = {NAME = 'boxreach [num]', DESC = 'Increases the hitbox of your held tool in a box shape'}
CMDs[#CMDs + 1] = {NAME = 'unreach / noreach', DESC = 'Turns off reach'}
CMDs[#CMDs + 1] = {NAME = 'grippos [X Y Z]', DESC = 'Changes your current tools grip position'}
CMDs[#CMDs + 1] = {NAME = 'usetools [amount] [delay]', DESC = 'Activates all tools in your backpack at the same time'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'addalias [cmd] [alias]', DESC = 'Adds an alias to a command'}
CMDs[#CMDs + 1] = {NAME = 'removealias [alias]', DESC = 'Removes a custom alias'}
CMDs[#CMDs + 1] = {NAME = 'clraliases', DESC = 'Removes all custom aliases'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'addplugin / plugin [name]', DESC = 'Add a plugin via command'}
CMDs[#CMDs + 1] = {NAME = 'removeplugin / deleteplugin [name]', DESC = 'Remove a plugin via command'}
CMDs[#CMDs + 1] = {NAME = 'reloadplugin [name]', DESC = 'Reloads a plugin'}
CMDs[#CMDs + 1] = {NAME = 'addallplugins / loadallplugins', DESC = 'Adds all available plugins from the workspace folder'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'wacky / wackyhelp', DESC = 'Lists all the wacky commands'}
CMDs[#CMDs + 1] = {NAME = 'disco / discomode [speed]', DESC = 'Rainbow disco lighting party'}
CMDs[#CMDs + 1] = {NAME = 'undisco / nodisco', DESC = 'Stops the disco and restores lighting'}
CMDs[#CMDs + 1] = {NAME = 'rainbowchar / rainbowme [speed]', DESC = 'Makes your character cycle through rainbow colors'}
CMDs[#CMDs + 1] = {NAME = 'unrainbowchar / unrainbowme', DESC = 'Restores your character colors'}
CMDs[#CMDs + 1] = {NAME = 'ghost / spooky', DESC = 'Turns you into a flickering forcefield ghost'}
CMDs[#CMDs + 1] = {NAME = 'unghost / unspooky', DESC = 'Brings you back to life'}
CMDs[#CMDs + 1] = {NAME = 'drunk / dizzy [strength]', DESC = 'Wobbly blurry camera'}
CMDs[#CMDs + 1] = {NAME = 'undrunk / sober', DESC = 'Sobers up your camera'}
CMDs[#CMDs + 1] = {NAME = 'earthquake / camshake [intensity]', DESC = 'Shakes your camera like an earthquake'}
CMDs[#CMDs + 1] = {NAME = 'unearthquake / uncamshake', DESC = 'Stops the camera shake'}
CMDs[#CMDs + 1] = {NAME = 'camroll / upsidedown [degrees]', DESC = 'Rolls your camera (default 180 = upside down)'}
CMDs[#CMDs + 1] = {NAME = 'uncamroll / unupsidedown', DESC = 'Puts your camera right side up'}
CMDs[#CMDs + 1] = {NAME = 'vertigo / dollyzoom [seconds]', DESC = 'Trippy FOV zoom in and out'}
CMDs[#CMDs + 1] = {NAME = 'orbitcam / cinematic [speed] [distance]', DESC = 'Camera orbits around you like a movie shot'}
CMDs[#CMDs + 1] = {NAME = 'unorbitcam / uncinematic', DESC = 'Returns your camera to normal'}
CMDs[#CMDs + 1] = {NAME = 'filter [name/random]', DESC = 'Screen filter: noir, sepia, vaporwave, nightvision, deepfried, underwater, thermal, dream'}
CMDs[#CMDs + 1] = {NAME = 'unfilter', DESC = 'Removes the screen filter'}
CMDs[#CMDs + 1] = {NAME = 'weather [type/random]', DESC = 'Weather with sound, clouds and lighting: snow, blizzard (the whole map snows over!), rain, storm (gets dark, thunder), sandstorm, aurora, stars, galaxy, bloodmoon, sakura, autumn, hearts, embers, fireflies, rainbow, meteors'}
CMDs[#CMDs + 1] = {NAME = 'weathervolume [0-3]', DESC = 'Changes how loud the weather sounds are (default 1)'}
CMDs[#CMDs + 1] = {NAME = 'fuckoff / unloadny', DESC = 'Completely unloads NeverYield: turns everything off and removes the GUI'}
CMDs[#CMDs + 1] = {NAME = 'END / theend', DESC = 'A black hole (only you see it) swallows the map and you, then takes you to a new server'}
CMDs[#CMDs + 1] = {NAME = 'unweather / clearskies', DESC = 'Clears the weather'}
CMDs[#CMDs + 1] = {NAME = 'confetti [amount]', DESC = 'Explodes confetti around you'}
CMDs[#CMDs + 1] = {NAME = 'dancefloor / discofloor [size]', DESC = 'Spawns a flashing disco dance floor under you'}
CMDs[#CMDs + 1] = {NAME = 'undancefloor', DESC = 'Removes the dance floor'}
CMDs[#CMDs + 1] = {NAME = 'moongravity / moon [gravity]', DESC = 'Low gravity (default 30)'}
CMDs[#CMDs + 1] = {NAME = 'normalgravity / unmoon', DESC = 'Restores normal gravity'}
CMDs[#CMDs + 1] = {NAME = 'pogo / bunnyhop', DESC = 'Makes you bounce constantly'}
CMDs[#CMDs + 1] = {NAME = 'unpogo / unbunnyhop', DESC = 'Stops bouncing'}
CMDs[#CMDs + 1] = {NAME = 'moonwalk', DESC = 'Walk backwards like a smooth criminal'}
CMDs[#CMDs + 1] = {NAME = 'unmoonwalk', DESC = 'Walk forwards again'}
CMDs[#CMDs + 1] = {NAME = 'backflip [count]', DESC = 'Do a backflip (or several)'}
CMDs[#CMDs + 1] = {NAME = 'frontflip [count]', DESC = 'Do a frontflip (or several)'}
CMDs[#CMDs + 1] = {NAME = 'barrelroll / doabarrelroll [count]', DESC = 'Do a barrel roll!'}
CMDs[#CMDs + 1] = {NAME = 'rocket / launch / yeetme [power]', DESC = 'Launches you into the sky with fire'}
CMDs[#CMDs + 1] = {NAME = 'jetpack [thrust]', DESC = 'Hold jump to fly upwards with flames'}
CMDs[#CMDs + 1] = {NAME = 'unjetpack', DESC = 'Takes off the jetpack'}
CMDs[#CMDs + 1] = {NAME = 'helicopter / heli [speed]', DESC = 'Spin and hover like a helicopter, hold jump to climb'}
CMDs[#CMDs + 1] = {NAME = 'unhelicopter / land', DESC = 'Lands the helicopter'}
CMDs[#CMDs + 1] = {NAME = 'trail / rainbowtrail [lifetime]', DESC = 'Gives you a rainbow trail'}
CMDs[#CMDs + 1] = {NAME = 'untrail', DESC = 'Removes the trail'}
CMDs[#CMDs + 1] = {NAME = 'partyfx / glowup', DESC = 'Rainbow sparkles, fire and glow on your character'}
CMDs[#CMDs + 1] = {NAME = 'unpartyfx / unglowup', DESC = 'Removes party effects'}
CMDs[#CMDs + 1] = {NAME = 'beyblade / letitrip [speed]', DESC = 'Spin + party effects. LET IT RIP'}
CMDs[#CMDs + 1] = {NAME = 'unbeyblade', DESC = 'Stops the beyblade'}
CMDs[#CMDs + 1] = {NAME = 'magic8ball / 8ball [question]', DESC = 'Ask the magic 8-ball'}
CMDs[#CMDs + 1] = {NAME = 'coinflip / flipcoin', DESC = 'Flip a coin'}
CMDs[#CMDs + 1] = {NAME = 'roll / dice [sides]', DESC = 'Roll a die (default d6)'}
CMDs[#CMDs + 1] = {NAME = 'fortune / fortunecookie', DESC = 'Get a silly fortune'}
CMDs[#CMDs + 1] = {NAME = 'compliment / hypeme', DESC = 'Get hyped up'}
CMDs[#CMDs + 1] = {NAME = 'roastme', DESC = 'Get roasted'}
CMDs[#CMDs + 1] = {NAME = 'chaos / surpriseme', DESC = 'Runs a random wacky command'}
CMDs[#CMDs + 1] = {NAME = 'unwacky / stopwacky', DESC = 'Turns off every wacky effect'}
CMDs[#CMDs + 1] = {NAME = 'skin / material [name/random]', DESC = 'Local skin: gold, chrome, diamond, glass, ice, lava, neon, wood, stone, grass'}
CMDs[#CMDs + 1] = {NAME = 'unskin', DESC = 'Restores your normal look'}
CMDs[#CMDs + 1] = {NAME = 'aura [color]', DESC = 'Glowing particle aura (rainbow if no color)'}
CMDs[#CMDs + 1] = {NAME = 'unaura', DESC = 'Removes the aura'}
CMDs[#CMDs + 1] = {NAME = 'halo [color]', DESC = 'Spinning ring of light above your head'}
CMDs[#CMDs + 1] = {NAME = 'unhalo', DESC = 'Removes the halo'}
CMDs[#CMDs + 1] = {NAME = 'pet / companion [name]', DESC = 'A little cube buddy that follows you around'}
CMDs[#CMDs + 1] = {NAME = 'unpet', DESC = 'Sends your pet home'}
CMDs[#CMDs + 1] = {NAME = 'nuke / kaboom', DESC = 'Harmless visual explosion with screen flash and shake'}
CMDs[#CMDs + 1] = {NAME = 'fireworks [count]', DESC = 'Launches a fireworks show around you'}
CMDs[#CMDs + 1] = {NAME = 'timelapse [speed]', DESC = 'Fast-forwards the day/night cycle'}
CMDs[#CMDs + 1] = {NAME = 'untimelapse', DESC = 'Stops the timelapse and restores the time'}
CMDs[#CMDs + 1] = {NAME = 'sunset / goldenhour', DESC = 'Warm sunset lighting'}
CMDs[#CMDs + 1] = {NAME = 'unsunset', DESC = 'Removes the sunset'}
CMDs[#CMDs + 1] = {NAME = 'flashlight / torch', DESC = 'Puts a flashlight on you'}
CMDs[#CMDs + 1] = {NAME = 'unflashlight', DESC = 'Turns off the flashlight'}
CMDs[#CMDs + 1] = {NAME = 'horror / spookymode', DESC = 'Dark spooky lighting plus a flashlight'}
CMDs[#CMDs + 1] = {NAME = 'unhorror', DESC = 'Turns the lights back on'}
CMDs[#CMDs + 1] = {NAME = 'matrix', DESC = 'Green vision + low gravity. There is no spoon'}
CMDs[#CMDs + 1] = {NAME = 'unmatrix / bluepill', DESC = 'Leaves the matrix'}
CMDs[#CMDs + 1] = {NAME = 'flop / faceplant [seconds]', DESC = 'Ragdoll flop onto the floor'}
CMDs[#CMDs + 1] = {NAME = 'zoomies / sanic [seconds] [speed]', DESC = 'Temporary super speed with a rainbow trail'}
CMDs[#CMDs + 1] = {NAME = 'joke', DESC = 'Tells a terrible joke'}
CMDs[#CMDs + 1] = {NAME = 'wouldyourather / wyr', DESC = 'Asks a would-you-rather question'}
CMDs[#CMDs + 1] = {NAME = 'stopwatch / timer', DESC = 'Starts / stops a stopwatch'}
CMDs[#CMDs + 1] = {NAME = 'neveryield / about', DESC = 'Shows NeverYield info'}
CMDs[#CMDs + 1] = {NAME = 'themes / themestudio', DESC = 'Opens the animated Theme Studio (also in Settings)'}
CMDs[#CMDs + 1] = {NAME = 'theme [name]', DESC = 'Cosmic: auto, space, nebula, galaxy, void, cosmic, classic. Vibes: ocean, sunset, matrix, sakura, candy, lava, arctic, forest, midnight, vaporwave, royal, toxic. Holidays: christmas, halloween, newyear, lunarnewyear, valentines, stpatricks, easter, fourthofjuly, thanksgiving, hanukkah, diwali. Memes: doge, stonks, sus, nyan, thisisfine, cheems, noob, vibecat, moai, trollge, skull, funnyaward'}
CMDs[#CMDs + 1] = {NAME = 'autotheme / holidaytheme', DESC = 'Automatically wear the holiday theme for today'}
CMDs[#CMDs + 1] = {NAME = 'themedebug', DESC = 'Shows what the Theme Studio drew (for fixing display problems)'}
CMDs[#CMDs + 1] = {NAME = 'spacemode / space', DESC = 'Purple space lighting, floating stars and low gravity'}
CMDs[#CMDs + 1] = {NAME = 'unspacemode / unspace', DESC = 'Comes back down to Earth'}
CMDs[#CMDs + 1] = {NAME = 'portal / reopen', DESC = 'Replays the NeverYield portal opening animation'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = '--- LIMBS ---', DESC = 'Works on R6 and R15 (R15 also bends elbows/knees). Effects stack! Optional [speed] multiplier'}
CMDs[#CMDs + 1] = {NAME = 'flail [speed]', DESC = 'Arms, legs and head flail around randomly'}
CMDs[#CMDs + 1] = {NAME = 'windmill [speed]', DESC = 'Arms spin like windmills'}
CMDs[#CMDs + 1] = {NAME = 'jelly / noodle [speed]', DESC = 'Every joint wobbles like jelly'}
CMDs[#CMDs + 1] = {NAME = 'wobblylegs / jellylegs [speed]', DESC = 'Noodle legs'}
CMDs[#CMDs + 1] = {NAME = 'headspin / owl [speed]', DESC = 'Your head spins around'}
CMDs[#CMDs + 1] = {NAME = 'headbang [speed]', DESC = 'Rock out'}
CMDs[#CMDs + 1] = {NAME = 'exorcist', DESC = 'Head turned backwards, twitching'}
CMDs[#CMDs + 1] = {NAME = 'paranoid / lookaround', DESC = 'Nervously looks around'}
CMDs[#CMDs + 1] = {NAME = 'sleepy / nod', DESC = 'Head droops and nods off'}
CMDs[#CMDs + 1] = {NAME = 'tpose', DESC = 'Assert dominance'}
CMDs[#CMDs + 1] = {NAME = 'scarecrow', DESC = 'Arms out, head tilted'}
CMDs[#CMDs + 1] = {NAME = 'zombie / zombiearms', DESC = 'Arms straight out in front'}
CMDs[#CMDs + 1] = {NAME = 'superman / supermanpose', DESC = 'Arms up over your head (try with fly)'}
CMDs[#CMDs + 1] = {NAME = 'wave / waving', DESC = 'Wave hello'}
CMDs[#CMDs + 1] = {NAME = 'hooray / armsup', DESC = 'Both arms up celebrating'}
CMDs[#CMDs + 1] = {NAME = 'chicken / flap', DESC = 'Flap your wings and peck'}
CMDs[#CMDs + 1] = {NAME = 'robot / robotdance', DESC = 'Snappy robot poses'}
CMDs[#CMDs + 1] = {NAME = 'dab', DESC = 'Dab'}
CMDs[#CMDs + 1] = {NAME = 'propeller / propellerarms', DESC = 'Arms spin around like propellers'}
CMDs[#CMDs + 1] = {NAME = 'airguitar / shred', DESC = 'Shred on an invisible guitar'}
CMDs[#CMDs + 1] = {NAME = 'boxing / shadowbox', DESC = 'Throw punches'}
CMDs[#CMDs + 1] = {NAME = 'limbchaos / possessed', DESC = 'Every joint spins in a different direction'}
CMDs[#CMDs + 1] = {NAME = 'lean / smoothcriminal [amount]', DESC = 'Lean forward like a smooth criminal'}
CMDs[#CMDs + 1] = {NAME = 'twist / twerk', DESC = 'Twist your body side to side'}
CMDs[#CMDs + 1] = {NAME = 'headstand / upsidedownme', DESC = 'Flip your body upside down'}
CMDs[#CMDs + 1] = {NAME = 'breakdance / bboy', DESC = 'Upside down headspin breakdance'}
CMDs[#CMDs + 1] = {NAME = 'randomlimbs / randompose', DESC = 'Turns on a random limb effect'}
CMDs[#CMDs + 1] = {NAME = 'un<effect>  (e.g. unflail)', DESC = 'Turns off one limb effect'}
CMDs[#CMDs + 1] = {NAME = 'unlimbs / resetlimbs', DESC = 'Turns off all limb effects'}
CMDs[#CMDs + 1] = {NAME = 'limbdebug', DESC = 'Shows your rig type and which joints the limb effects found'}
CMDs[#CMDs + 1] = {NAME = '--- MOVEMENT ---', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'crabwalk / sidewalk', DESC = 'Walk sideways like a crab'}
CMDs[#CMDs + 1] = {NAME = 'uncrabwalk', DESC = 'Walk normally'}
CMDs[#CMDs + 1] = {NAME = 'zigzag [strength]', DESC = 'Zig-zag while you walk'}
CMDs[#CMDs + 1] = {NAME = 'unzigzag', DESC = 'Walk straight'}
CMDs[#CMDs + 1] = {NAME = 'slide / penguin [speed]', DESC = 'Belly slide, steer with movement keys'}
CMDs[#CMDs + 1] = {NAME = 'unslide', DESC = 'Stand back up'}
CMDs[#CMDs + 1] = {NAME = 'tornado / twister [radius]', DESC = 'Spin around in a rising tornado'}
CMDs[#CMDs + 1] = {NAME = 'untornado', DESC = 'Touch down'}
CMDs[#CMDs + 1] = {NAME = 'ascend / heaven [speed]', DESC = 'Float up in a beam of light'}
CMDs[#CMDs + 1] = {NAME = 'unascend', DESC = 'Come back down'}
CMDs[#CMDs + 1] = {NAME = 'antigravity / floatup [seconds]', DESC = 'Float upward for a few seconds'}
CMDs[#CMDs + 1] = {NAME = 'dash [power]', DESC = 'Quick dash in the direction you move'}
CMDs[#CMDs + 1] = {NAME = 'blink [studs]', DESC = 'Teleport a few studs forward'}
CMDs[#CMDs + 1] = {NAME = 'multijump / doublejump [count]', DESC = 'Extra jumps in mid-air'}
CMDs[#CMDs + 1] = {NAME = 'unmultijump', DESC = 'Back to one jump'}
CMDs[#CMDs + 1] = {NAME = 'shiftsprint / sprint [speed] [key]', DESC = 'Hold Left Shift (or your key, e.g. sprint 32 Q) to sprint'}
CMDs[#CMDs + 1] = {NAME = 'unshiftsprint / unsprint', DESC = 'Turns off shift sprint'}
CMDs[#CMDs + 1] = {NAME = 'spinjump', DESC = 'Spin every time you jump'}
CMDs[#CMDs + 1] = {NAME = 'unspinjump', DESC = 'Stop spin jumping'}
CMDs[#CMDs + 1] = {NAME = 'flipjump', DESC = 'Backflip every time you jump'}
CMDs[#CMDs + 1] = {NAME = 'unflipjump', DESC = 'Stop flip jumping'}
CMDs[#CMDs + 1] = {NAME = 'bouncy / trampoline [bounciness]', DESC = 'Bounce back up when you land from high'}
CMDs[#CMDs + 1] = {NAME = 'unbouncy', DESC = 'Stop bouncing'}
CMDs[#CMDs + 1] = {NAME = '--- SCREEN & FUN ---', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'countdown [seconds]', DESC = 'Big on-screen countdown'}
CMDs[#CMDs + 1] = {NAME = 'screentext / bigtext [text]', DESC = 'Big rainbow text on your screen'}
CMDs[#CMDs + 1] = {NAME = 'emojirain [emoji] [count]', DESC = 'Emojis rain down your screen'}
CMDs[#CMDs + 1] = {NAME = 'letterbox / cinemabars', DESC = 'Movie-style black bars'}
CMDs[#CMDs + 1] = {NAME = 'unletterbox', DESC = 'Removes the black bars'}
CMDs[#CMDs + 1] = {NAME = 'selfie / selfiecam', DESC = 'Camera turns around to face you'}
CMDs[#CMDs + 1] = {NAME = 'unselfie', DESC = 'Normal camera'}
CMDs[#CMDs + 1] = {NAME = 'rainbowui / rgbui', DESC = 'The NeverYield GUI cycles through colors'}
CMDs[#CMDs + 1] = {NAME = 'unrainbowui', DESC = 'Restores your GUI colors'}
CMDs[#CMDs + 1] = {NAME = 'hud / statsdisplay', DESC = 'Shows FPS, speed and position on screen'}
CMDs[#CMDs + 1] = {NAME = 'unhud', DESC = 'Hides the stats display'}
CMDs[#CMDs + 1] = {NAME = 'calc / math [expression]', DESC = 'Calculator, e.g. calc (5+3)*2'}
CMDs[#CMDs + 1] = {NAME = 'randomplayer / pickplayer', DESC = 'Picks a random player in the server'}
CMDs[#CMDs + 1] = {NAME = '--- STATS TRACKER ---', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'stats / mystats [tab]', DESC = 'Your lifetime stats across every game: kills, deaths, K/D, streaks, playtime, games, chat, people, commands. Tabs: overview, combat, games, chat, people, commands'}
CMDs[#CMDs + 1] = {NAME = 'killcount / kd', DESC = 'Quick kills and deaths for this server and all time'}
CMDs[#CMDs + 1] = {NAME = 'mychats / chatsearch [text]', DESC = 'Opens your saved chat history (add text to search it)'}
CMDs[#CMDs + 1] = {NAME = 'chatlogging [on/off]', DESC = 'Also save other players\' messages (on by default)'}
CMDs[#CMDs + 1] = {NAME = 'statsexport / copystats', DESC = 'Copies a stats summary to your clipboard'}
CMDs[#CMDs + 1] = {NAME = 'statssave', DESC = 'Saves your stats now (they also save every minute and before teleports)'}
CMDs[#CMDs + 1] = {NAME = 'statsreset confirm', DESC = 'Starts your stats over (a backup file is kept)'}
-- wait()

for i = 1, #CMDs do
	local newcmd = Example:Clone()
	newcmd.Parent = CMDsF
	newcmd.Visible = false
	newcmd.Text = CMDs[i].NAME
	newcmd.Name = "CMD"
	table.insert(text1, newcmd)
	if CMDs[i].DESC ~= "" then
		newcmd:SetAttribute("Title", CMDs[i].NAME)
		newcmd:SetAttribute("Desc", CMDs[i].DESC)
		newcmd.MouseButton1Down:Connect(function()
			if not IsOnMobile and newcmd.Visible and newcmd.TextTransparency == 0 then
				local currentText = Cmdbar.Text
				Cmdbar:CaptureFocus()
				autoComplete(newcmd.Text, currentText)
				maximizeHolder()
			end
		end)
	end
end

IndexContents("", true)

function checkTT()
	local t
	local guisAtPosition = COREGUI:GetGuiObjectsAtPosition(IYMouse.X, IYMouse.Y)

	for _, gui in pairs(guisAtPosition) do
		if gui.Parent == CMDsF then
			t = gui
		end
	end

	if t ~= nil and t:GetAttribute("Title") ~= nil then
		local x = IYMouse.X
		local y = IYMouse.Y
		local xP
		local yP
		if IYMouse.X > 200 then
			xP = x - 201
		else
			xP = x + 21
		end
		if IYMouse.Y > (IYMouse.ViewSizeY-96) then
			yP = y - 97
		else
			yP = y
		end
		Tooltip.Position = UDim2.new(0, xP, 0, yP)
		Description.Text = t:GetAttribute("Desc")
		if t:GetAttribute("Title") ~= nil then
			Title_3.Text = t:GetAttribute("Title")
		else
			Title_3.Text = ''
		end
		Tooltip.Visible = true
	else
		Tooltip.Visible = false
	end
end

function FindInTable(tbl,val)
	if tbl == nil then return false end
	for _,v in pairs(tbl) do
		if v == val then return true end
	end 
	return false
end

function GetInTable(Table, Name)
	for i = 1, #Table do
		if Table[i] == Name then
			return i
		end
	end
	return false
end

function respawn(plr)
	if invisRunning then TurnVisible() end
    local char = plr.Character
    local hum = char:FindFirstChildWhichIsA("Humanoid")
	local archive = workspace.FallenPartsDestroyHeight
	local camType = workspace.CurrentCamera.CameraType
	workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
	workspace.FallenPartsDestroyHeight = 0/0
    getRoot(char).Position = Vector3.yAxis * archive
	task.wait(plr:GetNetworkPing())
	workspace.FallenPartsDestroyHeight = archive
	repeat task.wait() until not char.Parent or not hum.Parent or (hum and hum.Health <= 0)
	if hum then
		hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
	end
end

local refreshCmd = false
function refresh(plr)
	refreshCmd = true
	local root = getRoot(plr.Character)
	local pos = root.CFrame
	local pos1 = workspace.CurrentCamera.CFrame
	respawn(plr)
	task.spawn(function()
		local char = plr.CharacterAdded:Wait()
		local humanoid = char:FindFirstChildOfClass("Humanoid")
		while not humanoid do
			wait()
			humanoid = char:FindFirstChildOfClass("Humanoid")
		end
		humanoid.RootPart.CFrame, workspace.CurrentCamera.CFrame = pos, task.wait() and pos1
		refreshCmd = false
	end)
end

local lastDeath

function onDied()
	task.spawn(function()
		if pcall(function() Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid') end) and Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid') then
			Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid').Died:Connect(function()
				if getRoot(Players.LocalPlayer.Character) then
					lastDeath = getRoot(Players.LocalPlayer.Character).CFrame
				end
			end)
		else
			wait(2)
			onDied()
		end
	end)
end

Clip = true
spDelay = 0.1
Players.LocalPlayer.CharacterAdded:Connect(function()
	NOFLY()
	floating = false

	if not Clip then
		execCmd('clip')
	end

	repeat wait() until getRoot(Players.LocalPlayer.Character)

	pcall(function()
		if spawnpoint and not refreshCmd and spawnpos ~= nil then
			wait(spDelay)
			getRoot(Players.LocalPlayer.Character).CFrame = spawnpos
		end
	end)

	onDied()
end)

onDied()

local booly = {
    truthy = { ["true"] = true, ["t"] = true, ["1"] = true, ["yes"] = true, ["y"] = true, ["on"] = true, ["enable"] = true, ["enabled"] = true },
    falsy = { ["false"] = true, ["f"] = true, ["0"] = true, ["no"] = true, ["n"] = true, ["off"] = true, ["disable"] = true, ["disabled"] = true },
}

function parseBoolean(raw, default)
    raw = tostring(raw):lower()
    if booly.truthy[raw] then return true end
    if booly.falsy[raw] then return false end
    return default or false
end

function getstring(begin, args)
    return table.concat(args or cargs, " ", begin)
end

findCmd=function(cmd_name)
	for i,v in pairs(cmds)do
		if v.NAME:lower()==cmd_name:lower() or FindInTable(v.ALIAS,cmd_name:lower()) then
			return v
		end
	end
	return customAlias[cmd_name:lower()]
end

function splitString(str,delim)
	local broken = {}
	if delim == nil then delim = "," end
	for w in string.gmatch(str,"[^"..delim.."]+") do
		table.insert(broken,w)
	end
	return broken
end

cmdHistory = {}
local lastCmds = {}
local historyCount = 0
local split=" "
local lastBreakTime = 0
function execCmd(cmdStr,speaker,store)
	cmdStr = cmdStr:gsub("%s+$", "")
	task.spawn(function()
		local rawCmdStr = cmdStr
		cmdStr = string.gsub(cmdStr, "\\\\", "%%BackSlash%%")

		local commandsToRun = splitString(cmdStr, "\\")
		for i, v in pairs(commandsToRun) do
			v = string.gsub(v, "%%BackSlash%%", "\\")
			local x, y, num = v:find("^(%d+)%^")
			local cmdDelay = 0
			local infTimes = false

			if num then
				v = v:sub(y + 1)
				local x, y, del = v:find("^([%d%.]+)%^")
				if del then
					v = v:sub(y + 1)
					cmdDelay = tonumber(del) or 0
				end
			else
				local x, y = v:find("^inf%^")
				if x then
					infTimes = true
					v = v:sub(y + 1)
					local x, y, del = v:find("^([%d%.]+)%^")
					if del then
						v = v:sub(y + 1)
						del = tonumber(del) or 1
						cmdDelay = (del > 0 and del or 1)
					else
						cmdDelay = 1
					end
				end
			end
			num = tonumber(num or 1)

			if v:sub(1, 1) == "!" then
				local chunks = splitString(v:sub(2), split)
				if chunks[1] and lastCmds[chunks[1]] then v = lastCmds[chunks[1]] end
			end

			local args = splitString(v, split)
			local cmdName = args[1]
			local cmd = findCmd(cmdName)
			if cmd then
				table.remove(args, 1)
				cargs = args
				if not speaker then speaker = Players.LocalPlayer end

				if store then
					if speaker == Players.LocalPlayer then
						if cmdHistory[1] ~= rawCmdStr and rawCmdStr:sub(1, 11) ~= "lastcommand" and rawCmdStr:sub(1, 7) ~= "lastcmd" then
							table.insert(cmdHistory, 1, rawCmdStr)
						end
					end
					if #cmdHistory > 30 then table.remove(cmdHistory) end

					lastCmds[cmdName] = v
				end

				local cmdStartTime = tick()
				if infTimes then
					while lastBreakTime < cmdStartTime do
						local success, err = pcall(cmd.FUNC, args, speaker)
						if not success and _G.IY_DEBUG then
							warn("Command Error:", cmdName, err)
						end
						wait(cmdDelay)
					end
				else
					for rep = 1, num do
						if lastBreakTime > cmdStartTime then break end
						local success, err = pcall(cmd.FUNC, args, speaker)
						if not success and _G.IY_DEBUG then
							warn("Command Error:", cmdName, err)
							notify("Command Error: " .. cmdName, "Check console")
						end
						if success and type(err) == "string" and not table.find(args, "nonotify") then
							notify("Command: " .. cmdName, err)
						end
						if cmdDelay ~= 0 then wait(cmdDelay) end
					end
				end
			end
		end
	end)
end

function addcmd(name,alias,func,plgn)
	cmds[#cmds+1]=
		{
			NAME=name;
			ALIAS=alias or {};
			FUNC=func;
			PLUGIN=plgn;
		}
end

function removecmd(cmd)
	if cmd ~= " " then
		for i = #cmds,1,-1 do
			if cmds[i].NAME == cmd or FindInTable(cmds[i].ALIAS,cmd) then
				table.remove(cmds, i)
				for a,c in pairs(CMDsF:GetChildren()) do
					if string.find(c.Text, "^"..cmd.."$") or string.find(c.Text, "^"..cmd.." ") or string.find(c.Text, " "..cmd.."$") or string.find(c.Text, " "..cmd.." ") then
						c.TextTransparency = 0.7
						c.MouseButton1Click:Connect(function()
							notify(c.Text, "Command has been disabled by you or a plugin")
						end)
					end
				end
			end
		end
	end
end

function overridecmd(name, func)
	local cmd = findCmd(name)
	if cmd and cmd.FUNC then cmd.FUNC = func end
end

function addbind(cmd,key,iskeyup,toggle)
	if toggle then
		binds[#binds+1]=
			{
				COMMAND=cmd;
				KEY=key;
				ISKEYUP=iskeyup;
				TOGGLE = toggle;
			}
	else
		binds[#binds+1]=
			{
				COMMAND=cmd;
				KEY=key;
				ISKEYUP=iskeyup;
			}
	end
end

function addcmdtext(text,name,desc)
	local newcmd = Example:Clone()
	local tooltipText = tostring(text)
	local tooltipDesc = tostring(desc)
	newcmd.Parent = CMDsF
	newcmd.Visible = false
	newcmd.Text = text
	newcmd.Name = 'PLUGIN_'..name
	table.insert(text1,newcmd)
	if desc and desc ~= '' then
		newcmd:SetAttribute("Title", tooltipText)
		newcmd:SetAttribute("Desc", tooltipDesc)
		newcmd.MouseButton1Down:Connect(function()
			if newcmd.Visible and newcmd.TextTransparency == 0 then
				Cmdbar:CaptureFocus()
				autoComplete(newcmd.Text)
				maximizeHolder()
			end
		end)
	end
end

local WorldToScreen = function(Object)
	local ObjectVector = workspace.CurrentCamera:WorldToScreenPoint(Object.Position)
	return Vector2.new(ObjectVector.X, ObjectVector.Y)
end

local MousePositionToVector2 = function()
	return Vector2.new(IYMouse.X, IYMouse.Y)
end

local GetClosestPlayerFromCursor = function()
	local found = nil
	local ClosestDistance = math.huge
	for i, v in pairs(Players:GetPlayers()) do
		if v ~= Players.LocalPlayer and v.Character and v.Character:FindFirstChildOfClass("Humanoid") then
			for k, x in pairs(v.Character:GetChildren()) do
				if string.find(x.Name, "Torso") then
					local Distance = (WorldToScreen(x) - MousePositionToVector2()).Magnitude
					if Distance < ClosestDistance then
						ClosestDistance = Distance
						found = v
					end
				end
			end
		end
	end
	return found
end

SpecialPlayerCases = {
	["all"] = function(speaker) return Players:GetPlayers() end,
	["others"] = function(speaker)
		local plrs = {}
		for i,v in pairs(Players:GetPlayers()) do
			if v ~= speaker then
				table.insert(plrs,v)
			end
		end
		return plrs
	end,
	["me"] = function(speaker)return {speaker} end,
	["#(%d+)"] = function(speaker,args,currentList)
		local returns = {}
		local randAmount = tonumber(args[1])
		local players = {unpack(currentList)}
		for i = 1,randAmount do
			if #players == 0 then break end
			local randIndex = math.random(1,#players)
			table.insert(returns,players[randIndex])
			table.remove(players,randIndex)
		end
		return returns
	end,
	["random"] = function(speaker,args,currentList)
		local players = Players:GetPlayers()
		local localplayer = Players.LocalPlayer
		table.remove(players, table.find(players, localplayer))
		return {players[math.random(1,#players)]}
	end,
	["%%(.+)"] = function(speaker,args)
		local returns = {}
		local team = args[1]
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Team and string.sub(string.lower(plr.Team.Name),1,#team) == string.lower(team) then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["allies"] = function(speaker)
		local returns = {}
		local team = speaker.Team
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Team == team then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["enemies"] = function(speaker)
		local returns = {}
		local team = speaker.Team
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Team ~= team then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["team"] = function(speaker)
		local returns = {}
		local team = speaker.Team
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Team == team then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["nonteam"] = function(speaker)
		local returns = {}
		local team = speaker.Team
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Team ~= team then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["friends"] = function(speaker,args)
		local returns = {}
		for _,plr in pairs(Players:GetPlayers()) do
			if plr:IsFriendsWith(speaker.UserId) and plr ~= speaker then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["nonfriends"] = function(speaker,args)
		local returns = {}
		for _,plr in pairs(Players:GetPlayers()) do
			if not plr:IsFriendsWith(speaker.UserId) and plr ~= speaker then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["guests"] = function(speaker,args)
		local returns = {}
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Guest then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["bacons"] = function(speaker,args)
		local returns = {}
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Character:FindFirstChild('Pal Hair') or plr.Character:FindFirstChild('Kate Hair') then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["age(%d+)"] = function(speaker,args)
		local returns = {}
		local age = tonumber(args[1])
		if not age == nil then return end
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.AccountAge <= age then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["nearest"] = function(speaker,args,currentList)
		local speakerChar = speaker.Character
		if not speakerChar or not getRoot(speakerChar) then return end
		local lowest = math.huge
		local NearestPlayer = nil
		for _,plr in pairs(currentList) do
			if plr ~= speaker and plr.Character then
				local distance = plr:DistanceFromCharacter(getRoot(speakerChar).Position)
				if distance < lowest then
					lowest = distance
					NearestPlayer = {plr}
				end
			end
		end
		return NearestPlayer
	end,
	["farthest"] = function(speaker,args,currentList)
		local speakerChar = speaker.Character
		if not speakerChar or not getRoot(speakerChar) then return end
		local highest = 0
		local Farthest = nil
		for _,plr in pairs(currentList) do
			if plr ~= speaker and plr.Character then
				local distance = plr:DistanceFromCharacter(getRoot(speakerChar).Position)
				if distance > highest then
					highest = distance
					Farthest = {plr}
				end
			end
		end
		return Farthest
	end,
	["group(%d+)"] = function(speaker,args)
		local returns = {}
		local groupID = tonumber(args[1])
		for _,plr in pairs(Players:GetPlayers()) do
			if plr:IsInGroup(groupID) then  
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["alive"] = function(speaker,args)
		local returns = {}
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Character and plr.Character:FindFirstChildOfClass("Humanoid") and plr.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["dead"] = function(speaker,args)
		local returns = {}
		for _,plr in pairs(Players:GetPlayers()) do
			if (not plr.Character or not plr.Character:FindFirstChildOfClass("Humanoid")) or plr.Character:FindFirstChildOfClass("Humanoid").Health <= 0 then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["rad(%d+)"] = function(speaker,args)
		local returns = {}
		local radius = tonumber(args[1])
		local speakerChar = speaker.Character
		if not speakerChar or not getRoot(speakerChar) then return end
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Character and getRoot(plr.Character) then
				local magnitude = (getRoot(plr.Character).Position-getRoot(speakerChar).Position).magnitude
				if magnitude <= radius then table.insert(returns,plr) end
			end
		end
		return returns
	end,
	["cursor"] = function(speaker)
		local plrs = {}
		local v = GetClosestPlayerFromCursor()
		if v ~= nil then table.insert(plrs, v) end
		return plrs
	end,
	["npcs"] = function(speaker,args)
		local returns = {}
		for _, v in pairs(workspace:GetDescendants()) do
			if v:IsA("Model") and getRoot(v) and v:FindFirstChildWhichIsA("Humanoid") and Players:GetPlayerFromCharacter(v) == nil then
				local clone = Instance.new("Player")
				clone.Name = v.Name .. " - " .. v:FindFirstChildWhichIsA("Humanoid").DisplayName
				clone.Character = v
				table.insert(returns, clone)
			end
		end
		return returns
	end,
}

function toTokens(str)
	local tokens = {}
	for op,name in string.gmatch(str,"([+-])([^+-]+)") do
		table.insert(tokens,{Operator = op,Name = name})
	end
	return tokens
end

function onlyIncludeInTable(tab,matches)
	local matchTable = {}
	local resultTable = {}
	for i,v in pairs(matches) do matchTable[v.Name] = true end
	for i,v in pairs(tab) do if matchTable[v.Name] then table.insert(resultTable,v) end end
	return resultTable
end

function removeTableMatches(tab,matches)
	local matchTable = {}
	local resultTable = {}
	for i,v in pairs(matches) do matchTable[v.Name] = true end
	for i,v in pairs(tab) do if not matchTable[v.Name] then table.insert(resultTable,v) end end
	return resultTable
end

function getPlayersByName(Name)
	local Name,Len,Found = string.lower(Name),#Name,{}
	for _,v in pairs(Players:GetPlayers()) do
		if Name:sub(0,1) == '@' then
			if string.sub(string.lower(v.Name),1,Len-1) == Name:sub(2) then
				table.insert(Found,v)
			end
		else
			if string.sub(string.lower(v.Name),1,Len) == Name or string.sub(string.lower(v.DisplayName),1,Len) == Name then
				table.insert(Found,v)
			end
		end
	end
	return Found
end

function getPlayer(list,speaker)
	if list == nil then return {speaker.Name} end
	local nameList = splitString(list,",")

	local foundList = {}

	for _,name in pairs(nameList) do
		if string.sub(name,1,1) ~= "+" and string.sub(name,1,1) ~= "-" then name = "+"..name end
		local tokens = toTokens(name)
		local initialPlayers = Players:GetPlayers()

		for i,v in pairs(tokens) do
			if v.Operator == "+" then
				local tokenContent = v.Name
				local foundCase = false
				for regex,case in pairs(SpecialPlayerCases) do
					local matches = {string.match(tokenContent,"^"..regex.."$")}
					if #matches > 0 then
						foundCase = true
						initialPlayers = onlyIncludeInTable(initialPlayers,case(speaker,matches,initialPlayers))
					end
				end
				if not foundCase then
					initialPlayers = onlyIncludeInTable(initialPlayers,getPlayersByName(tokenContent))
				end
			else
				local tokenContent = v.Name
				local foundCase = false
				for regex,case in pairs(SpecialPlayerCases) do
					local matches = {string.match(tokenContent,"^"..regex.."$")}
					if #matches > 0 then
						foundCase = true
						initialPlayers = removeTableMatches(initialPlayers,case(speaker,matches,initialPlayers))
					end
				end
				if not foundCase then
					initialPlayers = removeTableMatches(initialPlayers,getPlayersByName(tokenContent))
				end
			end
		end

		for i,v in pairs(initialPlayers) do table.insert(foundList,v) end
	end

	local foundNames = {}
	for i,v in pairs(foundList) do table.insert(foundNames,v.Name) end

	return foundNames
end

function formatUsername(player)
	if player.DisplayName ~= player.Name then
		return string.format("%s (%s)", player.Name, player.DisplayName)
	end
	return player.Name
end

getprfx=function(strn)
	if strn:sub(1,string.len(prefix))==prefix then return{'cmd',string.len(prefix)+1}
	end return
end

function do_exec(str, plr)
	str = str:gsub('/e ', '')
	local t = getprfx(str)
	if not t then return end
	str = str:sub(t[2])
	if t[1]=='cmd' then
		execCmd(str, plr, true)
		IndexContents('',true,false,true)
		CMDsF.CanvasPosition = canvasPos
	end
end

lastTextBoxString,lastTextBoxCon,lastEnteredString = nil,nil,nil

UserInputService.TextBoxFocused:Connect(function(obj)
	if lastTextBoxCon then lastTextBoxCon:Disconnect() end
	if obj == Cmdbar then lastTextBoxString = nil return end
	lastTextBoxString = obj.Text
	lastTextBoxCon = obj:GetPropertyChangedSignal("Text"):Connect(function()
		if not (UserInputService:IsKeyDown(Enum.KeyCode.Return) or UserInputService:IsKeyDown(Enum.KeyCode.KeypadEnter)) then
			lastTextBoxString = obj.Text
		end
	end)
end)

UserInputService.InputBegan:Connect(function(input,gameProcessed)
	if gameProcessed then
		if Cmdbar and Cmdbar:IsFocused() then
			if input.KeyCode == Enum.KeyCode.Up then
				historyCount = historyCount + 1
				if historyCount > #cmdHistory then historyCount = #cmdHistory end
				Cmdbar.Text = cmdHistory[historyCount] or ""
				Cmdbar.CursorPosition = 1020
			elseif input.KeyCode == Enum.KeyCode.Down then
				historyCount = historyCount - 1
				if historyCount < 0 then historyCount = 0 end
				Cmdbar.Text = cmdHistory[historyCount] or ""
				Cmdbar.CursorPosition = 1020
			end
		elseif input.KeyCode == Enum.KeyCode.Return or input.KeyCode == Enum.KeyCode.KeypadEnter then
			lastEnteredString = lastTextBoxString
		end
	end
end)

Players.LocalPlayer.Chatted:Connect(function()
	wait()
	if lastEnteredString then
		local message = lastEnteredString
		lastEnteredString = nil
		do_exec(message, Players.LocalPlayer)
	end
end)

Cmdbar.PlaceholderText = "Command Bar ("..prefix..")"
Cmdbar:GetPropertyChangedSignal("Text"):Connect(function()
	if Cmdbar:IsFocused() then
		IndexContents(Cmdbar.Text,true,true)
	end
end)

local tabComplete = nil
tabAllowed = true
Cmdbar.FocusLost:Connect(function(enterpressed)
	if enterpressed then
		local cmdbarText = Cmdbar.Text:gsub("^"..prefix,"")
		execCmd(cmdbarText,Players.LocalPlayer,true)
	end
	if tabComplete then tabComplete:Disconnect() end
	wait()
	if not Cmdbar:IsFocused() then
		Cmdbar.Text = ""
		IndexContents('',true,false,true)
		if SettingsOpen == true then
			wait(0.2)
			Settings:TweenPosition(UDim2.new(0, 0, 0, 45), "InOut", "Quart", 0.2, true, nil)
			CMDsF.Visible = false
		end
	end
	CMDsF.CanvasPosition = canvasPos
end)

Cmdbar.Focused:Connect(function()
	historyCount = 0
	canvasPos = CMDsF.CanvasPosition
	if SettingsOpen == true then
		wait(0.2)
		CMDsF.Visible = true
		Settings:TweenPosition(UDim2.new(0, 0, 0, 220), "InOut", "Quart", 0.2, true, nil)
	end
	tabComplete = UserInputService.InputBegan:Connect(function(input,gameProcessed)
		if Cmdbar:IsFocused() then
			if tabAllowed == true and input.KeyCode == Enum.KeyCode.Tab and topCommand ~= nil then
				autoComplete(topCommand)
			end
		else
			tabComplete:Disconnect()
		end
	end)
end)

ESPenabled = false
CHMSenabled = false

function round(num, numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0)
	return math.floor(num * mult + 0.5) / mult
end

function ESP(plr, logic)
	task.spawn(function()
		for i,v in pairs(COREGUI:GetChildren()) do
			if v.Name == plr.Name..'_ESP' then
				v:Destroy()
			end
		end
		wait()
		if plr.Character and plr.Name ~= Players.LocalPlayer.Name and not COREGUI:FindFirstChild(plr.Name..'_ESP') then
			local ESPholder = Instance.new("Folder")
			ESPholder.Name = plr.Name..'_ESP'
			ESPholder.Parent = COREGUI
			repeat wait(1) until plr.Character and getRoot(plr.Character) and plr.Character:FindFirstChildOfClass("Humanoid")
			for b,n in pairs (plr.Character:GetChildren()) do
				if (n:IsA("BasePart")) then
					local a = Instance.new("BoxHandleAdornment")
					a.Name = plr.Name
					a.Parent = ESPholder
					a.Adornee = n
					a.AlwaysOnTop = true
					a.ZIndex = 10
					a.Size = n.Size
					a.Transparency = espTransparency
					if logic == true then
						a.Color = BrickColor.new(plr.TeamColor == Players.LocalPlayer.TeamColor and "Bright green" or "Bright red")
					else
						a.Color = plr.TeamColor
					end
				end
			end
			if plr.Character and plr.Character:FindFirstChild('Head') then
				local BillboardGui = Instance.new("BillboardGui")
				local TextLabel = Instance.new("TextLabel")
				BillboardGui.Adornee = plr.Character.Head
				BillboardGui.Name = plr.Name
				BillboardGui.Parent = ESPholder
				BillboardGui.Size = UDim2.new(0, 100, 0, 150)
				BillboardGui.StudsOffset = Vector3.new(0, 1, 0)
				BillboardGui.AlwaysOnTop = true
				TextLabel.Parent = BillboardGui
				TextLabel.BackgroundTransparency = 1
				TextLabel.Position = UDim2.new(0, 0, 0, -50)
				TextLabel.Size = UDim2.new(0, 100, 0, 100)
				TextLabel.Font = Enum.Font.SourceSansSemibold
				TextLabel.TextSize = 20
				TextLabel.TextColor3 = Color3.new(1, 1, 1)
				TextLabel.TextStrokeTransparency = 0
				TextLabel.TextYAlignment = Enum.TextYAlignment.Bottom
				TextLabel.Text = 'Name: '..plr.Name
				TextLabel.ZIndex = 10
				local espLoopFunc
				local teamChange
				local addedFunc
				addedFunc = plr.CharacterAdded:Connect(function()
					if ESPenabled then
						espLoopFunc:Disconnect()
						teamChange:Disconnect()
						ESPholder:Destroy()
						repeat wait(1) until getRoot(plr.Character) and plr.Character:FindFirstChildOfClass("Humanoid")
						ESP(plr, logic)
						addedFunc:Disconnect()
					else
						teamChange:Disconnect()
						addedFunc:Disconnect()
					end
				end)
				teamChange = plr:GetPropertyChangedSignal("TeamColor"):Connect(function()
					if ESPenabled then
						espLoopFunc:Disconnect()
						addedFunc:Disconnect()
						ESPholder:Destroy()
						repeat wait(1) until getRoot(plr.Character) and plr.Character:FindFirstChildOfClass("Humanoid")
						ESP(plr, logic)
						teamChange:Disconnect()
					else
						teamChange:Disconnect()
					end
				end)
				local function espLoop()
					if COREGUI:FindFirstChild(plr.Name..'_ESP') then
						if plr.Character and getRoot(plr.Character) and plr.Character:FindFirstChildOfClass("Humanoid") and Players.LocalPlayer.Character and getRoot(Players.LocalPlayer.Character) and Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
							local pos = math.floor((getRoot(Players.LocalPlayer.Character).Position - getRoot(plr.Character).Position).magnitude)
							TextLabel.Text = 'Name: '..plr.Name..' | Health: '..round(plr.Character:FindFirstChildOfClass('Humanoid').Health, 1)..' | Studs: '..pos
						end
					else
						teamChange:Disconnect()
						addedFunc:Disconnect()
						espLoopFunc:Disconnect()
					end
				end
				espLoopFunc = RunService.RenderStepped:Connect(espLoop)
			end
		end
	end)
end

function CHMS(plr)
	task.spawn(function()
		for i,v in pairs(COREGUI:GetChildren()) do
			if v.Name == plr.Name..'_CHMS' then
				v:Destroy()
			end
		end
		wait()
		if plr.Character and plr.Name ~= Players.LocalPlayer.Name and not COREGUI:FindFirstChild(plr.Name..'_CHMS') then
			local ESPholder = Instance.new("Folder")
			ESPholder.Name = plr.Name..'_CHMS'
			ESPholder.Parent = COREGUI
			repeat wait(1) until plr.Character and getRoot(plr.Character) and plr.Character:FindFirstChildOfClass("Humanoid")
			for b,n in pairs (plr.Character:GetChildren()) do
				if (n:IsA("BasePart")) then
					local a = Instance.new("BoxHandleAdornment")
					a.Name = plr.Name
					a.Parent = ESPholder
					a.Adornee = n
					a.AlwaysOnTop = true
					a.ZIndex = 10
					a.Size = n.Size
					a.Transparency = espTransparency
					a.Color = plr.TeamColor
				end
			end
			local addedFunc
			local teamChange
			local CHMSremoved
			addedFunc = plr.CharacterAdded:Connect(function()
				if CHMSenabled then
					ESPholder:Destroy()
					teamChange:Disconnect()
					repeat wait(1) until getRoot(plr.Character) and plr.Character:FindFirstChildOfClass("Humanoid")
					CHMS(plr)
					addedFunc:Disconnect()
				else
					teamChange:Disconnect()
					addedFunc:Disconnect()
				end
			end)
			teamChange = plr:GetPropertyChangedSignal("TeamColor"):Connect(function()
				if CHMSenabled then
					ESPholder:Destroy()
					addedFunc:Disconnect()
					repeat wait(1) until getRoot(plr.Character) and plr.Character:FindFirstChildOfClass("Humanoid")
					CHMS(plr)
					teamChange:Disconnect()
				else
					teamChange:Disconnect()
				end
			end)
			CHMSremoved = ESPholder.AncestryChanged:Connect(function()
				teamChange:Disconnect()
				addedFunc:Disconnect()
				CHMSremoved:Disconnect()
			end)
		end
	end)
end

function Locate(plr)
	task.spawn(function()
		for i,v in pairs(COREGUI:GetChildren()) do
			if v.Name == plr.Name..'_LC' then
				v:Destroy()
			end
		end
		wait()
		if plr.Character and plr.Name ~= Players.LocalPlayer.Name and not COREGUI:FindFirstChild(plr.Name..'_LC') then
			local ESPholder = Instance.new("Folder")
			ESPholder.Name = plr.Name..'_LC'
			ESPholder.Parent = COREGUI
			repeat wait(1) until plr.Character and getRoot(plr.Character) and plr.Character:FindFirstChildOfClass("Humanoid")
			for b,n in pairs (plr.Character:GetChildren()) do
				if (n:IsA("BasePart")) then
					local a = Instance.new("BoxHandleAdornment")
					a.Name = plr.Name
					a.Parent = ESPholder
					a.Adornee = n
					a.AlwaysOnTop = true
					a.ZIndex = 10
					a.Size = n.Size
					a.Transparency = espTransparency
					a.Color = plr.TeamColor
				end
			end
			if plr.Character and plr.Character:FindFirstChild('Head') then
				local BillboardGui = Instance.new("BillboardGui")
				local TextLabel = Instance.new("TextLabel")
				BillboardGui.Adornee = plr.Character.Head
				BillboardGui.Name = plr.Name
				BillboardGui.Parent = ESPholder
				BillboardGui.Size = UDim2.new(0, 100, 0, 150)
				BillboardGui.StudsOffset = Vector3.new(0, 1, 0)
				BillboardGui.AlwaysOnTop = true
				TextLabel.Parent = BillboardGui
				TextLabel.BackgroundTransparency = 1
				TextLabel.Position = UDim2.new(0, 0, 0, -50)
				TextLabel.Size = UDim2.new(0, 100, 0, 100)
				TextLabel.Font = Enum.Font.SourceSansSemibold
				TextLabel.TextSize = 20
				TextLabel.TextColor3 = Color3.new(1, 1, 1)
				TextLabel.TextStrokeTransparency = 0
				TextLabel.TextYAlignment = Enum.TextYAlignment.Bottom
				TextLabel.Text = 'Name: '..plr.Name
				TextLabel.ZIndex = 10
				local lcLoopFunc
				local addedFunc
				local teamChange
				addedFunc = plr.CharacterAdded:Connect(function()
					if ESPholder ~= nil and ESPholder.Parent ~= nil then
						lcLoopFunc:Disconnect()
						teamChange:Disconnect()
						ESPholder:Destroy()
						repeat wait(1) until getRoot(plr.Character) and plr.Character:FindFirstChildOfClass("Humanoid")
						Locate(plr)
						addedFunc:Disconnect()
					else
						teamChange:Disconnect()
						addedFunc:Disconnect()
					end
				end)
				teamChange = plr:GetPropertyChangedSignal("TeamColor"):Connect(function()
					if ESPholder ~= nil and ESPholder.Parent ~= nil then
						lcLoopFunc:Disconnect()
						addedFunc:Disconnect()
						ESPholder:Destroy()
						repeat wait(1) until getRoot(plr.Character) and plr.Character:FindFirstChildOfClass("Humanoid")
						Locate(plr)
						teamChange:Disconnect()
					else
						teamChange:Disconnect()
					end
				end)
				local function lcLoop()
					if COREGUI:FindFirstChild(plr.Name..'_LC') then
						if plr.Character and getRoot(plr.Character) and plr.Character:FindFirstChildOfClass("Humanoid") and Players.LocalPlayer.Character and getRoot(Players.LocalPlayer.Character) and Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
							local pos = math.floor((getRoot(Players.LocalPlayer.Character).Position - getRoot(plr.Character).Position).magnitude)
							TextLabel.Text = 'Name: '..plr.Name..' | Health: '..round(plr.Character:FindFirstChildOfClass('Humanoid').Health, 1)..' | Studs: '..pos
						end
					else
						teamChange:Disconnect()
						addedFunc:Disconnect()
						lcLoopFunc:Disconnect()
					end
				end
				lcLoopFunc = RunService.RenderStepped:Connect(lcLoop)
			end
		end
	end)
end

local bindsGUI = KeybindEditor
local awaitingInput = false
local keySelected = false

function refreshbinds()
	if Holder_2 then
		Holder_2:ClearAllChildren()
		Holder_2.CanvasSize = UDim2.new(0, 0, 0, 10)
		for i = 1, #binds do
			local YSize = 25
			local Position = ((i * YSize) - YSize)
			local newbind = Example_2:Clone()
			newbind.Parent = Holder_2
			newbind.Visible = true
			newbind.Position = UDim2.new(0,0,0, Position + 5)
			table.insert(shade2,newbind)
			table.insert(shade2,newbind.Text)
			table.insert(text1,newbind.Text)
			table.insert(shade3,newbind.Text.Delete)
			table.insert(text2,newbind.Text.Delete)
			local input = tostring(binds[i].KEY)
			local key
			if input == 'RightClick' or input == 'LeftClick' then
				key = input
			else
				key = input:sub(14)
			end
			if binds[i].TOGGLE then
				newbind.Text.Text = key.." > "..binds[i].COMMAND.." / "..binds[i].TOGGLE
			else
				newbind.Text.Text = key.." > "..binds[i].COMMAND.."  "..(binds[i].ISKEYUP and "(keyup)" or "(keydown)")
			end
			Holder_2.CanvasSize = UDim2.new(0,0,0, Position + 30)
			newbind.Text.Delete.MouseButton1Click:Connect(function()
				unkeybind(binds[i].COMMAND,binds[i].KEY)
			end)
		end
	end
end

refreshbinds()

toggleOn = {}

function unkeybind(cmd,key)
	for i = #binds,1,-1 do
		if binds[i].COMMAND == cmd and binds[i].KEY == key then
			toggleOn[binds[i]] = nil
			table.remove(binds, i)
		end
	end
	refreshbinds()
	updatesaves()
	if key == 'RightClick' or key == 'LeftClick' then
		notify('Keybinds Updated','Unbinded '..key..' from '..cmd)
	else
		notify('Keybinds Updated','Unbinded '..key:sub(14)..' from '..cmd)
	end
end

PositionsFrame.Delete.MouseButton1Click:Connect(function()
	execCmd('cpos')
end)

function refreshwaypoints()
	if #WayPoints > 0 or #pWayPoints > 0 then
		PositionsHint:Destroy()
	end
	if Holder_4 then
		Holder_4:ClearAllChildren()
		Holder_4.CanvasSize = UDim2.new(0, 0, 0, 10)
		local YSize = 25
		local num = 1
		for i = 1, #WayPoints do
			local Position = ((num * YSize) - YSize)
			local newpoint = Example_4:Clone()
			newpoint.Parent = Holder_4
			newpoint.Visible = true
			newpoint.Position = UDim2.new(0,0,0, Position + 5)
			newpoint.Text.Text = WayPoints[i].NAME
			table.insert(shade2,newpoint)
			table.insert(shade2,newpoint.Text)
			table.insert(text1,newpoint.Text)
			table.insert(shade3,newpoint.Text.Delete)
			table.insert(text2,newpoint.Text.Delete)
			table.insert(shade3,newpoint.Text.TP)
			table.insert(text2,newpoint.Text.TP)
			Holder_4.CanvasSize = UDim2.new(0,0,0, Position + 30)
			newpoint.Text.Delete.MouseButton1Click:Connect(function()
				execCmd('dpos '..WayPoints[i].NAME)
			end)
			newpoint.Text.TP.MouseButton1Click:Connect(function()
				execCmd("loadpos "..WayPoints[i].NAME)
			end)
			num = num+1
		end
		for i = 1, #pWayPoints do
			local Position = ((num * YSize) - YSize)
			local newpoint = Example_4:Clone()
			newpoint.Parent = Holder_4
			newpoint.Visible = true
			newpoint.Position = UDim2.new(0,0,0, Position + 5)
			newpoint.Text.Text = pWayPoints[i].NAME
			table.insert(shade2,newpoint)
			table.insert(shade2,newpoint.Text)
			table.insert(text1,newpoint.Text)
			table.insert(shade3,newpoint.Text.Delete)
			table.insert(text2,newpoint.Text.Delete)
			table.insert(shade3,newpoint.Text.TP)
			table.insert(text2,newpoint.Text.TP)
			Holder_4.CanvasSize = UDim2.new(0,0,0, Position + 30)
			newpoint.Text.Delete.MouseButton1Click:Connect(function()
				execCmd('dpos '..pWayPoints[i].NAME)
			end)
			newpoint.Text.TP.MouseButton1Click:Connect(function()
				execCmd("loadpos "..pWayPoints[i].NAME)
			end)
			num = num+1
		end
	end
end

refreshwaypoints()

function refreshaliases()
	if #aliases > 0 then
		AliasHint:Destroy()
	end
	if Holder_3 then
		Holder_3:ClearAllChildren()
		Holder_3.CanvasSize = UDim2.new(0, 0, 0, 10)
		for i = 1, #aliases do
			local YSize = 25
			local Position = ((i * YSize) - YSize)
			local newalias = Example_3:Clone()
			newalias.Parent = Holder_3
			newalias.Visible = true
			newalias.Position = UDim2.new(0,0,0, Position + 5)
			newalias.Text.Text = aliases[i].CMD.." > "..aliases[i].ALIAS
			table.insert(shade2,newalias)
			table.insert(shade2,newalias.Text)
			table.insert(text1,newalias.Text)
			table.insert(shade3,newalias.Text.Delete)
			table.insert(text2,newalias.Text.Delete)
			Holder_3.CanvasSize = UDim2.new(0,0,0, Position + 30)
			newalias.Text.Delete.MouseButton1Click:Connect(function()
				execCmd('removealias '..aliases[i].ALIAS)
			end)
		end
	end
end

local bindChosenKeyUp = false

BindTo.MouseButton1Click:Connect(function()
	awaitingInput = true
	BindTo.Text = 'Press something'
end)

BindTriggerSelect.MouseButton1Click:Connect(function()
	bindChosenKeyUp = not bindChosenKeyUp
	BindTriggerSelect.Text = bindChosenKeyUp and "KeyUp" or "KeyDown"
end)

newToggle = false
Cmdbar_3.Parent.Visible = false
On_2.MouseButton1Click:Connect(function()
	if newToggle == false then newToggle = true
		On_2.BackgroundTransparency = 0
		Cmdbar_3.Parent.Visible = true
		BindTriggerSelect.Visible = false
	else newToggle = false
		On_2.BackgroundTransparency = 1
		Cmdbar_3.Parent.Visible = false
		BindTriggerSelect.Visible = true
	end
end)

Add_2.MouseButton1Click:Connect(function()
	if keySelected then
		if string.find(Cmdbar_2.Text, "\\\\") or string.find(Cmdbar_3.Text, "\\\\") then
			notify('Keybind Error','Only use one backslash to keybind multiple commands into one keybind or command')
		else
			if newToggle and Cmdbar_3.Text ~= '' and Cmdbar_2.text ~= '' then
				addbind(Cmdbar_2.Text,keyPressed,false,Cmdbar_3.Text)
			elseif not newToggle and Cmdbar_2.text ~= '' then
				addbind(Cmdbar_2.Text,keyPressed,bindChosenKeyUp)
			else
				return
			end
			refreshbinds()
			updatesaves()
			if keyPressed == 'RightClick' or keyPressed == 'LeftClick' then
				notify('Keybinds Updated','Binded '..keyPressed..' to '..Cmdbar_2.Text..(newToggle and " / "..Cmdbar_3.Text or ""))
			else
				notify('Keybinds Updated','Binded '..keyPressed:sub(14)..' to '..Cmdbar_2.Text..(newToggle and " / "..Cmdbar_3.Text or ""))
			end
		end
	end
end)

Exit_2.MouseButton1Click:Connect(function()
	Cmdbar_2.Text = 'Command'
	Cmdbar_3.Text = 'Command 2'
	BindTo.Text = 'Click to bind'
	bindChosenKeyUp = false
	BindTriggerSelect.Text = "KeyDown"
	keySelected = false
	KeybindEditor:TweenPosition(UDim2.new(0.5, -180, 0, -500), "InOut", "Quart", 0.5, true, nil)
end)

function onInputBegan(input,gameProcessed)
	if awaitingInput then
		if input.UserInputType == Enum.UserInputType.Keyboard then
			keyPressed = tostring(input.KeyCode)
			BindTo.Text = keyPressed:sub(14)
		elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
			keyPressed = 'LeftClick'
			BindTo.Text = 'LeftClick'
		elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
			keyPressed = 'RightClick'
			BindTo.Text = 'RightClick'
		end
		awaitingInput = false
		keySelected = true
	end
	if not gameProcessed and #binds > 0 then
		for i,v in pairs(binds) do
			if not v.ISKEYUP then
				if (input.UserInputType == Enum.UserInputType.Keyboard and v.KEY:lower()==tostring(input.KeyCode):lower()) or (input.UserInputType == Enum.UserInputType.MouseButton1 and v.KEY:lower()=='leftclick') or (input.UserInputType == Enum.UserInputType.MouseButton2 and v.KEY:lower()=='rightclick') then
					if v.TOGGLE then
						local isOn = toggleOn[v] == true
						toggleOn[v] = not isOn
						if isOn then
							execCmd(v.TOGGLE,Players.LocalPlayer)
						else
							execCmd(v.COMMAND,Players.LocalPlayer)
						end
					else
						execCmd(v.COMMAND,Players.LocalPlayer)
					end
				end
			end
		end
	end
end

function onInputEnded(input,gameProcessed)
	if not gameProcessed and #binds > 0 then
		for i,v in pairs(binds) do
			if v.ISKEYUP then
				if (input.UserInputType == Enum.UserInputType.Keyboard and v.KEY:lower()==tostring(input.KeyCode):lower()) or (input.UserInputType == Enum.UserInputType.MouseButton1 and v.KEY:lower()=='leftclick') or (input.UserInputType == Enum.UserInputType.MouseButton2 and v.KEY:lower()=='rightclick') then
					execCmd(v.COMMAND,Players.LocalPlayer)
				end
			end
		end
	end
end

UserInputService.InputBegan:Connect(onInputBegan)
UserInputService.InputEnded:Connect(onInputEnded)

ClickTP.Select.MouseButton1Click:Connect(function()
	if keySelected then
		addbind('clicktp',keyPressed,bindChosenKeyUp)
		refreshbinds()
		updatesaves()
		if keyPressed == 'RightClick' or keyPressed == 'LeftClick' then
			notify('Keybinds Updated','Binded '..keyPressed..' to click tp')
		else
			notify('Keybinds Updated','Binded '..keyPressed:sub(14)..' to click tp')
		end
	end
end)

ClickDelete.Select.MouseButton1Click:Connect(function()
	if keySelected then
		addbind('clickdel',keyPressed,bindChosenKeyUp)
		refreshbinds()
		updatesaves()
		if keyPressed == 'RightClick' or keyPressed == 'LeftClick' then
			notify('Keybinds Updated','Binded '..keyPressed..' to click delete')
		else
			notify('Keybinds Updated','Binded '..keyPressed:sub(14)..' to click delete')
		end
	end
end)

local function clicktpFunc()
	pcall(function()
		local character = Players.LocalPlayer.Character
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid and humanoid.SeatPart then
			humanoid.Sit = false
			wait(0.1)
		end

		local hipHeight = humanoid and humanoid.HipHeight > 0 and (humanoid.HipHeight + 1)
		local rootPart = getRoot(character)
		local rootPartPosition = rootPart.Position
		local hitPosition = IYMouse.Hit.Position
		local newCFrame = CFrame.new(
			hitPosition, 
			Vector3.new(rootPartPosition.X, hitPosition.Y, rootPartPosition.Z)
		) * CFrame.Angles(0, math.pi, 0)

		rootPart.CFrame = newCFrame + Vector3.new(0, hipHeight or 4, 0)
		breakVelocity()
	end)
end

IYMouse.Button1Down:Connect(function()
	for i,v in pairs(binds) do
		if v.COMMAND == 'clicktp' then
			local input = v.KEY
			if input == 'RightClick' and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) and Players.LocalPlayer.Character then
				clicktpFunc()
			elseif input == 'LeftClick' and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) and Players.LocalPlayer.Character then
				clicktpFunc()
			elseif UserInputService:IsKeyDown(Enum.KeyCode[input:sub(14)]) and Players.LocalPlayer.Character then
				clicktpFunc()
			end
		elseif v.COMMAND == 'clickdel' then
			local input = v.KEY
			if input == 'RightClick' and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
				pcall(function() IYMouse.Target:Destroy() end)
			elseif input == 'LeftClick' and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
				pcall(function() IYMouse.Target:Destroy() end)
			elseif UserInputService:IsKeyDown(Enum.KeyCode[input:sub(14)]) then
				pcall(function() IYMouse.Target:Destroy() end)
			end
		end
	end
end)

PluginsGUI = PluginEditor.background

function addPlugin(name)
	if name:lower() == 'plugin file name' or name:lower() == 'iy_fe.iy' or name == 'iy_fe' then
		notify('Plugin Error','Please enter a valid plugin')
	else
		local file
		local fileName
		if name:sub(-3) == '.iy' then
			pcall(function() file = readfile(name) end)
			fileName = name
		else
			pcall(function() file = readfile(name..'.iy') end)
			fileName = name..'.iy'
		end
		if file then
			if not FindInTable(PluginsTable, fileName) then
				table.insert(PluginsTable, fileName)
				LoadPlugin(fileName)
				refreshplugins()
				pcall(eventEditor.Refresh)
			else
				notify('Plugin Error','This plugin is already added')
			end
		else
			notify('Plugin Error','Cannot locate file "'..fileName..'". Is the file in the correct folder?')
		end
	end
end

function deletePlugin(name)
	local pName = name..'.iy'
	if name:sub(-3) == '.iy' then
		pName = name
	end
	for i = #cmds,1,-1 do
		if cmds[i].PLUGIN == pName then
			table.remove(cmds, i)
		end
	end
	for i,v in pairs(CMDsF:GetChildren()) do
		if v.Name == 'PLUGIN_'..pName then
			v:Destroy()
		end
	end
	for i,v in pairs(PluginsTable) do
		if v == pName then
			table.remove(PluginsTable, i)
			notify('Removed Plugin',pName..' was removed')
		end
	end
	IndexContents('',true)
	refreshplugins()
end

function refreshplugins(dontSave)
	if #PluginsTable > 0 then
		PluginsHint:Destroy()
	end
	if Holder_5 then
		Holder_5:ClearAllChildren()
		Holder_5.CanvasSize = UDim2.new(0, 0, 0, 10)
		for i,v in pairs(PluginsTable) do
			local pName = v
			local YSize = 25
			local Position = ((i * YSize) - YSize)
			local newplugin = Example_5:Clone()
			newplugin.Parent = Holder_5
			newplugin.Visible = true
			newplugin.Position = UDim2.new(0,0,0, Position + 5)
			newplugin.Text.Text = pName
			table.insert(shade2,newplugin)
			table.insert(shade2,newplugin.Text)
			table.insert(text1,newplugin.Text)
			table.insert(shade3,newplugin.Text.Delete)
			table.insert(text2,newplugin.Text.Delete)
			Holder_5.CanvasSize = UDim2.new(0,0,0, Position + 30)
			newplugin.Text.Delete.MouseButton1Click:Connect(function()
				deletePlugin(pName)
			end)
		end
		if not dontSave then
			updatesaves()
		end
	end
end

local PluginCache
function LoadPlugin(val,startup)
	local plugin

	function CatchedPluginLoad()
		plugin = loadfile(val)()
	end

	function handlePluginError(plerror)
		notify('Plugin Error','An error occurred with the plugin, "'..val..'" and it could not be loaded')
		if FindInTable(PluginsTable,val) then
			for i,v in pairs(PluginsTable) do
				if v == val then
					table.remove(PluginsTable,i)
				end
			end
		end
		updatesaves()

		print("Original Error: "..tostring(plerror))
		print("Plugin Error, stack traceback: "..tostring(debug.traceback()))

		plugin = nil

		return false
	end

	xpcall(CatchedPluginLoad, handlePluginError)

	if plugin ~= nil then
		if not startup then
			notify('Loaded Plugin',"Name: "..plugin["PluginName"].."\n".."Description: "..plugin["PluginDescription"])
		end
		addcmdtext('',val)
		addcmdtext(string.upper('--'..plugin["PluginName"]),val,plugin["PluginDescription"])
		if plugin["Commands"] then
			for i,v in pairs(plugin["Commands"]) do 
				local cmdExt = ''
				local cmdName = i
				local function handleNames()
					cmdName = i
					if findCmd(cmdName..cmdExt) then
						if isNumber(cmdExt) then
							cmdExt = cmdExt+1
						else
							cmdExt = 1
						end
						handleNames()
					else
						cmdName = cmdName..cmdExt
					end
				end
				handleNames()
				addcmd(cmdName, v["Aliases"], v["Function"], val)
				if v["ListName"] then
					local newName = v.ListName
					local cmdNames = {i,unpack(v.Aliases)}
					for i,v in pairs(cmdNames) do
						newName = newName:gsub(v,v..cmdExt)
					end
					addcmdtext(newName,val,v["Description"])
				else
					addcmdtext(cmdName,val,v["Description"])
				end
			end
		end
		IndexContents('',true)
	elseif plugin == nil then
		plugin = nil
	end
end

function FindPlugins()
	if PluginsTable ~= nil and type(PluginsTable) == "table" then
		for i,v in pairs(PluginsTable) do
			LoadPlugin(v,true)
		end
		refreshplugins(true)
	end
end

AddPlugin.MouseButton1Click:Connect(function()
	addPlugin(PluginsGUI.FileName.Text)
end)

Exit_3.MouseButton1Click:Connect(function()
	PluginEditor:TweenPosition(UDim2.new(0.5, -180, 0, -500), "InOut", "Quart", 0.5, true, nil)
	FileName.Text = 'Plugin File Name'
end)

Add_3.MouseButton1Click:Connect(function()
	PluginEditor:TweenPosition(UDim2.new(0.5, -180, 0, 310), "InOut", "Quart", 0.5, true, nil)
end)

Plugins.MouseButton1Click:Connect(function()
	if writefileExploit() then
		PluginsFrame:TweenPosition(UDim2.new(0, 0, 0, 0), "InOut", "Quart", 0.5, true, nil)
		wait(0.5)
		SettingsHolder.Visible = false
	else
		notify('Incompatible Exploit','Your exploit is unable to use plugins (missing read/writefile)')
	end
end)

Close_4.MouseButton1Click:Connect(function()
	SettingsHolder.Visible = true
	PluginsFrame:TweenPosition(UDim2.new(0, 0, 0, 175), "InOut", "Quart", 0.5, true, nil)
end)

-- Your own copy of the script: rejoin / serverhop / keepiy load this in the next server
CustomSourceURL = "https://raw.githubusercontent.com/drdonut54/infinite/main/infinite.lua"
local TeleportCheck = false
Players.LocalPlayer.OnTeleport:Connect(function(State)
	if KeepInfYield and (not TeleportCheck) and queueteleport then
		TeleportCheck = true
		queueteleport("local ok = pcall(function() loadstring(game:HttpGet('" .. CustomSourceURL .. "'))() end) if not ok then loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))() end")
	end
end)

addcmd('addalias',{},function(args, speaker)
	if #args < 2 then return end
	local cmd = string.lower(args[1])
	local alias = string.lower(args[2])
	for i,v in pairs(cmds) do
		if v.NAME:lower()==cmd or FindInTable(v.ALIAS,cmd) then
			customAlias[alias] = v
			aliases[#aliases + 1] = {CMD = cmd, ALIAS = alias}
			notify('Aliases Modified',"Added "..alias.." as an alias to "..cmd)
			updatesaves()
			refreshaliases()
			break
		end
	end
end)

addcmd('removealias',{},function(args, speaker)
	if #args < 1 then return end
	local alias = string.lower(args[1])
	if customAlias[alias] then
		local cmd = customAlias[alias].NAME
		customAlias[alias] = nil
		for i = #aliases,1,-1 do
			if aliases[i].ALIAS == tostring(alias) then
				table.remove(aliases, i)
			end
		end
		notify('Aliases Modified',"Removed the alias "..alias.." from "..cmd)
		updatesaves()
		refreshaliases()
	end
end)

addcmd('clraliases',{},function(args, speaker)
	customAlias = {}
	aliases = {}
	notify('Aliases Modified','Removed all aliases')
	updatesaves()
	refreshaliases()
end)

addcmd('discord', {'support', 'help'}, function(args, speaker)
	if everyClipboard then
		toClipboard('https://discord.com/invite/78ZuWSq')
		notify('Discord Invite', 'Copied to clipboard!\ndiscord.gg/78ZuWSq')
	else
		notify('Discord Invite', 'discord.gg/78ZuWSq')
	end
	if httprequest then
		httprequest({
			Url = 'http://127.0.0.1:6463/rpc?v=1',
			Method = 'POST',
			Headers = {
				['Content-Type'] = 'application/json',
				Origin = 'https://discord.com'
			},
			Body = HttpService:JSONEncode({
				cmd = 'INVITE_BROWSER',
				nonce = HttpService:GenerateGUID(false),
				args = {code = '78ZuWSq'}
			})
		})
	end
end)

addcmd('keepiy', {}, function(args, speaker)
	if queueteleport then
		KeepInfYield = true
		notify('KeepIY','NeverYield will now run after you teleport')
		updatesaves()
	else
		notify('Incompatible Exploit','Your exploit does not support this command (missing queue_on_teleport)')
	end
end)

addcmd('unkeepiy', {}, function(args, speaker)
	if queueteleport then
		KeepInfYield = false
		notify('KeepIY','NeverYield will no longer run after you teleport')
		updatesaves()
	else
		notify('Incompatible Exploit','Your exploit does not support this command (missing queue_on_teleport)')
	end
end)

addcmd('togglekeepiy', {}, function(args, speaker)
	if queueteleport then
		KeepInfYield = not KeepInfYield
		updatesaves()
	else
		notify('Incompatible Exploit','Your exploit does not support this command (missing queue_on_teleport)')
	end
end)

local canOpenServerinfo = true
addcmd('serverinfo',{'info','sinfo'},function(args, speaker)
	if not canOpenServerinfo then return end
	canOpenServerinfo = false
	task.spawn(function()
		local FRAME = Instance.new("Frame")
		local shadow = Instance.new("Frame")
		local PopupText = Instance.new("TextLabel")
		local Exit = Instance.new("TextButton")
		local ExitImage = Instance.new("ImageLabel")
		local background = Instance.new("Frame")
		local TextLabel = Instance.new("TextLabel")
		local TextLabel2 = Instance.new("TextLabel")
		local TextLabel3 = Instance.new("TextLabel")
		local Time = Instance.new("TextLabel")
		local appearance = Instance.new("TextLabel")
		local maxplayers = Instance.new("TextLabel")
		local name = Instance.new("TextLabel")
		local placeid = Instance.new("TextLabel")
		local playerid = Instance.new("TextLabel")
		local players = Instance.new("TextLabel")
		local CopyApp = Instance.new("TextButton")
		local CopyPlrID = Instance.new("TextButton")
		local CopyPlcID = Instance.new("TextButton")
		local CopyPlcName = Instance.new("TextButton")

		FRAME.Name = randomString()
		FRAME.Parent = ScaledHolder
		FRAME.Active = true
		FRAME.BackgroundTransparency = 1
		FRAME.Position = UDim2.new(0.5, -130, 0, -500)
		FRAME.Size = UDim2.new(0, 250, 0, 20)
		FRAME.ZIndex = 10
		dragGUI(FRAME)

		shadow.Name = "shadow"
		shadow.Parent = FRAME
		shadow.BackgroundColor3 = currentShade2
		shadow.BorderSizePixel = 0
		shadow.Size = UDim2.new(0, 250, 0, 20)
		shadow.ZIndex = 10
		table.insert(shade2,shadow)

		PopupText.Name = "PopupText"
		PopupText.Parent = shadow
		PopupText.BackgroundTransparency = 1
		PopupText.Size = UDim2.new(1, 0, 0.95, 0)
		PopupText.ZIndex = 10
		PopupText.Font = Enum.Font.SourceSans
		PopupText.TextSize = 14
		PopupText.Text = "Server"
		PopupText.TextColor3 = currentText1
		PopupText.TextWrapped = true
		table.insert(text1,PopupText)

		Exit.Name = "Exit"
		Exit.Parent = shadow
		Exit.BackgroundTransparency = 1
		Exit.Position = UDim2.new(1, -20, 0, 0)
		Exit.Size = UDim2.new(0, 20, 0, 20)
		Exit.Text = ""
		Exit.ZIndex = 10

		ExitImage.Parent = Exit
		ExitImage.BackgroundColor3 = Color3.new(1, 1, 1)
		ExitImage.BackgroundTransparency = 1
		ExitImage.Position = UDim2.new(0, 5, 0, 5)
		ExitImage.Size = UDim2.new(0, 10, 0, 10)
		ExitImage.Image = getcustomasset("infiniteyield/assets/close.png")
		ExitImage.ZIndex = 10

		background.Name = "background"
		background.Parent = FRAME
		background.Active = true
		background.BackgroundColor3 = currentShade1
		background.BorderSizePixel = 0
		background.Position = UDim2.new(0, 0, 1, 0)
		background.Size = UDim2.new(0, 250, 0, 250)
		background.ZIndex = 10
		table.insert(shade1,background)

		TextLabel.Name = "Text Label"
		TextLabel.Parent = background
		TextLabel.BackgroundTransparency = 1
		TextLabel.BorderSizePixel = 0
		TextLabel.Position = UDim2.new(0, 5, 0, 80)
		TextLabel.Size = UDim2.new(0, 100, 0, 20)
		TextLabel.ZIndex = 10
		TextLabel.Font = Enum.Font.SourceSansLight
		TextLabel.TextSize = 20
		TextLabel.Text = "Run Time:"
		TextLabel.TextColor3 = currentText1
		TextLabel.TextXAlignment = Enum.TextXAlignment.Left
		table.insert(text1,TextLabel)

		TextLabel2.Name = "Text Label2"
		TextLabel2.Parent = background
		TextLabel2.BackgroundTransparency = 1
		TextLabel2.BorderSizePixel = 0
		TextLabel2.Position = UDim2.new(0, 5, 0, 130)
		TextLabel2.Size = UDim2.new(0, 100, 0, 20)
		TextLabel2.ZIndex = 10
		TextLabel2.Font = Enum.Font.SourceSansLight
		TextLabel2.TextSize = 20
		TextLabel2.Text = "Statistics:"
		TextLabel2.TextColor3 = currentText1
		TextLabel2.TextXAlignment = Enum.TextXAlignment.Left
		table.insert(text1,TextLabel2)

		TextLabel3.Name = "Text Label3"
		TextLabel3.Parent = background
		TextLabel3.BackgroundTransparency = 1
		TextLabel3.BorderSizePixel = 0
		TextLabel3.Position = UDim2.new(0, 5, 0, 10)
		TextLabel3.Size = UDim2.new(0, 100, 0, 20)
		TextLabel3.ZIndex = 10
		TextLabel3.Font = Enum.Font.SourceSansLight
		TextLabel3.TextSize = 20
		TextLabel3.Text = "Local Player:"
		TextLabel3.TextColor3 = currentText1
		TextLabel3.TextXAlignment = Enum.TextXAlignment.Left
		table.insert(text1,TextLabel3)

		Time.Name = "Time"
		Time.Parent = background
		Time.BackgroundTransparency = 1
		Time.BorderSizePixel = 0
		Time.Position = UDim2.new(0, 5, 0, 105)
		Time.Size = UDim2.new(0, 100, 0, 20)
		Time.ZIndex = 10
		Time.Font = Enum.Font.SourceSans
		Time.FontSize = Enum.FontSize.Size14
		Time.Text = "LOADING"
		Time.TextColor3 = currentText1
		Time.TextXAlignment = Enum.TextXAlignment.Left
		table.insert(text1,Time)

		appearance.Name = "appearance"
		appearance.Parent = background
		appearance.BackgroundTransparency = 1
		appearance.BorderSizePixel = 0
		appearance.Position = UDim2.new(0, 5, 0, 55)
		appearance.Size = UDim2.new(0, 100, 0, 20)
		appearance.ZIndex = 10
		appearance.Font = Enum.Font.SourceSans
		appearance.FontSize = Enum.FontSize.Size14
		appearance.Text = "Appearance: LOADING"
		appearance.TextColor3 = currentText1
		appearance.TextXAlignment = Enum.TextXAlignment.Left
		table.insert(text1,appearance)

		maxplayers.Name = "maxplayers"
		maxplayers.Parent = background
		maxplayers.BackgroundTransparency = 1
		maxplayers.BorderSizePixel = 0
		maxplayers.Position = UDim2.new(0, 5, 0, 175)
		maxplayers.Size = UDim2.new(0, 100, 0, 20)
		maxplayers.ZIndex = 10
		maxplayers.Font = Enum.Font.SourceSans
		maxplayers.FontSize = Enum.FontSize.Size14
		maxplayers.Text = "LOADING"
		maxplayers.TextColor3 = currentText1
		maxplayers.TextXAlignment = Enum.TextXAlignment.Left
		table.insert(text1,maxplayers)

		name.Name = "name"
		name.Parent = background
		name.BackgroundTransparency = 1
		name.BorderSizePixel = 0
		name.Position = UDim2.new(0, 5, 0, 215)
		name.Size = UDim2.new(0, 240, 0, 30)
		name.ZIndex = 10
		name.Font = Enum.Font.SourceSans
		name.FontSize = Enum.FontSize.Size14
		name.Text = "Place Name: LOADING"
		name.TextColor3 = currentText1
		name.TextWrapped = true
		name.TextXAlignment = Enum.TextXAlignment.Left
		name.TextYAlignment = Enum.TextYAlignment.Top
		table.insert(text1,name)

		placeid.Name = "placeid"
		placeid.Parent = background
		placeid.BackgroundTransparency = 1
		placeid.BorderSizePixel = 0
		placeid.Position = UDim2.new(0, 5, 0, 195)
		placeid.Size = UDim2.new(0, 100, 0, 20)
		placeid.ZIndex = 10
		placeid.Font = Enum.Font.SourceSans
		placeid.FontSize = Enum.FontSize.Size14
		placeid.Text = "Place ID: LOADING"
		placeid.TextColor3 = currentText1
		placeid.TextXAlignment = Enum.TextXAlignment.Left
		table.insert(text1,placeid)

		playerid.Name = "playerid"
		playerid.Parent = background
		playerid.BackgroundTransparency = 1
		playerid.BorderSizePixel = 0
		playerid.Position = UDim2.new(0, 5, 0, 35)
		playerid.Size = UDim2.new(0, 100, 0, 20)
		playerid.ZIndex = 10
		playerid.Font = Enum.Font.SourceSans
		playerid.FontSize = Enum.FontSize.Size14
		playerid.Text = "Player ID: LOADING"
		playerid.TextColor3 = currentText1
		playerid.TextXAlignment = Enum.TextXAlignment.Left
		table.insert(text1,playerid)

		players.Name = "players"
		players.Parent = background
		players.BackgroundTransparency = 1
		players.BorderSizePixel = 0
		players.Position = UDim2.new(0, 5, 0, 155)
		players.Size = UDim2.new(0, 100, 0, 20)
		players.ZIndex = 10
		players.Font = Enum.Font.SourceSans
		players.FontSize = Enum.FontSize.Size14
		players.Text = "LOADING"
		players.TextColor3 = currentText1
		players.TextXAlignment = Enum.TextXAlignment.Left
		table.insert(text1,players)

		CopyApp.Name = "CopyApp"
		CopyApp.Parent = background
		CopyApp.BackgroundColor3 = currentShade2
		CopyApp.BorderSizePixel = 0
		CopyApp.Position = UDim2.new(0, 210, 0, 55)
		CopyApp.Size = UDim2.new(0, 35, 0, 20)
		CopyApp.Font = Enum.Font.SourceSans
		CopyApp.TextSize = 14
		CopyApp.Text = "Copy"
		CopyApp.TextColor3 = currentText1
		CopyApp.ZIndex = 10
		table.insert(shade2,CopyApp)
		table.insert(text1,CopyApp)

		CopyPlrID.Name = "CopyPlrID"
		CopyPlrID.Parent = background
		CopyPlrID.BackgroundColor3 = currentShade2
		CopyPlrID.BorderSizePixel = 0
		CopyPlrID.Position = UDim2.new(0, 210, 0, 35)
		CopyPlrID.Size = UDim2.new(0, 35, 0, 20)
		CopyPlrID.Font = Enum.Font.SourceSans
		CopyPlrID.TextSize = 14
		CopyPlrID.Text = "Copy"
		CopyPlrID.TextColor3 = currentText1
		CopyPlrID.ZIndex = 10
		table.insert(shade2,CopyPlrID)
		table.insert(text1,CopyPlrID)

		CopyPlcID.Name = "CopyPlcID"
		CopyPlcID.Parent = background
		CopyPlcID.BackgroundColor3 = currentShade2
		CopyPlcID.BorderSizePixel = 0
		CopyPlcID.Position = UDim2.new(0, 210, 0, 195)
		CopyPlcID.Size = UDim2.new(0, 35, 0, 20)
		CopyPlcID.Font = Enum.Font.SourceSans
		CopyPlcID.TextSize = 14
		CopyPlcID.Text = "Copy"
		CopyPlcID.TextColor3 = currentText1
		CopyPlcID.ZIndex = 10
		table.insert(shade2,CopyPlcID)
		table.insert(text1,CopyPlcID)

		CopyPlcName.Name = "CopyPlcName"
		CopyPlcName.Parent = background
		CopyPlcName.BackgroundColor3 = currentShade2
		CopyPlcName.BorderSizePixel = 0
		CopyPlcName.Position = UDim2.new(0, 210, 0, 215)
		CopyPlcName.Size = UDim2.new(0, 35, 0, 20)
		CopyPlcName.Font = Enum.Font.SourceSans
		CopyPlcName.TextSize = 14
		CopyPlcName.Text = "Copy"
		CopyPlcName.TextColor3 = currentText1
		CopyPlcName.ZIndex = 10
		table.insert(shade2,CopyPlcName)
		table.insert(text1,CopyPlcName)

		local SINFOGUI = background
		FRAME:TweenPosition(UDim2.new(0.5, -130, 0, 100), "InOut", "Quart", 0.5, true, nil) 
		wait(0.5)
		Exit.MouseButton1Click:Connect(function()
			FRAME:TweenPosition(UDim2.new(0.5, -130, 0, -500), "InOut", "Quart", 0.5, true, nil) 
			wait(0.6)
			FRAME:Destroy()
			canOpenServerinfo = true
		end)
		local Asset = MarketplaceService:GetProductInfo(PlaceId)
		SINFOGUI.name.Text = "Place Name: " .. Asset.Name
		SINFOGUI.playerid.Text = "Player ID: " ..speaker.UserId
		SINFOGUI.maxplayers.Text = Players.MaxPlayers.. " Players Max"
		SINFOGUI.placeid.Text = "Place ID: " ..PlaceId

		CopyApp.MouseButton1Click:Connect(function()
			toClipboard(speaker.CharacterAppearanceId)
		end)
		CopyPlrID.MouseButton1Click:Connect(function()
			toClipboard(speaker.UserId)
		end)
		CopyPlcID.MouseButton1Click:Connect(function()
			toClipboard(PlaceId)
		end)
		CopyPlcName.MouseButton1Click:Connect(function()
			toClipboard(Asset.Name)
		end)

		repeat
			players = Players:GetPlayers()
			SINFOGUI.players.Text = #players.. " Player(s)"
			SINFOGUI.appearance.Text = "Appearance: " ..speaker.CharacterAppearanceId
			local seconds = math.floor(workspace.DistributedGameTime)
			local minutes = math.floor(workspace.DistributedGameTime / 60)
			local hours = math.floor(workspace.DistributedGameTime / 60 / 60)
			local seconds = seconds - (minutes * 60)
			local minutes = minutes - (hours * 60)
			if hours < 1 then if minutes < 1 then
					SINFOGUI.Time.Text = seconds .. " Second(s)" else
					SINFOGUI.Time.Text = minutes .. " Minute(s), " .. seconds .. " Second(s)"
				end
			else
				SINFOGUI.Time.Text = hours .. " Hour(s), " .. minutes .. " Minute(s), " .. seconds .. " Second(s)"
			end
			wait(1)
		until SINFOGUI.Parent == nil
	end)
end)

addcmd("jobid", {}, function(args, speaker)
	toClipboard("roblox://placeId=" .. PlaceId .. "&gameInstanceId=" .. JobId)
end)

addcmd('notifyjobid',{},function(args, speaker)
	notify('JobId / PlaceId',JobId..' / '..PlaceId)
end)

addcmd('breakloops',{'break'},function(args, speaker)
	lastBreakTime = tick()
end)

addcmd('gametp',{'gameteleport'},function(args, speaker)
	TeleportService:Teleport(args[1])
end)

teleportRespawnHandler = [[
local ok, data = pcall(function() return game:GetService("TeleportService"):GetLocalPlayerTeleportData() end)
if ok and typeof(data) == "CFrame" then
    local Players = game:GetService("Players")
    local ME = Players.LocalPlayer
    while not ME do
        Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
        ME = Players.LocalPlayer
    end

    local Character = ME.Character or ME.CharacterAdded:Wait()
    Character:WaitForChild("HumanoidRootPart")

    local t = tick()
    while (tick() - t) <= 0.3 do
        Character:PivotTo(data)
        task.wait()
    end
end
]]
addcmd("rejoin", {"rj"}, function(args, speaker)
    local data = nil
    if parseBoolean(args[1], false) == true then
        if queueteleport then
            if speaker.Character then
                data = speaker.Character:GetPivot()
                queueteleport(teleportRespawnHandler)
            end
        else
            notify("Incompatible Exploit", "Your exploit does not support this argument (missing queue_on_teleport)")
        end
    end

    if #Players:GetPlayers() <= 1 then
        Players.LocalPlayer:Kick("\nRejoining...")
        task.wait(0.3)
        TeleportService:Teleport(PlaceId, Players.LocalPlayer, data)
    else
        TeleportService:TeleportToPlaceInstance(PlaceId, JobId, Players.LocalPlayer, nil, data)
    end
end)

addcmd("inviteprompt", {}, function(args, speaker)
	local plrs = getPlayer(args[1], speaker)
	if #plrs > 0 then
		ExperienceService:LaunchExperience({
			placeId = PlaceId,
			gameInstanceId = JobId,
			referredByPlayerId = plr[1].UserId
		})
	end
end)

addcmd("autorejoin", {"autorj"}, function(args, speaker)
	GuiService.ErrorMessageChanged:Connect(function()
		execCmd("rejoin")
	end)
	notify("Auto Rejoin", "Auto rejoin enabled")
end)

addcmd("serverhop", {"shop"}, function(args, speaker)
	-- thanks to Amity for fixing
	local servers = {}
	local req = game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Desc&limit=100&excludeFullGames=true")
	local body = HttpService:JSONDecode(req)

	if body and body.data then
		for i, v in next, body.data do
			if type(v) == "table" and tonumber(v.playing) and tonumber(v.maxPlayers) and v.playing < v.maxPlayers and v.id ~= JobId then
				table.insert(servers, 1, v.id)
			end
		end
	end

	if #servers > 0 then
		TeleportService:TeleportToPlaceInstance(PlaceId, servers[math.random(1, #servers)], Players.LocalPlayer)
	else
		return notify("Serverhop", "Couldn't find a server.")
	end
end)

addcmd("exit", {"shutdown", "leave"}, function(args, speaker)
	game:Shutdown()
end)

local NoclipParts = {}
local Noclipping = nil
addcmd("noclip", {}, function(args, speaker)
    pcall(function() Noclipping:Disconnect() end)
    Clip = false
    task.wait(0.1)
    NoclipParts = {}
    Noclipping = RunService.Stepped:Connect(function()
        if Clip == false and speaker.Character ~= nil then
            for _, child in pairs(speaker.Character:GetDescendants()) do
                if child:IsA("BasePart") and child.CanCollide == true and child.Name ~= floatName then
                    child.CanCollide = false
                    NoclipParts[child] = true
                end
            end
        end
    end)
    if args[1] and args[1] == "nonotify" then return end
    notify("Noclip", "Noclip Enabled")
end)

addcmd("unnoclip", {"clip"}, function(args, speaker)
    pcall(function() Noclipping:Disconnect() end)
    Clip = true
    task.wait(0.1)
    for child, _ in pairs(NoclipParts) do
        if typeof(child) == "Instance" and child:IsA("BasePart") and child.Parent then
            child.CanCollide = true
        end
    end
    NoclipParts = {}
    if args[1] and args[1] == "nonotify" then return end
    notify("Noclip", "Noclip Disabled")
end)

addcmd("togglenoclip", {}, function(args, speaker)
    execCmd(Clip and "noclip" or "unnoclip")
end)

FLYING = false
QEfly = true
iyflyspeed = 1
vehicleflyspeed = 1
function sFLY(vfly)
	local plr = Players.LocalPlayer
	local char = plr.Character or plr.CharacterAdded:Wait()
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		repeat task.wait() until char:FindFirstChildOfClass("Humanoid")
		humanoid = char:FindFirstChildOfClass("Humanoid")
	end

	if flyKeyDown or flyKeyUp then
		flyKeyDown:Disconnect()
		flyKeyUp:Disconnect()
	end

	local T = getRoot(char)
	local CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
	local lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
	local SPEED = 0

	local function FLY()
		FLYING = true
		local BG = Instance.new('BodyGyro')
		local BV = Instance.new('BodyVelocity')
		BG.P = 9e4
		BG.Parent = T
		BV.Parent = T
		BG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
		BG.CFrame = T.CFrame
		BV.Velocity = Vector3.new(0, 0, 0)
		BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
		task.spawn(function()
			repeat task.wait()
				local camera = workspace.CurrentCamera
				if not vfly and humanoid then
					humanoid.PlatformStand = true
				end

				if CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0 then
					SPEED = 50
				elseif not (CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0) and SPEED ~= 0 then
					SPEED = 0
				end
				if (CONTROL.L + CONTROL.R) ~= 0 or (CONTROL.F + CONTROL.B) ~= 0 or (CONTROL.Q + CONTROL.E) ~= 0 then
					BV.Velocity = ((camera.CFrame.LookVector * (CONTROL.F + CONTROL.B)) + ((camera.CFrame * CFrame.new(CONTROL.L + CONTROL.R, (CONTROL.F + CONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).p) - camera.CFrame.p)) * SPEED
					lCONTROL = {F = CONTROL.F, B = CONTROL.B, L = CONTROL.L, R = CONTROL.R}
				elseif (CONTROL.L + CONTROL.R) == 0 and (CONTROL.F + CONTROL.B) == 0 and (CONTROL.Q + CONTROL.E) == 0 and SPEED ~= 0 then
					BV.Velocity = ((camera.CFrame.LookVector * (lCONTROL.F + lCONTROL.B)) + ((camera.CFrame * CFrame.new(lCONTROL.L + lCONTROL.R, (lCONTROL.F + lCONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).p) - camera.CFrame.p)) * SPEED
				else
					BV.Velocity = Vector3.new(0, 0, 0)
				end
				BG.CFrame = camera.CFrame
			until not FLYING
			CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
			lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
			SPEED = 0
			BG:Destroy()
			BV:Destroy()

			if humanoid then humanoid.PlatformStand = false end
		end)
	end

	flyKeyDown = UserInputService.InputBegan:Connect(function(input, processed)
		if processed then return end
		if input.KeyCode == Enum.KeyCode.W then
			CONTROL.F = (vfly and vehicleflyspeed or iyflyspeed)
		elseif input.KeyCode == Enum.KeyCode.S then
			CONTROL.B = - (vfly and vehicleflyspeed or iyflyspeed)
		elseif input.KeyCode == Enum.KeyCode.A then
			CONTROL.L = - (vfly and vehicleflyspeed or iyflyspeed)
		elseif input.KeyCode == Enum.KeyCode.D then
			CONTROL.R = (vfly and vehicleflyspeed or iyflyspeed)
		elseif input.KeyCode == Enum.KeyCode.E and QEfly then
			CONTROL.Q = (vfly and vehicleflyspeed or iyflyspeed)*2
		elseif input.KeyCode == Enum.KeyCode.Q and QEfly then
			CONTROL.E = -(vfly and vehicleflyspeed or iyflyspeed)*2
		end
		pcall(function() camera.CameraType = Enum.CameraType.Track end)
	end)

	flyKeyUp = UserInputService.InputEnded:Connect(function(input, processed)
		if processed then return end
		if input.KeyCode == Enum.KeyCode.W then
			CONTROL.F = 0
		elseif input.KeyCode == Enum.KeyCode.S then
			CONTROL.B = 0
		elseif input.KeyCode == Enum.KeyCode.A then
			CONTROL.L = 0
		elseif input.KeyCode == Enum.KeyCode.D then
			CONTROL.R = 0
		elseif input.KeyCode == Enum.KeyCode.E then
			CONTROL.Q = 0
		elseif input.KeyCode == Enum.KeyCode.Q then
			CONTROL.E = 0
		end
	end)
	FLY()
end

function NOFLY()
	FLYING = false
	if flyKeyDown or flyKeyUp then flyKeyDown:Disconnect() flyKeyUp:Disconnect() end
	if Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid') then
		Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid').PlatformStand = false
	end
	pcall(function() workspace.CurrentCamera.CameraType = Enum.CameraType.Custom end)
end

local velocityHandlerName = randomString()
local gyroHandlerName = randomString()
local mfly1
local mfly2

local unmobilefly = function(speaker)
	pcall(function()
		FLYING = false
		local root = getRoot(speaker.Character)
		root:FindFirstChild(velocityHandlerName):Destroy()
		root:FindFirstChild(gyroHandlerName):Destroy()
		speaker.Character:FindFirstChildWhichIsA("Humanoid").PlatformStand = false
		mfly1:Disconnect()
		mfly2:Disconnect()
	end)
end

local mobilefly = function(speaker, vfly)
	unmobilefly(speaker)
	FLYING = true

	local root = getRoot(speaker.Character)
	local camera = workspace.CurrentCamera
	local v3none = Vector3.new()
	local v3zero = Vector3.new(0, 0, 0)
	local v3inf = Vector3.new(9e9, 9e9, 9e9)

	local controlModule = require(speaker.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("ControlModule"))
	local bv = Instance.new("BodyVelocity")
	bv.Name = velocityHandlerName
	bv.Parent = root
	bv.MaxForce = v3zero
	bv.Velocity = v3zero

	local bg = Instance.new("BodyGyro")
	bg.Name = gyroHandlerName
	bg.Parent = root
	bg.MaxTorque = v3inf
	bg.P = 1000
	bg.D = 50

	mfly1 = speaker.CharacterAdded:Connect(function()
		local bv = Instance.new("BodyVelocity")
		bv.Name = velocityHandlerName
		bv.Parent = root
		bv.MaxForce = v3zero
		bv.Velocity = v3zero

		local bg = Instance.new("BodyGyro")
		bg.Name = gyroHandlerName
		bg.Parent = root
		bg.MaxTorque = v3inf
		bg.P = 1000
		bg.D = 50
	end)

	mfly2 = RunService.RenderStepped:Connect(function()
		root = getRoot(speaker.Character)
		camera = workspace.CurrentCamera
		if speaker.Character:FindFirstChildWhichIsA("Humanoid") and root and root:FindFirstChild(velocityHandlerName) and root:FindFirstChild(gyroHandlerName) then
			local humanoid = speaker.Character:FindFirstChildWhichIsA("Humanoid")
			local VelocityHandler = root:FindFirstChild(velocityHandlerName)
			local GyroHandler = root:FindFirstChild(gyroHandlerName)

			VelocityHandler.MaxForce = v3inf
			GyroHandler.MaxTorque = v3inf
			if not vfly then humanoid.PlatformStand = true end
			GyroHandler.CFrame = camera.CoordinateFrame
			VelocityHandler.Velocity = v3none

			local direction = controlModule:GetMoveVector()
			if direction.X > 0 then
				VelocityHandler.Velocity = VelocityHandler.Velocity + camera.CFrame.RightVector * (direction.X * ((vfly and vehicleflyspeed or iyflyspeed) * 50))
			end
			if direction.X < 0 then
				VelocityHandler.Velocity = VelocityHandler.Velocity + camera.CFrame.RightVector * (direction.X * ((vfly and vehicleflyspeed or iyflyspeed) * 50))
			end
			if direction.Z > 0 then
				VelocityHandler.Velocity = VelocityHandler.Velocity - camera.CFrame.LookVector * (direction.Z * ((vfly and vehicleflyspeed or iyflyspeed) * 50))
			end
			if direction.Z < 0 then
				VelocityHandler.Velocity = VelocityHandler.Velocity - camera.CFrame.LookVector * (direction.Z * ((vfly and vehicleflyspeed or iyflyspeed) * 50))
			end
		end
	end)
end

addcmd('fly',{},function(args, speaker)
	if not IsOnMobile then
		NOFLY()
		wait()
		sFLY()
	else
		mobilefly(speaker)
	end
	if args[1] and isNumber(args[1]) then
		iyflyspeed = args[1]
	end
end)

addcmd('flyspeed',{'flysp'},function(args, speaker)
	local speed = args[1] or 1
	if isNumber(speed) then
		iyflyspeed = speed
	end
end)

addcmd('unfly',{'nofly','novfly','unvehiclefly','novehiclefly','unvfly'},function(args, speaker)
	if not IsOnMobile then NOFLY() else unmobilefly(speaker) end
end)

addcmd('vfly',{'vehiclefly'},function(args, speaker)
	if not IsOnMobile then
		NOFLY()
		wait()
		sFLY(true)
	else
		mobilefly(speaker, true)
	end
	if args[1] and isNumber(args[1]) then
		vehicleflyspeed = args[1]
	end
end)

addcmd('togglevfly',{},function(args, speaker)
	if FLYING then
		if not IsOnMobile then NOFLY() else unmobilefly(speaker) end
	else
		if not IsOnMobile then sFLY(true) else mobilefly(speaker, true) end
	end
end)

addcmd('vflyspeed',{'vflysp','vehicleflyspeed','vehicleflysp'},function(args, speaker)
	local speed = args[1] or 1
	if isNumber(speed) then
		vehicleflyspeed = speed
	end
end)

addcmd('qefly',{'flyqe'},function(args, speaker)
	if args[1] == 'false' then
		QEfly = false
	else
		QEfly = true
	end
end)

addcmd('togglefly',{},function(args, speaker)
	if FLYING then
		if not IsOnMobile then NOFLY() else unmobilefly(speaker) end
	else
		if not IsOnMobile then sFLY() else mobilefly(speaker) end
	end
end)

CFspeed = 50
addcmd('cframefly', {'cfly'}, function(args, speaker)
	if args[1] and isNumber(args[1]) then
		CFspeed = args[1]
	end

	-- Full credit to peyton#9148 (apeyton)
	speaker.Character:FindFirstChildOfClass('Humanoid').PlatformStand = true
	local Head = speaker.Character:WaitForChild("Head")
	Head.Anchored = true
	if CFloop then CFloop:Disconnect() end
	CFloop = RunService.Heartbeat:Connect(function(deltaTime)
		local moveDirection = speaker.Character:FindFirstChildOfClass('Humanoid').MoveDirection * (CFspeed * deltaTime)
		local headCFrame = Head.CFrame
		local camera = workspace.CurrentCamera
		local cameraCFrame = camera.CFrame
		local cameraOffset = headCFrame:ToObjectSpace(cameraCFrame).Position
		cameraCFrame = cameraCFrame * CFrame.new(-cameraOffset.X, -cameraOffset.Y, -cameraOffset.Z + 1)
		local cameraPosition = cameraCFrame.Position
		local headPosition = headCFrame.Position

		local objectSpaceVelocity = CFrame.new(cameraPosition, Vector3.new(headPosition.X, cameraPosition.Y, headPosition.Z)):VectorToObjectSpace(moveDirection)
		Head.CFrame = CFrame.new(headPosition) * (cameraCFrame - cameraPosition) * CFrame.new(objectSpaceVelocity)
	end)
end)

addcmd('uncframefly',{'uncfly'},function(args, speaker)
	if CFloop then
		CFloop:Disconnect()
		speaker.Character:FindFirstChildOfClass('Humanoid').PlatformStand = false
		local Head = speaker.Character:WaitForChild("Head")
		Head.Anchored = false
	end
end)

addcmd('cframeflyspeed',{'cflyspeed'},function(args, speaker)
	if isNumber(args[1]) then
		CFspeed = args[1]
	end
end)

floating = false
local beganListener: RBXScriptConnection
local endListener: RBXScriptConnection
local floatingFunc: RBXScriptConnection

addcmd('float', {'platform'},function(args, speaker)
	local pchar = speaker.Character
	floatName = randomString()
	floating = true
	
	if pchar and not pchar:FindFirstChild(floatName) then
		task.spawn(function()
			local floatPoint = -3.1
			local floatPart = Instance.new('Part')
			floatPart.Name = floatName
			floatPart.Parent = pchar
			floatPart.Transparency = 1
			floatPart.Size = Vector3.new(2, 0.2, 1.5)
			floatPart.Anchored = true
			
			notify('Float', 'Started floating (Q = down & E = up)')
			
			beganListener = UserInputService.InputBegan:Connect(function(key, processed)
				if processed then return end

				if key.KeyCode == Enum.KeyCode.Q then
					floatPoint -= 0.5
				end
				if key.KeyCode == Enum.KeyCode.E then
					floatPoint += 1.5
				end
			end)
			endListener = UserInputService.InputEnded:Connect(function(key, processed)
				if processed then return end

				if key.KeyCode == Enum.KeyCode.Q then
					floatPoint += 0.5
				end
				if key.KeyCode == Enum.KeyCode.E then
					floatPoint -= 1.5
				end
			end)
			
			floatDied = speaker.Character:FindFirstChildOfClass('Humanoid').Died:Connect(function()
				floatingFunc:Disconnect()
				floatPart:Destroy()
				floatDied:Disconnect()
				beganListener:Disconnect()
				endListener:Disconnect()
				floatName = nil
			end)
			local function floatPadLoop()
				if pchar:FindFirstChild(floatName) and getRoot(pchar) then
					floatPart.CFrame = getRoot(pchar).CFrame * CFrame.new(0, floatPoint, 0)
				else
					floatingFunc:Disconnect()
					floatPart:Destroy()
					floatDied:Disconnect()
					beganListener:Disconnect()
					endListener:Disconnect()
					floatName = nil
				end
			end			
			floatingFunc = RunService.PreAnimation:Connect(floatPadLoop)
		end)
	end
end)

addcmd('unfloat',{'nofloat','unplatform','noplatform'},function(args, speaker)
	floating = false
	local pchar = speaker.Character
	notify('Float', 'Stopped floating')
	if pchar:FindFirstChild(floatName) then
		pchar:FindFirstChild(floatName):Destroy()
	end
	if floatDied then
		floatingFunc:Disconnect()
		floatDied:Disconnect()
		beganListener:Disconnect()
		endListener:Disconnect()
		floatName = nil
	end
end)

addcmd('togglefloat',{},function(args, speaker)
	if floating then
		execCmd('unfloat')
	else
		execCmd('float')
	end
end)

swimming = false
local oldgrav = workspace.Gravity
local swimbeat = nil
addcmd('swim',{},function(args, speaker)
	if not swimming and speaker and speaker.Character and speaker.Character:FindFirstChildWhichIsA("Humanoid") then
		oldgrav = workspace.Gravity
		workspace.Gravity = 0
		local swimDied = function()
			workspace.Gravity = oldgrav
			swimming = false
		end
		local Humanoid = speaker.Character:FindFirstChildWhichIsA("Humanoid")
		gravReset = Humanoid.Died:Connect(swimDied)
		local enums = Enum.HumanoidStateType:GetEnumItems()
		table.remove(enums, table.find(enums, Enum.HumanoidStateType.None))
		for i, v in pairs(enums) do
			Humanoid:SetStateEnabled(v, false)
		end
		Humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
		swimbeat = RunService.Heartbeat:Connect(function()
			pcall(function()
				getRoot(speaker.Character).Velocity = ((Humanoid.MoveDirection ~= Vector3.new() or UserInputService:IsKeyDown(Enum.KeyCode.Space)) and getRoot(speaker.Character).Velocity or Vector3.new())
			end)
		end)
		swimming = true
	end
end)

addcmd('unswim',{'noswim'},function(args, speaker)
	if speaker and speaker.Character and speaker.Character:FindFirstChildWhichIsA("Humanoid") then
		workspace.Gravity = oldgrav
		swimming = false
		if gravReset then
			gravReset:Disconnect()
		end
		if swimbeat ~= nil then
			swimbeat:Disconnect()
			swimbeat = nil
		end
		local Humanoid = speaker.Character:FindFirstChildWhichIsA("Humanoid")
		local enums = Enum.HumanoidStateType:GetEnumItems()
		table.remove(enums, table.find(enums, Enum.HumanoidStateType.None))
		for i, v in pairs(enums) do
			Humanoid:SetStateEnabled(v, true)
		end
	end
end)

addcmd('toggleswim',{},function(args, speaker)
	if swimming then
		execCmd('unswim')
	else
		execCmd('swim')
	end
end)

addcmd('setwaypoint',{'swp','setwp','spos','saveposition','savepos'},function(args, speaker)
	local WPName = tostring(getstring(1, args))
	if getRoot(speaker.Character) then
		notify('Modified Waypoints',"Created waypoint: "..getstring(1, args))
		local torso = getRoot(speaker.Character)
		WayPoints[#WayPoints + 1] = {NAME = WPName, COORD = {math.floor(torso.Position.X), math.floor(torso.Position.Y), math.floor(torso.Position.Z)}, GAME = PlaceId}
		if AllWaypoints ~= nil then
			AllWaypoints[#AllWaypoints + 1] = {NAME = WPName, COORD = {math.floor(torso.Position.X), math.floor(torso.Position.Y), math.floor(torso.Position.Z)}, GAME = PlaceId}
		end
	end	
	refreshwaypoints()
	updatesaves()
end)

addcmd('waypointpos',{'wpp','setwaypointposition','setpos','setwaypoint','setwaypointpos'},function(args, speaker)
	local WPName = tostring(getstring(1, args))
	if getRoot(speaker.Character) then
		notify('Modified Waypoints',"Created waypoint: "..getstring(1, args))
		WayPoints[#WayPoints + 1] = {NAME = WPName, COORD = {args[2], args[3], args[4]}, GAME = PlaceId}
		if AllWaypoints ~= nil then
			AllWaypoints[#AllWaypoints + 1] = {NAME = WPName, COORD = {args[2], args[3], args[4]}, GAME = PlaceId}
		end
	end	
	refreshwaypoints()
	updatesaves()
end)

addcmd('waypoints',{'positions'},function(args, speaker)
	if SettingsOpen == false then SettingsOpen = true
		Settings:TweenPosition(UDim2.new(0, 0, 0, 45), "InOut", "Quart", 0.5, true, nil)
		CMDsF.Visible = false
	end
	KeybindsFrame:TweenPosition(UDim2.new(0, 0, 0, 175), "InOut", "Quart", 0.5, true, nil)
	AliasesFrame:TweenPosition(UDim2.new(0, 0, 0, 175), "InOut", "Quart", 0.5, true, nil)
	PluginsFrame:TweenPosition(UDim2.new(0, 0, 0, 175), "InOut", "Quart", 0.5, true, nil)
	PositionsFrame:TweenPosition(UDim2.new(0, 0, 0, 0), "InOut", "Quart", 0.5, true, nil)
	wait(0.5)
	SettingsHolder.Visible = false
	maximizeHolder()
end)

waypointParts = {}
addcmd('showwaypoints',{'showwp','showwps'},function(args, speaker)
	execCmd('hidewaypoints')
	wait()
	for i,_ in pairs(WayPoints) do
		local x = WayPoints[i].COORD[1]
		local y = WayPoints[i].COORD[2]
		local z = WayPoints[i].COORD[3]
		local part = Instance.new("Part")
		part.Size = Vector3.new(5,5,5)
		part.CFrame = CFrame.new(x,y,z)
		part.Parent = workspace
		part.Anchored = true
		part.CanCollide = false
		table.insert(waypointParts,part)
		local view = Instance.new("BoxHandleAdornment")
		view.Adornee = part
		view.AlwaysOnTop = true
		view.ZIndex = 10
		view.Size = part.Size
		view.Parent = part
	end
	for i,v in pairs(pWayPoints) do
		local view = Instance.new("BoxHandleAdornment")
		view.Adornee = pWayPoints[i].COORD[1]
		view.AlwaysOnTop = true
		view.ZIndex = 10
		view.Size = pWayPoints[i].COORD[1].Size
		view.Parent = pWayPoints[i].COORD[1]
		table.insert(waypointParts,view)
	end
end)

addcmd('hidewaypoints',{'hidewp','hidewps'},function(args, speaker)
	for i,v in pairs(waypointParts) do
		v:Destroy()
	end
	waypointParts = {}
end)

addcmd('waypoint',{'wp','lpos','loadposition','loadpos'},function(args, speaker)
	local WPName = tostring(getstring(1, args))
	if speaker.Character then
		for i,_ in pairs(WayPoints) do
			if tostring(WayPoints[i].NAME):lower() == tostring(WPName):lower() then
				local x = WayPoints[i].COORD[1]
				local y = WayPoints[i].COORD[2]
				local z = WayPoints[i].COORD[3]
				getRoot(speaker.Character).CFrame = CFrame.new(x,y,z)
			end
		end
		for i,_ in pairs(pWayPoints) do
			if tostring(pWayPoints[i].NAME):lower() == tostring(WPName):lower() then
				getRoot(speaker.Character).CFrame = CFrame.new(pWayPoints[i].COORD[1].Position)
			end
		end
	end
end)

tweenSpeed = 1
addcmd('tweenspeed',{'tspeed'},function(args, speaker)
	local newSpeed = args[1] or 1
	if tonumber(newSpeed) then
		tweenSpeed = tonumber(newSpeed)
	end
end)

addcmd('tweenwaypoint',{'twp'},function(args, speaker)
	local WPName = tostring(getstring(1, args))
	if speaker.Character then
		for i,_ in pairs(WayPoints) do
			local x = WayPoints[i].COORD[1]
			local y = WayPoints[i].COORD[2]
			local z = WayPoints[i].COORD[3]
			if tostring(WayPoints[i].NAME):lower() == tostring(WPName):lower() then
				TweenService:Create(getRoot(speaker.Character), TweenInfo.new(tweenSpeed, Enum.EasingStyle.Linear), {CFrame = CFrame.new(x,y,z)}):Play()
			end
		end
		for i,_ in pairs(pWayPoints) do
			if tostring(pWayPoints[i].NAME):lower() == tostring(WPName):lower() then
				TweenService:Create(getRoot(speaker.Character), TweenInfo.new(tweenSpeed, Enum.EasingStyle.Linear), {CFrame = CFrame.new(pWayPoints[i].COORD[1].Position)}):Play()
			end
		end
	end
end)

addcmd('walktowaypoint',{'wtwp'},function(args, speaker)
	local WPName = tostring(getstring(1, args))
	if speaker.Character then
		for i,_ in pairs(WayPoints) do
			local x = WayPoints[i].COORD[1]
			local y = WayPoints[i].COORD[2]
			local z = WayPoints[i].COORD[3]
			if tostring(WayPoints[i].NAME):lower() == tostring(WPName):lower() then
				if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
					speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
					wait(.1)
				end
				speaker.Character:FindFirstChildOfClass('Humanoid').WalkToPoint = Vector3.new(x,y,z)
			end
		end
		for i,_ in pairs(pWayPoints) do
			if tostring(pWayPoints[i].NAME):lower() == tostring(WPName):lower() then
				if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
					speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
					wait(.1)
				end
				speaker.Character:FindFirstChildOfClass('Humanoid').WalkToPoint = Vector3.new(pWayPoints[i].COORD[1].Position)
			end
		end
	end
end)

addcmd('deletewaypoint',{'dwp','dpos','deleteposition','deletepos'},function(args, speaker)
	for i,v in pairs(WayPoints) do
		if v.NAME:lower() == tostring(getstring(1, args)):lower() then
			notify('Modified Waypoints',"Deleted waypoint: " .. v.NAME)
			table.remove(WayPoints, i)
		end
	end
	if AllWaypoints ~= nil and #AllWaypoints > 0 then
		for i,v in pairs(AllWaypoints) do
			if v.NAME:lower() == tostring(getstring(1, args)):lower() then
				if not v.GAME or v.GAME == PlaceId then
					table.remove(AllWaypoints, i)
				end
			end
		end
	end
	for i,v in pairs(pWayPoints) do
		if v.NAME:lower() == tostring(getstring(1, args)):lower() then
			notify('Modified Waypoints',"Deleted waypoint: " .. v.NAME)
			table.remove(pWayPoints, i)
		end
	end
	refreshwaypoints()
	updatesaves()
end)

addcmd('clearwaypoints',{'cwp','clearpositions','cpos','clearpos'},function(args, speaker)
	WayPoints = {}
	pWayPoints = {}
	refreshwaypoints()
	updatesaves()
	AllWaypoints = {}
	notify('Modified Waypoints','Removed all waypoints')
end)

addcmd('cleargamewaypoints',{'cgamewp'},function(args, speaker)
	for i,v in pairs(WayPoints) do
		if v.GAME == PlaceId then
			table.remove(WayPoints, i)
		end
	end
	if AllWaypoints ~= nil and #AllWaypoints > 0 then
		for i,v in pairs(AllWaypoints) do
			if v.GAME == PlaceId then
				table.remove(AllWaypoints, i)
			end
		end
	end
	for i,v in pairs(pWayPoints) do
		if v.GAME == PlaceId then
			table.remove(pWayPoints, i)
		end
	end
	refreshwaypoints()
	updatesaves()
	notify('Modified Waypoints','Deleted game waypoints')
end)


local coreGuiTypeNames = {
	-- predefined aliases
	["inventory"] = Enum.CoreGuiType.Backpack,
	["leaderboard"] = Enum.CoreGuiType.PlayerList,
	["emotes"] = Enum.CoreGuiType.EmotesMenu
}

-- Load the full list of enums
for _, enumItem in ipairs(Enum.CoreGuiType:GetEnumItems()) do
	coreGuiTypeNames[enumItem.Name:lower()] = enumItem
end

addcmd('enable',{},function(args, speaker)
	local input = args[1] and args[1]:lower()
	if input then
		if input == "reset" then
			StarterGui:SetCore("ResetButtonCallback", true)
		else
			local coreGuiType = coreGuiTypeNames[input]
			if coreGuiType then
				StarterGui:SetCoreGuiEnabled(coreGuiType, true)
			end
		end
	end
end)

addcmd('disable',{},function(args, speaker)
	local input = args[1] and args[1]:lower()
	if input then
		if input == "reset" then
			StarterGui:SetCore("ResetButtonCallback", false)
		else
			local coreGuiType = coreGuiTypeNames[input]
			if coreGuiType then
				StarterGui:SetCoreGuiEnabled(coreGuiType, false)
			end
		end
	end
end)


local invisGUIS = {}
addcmd('showguis',{},function(args, speaker)
	for i,v in pairs(PlayerGui:GetDescendants()) do
		if (v:IsA("Frame") or v:IsA("ImageLabel") or v:IsA("ScrollingFrame")) and not v.Visible then
			v.Visible = true
			if not FindInTable(invisGUIS,v) then
				table.insert(invisGUIS,v)
			end
		end
	end
end)

addcmd('unshowguis',{},function(args, speaker)
	for i,v in pairs(invisGUIS) do
		v.Visible = false
	end
	invisGUIS = {}
end)

local hiddenGUIS = {}
addcmd('hideguis',{},function(args, speaker)
	for i,v in pairs(PlayerGui:GetDescendants()) do
		if (v:IsA("Frame") or v:IsA("ImageLabel") or v:IsA("ScrollingFrame")) and v.Visible then
			v.Visible = false
			if not FindInTable(hiddenGUIS,v) then
				table.insert(hiddenGUIS,v)
			end
		end
	end
end)

addcmd('unhideguis',{},function(args, speaker)
	for i,v in pairs(hiddenGUIS) do
		v.Visible = true
	end
	hiddenGUIS = {}
end)

function deleteGuisAtPos()
	pcall(function()
		local guisAtPosition = PlayerGui:GetGuiObjectsAtPosition(IYMouse.X, IYMouse.Y)
		for _, gui in pairs(guisAtPosition) do
			if gui.Visible == true then
				gui:Destroy()
			end
		end
	end)
end

local deleteGuiInput
addcmd('guidelete',{},function(args, speaker)
	deleteGuiInput = UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
		if not gameProcessedEvent then
			if input.KeyCode == Enum.KeyCode.Backspace then
				deleteGuisAtPos()
			end
		end
	end)
	notify('GUI Delete Enabled','Hover over a GUI and press backspace to delete it')
end)

addcmd('unguidelete',{'noguidelete'},function(args, speaker)
	if deleteGuiInput then deleteGuiInput:Disconnect() end
	notify('GUI Delete Disabled','GUI backspace delete has been disabled')
end)

local wasStayOpen = StayOpen
addcmd('hideiy',{},function(args, speaker)
	isHidden = true
	wasStayOpen = StayOpen
	if StayOpen == true then
		StayOpen = false
		On.BackgroundTransparency = 1
	end
	minimizeNum = 0
	minimizeHolder()
	if not (args[1] and tostring(args[1]) == 'nonotify') then notify('IY Hidden','You can press the prefix key to access the command bar') end
end)

addcmd('showiy',{'unhideiy'},function(args, speaker)
	isHidden = false
	minimizeNum = -20
	if wasStayOpen then
		maximizeHolder()
		StayOpen = true
		On.BackgroundTransparency = 0
	else
		minimizeHolder()
	end
end)

addcmd('rec', {'record'}, function(args, speaker)
	return COREGUI:ToggleRecording()
end)

addcmd('screenshot', {'scrnshot'}, function(args, speaker)
	return COREGUI:TakeScreenshot()
end)

addcmd('togglefs', {'togglefullscreen'}, function(args, speaker)
	return GuiService:ToggleFullscreen()
end)

addcmd('inspect', {'examine'}, function(args, speaker)
	for _, v in ipairs(getPlayer(args[1], speaker)) do
		GuiService:CloseInspectMenu()
		GuiService:InspectPlayerFromUserId(Players[v].UserId)
	end
end)

addcmd("savegame", {"saveplace"}, function(args, speaker)
	if saveinstance then
		notify("Loading", "Downloading game. This will take a while")
		saveinstance()
		notify("Game Saved", "Saved place to the workspace folder within your exploit folder.")
	else
		notify("Incompatible Exploit", "Your exploit does not support this command (missing saveinstance)")
	end
end)

addcmd("clearerror", {"clearerrors"}, function(args, speaker)
    GuiService:ClearError()
end)

addcmd("antigameplaypaused", {}, function(args, speaker)
    pcall(function() networkPaused:Disconnect() end)
    networkPaused = COREGUI.RobloxGui.ChildAdded:Connect(function(obj)
        if obj.Name == "CoreScripts/NetworkPause" then
            obj:Destroy()
        end
    end)
    COREGUI.RobloxGui["CoreScripts/NetworkPause"]:Destroy()
end)

addcmd("unantigameplaypaused", {}, function(args, speaker)
    networkPaused:Disconnect()
end)

addcmd('clientantikick',{'antikick'},function(args, speaker)
	if not hookmetamethod then 
		return notify('Incompatible Exploit','Your exploit does not support this command (missing hookmetamethod)')
	end
	local LocalPlayer = Players.LocalPlayer
	local oldNamecall; oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(...)
    	local method = getnamecallmethod and getnamecallmethod() or ""
    	if select(1, ...) == LocalPlayer and method == "Kick" or method == "kick" then
        	return nil
    	end
    	return oldNamecall(...)
	end))
	hookfunction(LocalPlayer.Kick, newcclosure(function(self, _)
    	if self ~= lp then
        	error("Expected ':' not '.' calling member function Kick", 2)
    	end
    	return nil
	end))

	notify('Client Antikick','Client anti kick is now active (only effective on localscript kick)')
end)

allow_rj = true
addcmd('clientantiteleport',{'antiteleport'},function(args, speaker)
	if not hookmetamethod then 
		return notify('Incompatible Exploit','Your exploit does not support this command (missing hookmetamethod)')
	end

	local oldTp; oldTp = hookfunction(TeleportService.Teleport, newcclosure(function(self, placeId, player, _teleportData, customLoadingScreen)
		if checkcaller() or (allow_rj and placeId == game.PlaceId) then
			return oldTp(self, placeId, player, _teleportData, customLoadingScreen)
		end
		if self ~= TeleportService then
			error("Expected ':' not '.' calling member function Teleport", 2)
		end
		if placeId == nil then
			error("Argument 1 missing or nil", 2)
		end
		if typeof(placeId) ~= "number" and placeId ~= true then
			error(`Unable to cast {typeof(placeId)} to int64`, 2)
		elseif placeId == true then
			-- somehow raise raiseTeleportInitFailedEvent
			return
		end
		if typeof(customLoadingScreen) ~= "Instance" and customLoadingScreen ~= nil then
			error("Unable to cast value to Object", 2)
		end
		return nil
	end))
	hookfunction(TeleportService.TeleportAsync, newcclosure(function(self, placeId, players, teleportOptions)
		if self ~= TeleportService then
			error("Expected ':' not '.' calling member function TeleportAsync", 2)
		end
		if players == nil then
			error("Argument 2 missing or nil", 2)
		end
		if typeof(players) ~= "table" then
			error("Unable to cast value to Objects", 2)
		end
		error("TeleportUnknown must be called from a Server", 2)
	end))
	local oldNamecall; oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(...)
		local nmc = getnamecallmethod()
		if select(1, ...) == TeleportService and nmc == "teleport" or nmc == "Teleport" or nmc == "TeleportToPlaceInstance" or nmc == "TeleportAsync" then
			if checkcaller() or (allow_rj and select(2, ...) == game.PlaceId) then
				return oldNamecall(...)
			end
			return
		end
		return oldNamecall(...)
	end))

	notify('Client AntiTP','Client anti teleport is now active (only effective on localscript teleport)')
end)

addcmd('allowrejoin',{'allowrj'},function(args, speaker)
	allow_rj = not allow_rj
	notify("Client AntiTP", `Scripts now may{allow_rj and "" or " not"} make you rejoin the server`)
end)

addcmd("cancelteleport", {"canceltp"}, function(args, speaker)
	TeleportService:TeleportCancel()
end)

addcmd("volume",{ "vol"}, function(args, speaker)
	UserSettings():GetService("UserGameSettings").MasterVolume = args[1]/10
end)

addcmd("antilag", {"boostfps", "lowgraphics"}, function(args, speaker)
	local Terrain = workspace:FindFirstChildWhichIsA("Terrain")
	Terrain.WaterWaveSize = 0
	Terrain.WaterWaveSpeed = 0
	Terrain.WaterReflectance = 0
	Terrain.WaterTransparency = 1
	Lighting.GlobalShadows = false
	Lighting.FogEnd = 9e9
	Lighting.FogStart = 9e9
	settings().Rendering.QualityLevel = 1
	for _, v in pairs(game:GetDescendants()) do
		if v:IsA("BasePart") then
			v.CastShadow = false
			v.Material = "Plastic"
			v.Reflectance = 0
			v.BackSurface = "SmoothNoOutlines"
			v.BottomSurface = "SmoothNoOutlines"
			v.FrontSurface = "SmoothNoOutlines"
			v.LeftSurface = "SmoothNoOutlines"
			v.RightSurface = "SmoothNoOutlines"
			v.TopSurface = "SmoothNoOutlines"
		elseif v:IsA("Decal") then
			v.Transparency = 1
			v.Texture = ""
		elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
			v.Lifetime = NumberRange.new(0)
		end
	end
	for _, v in pairs(Lighting:GetDescendants()) do
		if v:IsA("PostEffect") then
			v.Enabled = false
		end
	end
	workspace.DescendantAdded:Connect(function(child)
		task.spawn(function()
			if child:IsA("ForceField") or child:IsA("Sparkles") or child:IsA("Smoke") or child:IsA("Fire") or child:IsA("Beam") then
				RunService.Heartbeat:Wait()
				child:Destroy()
			elseif child:IsA("BasePart") then
				child.CastShadow = false
			end
		end)
	end)
end)

addcmd("setfpscap", {"fpscap", "maxfps"}, function(args, speaker)
	if fpscaploop then
		task.cancel(fpscaploop)
		fpscaploop = nil
	end

	local fpsCap = 60
	local num = tonumber(args[1]) or 1e6
	if num == "none" then
		return
	elseif num > 0 then
		fpsCap = num
	else
		return notify("Invalid argument", "Please provide a number above 0 or 'none'.")
	end

	if setfpscap and type(setfpscap) == "function" then
		setfpscap(fpsCap)
	else
		fpscaploop = task.spawn(function()
			local timer = os.clock()
			while true do
				if os.clock() >= timer + 1 / fpsCap then
					timer = os.clock()
					task.wait()
				end
			end
		end)
	end
end)

addcmd('notify',{},function(args, speaker)
	notify(getstring(1, args))
end)

addcmd('lastcommand',{'lastcmd'},function(args, speaker)
	if cmdHistory[1]:sub(1,11) ~= 'lastcommand' and cmdHistory[1]:sub(1,7) ~= 'lastcmd' then
		execCmd(cmdHistory[1])
	end
end)

addcmd('esp',{},function(args, speaker)
	if not CHMSenabled then
		ESPenabled = true
		for i,v in pairs(Players:GetPlayers()) do
			if v.Name ~= speaker.Name then
				ESP(v)
			end
		end
	else
		notify('ESP','Disable chams (nochams) before using esp')
	end
end)

addcmd('espteam',{},function(args, speaker)
	if not CHMSenabled then
		ESPenabled = true
		for i,v in pairs(Players:GetPlayers()) do
			if v.Name ~= speaker.Name then
				ESP(v, true)
			end
		end
	else
		notify('ESP','Disable chams (nochams) before using esp')
	end
end)

addcmd('noesp',{'unesp','unespteam'},function(args, speaker)
	ESPenabled = false
	for i,c in pairs(COREGUI:GetChildren()) do
		if string.sub(c.Name, -4) == '_ESP' then
			c:Destroy()
		end
	end
end)

addcmd("esptransparency", {}, function(args, speaker)
    espTransparency = tonumber(args[1]) or 0.3
    if ESPenabled then execCmd("esp") end
    if CHMSenabled then execCmd("chams") end
    updatesaves()
end)

local espParts = {}
local partEspTrigger = nil
function partAdded(part)
	if #espParts > 0 then
		if FindInTable(espParts,part.Name:lower()) then
			local a = Instance.new("BoxHandleAdornment")
			a.Name = part.Name:lower().."_PESP"
			a.Parent = part
			a.Adornee = part
			a.AlwaysOnTop = true
			a.ZIndex = 0
			a.Size = part.Size
			a.Transparency = espTransparency
			a.Color = BrickColor.new("Lime green")
		end
	else
		partEspTrigger:Disconnect()
		partEspTrigger = nil
	end
end

addcmd('partesp',{},function(args, speaker)
	local partEspName = getstring(1, args):lower()
	if not FindInTable(espParts,partEspName) then
		table.insert(espParts,partEspName)
		for i,v in pairs(workspace:GetDescendants()) do
			if v:IsA("BasePart") and v.Name:lower() == partEspName then
				local a = Instance.new("BoxHandleAdornment")
				a.Name = partEspName.."_PESP"
				a.Parent = v
				a.Adornee = v
				a.AlwaysOnTop = true
				a.ZIndex = 0
				a.Size = v.Size
				a.Transparency = espTransparency
				a.Color = BrickColor.new("Lime green")
			end
		end
	end
	if partEspTrigger == nil then
		partEspTrigger = workspace.DescendantAdded:Connect(partAdded)
	end
end)

addcmd('unpartesp',{'nopartesp'},function(args, speaker)
	if args[1] then
		local partEspName = getstring(1, args):lower()
		if FindInTable(espParts,partEspName) then
			table.remove(espParts, GetInTable(espParts, partEspName))
		end
		for i,v in pairs(workspace:GetDescendants()) do
			if v:IsA("BoxHandleAdornment") and v.Name == partEspName..'_PESP' then
				v:Destroy()
			end
		end
	else
		partEspTrigger:Disconnect()
		partEspTrigger = nil
		espParts = {}
		for i,v in pairs(workspace:GetDescendants()) do
			if v:IsA("BoxHandleAdornment") and v.Name:sub(-5) == '_PESP' then
				v:Destroy()
			end
		end
	end
end)

addcmd('chams',{},function(args, speaker)
	if not ESPenabled then
		CHMSenabled = true
		for i,v in pairs(Players:GetPlayers()) do
			if v.Name ~= speaker.Name then
				CHMS(v)
			end
		end
	else
		notify('Chams','Disable ESP (noesp) before using chams')
	end
end)

addcmd('nochams',{'unchams'},function(args, speaker)
	CHMSenabled = false
	for i,v in pairs(Players:GetPlayers()) do
		local chmsplr = v
		for i,c in pairs(COREGUI:GetChildren()) do
			if c.Name == chmsplr.Name..'_CHMS' then
				c:Destroy()
			end
		end
	end
end)

addcmd('locate',{},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players) do
		Locate(Players[v])
	end
end)

addcmd('nolocate',{'unlocate'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	if args[1] then
		for i,v in pairs(players) do
			for i,c in pairs(COREGUI:GetChildren()) do
				if c.Name == Players[v].Name..'_LC' then
					c:Destroy()
				end
			end
		end
	else
		for i,c in pairs(COREGUI:GetChildren()) do
			if string.sub(c.Name, -3) == '_LC' then
				c:Destroy()
			end
		end
	end
end)

viewing = nil
addcmd('view',{'spectate'},function(args, speaker)
	StopFreecam()
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players) do
		if viewDied then
			viewDied:Disconnect()
			viewChanged:Disconnect()
		end
		viewing = Players[v]
		workspace.CurrentCamera.CameraSubject = viewing.Character
		notify('Spectate','Viewing ' .. Players[v].Name)
		local function viewDiedFunc()
			repeat wait() until Players[v].Character ~= nil and getRoot(Players[v].Character)
			workspace.CurrentCamera.CameraSubject = viewing.Character
		end
		viewDied = Players[v].CharacterAdded:Connect(viewDiedFunc)
		local function viewChangedFunc()
			workspace.CurrentCamera.CameraSubject = viewing.Character
		end
		viewChanged = workspace.CurrentCamera:GetPropertyChangedSignal("CameraSubject"):Connect(viewChangedFunc)
	end
end)

addcmd('viewpart',{'viewp'},function(args, speaker)
	StopFreecam()
	if args[1] then
		for i,v in pairs(workspace:GetDescendants()) do
			if v.Name:lower() == getstring(1, args):lower() and v:IsA("BasePart") then
				wait(0.1)
				workspace.CurrentCamera.CameraSubject = v
			end
		end
	end
end)

addcmd('unview',{'unspectate'},function(args, speaker)
	StopFreecam()
	if viewing ~= nil then
		viewing = nil
		notify('Spectate','View turned off')
	end
	if viewDied then
		viewDied:Disconnect()
		viewChanged:Disconnect()
	end
	workspace.CurrentCamera.CameraSubject = speaker.Character
end)


fcRunning = false
local Camera = workspace.CurrentCamera
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	local newCamera = workspace.CurrentCamera
	if newCamera then
		Camera = newCamera
	end
end)

local INPUT_PRIORITY = Enum.ContextActionPriority.High.Value

Spring = {} do
	Spring.__index = Spring

	function Spring.new(freq, pos)
		local self = setmetatable({}, Spring)
		self.f = freq
		self.p = pos
		self.v = pos*0
		return self
	end

	function Spring:Update(dt, goal)
		local f = self.f*2*math.pi
		local p0 = self.p
		local v0 = self.v

		local offset = goal - p0
		local decay = math.exp(-f*dt)

		local p1 = goal + (v0*dt - offset*(f*dt + 1))*decay
		local v1 = (f*dt*(offset*f - v0) + v0)*decay

		self.p = p1
		self.v = v1

		return p1
	end

	function Spring:Reset(pos)
		self.p = pos
		self.v = pos*0
	end
end

local cameraPos = Vector3.new()
local cameraRot = Vector2.new()

local velSpring = Spring.new(5, Vector3.new())
local panSpring = Spring.new(5, Vector2.new())

Input = {} do

	keyboard = {
		W = 0,
		A = 0,
		S = 0,
		D = 0,
		E = 0,
		Q = 0,
		Up = 0,
		Down = 0,
		LeftShift = 0,
	}

	mouse = {
		Delta = Vector2.new(),
	}

	NAV_KEYBOARD_SPEED = Vector3.new(1, 1, 1)
	PAN_MOUSE_SPEED = Vector2.new(1, 1)*(math.pi/64)
	NAV_ADJ_SPEED = 0.75
	NAV_SHIFT_MUL = 0.25

	navSpeed = 1

	function Input.Vel(dt)
		navSpeed = math.clamp(navSpeed + dt*(keyboard.Up - keyboard.Down)*NAV_ADJ_SPEED, 0.01, 4)

		local kKeyboard = Vector3.new(
			keyboard.D - keyboard.A,
			keyboard.E - keyboard.Q,
			keyboard.S - keyboard.W
		)*NAV_KEYBOARD_SPEED

		local shift = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)

		return (kKeyboard)*(navSpeed*(shift and NAV_SHIFT_MUL or 1))
	end

	function Input.Pan(dt)
		local kMouse = mouse.Delta*PAN_MOUSE_SPEED
		mouse.Delta = Vector2.new()
		return kMouse
	end

	do
		function Keypress(action, state, input)
			keyboard[input.KeyCode.Name] = state == Enum.UserInputState.Begin and 1 or 0
			return Enum.ContextActionResult.Sink
		end

		function MousePan(action, state, input)
			local delta = input.Delta
			mouse.Delta = Vector2.new(-delta.y, -delta.x)
			return Enum.ContextActionResult.Sink
		end

		function Zero(t)
			for k, v in pairs(t) do
				t[k] = v*0
			end
		end

		function Input.StartCapture()
			ContextActionService:BindActionAtPriority("FreecamKeyboard",Keypress,false,INPUT_PRIORITY,
				Enum.KeyCode.W,
				Enum.KeyCode.A,
				Enum.KeyCode.S,
				Enum.KeyCode.D,
				Enum.KeyCode.E,
				Enum.KeyCode.Q,
				Enum.KeyCode.Up,
				Enum.KeyCode.Down
			)
			ContextActionService:BindActionAtPriority("FreecamMousePan",MousePan,false,INPUT_PRIORITY,Enum.UserInputType.MouseMovement)
		end

		function Input.StopCapture()
			navSpeed = 1
			Zero(keyboard)
			Zero(mouse)
			ContextActionService:UnbindAction("FreecamKeyboard")
			ContextActionService:UnbindAction("FreecamMousePan")
		end
	end
end

function GetFocusDistance(cameraFrame)
	local znear = 0.1
	local viewport = Camera.ViewportSize
	local projy = 2*math.tan(cameraFov/2)
	local projx = viewport.x/viewport.y*projy
	local fx = cameraFrame.rightVector
	local fy = cameraFrame.upVector
	local fz = cameraFrame.lookVector

	local minVect = Vector3.new()
	local minDist = 512

	for x = 0, 1, 0.5 do
		for y = 0, 1, 0.5 do
			local cx = (x - 0.5)*projx
			local cy = (y - 0.5)*projy
			local offset = fx*cx - fy*cy + fz
			local origin = cameraFrame.p + offset*znear
			local _, hit = workspace:FindPartOnRay(Ray.new(origin, offset.unit*minDist))
			local dist = (hit - origin).magnitude
			if minDist > dist then
				minDist = dist
				minVect = offset.unit
			end
		end
	end

	return fz:Dot(minVect)*minDist
end

local function StepFreecam(dt)
	local vel = velSpring:Update(dt, Input.Vel(dt))
	local pan = panSpring:Update(dt, Input.Pan(dt))

	local zoomFactor = math.sqrt(math.tan(math.rad(70/2))/math.tan(math.rad(cameraFov/2)))

	cameraRot = cameraRot + pan*Vector2.new(0.75, 1)*8*(dt/zoomFactor)
	cameraRot = Vector2.new(math.clamp(cameraRot.x, -math.rad(90), math.rad(90)), cameraRot.y%(2*math.pi))

	local cameraCFrame = CFrame.new(cameraPos)*CFrame.fromOrientation(cameraRot.x, cameraRot.y, 0)*CFrame.new(vel*Vector3.new(1, 1, 1)*64*dt)
	cameraPos = cameraCFrame.p

	Camera.CFrame = cameraCFrame
	Camera.Focus = cameraCFrame*CFrame.new(0, 0, -GetFocusDistance(cameraCFrame))
	Camera.FieldOfView = cameraFov
end

local PlayerState = {} do
	mouseBehavior = ""
	mouseIconEnabled = ""
	cameraType = ""
	cameraFocus = ""
	cameraCFrame = ""
	cameraFieldOfView = ""

	function PlayerState.Push()
		cameraFieldOfView = Camera.FieldOfView
		Camera.FieldOfView = 70

		cameraType = Camera.CameraType
		Camera.CameraType = Enum.CameraType.Custom

		cameraCFrame = Camera.CFrame
		cameraFocus = Camera.Focus

		mouseIconEnabled = UserInputService.MouseIconEnabled
		UserInputService.MouseIconEnabled = true

		mouseBehavior = UserInputService.MouseBehavior
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	end

	function PlayerState.Pop()
		Camera.FieldOfView = 70

		Camera.CameraType = cameraType
		cameraType = nil

		Camera.CFrame = cameraCFrame
		cameraCFrame = nil

		Camera.Focus = cameraFocus
		cameraFocus = nil

		UserInputService.MouseIconEnabled = mouseIconEnabled
		mouseIconEnabled = nil

		UserInputService.MouseBehavior = mouseBehavior
		mouseBehavior = nil
	end
end

function StartFreecam(pos)
	if fcRunning then
		StopFreecam()
	end
	local cameraCFrame = Camera.CFrame
	if pos then
		cameraCFrame = pos
	end
	cameraRot = Vector2.new()
	cameraPos = cameraCFrame.p
	cameraFov = Camera.FieldOfView

	velSpring:Reset(Vector3.new())
	panSpring:Reset(Vector2.new())

	PlayerState.Push()
	RunService:BindToRenderStep("Freecam", Enum.RenderPriority.Camera.Value, StepFreecam)
	Input.StartCapture()
	fcRunning = true
end

function StopFreecam()
	if not fcRunning then return end
	Input.StopCapture()
	RunService:UnbindFromRenderStep("Freecam")
	PlayerState.Pop()
	workspace.Camera.FieldOfView = 70
	fcRunning = false
end

addcmd('freecam',{'fc'},function(args, speaker)
	StartFreecam()
end)

addcmd('freecampos',{'fcpos','fcp','freecamposition','fcposition'},function(args, speaker)
	if not args[1] then return end
	local freecamPos = CFrame.new(args[1],args[2],args[3])
	StartFreecam(freecamPos)
end)

addcmd('freecamwaypoint',{'fcwp'},function(args, speaker)
	local WPName = tostring(getstring(1, args))
	if speaker.Character then
		for i,_ in pairs(WayPoints) do
			local x = WayPoints[i].COORD[1]
			local y = WayPoints[i].COORD[2]
			local z = WayPoints[i].COORD[3]
			if tostring(WayPoints[i].NAME):lower() == tostring(WPName):lower() then
				StartFreecam(CFrame.new(x,y,z))
			end
		end
		for i,_ in pairs(pWayPoints) do
			if tostring(pWayPoints[i].NAME):lower() == tostring(WPName):lower() then
				StartFreecam(CFrame.new(pWayPoints[i].COORD[1].Position))
			end
		end
	end
end)

addcmd('freecamgoto',{'fcgoto','freecamtp','fctp'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players) do
		StartFreecam(getRoot(Players[v].Character).CFrame)
	end
end)

addcmd('unfreecam',{'nofreecam','unfc','nofc'},function(args, speaker)
	StopFreecam()
end)

addcmd('freecamspeed',{'fcspeed'},function(args, speaker)
	local FCspeed = args[1] or 1
	if isNumber(FCspeed) then
		NAV_KEYBOARD_SPEED = Vector3.new(FCspeed, FCspeed, FCspeed)
	end
end)

addcmd('notifyfreecamposition',{'notifyfcpos'},function(args, speaker)
	if fcRunning then
		local X,Y,Z = workspace.CurrentCamera.CFrame.Position.X,workspace.CurrentCamera.CFrame.Position.Y,workspace.CurrentCamera.CFrame.Position.Z
		local Format, Round = string.format, math.round
		notify("Current Position", Format("%s, %s, %s", Round(X), Round(Y), Round(Z)))
	end
end)

addcmd('copyfreecamposition',{'copyfcpos'},function(args, speaker)
	if fcRunning then
		local X,Y,Z = workspace.CurrentCamera.CFrame.Position.X,workspace.CurrentCamera.CFrame.Position.Y,workspace.CurrentCamera.CFrame.Position.Z
		local Format, Round = string.format, math.round
		toClipboard(Format("%s, %s, %s", Round(X), Round(Y), Round(Z)))
	end
end)

addcmd('gotocamera',{'gotocam','tocam'},function(args, speaker)
	getRoot(speaker.Character).CFrame = workspace.Camera.CFrame
end)

addcmd('tweengotocamera',{'tweengotocam','tgotocam','ttocam'},function(args, speaker)
	TweenService:Create(getRoot(speaker.Character), TweenInfo.new(tweenSpeed, Enum.EasingStyle.Linear), {CFrame = workspace.Camera.CFrame}):Play()
end)

addcmd('fov',{},function(args, speaker)
	local fov = args[1] or 70
	if isNumber(fov) then
		workspace.CurrentCamera.FieldOfView = fov
	end
end)

local preMaxZoom = Players.LocalPlayer.CameraMaxZoomDistance
local preMinZoom = Players.LocalPlayer.CameraMinZoomDistance
addcmd('lookat',{},function(args, speaker)
	if speaker.CameraMaxZoomDistance ~= 0.5 then
		preMaxZoom = speaker.CameraMaxZoomDistance
		preMinZoom = speaker.CameraMinZoomDistance
	end
	speaker.CameraMaxZoomDistance = 0.5
	speaker.CameraMinZoomDistance = 0.5
	wait()
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players) do
		local target = Players[v].Character
		if target and target:FindFirstChild('Head') then
			workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.p, target.Head.CFrame.p)
			wait(0.1)
		end
	end
	speaker.CameraMaxZoomDistance = preMaxZoom
	speaker.CameraMinZoomDistance = preMinZoom
end)

addcmd('fixcam',{'restorecam'},function(args, speaker)
	StopFreecam()
	execCmd('unview')
	workspace.CurrentCamera:remove()
	wait(.1)
	repeat wait() until speaker.Character ~= nil
	workspace.CurrentCamera.CameraSubject = speaker.Character:FindFirstChildWhichIsA('Humanoid')
	workspace.CurrentCamera.CameraType = "Custom"
	speaker.CameraMinZoomDistance = 0.5
	speaker.CameraMaxZoomDistance = 400
	speaker.CameraMode = "Classic"
	speaker.Character.Head.Anchored = false
end)

addcmd("enableshiftlock", {"enablesl", "shiftlock"}, function(args, speaker)
	local function enableShiftlock() 
		speaker.DevEnableMouseLock = true 
	end
	speaker:GetPropertyChangedSignal("DevEnableMouseLock"):Connect(enableShiftlock)
	enableShiftlock()
	notify("Shiftlock", "Shift lock should now be available")
end)

addcmd('firstp',{},function(args, speaker)
	speaker.CameraMode = "LockFirstPerson"
end)

addcmd('thirdp',{},function(args, speaker)
	speaker.CameraMode = "Classic"
end)

addcmd('noclipcam', {'nccam'}, function(args, speaker)
	local sc = (debug and debug.setconstant) or setconstant
	local gc = (debug and debug.getconstants) or getconstants
	if not sc or not getgc or not gc then
		return notify('Incompatible Exploit', 'Your exploit does not support this command (missing setconstant or getconstants or getgc)')
	end
	local pop = speaker.PlayerScripts.PlayerModule.CameraModule.ZoomController.Popper
	for _, v in pairs(getgc()) do
		if type(v) == 'function' and getfenv(v).script == pop then
			for i, v1 in pairs(gc(v)) do
				if tonumber(v1) == .25 then
					sc(v, i, 0)
				elseif tonumber(v1) == 0 then
					sc(v, i, .25)
				end
			end
		end
	end
end)

addcmd('maxzoom',{},function(args, speaker)
	speaker.CameraMaxZoomDistance = args[1]
end)

addcmd('minzoom',{},function(args, speaker)
	speaker.CameraMinZoomDistance = args[1]
end)

addcmd('camdistance',{},function(args, speaker)
	local camMax = speaker.CameraMaxZoomDistance
	local camMin = speaker.CameraMinZoomDistance
	if camMax < tonumber(args[1]) then
		camMax = args[1]
	end
	speaker.CameraMaxZoomDistance = args[1]
	speaker.CameraMinZoomDistance = args[1]
	wait()
	speaker.CameraMaxZoomDistance = camMax
	speaker.CameraMinZoomDistance = camMin
end)

addcmd('unlockws',{'unlockworkspace'},function(args, speaker)
	for i,v in pairs(workspace:GetDescendants()) do
		if v:IsA("BasePart") then
			v.Locked = false
		end
	end
end)

addcmd('lockws',{'lockworkspace'},function(args, speaker) 
	for i,v in pairs(workspace:GetDescendants()) do
		if v:IsA("BasePart") then
			v.Locked = true
		end
	end
end)

addcmd('delete',{'remove'},function(args, speaker)
	for i,v in pairs(workspace:GetDescendants()) do
		if v.Name:lower() == getstring(1, args):lower() then
			v:Destroy()
		end
	end
	notify('Item(s) Deleted','Deleted ' ..getstring(1, args))
end)

addcmd('deleteclass',{'removeclass','deleteclassname','removeclassname','dc'},function(args, speaker)
	for i,v in pairs(workspace:GetDescendants()) do
		if v.ClassName:lower() == getstring(1, args):lower() then
			v:Destroy()
		end
	end
	notify('Item(s) Deleted','Deleted items with ClassName ' ..getstring(1, args))
end)

addcmd('chardelete',{'charremove','cd'},function(args, speaker)
	for i,v in pairs(speaker.Character:GetDescendants()) do
		if v.Name:lower() == getstring(1, args):lower() then
			v:Destroy()
		end
	end
	notify('Item(s) Deleted','Deleted ' ..getstring(1, args))
end)

addcmd('chardeleteclass',{'charremoveclass','chardeleteclassname','charremoveclassname','cdc'},function(args, speaker)
	for i,v in pairs(speaker.Character:GetDescendants()) do
		if v.ClassName:lower() == getstring(1, args):lower() then
			v:Destroy()
		end
	end
	notify('Item(s) Deleted','Deleted items with ClassName ' ..getstring(1, args))
end)

addcmd('deletevelocity',{'dv','removevelocity','removeforces'},function(args, speaker)
	for i,v in pairs(speaker.Character:GetDescendants()) do
		if v:IsA("BodyVelocity") or v:IsA("BodyGyro") or v:IsA("RocketPropulsion") or v:IsA("BodyThrust") or v:IsA("BodyAngularVelocity") or v:IsA("AngularVelocity") or v:IsA("BodyForce") or v:IsA("VectorForce") or v:IsA("LineForce") then
			v:Destroy()
		end
	end
end)

addcmd('deleteinvisparts',{'deleteinvisibleparts','dip'},function(args, speaker)
	for i,v in pairs(workspace:GetDescendants()) do
		if v:IsA("BasePart") and v.Transparency == 1 and v.CanCollide then
			v:Destroy()
		end
	end
end)

local shownParts = {}
addcmd('invisibleparts',{'invisparts'},function(args, speaker)
	for i,v in pairs(workspace:GetDescendants()) do
		if v:IsA("BasePart") and v.Transparency == 1 then
			if not table.find(shownParts,v) then
				table.insert(shownParts,v)
			end
			v.Transparency = 0
		end
	end
end)

addcmd('uninvisibleparts',{'uninvisparts'},function(args, speaker)
	for i,v in pairs(shownParts) do
		v.Transparency = 1
	end
	shownParts = {}
end)

addcmd("btools", {}, function(args, speaker)
	for i = 1, 4 do
		local Tool = Instance.new("HopperBin")
		Tool.BinType = i
		Tool.Name = randomString()
		Tool.Parent = speaker:FindFirstChildWhichIsA("Backpack")
	end
end)

addcmd("f3x", {"fex"}, function(args, speaker)
	loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/refs/heads/main/f3x.lua"))()
end)

addcmd("partpath", {"partname"}, function(args, speaker)
	selectPart()
end)

local antiAfkCon = nil
addcmd("antiafk", {"antiidle"}, function(args, speaker)
    if getconnections then
        for _, c in getconnections(speaker.Idled) do
            pcall(function() c:Disable() end) -- supposed to "pause" it
            pcall(function() c:Disconnect() end) -- supposed to disconnect it
        end
    end

    pcall(function() antiAfkCon:Disconnect() end)
    antiAfkCon = speaker.Idled:Connect(function()
        local VirtualInputManager = Instance.new("VirtualInputManager")
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        VirtualInputManager:Destroy()
    end)

    if not (args[1] and tostring(args[1]) == "nonotify") then notify("Anti Idle", "Anti idle is enabled") end
end)

addcmd("datalimit", {}, function(args, speaker)
	local kbps = tonumber(args[1])
	if kbps then
		Services.NetworkClient:SetOutgoingKBPSLimit(kbps)
	end
end)

addcmd("replicationlag", {"backtrack"}, function(args, speaker)
	if tonumber(args[1]) then
		settings():GetService("NetworkSettings").IncomingReplicationLag = args[1]
	end
end)

addcmd("noprompts", {"nopurchaseprompts"}, function(args, speaker)
	COREGUI.PurchasePromptApp.Enabled = false
end)

addcmd("showprompts", {"showpurchaseprompts"}, function(args, speaker)
	COREGUI.PurchasePromptApp.Enabled = true
end)

promptNewRig = function(speaker, rig)
	local humanoid = speaker.Character:FindFirstChildWhichIsA("Humanoid")
	if humanoid then
		AvatarEditorService:PromptSaveAvatar(humanoid.HumanoidDescription, Enum.HumanoidRigType[rig])
		local result = AvatarEditorService.PromptSaveAvatarCompleted:Wait()
		if result == Enum.AvatarPromptResult.Success then
			execCmd("reset")
		end
	end
end

addcmd("promptr6", {}, function(args, speaker)
	promptNewRig(speaker, "R6")
end)

addcmd("promptr15", {}, function(args, speaker)
	promptNewRig(speaker, "R15")
end)

addcmd("wallwalk", {"walkonwalls"}, function(args, speaker)
	loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/wallwalker.lua"))()
end)

addcmd('age',{},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	local ages = {}
	for i,v in pairs(players) do
		local p = Players[v]
		table.insert(ages, p.Name.."'s age is: "..p.AccountAge)
	end
	notify('Account Age',table.concat(ages, ',\n'))
end)

addcmd('chatage',{},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	local ages = {}
	for i,v in pairs(players) do
		local p = Players[v]
		table.insert(ages, p.Name.."'s age is: "..p.AccountAge)
	end
	local chatString = table.concat(ages, ', ')
	chatMessage(chatString)
end)

addcmd('joindate',{'jd'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	local dates = {}
	for i,v in pairs(players) do
		local p = Players[v]

		local secondsOld = p.AccountAge * 24 * 60 * 60
		local now = os.time()
		local dateJoined  = p.Name .. " joined: " .. os.date("%m/%d/%y", now - secondsOld)

		table.insert(dates, dateJoined)
	end
	notify('Join Date (Month/Day/Year)',table.concat(dates, ',\n'))
end)

addcmd('chatjoindate',{'cjd'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	local dates = {}
	for i,v in pairs(players) do
		local p = Players[v]

		local secondsOld = p.AccountAge * 24 * 60 * 60
		local now = os.time()
		local dateJoined  = p.Name .. " joined: " .. os.date("%m/%d/%y", now - secondsOld)

		table.insert(dates, dateJoined)
	end
	local chatString = table.concat(dates, ', ')
	chatMessage(chatString)
end)

addcmd('copyname',{'copyuser'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players) do
		local name = tostring(Players[v].Name)
		toClipboard(name)
	end
end)

addcmd('userid',{'id'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players) do
		local id = tostring(Players[v].UserId)
		notify('User ID',id)
	end
end)

addcmd("copyplaceid", {"placeid"}, function(args, speaker)
	toClipboard(PlaceId)
end)

addcmd("copygameid", {"gameid"}, function(args, speaker)
	toClipboard(game.GameId)
end)

addcmd('copyid',{'copyuserid'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players) do
		local id = tostring(Players[v].UserId)
		toClipboard(id)
	end
end)

addcmd('creatorid',{'creator'},function(args, speaker)
	if game.CreatorType == Enum.CreatorType.User then
		notify('Creator ID',game.CreatorId)
	elseif game.CreatorType == Enum.CreatorType.Group then
		local OwnerID = GroupService:GetGroupInfoAsync(game.CreatorId).Owner.Id
		speaker.UserId = OwnerID
		notify('Creator ID',OwnerID)
	end
end)

addcmd('copycreatorid',{'copycreator'},function(args, speaker)
	if game.CreatorType == Enum.CreatorType.User then
		toClipboard(game.CreatorId)
		notify('Copied ID','Copied creator ID to clipboard')
	elseif game.CreatorType == Enum.CreatorType.Group then
		local OwnerID = GroupService:GetGroupInfoAsync(game.CreatorId).Owner.Id
		toClipboard(OwnerID)
		notify('Copied ID','Copied creator ID to clipboard')
	end
end)

addcmd('setcreatorid',{'setcreator'},function(args, speaker)
	if game.CreatorType == Enum.CreatorType.User then
		speaker.UserId = game.CreatorId
		notify('Set ID','Set UserId to '..game.CreatorId)
	elseif game.CreatorType == Enum.CreatorType.Group then
		local OwnerID = GroupService:GetGroupInfoAsync(game.CreatorId).Owner.Id
		speaker.UserId = OwnerID
		notify('Set ID','Set UserId to '..OwnerID)
	end
end)

addcmd('appearanceid',{'aid'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players) do
		local aid = tostring(Players[v].CharacterAppearanceId)
		notify('Appearance ID',aid)
	end
end)

addcmd('copyappearanceid',{'caid'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players) do
		local aid = tostring(Players[v].CharacterAppearanceId)
		toClipboard(aid)
	end
end)

addcmd('norender',{},function(args, speaker)
	RunService:Set3dRenderingEnabled(false)
end)

addcmd('render',{},function(args, speaker)
	RunService:Set3dRenderingEnabled(true)
end)

addcmd('2022materials',{'use2022materials'},function(args, speaker)
	if sethidden then
		sethidden(MaterialService, "Use2022Materials", true)
	else
		notify('Incompatible Exploit','Your exploit does not support this command (missing sethiddenproperty)')
	end
end)

addcmd('un2022materials',{'unuse2022materials'},function(args, speaker)
	if sethidden then
		sethidden(MaterialService, "Use2022Materials", false)
	else
		notify('Incompatible Exploit','Your exploit does not support this command (missing sethiddenproperty)')
	end
end)

addcmd("goto", {"to"}, function(args, speaker)
	local character = speaker and speaker.Character
	local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
	if humanoid == nil then return end

	if humanoid and humanoid.SeatPart then
		humanoid.Sit = false
		task.wait(0.1)
	end

	local waitForStream = parseBoolean(args[2], false)
	for _, name in getPlayer(args[1], speaker) do
		local targetCharacter = Players[name].Character
		if targetCharacter ~= nil then
			local targetPivot = targetCharacter:GetPivot()
			local targetPosition = targetPivot.Position

			if waitForStream and workspace.StreamingEnabled then
				task.spawn(speaker.RequestStreamAroundAsync, speaker, targetPosition, 5)
				targetCharacter:WaitForChild("HumanoidRootPart", 5)
			end

			speaker.Character:PivotTo(CFrame.new(targetPosition + (targetPivot.LookVector * 3), targetPosition))
			breakVelocity()
			break
		end
	end
end)

addcmd("tweengoto", {"tgoto", "tto", "tweento"}, function(args, speaker)
    local character = speaker and speaker.Character
    local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")

    local oldState = humanoid and humanoid:GetStateEnabled(Enum.HumanoidStateType.Seated)
    if humanoid then humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false) end

    local players = getPlayer(args[1], speaker)
    for _, v in pairs(players) do
        if Players[v].Character ~= nil then
            if humanoid and humanoid.SeatPart then
                humanoid.Sit = false
                task.wait(0.1)
            end
            TweenService:Create(getRoot(speaker.Character), TweenInfo.new(tweenSpeed, Enum.EasingStyle.Linear), {
                CFrame = getRoot(Players[v].Character):GetPivot() + Vector3.new(3, 1, 0)
            }):Play()
        end
    end
    execCmd("breakvelocity")

    if type(oldState) == "boolean" then
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, oldState)
    end
end)

addcmd("vehiclegoto", {"vgoto", "vtp", "vehicletp"}, function(args, speaker)
    local character = speaker.Character
    local humanoid = if character then character:FindFirstChildOfClass("Humanoid") else nil
    if not humanoid then return end

    local seat = humanoid.SeatPart
    local vehicleModel = if seat then seat:FindFirstAncestorWhichIsA("Model") else nil
    if vehicleModel == nil then
        notify("Vehicle Goto", "Make sure you're sitting in a vehicle.")
        return
    end

    for _, v in getPlayer(args[1], speaker) do
        if Players[v].Character == nil then continue end

        local root = getRoot(Players[v].Character)
        if root == nil then continue end

        vehicleModel:PivotTo(root:GetPivot())
        break
    end
end)

addcmd('pulsetp',{'ptp'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players)do
		if Players[v].Character ~= nil then
			local startPos = getRoot(speaker.Character).CFrame
			local seconds = args[2] or 1
			if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
				speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
				wait(.1)
			end
			getRoot(speaker.Character).CFrame = getRoot(Players[v].Character).CFrame + Vector3.new(3,1,0)
			wait(seconds)
			getRoot(speaker.Character).CFrame = startPos
		end
	end
	execCmd('breakvelocity')
end)

local vnoclipParts = {}
addcmd('vehiclenoclip',{'vnoclip'},function(args, speaker)
	vnoclipParts = {}
	local seat = speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart
	local vehicleModel = seat.Parent
	repeat
		if vehicleModel.ClassName ~= "Model" then
			vehicleModel = vehicleModel.Parent
		end
	until vehicleModel.ClassName == "Model"
	wait(0.1)
	execCmd('noclip')
	for i,v in pairs(vehicleModel:GetDescendants()) do
		if v:IsA("BasePart") and v.CanCollide then
			table.insert(vnoclipParts,v)
			v.CanCollide = false
		end
	end
end)

addcmd("vehicleclip", {"vclip", "unvnoclip", "unvehiclenoclip"}, function(args, speaker)
	execCmd("clip")
	for i, v in pairs(vnoclipParts) do
		v.CanCollide = true
	end
	vnoclipParts = {}
end)

addcmd("togglevnoclip", {}, function(args, speaker)
	execCmd(Clip and "vnoclip" or "vclip")
end)

addcmd('clientbring',{'cbring'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players)do
		if Players[v].Character ~= nil then
			if Players[v].Character:FindFirstChildOfClass('Humanoid') then
				Players[v].Character:FindFirstChildOfClass('Humanoid').Sit = false
			end
			wait()
			getRoot(Players[v].Character).CFrame = getRoot(speaker.Character).CFrame + Vector3.new(3,1,0)
		end
	end
end)

local bringT = {}
addcmd('loopbring',{},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players)do
		task.spawn(function()
			if Players[v].Name ~= speaker.Name and not FindInTable(bringT, Players[v].Name) then
				table.insert(bringT, Players[v].Name)
				local plrName = Players[v].Name
				local pchar=Players[v].Character
				local distance = 3
				if args[2] and isNumber(args[2]) then
					distance = args[2]
				end
				local lDelay = 0
				if args[3] and isNumber(args[3]) then
					lDelay = args[3]
				end
				repeat
					for i,c in pairs(players) do
						if Players:FindFirstChild(v) then
							pchar = Players[v].Character
							if pchar~= nil and Players[v].Character ~= nil and getRoot(pchar) and speaker.Character ~= nil and getRoot(speaker.Character) then
								getRoot(pchar).CFrame = getRoot(speaker.Character).CFrame + Vector3.new(distance,1,0)
							end
							wait(lDelay)
						else 
							for a,b in pairs(bringT) do if b == plrName then table.remove(bringT, a) end end
						end
					end
				until not FindInTable(bringT, plrName)
			end
		end)
	end
end)

addcmd('unloopbring',{'noloopbring'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players)do
		task.spawn(function()
			for a,b in pairs(bringT) do if b == Players[v].Name then table.remove(bringT, a) end end
		end)
	end
end)

local walkto = false
local waypointwalkto = false
addcmd('walkto',{'follow'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players)do
		if Players[v].Character ~= nil then
			if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
				speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
				wait(.1)
			end
			walkto = true
			repeat wait()
				speaker.Character:FindFirstChildOfClass('Humanoid'):MoveTo(getRoot(Players[v].Character).Position)
			until Players[v].Character == nil or not getRoot(Players[v].Character) or walkto == false
		end
	end
end)

addcmd('pathfindwalkto',{'pathfindfollow'},function(args, speaker)
	walkto = false
	wait()
	local players = getPlayer(args[1], speaker)
	local hum = Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	local path = PathService:CreatePath()
	for i,v in pairs(players)do
		if Players[v].Character ~= nil then
			if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
				speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
				wait(.1)
			end
			walkto = true
			repeat wait()
				local success, response = pcall(function()
					path:ComputeAsync(getRoot(speaker.Character).Position, getRoot(Players[v].Character).Position)
					local waypoints = path:GetWaypoints()
					local distance 
					for waypointIndex, waypoint in pairs(waypoints) do
						local waypointPosition = waypoint.Position
						hum:MoveTo(waypointPosition)
						repeat 
							distance = (waypointPosition - hum.Parent.PrimaryPart.Position).magnitude
							wait()
						until
						distance <= 5
					end	 
				end)
				if not success then
					speaker.Character:FindFirstChildOfClass('Humanoid'):MoveTo(getRoot(Players[v].Character).Position)
				end
			until Players[v].Character == nil or not getRoot(Players[v].Character) or walkto == false
		end
	end
end)

addcmd('pathfindwalktowaypoint',{'pathfindwalktowp'},function(args, speaker)
	waypointwalkto = false
	wait()
	local WPName = tostring(getstring(1, args))
	local hum = Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	local path = PathService:CreatePath()
	if speaker.Character then
		for i,_ in pairs(WayPoints) do
			if tostring(WayPoints[i].NAME):lower() == tostring(WPName):lower() then
				if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
					speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
					wait(.1)
				end
				local TrueCoords = Vector3.new(WayPoints[i].COORD[1], WayPoints[i].COORD[2], WayPoints[i].COORD[3])
				waypointwalkto = true
				repeat wait()
					local success, response = pcall(function()
						path:ComputeAsync(getRoot(speaker.Character).Position, TrueCoords)
						local waypoints = path:GetWaypoints()
						local distance 
						for waypointIndex, waypoint in pairs(waypoints) do
							local waypointPosition = waypoint.Position
							hum:MoveTo(waypointPosition)
							repeat 
								distance = (waypointPosition - hum.Parent.PrimaryPart.Position).magnitude
								wait()
							until
							distance <= 5
						end
					end)
					if not success then
						speaker.Character:FindFirstChildOfClass('Humanoid'):MoveTo(TrueCoords)
					end
				until not speaker.Character or waypointwalkto == false
			end
		end
		for i,_ in pairs(pWayPoints) do
			if tostring(pWayPoints[i].NAME):lower() == tostring(WPName):lower() then
				if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
					speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
					wait(.1)
				end
				local TrueCoords = pWayPoints[i].COORD[1].Position
				waypointwalkto = true
				repeat wait()
					local success, response = pcall(function()
						path:ComputeAsync(getRoot(speaker.Character).Position, TrueCoords)
						local waypoints = path:GetWaypoints()
						local distance 
						for waypointIndex, waypoint in pairs(waypoints) do
							local waypointPosition = waypoint.Position
							hum:MoveTo(waypointPosition)
							repeat 
								distance = (waypointPosition - hum.Parent.PrimaryPart.Position).magnitude
								wait()
							until
							distance <= 5
						end
					end)
					if not success then
						speaker.Character:FindFirstChildOfClass('Humanoid'):MoveTo(TrueCoords)
					end
				until not speaker.Character or waypointwalkto == false
			end
		end
	end
end)

addcmd('unwalkto',{'nowalkto','unfollow','nofollow'},function(args, speaker)
	walkto = false
	waypointwalkto = false
end)

addcmd("orbit", {}, function(args, speaker)
	execCmd("unorbit nonotify")

	local target = Players:FindFirstChild(getPlayer(args[1], speaker)[1])
	local root = getRoot(speaker.Character)
	local humanoid = speaker.Character:FindFirstChildWhichIsA("Humanoid")

	if target and target.Character and getRoot(target.Character) and root and humanoid then
		local rotation = 0
		local speed = tonumber(args[2]) or 0.2
		local distance = tonumber(args[3]) or 6

		orbit1 = RunService.Stepped:Connect(function()
			breakVelocity()
			rotation = rotation + speed

			local targetRoot = getRoot(target.Character).Position
			local orbitPosition = (CFrame.new(targetRoot) * CFrame.Angles(0, math.rad(rotation), 0) * CFrame.new(distance, 0, 0)).Position
			root.CFrame = CFrame.lookAt(orbitPosition, Vector3.new(targetRoot.X, orbitPosition.Y, targetRoot.Z))
		end)

		orbit2 = humanoid.Died:Connect(function() execCmd("unorbit") end)

		orbit3 = humanoid.Seated:Connect(function(value)
			if value then execCmd("unorbit") end
		end)

		notify("Orbit", "Started orbiting " .. formatUsername(target))
	end
end)

addcmd("unorbit", {}, function(args, speaker)
	if orbit1 then orbit1:Disconnect() end
	if orbit2 then orbit2:Disconnect() end
	if orbit3 then orbit3:Disconnect() end
	if args[1] ~= "nonotify" then notify("Orbit", "Stopped orbiting player") end
end)


addcmd('freeze',{'fr'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	if players ~= nil then
		for i,v in pairs(players) do
			task.spawn(function()
				for i, x in next, Players[v].Character:GetDescendants() do
					if x:IsA("BasePart") and not x.Anchored then
						x.Anchored = true
					end
				end
			end)
		end
	end
end)


addcmd('thaw',{'unfreeze','unfr'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	if players ~= nil then
		for i,v in pairs(players) do
			task.spawn(function()
				for i, x in next, Players[v].Character:GetDescendants() do
					if x.Name ~= floatName and x:IsA("BasePart") and x.Anchored then
						x.Anchored = false
					end
				end
			end)
		end
	end
end)

addcmd("anchor", {}, function(args, speaker)
    getRoot(speaker.Character).Anchored = true
end)

addcmd("unanchor", {}, function(args, speaker)
    getRoot(speaker.Character).Anchored = false
end)

oofing = false
addcmd('loopoof',{},function(args, speaker)
	oofing = true
	repeat wait(0.1)
		for i,v in pairs(Players:GetPlayers()) do
			if v.Character ~= nil and v.Character:FindFirstChild'Head' then
				for _,x in pairs(v.Character.Head:GetChildren()) do
					if x:IsA'Sound' then x.Playing = true end
				end
			end
		end
	until oofing == false
end)

addcmd('unloopoof',{},function(args, speaker)
	oofing = false
end)

local notifiedRespectFiltering = false
addcmd('muteboombox',{},function(args, speaker)
	if not notifiedRespectFiltering and SoundService.RespectFilteringEnabled then notifiedRespectFiltering = true notify('RespectFilteringEnabled','RespectFilteringEnabled is set to true (the command will still work but may only be clientsided)') end
	local players = getPlayer(args[1], speaker)
	if players ~= nil then
		for i,v in pairs(players) do
			task.spawn(function()
				for i, x in next, Players[v].Character:GetDescendants() do
					if x:IsA("Sound") and x.Playing == true then
						x.Playing = false
					end
				end
				for i, x in next, Players[v]:FindFirstChildOfClass("Backpack"):GetDescendants() do
					if x:IsA("Sound") and x.Playing == true then
						x.Playing = false
					end
				end
			end)
		end
	end
end)

addcmd('unmuteboombox',{},function(args, speaker)
	if not notifiedRespectFiltering and SoundService.RespectFilteringEnabled then notifiedRespectFiltering = true notify('RespectFilteringEnabled','RespectFilteringEnabled is set to true (the command will still work but may only be clientsided)') end
	local players = getPlayer(args[1], speaker)
	if players ~= nil then
		for i,v in pairs(players) do
			task.spawn(function()
				for i, x in next, Players[v].Character:GetDescendants() do
					if x:IsA("Sound") and x.Playing == false then
						x.Playing = true
					end
				end
			end)
		end
	end
end)

addcmd("reset", {}, function(args, speaker)
	local humanoid = speaker.Character and speaker.Character:FindFirstChildWhichIsA("Humanoid")
	if humanoid then
		humanoid:ChangeState(Enum.HumanoidStateType.Dead)
	else
		speaker.Character:BreakJoints()
	end
end)

addcmd('freezeanims',{},function(args, speaker)
	local Humanoid = speaker.Character:FindFirstChildOfClass("Humanoid") or speaker.Character:FindFirstChildOfClass("AnimationController")
	local ActiveTracks = Humanoid:GetPlayingAnimationTracks()
	for _, v in pairs(ActiveTracks) do
		v:AdjustSpeed(0)
	end
end)

addcmd('unfreezeanims',{},function(args, speaker)
	local Humanoid = speaker.Character:FindFirstChildOfClass("Humanoid") or speaker.Character:FindFirstChildOfClass("AnimationController")
	local ActiveTracks = Humanoid:GetPlayingAnimationTracks()
	for _, v in pairs(ActiveTracks) do
		v:AdjustSpeed(1)
	end
end)

addcmd("respawn", {}, function(args, speaker)
	respawn(speaker)
end)

addcmd("refresh", {"re"}, function(args, speaker)
	refresh(speaker)
end)

addcmd("god", {}, function(args, speaker)
	local Cam = workspace.CurrentCamera
	local Char, Pos = speaker.Character, Cam.CFrame
	local Human = Char and Char:FindFirstChildWhichIsA("Humanoid")
	local nHuman = Human:Clone()
	nHuman.Parent = char
	speaker.Character = nil
	nHuman:SetStateEnabled(15, false)
	nHuman:SetStateEnabled(1, false)
	nHuman:SetStateEnabled(0, false)
	nHuman.BreakJointsOnDeath = true
	Human:Destroy()
	speaker.Character = char
	Cam.CameraSubject = nHuman
	Cam.CFrame = task.wait() and pos
	nHuman.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	local Script = Char:FindFirstChild("Animate")
	if Script then
		Script.Disabled = true
		task.wait()
		Script.Disabled = false
	end
	nHuman.Health = nHuman.MaxHealth
end)

invisRunning = false
addcmd('invisible',{'invis'},function(args, speaker)
	if invisRunning then return end
	invisRunning = true
	-- Full credit to AmokahFox @V3rmillion
	local Player = speaker
	repeat wait(.1) until Player.Character
	local Character = Player.Character
	Character.Archivable = true
	local IsInvis = false
	local IsRunning = true
	local InvisibleCharacter = Character:Clone()
	InvisibleCharacter.Parent = Lighting
	local Void = workspace.FallenPartsDestroyHeight
	InvisibleCharacter.Name = ""
	local CF

	local invisFix = RunService.Stepped:Connect(function()
		pcall(function()
			local IsInteger
			if tostring(Void):find'-' then
				IsInteger = true
			else
				IsInteger = false
			end
			local Pos = Player.Character.Humanoid.RootPart.Position
			local Pos_String = tostring(Pos)
			local Pos_Seperate = Pos_String:split(', ')
			local X = tonumber(Pos_Seperate[1])
			local Y = tonumber(Pos_Seperate[2])
			local Z = tonumber(Pos_Seperate[3])
			if IsInteger == true then
				if Y <= Void then
					Respawn()
				end
			elseif IsInteger == false then
				if Y >= Void then
					Respawn()
				end
			end
		end)
	end)

	for i,v in pairs(InvisibleCharacter:GetDescendants())do
		if v:IsA("BasePart") then
			if v.Name == "HumanoidRootPart" then
				v.Transparency = 1
			else
				v.Transparency = .5
			end
		end
	end

	function Respawn()
		IsRunning = false
		if IsInvis == true then
			pcall(function()
				Player.Character = Character
				wait()
				Character.Parent = workspace
				Character:FindFirstChildWhichIsA'Humanoid':Destroy()
				IsInvis = false
				InvisibleCharacter.Parent = nil
				invisRunning = false
			end)
		elseif IsInvis == false then
			pcall(function()
				Player.Character = Character
				wait()
				Character.Parent = workspace
				Character:FindFirstChildWhichIsA'Humanoid':Destroy()
				TurnVisible()
			end)
		end
	end

	local invisDied
	invisDied = InvisibleCharacter:FindFirstChildOfClass'Humanoid'.Died:Connect(function()
		Respawn()
		invisDied:Disconnect()
	end)

	if IsInvis == true then return end
	IsInvis = true
	CF = workspace.CurrentCamera.CFrame
	local CF_1 = Player.Character.Humanoid.RootPart.CFrame
	Character:MoveTo(Vector3.new(0,math.pi*1000000,0))
	workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
	wait(.2)
	workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
	InvisibleCharacter = InvisibleCharacter
	Character.Parent = Lighting
	InvisibleCharacter.Parent = workspace
	InvisibleCharacter.Humanoid.RootPart.CFrame = CF_1
	Player.Character = InvisibleCharacter
	execCmd('fixcam')
	Player.Character.Animate.Disabled = true
	Player.Character.Animate.Disabled = false

	function TurnVisible()
		if IsInvis == false then return end
		invisFix:Disconnect()
		invisDied:Disconnect()
		CF = workspace.CurrentCamera.CFrame
		Character = Character
		local CF_1 = Player.Character.Humanoid.RootPart.CFrame
		Character.Humanoid.RootPart.CFrame = CF_1
		InvisibleCharacter:Destroy()
		Player.Character = Character
		Character.Parent = workspace
		IsInvis = false
		Player.Character.Animate.Disabled = true
		Player.Character.Animate.Disabled = false
		invisDied = Character:FindFirstChildOfClass'Humanoid'.Died:Connect(function()
			Respawn()
			invisDied:Disconnect()
		end)
		invisRunning = false
	end
	notify('Invisible','You now appear invisible to other players')
end)

addcmd("visible", {"vis","uninvisible"}, function(args, speaker)
	TurnVisible()
end)

addcmd("toggleinvis", {}, function(args, speaker)
	execCmd(invisRunning and "visible" or "invisible")
end)

addcmd('toolinvisible',{'toolinvis','tinvis'},function(args, speaker)
	local Char  = Players.LocalPlayer.Character
	local touched = false
	local tpdback = false
	local box = Instance.new('Part')
	box.Anchored = true
	box.CanCollide = true
	box.Size = Vector3.new(10,1,10)
	box.Position = Vector3.new(0,10000,0)
	box.Parent = workspace
	local boxTouched = box.Touched:connect(function(part)
		if (part.Parent.Name == Players.LocalPlayer.Name) then
			if touched == false then
				touched = true
				local function apply()
					local no = Char.Humanoid.RootPart:Clone()
					task.wait(.25)
					Char.Humanoid.RootPart:Destroy()
					no.Parent = Char
					Char:MoveTo(loc)
					touched = false
				end
				if Char then
					apply()
				end
			end
		end
	end)
	repeat wait() until Char
	local cleanUp
	cleanUp = Players.LocalPlayer.CharacterAdded:connect(function(char)
		boxTouched:Disconnect()
		box:Destroy()
		cleanUp:Disconnect()
	end)
	loc = Char.Humanoid.RootPart.Position
	Char:MoveTo(box.Position + Vector3.new(0,.5,0))
end)

addcmd("strengthen", {}, function(args, speaker)
	for _, child in pairs(speaker.Character:GetDescendants()) do
		if child.ClassName == "Part" then
			if args[1] then
				child.CustomPhysicalProperties = PhysicalProperties.new(args[1], 0.3, 0.5)
			else
				child.CustomPhysicalProperties = PhysicalProperties.new(100, 0.3, 0.5)
			end
		end
	end
end)

addcmd("weaken", {}, function(args, speaker)
	for _, child in pairs(speaker.Character:GetDescendants()) do
		if child.ClassName == "Part" then
			if args[1] then
				child.CustomPhysicalProperties = PhysicalProperties.new(-args[1], 0.3, 0.5)
			else
				child.CustomPhysicalProperties = PhysicalProperties.new(0, 0.3, 0.5)
			end
		end
	end
end)

addcmd("unweaken", {"unstrengthen"}, function(args, speaker)
	for _, child in pairs(speaker.Character:GetDescendants()) do
		if child.ClassName == "Part" then
			child.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5)
		end
	end
end)

addcmd("breakvelocity", {}, function(args, speaker)
	local BeenASecond, V3 = false, Vector3.new(0, 0, 0)
	delay(1, function()
		BeenASecond = true
	end)
	while not BeenASecond do
		for _, v in ipairs(speaker.Character:GetDescendants()) do
			if v:IsA("BasePart") then
				v.Velocity, v.RotVelocity = V3, V3
			end
		end
		wait()
	end
end)

addcmd('jpower',{'jumppower','jp'},function(args, speaker)
	local jpower = args[1] or 50
	if isNumber(jpower) then
		if speaker.Character:FindFirstChildOfClass('Humanoid').UseJumpPower then
			speaker.Character:FindFirstChildOfClass('Humanoid').JumpPower = jpower
		else
			speaker.Character:FindFirstChildOfClass('Humanoid').JumpHeight  = jpower
		end
	end
end)

addcmd("maxslopeangle", {"msa"}, function(args, speaker)
	local sangle = args[1] or 89
	if isNumber(sangle) then
		speaker.Character:FindFirstChildWhichIsA("Humanoid").MaxSlopeAngle = sangle
	end
end)

addcmd("gravity", {"grav"}, function(args, speaker)
	local grav = args[1] or oldgrav
	if isNumber(grav) then
		workspace.Gravity = grav
	end
end)

addcmd("hipheight", {"hheight"}, function(args, speaker)
	local hipHeight = args[1] or (r15(speaker) and 2.1 or 0)
	if isNumber(hipHeight) then
		speaker.Character:FindFirstChildWhichIsA("Humanoid").HipHeight = hipHeight
	end
end)

addcmd("dance", {}, function(args, speaker)
	pcall(execCmd, "undance")
	local dances = {"27789359", "30196114", "248263260", "45834924", "33796059", "28488254", "52155728"}
	if r15(speaker) then
		dances = {"3333432454", "4555808220", "4049037604", "4555782893", "10214311282", "10714010337", "10713981723", "10714372526", "10714076981", "10714392151", "11444443576"}
	end
	local animation = Instance.new("Animation")
	animation.AnimationId = "rbxassetid://" .. dances[math.random(1, #dances)]
	danceTrack = speaker.Character:FindFirstChildWhichIsA("Humanoid"):LoadAnimation(animation)
	danceTrack.Looped = true
	danceTrack:Play()
end)

addcmd("undance", {"nodance"}, function(args, speaker)
	danceTrack:Stop()
	danceTrack:Destroy()
end)

addcmd('nolimbs',{'rlimbs'},function(args, speaker)
	if r15(speaker) then
		for i,v in pairs(speaker.Character:GetChildren()) do
			if v:IsA("BasePart") and
				v.Name == "RightUpperLeg" or
				v.Name == "LeftUpperLeg" or
				v.Name == "RightUpperArm" or
				v.Name == "LeftUpperArm" then
				v:Destroy()
			end
		end
	else
		for i,v in pairs(speaker.Character:GetChildren()) do
			if v:IsA("BasePart") and
				v.Name == "Right Leg" or
				v.Name == "Left Leg" or
				v.Name == "Right Arm" or
				v.Name == "Left Arm" then
				v:Destroy()
			end
		end
	end
end)

addcmd('noarms',{'rarms'},function(args, speaker)
	if r15(speaker) then
		for i,v in pairs(speaker.Character:GetChildren()) do
			if v:IsA("BasePart") and
				v.Name == "RightUpperArm" or
				v.Name == "LeftUpperArm" then
				v:Destroy()
			end
		end
	else
		for i,v in pairs(speaker.Character:GetChildren()) do
			if v:IsA("BasePart") and
				v.Name == "Right Arm" or
				v.Name == "Left Arm" then
				v:Destroy()
			end
		end
	end
end)

addcmd('nolegs',{'rlegs'},function(args, speaker)
	if r15(speaker) then
		for i,v in pairs(speaker.Character:GetChildren()) do
			if v:IsA("BasePart") and
				v.Name == "RightUpperLeg" or
				v.Name == "LeftUpperLeg" then
				v:Destroy()
			end
		end
	else
		for i,v in pairs(speaker.Character:GetChildren()) do
			if v:IsA("BasePart") and
				v.Name == "Right Leg" or
				v.Name == "Left Leg" then
				v:Destroy()
			end
		end
	end
end)

addcmd("sit", {}, function(args, speaker)
	speaker.Character:FindFirstChildWhichIsA("Humanoid").Sit = true
end)

addcmd("lay", {"laydown"}, function(args, speaker)
	local humanoid = speaker.Character:FindFirstChildWhichIsA("Humanoid")
	humanoid.Sit = true
	task.wait(0.1)
	humanoid.RootPart.CFrame = humanoid.RootPart.CFrame * CFrame.Angles(math.pi * 0.5, 0, 0)
	for _, v in ipairs(humanoid:GetPlayingAnimationTracks()) do
		v:Stop()
	end
end)

addcmd("sitwalk", {}, function(args, speaker)
	local anims = speaker.Character.Animate
	local sit = anims.sit:FindFirstChildWhichIsA("Animation").AnimationId
	anims.idle:FindFirstChildWhichIsA("Animation").AnimationId = sit
	anims.walk:FindFirstChildWhichIsA("Animation").AnimationId = sit
	anims.run:FindFirstChildWhichIsA("Animation").AnimationId = sit
	anims.jump:FindFirstChildWhichIsA("Animation").AnimationId = sit
	speaker.Character:FindFirstChildWhichIsA("Humanoid").HipHeight = not r15(speaker) and -1.5 or 0.5
end)

addcmd("nosit", {}, function(args, speaker)
	speaker.Character:FindFirstChildWhichIsA("Humanoid"):SetStateEnabled(Enum.HumanoidStateType.Seated, false)
end)

addcmd("unnosit", {}, function(args, speaker)
	speaker.Character:FindFirstChildWhichIsA("Humanoid"):SetStateEnabled(Enum.HumanoidStateType.Seated, true)
end)

addcmd("jump", {}, function(args, speaker)
	speaker.Character:FindFirstChildWhichIsA("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
end)

local infJump
infJumpDebounce = false
addcmd("infjump", {"infinitejump"}, function(args, speaker)
	if infJump then infJump:Disconnect() end
	infJumpDebounce = false
	infJump = UserInputService.JumpRequest:Connect(function()
		if not infJumpDebounce then
			infJumpDebounce = true
			speaker.Character:FindFirstChildWhichIsA("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
			wait()
			infJumpDebounce = false
		end
	end)
end)

addcmd("uninfjump", {"uninfinitejump", "noinfjump", "noinfinitejump"}, function(args, speaker)
	if infJump then infJump:Disconnect() end
	infJumpDebounce = false
end)

local flyjump
addcmd("flyjump", {}, function(args, speaker)
	if flyjump then flyjump:Disconnect() end
	flyjump = UserInputService.JumpRequest:Connect(function()
		speaker.Character:FindFirstChildWhichIsA("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
	end)
end)

addcmd("unflyjump", {"noflyjump"}, function(args, speaker)
	if flyjump then flyjump:Disconnect() end
end)

local HumanModCons = {}
addcmd('autojump',{'ajump'},function(args, speaker)
	local Char = speaker.Character
	local Human = Char and Char:FindFirstChildWhichIsA("Humanoid")
	local function autoJump()
		if Char and Human then
			local check1 = workspace:FindPartOnRay(Ray.new(Human.RootPart.Position-Vector3.new(0,1.5,0), Human.RootPart.CFrame.lookVector*3), Human.Parent)
			local check2 = workspace:FindPartOnRay(Ray.new(Human.RootPart.Position+Vector3.new(0,1.5,0), Human.RootPart.CFrame.lookVector*3), Human.Parent)
			if check1 or check2 then
				Human.Jump = true
			end
		end
	end
	autoJump()
	HumanModCons.ajLoop = (HumanModCons.ajLoop and HumanModCons.ajLoop:Disconnect() and false) or RunService.RenderStepped:Connect(autoJump)
	HumanModCons.ajCA = (HumanModCons.ajCA and HumanModCons.ajCA:Disconnect() and false) or speaker.CharacterAdded:Connect(function(nChar)
		Char, Human = nChar, nChar:WaitForChild("Humanoid")
		autoJump()
		HumanModCons.ajLoop = (HumanModCons.ajLoop and HumanModCons.ajLoop:Disconnect() and false) or RunService.RenderStepped:Connect(autoJump)
	end)
end)

addcmd('unautojump',{'noautojump', 'noajump', 'unajump'},function(args, speaker)
	HumanModCons.ajLoop = (HumanModCons.ajLoop and HumanModCons.ajLoop:Disconnect() and false) or nil
	HumanModCons.ajCA = (HumanModCons.ajCA and HumanModCons.ajCA:Disconnect() and false) or nil
end)

addcmd('edgejump',{'ejump'},function(args, speaker)
	local Char = speaker.Character
	local Human = Char and Char:FindFirstChildWhichIsA("Humanoid")
	-- Full credit to NoelGamer06 @V3rmillion
	local state
	local laststate
	local lastcf
	local function edgejump()
		if Char and Human then
			laststate = state
			state = Human:GetState()
			if laststate ~= state and state == Enum.HumanoidStateType.Freefall and laststate ~= Enum.HumanoidStateType.Jumping then
				Char.Humanoid.RootPart.CFrame = lastcf
				Char.Humanoid.RootPart.Velocity = Vector3.new(Char.Humanoid.RootPart.Velocity.X, Human.JumpPower or Human.JumpHeight, Char.Humanoid.RootPart.Velocity.Z)
			end
			lastcf = Char.Humanoid.RootPart.CFrame
		end
	end
	edgejump()
	HumanModCons.ejLoop = (HumanModCons.ejLoop and HumanModCons.ejLoop:Disconnect() and false) or RunService.RenderStepped:Connect(edgejump)
	HumanModCons.ejCA = (HumanModCons.ejCA and HumanModCons.ejCA:Disconnect() and false) or speaker.CharacterAdded:Connect(function(nChar)
		Char, Human = nChar, nChar:WaitForChild("Humanoid")
		edgejump()
		HumanModCons.ejLoop = (HumanModCons.ejLoop and HumanModCons.ejLoop:Disconnect() and false) or RunService.RenderStepped:Connect(edgejump)
	end)
end)

addcmd('unedgejump',{'noedgejump', 'noejump', 'unejump'},function(args, speaker)
	HumanModCons.ejLoop = (HumanModCons.ejLoop and HumanModCons.ejLoop:Disconnect() and false) or nil
	HumanModCons.ejCA = (HumanModCons.ejCA and HumanModCons.ejCA:Disconnect() and false) or nil
end)

addcmd("team", {}, function(args, speaker)
	local teamName = getstring(1, args)
	local team = nil
	local root = speaker.Character and getRoot(speaker.Character)
	for _, v in ipairs(Teams:GetChildren()) do
		if v.Name:lower():match(teamName:lower()) then
			team = v
			break
		end
	end
	if not team then
		return notify("Invalid Team", teamName .. " is not a valid team")
	end
	if root and firetouchinterest then
		for _, v in ipairs(workspace:GetDescendants()) do
			if v:IsA("SpawnLocation") and v.BrickColor == team.TeamColor and v.AllowTeamChangeOnTouch == true then
				firetouchinterest(v, root, 0)
				firetouchinterest(v, root, 1)
				break
			end
		end
	else
		speaker.Team = team
	end
end)

addcmd('nobgui',{'unbgui','nobillboardgui','unbillboardgui','noname','rohg'},function(args, speaker)
	for i,v in pairs(speaker.Character:GetDescendants())do
		if v:IsA("BillboardGui") or v:IsA("SurfaceGui") then
			v:Destroy()
		end
	end
end)

addcmd('loopnobgui',{'loopunbgui','loopnobillboardgui','loopunbillboardgui','loopnoname','looprohg'},function(args, speaker)
	for i,v in pairs(speaker.Character:GetDescendants())do
		if v:IsA("BillboardGui") or v:IsA("SurfaceGui") then
			v:Destroy()
		end
	end
	local function charPartAdded(part)
		if part:IsA("BillboardGui") or part:IsA("SurfaceGui") then
			wait()
			part:Destroy()
		end
	end
	charPartTrigger = speaker.Character.DescendantAdded:Connect(charPartAdded)
end)

addcmd('unloopnobgui',{'unloopunbgui','unloopnobillboardgui','unloopunbillboardgui','unloopnoname','unlooprohg'},function(args, speaker)
	if charPartTrigger then
		charPartTrigger:Disconnect()
	end
end)

addcmd('spasm',{},function(args, speaker)
	if not r15(speaker) then
		local pchar=speaker.Character
		local AnimationId = "33796059"
		SpasmAnim = Instance.new("Animation")
		SpasmAnim.AnimationId = "rbxassetid://"..AnimationId
		Spasm = pchar:FindFirstChildOfClass('Humanoid'):LoadAnimation(SpasmAnim)
		Spasm:Play()
		Spasm:AdjustSpeed(99)
	else
		notify('R6 Required','This command requires the r6 rig type')
	end
end)

addcmd('unspasm',{'nospasm'},function(args, speaker)
	Spasm:Stop()
	SpasmAnim:Destroy()
end)

addcmd('headthrow',{},function(args, speaker)
	if not r15(speaker) then
		local AnimationId = "35154961"
		local Anim = Instance.new("Animation")
		Anim.AnimationId = "rbxassetid://"..AnimationId
		local k = speaker.Character:FindFirstChildOfClass('Humanoid'):LoadAnimation(Anim)
		k:Play(0)
		k:AdjustSpeed(1)
	else
		notify('R6 Required','This command requires the r6 rig type')
	end
end)

local function anim2track(asset_id)
	local objs = game:GetObjects(asset_id)
	for i = 1, #objs do
		if objs[i]:IsA("Animation") then
			return objs[i].AnimationId
		end
	end
	return asset_id
end

addcmd("animation", {"anim"}, function(args, speaker)
	local animid = tostring(args[1])
	if not animid:find("rbxassetid://") then
		animid = "rbxassetid://" .. animid
	end
	animid = anim2track(animid)
	local animation = Instance.new("Animation")
	animation.AnimationId = animid
	local anim = speaker.Character:FindFirstChildWhichIsA("Humanoid"):LoadAnimation(animation)
	anim.Priority = Enum.AnimationPriority.Movement
	anim:Play()
	if args[2] then anim:AdjustSpeed(tostring(args[2])) end
end)

addcmd("emote", {"em"}, function(args, speaker)
	local anim = humanoid:PlayEmoteAndGetAnimTrackById(args[1])
	if args[2] then anim:AdjustSpeed(tostring(args[2])) end
end)


addcmd('noanim',{},function(args, speaker)
	speaker.Character.Animate.Disabled = true
end)

addcmd('reanim',{},function(args, speaker)
	speaker.Character.Animate.Disabled = false
end)

addcmd('animspeed',{},function(args, speaker)
	local Char = speaker.Character
	local Hum = Char:FindFirstChildOfClass("Humanoid") or Char:FindFirstChildOfClass("AnimationController")

	for i,v in next, Hum:GetPlayingAnimationTracks() do
		v:AdjustSpeed(tonumber(args[1] or 1))
	end
end)

addcmd('copyanimation',{'copyanim','copyemote'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for _,v in ipairs(players)do
		local char = Players[v].Character
		for _, v1 in pairs(speaker.Character:FindFirstChildOfClass('Humanoid'):GetPlayingAnimationTracks()) do
			v1:Stop()
		end
		for _, v1 in pairs(Players[v].Character:FindFirstChildOfClass('Humanoid'):GetPlayingAnimationTracks()) do
			if not string.find(v1.Animation.AnimationId, "507768375") then
				local ANIM = speaker.Character:FindFirstChildOfClass('Humanoid'):LoadAnimation(v1.Animation)
				ANIM:Play(.1, 1, v1.Speed)
				ANIM.TimePosition = v1.TimePosition
				task.spawn(function()
					v1.Stopped:Wait()
					ANIM:Stop()
					ANIM:Destroy()
				end)
			end
		end
	end
end)

addcmd("copyanimationid", {"copyanimid", "copyemoteid"}, function(args, speaker)
	local copyAnimId = function(player)
		local found = "Animations Copied"

		for _, v in pairs(player.Character:FindFirstChildWhichIsA("Humanoid"):GetPlayingAnimationTracks()) do
			local animationId = v.Animation.AnimationId
			local assetId = animationId:find("rbxassetid://") and animationId:match("%d+")

			if not string.find(animationId, "507768375") and not string.find(animationId, "180435571") then
				if assetId then
					local success, result = pcall(function()
						return MarketplaceService:GetProductInfo(tonumber(assetId)).Name
					end)
					local name = success and result or "Failed to get name"
					found = found .. "\n\nName: " .. name .. "\nAnimation Id: " .. animationId
				else
					found = found .. "\n\nAnimation Id: " .. animationId
				end
			end
		end

		if found ~= "Animations Copied" then
			toClipboard(found)
		else
			notify("Animations", "No animations to copy")
		end
	end

	if args[1] then
		copyAnimId(Players[getPlayer(args[1], speaker)[1]])
	else
		copyAnimId(speaker)
	end
end)

addcmd('stopanimations',{'stopanims','stopanim'},function(args, speaker)
	local Char = speaker.Character
	local Hum = Char:FindFirstChildOfClass("Humanoid") or Char:FindFirstChildOfClass("AnimationController")

	for i,v in next, Hum:GetPlayingAnimationTracks() do
		v:Stop()
	end
end)

addcmd('refreshanimations', {'refreshanimation', 'refreshanims', 'refreshanim'}, function(args, speaker)
	local Char = speaker.Character or speaker.CharacterAdded:Wait()
	local Human = Char and Char:WaitForChild('Humanoid', 15)
	local Animate = Char and Char:WaitForChild('Animate', 15)
	if not Human or not Animate then
		return notify('Refresh Animations', 'Failed to get Animate/Humanoid')
	end
	Animate.Disabled = true
	for _, v in ipairs(Human:GetPlayingAnimationTracks()) do
		v:Stop()
	end
	Animate.Disabled = false
end)

addcmd('allowcustomanim', {'allowcustomanimations'}, function(args, speaker)
	StarterPlayer.AllowCustomAnimations = true
	execCmd('refreshanimations')
end)

addcmd('unallowcustomanim', {'unallowcustomanimations'}, function(args, speaker)
	StarterPlayer.AllowCustomAnimations = false
	execCmd('refreshanimations')
end)

addcmd('loopanimation', {'loopanim'},function(args, speaker)
	local Char = speaker.Character
	local Human = Char and Char.FindFirstChildWhichIsA(Char, "Humanoid")
	for _, v in ipairs(Human.GetPlayingAnimationTracks(Human)) do
		v.Looped = true
	end
end)

addcmd('tpposition',{'tppos'},function(args, speaker)
	if #args < 3 then return end
	local tpX,tpY,tpZ = tonumber((args[1]:gsub(",", ""))),tonumber((args[2]:gsub(",", ""))),tonumber((args[3]:gsub(",", "")))
	local char = speaker.Character
	if char and getRoot(char) then
		getRoot(char).CFrame = CFrame.new(tpX,tpY,tpZ)
	end
end)

addcmd('tweentpposition',{'ttppos'},function(args, speaker)
	if #args < 3 then return end
	local tpX,tpY,tpZ = tonumber((args[1]:gsub(",", ""))),tonumber((args[2]:gsub(",", ""))),tonumber((args[3]:gsub(",", "")))
	local char = speaker.Character
	if char and getRoot(char) then
		TweenService:Create(getRoot(speaker.Character), TweenInfo.new(tweenSpeed, Enum.EasingStyle.Linear), {CFrame = CFrame.new(tpX,tpY,tpZ)}):Play()
	end
end)

addcmd("offset", {}, function(args, speaker)
    if #args < 3 then return end
    speaker.Character:TranslateBy(Vector3.new(tonumber(args[1]) or 0, tonumber(args[2]) or 0, tonumber(args[3]) or 0))
end)

addcmd("tweenoffset", {"toffset"}, function(args, speaker)
    if #args < 3 then return end
    local tpX, tpY, tpZ = tonumber(args[1]), tonumber(args[2]), tonumber(args[3])
    local root = getRoot(speaker.Character)
    local pos = root.Position + Vector3.new(tpX, tpY, tpZ)
    TweenService:Create(root, TweenInfo.new(tweenSpeed, Enum.EasingStyle.Linear), {CFrame = CFrame.new(pos)}):Play()
    breakVelocity()
end)

addcmd("clickteleport", {}, function(args, speaker)
    if speaker ~= Players.LocalPlayer then return end
    notify("Click TP", "Go to Settings > Keybinds > Add to set up click teleport")
end)

addcmd("mouseteleport", {"mousetp"}, function(args, speaker)
    local root = getRoot(speaker.Character)
    local pos = IYMouse.Hit
    if root and pos then
        root.CFrame = CFrame.new(pos.X, pos.Y + 3, pos.Z, select(4, root.CFrame:components()))
        breakVelocity()
    end
end)

addcmd("tptool", {"teleporttool"}, function(args, speaker)
    local TpTool = Instance.new("Tool")
    TpTool.Name = "Teleport Tool"
    TpTool.RequiresHandle = false
    TpTool.Parent = speaker:FindFirstChildOfClass("Backpack")
    TpTool.Activated:Connect(function()
        local root = getRoot(speaker.Character)
        local pos = IYMouse.Hit
        if not root or not pos then return end
        root.CFrame = CFrame.new(pos.X, pos.Y + 3, pos.Z, select(4, root.CFrame:components()))
        breakVelocity()
    end)
end)

addcmd("thru", {}, function(args, speaker)
    local root = getRoot(speaker.Character)
    local num = tonumber(args[1]) or 5
    local pos = root.CFrame.Position + (root.CFrame.LookVector * num)
    root.CFrame = CFrame.new(pos, pos + root.CFrame.LookVector)
end)

addcmd('clickdelete',{},function(args, speaker)
	if speaker == Players.LocalPlayer then
		notify('Click Delete','Go to Settings > Keybinds > Add to set up click delete')
	end
end)

addcmd('getposition',{'getpos','notifypos','notifyposition'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players)do
		local char = Players[v].Character
		local pos = char and (getRoot(char) or char:FindFirstChildWhichIsA("BasePart"))
		pos = pos and pos.Position
		if not pos then
			return notify('Getposition Error','Missing character')
		end
		local roundedPos = math.round(pos.X) .. ", " .. math.round(pos.Y) .. ", " .. math.round(pos.Z)
		notify('Current Position',roundedPos)
	end
end)

addcmd('copyposition',{'copypos'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players)do
		local char = Players[v].Character
		local pos = char and (getRoot(char) or char:FindFirstChildWhichIsA("BasePart"))
		pos = pos and pos.Position
		if not pos then
			return notify('Getposition Error','Missing character')
		end
		local roundedPos = math.round(pos.X) .. ", " .. math.round(pos.Y) .. ", " .. math.round(pos.Z)
		toClipboard(roundedPos)
	end
end)

addcmd('walktopos',{'walktoposition'},function(args, speaker)
	if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
		speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
		wait(.1)
	end
	speaker.Character:FindFirstChildOfClass('Humanoid').WalkToPoint = Vector3.new(args[1],args[2],args[3])
end)

addcmd('speed',{'ws','walkspeed'},function(args, speaker)
	if args[2] then
		local speed = args[2] or 16
		if isNumber(speed) then
			speaker.Character:FindFirstChildOfClass('Humanoid').WalkSpeed = speed
		end
	else
		local speed = args[1] or 16
		if isNumber(speed) then
			speaker.Character:FindFirstChildOfClass('Humanoid').WalkSpeed = speed
		end
	end
end)

addcmd('spoofspeed',{'spoofws','spoofwalkspeed'},function(args, speaker)
	if args[1] and isNumber(args[1]) then
		if hookmetamethod then
			local char = speaker.Character
			local setspeed;
			local index; index = hookmetamethod(game, "__index", function(self, key)
				if not checkcaller() and typeof(self) == "Instance" and self:IsA("Humanoid") and (key == "WalkSpeed" or key == "walkSpeed") and self:IsDescendantOf(char) then
					return setspeed or args[1]
				end
				return index(self, key)
			end)
			local newindex; newindex = hookmetamethod(game, "__newindex", function(self, key, value)
				if not checkcaller() and typeof(self) == "Instance" and self:IsA("Humanoid") and (key == "WalkSpeed" or key == "walkSpeed") and self:IsDescendantOf(char) then
					setspeed = tonumber(value)
				end
				return newindex(self, key, value)
			end)
		else
			notify('Incompatible Exploit','Your exploit does not support this command (missing hookmetamethod)')
		end
	end
end)

addcmd('loopspeed',{'loopws'},function(args, speaker)
	local speed = args[1] or 16
	if args[2] then
		speed = args[2] or 16
	end
	if isNumber(speed) then
		local Char = speaker.Character or workspace:FindFirstChild(speaker.Name)
		local Human = Char and Char:FindFirstChildWhichIsA("Humanoid")
		local function WalkSpeedChange()
			if Char and Human then
				Human.WalkSpeed = speed
			end
		end
		WalkSpeedChange()
		HumanModCons.wsLoop = (HumanModCons.wsLoop and HumanModCons.wsLoop:Disconnect() and false) or Human:GetPropertyChangedSignal("WalkSpeed"):Connect(WalkSpeedChange)
		HumanModCons.wsCA = (HumanModCons.wsCA and HumanModCons.wsCA:Disconnect() and false) or speaker.CharacterAdded:Connect(function(nChar)
			Char, Human = nChar, nChar:WaitForChild("Humanoid")
			WalkSpeedChange()
			HumanModCons.wsLoop = (HumanModCons.wsLoop and HumanModCons.wsLoop:Disconnect() and false) or Human:GetPropertyChangedSignal("WalkSpeed"):Connect(WalkSpeedChange)
		end)
	end
end)

addcmd('unloopspeed',{'unloopws'},function(args, speaker)
	HumanModCons.wsLoop = (HumanModCons.wsLoop and HumanModCons.wsLoop:Disconnect() and false) or nil
	HumanModCons.wsCA = (HumanModCons.wsCA and HumanModCons.wsCA:Disconnect() and false) or nil
end)

addcmd('spoofjumppower',{'spoofjp'},function(args, speaker)
	if args[1] and isNumber(args[1]) then
		if hookmetamethod then
			local char = speaker.Character
			local setpower;
			local index; index = hookmetamethod(game, "__index", function(self, key)
				if not checkcaller() and typeof(self) == "Instance" and self:IsA("Humanoid") and (key == "JumpPower" or key == "jumpPower") and self:IsDescendantOf(char) then
					return setpower or args[1]
				end
				return index(self, key)
			end)
			local newindex; newindex = hookmetamethod(game, "__newindex", function(self, key, value)
				if not checkcaller() and typeof(self) == "Instance" and self:IsA("Humanoid") and (key == "JumpPower" or key == "jumpPower") and self:IsDescendantOf(char) then
					setpower = tonumber(value)
				end
				return newindex(self, key, value)
			end)
		else
			notify('Incompatible Exploit','Your exploit does not support this command (missing hookmetamethod)')
		end
	end
end)

addcmd('loopjumppower',{'loopjp','loopjpower'},function(args, speaker)
	local jpower = args[1] or 50
	if isNumber(jpower) then
		local Char = speaker.Character or workspace:FindFirstChild(speaker.Name)
		local Human = Char and Char:FindFirstChildWhichIsA("Humanoid")
		local function JumpPowerChange()
			if Char and Human then
				if speaker.Character:FindFirstChildOfClass('Humanoid').UseJumpPower then
					speaker.Character:FindFirstChildOfClass('Humanoid').JumpPower = jpower
				else
					speaker.Character:FindFirstChildOfClass('Humanoid').JumpHeight  = jpower
				end
			end
		end
		JumpPowerChange()
		HumanModCons.jpLoop = (HumanModCons.jpLoop and HumanModCons.jpLoop:Disconnect() and false) or Human:GetPropertyChangedSignal("JumpPower"):Connect(JumpPowerChange)
		HumanModCons.jpCA = (HumanModCons.jpCA and HumanModCons.jpCA:Disconnect() and false) or speaker.CharacterAdded:Connect(function(nChar)
			Char, Human = nChar, nChar:WaitForChild("Humanoid")
			JumpPowerChange()
			HumanModCons.jpLoop = (HumanModCons.jpLoop and HumanModCons.jpLoop:Disconnect() and false) or Human:GetPropertyChangedSignal("JumpPower"):Connect(JumpPowerChange)
		end)
	end
end)

addcmd('unloopjumppower',{'unloopjp','unloopjpower'},function(args, speaker)
	local Char = speaker.Character or workspace:FindFirstChild(speaker.Name)
	local Human = Char and Char:FindFirstChildWhichIsA("Humanoid")
	HumanModCons.jpLoop = (HumanModCons.jpLoop and HumanModCons.jpLoop:Disconnect() and false) or nil
	HumanModCons.jpCA = (HumanModCons.jpCA and HumanModCons.jpCA:Disconnect() and false) or nil
	if Char and Human then
		if speaker.Character:FindFirstChildOfClass('Humanoid').UseJumpPower then
			speaker.Character:FindFirstChildOfClass('Humanoid').JumpPower = 50
		else
			speaker.Character:FindFirstChildOfClass('Humanoid').JumpHeight  = 50
		end
	end
end)

addcmd('tools',{'gears'},function(args, speaker)
	local function copy(instance)
		for i,c in pairs(instance:GetChildren())do
			if c:IsA('Tool') or c:IsA('HopperBin') then
				c:Clone().Parent = speaker:FindFirstChildOfClass("Backpack")
			end
			copy(c)
		end
	end
	copy(Lighting)
	local function copy(instance)
		for i,c in pairs(instance:GetChildren())do
			if c:IsA('Tool') or c:IsA('HopperBin') then
				c:Clone().Parent = speaker:FindFirstChildOfClass("Backpack")
			end
			copy(c)
		end
	end
	copy(ReplicatedStorage)
	notify('Tools','Copied tools from ReplicatedStorage and Lighting')
end)

addcmd('notools',{'rtools','clrtools','removetools','deletetools','dtools'},function(args, speaker)
	for i,v in pairs(speaker:FindFirstChildOfClass("Backpack"):GetDescendants()) do
		if v:IsA('Tool') or v:IsA('HopperBin') then
			v:Destroy()
		end
	end
	for i,v in pairs(speaker.Character:GetDescendants()) do
		if v:IsA('Tool') or v:IsA('HopperBin') then
			v:Destroy()
		end
	end
end)

addcmd('deleteselectedtool',{'dst'},function(args, speaker)
	for i,v in pairs(speaker.Character:GetDescendants()) do
		if v:IsA('Tool') or v:IsA('HopperBin') then
			v:Destroy()
		end
	end
end)

addcmd("console", {}, function(args, speaker)
	StarterGui:SetCore("DevConsoleVisible", true)
end)

addcmd('oldconsole',{},function(args, speaker)
	-- Thanks wally!!
	notify("Loading",'Hold on a sec')
	local _, str = pcall(function()
		return game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/console.lua", true)
	end)

	local s, e = loadstring(str)
	if typeof(s) ~= "function" then
		return
	end

	local success, message = pcall(s)
	if (not success) then
		if printconsole then
			printconsole(message)
		elseif printoutput then
			printoutput(message)
		end
	end
	wait(1)
	notify('Console','Press F9 to open the console')
end)

addcmd("explorer", {"dex"}, function(args, speaker)
    notify("Loading", "Hold on a sec")
    loadstring(game:HttpGet("https://github.com/AZYsGithub/DexPlusPlus/releases/latest/download/out.lua"))()
end)

addcmd("moondex", {"mdex"}, function(args, speaker)
    notify("Loading", "Hold on a sec")
    loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))()
end)

addcmd("remotespy", {"rspy", "cobalt", "cspy"}, function(args, speaker)
    notify("Loading", "Hold on a sec")
    -- Full credit to notpoiu, creator of Cobalt
    loadstring(game:HttpGet("https://gitlab.com/upio/cobalt/-/releases/permalink/latest/downloads/Cobalt.luau"))()
end)

addcmd("simplespy", {"sspy"}, function(args, speaker)
    notify("Loading", "Hold on a sec")
    -- Full credit to exx, creator of SimpleSpy
    -- also thanks to Amity for fixing
    loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/SimpleSpyV3/main.lua"))()
end)

addcmd('audiologger',{'alogger'},function(args, speaker)
	notify("Loading",'Hold on a sec')
	loadstring(game:HttpGet(('https://raw.githubusercontent.com/infyiff/backup/main/audiologger.lua'),true))()
end)

local loopgoto = nil
addcmd('loopgoto',{},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players)do
		loopgoto = nil
		if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
			speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
			wait(.1)
		end
		loopgoto = Players[v]
		local distance = 3
		if args[2] and isNumber(args[2]) then
			distance = args[2]
		end
		local lDelay = 0
		if args[3] and isNumber(args[3]) then
			lDelay = args[3]
		end
		repeat
			if Players:FindFirstChild(v) then
				if Players[v].Character ~= nil then
					getRoot(speaker.Character).CFrame = getRoot(Players[v].Character).CFrame + Vector3.new(distance,1,0)
				end
				wait(lDelay)
			else
				loopgoto = nil
			end
		until loopgoto ~= Players[v]
	end
end)

addcmd('unloopgoto',{'noloopgoto'},function(args, speaker)
	loopgoto = nil
end)

addcmd('headsit',{},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	if headSit then headSit:Disconnect() end
	for i,v in pairs(players)do
		speaker.Character:FindFirstChildOfClass('Humanoid').Sit = true
		headSit = RunService.Heartbeat:Connect(function()
			if Players:FindFirstChild(Players[v].Name) and Players[v].Character ~= nil and getRoot(Players[v].Character) and getRoot(speaker.Character) and speaker.Character:FindFirstChildOfClass('Humanoid').Sit == true then
				getRoot(speaker.Character).CFrame = getRoot(Players[v].Character).CFrame * CFrame.Angles(0,math.rad(0),0)* CFrame.new(0,1.6,0.4)
			else
				headSit:Disconnect()
			end
		end)
	end
end)

addcmd('chat',{'say'},function(args, speaker)
	local cString = getstring(1, args)
	chatMessage(cString)
end)


spamming = false
spamspeed = 1
addcmd('spam',{},function(args, speaker)
	spamming = true
	local spamstring = getstring(1, args)
	repeat wait(spamspeed)
		chatMessage(spamstring)
	until spamming == false
end)

addcmd('nospam',{'unspam'},function(args, speaker)
	spamming = false
end)

addcmd('whisper',{'pm'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players)do
		task.spawn(function()
			local plrName = Players[v].Name
			local pmstring = getstring(2, args)
			chatMessage("/w "..plrName.." "..pmstring)
		end)
	end
end)

pmspamming = {}
addcmd('pmspam',{},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players)do
		task.spawn(function()
			local plrName = Players[v].Name
			if FindInTable(pmspamming, plrName) then return end
			table.insert(pmspamming, plrName)
			local pmspamstring = getstring(2, args)
			repeat
				if Players:FindFirstChild(v) then
					wait(spamspeed)
					chatMessage("/w "..plrName.." "..pmspamstring)
				else
					for a,b in pairs(pmspamming) do if b == plrName then table.remove(pmspamming, a) end end
				end
			until not FindInTable(pmspamming, plrName)
		end)
	end
end)

addcmd('nopmspam',{'unpmspam'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players)do
		task.spawn(function()
			for a,b in pairs(pmspamming) do
				if b == Players[v].Name then
					table.remove(pmspamming, a)
				end
			end
		end)
	end
end)

addcmd('spamspeed',{},function(args, speaker)
	local speed = args[1] or 1
	if isNumber(speed) then
		spamspeed = speed
	end
end)

addcmd('bubblechat',{},function(args, speaker)
	if isLegacyChat then
		ChatService.BubbleChatEnabled = true
	else
		TextChatService.BubbleChatConfiguration.Enabled = true
	end
end)

addcmd('unbubblechat',{'nobubblechat'},function(args, speaker)
	if isLegacyChat then
		ChatService.BubbleChatEnabled = false
	else
		TextChatService.BubbleChatConfiguration.Enabled = false
	end
end)

addcmd("chatwindow", {}, function(args, speaker)
	TextChatService.ChatWindowConfiguration.Enabled = true
end)

addcmd("unchatwindow", {"nochatwindow"}, function(args, speaker)
	TextChatService.ChatWindowConfiguration.Enabled = false
end)

addcmd("darkchat", {}, function(args, speaker)
    local BCC = TextChatService:FindFirstChildOfClass("BubbleChatConfiguration")
    local CWC = TextChatService:FindFirstChildOfClass("ChatWindowConfiguration")
    local CIBC = TextChatService:FindFirstChildOfClass("ChatInputBarConfiguration")
    if BCC then
        BCC.Enabled = true
        BCC.BackgroundColor3 = Color3.fromRGB()
        BCC.BackgroundTransparency = 0.3
        BCC.TailVisible = true
        BCC.TextColor3 = Color3.fromRGB(0xFF, 0xFF, 0xFF)
    end
    if CWC then
        CWC.Enabled = true
        CWC.BackgroundColor3 = Color3.fromRGB()
        CWC.BackgroundTransparency = 0.3
        CWC.TextColor3 = Color3.fromRGB(0xFF, 0xFF, 0xFF)
        CWC.TextStrokeColor3 = Color3.fromRGB()
        CWC.TextStrokeTransparency = 0.5
    end
    if CIBC then
        CIBC.Enabled = true
        CIBC.BackgroundColor3 = Color3.fromRGB()
        CIBC.BackgroundTransparency = 0.5
        CIBC.PlaceholderColor3 = Color3.fromRGB(0xFF, 0xFF, 0xFF)
        CIBC.TextColor3 = Color3.fromRGB(0xFF, 0xFF, 0xFF)
        CIBC.TextStrokeColor3 = Color3.fromRGB()
        CIBC.TextStrokeTransparency = 0.5
    end
end)

addcmd('blockhead',{},function(args, speaker)
	speaker.Character.Head:FindFirstChildOfClass("SpecialMesh"):Destroy()
end)

addcmd('blockhats',{},function(args, speaker)
	for _,v in pairs(speaker.Character:FindFirstChildOfClass('Humanoid'):GetAccessories()) do
		for i,c in pairs(v:GetDescendants()) do
			if c:IsA("SpecialMesh") then
				c:Destroy()
			end
		end
	end
end)

addcmd('blocktool',{},function(args, speaker)
	for _,v in pairs(speaker.Character:GetChildren()) do
		if v:IsA("Tool") or v:IsA("HopperBin") then
			for i,c in pairs(v:GetDescendants()) do
				if c:IsA("SpecialMesh") then
					c:Destroy()
				end
			end
		end
	end
end)

addcmd('creeper',{},function(args, speaker)
	if r15(speaker) then
		speaker.Character.Head:FindFirstChildOfClass("SpecialMesh"):Destroy()
		speaker.Character.LeftUpperArm:Destroy()
		speaker.Character.RightUpperArm:Destroy()
		speaker.Character:FindFirstChildOfClass("Humanoid"):RemoveAccessories()
	else
		speaker.Character.Head:FindFirstChildOfClass("SpecialMesh"):Destroy()
		speaker.Character["Left Arm"]:Destroy()
		speaker.Character["Right Arm"]:Destroy()
		speaker.Character:FindFirstChildOfClass("Humanoid"):RemoveAccessories()
	end
end)

function getTorso(x)
	x = x or Players.LocalPlayer.Character
	return x:FindFirstChild("Torso") or x:FindFirstChild("UpperTorso") or x:FindFirstChild("LowerTorso") or x:FindFirstChild("HumanoidRootPart")
end

addcmd("bang", {"rape"}, function(args, speaker)
	execCmd("unbang")
	wait()
	local humanoid = speaker.Character:FindFirstChildWhichIsA("Humanoid")
	bangAnim = Instance.new("Animation")
	bangAnim.AnimationId = not r15(speaker) and "rbxassetid://148840371" or "rbxassetid://5918726674"
	bang = humanoid:LoadAnimation(bangAnim)
	bang:Play(0.1, 1, 1)
	bang:AdjustSpeed(args[2] or 3)
	bangDied = humanoid.Died:Connect(function()
		bang:Stop()
		bangAnim:Destroy()
		bangDied:Disconnect()
		bangLoop:Disconnect()
	end)
	if args[1] then
		local players = getPlayer(args[1], speaker)
		for _, v in pairs(players) do
			local bangplr = Players[v].Name
			local bangOffet = CFrame.new(0, 0, 1.1)
			bangLoop = RunService.Stepped:Connect(function()
				pcall(function()
					local otherRoot = getTorso(Players[bangplr].Character)
					getRoot(speaker.Character).CFrame = otherRoot.CFrame * bangOffet
				end)
			end)
			break
		end
	end
end)

addcmd("unbang", {"unrape"}, function(args, speaker)
	if bangDied then
		bangDied:Disconnect()
		bang:Stop()
		bangAnim:Destroy()
		bangLoop:Disconnect()
	end
end)

addcmd('carpet',{},function(args, speaker)
	if not r15(speaker) then
		execCmd('uncarpet')
		wait()
		local players = getPlayer(args[1], speaker)
		for i,v in pairs(players)do
			carpetAnim = Instance.new("Animation")
			carpetAnim.AnimationId = "rbxassetid://282574440"
			carpet = speaker.Character:FindFirstChildOfClass('Humanoid'):LoadAnimation(carpetAnim)
			carpet:Play(.1, 1, 1)
			local carpetplr = Players[v].Name
			carpetDied = speaker.Character:FindFirstChildOfClass'Humanoid'.Died:Connect(function()
				carpetLoop:Disconnect()
				carpet:Stop()
				carpetAnim:Destroy()
				carpetDied:Disconnect()
			end)
			carpetLoop = RunService.Heartbeat:Connect(function()
				pcall(function()
					getRoot(Players.LocalPlayer.Character).CFrame = getRoot(Players[carpetplr].Character).CFrame
				end)
			end)
		end
	else
		notify('R6 Required','This command requires the r6 rig type')
	end
end)

addcmd('uncarpet',{'nocarpet'},function(args, speaker)
	if carpetLoop then
		carpetLoop:Disconnect()
		carpetDied:Disconnect()
		carpet:Stop()
		carpetAnim:Destroy()
	end
end)

addcmd('friend',{},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players)do
		speaker:RequestFriendship(Players[v])
	end
end)

addcmd('unfriend',{},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players)do
		speaker:RevokeFriendship(Players[v])
	end
end)

addcmd('bringpart',{},function(args, speaker)
	for i,v in pairs(workspace:GetDescendants()) do
		if v.Name:lower() == getstring(1, args):lower() and v:IsA("BasePart") then
			v.CFrame = getRoot(speaker.Character).CFrame
		end
	end
end)

addcmd('bringpartclass',{'bpc'},function(args, speaker)
	for i,v in pairs(workspace:GetDescendants()) do
		if v.ClassName:lower() == getstring(1, args):lower() and v:IsA("BasePart") then
			v.CFrame = getRoot(speaker.Character).CFrame
		end
	end
end)

gotopartDelay = 0.1
addcmd('gotopart',{'topart'},function(args, speaker)
	for i,v in pairs(workspace:GetDescendants()) do
		if v.Name:lower() == getstring(1, args):lower() and v:IsA("BasePart") then
			if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
				speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
				wait(.1)
			end
			wait(gotopartDelay)
			getRoot(speaker.Character).CFrame = v.CFrame
		end
	end
end)

addcmd('tweengotopart',{'tgotopart','ttopart'},function(args, speaker)
	for i,v in pairs(workspace:GetDescendants()) do
		if v.Name:lower() == getstring(1, args):lower() and v:IsA("BasePart") then
			if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
				speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
				wait(.1)
			end
			wait(gotopartDelay)
			TweenService:Create(getRoot(speaker.Character), TweenInfo.new(tweenSpeed, Enum.EasingStyle.Linear), {CFrame = v.CFrame}):Play()
		end
	end
end)

addcmd('gotopartclass',{'gpc'},function(args, speaker)
	for i,v in pairs(workspace:GetDescendants()) do
		if v.ClassName:lower() == getstring(1, args):lower() and v:IsA("BasePart") then
			if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
				speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
				wait(.1)
			end
			wait(gotopartDelay)
			getRoot(speaker.Character).CFrame = v.CFrame
		end
	end
end)

addcmd('tweengotopartclass',{'tgpc'},function(args, speaker)
	for i,v in pairs(workspace:GetDescendants()) do
		if v.ClassName:lower() == getstring(1, args):lower() and v:IsA("BasePart") then
			if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
				speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
				wait(.1)
			end
			wait(gotopartDelay)
			TweenService:Create(getRoot(speaker.Character), TweenInfo.new(tweenSpeed, Enum.EasingStyle.Linear), {CFrame = v.CFrame}):Play()
		end
	end
end)

addcmd('gotomodel',{'tomodel'},function(args, speaker)
	for i,v in pairs(workspace:GetDescendants()) do
		if v.Name:lower() == getstring(1, args):lower() and v:IsA("Model") then
			if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
				speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
				wait(.1)
			end
			wait(gotopartDelay)
			getRoot(speaker.Character).CFrame = v:GetModelCFrame()
		end
	end
end)

addcmd('tweengotomodel',{'tgotomodel','ttomodel'},function(args, speaker)
	for i,v in pairs(workspace:GetDescendants()) do
		if v.Name:lower() == getstring(1, args):lower() and v:IsA("Model") then
			if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
				speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
				wait(.1)
			end
			wait(gotopartDelay)
			TweenService:Create(getRoot(speaker.Character), TweenInfo.new(tweenSpeed, Enum.EasingStyle.Linear), {CFrame = v:GetModelCFrame()}):Play()
		end
	end
end)

addcmd('gotopartdelay',{},function(args, speaker)
	local gtpDelay = args[1] or 0.1
	if isNumber(gtpDelay) then
		gotopartDelay = gtpDelay
	end
end)

addcmd('noclickdetectorlimits',{'nocdlimits','removecdlimits'},function(args, speaker)
	for i,v in ipairs(workspace:GetDescendants()) do
		if v:IsA("ClickDetector") then
			v.MaxActivationDistance = math.huge
		end
	end
end)

addcmd('fireclickdetectors',{'firecd','firecds'}, function(args, speaker)
	if fireclickdetector then
		if args[1] then
			local name = getstring(1, args):lower()
			for _, descendant in ipairs(workspace:GetDescendants()) do
				if descendant:IsA("ClickDetector") and descendant.Name:lower() == name or descendant.Parent.Name:lower() == name then
					fireclickdetector(descendant)
				end
			end
		else
			for _, descendant in ipairs(workspace:GetDescendants()) do
				if descendant:IsA("ClickDetector") then
					fireclickdetector(descendant)
				end
			end
		end
	else
		notify("Incompatible Exploit", "Your exploit does not support this command (missing fireclickdetector)")
	end
end)

addcmd('noproximitypromptlimits',{'nopplimits','removepplimits'},function(args, speaker)
	for i,v in pairs(workspace:GetDescendants()) do
		if v:IsA("ProximityPrompt") then
			v.MaxActivationDistance = math.huge
		end
	end
end)

addcmd('fireproximityprompts',{'firepp'},function(args, speaker)
	if fireproximityprompt then
		if args[1] then
			local name = getstring(1, args)
			for _, descendant in ipairs(workspace:GetDescendants()) do
				if descendant:IsA("ProximityPrompt") and descendant.Name == name or descendant.Parent.Name == name then
					fireproximityprompt(descendant)
				end
			end
		else
			for _, descendant in ipairs(workspace:GetDescendants()) do
				if descendant:IsA("ProximityPrompt") then
					fireproximityprompt(descendant)
				end
			end
		end
	else
		notify("Incompatible Exploit", "Your exploit does not support this command (missing fireproximityprompt)")
	end
end)

local PromptButtonHoldBegan = nil
addcmd('instantproximityprompts',{'instantpp'},function(args, speaker)
	if fireproximityprompt then
		execCmd("uninstantproximityprompts")
		wait(0.1)
		PromptButtonHoldBegan = ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt)
			fireproximityprompt(prompt)
		end)
	else
		notify('Incompatible Exploit','Your exploit does not support this command (missing fireproximityprompt)')
	end
end)

addcmd('uninstantproximityprompts',{'uninstantpp'},function(args, speaker)
	if PromptButtonHoldBegan ~= nil then
		PromptButtonHoldBegan:Disconnect()
		PromptButtonHoldBegan = nil
	end
end)

addcmd('notifyping',{'ping'},function(args, speaker)
	notify("Ping", math.round(speaker:GetNetworkPing() * 1000) .. "ms")
end)

addcmd('grabtools', {}, function(args, speaker)
	local humanoid = speaker.Character:FindFirstChildWhichIsA("Humanoid")
	for _, child in ipairs(workspace:GetChildren()) do
		if speaker.Character and child:IsA("BackpackItem") and child:FindFirstChild("Handle") then
			humanoid:EquipTool(child)
		end
	end

	if grabtoolsFunc then 
		grabtoolsFunc:Disconnect() 
	end

	grabtoolsFunc = workspace.ChildAdded:Connect(function(child)
		if speaker.Character and child:IsA("BackpackItem") and child:FindFirstChild("Handle") then
			humanoid:EquipTool(child)
		end
	end)

	notify("Grabtools", "Picking up any dropped tools")
end)

addcmd('nograbtools',{'ungrabtools'},function(args, speaker)
	if grabtoolsFunc then 
		grabtoolsFunc:Disconnect() 
	end

	notify("Grabtools", "Grabtools has been disabled")
end)

local specifictoolremoval = {}
addcmd('removespecifictool',{},function(args, speaker)
	if args[1] and speaker:FindFirstChildOfClass("Backpack") then
		local tool = string.lower(getstring(1, args))
		local RST = RunService.RenderStepped:Connect(function()
			if speaker:FindFirstChildOfClass("Backpack") then
				for i,v in pairs(speaker:FindFirstChildOfClass("Backpack"):GetChildren()) do
					if v.Name:lower() == tool then
						v:Remove()
					end
				end
			end
		end)
		specifictoolremoval[tool] = RST
	end
end)

addcmd('unremovespecifictool',{},function(args, speaker)
	if args[1] then
		local tool = string.lower(getstring(1, args))
		if specifictoolremoval[tool] ~= nil then
			specifictoolremoval[tool]:Disconnect()
			specifictoolremoval[tool] = nil
		end
	end
end)

addcmd('clearremovespecifictool',{},function(args, speaker)
	for obj in pairs(specifictoolremoval) do
		specifictoolremoval[obj]:Disconnect()
		specifictoolremoval[obj] = nil
	end
end)

addcmd('light',{},function(args, speaker)
	local light = Instance.new("PointLight")
	light.Parent = getRoot(speaker.Character)
	light.Range = 30
	if args[1] then
		light.Brightness = args[2]
		light.Range = args[1]
	else
		light.Brightness = 5
	end
end)

addcmd('unlight',{'nolight'},function(args, speaker)
	for i,v in pairs(speaker.Character:GetDescendants()) do
		if v.ClassName == "PointLight" then
			v:Destroy()
		end
	end
end)

addcmd('copytools',{},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players)do
		task.spawn(function()
			for i,v in pairs(Players[v]:FindFirstChildOfClass("Backpack"):GetChildren()) do
				if v:IsA('Tool') or v:IsA('HopperBin') then
					v:Clone().Parent = speaker:FindFirstChildOfClass("Backpack")
				end
			end
		end)
	end
end)

addcmd('naked',{},function(args, speaker)
	for i,v in pairs(speaker.Character:GetDescendants()) do
		if v:IsA("Clothing") or v:IsA("ShirtGraphic") then
			v:Destroy()
		end
	end
end)

addcmd('noface',{'removeface'},function(args, speaker)
	for i,v in pairs(speaker.Character:GetDescendants()) do
		if v:IsA("Decal") and v.Name == 'face' then
			v:Destroy()
		end
	end
end)

addcmd('spawnpoint',{'spawn'},function(args, speaker)
	spawnpos = getRoot(speaker.Character).CFrame
	spawnpoint = true
	spDelay = tonumber(args[1]) or 0.1
	notify('Spawn Point','Spawn point created at '..tostring(spawnpos))
end)

addcmd('nospawnpoint',{'nospawn','removespawnpoint'},function(args, speaker)
	spawnpoint = false
	notify('Spawn Point','Removed spawn point')
end)

addcmd('flashback',{'diedtp'},function(args, speaker)
	if lastDeath ~= nil then
		if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
			speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
			wait(.1)
		end
		getRoot(speaker.Character).CFrame = lastDeath
	end
end)

addcmd('hatspin',{'spinhats'},function(args, speaker)
	execCmd('unhatspin')
	wait(.5)
	for _,v in pairs(speaker.Character:FindFirstChildOfClass('Humanoid'):GetAccessories()) do
		local keep = Instance.new("BodyPosition") keep.Name = randomString() keep.Parent = v.Handle
		local spin = Instance.new("BodyAngularVelocity") spin.Name = randomString() spin.Parent = v.Handle
		v.Handle:FindFirstChildOfClass("Weld"):Destroy()
		if args[1] then
			spin.AngularVelocity = Vector3.new(0, args[1], 0)
			spin.MaxTorque = Vector3.new(0, args[1] * 2, 0)
		else
			spin.AngularVelocity = Vector3.new(0, 100, 0)
			spin.MaxTorque = Vector3.new(0, 200, 0)
		end
		keep.P = 30000
		keep.D = 50
		spinhats = RunService.Stepped:Connect(function()
			pcall(function()
				keep.Position = Players.LocalPlayer.Character.Head.Position
			end)
		end)
	end
end)

addcmd('unhatspin',{'unspinhats'},function(args, speaker)
	if spinhats then
		spinhats:Disconnect()
	end
	for _,v in pairs(speaker.Character:FindFirstChildOfClass('Humanoid'):GetAccessories()) do
		v.Parent = workspace
		for i,c in pairs(v.Handle) do
			if c:IsA("BodyPosition") or c:IsA("BodyAngularVelocity") then
				c:Destroy()
			end
		end
		wait()
		v.Parent = speaker.Character
	end
end)

addcmd('clearhats',{'cleanhats'},function(args, speaker)
	if firetouchinterest then
		local Player = Players.LocalPlayer
		local Character = Player.Character
		local Old = getRoot(Character).CFrame
		local Hats = {}

		for _, child in ipairs(workspace:GetChildren()) do
			if child:IsA("Accessory") then
				table.insert(Hats, child)
			end
		end

		for _, accessory in ipairs(Character:FindFirstChildOfClass("Humanoid"):GetAccessories()) do
			accessory:Destroy()
		end

		for i = 1, #Hats do
			repeat RunService.Heartbeat:wait() until Hats[i]
			firetouchinterest(Hats[i].Handle,getRoot(Character),0)
			repeat RunService.Heartbeat:wait() until Character:FindFirstChildOfClass("Accessory")
			Character:FindFirstChildOfClass("Accessory"):Destroy()
			repeat RunService.Heartbeat:wait() until not Character:FindFirstChildOfClass("Accessory")
		end

		execCmd("reset")

		Player.CharacterAdded:Wait()

		for i = 1,20 do 
			RunService.Heartbeat:Wait()
			if getRoot(Player.Character) then
				getRoot(Player.Character).Humanoid.RootPart.CFrame = Old
			end
		end
	else
		notify("Incompatible Exploit","Your exploit does not support this command (missing firetouchinterest)")
	end
end)

addcmd('split',{},function(args, speaker)
	if r15(speaker) then
		speaker.Character.UpperTorso.Waist:Destroy()
	else
		notify('R15 Required','This command requires the r15 rig type')
	end
end)

addcmd('nilchar',{},function(args, speaker)
	if speaker.Character ~= nil then
		speaker.Character.Parent = nil
	end
end)

addcmd('unnilchar',{'nonilchar'},function(args, speaker)
	if speaker.Character ~= nil then
		speaker.Character.Parent = workspace
	end
end)

addcmd('noroot',{'removeroot','rroot'},function(args, speaker)
	if speaker.Character ~= nil then
		local char = Players.LocalPlayer.Character
		char.Parent = nil
		char.Humanoid.RootPart:Destroy()
		char.Parent = workspace
	end
end)

addcmd('replaceroot',{'replacerootpart'},function(args, speaker)
	if speaker.Character ~= nil and getRoot(speaker.Character) then
		local Char = speaker.Character
		local OldParent = Char.Parent
		local HRP = Char and getRoot(Char)
		local OldPos = HRP.CFrame
		Char.Parent = game
		local HRP1 = HRP:Clone()
		HRP1.Parent = Char
		HRP = HRP:Destroy()
		HRP1.CFrame = OldPos
		Char.Parent = OldParent
	end
end)

addcmd('clearcharappearance',{'clearchar','clrchar'},function(args, speaker)
	speaker:ClearCharacterAppearance()
end)

addcmd('equiptools',{},function(args, speaker)
	for i,v in pairs(speaker:FindFirstChildOfClass("Backpack"):GetChildren()) do
		if v:IsA("Tool") or v:IsA("HopperBin") then
			v.Parent = speaker.Character
		end
	end
end)

addcmd('unequiptools',{},function(args, speaker)
	speaker.Character:FindFirstChildOfClass('Humanoid'):UnequipTools()
end)

local function GetHandleTools(p)
	p = p or Players.LocalPlayer
	local r = {}
	for _, v in ipairs(p.Character and p.Character:GetChildren() or {}) do
		if v.IsA(v, "BackpackItem") and v.FindFirstChild(v, "Handle") then
			r[#r + 1] = v
		end
	end
	for _, v in ipairs(p.Backpack:GetChildren()) do
		if v.IsA(v, "BackpackItem") and v.FindFirstChild(v, "Handle") then
			r[#r + 1] = v
		end
	end
	return r
end
addcmd('dupetools', {'clonetools'}, function(args, speaker)
	local LOOP_NUM = tonumber(args[1]) or 1
	local OrigPos = speaker.Character.Humanoid.RootPart.Position
	local Tools, TempPos = {}, Vector3.new(math.random(-2e5, 2e5), 2e5, math.random(-2e5, 2e5))
	for i = 1, LOOP_NUM do
		local Human = speaker.Character:WaitForChild("Humanoid")
		wait(.1, Human.Parent:MoveTo(TempPos))
		Human.RootPart.Anchored = speaker:ClearCharacterAppearance(wait(.1)) or true
		local t = GetHandleTools(speaker)
		while #t > 0 do
			for _, v in ipairs(t) do
				task.spawn(function()
					for _ = 1, 25 do
						v.Parent = speaker.Character
						v.Handle.Anchored = true
					end
					for _ = 1, 5 do
						v.Parent = workspace
					end
					table.insert(Tools, v.Handle)
				end)
			end
			t = GetHandleTools(speaker)
		end
		wait(.1)
		speaker.Character = speaker.Character:Destroy()
		speaker.CharacterAdded:Wait():WaitForChild("Humanoid").Parent:MoveTo(LOOP_NUM == i and OrigPos or TempPos, wait(.1))
		if i == LOOP_NUM or i % 5 == 0 then
			local HRP = speaker.Character.Humanoid.RootPart
			if type(firetouchinterest) == "function" then
				for _, v in ipairs(Tools) do
					v.Anchored = not firetouchinterest(v, HRP, 1, firetouchinterest(v, HRP, 0)) and false or false
				end
			else
				for _, v in ipairs(Tools) do
					task.spawn(function()
						local x = v.CanCollide
						v.CanCollide = false
						v.Anchored = false
						for _ = 1, 10 do
							v.CFrame = HRP.CFrame
							wait()
						end
						v.CanCollide = x
					end)
				end
			end
			wait(.1)
			Tools = {}
		end
		TempPos = TempPos + Vector3.new(10, math.random(-5, 5), 0)
	end
end)

addcmd('touchinterests', {'touchinterest', 'firetouchinterests', 'firetouchinterest'}, function(args, speaker)
	local Root = getRoot(speaker.Character) or speaker.Character:FindFirstChildWhichIsA("BasePart")

	if not firetouchinterest then
		notify("Incompatible Exploit", "Your exploit does not support this command (missing firetouchinterest)")
		return
	end

	local function Touch(x)
		x = x.FindFirstAncestorWhichIsA(x, "Part")
		if x then
			return task.spawn(function()
				firetouchinterest(x, Root, 1, wait() and firetouchinterest(x, Root, 0))
			end)
		end
		x.CFrame = Root.CFrame
	end

	if args[1] then
		local name = getstring(1, args):lower()
		print(name..' -name')
		for _, v in ipairs(workspace:GetDescendants()) do
			if v:IsA("TouchTransmitter") and v.Name:lower() == name or v.Parent.Name:lower() == name then
				Touch(v)
			end
		end
	else
		for _, v in ipairs(workspace:GetDescendants()) do
			if v.IsA(v, "TouchTransmitter") then
				Touch(v)
			end
		end
	end
end)

addcmd('fullbright',{'fb','fullbrightness'},function(args, speaker)
	Lighting.Brightness = 2
	Lighting.ClockTime = 14
	Lighting.FogEnd = 100000
	Lighting.GlobalShadows = false
	Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
end)

addcmd('loopfullbright',{'loopfb'},function(args, speaker)
	if brightLoop then
		brightLoop:Disconnect()
	end
	local function brightFunc()
		Lighting.Brightness = 2
		Lighting.ClockTime = 14
		Lighting.FogEnd = 100000
		Lighting.GlobalShadows = false
		Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
	end

	brightLoop = RunService.RenderStepped:Connect(brightFunc)
end)

addcmd('unloopfullbright',{'unloopfb'},function(args, speaker)
	if brightLoop then
		brightLoop:Disconnect()
	end
end)

addcmd('ambient',{},function(args, speaker)
	Lighting.Ambient = Color3.new(args[1],args[2],args[3])
	Lighting.OutdoorAmbient = Color3.new(args[1],args[2],args[3])
end)

addcmd('day',{},function(args, speaker)
	Lighting.ClockTime = 14
end)

addcmd('night',{},function(args, speaker)
	Lighting.ClockTime = 0
end)

addcmd('nofog',{},function(args, speaker)
	Lighting.FogEnd = 100000
	for i,v in pairs(Lighting:GetDescendants()) do
		if v:IsA("Atmosphere") then
			v:Destroy()
		end
	end
end)

addcmd('brightness',{},function(args, speaker)
	Lighting.Brightness = args[1]
end)

addcmd('globalshadows',{'gshadows'},function(args, speaker)
	Lighting.GlobalShadows = true
end)

addcmd('unglobalshadows',{'nogshadows','ungshadows','noglobalshadows'},function(args, speaker)
	Lighting.GlobalShadows = false
end)

origsettings = {abt = Lighting.Ambient, oabt = Lighting.OutdoorAmbient, brt = Lighting.Brightness, time = Lighting.ClockTime, fe = Lighting.FogEnd, fs = Lighting.FogStart, gs = Lighting.GlobalShadows}

addcmd('restorelighting',{'rlighting'},function(args, speaker)
	Lighting.Ambient = origsettings.abt
	Lighting.OutdoorAmbient = origsettings.oabt
	Lighting.Brightness = origsettings.brt
	Lighting.ClockTime = origsettings.time
	Lighting.FogEnd = origsettings.fe
	Lighting.FogStart = origsettings.fs
	Lighting.GlobalShadows = origsettings.gs
end)

addcmd('stun',{'platformstand'},function(args, speaker)
	speaker.Character:FindFirstChildOfClass('Humanoid').PlatformStand = true
end)

addcmd('unstun',{'nostun','unplatformstand','noplatformstand'},function(args, speaker)
	speaker.Character:FindFirstChildOfClass('Humanoid').PlatformStand = false
end)

addcmd('norotate',{'noautorotate'},function(args, speaker)
	speaker.Character:FindFirstChildOfClass('Humanoid').AutoRotate  = false
end)

addcmd('unnorotate',{'autorotate'},function(args, speaker)
	speaker.Character:FindFirstChildOfClass('Humanoid').AutoRotate  = true
end)

addcmd('enablestate',{},function(args, speaker)
	local x = args[1]
	if not tonumber(x) then
		local x = Enum.HumanoidStateType[args[1]]
	end
	speaker.Character:FindFirstChildOfClass("Humanoid"):SetStateEnabled(x, true)
end)

addcmd('disablestate',{},function(args, speaker)
	local x = args[1]
	if not tonumber(x) then
		local x = Enum.HumanoidStateType[args[1]]
	end
	speaker.Character:FindFirstChildOfClass("Humanoid"):SetStateEnabled(x, false)
end)

addcmd('drophats',{'drophat'},function(args, speaker)
	if speaker.Character then
		for _,v in pairs(speaker.Character:FindFirstChildOfClass('Humanoid'):GetAccessories()) do
			v.Parent = workspace
		end
	end
end)

addcmd('deletehats',{'nohats','rhats'},function(args, speaker)
	for i,v in next, speaker.Character:GetDescendants() do
		if v:IsA("Accessory") then
			for i,p in next, v:GetDescendants() do
				if p:IsA("Weld") then
					p:Destroy()
				end
			end
		end
	end
end)

addcmd('droptools',{'droptool'},function(args, speaker)
	for i,v in pairs(Players.LocalPlayer.Backpack:GetChildren()) do
		if v:IsA("Tool") then
			v.Parent = Players.LocalPlayer.Character
		end
	end
	wait()
	for i,v in pairs(Players.LocalPlayer.Character:GetChildren()) do
		if v:IsA("Tool") then
			v.Parent = workspace
		end
	end
end)

addcmd('droppabletools',{},function(args, speaker)
	if speaker.Character then
		for _,obj in pairs(speaker.Character:GetChildren()) do
			if obj:IsA("Tool") then
				obj.CanBeDropped = true
			end
		end
	end
	if speaker:FindFirstChildOfClass("Backpack") then
		for _,obj in pairs(speaker:FindFirstChildOfClass("Backpack"):GetChildren()) do
			if obj:IsA("Tool") then
				obj.CanBeDropped = true
			end
		end
	end
end)

local currentToolSize = ""
local currentGripPos = ""
addcmd('reach',{},function(args, speaker)
	execCmd('unreach')
	wait()
	for i,v in pairs(speaker.Character:GetDescendants()) do
		if v:IsA("Tool") then
			if args[1] then
				currentToolSize = v.Handle.Size
				currentGripPos = v.GripPos
				local a = Instance.new("SelectionBox")
				a.Name = "SelectionBoxCreated"
				a.Parent = v.Handle
				a.Adornee = v.Handle
				v.Handle.Massless = true
				v.Handle.Size = Vector3.new(0.5,0.5,args[1])
				v.GripPos = Vector3.new(0,0,0)
				speaker.Character:FindFirstChildOfClass('Humanoid'):UnequipTools()
			else
				currentToolSize = v.Handle.Size
				currentGripPos = v.GripPos
				local a = Instance.new("SelectionBox")
				a.Name = "SelectionBoxCreated"
				a.Parent = v.Handle
				a.Adornee = v.Handle
				v.Handle.Massless = true
				v.Handle.Size = Vector3.new(0.5,0.5,60)
				v.GripPos = Vector3.new(0,0,0)
				speaker.Character:FindFirstChildOfClass('Humanoid'):UnequipTools()
			end
		end
	end
end)

addcmd("boxreach", {}, function(args, speaker)
	execCmd("unreach")
	wait()
	for i, v in pairs(speaker.Character:GetDescendants()) do
		if v:IsA("Tool") then
			local size = tonumber(args[1]) or 60
			currentToolSize = v.Handle.Size
			currentGripPos = v.GripPos
			local a = Instance.new("SelectionBox")
			a.Name = "SelectionBoxCreated"
			a.Parent = v.Handle
			a.Adornee = v.Handle
			v.Handle.Massless = true
			v.Handle.Size = Vector3.new(size, size, size)
			v.GripPos = Vector3.new(0, 0, 0)
			speaker.Character:FindFirstChildOfClass("Humanoid"):UnequipTools()
		end
	end
end)

addcmd('unreach',{'noreach','unboxreach'},function(args, speaker)
	for i,v in pairs(speaker.Character:GetDescendants()) do
		if v:IsA("Tool") then
			v.Handle.Size = currentToolSize
			v.GripPos = currentGripPos
			v.Handle.SelectionBoxCreated:Destroy()
		end
	end
end)

addcmd('grippos',{},function(args, speaker)
	for i,v in pairs(speaker.Character:GetDescendants()) do
		if v:IsA("Tool") then
			v.Parent = speaker:FindFirstChildOfClass("Backpack")
			v.GripPos = Vector3.new(args[1],args[2],args[3])
			v.Parent = speaker.Character
		end
	end
end)

addcmd('usetools', {}, function(args, speaker)
	local Backpack = speaker:FindFirstChildOfClass("Backpack")
	local amount = tonumber(args[1]) or 1
	local delay_ = tonumber(args[2]) or false
	for _, v in ipairs(Backpack:GetChildren()) do
		v.Parent = speaker.Character
		task.spawn(function()
			for _ = 1, amount do
				v:Activate()
				if delay_ then
					wait(delay_)
				end
			end
			v.Parent = Backpack
		end)
	end
end)

addcmd("logs", {}, function(args, speaker)
	logsEnabled = true
	jLogsEnabled = true
	Toggle.Text = "Enabled"
	Toggle_2.Text = "Enabled"
	logs:TweenPosition(UDim2.new(0, 0, 1, -265), "InOut", "Quart", 0.3, true, nil)
end)

addcmd("chatlogs", {"clogs"}, function(args, speaker)
	logsEnabled = true
	join.Visible = false
	chat.Visible = true
	table.remove(shade3, table.find(shade3, selectChat))
	table.remove(shade2, table.find(shade2, selectJoin))
	table.insert(shade2, selectChat)
	table.insert(shade3, selectJoin)
	selectJoin.BackgroundColor3 = currentShade3
	selectChat.BackgroundColor3 = currentShade2
	Toggle.Text = "Enabled"
	logs:TweenPosition(UDim2.new(0, 0, 1, -265), "InOut", "Quart", 0.3, true, nil)
end)

addcmd("joinlogs", {"jlogs"}, function(args, speaker)
	jLogsEnabled = true
	chat.Visible = false
	join.Visible = true	
	table.remove(shade3, table.find(shade3, selectJoin))
	table.remove(shade2, table.find(shade2, selectChat))
	table.insert(shade2, selectJoin)
	table.insert(shade3, selectChat)
	selectChat.BackgroundColor3 = currentShade3
	selectJoin.BackgroundColor3 = currentShade2
	Toggle_2.Text = "Enabled"
	logs:TweenPosition(UDim2.new(0, 0, 1, -265), "InOut", "Quart", 0.3, true, nil)
end)

addcmd("chatlogswebhook", {"logswebhook"}, function(args, speaker)
	if not httprequest then
		return notify("Incompatible Exploit", "Your exploit does not support this command (missing request)")
	end
	logsWebhook = args[1] or nil
	updatesaves()
end)

flinging = false
addcmd('fling',{},function(args, speaker)
	flinging = false
	for _, child in next, speaker.Character:GetDescendants() do
		if child:IsA("BasePart") then
			child.CustomPhysicalProperties = PhysicalProperties.new(100, 0.3, 0.5)
		end
	end
	execCmd('noclip nonotify')
	task.wait(.1)
	local bambam = Instance.new("BodyAngularVelocity")
	bambam.Name = randomString()
	bambam.Parent = getRoot(speaker.Character)
	bambam.AngularVelocity = Vector3.new(0,99999,0)
	bambam.MaxTorque = Vector3.new(0,math.huge,0)
	bambam.P = math.huge
	for i, v in next, speaker.Character:GetChildren() do
		if v:IsA("BasePart") then
			v.Massless = true
			v.Velocity = Vector3.zero
		end
	end
	flinging = true
	flingDied = speaker.Character:FindFirstChildOfClass('Humanoid').Died:Connect(function()
		execCmd('unfling')
	end)
	repeat
		bambam.AngularVelocity = Vector3.new(0,99999,0)
		task.wait(.2)
		bambam.AngularVelocity = Vector3.new(0,0,0)
		task.wait(.1)
	until flinging == false
end)

addcmd('unfling',{'nofling'},function(args, speaker)
	execCmd('clip nonotify')
	if flingDied then flingDied:Disconnect() end
	flinging = false
	task.wait(.1)
	local speakerChar = speaker.Character
	if not speakerChar or not getRoot(speakerChar) then return end
	for _, v in next, speakerChar:GetDescendants() do
		if v:IsA("BasePart") then
			v.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5)
			v.Massless = false
			v.Velocity = Vector3.zero
		elseif v:IsA("BodyAngularVelocity") then
			v:Destroy()
		end
	end
end)

addcmd('togglefling',{},function(args, speaker)
	if flinging then
		execCmd('unfling')
	else
		execCmd('fling')
	end
end)

addcmd("flyfling", {}, function(args, speaker)
	execCmd("unvehiclefly\\unwalkfling")
	task.wait()
	vehicleflyspeed = tonumber(args[1]) or vehicleflyspeed
	execCmd("vehiclefly\\walkfling")
end)

addcmd("unflyfling", {}, function(args, speaker)
	execCmd("unvehiclefly\\unwalkfling\\breakvelocity")
end)

addcmd("toggleflyfling", {}, function(args, speaker)
	execCmd(flinging and "unflyfling" or "flyfling")
end)

walkflinging = false
addcmd("walkfling", {}, function(args, speaker)
	execCmd("unwalkfling")
	local humanoid = speaker.Character:FindFirstChildWhichIsA("Humanoid")
	if humanoid then
		humanoid.Died:Connect(function()
			execCmd("unwalkfling")
		end)
	end

	execCmd("noclip nonotify")
	walkflinging = true
	repeat RunService.Heartbeat:Wait()
		local character = speaker.Character
		local root = getRoot(character)
		local vel, movel = nil, 0.1

		while not (character and character.Parent and root and root.Parent) do
			RunService.Heartbeat:Wait()
			character = speaker.Character
			root = getRoot(character)
		end

		vel = root.Velocity
		root.Velocity = vel * 10000 + Vector3.new(0, 10000, 0)

		RunService.RenderStepped:Wait()
		if character and character.Parent and root and root.Parent then
			root.Velocity = vel
		end

		RunService.Stepped:Wait()
		if character and character.Parent and root and root.Parent then
			root.Velocity = vel + Vector3.new(0, movel, 0)
			movel = movel * -1
		end
	until walkflinging == false
end)

addcmd("unwalkfling", {"nowalkfling"}, function(args, speaker)
	walkflinging = false
	execCmd("unnoclip nonotify")
end)

addcmd("togglewalkfling", {}, function(args, speaker)
	execCmd(walkflinging and "unwalkfling" or "walkfling")
end)

addcmd('invisfling',{},function(args, speaker)
	local ch = speaker.Character
	ch:FindFirstChildWhichIsA("Humanoid"):SetStateEnabled(Enum.HumanoidStateType.Dead, false)
	local prt=Instance.new("Model")
	prt.Parent = speaker.Character
	local z1 = Instance.new("Part")
	z1.Name="Torso"
	z1.CanCollide = false
	z1.Anchored = true
	local z2 = Instance.new("Part")
	z2.Name="Head"
	z2.Parent = prt
	z2.Anchored = true
	z2.CanCollide = false
	local z3 =Instance.new("Humanoid")
	z3.Name="Humanoid"
	z3.Parent = prt
	z1.Position = Vector3.new(0,9999,0)
	speaker.Character=prt
	wait(3)
	speaker.Character=ch
	wait(3)
	local Hum = Instance.new("Humanoid")
	z2:Clone()
	Hum.Parent = speaker.Character
	local root =  getRoot(speaker.Character)
	for i,v in pairs(speaker.Character:GetChildren()) do
		if v ~= root and  v.Name ~= "Humanoid" then
			v:Destroy()
		end
	end
	root.Transparency = 0
	root.Color = Color3.new(1, 1, 1)
	local invisflingStepped
	invisflingStepped = RunService.Stepped:Connect(function()
		if speaker.Character and getRoot(speaker.Character) then
			getRoot(speaker.Character).CanCollide = false
		else
			invisflingStepped:Disconnect()
		end
	end)
	sFLY()
	workspace.CurrentCamera.CameraSubject = root
	local bambam = Instance.new("BodyThrust")
	bambam.Parent = getRoot(speaker.Character)
	bambam.Force = Vector3.new(99999,99999*10,99999)
	bambam.Location = getRoot(speaker.Character).Position
end)

addcmd("antifling", {}, function(args, speaker)
	if antifling then
		antifling:Disconnect()
		antifling = nil
	end
	antifling = RunService.Stepped:Connect(function()
		for _, player in pairs(Players:GetPlayers()) do
			if player ~= speaker and player.Character then
				for _, v in pairs(player.Character:GetDescendants()) do
					if v:IsA("BasePart") then
						v.CanCollide = false
					end
				end
			end
		end
	end)
end)

addcmd("unantifling", {}, function(args, speaker)
	if antifling then
		antifling:Disconnect()
		antifling = nil
	end
end)

addcmd("toggleantifling", {}, function(args, speaker)
	execCmd(antifling and "unantifling" or "antifling")
end)

function attach(speaker,target)
	if tools(speaker) then
		local char = speaker.Character
		local tchar = target.Character
		local hum = speaker.Character:FindFirstChildOfClass("Humanoid")
		local hrp = getRoot(speaker.Character)
		local hrp2 = getRoot(target.Character)
		hum.Name = "1"
		local newHum = hum:Clone()
		newHum.Parent = char
		newHum.Name = "Humanoid"
		wait()
		hum:Destroy()
		workspace.CurrentCamera.CameraSubject = char
		newHum.DisplayDistanceType = "None"
		local tool = speaker:FindFirstChildOfClass("Backpack"):FindFirstChildOfClass("Tool") or speaker.Character:FindFirstChildOfClass("Tool")
		tool.Parent = char
		hrp.CFrame = hrp2.CFrame * CFrame.new(0, 0, 0) * CFrame.new(math.random(-100, 100)/200,math.random(-100, 100)/200,math.random(-100, 100)/200)
		local n = 0
		repeat
			wait(.1)
			n = n + 1
			hrp.CFrame = hrp2.CFrame
		until (tool.Parent ~= char or not hrp or not hrp2 or not hrp.Parent or not hrp2.Parent or n > 250) and n > 2
	else
		notify('Tool Required','You need to have an item in your inventory to use this command')
	end
end

function kill(speaker,target,fast)
	if tools(speaker) then
		if target ~= nil then
			local NormPos = getRoot(speaker.Character).CFrame
			if not fast then
				refresh(speaker)
				wait()
				repeat wait() until speaker.Character ~= nil and getRoot(speaker.Character)
				wait(0.3)
			end
			local hrp = getRoot(speaker.Character)
			attach(speaker,target)
			repeat
				wait()
				hrp.CFrame = CFrame.new(999999, workspace.FallenPartsDestroyHeight + 5,999999)
			until not getRoot(target.Character) or not getRoot(speaker.Character)
			local char = speaker.CharacterAdded:Wait()
			local humanoid = char:FindFirstChildOfClass("Humanoid") or char.ChildAdded:Wait()
			while not humanoid:IsA("Humanoid") do
				humanoid = char:FindFirstChildOfClass("Humanoid") or char.ChildAdded:Wait()
			end
			humanoid.RootPart.CFrame = NormPos
		end
	else
		notify('Tool Required','You need to have an item in your inventory to use this command')
	end
end

addcmd("handlekill", {"hkill"}, function(args, speaker)
	if not firetouchinterest then
		return notify("Incompatible Exploit", "Your exploit does not support this command (missing firetouchinterest)")
	end
	if not speaker.Character then return end
	local tool = speaker.Character:FindFirstChildWhichIsA("Tool")
	local handle = tool and tool:FindFirstChild("Handle")
	if not handle then
		return notify("Handle Kill", "You need to hold a \"Tool\" that does damage on touch. For example a common Sword tool.")
	end
	local range = tonumber(args[2]) or math.huge
	if range ~= math.huge then notify("Handle Kill", ("Started!\nRadius: %s"):format(tostring(range):upper())) end

	while task.wait() and speaker.Character and tool.Parent and tool.Parent == speaker.Character do
		for _, plr in next, getPlayer(args[1], speaker) do
			plr = Players[plr]
			if plr ~= speaker and plr.Character then
				local hum = plr.Character:FindFirstChildWhichIsA("Humanoid")
				local root = hum and getRoot(plr.Character)

				if root and hum.Health > 0 and hum:GetState() ~= Enum.HumanoidStateType.Dead and speaker:DistanceFromCharacter(root.Position) <= range then
					firetouchinterest(handle, root, 1)
					firetouchinterest(handle, root, 0)
				end
			end
		end
	end

	notify("Handle Kill", "Stopped!")
end)

tpwalkStack = 0
addcmd("teleportwalk", {"tpwalk"}, function(args, speaker)
    pcall(function() tpwalking:Disconnect() end)

    local character = speaker.Character
    local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
    local speed = (args[1] and isNumber(args[1])) and tonumber(args[1]) or 1

    if parseBoolean(args[2]) then
        tpwalkStack = tpwalkStack + speed
    end

    tpwalking = RunService.Heartbeat:Connect(function(delta)
        if not (character and humanoid and humanoid.Parent) then
            tpwalking:Disconnect()
            return
        end

        if humanoid.MoveDirection.Magnitude > 0 then
            character:TranslateBy(humanoid.MoveDirection * (speed + tpwalkStack) * delta * 10)
        end
    end)
end)

addcmd("unteleportwalk", {"untpwalk"}, function(args, speaker)
    tpwalkStack = 0
    tpwalking:Disconnect()
end)

function bring(speaker,target,fast)
	if tools(speaker) then
		if target ~= nil then
			local NormPos = getRoot(speaker.Character).CFrame
			if not fast then
				refresh(speaker)
				wait()
				repeat wait() until speaker.Character ~= nil and getRoot(speaker.Character)
				wait(0.3)
			end
			local hrp = getRoot(speaker.Character)
			attach(speaker,target)
			repeat
				wait()
				hrp.CFrame = NormPos
			until not getRoot(target.Character) or not getRoot(speaker.Character)
			local char = speaker.CharacterAdded:Wait()
			local humanoid = char:FindFirstChildOfClass("Humanoid") or char.ChildAdded:Wait()
			while not humanoid:IsA("Humanoid") do
				humanoid = char:FindFirstChildOfClass("Humanoid") or char.ChildAdded:Wait()
			end
			humanoid.RootPart.CFrame = NormPos
		end
	else
		notify('Tool Required','You need to have an item in your inventory to use this command')
	end
end

function teleport(speaker,target,target2,fast)
	if tools(speaker) then
		if target ~= nil then
			local NormPos = getRoot(speaker.Character).CFrame
			if not fast then
				refresh(speaker)
				wait()
				repeat wait() until speaker.Character ~= nil and getRoot(speaker.Character)
				wait(0.3)
			end
			local hrp = getRoot(speaker.Character)
			local hrp2 = getRoot(target2.Character)
			attach(speaker,target)
			repeat
				wait()
				hrp.CFrame = hrp2.CFrame
			until not getRoot(target.Character) or not getRoot(speaker.Character)
			wait(1)
			local char = speaker.CharacterAdded:Wait()
			local humanoid = char:FindFirstChildOfClass("Humanoid") or char.ChildAdded:Wait()
			while not humanoid:IsA("Humanoid") do
				humanoid = char:FindFirstChildOfClass("Humanoid") or char.ChildAdded:Wait()
			end
			humanoid.RootPart.CFrame = NormPos
		end
	else
		notify('Tool Required','You need to have an item in your inventory to use this command')
	end
end

addcmd('spin',{},function(args, speaker)
	local spinSpeed = 20
	if args[1] and isNumber(args[1]) then
		spinSpeed = args[1]
	end
	for i,v in pairs(getRoot(speaker.Character):GetChildren()) do
		if v.Name == "Spinning" then
			v:Destroy()
		end
	end
	local Spin = Instance.new("BodyAngularVelocity")
	Spin.Name = "Spinning"
	Spin.Parent = getRoot(speaker.Character)
	Spin.MaxTorque = Vector3.new(0, math.huge, 0)
	Spin.AngularVelocity = Vector3.new(0,spinSpeed,0)
end)

addcmd('unspin',{},function(args, speaker)
	for i,v in pairs(getRoot(speaker.Character):GetChildren()) do
		if v.Name == "Spinning" then
			v:Destroy()
		end
	end
end)

xrayEnabled = false
function xray()
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("BasePart") and not v.Parent:FindFirstChildWhichIsA("Humanoid") and not v.Parent.Parent:FindFirstChildWhichIsA("Humanoid") then
			v.LocalTransparencyModifier = xrayEnabled and 0.5 or 0
		end
	end
end

addcmd("xray", {}, function(args, speaker)
	xrayEnabled = true
	xray()
end)

addcmd("unxray", {"noxray"}, function(args, speaker)
	xrayEnabled = false
	xray()
end)

addcmd("togglexray", {}, function(args, speaker)
	xrayEnabled = not xrayEnabled
	xray()
end)

addcmd("loopxray", {}, function(args, speaker)
	pcall(function() xrayLoop:Disconnect() end)
	xrayLoop = RunService.RenderStepped:Connect(function()
		xrayEnabled = true
		xray()
	end)
end)

addcmd("unloopxray", {}, function(args, speaker)
	pcall(function() xrayLoop:Disconnect() end)
	xrayEnabled = false
	xray()
end)

local walltpTouch = nil
addcmd('walltp',{},function(args, speaker)
	local torso
	if r15(speaker) then
		torso = speaker.Character.UpperTorso
	else
		torso = speaker.Character.Torso
	end
	local function touchedFunc(hit)
		local Root = getRoot(speaker.Character)
		if hit:IsA("BasePart") and hit.Position.Y > Root.Position.Y - speaker.Character:FindFirstChildOfClass('Humanoid').HipHeight then
			local hitP = getRoot(hit.Parent)
			if hitP ~= nil then
				Root.CFrame = hit.CFrame * CFrame.new(Root.CFrame.lookVector.X,hitP.Size.Z/2 + speaker.Character:FindFirstChildOfClass('Humanoid').HipHeight,Root.CFrame.lookVector.Z)
			elseif hitP == nil then
				Root.CFrame = hit.CFrame * CFrame.new(Root.CFrame.lookVector.X,hit.Size.Y/2 + speaker.Character:FindFirstChildOfClass('Humanoid').HipHeight,Root.CFrame.lookVector.Z)
			end
		end
	end
	walltpTouch = torso.Touched:Connect(touchedFunc)
end)

addcmd('unwalltp',{'nowalltp'},function(args, speaker)
	if walltpTouch then
		walltpTouch:Disconnect()
	end
end)

autoclicking = false
addcmd('autoclick',{},function(args, speaker)
	if mouse1press and mouse1release then
		execCmd('unautoclick')
		wait()
		local clickDelay = 0.1
		local releaseDelay = 0.1
		if args[1] and isNumber(args[1]) then clickDelay = args[1] end
		if args[2] and isNumber(args[2]) then releaseDelay = args[2] end
		autoclicking = true
		cancelAutoClick = UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
			if not gameProcessedEvent then
				if (input.KeyCode == Enum.KeyCode.Backspace and UserInputService:IsKeyDown(Enum.KeyCode.Equals)) or (input.KeyCode == Enum.KeyCode.Equals and UserInputService:IsKeyDown(Enum.KeyCode.Backspace)) then
					autoclicking = false
					cancelAutoClick:Disconnect()
				end
			end
		end)
		notify('Auto Clicker',"Press [backspace] and [=] at the same time to stop")
		repeat wait(clickDelay)
			mouse1press()
			wait(releaseDelay)
			mouse1release()
		until autoclicking == false
	else
		notify('Auto Clicker',"Your exploit doesn't have the ability to use the autoclick")
	end
end)

addcmd('unautoclick',{'noautoclick'},function(args, speaker)
	autoclicking = false
	if cancelAutoClick then cancelAutoClick:Disconnect() end
end)

addcmd('mousesensitivity',{'ms'},function(args, speaker)
	UserInputService.MouseDeltaSensitivity = args[1]
end)

local nameBox = nil
local nbSelection = nil
addcmd('hovername',{},function(args, speaker)
	execCmd('unhovername')
	wait()
	nameBox = Instance.new("TextLabel")
	nameBox.Name = randomString()
	nameBox.Parent = ScaledHolder
	nameBox.BackgroundTransparency = 1
	nameBox.Size = UDim2.new(0,200,0,30)
	nameBox.Font = Enum.Font.Code
	nameBox.TextSize = 16
	nameBox.Text = ""
	nameBox.TextColor3 = Color3.new(1, 1, 1)
	nameBox.TextStrokeTransparency = 0
	nameBox.TextXAlignment = Enum.TextXAlignment.Left
	nameBox.ZIndex = 10
	nbSelection = Instance.new('SelectionBox')
	nbSelection.Name = randomString()
	nbSelection.LineThickness = 0.03
	nbSelection.Color3 = Color3.new(1, 1, 1)
	local function updateNameBox()
		local t
		local target = IYMouse.Target

		if target then
			local humanoid = target.Parent:FindFirstChildOfClass("Humanoid") or target.Parent.Parent:FindFirstChildOfClass("Humanoid")
			if humanoid then
				t = humanoid.Parent
			end
		end

		if t ~= nil then
			local x = IYMouse.X
			local y = IYMouse.Y
			local xP
			local yP
			if IYMouse.X > 200 then
				xP = x - 205
				nameBox.TextXAlignment = Enum.TextXAlignment.Right
			else
				xP = x + 25
				nameBox.TextXAlignment = Enum.TextXAlignment.Left
			end
			nameBox.Position = UDim2.new(0, xP, 0, y)
			nameBox.Text = t.Name
			nameBox.Visible = true
			nbSelection.Parent = t
			nbSelection.Adornee = t
		else
			nameBox.Visible = false
			nbSelection.Parent = nil
			nbSelection.Adornee = nil
		end
	end
	nbUpdateFunc = IYMouse.Move:Connect(updateNameBox)
end)

addcmd('unhovername',{'nohovername'},function(args, speaker)
	if nbUpdateFunc then
		nbUpdateFunc:Disconnect()
		nameBox:Destroy()
		nbSelection:Destroy()
	end
end)

addcmd('headsize',{},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players) do
		if Players[v] ~= speaker and Players[v].Character:FindFirstChild('Head') then
			local sizeArg = tonumber(args[2])
			local Size = Vector3.new(sizeArg,sizeArg,sizeArg)
			local Head = Players[v].Character:FindFirstChild('Head')
			if Head:IsA("BasePart") then
				Head.CanCollide = false
				if not args[2] or sizeArg == 1 then
					Head.Size = Vector3.new(2,1,1)
				else
					Head.Size = Size
				end
			end
		end
	end
end)

addcmd('hitbox',{},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	local transparency = args[3] and tonumber(args[3]) or 0.4
	for i,v in pairs(players) do
		if Players[v] ~= speaker and getRoot(Players[v].Character) then
			local sizeArg = tonumber(args[2])
			local Size = Vector3.new(sizeArg,sizeArg,sizeArg)
			local Root = getRoot(Players[v].Character)
			if Root:IsA("BasePart") then
				Root.CanCollide = false
				if not args[2] or sizeArg == 1 then
					Root.Size = Vector3.new(2,1,1)
					Root.Transparency = transparency
				else
					Root.Size = Size
					Root.Transparency = transparency
				end
			end
		end
	end
end)

addcmd("hitboxes", {}, function(args, speaker)
    settings():GetService("RenderSettings").ShowBoundingBoxes = true
end)

addcmd("unhitboxes", {}, function(args, speaker)
    settings():GetService("RenderSettings").ShowBoundingBoxes = false
end)

addcmd('stareat',{'stare'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players) do
		if stareLoop then
			stareLoop:Disconnect()
		end
		if not getRoot(Players.LocalPlayer.Character) and getRoot(Players[v].Character) then return end
		local function stareFunc()
			if Players.LocalPlayer.Character.PrimaryPart and Players:FindFirstChild(v) and Players[v].Character ~= nil and getRoot(Players[v].Character) then
				local chrPos=Players.LocalPlayer.Character.PrimaryPart.Position
				local tPos=getRoot(Players[v].Character).Position
				local modTPos=Vector3.new(tPos.X,chrPos.Y,tPos.Z)
				local newCF=CFrame.new(chrPos,modTPos)
				Players.LocalPlayer.Character:SetPrimaryPartCFrame(newCF)
			elseif not Players:FindFirstChild(v) then
				stareLoop:Disconnect()
			end
		end

		stareLoop = RunService.RenderStepped:Connect(stareFunc)
	end
end)

addcmd('unstareat',{'unstare','nostare','nostareat'},function(args, speaker)
	if stareLoop then
		stareLoop:Disconnect()
	end
end)

RolewatchData = {Group = 0, Role = "", Leave = false}
RolewatchConnection = Players.PlayerAdded:Connect(function(player)
	if RolewatchData.Group == 0 then return end
	if player:IsInGroup(RolewatchData.Group) then
		if tostring(player:GetRoleInGroup(RolewatchData.Group)):lower() == RolewatchData.Role:lower() then
			if RolewatchData.Leave == true then
				Players.LocalPlayer:Kick("\n\nRolewatch\nPlayer \"" .. tostring(player.Name) .. "\" has joined with the Role \"" .. RolewatchData.Role .. "\"\n")
			else
				notify("Rolewatch", "Player \"" .. tostring(player.Name) .. "\" has joined with the Role \"" .. RolewatchData.Role .. "\"")
			end
		end
	end
end)

addcmd("rolewatch", {}, function(args, speaker)
	local groupId = tonumber(args[1] or 0)
	local roleName = args[2] and tostring(getstring(2, args))
	if groupId and roleName then
		RolewatchData.Group = groupId
		RolewatchData.Role = roleName
		notify("Rolewatch", "Watching Group ID \"" .. tostring(groupId) .. "\" for Role \"" .. roleName .. "\"")
	end
end)

addcmd("rolewatchstop", {}, function(args, speaker)
	RolewatchData.Group = 0
	RolewatchData.Role = ""
	RolewatchData.Leave = false
	notify("Rolewatch", "Disabled")
end)

addcmd("rolewatchleave", {"unrolewatch"}, function(args, speaker)
	RolewatchData.Leave = not RolewatchData.Leave
	notify("Rolewatch", RolewatchData.Leave and "Leave has been Enabled" or "Leave has been Disabled")
end)

staffRoles = {"mod", "admin", "staff", "dev", "founder", "owner", "supervis", "manager", "management", "executive", "president", "chairman", "chairwoman", "chairperson", "director"}

getStaffRole = function(player)
	local playerRole = player:GetRoleInGroup(game.CreatorId)
	local result = {Role = playerRole, Staff = false}
	if player:IsInGroup(1200769) then
		result.Role = "Roblox Employee"
		result.Staff = true
	end
	for _, role in pairs(staffRoles) do
		if string.find(string.lower(playerRole), role) then
			result.Staff = true
		end
	end
	return result
end

addcmd("staffwatch", {}, function(args, speaker)
	if staffwatchjoin then
		staffwatchjoin:Disconnect()
	end
	if game.CreatorType == Enum.CreatorType.Group then
		local found = {}
		staffwatchjoin = Players.PlayerAdded:Connect(function(player)
			local result = getStaffRole(player)
			if result.Staff then
				notify("Staffwatch", formatUsername(player) .. " is a " .. result.Role)
			end
		end)
		for _, player in pairs(Players:GetPlayers()) do
			local result = getStaffRole(player)
			if result.Staff then
				table.insert(found, formatUsername(player) .. " is a " .. result.Role)
			end
		end
		if #found > 0 then
			notify("Staffwatch", table.concat(found, ",\n"))
		else
			notify("Staffwatch", "Enabled")
		end
	else
		notify("Staffwatch", "Game is not owned by a Group")
	end
end)

addcmd("unstaffwatch", {}, function(args, speaker)
	if staffwatchjoin then
		staffwatchjoin:Disconnect()
	end
	notify("Staffwatch", "Disabled")
end)

local function playerGroups()
    local players = Players:GetPlayers()
    local graph = {}
    local seen = {}
    local groups = {}

    for _, p in ipairs(players) do
        graph[p] = {}
    end

    for i = 1, #players do
        for j = i + 1, #players do
            local p1 = players[i]
            local p2 = players[j]

            local success, result = pcall(function()
                return p1:IsFriendsWithAsync(p2.UserId)
            end)

            if success and result then
                table.insert(graph[p1], p2)
                table.insert(graph[p2], p1)
            end
        end
    end

    local function dfs(player, group)
        seen[player] = true
        table.insert(group, player)

        for _, possible in ipairs(graph[player]) do
            if not seen[possible] then
                dfs(possible, group)
            end
        end
    end

    for _, p in ipairs(players) do
        if not seen[p] then
            local group = {}
            dfs(p, group)
            table.insert(groups, group)
        end
    end

    return groups
end

addcmd("findfriendgroups", {}, function(args, speaker)
    notify("Checking Players", "This might take a while (slow function)")

    local groups = playerGroups()
    local playerList = StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.PlayerList)

    local result = ""
    local index = 1
    local found = 0

    for _, group in ipairs(groups) do
        if #group == 1 then continue end
        local names = {}
        for _, player in ipairs(group) do
            table.insert(names, playerList and player.DisplayName or player.Name)
        end
        result = result .. index .. ". " .. table.concat(names, ", ") .. "\n"
        index = index + 1
        found = found + 1
    end

    createPopup("Friend Groups", found == 0 and "None" or result)
end)

addcmd('removeterrain',{'rterrain','noterrain'},function(args, speaker)
	workspace:FindFirstChildOfClass('Terrain'):Clear()
end)

addcmd('clearnilinstances',{'nonilinstances','cni'},function(args, speaker)
	if getnilinstances then
		for i,v in pairs(getnilinstances()) do
			v:Destroy()
		end
	else
		notify('Incompatible Exploit','Your exploit does not support this command (missing getnilinstances)')
	end
end)

addcmd('destroyheight',{'dh'},function(args, speaker)
	local dh = args[1] or -500
	if isNumber(dh) then
		workspace.FallenPartsDestroyHeight = dh
	end
end)

OrgDestroyHeight = workspace.FallenPartsDestroyHeight
addcmd("antivoid", {}, function(args, speaker)
	execCmd("unantivoid nonotify")
	task.wait()
	antivoidloop = RunService.Stepped:Connect(function()
		local root = getRoot(speaker.Character)
		if root and root.Position.Y <= OrgDestroyHeight + 25 then
			root.Velocity = root.Velocity + Vector3.new(0, 250, 0)
		end
	end)
	if args[1] ~= "nonotify" then notify("antivoid", "Enabled") end
end)

addcmd("unantivoid", {"noantivoid"}, function(args, speaker)
	pcall(function() antivoidloop:Disconnect() end)
	antivoidloop = nil
	if args[1] ~= "nonotify" then notify("antivoid", "Disabled") end
end)

antivoidWasEnabled = false
addcmd("fakeout", {}, function(args, speaker)
	local root = getRoot(speaker.Character)
	local oldpos = root.CFrame
	if antivoidloop then
		execCmd("unantivoid nonotify")
		antivoidWasEnabled = true
	end
	workspace.FallenPartsDestroyHeight = 0/1/0
	root.CFrame = CFrame.new(Vector3.new(0, OrgDestroyHeight - 25, 0))
	task.wait(1)
	root.CFrame = oldpos
	workspace.FallenPartsDestroyHeight = OrgDestroyHeight
	if antivoidWasEnabled then
		execCmd("antivoid nonotify")
		antivoidWasEnabled = false
	end
end)

addcmd("trip", {}, function(args, speaker)
	local humanoid = speaker.Character and speaker.Character:FindFirstChildWhichIsA("Humanoid")
	local root = speaker.Character and getRoot(speaker.Character)
	if humanoid and root then
		humanoid:ChangeState(Enum.HumanoidStateType.FallingDown)
		root.Velocity = root.CFrame.LookVector * 30
	end
end)

addcmd("removeads", {"adblock"}, function(args, speaker)
	while wait() do
		pcall(function()
			for i, v in pairs(workspace:GetDescendants()) do
				if v:IsA("PackageLink") then
					if v.Parent:FindFirstChild("ADpart") then
						v.Parent:Destroy()
					end
					if v.Parent:FindFirstChild("AdGuiAdornee") then
						v.Parent.Parent:Destroy()
					end
				end
			end
		end)
	end
end)

addcmd("scare", {"spook"}, function(args, speaker)
	local players = getPlayer(args[1], speaker)
	local oldpos = nil

	for _, v in pairs(players) do
		local root = speaker.Character and getRoot(speaker.Character)
		local target = Players[v]
		local targetRoot = target and target.Character and getRoot(target.Character)

		if root and targetRoot and target ~= speaker then
			oldpos = root.CFrame
			root.CFrame = targetRoot.CFrame + targetRoot.CFrame.lookVector * 2
			root.CFrame = CFrame.new(root.Position, targetRoot.Position)
			task.wait(0.5)
			root.CFrame = oldpos
		end
	end
end)

addcmd("alignmentkeys", {}, function(args, speaker)
	alignmentKeys = UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.KeyCode == Enum.KeyCode.Comma then workspace.CurrentCamera:PanUnits(-1) end
		if input.KeyCode == Enum.KeyCode.Period then workspace.CurrentCamera:PanUnits(1) end
	end)
	alignmentKeysEmotes = StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu)
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, false)
end)

addcmd("unalignmentkeys", {"noalignmentkeys"}, function(args, speaker)
	if type(alignmentKeysEmotes) == "boolean" then
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, alignmentKeysEmotes)
	end
	alignmentKeys:Disconnect()
end)

addcmd("ctrllock", {}, function(args, speaker)
	local mouseLockController = speaker.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("CameraModule"):WaitForChild("MouseLockController")
	local boundKeys = mouseLockController:FindFirstChild("BoundKeys")

	if boundKeys then
		boundKeys.Value = "LeftControl"
	else
		boundKeys = Instance.new("StringValue")
		boundKeys.Name = "BoundKeys"
		boundKeys.Value = "LeftControl"
		boundKeys.Parent = mouseLockController
	end
end)

addcmd("unctrllock", {}, function(args, speaker)
	local mouseLockController = speaker.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("CameraModule"):WaitForChild("MouseLockController")
	local boundKeys = mouseLockController:FindFirstChild("BoundKeys")

	if boundKeys then
		boundKeys.Value = "LeftShift"
	else
		boundKeys = Instance.new("StringValue")
		boundKeys.Name = "BoundKeys"
		boundKeys.Value = "LeftShift"
		boundKeys.Parent = mouseLockController
	end
end)

addcmd("listento", {}, function(args, speaker)
	execCmd("unlistento")
	if not args[1] then return end

	local player = Players:FindFirstChild(getPlayer(args[1], speaker)[1])
	local root = player and player.Character and getRoot(player.Character)

	if root then
		SoundService:SetListener(Enum.ListenerType.ObjectPosition, root)
		listentoChar = player.CharacterAdded:Connect(function()
			repeat task.wait() until Players[player.Name].Character ~= nil and getRoot(Players[player.Name].Character)
			SoundService:SetListener(Enum.ListenerType.ObjectPosition, getRoot(Players[player.Name].Character))
		end)
	end
end)

addcmd("unlistento", {}, function(args, speaker)
	SoundService:SetListener(Enum.ListenerType.Camera)
	listentoChar:Disconnect()
end)

addcmd("jerk", {}, function(args, speaker)
	local humanoid = speaker.Character:FindFirstChildWhichIsA("Humanoid")
	local backpack = speaker:FindFirstChildWhichIsA("Backpack")
	if not humanoid or not backpack then return end

	local tool = Instance.new("Tool")
	tool.Name = "Jerk Off"
	tool.ToolTip = "in the stripped club. straight up \"jorking it\" . and by \"it\" , haha, well. let's justr say. My peanits."
	tool.RequiresHandle = false
	tool.Parent = backpack

	local jorkin = false
	local track = nil

	local function stopTomfoolery()
		jorkin = false
		if track then
			track:Stop()
			track = nil
		end
	end

	tool.Equipped:Connect(function() jorkin = true end)
	tool.Unequipped:Connect(stopTomfoolery)
	humanoid.Died:Connect(stopTomfoolery)

	while task.wait() do
		if not jorkin then continue end

		local isR15 = r15(speaker)
		if not track then
			local anim = Instance.new("Animation")
			anim.AnimationId = not isR15 and "rbxassetid://72042024" or "rbxassetid://698251653"
			track = humanoid:LoadAnimation(anim)
		end

		track:Play()
		track:AdjustSpeed(isR15 and 0.7 or 0.65)
		track.TimePosition = 0.6
		task.wait(0.1)
		while track and track.TimePosition < (not isR15 and 0.65 or 0.7) do task.wait(0.1) end
		if track then
			track:Stop()
			track = nil
		end
	end
end)

addcmd("guiscale", {}, function(args, speaker)
	if args[1] and isNumber(args[1]) then
		local scale = tonumber(args[1])
		if scale % 1 == 0 then scale = scale / 100 end
		-- me when i divide and it explodes
		if scale == 0.01 then scale = 1 end
		if scale == 0.02 then scale = 2 end

		if scale >= 0.4 and scale <= 2 then
			guiScale = scale
		end
	else
		guiScale = defaultGuiScale
	end

	Scale.Scale = math.max(Holder.AbsoluteSize.X / 1920, guiScale)
	updatesaves()
end)

addcmd("muteallvoices", {"muteallvcs"}, function(args, speaker)
	Services.VoiceChatInternal:SubscribePauseAll(true)
end)

addcmd("unmuteallvoices", {"unmuteallvcs"}, function(args, speaker)
	Services.VoiceChatInternal:SubscribePauseAll(false)
end)

addcmd("mutevc", {}, function(args, speaker)
	for _, plr in getPlayer(args[1], speaker) do
		if Players[plr] == speaker then continue end
		Services.VoiceChatInternal:SubscribePause(Players[plr].UserId, true)
	end
end)

addcmd("unmutevc", {}, function(args, speaker)
	for _, plr in getPlayer(args[1], speaker) do
		if Players[plr] == speaker then continue end
		Services.VoiceChatInternal:SubscribePause(Players[plr].UserId, false)
	end
end)

addcmd("phonebook", {"call"}, function(args, speaker)
	local success, canInvite = pcall(function()
		return SocialService:CanSendCallInviteAsync(speaker)
	end)
	if success and canInvite then
		SocialService:PromptPhoneBook(speaker, "")
	else
		notify("Phonebook", "It seems you're not able to call anyone. Sorry!")
	end
end)

local freezingua = nil
frozenParts = {}
addcmd('freezeunanchored',{'freezeua'},function(args, speaker)
	local badnames = {
		"Head",
		"UpperTorso",
		"LowerTorso",
		"RightUpperArm",
		"LeftUpperArm",
		"RightLowerArm",
		"LeftLowerArm",
		"RightHand",
		"LeftHand",
		"RightUpperLeg",
		"LeftUpperLeg",
		"RightLowerLeg",
		"LeftLowerLeg",
		"RightFoot",
		"LeftFoot",
		"Torso",
		"Right Arm",
		"Left Arm",
		"Right Leg",
		"Left Leg",
		"HumanoidRootPart"
	}
	local function FREEZENOOB(v)
		if v:IsA("BasePart" or "UnionOperation") and v.Anchored == false then
			local BADD = false
			for i = 1,#badnames do
				if v.Name == badnames[i] then
					BADD = true
				end
			end
			if speaker.Character and v:IsDescendantOf(speaker.Character) then
				BADD = true
			end
			if BADD == false then
				for i,c in pairs(v:GetChildren()) do
					if c:IsA("BodyPosition") or c:IsA("BodyGyro") then
						c:Destroy()
					end
				end
				local bodypos = Instance.new("BodyPosition")
				bodypos.Parent = v
				bodypos.Position = v.Position
				bodypos.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
				local bodygyro = Instance.new("BodyGyro")
				bodygyro.Parent = v
				bodygyro.CFrame = v.CFrame
				bodygyro.MaxTorque = Vector3.new(math.huge,math.huge,math.huge)
				if not table.find(frozenParts,v) then
					table.insert(frozenParts,v)
				end
			end
		end
	end
	for i,v in pairs(workspace:GetDescendants()) do
		FREEZENOOB(v)
	end
	freezingua = workspace.DescendantAdded:Connect(FREEZENOOB)
end)

addcmd('thawunanchored',{'thawua','unfreezeunanchored','unfreezeua'},function(args, speaker)
	if freezingua then
		freezingua:Disconnect()
	end
	for i,v in pairs(frozenParts) do
		for i,c in pairs(v:GetChildren()) do
			if c:IsA("BodyPosition") or c:IsA("BodyGyro") then
				c:Destroy()
			end
		end
	end
	frozenParts = {}
end)

addcmd('tpunanchored',{'tpua'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players) do
		local Forces = {}
		for _,part in pairs(workspace:GetDescendants()) do
			if Players[v].Character:FindFirstChild('Head') and part:IsA("BasePart" or "UnionOperation" or "Model") and part.Anchored == false and not part:IsDescendantOf(speaker.Character) and part.Name == "Torso" == false and part.Name == "Head" == false and part.Name == "Right Arm" == false and part.Name == "Left Arm" == false and part.Name == "Right Leg" == false and part.Name == "Left Leg" == false and part.Name == "HumanoidRootPart" == false then
				for i,c in pairs(part:GetChildren()) do
					if c:IsA("BodyPosition") or c:IsA("BodyGyro") then
						c:Destroy()
					end
				end
				local ForceInstance = Instance.new("BodyPosition")
				ForceInstance.Parent = part
				ForceInstance.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
				table.insert(Forces, ForceInstance)
				if not table.find(frozenParts,part) then
					table.insert(frozenParts,part)
				end
			end
		end
		for i,c in pairs(Forces) do
			c.Position = Players[v].Character.Head.Position
		end
	end
end)

keycodeMap = {
	["0"] = 0x30,
	["1"] = 0x31,
	["2"] = 0x32,
	["3"] = 0x33,
	["4"] = 0x34,
	["5"] = 0x35,
	["6"] = 0x36,
	["7"] = 0x37,
	["8"] = 0x38,
	["9"] = 0x39,
	["a"] = 0x41,
	["b"] = 0x42,
	["c"] = 0x43,
	["d"] = 0x44,
	["e"] = 0x45,
	["f"] = 0x46,
	["g"] = 0x47,
	["h"] = 0x48,
	["i"] = 0x49,
	["j"] = 0x4A,
	["k"] = 0x4B,
	["l"] = 0x4C,
	["m"] = 0x4D,
	["n"] = 0x4E,
	["o"] = 0x4F,
	["p"] = 0x50,
	["q"] = 0x51,
	["r"] = 0x52,
	["s"] = 0x53,
	["t"] = 0x54,
	["u"] = 0x55,
	["v"] = 0x56,
	["w"] = 0x57,
	["x"] = 0x58,
	["y"] = 0x59,
	["z"] = 0x5A,
	["enter"] = 0x0D,
	["shift"] = 0x10,
	["ctrl"] = 0x11,
	["alt"] = 0x12,
	["pause"] = 0x13,
	["capslock"] = 0x14,
	["spacebar"] = 0x20,
	["space"] = 0x20,
	["pageup"] = 0x21,
	["pagedown"] = 0x22,
	["end"] = 0x23,
	["home"] = 0x24,
	["left"] = 0x25,
	["up"] = 0x26,
	["right"] = 0x27,
	["down"] = 0x28,
	["insert"] = 0x2D,
	["delete"] = 0x2E,
	["f1"] = 0x70,
	["f2"] = 0x71,
	["f3"] = 0x72,
	["f4"] = 0x73,
	["f5"] = 0x74,
	["f6"] = 0x75,
	["f7"] = 0x76,
	["f8"] = 0x77,
	["f9"] = 0x78,
	["f10"] = 0x79,
	["f11"] = 0x7A,
	["f12"] = 0x7B,
}
autoKeyPressing = false
cancelAutoKeyPress = nil

addcmd('autokeypress',{'keypress'},function(args, speaker)
	if keypress and keyrelease and args[1] then
		local code = keycodeMap[args[1]:lower()]
		if not code then notify('Auto Key Press',"Invalid key") return end
		execCmd('unautokeypress')
		wait()
		local clickDelay = 0.1
		local releaseDelay = 0.1
		if args[2] and isNumber(args[2]) then clickDelay = args[2] end
		if args[3] and isNumber(args[3]) then releaseDelay = args[3] end
		autoKeyPressing = true
		cancelAutoKeyPress = UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
			if not gameProcessedEvent then
				if (input.KeyCode == Enum.KeyCode.Backspace and UserInputService:IsKeyDown(Enum.KeyCode.Equals)) or (input.KeyCode == Enum.KeyCode.Equals and UserInputService:IsKeyDown(Enum.KeyCode.Backspace)) then
					autoKeyPressing = false
					cancelAutoKeyPress:Disconnect()
				end
			end
		end)
		notify('Auto Key Press',"Press [backspace] and [=] at the same time to stop")
		repeat wait(clickDelay)
			keypress(code)
			wait(releaseDelay)
			keyrelease(code)
		until autoKeyPressing == false
		if cancelAutoKeyPress then cancelAutoKeyPress:Disconnect() keyrelease(code) end
	else
		notify('Auto Key Press',"Your exploit doesn't have the ability to use auto key press")
	end
end)

addcmd('unautokeypress',{'noautokeypress','unkeypress','nokeypress'},function(args, speaker)
	autoKeyPressing = false
	if cancelAutoKeyPress then cancelAutoKeyPress:Disconnect() end
end)

addcmd('addplugin',{'plugin'},function(args, speaker)
	addPlugin(getstring(1, args))
end)

addcmd('removeplugin',{'deleteplugin'},function(args, speaker)
	deletePlugin(getstring(1, args))
end)

addcmd('reloadplugin',{},function(args, speaker)
	local pluginName = getstring(1, args)
	deletePlugin(pluginName)
	wait(1)
	addPlugin(pluginName)
end)

addcmd("addallplugins", {"loadallplugins"}, function(args, speaker)
	if not listfiles or not isfolder then
		notify("Incompatible Exploit", "Your exploit does not support this command (missing listfiles/isfolder)")
		return
	end

	for _, filePath in ipairs(listfiles("")) do
		local fileName = filePath:match("([^/\\]+%.iy)$")

		if fileName and
			fileName:lower() ~= "iy_fe.iy" and
			not isfolder(fileName) and
			not table.find(PluginsTable, fileName)
		then
			addPlugin(fileName)
		end
	end
end)

-- ==================== WACKY COMMANDS ====================
WackyState = {conns = {}, objects = {}, binds = {}, saved = {}}

WackyState.disconnect = function(key)
	if WackyState.conns[key] then
		WackyState.conns[key]:Disconnect()
		WackyState.conns[key] = nil
	end
end

WackyState.connect = function(key, conn)
	WackyState.disconnect(key)
	WackyState.conns[key] = conn
end

WackyState.track = function(key, obj)
	WackyState.objects[key] = WackyState.objects[key] or {}
	table.insert(WackyState.objects[key], obj)
	return obj
end

WackyState.clear = function(key)
	for _, obj in ipairs(WackyState.objects[key] or {}) do
		pcall(function() obj:Destroy() end)
	end
	WackyState.objects[key] = nil
end

WackyState.unbindCam = function(key)
	if WackyState.binds[key] then
		pcall(function() RunService:UnbindFromRenderStep(WackyState.binds[key]) end)
		WackyState.binds[key] = nil
	end
end

WackyState.bindCam = function(key, func)
	WackyState.unbindCam(key)
	WackyState.binds[key] = "Wacky" .. key .. tostring(math.random(1, 1e9))
	RunService:BindToRenderStep(WackyState.binds[key], Enum.RenderPriority.Camera.Value + 1, func)
end

WackyState.parts = function(speaker)
	local char = speaker.Character
	if not char then return {} end
	if WackyState.partChar ~= char then
		WackyState.partChar, WackyState.partList = char, nil
		local function mark(d)
			if d:IsA("BasePart") then
				WackyState.partList = nil
			end
		end
		WackyState.connect("partsAdded", char.DescendantAdded:Connect(mark))
		WackyState.connect("partsRemoving", char.DescendantRemoving:Connect(mark))
	end
	if WackyState.partList then
		return WackyState.partList
	end
	local parts = {}
	for _, v in ipairs(char:GetDescendants()) do
		if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
			table.insert(parts, v)
		end
	end
	WackyState.partList = parts
	return parts
end

WackyState.rainbow = function(speed, offset)
	return Color3.fromHSV(((tick() * (speed or 1)) + (offset or 0)) % 1, 1, 1)
end

WackyState.randomColor = function()
	return Color3.fromHSV(math.random(), 0.9, 1)
end

WackyState.num = function(arg, default)
	if arg and isNumber(arg) then
		return tonumber(arg) or default
	end
	return default
end

WackyState.pick = function(list)
	return list[math.random(1, #list)]
end

WackyState.rainbowSequence = function()
	local keys = {}
	for i = 0, 6 do
		table.insert(keys, ColorSequenceKeypoint.new(i / 6, Color3.fromHSV(i / 6, 1, 1)))
	end
	return ColorSequence.new(keys)
end

-- Shared lighting snapshot: every effect that changes Lighting claims the properties it touches.
-- The game's own value is saved once and put back when the last effect using it turns off,
-- so turning effects off in any order always ends with the original lighting.
WackyState.light = {orig = {}, users = {}, restoring = {}}

WackyState.lightStopRestore = function()
	local L = WackyState.light
	if L.tween then
		pcall(function() L.tween:Cancel() end)
		L.tween = nil
	end
	for prop, value in pairs(L.restoring) do
		pcall(function() Lighting[prop] = value end)
	end
	L.restoring = {}
end

WackyState.lightClaim = function(owner, props)
	local L = WackyState.light
	WackyState.lightStopRestore()
	for _, prop in ipairs(props) do
		local users = L.users[prop]
		if not users then
			users = {}
			L.users[prop] = users
			if L.orig[prop] == nil then
				L.orig[prop] = Lighting[prop]
			end
		end
		users[owner] = true
	end
end

WackyState.lightRelease = function(owner, fadeTime)
	local L = WackyState.light
	local free = {}
	for prop, users in pairs(L.users) do
		if users[owner] then
			users[owner] = nil
			if next(users) == nil then
				free[prop] = L.orig[prop]
			end
		end
	end
	local any = false
	for prop in pairs(free) do
		L.users[prop] = nil
		L.orig[prop] = nil
		any = true
	end
	if not any then return end
	if fadeTime and fadeTime > 0 then
		WackyState.lightStopRestore()
		L.restoring = free
		local tween = TweenService:Create(Lighting, TweenInfo.new(fadeTime, Enum.EasingStyle.Sine), free)
		L.tween = tween
		tween.Completed:Connect(function()
			if L.tween == tween then
				L.tween = nil
				L.restoring = {}
			end
		end)
		tween:Play()
	else
		for prop, value in pairs(free) do
			pcall(function() Lighting[prop] = value end)
		end
	end
end

WackyState.lightReleaseAll = function()
	local owners = {}
	for _, users in pairs(WackyState.light.users) do
		for owner in pairs(users) do
			owners[owner] = true
		end
	end
	for owner in pairs(owners) do
		WackyState.lightRelease(owner)
	end
	WackyState.lightStopRestore()
end

-- Effects attached to your character come back after you respawn
WackyState.respawnFx = {}

WackyState.remember = function(name, args)
	WackyState.respawnFx[name] = args or {}
	if WackyState.conns.respawnFx then return end
	WackyState.connect("respawnFx", Players.LocalPlayer.CharacterAdded:Connect(function(char)
		local root = char:WaitForChild("HumanoidRootPart", 10)
		if not root then return end
		task.wait(0.3)
		for fxName, fxArgs in pairs(WackyState.respawnFx) do
			local cmd = findCmd(fxName)
			if cmd and Players.LocalPlayer.Character == char then
				pcall(cmd.FUNC, fxArgs, Players.LocalPlayer)
			end
		end
	end))
end

WackyState.forget = function(name)
	WackyState.respawnFx[name] = nil
end

-- Disco lighting
addcmd('disco',{'discomode'},function(args, speaker)
	local speed = WackyState.num(args[1], 0.5)
	WackyState.lightClaim("disco", {"Ambient", "OutdoorAmbient", "FogColor", "ColorShift_Top"})
	WackyState.clear("disco")
	local cc = WackyState.track("disco", Instance.new("ColorCorrectionEffect"))
	cc.Name = randomString()
	cc.Saturation = 0.6
	cc.Contrast = 0.15
	cc.Parent = Lighting
	WackyState.connect("disco", RunService.Heartbeat:Connect(function()
		local color = WackyState.rainbow(speed)
		Lighting.Ambient = color
		Lighting.OutdoorAmbient = color
		Lighting.FogColor = color
		Lighting.ColorShift_Top = color
		cc.TintColor = WackyState.rainbow(speed, 0.5):Lerp(Color3.new(1, 1, 1), 0.6)
	end))
	notify('Disco', 'Let\'s get funky! Use undisco to stop the party.')
end)

addcmd('undisco',{'nodisco'},function(args, speaker)
	WackyState.disconnect("disco")
	WackyState.clear("disco")
	WackyState.lightRelease("disco")
end)

-- Rainbow character
addcmd('rainbowchar',{'rainbowme','rgbchar'},function(args, speaker)
	local speed = WackyState.num(args[1], 0.4)
	WackyState.saved.charColors = WackyState.saved.charColors or setmetatable({}, {__mode = "k"})
	WackyState.connect("rainbowchar", RunService.Heartbeat:Connect(function()
		for i, part in ipairs(WackyState.parts(speaker)) do
			if WackyState.saved.charColors[part] == nil then
				WackyState.saved.charColors[part] = part.Color
			end
			part.Color = WackyState.rainbow(speed, i * 0.05)
		end
	end))
end)

addcmd('unrainbowchar',{'unrainbowme','unrgbchar'},function(args, speaker)
	WackyState.disconnect("rainbowchar")
	for part, color in pairs(WackyState.saved.charColors or {}) do
		if part.Parent then
			part.Color = color
		end
	end
	WackyState.saved.charColors = nil
end)

-- Ghost mode
addcmd('ghost',{'spooky'},function(args, speaker)
	WackyState.saved.ghost = WackyState.saved.ghost or setmetatable({}, {__mode = "k"})
	WackyState.connect("ghost", RunService.Heartbeat:Connect(function()
		local fade = 0.3 + math.sin(tick() * 2) * 0.25
		for _, part in ipairs(WackyState.parts(speaker)) do
			if WackyState.saved.ghost[part] == nil then
				WackyState.saved.ghost[part] = {part.Transparency, part.Material}
			end
			if part.Material ~= Enum.Material.ForceField then
				part.Material = Enum.Material.ForceField
			end
			part.Transparency = fade
		end
	end))
	notify('Ghost', 'Boooo! Use unghost to come back to life.')
end)

addcmd('unghost',{'unspooky'},function(args, speaker)
	WackyState.disconnect("ghost")
	for part, data in pairs(WackyState.saved.ghost or {}) do
		if part.Parent then
			part.Transparency = data[1]
			part.Material = data[2]
		end
	end
	WackyState.saved.ghost = nil
end)

-- Camera effects
addcmd('drunk',{'dizzy'},function(args, speaker)
	local strength = WackyState.num(args[1], 1)
	WackyState.saved.drunkFov = WackyState.saved.drunkFov or workspace.CurrentCamera.FieldOfView
	local baseFov = WackyState.saved.drunkFov
	WackyState.clear("drunk")
	local blur = WackyState.track("drunk", Instance.new("BlurEffect"))
	blur.Name = randomString()
	blur.Size = 4 * strength
	blur.Parent = Lighting
	WackyState.bindCam("drunk", function()
		local t = tick()
		local cam = workspace.CurrentCamera
		cam.CFrame = cam.CFrame * CFrame.Angles(0, 0, math.sin(t * 1.3) * 0.12 * strength) * CFrame.new(math.sin(t * 0.8) * 0.6 * strength, math.cos(t * 1.1) * 0.3 * strength, 0)
		cam.FieldOfView = math.clamp(baseFov + math.sin(t * 0.9) * 10 * strength, 1, 120)
	end)
	notify('Drunk', '*hic* Use undrunk to sober up.')
end)

addcmd('undrunk',{'undizzy','sober'},function(args, speaker)
	WackyState.unbindCam("drunk")
	WackyState.clear("drunk")
	if WackyState.saved.drunkFov then
		workspace.CurrentCamera.FieldOfView = WackyState.saved.drunkFov
		WackyState.saved.drunkFov = nil
	end
end)

addcmd('earthquake',{'camshake'},function(args, speaker)
	local intensity = WackyState.num(args[1], 1)
	WackyState.bindCam("earthquake", function()
		local cam = workspace.CurrentCamera
		cam.CFrame = cam.CFrame * CFrame.new((math.random() - 0.5) * intensity, (math.random() - 0.5) * intensity, (math.random() - 0.5) * intensity * 0.5)
	end)
end)

addcmd('unearthquake',{'uncamshake'},function(args, speaker)
	WackyState.unbindCam("earthquake")
end)

addcmd('camroll',{'upsidedown','tiltcam'},function(args, speaker)
	local degrees = WackyState.num(args[1], 180)
	WackyState.bindCam("camroll", function()
		local cam = workspace.CurrentCamera
		cam.CFrame = cam.CFrame * CFrame.Angles(0, 0, math.rad(degrees))
	end)
end)

addcmd('uncamroll',{'unupsidedown','untiltcam'},function(args, speaker)
	WackyState.unbindCam("camroll")
end)

addcmd('vertigo',{'dollyzoom'},function(args, speaker)
	if WackyState.vertigoRunning then return end
	WackyState.vertigoRunning = true
	local duration = WackyState.num(args[1], 3)
	task.spawn(function()
		local cam = workspace.CurrentCamera
		local baseFov = cam.FieldOfView
		local start = tick()
		while tick() - start < duration do
			local alpha = (tick() - start) / duration
			cam.FieldOfView = math.clamp(baseFov + math.sin(alpha * math.pi * 4) * 45, 5, 120)
			RunService.RenderStepped:Wait()
		end
		cam.FieldOfView = baseFov
		WackyState.vertigoRunning = false
	end)
end)

addcmd('orbitcam',{'cinematic'},function(args, speaker)
	local speed = WackyState.num(args[1], 0.5)
	local distance = WackyState.num(args[2], 18)
	local start = tick()
	workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
	WackyState.bindCam("orbitcam", function()
		local root = getRoot(speaker.Character)
		if not root then return end
		local angle = (tick() - start) * speed
		local pos = root.Position + Vector3.new(math.cos(angle) * distance, distance * 0.35, math.sin(angle) * distance)
		workspace.CurrentCamera.CFrame = CFrame.lookAt(pos, root.Position)
	end)
end)

addcmd('unorbitcam',{'uncinematic'},function(args, speaker)
	if not WackyState.binds.orbitcam then return end
	WackyState.unbindCam("orbitcam")
	if WackyState.binds.selfie then return end
	local cam = workspace.CurrentCamera
	cam.CameraType = Enum.CameraType.Custom
	local hum = speaker.Character and speaker.Character:FindFirstChildOfClass("Humanoid")
	if hum then
		cam.CameraSubject = hum
	end
end)

-- Screen filters
WackyState.filters = {
	noir = {Saturation = -1, Contrast = 0.35, Brightness = -0.05},
	sepia = {Saturation = -0.7, Contrast = 0.1, TintColor = Color3.fromRGB(255, 225, 175)},
	vaporwave = {Saturation = 0.5, Contrast = 0.15, TintColor = Color3.fromRGB(255, 160, 255), bloom = 1},
	nightvision = {Saturation = -1, Contrast = 0.3, Brightness = 0.2, TintColor = Color3.fromRGB(120, 255, 120)},
	deepfried = {Saturation = 3, Contrast = 1.5, TintColor = Color3.fromRGB(255, 190, 130), bloom = 3},
	underwater = {Saturation = 0.2, TintColor = Color3.fromRGB(120, 190, 255), blur = 6},
	thermal = {Saturation = 2, Contrast = 0.7, TintColor = Color3.fromRGB(255, 130, 70)},
	dream = {Saturation = 0.3, Brightness = 0.1, TintColor = Color3.fromRGB(255, 230, 255), blur = 3, bloom = 2},
}

addcmd('filter',{'screenfilter'},function(args, speaker)
	local names = {}
	for k in pairs(WackyState.filters) do
		table.insert(names, k)
	end
	table.sort(names)
	local choice = args[1] and args[1]:lower() or "random"
	if choice == "random" then
		choice = WackyState.pick(names)
	end
	local preset = WackyState.filters[choice]
	if not preset then
		notify('Filter', 'Unknown filter. Try: ' .. table.concat(names, ', ') .. ', random')
		return
	end
	WackyState.clear("filter")
	local cc = WackyState.track("filter", Instance.new("ColorCorrectionEffect"))
	cc.Name = randomString()
	cc.Saturation = preset.Saturation or 0
	cc.Contrast = preset.Contrast or 0
	cc.Brightness = preset.Brightness or 0
	cc.TintColor = preset.TintColor or Color3.new(1, 1, 1)
	cc.Parent = Lighting
	if preset.bloom then
		local bloom = WackyState.track("filter", Instance.new("BloomEffect"))
		bloom.Name = randomString()
		bloom.Intensity = preset.bloom
		bloom.Size = 40
		bloom.Threshold = 0.6
		bloom.Parent = Lighting
	end
	if preset.blur then
		local blur = WackyState.track("filter", Instance.new("BlurEffect"))
		blur.Name = randomString()
		blur.Size = preset.blur
		blur.Parent = Lighting
	end
	notify('Filter', 'Applied "' .. choice .. '" filter. Use unfilter to remove it.')
end)

addcmd('unfilter',{'noscreenfilter','unscreenfilter'},function(args, speaker)
	WackyState.clear("filter")
end)

-- weather / unweather live in WEATHER 2.0 further down

-- Confetti and dance floor
addcmd('confetti',{},function(args, speaker)
	local root = getRoot(speaker.Character)
	if not root then return end
	local amount = math.clamp(math.floor(WackyState.num(args[1], 80)), 1, 500)
	for i = 1, amount do
		local p = Instance.new("Part")
		p.Name = randomString()
		p.Size = Vector3.new(0.4, 0.05, 0.25)
		p.Material = Enum.Material.Neon
		p.Color = WackyState.randomColor()
		p.CanTouch = false
		p.CanQuery = false
		p.Massless = true
		p.CFrame = CFrame.new(root.Position + Vector3.new(math.random(-6, 6), math.random(6, 12), math.random(-6, 6))) * CFrame.Angles(math.random() * 6.28, math.random() * 6.28, math.random() * 6.28)
		p.Parent = workspace
		p.AssemblyLinearVelocity = Vector3.new(math.random(-20, 20), math.random(10, 40), math.random(-20, 20))
		p.AssemblyAngularVelocity = Vector3.new(math.random(-20, 20), math.random(-20, 20), math.random(-20, 20))
		Services.Debris:AddItem(p, 8)
	end
end)

addcmd('dancefloor',{'discofloor'},function(args, speaker)
	local char = speaker.Character
	local root = getRoot(char)
	if not root then return end
	local size = math.clamp(math.floor(WackyState.num(args[1], 7)), 2, 20)
	local tileSize = 6
	WackyState.disconnect("dancefloor")
	WackyState.clear("dancefloor")
	local params = RaycastParams.new()
	params.FilterDescendantsInstances = {char}
	params.FilterType = Enum.RaycastFilterType.Exclude
	local hit = workspace:Raycast(root.Position, Vector3.new(0, -50, 0), params)
	local floorY = hit and hit.Position.Y or (root.Position.Y - 3)
	local half = (size - 1) / 2
	local tiles = {}
	for x = 0, size - 1 do
		for z = 0, size - 1 do
			local tile = WackyState.track("dancefloor", Instance.new("Part"))
			tile.Name = randomString()
			tile.Anchored = true
			tile.Size = Vector3.new(tileSize - 0.2, 1, tileSize - 0.2)
			tile.Material = Enum.Material.Neon
			tile.Color = WackyState.randomColor()
			tile.TopSurface = Enum.SurfaceType.Smooth
			tile.CFrame = CFrame.new(root.Position.X + (x - half) * tileSize, floorY - 0.45, root.Position.Z + (z - half) * tileSize)
			tile.Parent = workspace
			table.insert(tiles, tile)
		end
	end
	local last = 0
	WackyState.connect("dancefloor", RunService.Heartbeat:Connect(function()
		if tick() - last > 0.35 then
			last = tick()
			for _, tile in ipairs(tiles) do
				tile.Color = WackyState.randomColor()
			end
		end
	end))
	notify('Dance Floor', 'Bust a move! Use undancefloor to pack it up.')
end)

addcmd('undancefloor',{'undiscofloor','nodancefloor'},function(args, speaker)
	WackyState.disconnect("dancefloor")
	WackyState.clear("dancefloor")
end)

-- Movement tricks
addcmd('moongravity',{'moon','lowgravity'},function(args, speaker)
	WackyState.saved.gravity = WackyState.saved.gravity or workspace.Gravity
	workspace.Gravity = WackyState.num(args[1], 30)
end)

addcmd('normalgravity',{'unmoongravity','unmoon','unlowgravity'},function(args, speaker)
	if WackyState.saved.gravity then
		workspace.Gravity = WackyState.saved.gravity
		WackyState.saved.gravity = nil
	end
end)

addcmd('pogo',{'bunnyhop','bhop'},function(args, speaker)
	WackyState.connect("pogo", RunService.Heartbeat:Connect(function()
		local hum = speaker.Character and speaker.Character:FindFirstChildOfClass("Humanoid")
		if hum and hum.FloorMaterial ~= Enum.Material.Air and hum:GetState() ~= Enum.HumanoidStateType.Jumping then
			hum:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end))
end)

addcmd('unpogo',{'nopogo','unbunnyhop','unbhop'},function(args, speaker)
	WackyState.disconnect("pogo")
end)

addcmd('moonwalk',{},function(args, speaker)
	WackyState.connect("moonwalk", RunService.Heartbeat:Connect(function()
		local char = speaker.Character
		local root = getRoot(char)
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if not root or not hum then return end
		if hum.AutoRotate then
			hum.AutoRotate = false
		end
		local dir = hum.MoveDirection
		if dir.Magnitude > 0.1 then
			local pos = root.Position
			root.CFrame = CFrame.lookAt(pos, pos - Vector3.new(dir.X, 0, dir.Z))
		end
	end))
	notify('Moonwalk', 'Hee-hee! Walk around to moonwalk. Use unmoonwalk to stop.')
end)

addcmd('unmoonwalk',{'nomoonwalk'},function(args, speaker)
	if not WackyState.conns.moonwalk then return end
	WackyState.disconnect("moonwalk")
	local hum = speaker.Character and speaker.Character:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.AutoRotate = true
	end
end)

WackyState.flip = function(speaker, axis, count)
	local char = speaker.Character
	local root = getRoot(char)
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not root or not hum or WackyState.flipping then return end
	WackyState.flipping = true
	local flips = math.clamp(math.floor(count or 1), 1, 10)
	local target = math.pi * 2 * flips
	local perFlip = 0.45
	hum:ChangeState(Enum.HumanoidStateType.Jumping)
	local vel = root.AssemblyLinearVelocity
	root.AssemblyLinearVelocity = Vector3.new(vel.X, 40 + flips * 15, vel.Z)
	task.spawn(function()
		pcall(function()
			hum.PlatformStand = true
			local turned = 0
			while turned < target and root.Parent do
				local dt = RunService.Heartbeat:Wait()
				local step = math.min(target - turned, dt * math.pi * 2 / perFlip)
				turned = turned + step
				root.CFrame = root.CFrame * CFrame.fromAxisAngle(axis, step)
			end
		end)
		pcall(function() hum.PlatformStand = false end)
		WackyState.flipping = false
	end)
end

addcmd('backflip',{},function(args, speaker)
	WackyState.flip(speaker, Vector3.new(1, 0, 0), WackyState.num(args[1], 1))
end)

addcmd('frontflip',{},function(args, speaker)
	WackyState.flip(speaker, Vector3.new(-1, 0, 0), WackyState.num(args[1], 1))
end)

addcmd('barrelroll',{'doabarrelroll'},function(args, speaker)
	WackyState.flip(speaker, Vector3.new(0, 0, 1), WackyState.num(args[1], 1))
end)

addcmd('rocket',{'launch','yeetme'},function(args, speaker)
	local char = speaker.Character
	local root = getRoot(char)
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not root or not hum then return end
	local power = WackyState.num(args[1], 200)
	local fire = Instance.new("Fire")
	fire.Name = randomString()
	fire.Size = 8
	fire.Heat = -20
	fire.Parent = root
	local smoke = Instance.new("Smoke")
	smoke.Name = randomString()
	smoke.Opacity = 0.3
	smoke.RiseVelocity = -5
	smoke.Size = 3
	smoke.Parent = root
	Services.Debris:AddItem(fire, 3)
	Services.Debris:AddItem(smoke, 3)
	hum:ChangeState(Enum.HumanoidStateType.Jumping)
	local vel = root.AssemblyLinearVelocity
	root.AssemblyLinearVelocity = Vector3.new(vel.X, power, vel.Z)
	notify('Rocket', '3... 2... 1... LIFTOFF!')
end)

addcmd('jetpack',{},function(args, speaker)
	local root = getRoot(speaker.Character)
	if not root then return end
	local thrust = WackyState.num(args[1], 40)
	WackyState.disconnect("jetpack")
	WackyState.clear("jetpack")
	local fire = WackyState.track("jetpack", Instance.new("Fire"))
	fire.Name = randomString()
	fire.Size = 4
	fire.Heat = -15
	fire.Enabled = false
	fire.Parent = root
	WackyState.connect("jetpack", RunService.Heartbeat:Connect(function()
		local char = speaker.Character
		local r = getRoot(char)
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if not r or not hum then return end
		if fire.Parent ~= r then
			fire = WackyState.track("jetpack", Instance.new("Fire"))
			fire.Name = randomString()
			fire.Size = 4
			fire.Heat = -15
			fire.Enabled = false
			fire.Parent = r
		end
		local held = hum.Jump
		if fire.Enabled ~= held then
			pcall(function() fire.Enabled = held end)
		end
		if held then
			local v = r.AssemblyLinearVelocity
			r.AssemblyLinearVelocity = Vector3.new(v.X, thrust, v.Z)
		end
	end))
	notify('Jetpack', 'Hold jump to blast off! Use unjetpack to take it off.')
end)

addcmd('unjetpack',{'nojetpack'},function(args, speaker)
	WackyState.disconnect("jetpack")
	WackyState.clear("jetpack")
end)

addcmd('helicopter',{'heli'},function(args, speaker)
	local root = getRoot(speaker.Character)
	if not root then return end
	WackyState.clear("helicopter")
	local spin = WackyState.track("helicopter", Instance.new("BodyAngularVelocity"))
	spin.Name = randomString()
	spin.MaxTorque = Vector3.new(0, math.huge, 0)
	spin.AngularVelocity = Vector3.new(0, WackyState.num(args[1], 40), 0)
	spin.Parent = root
	local lift = WackyState.track("helicopter", Instance.new("BodyVelocity"))
	lift.Name = randomString()
	lift.MaxForce = Vector3.new(0, math.huge, 0)
	lift.Velocity = Vector3.new(0, 0, 0)
	lift.Parent = root
	-- hover in place, hold jump to climb
	WackyState.connect("helicopter", RunService.Heartbeat:Connect(function()
		if not lift.Parent then
			WackyState.disconnect("helicopter")
			return
		end
		local hum = speaker.Character and speaker.Character:FindFirstChildOfClass("Humanoid")
		lift.Velocity = Vector3.new(0, (hum and hum.Jump) and 14 or 0, 0)
	end))
	WackyState.remember("helicopter", args)
	notify('Helicopter', 'Whup whup whup! Hold jump to climb. Use unhelicopter to land.')
end)

addcmd('unhelicopter',{'unheli','land'},function(args, speaker)
	WackyState.disconnect("helicopter")
	WackyState.clear("helicopter")
	WackyState.forget("helicopter")
end)

-- Visual effects on your character
addcmd('trail',{'rainbowtrail'},function(args, speaker)
	local root = getRoot(speaker.Character)
	if not root then return end
	WackyState.clear("trail")
	local a0 = WackyState.track("trail", Instance.new("Attachment"))
	a0.Name = randomString()
	a0.Position = Vector3.new(0, 1, 0)
	a0.Parent = root
	local a1 = WackyState.track("trail", Instance.new("Attachment"))
	a1.Name = randomString()
	a1.Position = Vector3.new(0, -1.5, 0)
	a1.Parent = root
	local trail = WackyState.track("trail", Instance.new("Trail"))
	trail.Name = randomString()
	trail.Attachment0 = a0
	trail.Attachment1 = a1
	trail.Lifetime = WackyState.num(args[1], 1.5)
	trail.LightEmission = 1
	trail.FaceCamera = true
	trail.Transparency = NumberSequence.new(0, 1)
	trail.WidthScale = NumberSequence.new(1, 0)
	trail.Color = WackyState.rainbowSequence()
	trail.Parent = root
	WackyState.remember("trail", args)
end)

addcmd('untrail',{'notrail','unrainbowtrail'},function(args, speaker)
	WackyState.clear("trail")
	WackyState.forget("trail")
end)

addcmd('partyfx',{'glowup'},function(args, speaker)
	local root = getRoot(speaker.Character)
	if not root then return end
	WackyState.disconnect("partyfx")
	WackyState.clear("partyfx")
	local sparkles = WackyState.track("partyfx", Instance.new("Sparkles"))
	sparkles.Name = randomString()
	sparkles.Parent = root
	local light = WackyState.track("partyfx", Instance.new("PointLight"))
	light.Name = randomString()
	light.Range = 16
	light.Brightness = 3
	light.Parent = root
	local fire = WackyState.track("partyfx", Instance.new("Fire"))
	fire.Name = randomString()
	fire.Size = 3
	fire.Heat = 4
	fire.Parent = root
	WackyState.connect("partyfx", RunService.Heartbeat:Connect(function()
		local color = WackyState.rainbow(0.5)
		pcall(function()
			light.Color = color
			sparkles.SparkleColor = color
			fire.Color = color
			fire.SecondaryColor = WackyState.rainbow(0.5, 0.3)
		end)
	end))
	WackyState.remember("partyfx", args)
end)

addcmd('unpartyfx',{'unglowup','nopartyfx'},function(args, speaker)
	WackyState.disconnect("partyfx")
	WackyState.clear("partyfx")
	WackyState.forget("partyfx")
end)

addcmd('beyblade',{'letitrip'},function(args, speaker)
	execCmd('spin ' .. tostring(WackyState.num(args[1], 80)), speaker)
	execCmd('partyfx', speaker)
	notify('Beyblade', '3, 2, 1... LET IT RIP!')
end)

addcmd('unbeyblade',{'nobeyblade'},function(args, speaker)
	execCmd('unspin', speaker)
	execCmd('unpartyfx', speaker)
end)

-- Silly notifications (only you see these)
WackyState.eightBall = {
	"It is certain.", "Without a doubt.", "You may rely on it.", "Yes, definitely.", "Most likely.",
	"Outlook good.", "Signs point to yes.", "Reply hazy, try again.", "Ask again later.",
	"Better not tell you now.", "Cannot predict now.", "Don't count on it.", "My reply is no.",
	"My sources say no.", "Outlook not so good.", "Very doubtful.", "Ask a noob, they know.",
	"The bacon hair council says yes.", "Absolutely not. Never. Ever.", "Only if you do a backflip first."
}

WackyState.fortunes = {
	"You will find a free Robux in an obby. It will be a lie.",
	"A suspicious noob will offer you a trade. Decline.",
	"Your next jump will be legendary.",
	"Beware of lava that looks like regular floor.",
	"Today is a good day to moonwalk.",
	"Somewhere, a guest misses you.",
	"You will win the next game of tag. Probably.",
	"An oof is coming. Embrace it.",
	"The dance floor calls to you.",
	"Your hat collection will grow mightily.",
	"Fortune favors those who type ;chaos.",
	"A wise player once said: 'just don't fall'."
}

WackyState.compliments = {
	"Your avatar is drip incarnate.", "Your parkour is basically art.", "Even the admins are jealous of your style.",
	"You have main character energy.", "Your ping is low and so is your stress.", "Legends say you've never fallen off an obby.",
	"You walk like you own the server.", "10/10 vibes, would trade with again."
}

WackyState.roasts = {
	"Your avatar was free and it shows.", "You jump like the spacebar owes you money.",
	"You've fallen off more obbies than gravity has.", "Your aim is a cry for help.",
	"Even the noobs feel sorry for you.", "Your inventory is just vibes and regret.",
	"You walked into lava. On purpose? We may never know.", "Your hat is doing all the work."
}

addcmd('magic8ball',{'8ball'},function(args, speaker)
	local question = getstring(1, args)
	notify('Magic 8-Ball', (question ~= "" and ('"' .. question .. '" -> ') or '') .. WackyState.pick(WackyState.eightBall))
end)

addcmd('coinflip',{'flipcoin'},function(args, speaker)
	notify('Coin Flip', math.random(1, 2) == 1 and 'Heads!' or 'Tails!')
end)

addcmd('roll',{'dice'},function(args, speaker)
	local sides = math.max(2, math.floor(WackyState.num(args[1], 6)))
	notify('Dice', 'You rolled a ' .. math.random(1, sides) .. ' (d' .. sides .. ')')
end)

addcmd('fortune',{'fortunecookie'},function(args, speaker)
	notify('Fortune Cookie', WackyState.pick(WackyState.fortunes))
end)

addcmd('compliment',{'hypeme'},function(args, speaker)
	notify('Compliment', WackyState.pick(WackyState.compliments))
end)

addcmd('roastme',{},function(args, speaker)
	notify('Roast', WackyState.pick(WackyState.roasts))
end)

-- Chaos and cleanup
WackyState.chaosList = {
	'disco', 'rainbowchar', 'drunk', 'confetti 120', 'helicopter', 'backflip', 'frontflip 2', 'barrelroll',
	'rocket', 'trail', 'partyfx', 'filter random', 'weather random', 'dancefloor', 'camroll 180',
	'earthquake 0.6', 'vertigo', 'orbitcam', 'ghost', 'moongravity', 'pogo', 'jetpack', 'moonwalk',
	'beyblade', 'magic8ball', 'fortune', 'compliment', 'roastme'
}

WackyState.undoList = {
	'undisco', 'unrainbowchar', 'unghost', 'undrunk', 'unearthquake', 'uncamroll', 'unorbitcam',
	'unfilter', 'unweather', 'undancefloor', 'normalgravity', 'unpogo', 'unmoonwalk', 'unjetpack',
	'unhelicopter', 'untrail', 'unpartyfx', 'unspin'
}

addcmd('chaos',{'randomwacky','surpriseme'},function(args, speaker)
	local cmd = WackyState.pick(WackyState.chaosList)
	notify('Chaos', 'The wheel of chaos picked: ' .. cmd)
	execCmd(cmd, speaker)
end)

addcmd('unwacky',{'stopwacky','unchaos'},function(args, speaker)
	for _, cmd in ipairs(WackyState.undoList) do
		execCmd(cmd, speaker)
	end
	notify('Wacky', 'All wacky effects cleared. Back to boring reality.')
end)

addcmd('wacky',{'wackyhelp'},function(args, speaker)
	notify('Wacky Commands', 'Open the command list and scroll to the bottom for every wacky command: party effects, limbs (flail, windmill, robot, dab, tpose...), movement (slide, tornado, multijump, sprint...), camera, screen fun, chaos and unwacky.', 12)
end)
-- ================== END WACKY COMMANDS ==================

-- ==================== WACKY COMMANDS 2 ====================
WackyState.colors = {
	red = Color3.fromRGB(255, 60, 60), orange = Color3.fromRGB(255, 150, 40), yellow = Color3.fromRGB(255, 230, 60),
	green = Color3.fromRGB(60, 255, 100), blue = Color3.fromRGB(60, 140, 255), purple = Color3.fromRGB(170, 80, 255),
	pink = Color3.fromRGB(255, 120, 200), white = Color3.new(1, 1, 1), black = Color3.fromRGB(20, 20, 20),
	gold = Color3.fromRGB(255, 200, 50), cyan = Color3.fromRGB(60, 240, 255)
}

WackyState.colorArg = function(arg)
	return arg and WackyState.colors[arg:lower()] or nil
end

-- Skins
WackyState.skins = {
	gold = {Material = Enum.Material.Foil, Color = Color3.fromRGB(255, 200, 50)},
	chrome = {Material = Enum.Material.Foil, Color = Color3.fromRGB(200, 200, 215)},
	diamond = {Material = Enum.Material.Glass, Color = Color3.fromRGB(150, 230, 255), Transparency = 0.25},
	glass = {Material = Enum.Material.Glass, Color = Color3.new(1, 1, 1), Transparency = 0.5},
	ice = {Material = Enum.Material.Ice, Color = Color3.fromRGB(170, 220, 255)},
	lava = {Material = Enum.Material.CrackedLava, Color = Color3.fromRGB(255, 90, 20)},
	neon = {Material = Enum.Material.Neon},
	wood = {Material = Enum.Material.Wood, Color = Color3.fromRGB(140, 90, 50)},
	stone = {Material = Enum.Material.Slate, Color = Color3.fromRGB(120, 120, 120)},
	grass = {Material = Enum.Material.Grass, Color = Color3.fromRGB(80, 170, 60)},
}

addcmd('skin',{'material'},function(args, speaker)
	local names = {}
	for k in pairs(WackyState.skins) do
		table.insert(names, k)
	end
	table.sort(names)
	local choice = args[1] and args[1]:lower() or "random"
	if choice == "random" then
		choice = WackyState.pick(names)
	end
	local preset = WackyState.skins[choice]
	if not preset then
		notify('Skin', 'Unknown skin. Try: ' .. table.concat(names, ', ') .. ', random')
		return
	end
	local color = preset.Color or WackyState.colorArg(args[2]) or WackyState.randomColor()
	WackyState.saved.skin = WackyState.saved.skin or setmetatable({}, {__mode = "k"})
	for _, part in ipairs(WackyState.parts(speaker)) do
		if WackyState.saved.skin[part] == nil then
			WackyState.saved.skin[part] = {part.Color, part.Material, part.Transparency}
		end
		pcall(function()
			part.Material = preset.Material
			part.Color = color
			if preset.Transparency and part.Transparency < 1 then
				part.Transparency = preset.Transparency
			end
		end)
	end
	WackyState.remember("skin", {choice, args[2]})
	notify('Skin', 'You are now made of ' .. choice .. '. Use unskin to change back.')
end)

addcmd('unskin',{'unmaterial'},function(args, speaker)
	WackyState.forget("skin")
	for part, data in pairs(WackyState.saved.skin or {}) do
		if part.Parent then
			part.Color, part.Material, part.Transparency = data[1], data[2], data[3]
		end
	end
	WackyState.saved.skin = nil
end)

-- Aura
addcmd('aura',{},function(args, speaker)
	local root = getRoot(speaker.Character)
	if not root then return end
	WackyState.clear("aura")
	local color = WackyState.colorArg(args[1])
	local emitter = WackyState.track("aura", Instance.new("ParticleEmitter"))
	emitter.Name = randomString()
	emitter.Rate = 60
	emitter.Speed = NumberRange.new(1, 3)
	emitter.SpreadAngle = Vector2.new(180, 180)
	emitter.Lifetime = NumberRange.new(1, 1.8)
	emitter.Acceleration = Vector3.new(0, 4, 0)
	emitter.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.8), NumberSequenceKeypoint.new(1, 0)})
	emitter.Transparency = NumberSequence.new(0.2, 1)
	emitter.LightEmission = 1
	emitter.Color = color and ColorSequence.new(color) or WackyState.rainbowSequence()
	emitter.Parent = root
	WackyState.remember("aura", args)
end)

addcmd('unaura',{'noaura'},function(args, speaker)
	WackyState.clear("aura")
	WackyState.forget("aura")
end)

-- Halo
addcmd('halo',{},function(args, speaker)
	WackyState.disconnect("halo")
	WackyState.clear("halo")
	local color = WackyState.colorArg(args[1]) or Color3.fromRGB(255, 230, 120)
	local orbs = {}
	for i = 1, 12 do
		local orb = WackyState.track("halo", Instance.new("Part"))
		orb.Name = randomString()
		orb.Shape = Enum.PartType.Ball
		orb.Size = Vector3.new(0.35, 0.35, 0.35)
		orb.Material = Enum.Material.Neon
		orb.Color = color
		orb.Anchored = true
		orb.CanCollide = false
		orb.CanQuery = false
		orb.CanTouch = false
		orb.Parent = workspace
		table.insert(orbs, orb)
	end
	WackyState.connect("halo", RunService.Heartbeat:Connect(function()
		local head = speaker.Character and speaker.Character:FindFirstChild("Head")
		if not head then return end
		local t = tick()
		for i, orb in ipairs(orbs) do
			local a = t * 1.5 + (i / #orbs) * math.pi * 2
			orb.CFrame = CFrame.new(head.Position + Vector3.new(math.cos(a) * 1.1, 1.3 + math.sin(t * 2) * 0.1, math.sin(a) * 1.1))
		end
	end))
end)

addcmd('unhalo',{'nohalo'},function(args, speaker)
	WackyState.disconnect("halo")
	WackyState.clear("halo")
end)

-- Pet companion
WackyState.petNames = {"Sir Cubes", "Blocky", "Mr. Bobble", "Lil Noob", "Sparkles", "Captain Oof", "Pebble", "Nugget"}

addcmd('pet',{'companion'},function(args, speaker)
	local name = getstring(1, args)
	if name == "" then
		name = WackyState.pick(WackyState.petNames)
	end
	WackyState.disconnect("pet")
	WackyState.clear("pet")
	local body = WackyState.track("pet", Instance.new("Part"))
	body.Name = randomString()
	body.Size = Vector3.new(1.4, 1.4, 1.4)
	body.Material = Enum.Material.Neon
	body.Anchored = true
	body.CanCollide = false
	body.CanQuery = false
	body.CanTouch = false
	local face = Instance.new("SurfaceGui")
	face.Face = Enum.NormalId.Front
	face.Parent = body
	local faceText = Instance.new("TextLabel")
	faceText.Size = UDim2.new(1, 0, 1, 0)
	faceText.BackgroundTransparency = 1
	faceText.Text = "^_^"
	faceText.TextScaled = true
	faceText.Font = Enum.Font.GothamBold
	faceText.TextColor3 = Color3.new(0, 0, 0)
	faceText.Parent = face
	local tag = Instance.new("BillboardGui")
	tag.Size = UDim2.new(0, 120, 0, 24)
	tag.StudsOffset = Vector3.new(0, 1.6, 0)
	tag.AlwaysOnTop = true
	tag.Parent = body
	local tagText = Instance.new("TextLabel")
	tagText.Size = UDim2.new(1, 0, 1, 0)
	tagText.BackgroundTransparency = 1
	tagText.Text = name
	tagText.TextScaled = true
	tagText.Font = Enum.Font.GothamBold
	tagText.TextColor3 = Color3.new(1, 1, 1)
	tagText.TextStrokeTransparency = 0.3
	tagText.Parent = tag
	body.Parent = workspace
	local faces = {"^_^", "o_o", ":3", "^o^", "-_-", ">_<", "owo"}
	local lastFace = 0
	WackyState.connect("pet", RunService.Heartbeat:Connect(function()
		local root = getRoot(speaker.Character)
		if not root then return end
		local t = tick()
		local target = (root.CFrame * CFrame.new(3, 1.5 + math.sin(t * 3) * 0.4, 2)).Position
		local pos = body.Position:Lerp(target, 0.12)
		body.CFrame = CFrame.lookAt(pos, workspace.CurrentCamera.CFrame.Position)
		body.Color = WackyState.rainbow(0.15)
		if t - lastFace > 2.5 then
			lastFace = t
			faceText.Text = WackyState.pick(faces)
		end
	end))
	notify('Pet', 'Say hi to ' .. name .. '! Use unpet to send them home.')
end)

addcmd('unpet',{'nopet'},function(args, speaker)
	WackyState.disconnect("pet")
	WackyState.clear("pet")
end)

-- Explosions and fireworks (visual only, no damage)
addcmd('nuke',{'kaboom'},function(args, speaker)
	local root = getRoot(speaker.Character)
	if not root then return end
	local pos = root.Position + root.CFrame.LookVector * 40
	local boom = Instance.new("Explosion")
	boom.Position = pos
	boom.BlastRadius = 30
	boom.BlastPressure = 0
	boom.DestroyJointRadiusPercent = 0
	boom.ExplosionType = Enum.ExplosionType.NoCraters
	boom.Parent = workspace
	local ball = Instance.new("Part")
	ball.Name = randomString()
	ball.Shape = Enum.PartType.Ball
	ball.Anchored = true
	ball.CanCollide = false
	ball.CanQuery = false
	ball.CanTouch = false
	ball.Material = Enum.Material.Neon
	ball.Color = Color3.fromRGB(255, 140, 40)
	ball.Size = Vector3.new(2, 2, 2)
	ball.Position = pos
	ball.Parent = workspace
	TweenService:Create(ball, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = Vector3.new(60, 60, 60), Transparency = 1}):Play()
	Services.Debris:AddItem(ball, 2)
	local flash = Instance.new("ColorCorrectionEffect")
	flash.Name = randomString()
	flash.Brightness = 0.8
	flash.Parent = Lighting
	TweenService:Create(flash, TweenInfo.new(1.5), {Brightness = 0}):Play()
	Services.Debris:AddItem(flash, 2)
	WackyState.bindCam("nukeshake", function()
		local cam = workspace.CurrentCamera
		cam.CFrame = cam.CFrame * CFrame.new((math.random() - 0.5) * 1.5, (math.random() - 0.5) * 1.5, 0)
	end)
	task.delay(1.2, function()
		WackyState.unbindCam("nukeshake")
	end)
end)

addcmd('fireworks',{'firework'},function(args, speaker)
	local count = math.clamp(math.floor(WackyState.num(args[1], 5)), 1, 30)
	for i = 1, count do
		task.delay((i - 1) * 0.35, function()
			local root = getRoot(speaker.Character)
			if not root then return end
			local color = WackyState.randomColor()
			local shell = Instance.new("Part")
			shell.Name = randomString()
			shell.Shape = Enum.PartType.Ball
			shell.Size = Vector3.new(0.6, 0.6, 0.6)
			shell.Material = Enum.Material.Neon
			shell.Color = color
			shell.Anchored = true
			shell.CanCollide = false
			shell.CanQuery = false
			shell.CanTouch = false
			shell.Position = root.Position + Vector3.new(math.random(-15, 15), 0, math.random(-15, 15))
			local sparks = Instance.new("ParticleEmitter")
			sparks.Rate = 0
			sparks.Speed = NumberRange.new(20, 35)
			sparks.SpreadAngle = Vector2.new(180, 180)
			sparks.Lifetime = NumberRange.new(1, 1.6)
			sparks.Drag = 3
			sparks.Acceleration = Vector3.new(0, -8, 0)
			sparks.LightEmission = 1
			sparks.Size = NumberSequence.new(0.5, 0)
			sparks.Color = ColorSequence.new(color, WackyState.randomColor())
			sparks.Parent = shell
			shell.Parent = workspace
			pcall(function()
				local launch = WackyState.sound(WackyState.assets.sounds.fwlaunch, shell, 0.7, false, 0.9 + math.random() * 0.3)
				launch.RollOffMaxDistance = 300
			end)
			local up = TweenService:Create(shell, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = shell.Position + Vector3.new(0, math.random(35, 55), 0)})
			up:Play()
			up.Completed:Wait()
			shell.Transparency = 1
			sparks:Emit(120)
			pcall(function()
				local boom = WackyState.sound(WackyState.assets.sounds.fwboom, shell, 1, false, 1.2 + math.random() * 0.3)
				boom.RollOffMaxDistance = 600
				local crackle = WackyState.sound(WackyState.assets.sounds.fwcrackle, shell, 0.45, false, 0.9 + math.random() * 0.2)
				crackle.RollOffMaxDistance = 400
			end)
			Services.Debris:AddItem(shell, 6)
		end)
	end
end)

-- Lighting moods
addcmd('timelapse',{},function(args, speaker)
	local speed = WackyState.num(args[1], 2)
	WackyState.lightClaim("timelapse", {"ClockTime"})
	WackyState.connect("timelapse", RunService.Heartbeat:Connect(function(dt)
		Lighting.ClockTime = (Lighting.ClockTime + dt * speed) % 24
	end))
end)

addcmd('untimelapse',{'notimelapse'},function(args, speaker)
	WackyState.disconnect("timelapse")
	WackyState.lightRelease("timelapse")
end)

addcmd('sunset',{'goldenhour'},function(args, speaker)
	WackyState.lightClaim("sunset", {"ClockTime"})
	Lighting.ClockTime = 17.8
	WackyState.clear("sunset")
	local cc = WackyState.track("sunset", Instance.new("ColorCorrectionEffect"))
	cc.Name = randomString()
	cc.TintColor = Color3.fromRGB(255, 205, 170)
	cc.Saturation = 0.25
	cc.Parent = Lighting
end)

addcmd('unsunset',{'nosunset'},function(args, speaker)
	WackyState.clear("sunset")
	WackyState.lightRelease("sunset")
end)

addcmd('flashlight',{'torch'},function(args, speaker)
	local root = getRoot(speaker.Character)
	if not root then return end
	WackyState.clear("flashlight")
	local light = WackyState.track("flashlight", Instance.new("SpotLight"))
	light.Name = randomString()
	light.Face = Enum.NormalId.Front
	light.Range = 60
	light.Angle = 50
	light.Brightness = 5
	light.Shadows = true
	light.Parent = root
	WackyState.remember("flashlight", args)
end)

addcmd('unflashlight',{'untorch','noflashlight'},function(args, speaker)
	WackyState.clear("flashlight")
	WackyState.forget("flashlight")
end)

addcmd('horror',{'spookymode'},function(args, speaker)
	WackyState.lightClaim("horror", {"ClockTime", "Brightness"})
	Lighting.ClockTime = 0
	Lighting.Brightness = 0
	WackyState.clear("horror")
	local cc = WackyState.track("horror", Instance.new("ColorCorrectionEffect"))
	cc.Name = randomString()
	cc.Brightness = -0.2
	cc.Contrast = 0.4
	cc.Saturation = -0.6
	cc.TintColor = Color3.fromRGB(255, 160, 160)
	cc.Parent = Lighting
	execCmd('flashlight', speaker)
	notify('Horror', 'Something is watching you... Use unhorror to turn the lights back on.')
end)

addcmd('unhorror',{'unspookymode'},function(args, speaker)
	WackyState.clear("horror")
	execCmd('unflashlight', speaker)
	WackyState.lightRelease("horror")
end)

addcmd('matrix',{'thereisnospoon'},function(args, speaker)
	execCmd('filter nightvision', speaker)
	execCmd('moongravity 45', speaker)
	notify('Matrix', 'There is no spoon. Use unmatrix to take the blue pill.')
end)

addcmd('unmatrix',{'bluepill'},function(args, speaker)
	execCmd('unfilter', speaker)
	execCmd('normalgravity', speaker)
end)

-- Movement silliness
addcmd('flop',{'faceplant'},function(args, speaker)
	local char = speaker.Character
	local root = getRoot(char)
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not root or not hum then return end
	hum.PlatformStand = true
	local v = root.AssemblyLinearVelocity
	root.AssemblyLinearVelocity = Vector3.new(v.X, 25, v.Z)
	root.AssemblyAngularVelocity = Vector3.new(math.random(-12, 12), math.random(-6, 6), math.random(-12, 12))
	task.delay(WackyState.num(args[1], 2.5), function()
		pcall(function()
			hum.PlatformStand = false
			hum:ChangeState(Enum.HumanoidStateType.GettingUp)
		end)
	end)
end)

addcmd('zoomies',{'sanic'},function(args, speaker)
	local char = speaker.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not hum or WackyState.zooming then return end
	WackyState.zooming = true
	local old = hum.WalkSpeed
	hum.WalkSpeed = WackyState.num(args[2], 80)
	execCmd('trail 0.6', speaker)
	notify('Zoomies', 'GOTTA GO FAST!')
	task.delay(WackyState.num(args[1], 5), function()
		pcall(function() hum.WalkSpeed = old end)
		execCmd('untrail', speaker)
		WackyState.zooming = false
	end)
end)

-- More silly notifications
WackyState.jokes = {
	"Why did the noob cross the road? To get to the other obby.",
	"I told my friend a joke about lava. It was too hot to handle.",
	"Why don't Robloxians ever get lost? They always respawn at home.",
	"What's a noob's favorite exercise? Falling.",
	"I would tell you a joke about server lag... but you wouldn't get it until later.",
	"Why was the brick so calm? It was anchored.",
	"My character has a great personality. It's just not rendering yet.",
	"Why did the part go to therapy? It had too many unresolved collisions."
}

WackyState.wyr = {
	"Would you rather only walk backwards forever, or only jump everywhere?",
	"Would you rather have infinite Robux but no friends, or infinite friends but no Robux?",
	"Would you rather be a giant noob or a tiny pro?",
	"Would you rather have lava floors or ice floors in every game?",
	"Would you rather lose your hat collection or your favorite emote?",
	"Would you rather be followed by a pet forever or always have confetti falling on you?"
}

addcmd('joke',{'telljoke'},function(args, speaker)
	notify('Joke', WackyState.pick(WackyState.jokes), 8)
end)

addcmd('wouldyourather',{'wyr'},function(args, speaker)
	notify('Would You Rather', WackyState.pick(WackyState.wyr), 8)
end)

addcmd('stopwatch',{'timer'},function(args, speaker)
	if WackyState.stopwatchStart then
		notify('Stopwatch', string.format('Stopped at %.2f seconds', tick() - WackyState.stopwatchStart))
		WackyState.stopwatchStart = nil
	else
		WackyState.stopwatchStart = tick()
		notify('Stopwatch', 'Started! Run stopwatch again to stop it.')
	end
end)

for _, cmd in ipairs({'skin random', 'aura', 'halo', 'pet', 'nuke', 'fireworks 6', 'timelapse 4', 'sunset', 'horror', 'matrix', 'flop', 'zoomies', 'joke', 'wouldyourather'}) do
	table.insert(WackyState.chaosList, cmd)
end
for _, cmd in ipairs({'unskin', 'unaura', 'unhalo', 'unpet', 'untimelapse', 'unsunset', 'unhorror', 'unflashlight', 'unmatrix'}) do
	table.insert(WackyState.undoList, cmd)
end
-- ================ END WACKY COMMANDS 2 ================

-- ==================== NEVERYIELD COMMANDS ====================
addcmd('theme',{'nytheme'},function(args, speaker)
	local choice = args[1] and args[1]:lower() or "auto"
	if choice == "custom" then
		NeverYieldTheme.openStudio("custom")
		return
	end
	local ok, theme = NeverYieldTheme.apply(choice, true)
	if not ok then
		local ids = {}
		for _, t in ipairs(NeverYieldTheme.list) do table.insert(ids, t.id) end
		notify('Theme', 'Unknown theme. Try: ' .. table.concat(ids, ', ') .. ' (or type themes)')
		return
	end
	notify('Theme', theme.icon .. ' ' .. theme.name .. ' theme applied.')
end)

addcmd('spacemode',{'space'},function(args, speaker)
	WackyState.lightClaim("spacemode", {"ClockTime"})
	Lighting.ClockTime = 0
	WackyState.clear("spacemode")
	local cc = WackyState.track("spacemode", Instance.new("ColorCorrectionEffect"))
	cc.Name = randomString()
	cc.TintColor = Color3.fromRGB(205, 175, 255)
	cc.Saturation = 0.3
	cc.Contrast = 0.15
	cc.Parent = Lighting
	local bloom = WackyState.track("spacemode", Instance.new("BloomEffect"))
	bloom.Name = randomString()
	bloom.Intensity = 1.2
	bloom.Size = 30
	bloom.Threshold = 0.7
	bloom.Parent = Lighting
	execCmd('weather galaxy', speaker)
	execCmd('moongravity 20', speaker)
	notify('Space Mode', 'Houston, we have a vibe. Use unspacemode to come back to Earth.')
end)

addcmd('unspacemode',{'unspace'},function(args, speaker)
	WackyState.clear("spacemode")
	execCmd('unweather', speaker)
	execCmd('normalgravity', speaker)
	WackyState.lightRelease("spacemode")
end)

addcmd('neveryield',{'about','ny'},function(args, speaker)
	notify('NeverYield v' .. currentVersion, 'Edited by kas. ' .. #cmds .. ' commands loaded. Type wacky for the fun stuff.', 8)
end)

table.insert(WackyState.chaosList, 'spacemode')
table.insert(WackyState.undoList, 'unspacemode')
-- ================== END NEVERYIELD COMMANDS ==================

addcmd('portal',{'reopen'},function(args, speaker)
	task.spawn(NeverYieldPortal.open)
end)

-- ==================== WACKY COMMANDS 3: LIMBS, MOVEMENT, FUN ====================
-- Limb engine: effects return rotations (in the parent part's space, around the joint)
-- that override Motor6D.Transform every physics step. Works on R6 and R15.
WackyState.limbFx = {}
WackyState.limbActive = {}
WackyState.limbTouched = setmetatable({}, {__mode = "k"})
WackyState.jointRoles = {
	rightshoulder = "rs", leftshoulder = "ls", righthip = "rh", lefthip = "lh",
	neck = "neck", waist = "waist", rootjoint = "root", root = "root",
	rightelbow = "re", leftelbow = "le", rightknee = "rk", leftknee = "lk"
}

WackyState.getJoints = function(char)
	local cache = WackyState.jointCache
	if WackyState.jointChar == char and cache and cache.neck and cache.neck.motor.Parent and cache.rs and cache.rs.motor.Parent then
		return cache
	end
	local joints = {}
	for _, joint in ipairs(char:GetDescendants()) do
		-- classic rigs use Motor6D; upgraded R15 avatars use AnimationConstraint (same Transform idea,
		-- but the joint frame comes from Attachment0 instead of C0)
		local isMotor = joint:IsA("Motor6D")
		local isConstraint = not isMotor and joint:IsA("AnimationConstraint")
		if isMotor or isConstraint then
			local role = WackyState.jointRoles[(joint.Name:gsub(" ", "")):lower()]
			local enabled = true
			pcall(function() enabled = joint.Enabled end)
			local frame
			if isMotor then
				frame = joint.C0
			elseif joint.Attachment0 then
				frame = joint.Attachment0.CFrame
			end
			local current = role and joints[role]
			local better = not current or (enabled and not current.enabled) or (enabled and isConstraint and current.motor:IsA("Motor6D"))
			if role and frame and better then
				local r0 = frame - frame.Position
				joints[role] = {motor = joint, r0 = r0, r0inv = r0:Inverse(), enabled = enabled}
			end
		end
	end
	if joints.neck and joints.rs then
		WackyState.jointChar = char
		WackyState.jointCache = joints
	end
	return joints
end

WackyState.limbStep = function()
	local char = Players.LocalPlayer.Character
	if not char then return end
	local joints = WackyState.getJoints(char)
	local t = tick()
	local poses = WackyState.limbPoses
	if poses then
		table.clear(poses)
	else
		poses = {}
		WackyState.limbPoses = poses
	end
	for name, speed in pairs(WackyState.limbActive) do
		local ok, result = pcall(WackyState.limbFx[name], t, speed)
		if ok and result then
			for role, q in pairs(result) do
				poses[role] = poses[role] and (poses[role] * q) or q
			end
		end
	end
	for role, q in pairs(poses) do
		local joint = joints[role]
		if joint and joint.motor.Parent then
			joint.motor.Transform = joint.r0inv * q * joint.r0
			WackyState.limbTouched[joint.motor] = true
		end
	end
end

WackyState.limbOn = function(name, speedArg)
	WackyState.limbActive[name] = WackyState.num(speedArg, 1)
	if not WackyState.conns.limbs then
		WackyState.connect("limbs", RunService.Stepped:Connect(WackyState.limbStep))
	end
end

WackyState.limbOff = function(name)
	if name then
		WackyState.limbActive[name] = nil
	else
		WackyState.limbActive = {}
	end
	for motor in pairs(WackyState.limbTouched) do
		pcall(function() motor.Transform = CFrame.new() end)
	end
	WackyState.limbTouched = setmetatable({}, {__mode = "k"})
	if next(WackyState.limbActive) == nil then
		WackyState.disconnect("limbs")
	end
end

-- Axis guide (parent part space): +X rotation swings a hanging limb forward,
-- +Z rotation raises the right arm out to the side (use -Z for the left arm),
-- +Y rotation turns left/right, -X on the neck nods the head forward.
WackyState.limbFx.flail = function(t, s)
	local function n(seed, amp) return math.noise(t * 3 * s, seed) * amp end
	return {
		rs = CFrame.Angles(n(1.1, 6), n(2.2, 3), n(3.3, 6)),
		ls = CFrame.Angles(n(4.4, 6), n(5.5, 3), n(6.6, 6)),
		rh = CFrame.Angles(n(7.7, 3), 0, n(8.8, 2)),
		lh = CFrame.Angles(n(9.9, 3), 0, n(10.1, 2)),
		neck = CFrame.Angles(n(11.2, 1.5), n(12.3, 2), 0),
	}
end

WackyState.limbFx.windmill = function(t, s)
	return {rs = CFrame.Angles(t * 8 * s, 0, 0), ls = CFrame.Angles(t * 8 * s + math.pi, 0, 0)}
end

WackyState.jellyRoles = {"rs", "ls", "rh", "lh", "neck", "waist", "re", "le", "rk", "lk"}
WackyState.chaosRoles = {"rs", "ls", "rh", "lh", "neck", "re", "le", "rk", "lk"}

WackyState.limbFx.jelly = function(t, s)
	local poses = {}
	for i, role in ipairs(WackyState.jellyRoles) do
		poses[role] = CFrame.Angles(math.sin(t * 6 * s + i) * 0.5, 0, math.cos(t * 5 * s + i * 1.7) * 0.4)
	end
	return poses
end

WackyState.limbFx.wobblylegs = function(t, s)
	return {
		rh = CFrame.Angles(math.sin(t * 9 * s) * 0.9, 0, math.cos(t * 7 * s) * 0.6),
		lh = CFrame.Angles(math.sin(t * 9 * s + 2) * 0.9, 0, math.cos(t * 7 * s + 1) * 0.6),
		rk = CFrame.Angles(math.sin(t * 11 * s) * 1.2, 0, 0),
		lk = CFrame.Angles(math.sin(t * 11 * s + 1) * 1.2, 0, 0),
	}
end

WackyState.limbFx.headspin = function(t, s)
	return {neck = CFrame.Angles(0, t * 10 * s, 0)}
end

WackyState.limbFx.headbang = function(t, s)
	return {neck = CFrame.Angles(-math.abs(math.sin(t * 8 * s)) * 0.8 + 0.2, 0, 0)}
end

WackyState.limbFx.exorcist = function(t, s)
	return {neck = CFrame.Angles(0, math.pi + math.sin(t * 25 * s) * 0.15, math.sin(t * 13 * s) * 0.1)}
end

WackyState.limbFx.paranoid = function(t, s)
	return {neck = CFrame.Angles(math.noise(t * 4 * s, 1.3) * 0.4, math.sin(t * 1.7 * s) * 1.2 + math.noise(t * 6, 2.1) * 0.3, 0)}
end

WackyState.limbFx.sleepy = function(t, s)
	return {neck = CFrame.Angles(-0.5 - math.sin(t * 1.2 * s) * 0.25, 0, 0.15)}
end

WackyState.limbFx.tpose = function(t, s)
	return {rs = CFrame.Angles(0, 0, math.pi / 2), ls = CFrame.Angles(0, 0, -math.pi / 2)}
end

WackyState.limbFx.scarecrow = function(t, s)
	return {
		rs = CFrame.Angles(0, 0, 1.45), ls = CFrame.Angles(0, 0, -1.45),
		neck = CFrame.Angles(-0.3, 0, 0.45 + math.sin(t * 2 * s) * 0.05),
		rh = CFrame.Angles(0, 0, -0.05), lh = CFrame.Angles(0, 0, 0.05),
	}
end

WackyState.limbFx.zombie = function(t, s)
	return {
		rs = CFrame.Angles(math.pi / 2 + math.sin(t * 2 * s) * 0.1, 0, 0),
		ls = CFrame.Angles(math.pi / 2 + math.sin(t * 2 * s + 1) * 0.1, 0, 0),
		neck = CFrame.Angles(0, 0, math.sin(t * 1.5 * s) * 0.3),
	}
end

WackyState.limbFx.superman = function(t, s)
	return {rs = CFrame.Angles(math.pi * 0.95, 0, 0.1), ls = CFrame.Angles(math.pi * 0.95, 0, -0.1)}
end

WackyState.limbFx.wave = function(t, s)
	return {rs = CFrame.Angles(0, 0, 2.6 + math.sin(t * 8 * s) * 0.35)}
end

WackyState.limbFx.hooray = function(t, s)
	local bounce = math.sin(t * 6 * s) * 0.15
	return {rs = CFrame.Angles(0, 0, math.pi - 0.35 + bounce), ls = CFrame.Angles(0, 0, -(math.pi - 0.35 + bounce))}
end

WackyState.limbFx.chicken = function(t, s)
	local flap = (math.sin(t * 14 * s) + 1) * 0.35
	return {
		rs = CFrame.Angles(0, 0, 0.3 + flap), ls = CFrame.Angles(0, 0, -(0.3 + flap)),
		re = CFrame.Angles(0, 0, -0.9), le = CFrame.Angles(0, 0, 0.9),
		neck = CFrame.Angles(-math.max(0, math.sin(t * 7 * s)) * 0.5, 0, 0),
	}
end

WackyState.robotPose = {}
WackyState.robotLast = 0
WackyState.limbFx.robot = function(t, s)
	if t - WackyState.robotLast > 0.35 / s then
		WackyState.robotLast = t
		local function q() return math.rad(45 * math.random(-2, 2)) end
		WackyState.robotPose = {
			rs = CFrame.Angles(q(), 0, math.abs(q())), ls = CFrame.Angles(q(), 0, -math.abs(q())),
			neck = CFrame.Angles(0, q() * 0.5, 0), re = CFrame.Angles(math.abs(q()), 0, 0), le = CFrame.Angles(math.abs(q()), 0, 0),
		}
	end
	return WackyState.robotPose
end

WackyState.limbFx.dab = function(t, s)
	return {
		rs = CFrame.Angles(0.4, 0, 2.3),
		ls = CFrame.Angles(1.6, 0.6, -1.1),
		le = CFrame.Angles(1.4, 0, 0),
		neck = CFrame.Angles(-0.55, 0.5, 0),
	}
end

WackyState.limbFx.propeller = function(t, s)
	local spin = CFrame.Angles(0, t * 15 * s, 0)
	return {rs = spin * CFrame.Angles(0, 0, math.pi / 2), ls = spin * CFrame.Angles(0, 0, -math.pi / 2)}
end

WackyState.limbFx.airguitar = function(t, s)
	return {
		rs = CFrame.Angles(0.7 + math.sin(t * 22 * s) * 0.35, 0, 0.2),
		ls = CFrame.Angles(1.3, 0, -0.5),
		neck = CFrame.Angles(-math.abs(math.sin(t * 4 * s)) * 0.4, 0, 0),
	}
end

WackyState.limbFx.boxing = function(t, s)
	local p = math.sin(t * 9 * s)
	return {
		rs = CFrame.Angles(0.9 + math.max(0, p) * 0.7, 0, 0.1),
		ls = CFrame.Angles(0.9 + math.max(0, -p) * 0.7, 0, -0.1),
		re = CFrame.Angles(1.2 - math.max(0, p) * 1.1, 0, 0),
		le = CFrame.Angles(1.2 - math.max(0, -p) * 1.1, 0, 0),
		neck = CFrame.Angles(0, math.sin(t * 3 * s) * 0.2, 0),
	}
end

WackyState.limbFx.limbchaos = function(t, s)
	local poses = {}
	for i, role in ipairs(WackyState.chaosRoles) do
		poses[role] = CFrame.Angles(t * (2 + i) * s, t * (3 + i * 0.5) * s, t * (1 + i * 0.7) * s)
	end
	return poses
end

WackyState.limbFx.lean = function(t, s)
	return {root = CFrame.Angles(-math.rad(35 * s), 0, 0)}
end

WackyState.limbFx.twist = function(t, s)
	return {waist = CFrame.Angles(0, math.sin(t * 6 * s) * 1.2, 0), root = CFrame.Angles(0, math.sin(t * 6 * s) * 0.6, 0)}
end

WackyState.limbFx.headstand = function(t, s)
	return {root = CFrame.Angles(math.pi, 0, 0)}
end

WackyState.limbFx.breakdance = function(t, s)
	return {
		root = CFrame.Angles(math.pi, t * 8 * s, 0),
		rh = CFrame.Angles(math.sin(t * 10 * s) * 1.2, 0, 0.8), lh = CFrame.Angles(-math.sin(t * 10 * s) * 1.2, 0, -0.8),
	}
end

addcmd('flail',{'flailarms'},function(args, speaker) WackyState.limbOn('flail', args[1]) end)
addcmd('unflail',{'noflail'},function(args, speaker) WackyState.limbOff('flail') end)
addcmd('windmill',{},function(args, speaker) WackyState.limbOn('windmill', args[1]) end)
addcmd('unwindmill',{'nowindmill'},function(args, speaker) WackyState.limbOff('windmill') end)
addcmd('jelly',{'noodle'},function(args, speaker) WackyState.limbOn('jelly', args[1]) end)
addcmd('unjelly',{'unnoodle'},function(args, speaker) WackyState.limbOff('jelly') end)
addcmd('wobblylegs',{'jellylegs'},function(args, speaker) WackyState.limbOn('wobblylegs', args[1]) end)
addcmd('unwobblylegs',{'unjellylegs'},function(args, speaker) WackyState.limbOff('wobblylegs') end)
addcmd('headspin',{'owl'},function(args, speaker) WackyState.limbOn('headspin', args[1]) end)
addcmd('unheadspin',{'unowl'},function(args, speaker) WackyState.limbOff('headspin') end)
addcmd('headbang',{},function(args, speaker) WackyState.limbOn('headbang', args[1]) end)
addcmd('unheadbang',{'noheadbang'},function(args, speaker) WackyState.limbOff('headbang') end)
addcmd('exorcist',{},function(args, speaker) WackyState.limbOn('exorcist', args[1]) end)
addcmd('unexorcist',{'noexorcist'},function(args, speaker) WackyState.limbOff('exorcist') end)
addcmd('paranoid',{'lookaround'},function(args, speaker) WackyState.limbOn('paranoid', args[1]) end)
addcmd('unparanoid',{'unlookaround'},function(args, speaker) WackyState.limbOff('paranoid') end)
addcmd('sleepy',{'nod'},function(args, speaker) WackyState.limbOn('sleepy', args[1]) end)
addcmd('unsleepy',{'unnod'},function(args, speaker) WackyState.limbOff('sleepy') end)
addcmd('tpose',{},function(args, speaker) WackyState.limbOn('tpose', args[1]) end)
addcmd('untpose',{'notpose'},function(args, speaker) WackyState.limbOff('tpose') end)
addcmd('scarecrow',{},function(args, speaker) WackyState.limbOn('scarecrow', args[1]) end)
addcmd('unscarecrow',{'noscarecrow'},function(args, speaker) WackyState.limbOff('scarecrow') end)
addcmd('zombie',{'zombiearms'},function(args, speaker) WackyState.limbOn('zombie', args[1]) end)
addcmd('unzombie',{'unzombiearms'},function(args, speaker) WackyState.limbOff('zombie') end)
addcmd('superman',{'supermanpose'},function(args, speaker) WackyState.limbOn('superman', args[1]) end)
addcmd('unsuperman',{'unsupermanpose'},function(args, speaker) WackyState.limbOff('superman') end)
addcmd('wave',{'waving'},function(args, speaker) WackyState.limbOn('wave', args[1]) end)
addcmd('unwave',{'nowave'},function(args, speaker) WackyState.limbOff('wave') end)
addcmd('hooray',{'armsup'},function(args, speaker) WackyState.limbOn('hooray', args[1]) end)
addcmd('unhooray',{'unarmsup'},function(args, speaker) WackyState.limbOff('hooray') end)
addcmd('chicken',{'flap'},function(args, speaker) WackyState.limbOn('chicken', args[1]) end)
addcmd('unchicken',{'unflap'},function(args, speaker) WackyState.limbOff('chicken') end)
addcmd('robot',{'robotdance'},function(args, speaker) WackyState.limbOn('robot', args[1]) end)
addcmd('unrobot',{'unrobotdance'},function(args, speaker) WackyState.limbOff('robot') end)
addcmd('dab',{},function(args, speaker) WackyState.limbOn('dab', args[1]) end)
addcmd('undab',{'nodab'},function(args, speaker) WackyState.limbOff('dab') end)
addcmd('propeller',{'propellerarms'},function(args, speaker) WackyState.limbOn('propeller', args[1]) end)
addcmd('unpropeller',{'unpropellerarms'},function(args, speaker) WackyState.limbOff('propeller') end)
addcmd('airguitar',{'shred'},function(args, speaker) WackyState.limbOn('airguitar', args[1]) end)
addcmd('unairguitar',{'unshred'},function(args, speaker) WackyState.limbOff('airguitar') end)
addcmd('boxing',{'shadowbox'},function(args, speaker) WackyState.limbOn('boxing', args[1]) end)
addcmd('unboxing',{'unshadowbox'},function(args, speaker) WackyState.limbOff('boxing') end)
addcmd('limbchaos',{'possessed'},function(args, speaker) WackyState.limbOn('limbchaos', args[1]) end)
addcmd('unlimbchaos',{'unpossessed'},function(args, speaker) WackyState.limbOff('limbchaos') end)
addcmd('lean',{'smoothcriminal'},function(args, speaker) WackyState.limbOn('lean', args[1]) end)
addcmd('unlean',{'nolean'},function(args, speaker) WackyState.limbOff('lean') end)
addcmd('twist',{'twerk'},function(args, speaker) WackyState.limbOn('twist', args[1]) end)
addcmd('untwist',{'untwerk'},function(args, speaker) WackyState.limbOff('twist') end)
addcmd('headstand',{'upsidedownme'},function(args, speaker) WackyState.limbOn('headstand', args[1]) end)
addcmd('unheadstand',{'unupsidedownme'},function(args, speaker) WackyState.limbOff('headstand') end)
addcmd('breakdance',{'bboy'},function(args, speaker) WackyState.limbOn('breakdance', args[1]) end)
addcmd('unbreakdance',{'unbboy'},function(args, speaker) WackyState.limbOff('breakdance') end)

addcmd('randomlimbs',{'randompose'},function(args, speaker)
	local names = {}
	for name in pairs(WackyState.limbFx) do
		table.insert(names, name)
	end
	local pick = WackyState.pick(names)
	WackyState.limbOn(pick, args[1])
	notify('Limbs', 'Your body chose: ' .. pick)
end)

addcmd('unlimbs',{'resetlimbs','nolimbfx'},function(args, speaker)
	WackyState.limbOff()
end)

addcmd('limbdebug',{'jointdebug'},function(args, speaker)
	local char = speaker.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not hum then
		notify('Limb Debug', 'No character found.')
		return
	end
	WackyState.jointCache = nil
	local joints = WackyState.getJoints(char)
	local found, missing = {}, {}
	for _, role in ipairs({"neck", "rs", "ls", "rh", "lh", "root", "waist", "re", "le", "rk", "lk"}) do
		local joint = joints[role]
		if joint then
			table.insert(found, role .. "=" .. joint.motor.ClassName .. (joint.enabled and "" or "(off)"))
		else
			table.insert(missing, role)
		end
	end
	local info = "Rig: " .. tostring(hum.RigType.Name) .. " | Found: " .. table.concat(found, ", ") .. " | Missing: " .. (#missing > 0 and table.concat(missing, ", ") or "none")
	warn("[NeverYield limbdebug] " .. info)
	notify('Limb Debug', info, 20)
end)

-- Movement
WackyState.humRoot = function(speaker)
	local char = speaker.Character
	return char and char:FindFirstChildOfClass("Humanoid"), getRoot(char)
end

addcmd('crabwalk',{'sidewalk'},function(args, speaker)
	WackyState.connect("crabwalk", RunService.Heartbeat:Connect(function()
		local hum, root = WackyState.humRoot(speaker)
		if not hum or not root then return end
		if hum.AutoRotate then
			hum.AutoRotate = false
		end
		local dir = hum.MoveDirection
		if dir.Magnitude > 0.1 then
			local pos = root.Position
			root.CFrame = CFrame.lookAt(pos, pos + Vector3.new(-dir.Z, 0, dir.X))
		end
	end))
	notify('Crab Walk', 'Scuttle scuttle. Use uncrabwalk to walk normally.')
end)

addcmd('uncrabwalk',{'unsidewalk'},function(args, speaker)
	if not WackyState.conns.crabwalk then return end
	WackyState.disconnect("crabwalk")
	local hum = WackyState.humRoot(speaker)
	if hum then hum.AutoRotate = true end
end)

addcmd('zigzag',{},function(args, speaker)
	local strength = WackyState.num(args[1], 3)
	WackyState.connect("zigzag", RunService.Heartbeat:Connect(function()
		local hum, root = WackyState.humRoot(speaker)
		if not hum or not root then return end
		local dir = hum.MoveDirection
		if dir.Magnitude > 0.1 then
			root.AssemblyLinearVelocity = root.AssemblyLinearVelocity + Vector3.new(-dir.Z, 0, dir.X) * math.sin(tick() * 10) * strength
		end
	end))
end)

addcmd('unzigzag',{'nozigzag'},function(args, speaker)
	WackyState.disconnect("zigzag")
end)

addcmd('slide',{'penguin','bellyslide'},function(args, speaker)
	local hum, root = WackyState.humRoot(speaker)
	if not hum or not root then return end
	local speed = WackyState.num(args[1], 45)
	local last = root.CFrame.LookVector * Vector3.new(1, 0, 1)
	if last.Magnitude < 0.1 then last = Vector3.new(0, 0, -1) end
	last = last.Unit
	hum.PlatformStand = true
	WackyState.connect("slide", RunService.Heartbeat:Connect(function()
		local h, r = WackyState.humRoot(speaker)
		if not h or not r then return end
		h.PlatformStand = true
		if h.MoveDirection.Magnitude > 0.1 then
			last = h.MoveDirection.Unit
		end
		local pos = r.Position
		r.CFrame = CFrame.lookAt(pos, pos + last) * CFrame.Angles(-math.pi / 2, 0, 0)
		r.AssemblyLinearVelocity = Vector3.new(last.X * speed, r.AssemblyLinearVelocity.Y, last.Z * speed)
		r.AssemblyAngularVelocity = Vector3.zero
	end))
	notify('Belly Slide', 'Wheee! Steer with your movement keys. Use unslide to stand up.')
end)

addcmd('unslide',{'unpenguin','unbellyslide'},function(args, speaker)
	if not WackyState.conns.slide then return end
	WackyState.disconnect("slide")
	local hum, root = WackyState.humRoot(speaker)
	if hum then
		hum.PlatformStand = false
		hum:ChangeState(Enum.HumanoidStateType.GettingUp)
	end
	if root then
		local facing = root.CFrame.UpVector * Vector3.new(1, 0, 1)
		if facing.Magnitude < 0.1 then facing = Vector3.new(0, 0, -1) end
		local pos = root.Position + Vector3.new(0, 2, 0)
		root.CFrame = CFrame.lookAt(pos, pos + facing.Unit)
	end
end)

addcmd('tornado',{'twister'},function(args, speaker)
	local hum, root = WackyState.humRoot(speaker)
	if not root then return end
	WackyState.disconnect("tornado")
	WackyState.clear("tornado")
	local radius = WackyState.num(args[1], 8)
	local spin = WackyState.track("tornado", Instance.new("BodyAngularVelocity"))
	spin.Name = randomString()
	spin.MaxTorque = Vector3.new(0, math.huge, 0)
	spin.AngularVelocity = Vector3.new(0, 30, 0)
	spin.Parent = root
	local move = WackyState.track("tornado", Instance.new("BodyVelocity"))
	move.Name = randomString()
	move.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	move.Parent = root
	WackyState.connect("tornado", RunService.Heartbeat:Connect(function()
		local t = tick()
		move.Velocity = Vector3.new(-math.sin(t * 3) * radius * 3, math.sin(t * 2) * 4, math.cos(t * 3) * radius * 3)
	end))
	notify('Tornado', 'You are the storm now. Use untornado to touch down.')
end)

addcmd('untornado',{'untwister'},function(args, speaker)
	WackyState.disconnect("tornado")
	WackyState.clear("tornado")
end)

addcmd('ascend',{'heaven'},function(args, speaker)
	local hum, root = WackyState.humRoot(speaker)
	if not root then return end
	WackyState.disconnect("ascend")
	WackyState.clear("ascend")
	local beam = WackyState.track("ascend", Instance.new("Part"))
	beam.Name = randomString()
	beam.Anchored = true
	beam.CanCollide = false
	beam.CanQuery = false
	beam.CanTouch = false
	beam.Shape = Enum.PartType.Cylinder
	beam.Material = Enum.Material.Neon
	beam.Color = Color3.fromRGB(255, 245, 200)
	beam.Transparency = 0.6
	beam.Size = Vector3.new(400, 8, 8)
	beam.Parent = workspace
	local lift = WackyState.track("ascend", Instance.new("BodyVelocity"))
	lift.Name = randomString()
	lift.MaxForce = Vector3.new(0, math.huge, 0)
	lift.Velocity = Vector3.new(0, WackyState.num(args[1], 6), 0)
	lift.Parent = root
	WackyState.connect("ascend", RunService.Heartbeat:Connect(function()
		if not lift.Parent then
			-- you respawned: the beam goes away too
			WackyState.disconnect("ascend")
			WackyState.clear("ascend")
			return
		end
		local r = getRoot(speaker.Character)
		if r then
			beam.CFrame = CFrame.new(r.Position.X, r.Position.Y + 150, r.Position.Z) * CFrame.Angles(0, 0, math.pi / 2)
		end
	end))
	local glow = WackyState.track("ascend", Instance.new("ParticleEmitter"))
	glow.Name = randomString()
	glow.Rate = 60
	glow.Speed = NumberRange.new(1, 3)
	glow.SpreadAngle = Vector2.new(180, 180)
	glow.Lifetime = NumberRange.new(1, 1.8)
	glow.Acceleration = Vector3.new(0, 4, 0)
	glow.Size = NumberSequence.new(0.8, 0)
	glow.Transparency = NumberSequence.new(0.2, 1)
	glow.LightEmission = 1
	glow.Color = ColorSequence.new(Color3.fromRGB(255, 245, 200))
	glow.Parent = root
	notify('Ascend', 'You are being called upward... Use unascend to come back.')
end)

addcmd('unascend',{'unheaven'},function(args, speaker)
	if not WackyState.conns.ascend then return end
	WackyState.disconnect("ascend")
	WackyState.clear("ascend")
end)

addcmd('antigravity',{'floatup'},function(args, speaker)
	local hum, root = WackyState.humRoot(speaker)
	if not root then return end
	WackyState.clear("antigravity")
	local force = WackyState.track("antigravity", Instance.new("BodyForce"))
	force.Name = randomString()
	force.Force = Vector3.new(0, root.AssemblyMass * workspace.Gravity * 1.15, 0)
	force.Parent = root
	task.delay(WackyState.num(args[1], 4), function()
		pcall(function() force:Destroy() end)
	end)
end)

addcmd('dash',{},function(args, speaker)
	local hum, root = WackyState.humRoot(speaker)
	if not root then return end
	local dir = (hum and hum.MoveDirection.Magnitude > 0.1) and hum.MoveDirection or root.CFrame.LookVector
	local power = WackyState.num(args[1], 120)
	root.AssemblyLinearVelocity = Vector3.new(dir.X * power, root.AssemblyLinearVelocity.Y + 10, dir.Z * power)
	local trail = Instance.new("Fire")
	trail.Name = randomString()
	trail.Size = 4
	trail.Color = Color3.fromRGB(170, 90, 255)
	trail.SecondaryColor = Color3.fromRGB(110, 200, 255)
	trail.Parent = root
	Services.Debris:AddItem(trail, 0.6)
end)

addcmd('blink',{'blinkforward'},function(args, speaker)
	local hum, root = WackyState.humRoot(speaker)
	if not root then return end
	root.CFrame = root.CFrame + root.CFrame.LookVector * WackyState.num(args[1], 10)
end)

addcmd('multijump',{'doublejump'},function(args, speaker)
	local extra = math.max(1, math.floor(WackyState.num(args[1], 1)))
	local used, lastJump = 0, 0
	WackyState.connect("multijumpLand", RunService.Heartbeat:Connect(function()
		local hum = WackyState.humRoot(speaker)
		if hum and hum.FloorMaterial ~= Enum.Material.Air then
			used = 0
		end
	end))
	WackyState.connect("multijump", UserInputService.JumpRequest:Connect(function()
		local hum, root = WackyState.humRoot(speaker)
		if not hum or not root then return end
		if hum.FloorMaterial ~= Enum.Material.Air then
			lastJump = tick()
			return
		end
		if used >= extra or tick() - lastJump < 0.25 then return end
		used = used + 1
		lastJump = tick()
		local v = root.AssemblyLinearVelocity
		root.AssemblyLinearVelocity = Vector3.new(v.X, 50, v.Z)
	end))
	notify('Multi Jump', 'You can now jump ' .. extra .. ' extra time(s) in the air.')
end)

addcmd('unmultijump',{'undoublejump'},function(args, speaker)
	WackyState.disconnect("multijump")
	WackyState.disconnect("multijumpLand")
end)

WackyState.keyArg = function(arg, default)
	if not arg then return default end
	local wanted = arg:lower()
	for _, item in ipairs(Enum.KeyCode:GetEnumItems()) do
		if item.Name:lower() == wanted then
			return item
		end
	end
	return default
end

addcmd('shiftsprint',{'sprint'},function(args, speaker)
	local sprintSpeed = WackyState.num(args[1], 32)
	local sprintKey = WackyState.keyArg(args[2], Enum.KeyCode.LeftShift)
	WackyState.connect("sprintDown", UserInputService.InputBegan:Connect(function(input, processed)
		if processed or input.KeyCode ~= sprintKey then return end
		local hum = WackyState.humRoot(speaker)
		if hum and not WackyState.sprintOld then
			WackyState.sprintOld = hum.WalkSpeed
			hum.WalkSpeed = sprintSpeed
		end
	end))
	WackyState.connect("sprintUp", UserInputService.InputEnded:Connect(function(input)
		if input.KeyCode ~= sprintKey then return end
		local hum = WackyState.humRoot(speaker)
		if hum and WackyState.sprintOld then
			hum.WalkSpeed = WackyState.sprintOld
		end
		WackyState.sprintOld = nil
	end))
	notify('Sprint', 'Hold ' .. sprintKey.Name .. ' to sprint at speed ' .. sprintSpeed .. '. (Shift Lock also uses Left Shift: try sprint 32 Q)')
end)

addcmd('unshiftsprint',{'unsprint'},function(args, speaker)
	WackyState.disconnect("sprintDown")
	WackyState.disconnect("sprintUp")
	local hum = WackyState.humRoot(speaker)
	if hum and WackyState.sprintOld then
		hum.WalkSpeed = WackyState.sprintOld
	end
	WackyState.sprintOld = nil
end)

-- Jump tricks: watch for the moment a jump starts
WackyState.onJump = function(key, callback)
	local hooked = nil
	local stateKey = key .. "State"
	WackyState.disconnect(stateKey)
	WackyState.connect(key, RunService.Heartbeat:Connect(function()
		local hum = WackyState.humRoot(Players.LocalPlayer)
		if hum and hum ~= hooked then
			hooked = hum
			WackyState.connect(stateKey, hum.StateChanged:Connect(function(_, new)
				if not WackyState.conns[key] then
					WackyState.disconnect(stateKey)
					return
				end
				if new == Enum.HumanoidStateType.Jumping then
					local h, root = WackyState.humRoot(Players.LocalPlayer)
					if h and root then
						callback(h, root)
					end
				end
			end))
		end
	end))
end

addcmd('spinjump',{},function(args, speaker)
	WackyState.onJump("spinjump", function(hum, root)
		task.spawn(function()
			local turned = 0
			hum.AutoRotate = false
			while turned < math.pi * 2 and root.Parent do
				local dt = RunService.Heartbeat:Wait()
				local step = math.min(math.pi * 2 - turned, dt * math.pi * 2 / 0.4)
				turned = turned + step
				root.CFrame = root.CFrame * CFrame.Angles(0, step, 0)
			end
			if not WackyState.conns.moonwalk and not WackyState.conns.crabwalk then
				pcall(function() hum.AutoRotate = true end)
			end
		end)
	end)
end)

addcmd('unspinjump',{'nospinjump'},function(args, speaker)
	WackyState.disconnect("spinjump")
end)

addcmd('flipjump',{},function(args, speaker)
	WackyState.onJump("flipjump", function(hum, root)
		WackyState.flip(speaker, Vector3.new(1, 0, 0), 1)
	end)
end)

addcmd('unflipjump',{'noflipjump'},function(args, speaker)
	WackyState.disconnect("flipjump")
end)

addcmd('bouncy',{'trampoline'},function(args, speaker)
	local bounciness = WackyState.num(args[1], 0.8)
	local lastVy = 0
	WackyState.connect("bouncy", RunService.Heartbeat:Connect(function()
		local hum, root = WackyState.humRoot(speaker)
		if not hum or not root then return end
		local vy = root.AssemblyLinearVelocity.Y
		if hum.FloorMaterial ~= Enum.Material.Air and lastVy < -25 then
			local v = root.AssemblyLinearVelocity
			root.AssemblyLinearVelocity = Vector3.new(v.X, -lastVy * bounciness, v.Z)
			vy = 0
		end
		lastVy = vy
	end))
	notify('Bouncy', 'Boing! Jump off something tall. Use unbouncy to stop.')
end)

addcmd('unbouncy',{'untrampoline'},function(args, speaker)
	WackyState.disconnect("bouncy")
end)

-- On-screen fun (only you see these)
WackyState.overlay = function()
	if WackyState.screen and WackyState.screen.Parent then
		return WackyState.screen
	end
	local screen = Instance.new("ScreenGui")
	screen.Name = randomString()
	screen.IgnoreGuiInset = true
	screen.ResetOnSpawn = false
	screen.DisplayOrder = 999999
	local ok = pcall(function()
		screen.Parent = gethui and gethui() or COREGUI
	end)
	if not ok then
		screen.Parent = Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")
	end
	WackyState.screen = screen
	return screen
end

WackyState.bigLabel = function(text, color)
	local label = Instance.new("TextLabel")
	label.Name = randomString()
	label.AnchorPoint = Vector2.new(0.5, 0.5)
	label.Position = UDim2.new(0.5, 0, 0.4, 0)
	label.Size = UDim2.new(0.8, 0, 0.2, 0)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.FredokaOne
	label.TextScaled = true
	label.Text = text
	label.TextColor3 = color or Color3.new(1, 1, 1)
	label.TextStrokeTransparency = 0
	label.TextStrokeColor3 = Color3.fromRGB(40, 0, 70)
	label.Parent = WackyState.overlay()
	return label
end

addcmd('countdown',{},function(args, speaker)
	local from = math.clamp(math.floor(WackyState.num(args[1], 3)), 1, 60)
	task.spawn(function()
		for i = from, 0, -1 do
			local label = WackyState.bigLabel(i == 0 and "GO!" or tostring(i), i == 0 and Color3.fromRGB(120, 255, 140) or Color3.new(1, 1, 1))
			local scale = Instance.new("UIScale")
			scale.Scale = 1.6
			scale.Parent = label
			TweenService:Create(scale, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
			task.wait(0.8)
			TweenService:Create(label, TweenInfo.new(0.2), {TextTransparency = 1, TextStrokeTransparency = 1}):Play()
			Services.Debris:AddItem(label, 0.3)
			task.wait(0.2)
		end
	end)
end)

addcmd('screentext',{'bigtext'},function(args, speaker)
	local text = getstring(1, args)
	if text == "" then text = "NEVERYIELD" end
	local label = WackyState.bigLabel(text)
	task.spawn(function()
		local start = tick()
		while tick() - start < 3 and label.Parent do
			label.TextColor3 = WackyState.rainbow(0.8)
			RunService.RenderStepped:Wait()
		end
		TweenService:Create(label, TweenInfo.new(0.4), {TextTransparency = 1, TextStrokeTransparency = 1}):Play()
		Services.Debris:AddItem(label, 0.5)
	end)
end)

WackyState.emojis = {"\u{1F389}", "\u{2728}", "\u{1F525}", "\u{1F49C}", "\u{1F680}", "\u{1F30C}", "\u{1F602}", "\u{1F355}", "\u{2B50}", "\u{1F986}", "\u{1F47E}", "\u{1F369}"}

addcmd('emojirain',{'emojis'},function(args, speaker)
	local chosen = args[1]
	local count = math.clamp(math.floor(WackyState.num(args[2], 40)), 1, 200)
	if chosen and isNumber(chosen) then
		count = math.clamp(math.floor(tonumber(chosen)), 1, 200)
		chosen = nil
	end
	local screen = WackyState.overlay()
	for i = 1, count do
		task.delay(math.random() * 2, function()
			local label = Instance.new("TextLabel")
			label.Name = randomString()
			label.BackgroundTransparency = 1
			label.Size = UDim2.new(0, 40, 0, 40)
			label.TextScaled = true
			label.Text = chosen or WackyState.pick(WackyState.emojis)
			label.Position = UDim2.new(math.random(), -20, 0, -50)
			label.Rotation = math.random(-30, 30)
			label.Parent = screen
			local fall = TweenService:Create(label, TweenInfo.new(2 + math.random() * 2, Enum.EasingStyle.Linear), {
				Position = UDim2.new(label.Position.X.Scale, -20, 1, 50),
				Rotation = label.Rotation + math.random(-180, 180),
			})
			fall:Play()
			fall.Completed:Connect(function() label:Destroy() end)
		end)
	end
end)

addcmd('letterbox',{'cinemabars'},function(args, speaker)
	WackyState.clear("letterbox")
	local screen = WackyState.overlay()
	for _, top in ipairs({true, false}) do
		local bar = WackyState.track("letterbox", Instance.new("Frame"))
		bar.Name = randomString()
		bar.BorderSizePixel = 0
		bar.BackgroundColor3 = Color3.new(0, 0, 0)
		bar.AnchorPoint = Vector2.new(0, top and 0 or 1)
		bar.Position = UDim2.new(0, 0, top and 0 or 1, 0)
		bar.Size = UDim2.new(1, 0, 0, 0)
		bar.Parent = screen
		TweenService:Create(bar, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0.12, 0)}):Play()
	end
end)

addcmd('unletterbox',{'uncinemabars'},function(args, speaker)
	WackyState.clear("letterbox")
end)

addcmd('selfie',{'selfiecam'},function(args, speaker)
	workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
	WackyState.bindCam("selfie", function()
		local head = speaker.Character and speaker.Character:FindFirstChild("Head")
		if not head then return end
		local camPos = (head.CFrame * CFrame.new(0.6, 0.4, -4.5)).Position
		workspace.CurrentCamera.CFrame = CFrame.lookAt(camPos, head.Position)
	end)
	notify('Selfie', 'Say cheese! Use unselfie to put the phone away.')
end)

addcmd('unselfie',{'unselfiecam'},function(args, speaker)
	if not WackyState.binds.selfie then return end
	WackyState.unbindCam("selfie")
	if WackyState.binds.orbitcam then return end
	local cam = workspace.CurrentCamera
	cam.CameraType = Enum.CameraType.Custom
	local hum = WackyState.humRoot(speaker)
	if hum then cam.CameraSubject = hum end
end)

addcmd('rainbowui',{'rgbui'},function(args, speaker)
	if WackyState.conns.rainbowui then return end
	WackyState.saved.ui = {currentShade1, currentShade2, currentShade3}
	local last = 0
	WackyState.connect("rainbowui", RunService.Heartbeat:Connect(function()
		if tick() - last < 0.15 then return end
		last = tick()
		local h = (tick() * 0.15) % 1
		updateColors(Color3.fromHSV(h, 0.7, 0.18), shade1)
		updateColors(Color3.fromHSV(h, 0.7, 0.3), shade2)
		updateColors(Color3.fromHSV(h, 0.7, 0.65), shade3)
	end))
end)

addcmd('unrainbowui',{'unrgbui'},function(args, speaker)
	if not WackyState.conns.rainbowui then return end
	WackyState.disconnect("rainbowui")
	local s = WackyState.saved.ui
	if s then
		updateColors(s[1], shade1)
		updateColors(s[2], shade2)
		updateColors(s[3], shade3)
		WackyState.saved.ui = nil
	end
end)

addcmd('hud',{'statsdisplay'},function(args, speaker)
	WackyState.disconnect("hud")
	WackyState.clear("hud")
	local label = WackyState.track("hud", Instance.new("TextLabel"))
	label.Name = randomString()
	label.Position = UDim2.new(0, 12, 0, 60)
	label.Size = UDim2.new(0, 220, 0, 66)
	label.BackgroundColor3 = Color3.fromRGB(16, 10, 34)
	label.BackgroundTransparency = 0.25
	label.TextColor3 = Color3.fromRGB(236, 224, 255)
	label.Font = Enum.Font.Code
	label.TextSize = 14
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Top
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = label
	local pad = Instance.new("UIPadding")
	pad.PaddingLeft = UDim.new(0, 8)
	pad.PaddingTop = UDim.new(0, 6)
	pad.Parent = label
	label.Parent = WackyState.overlay()
	local frames, last = 0, tick()
	WackyState.connect("hud", RunService.RenderStepped:Connect(function()
		frames = frames + 1
		local now = tick()
		if now - last < 0.25 then return end
		local fps = math.floor(frames / (now - last) + 0.5)
		frames, last = 0, now
		local root = getRoot(speaker.Character)
		local speed, pos = 0, Vector3.zero
		if root then
			speed = (root.AssemblyLinearVelocity * Vector3.new(1, 0, 1)).Magnitude
			pos = root.Position
		end
		label.Text = string.format("FPS: %d\nSpeed: %.1f studs/s\nPos: %d, %d, %d", fps, speed, pos.X, pos.Y, pos.Z)
	end))
end)

addcmd('unhud',{'unstatsdisplay'},function(args, speaker)
	WackyState.disconnect("hud")
	WackyState.clear("hud")
end)

addcmd('calc',{'calculate','math'},function(args, speaker)
	local expr = getstring(1, args)
	if expr == "" or not expr:match("^[%d%s%+%-%*/%%%^%.%(%)]+$") then
		notify('Calculator', 'Only numbers and + - * / % ^ ( ) are allowed.')
		return
	end
	local fn = loadstring("return " .. expr)
	local ok, result = pcall(function() return fn and fn() end)
	if ok and result ~= nil then
		notify('Calculator', expr .. ' = ' .. tostring(result))
	else
		notify('Calculator', 'That math does not compute.')
	end
end)

addcmd('randomplayer',{'pickplayer'},function(args, speaker)
	local list = Players:GetPlayers()
	local p = WackyState.pick(list)
	notify('Random Player', 'The chosen one is ' .. p.DisplayName .. ' (@' .. p.Name .. ')')
end)

for _, cmd in ipairs({'flail', 'windmill', 'jelly', 'headspin', 'exorcist', 'tpose', 'zombie', 'chicken', 'robot', 'dab',
	'propeller', 'airguitar', 'boxing', 'limbchaos', 'breakdance', 'randomlimbs', 'crabwalk', 'zigzag', 'slide',
	'tornado', 'ascend', 'antigravity', 'dash', 'spinjump', 'flipjump', 'bouncy', 'countdown 3', 'emojirain',
	'screentext CHAOS', 'letterbox', 'selfie', 'rainbowui'}) do
	table.insert(WackyState.chaosList, cmd)
end
for _, cmd in ipairs({'unlimbs', 'uncrabwalk', 'unzigzag', 'unslide', 'untornado', 'unascend', 'unmultijump',
	'unshiftsprint', 'unspinjump', 'unflipjump', 'unbouncy', 'unletterbox', 'unselfie', 'unrainbowui'}) do
	table.insert(WackyState.undoList, cmd)
end
-- ================== END WACKY COMMANDS 3 ==================

-- ==================== NEVERYIELD THEME STUDIO ====================
NeverYieldTheme = {selected = "space", lastSpawn = 0, cards = {}}

NeverYieldTheme.rgb = function(c)
	return Color3.fromRGB(c[1], c[2], c[3])
end

NeverYieldTheme.list = {
	{id = "auto", name = "Auto Holiday", icon = "\u{1F4C5}", desc = "Wears whichever holiday theme matches today's date (Deep Space otherwise)."},
	{id = "space", name = "Deep Space", icon = "\u{1F30C}", mode = "twinkle", rate = 3,
		desc = "The original NeverYield look. Twinkling stars and a purple portal rim.",
		colors = {{16, 10, 34}, {32, 18, 64}, {86, 50, 160}, {236, 224, 255}, {0, 0, 0}, {140, 90, 235}},
		rim = {{170, 90, 255}, {255, 120, 230}, {110, 200, 255}}, particles = {"\u{2728}", "\u{2B50}", "\u{1F4AB}"}},
	{id = "nebula", name = "Nebula", icon = "\u{1F320}", mode = "twinkle", rate = 4,
		desc = "Hot pink star clouds swirling around the rim.",
		colors = {{30, 8, 36}, {58, 16, 70}, {170, 60, 170}, {255, 220, 250}, {0, 0, 0}, {230, 100, 220}},
		rim = {{255, 80, 200}, {160, 60, 255}, {255, 160, 120}}, particles = {"\u{2728}", "\u{1F4AB}", "\u{1F31F}"}},
	{id = "galaxy", name = "Galaxy", icon = "\u{1FA90}", mode = "drift", rate = 1,
		desc = "Deep blue galaxy with planets drifting past.",
		colors = {{10, 12, 40}, {22, 26, 78}, {70, 80, 190}, {220, 230, 255}, {0, 0, 0}, {110, 140, 255}},
		rim = {{90, 120, 255}, {200, 120, 255}, {120, 230, 255}}, particles = {"\u{1FA90}", "\u{2B50}", "\u{1F311}", "\u{2604}\u{FE0F}"}},
	{id = "void", name = "The Void", icon = "\u{1F573}\u{FE0F}", mode = "rise", rate = 2,
		desc = "Almost pitch black. Something is rising out of the dark.",
		colors = {{6, 4, 12}, {14, 10, 24}, {60, 36, 110}, {200, 180, 255}, {0, 0, 0}, {110, 70, 200}},
		rim = {{60, 20, 120}, {140, 60, 255}, {20, 0, 40}}, particles = {"\u{1F311}", "\u{1F5A4}", "\u{1F49C}"}},
	{id = "cosmic", name = "Cosmic Ocean", icon = "\u{2604}\u{FE0F}", mode = "fall", rate = 2,
		desc = "Teal starlight with comets streaking down.",
		colors = {{8, 22, 38}, {14, 40, 66}, {40, 130, 170}, {210, 250, 255}, {0, 0, 0}, {80, 210, 230}},
		rim = {{60, 220, 255}, {40, 120, 255}, {160, 255, 240}}, particles = {"\u{2604}\u{FE0F}", "\u{2B50}", "\u{2728}"}},
	{id = "christmas", name = "Christmas", icon = "\u{1F384}", mode = "fall", rate = 4, candy = true,
		desc = "Snow falling over a candy cane portal rim.",
		colors = {{14, 40, 24}, {24, 64, 38}, {190, 40, 50}, {255, 245, 235}, {0, 0, 0}, {220, 60, 60}},
		rim = {{230, 40, 50}, {255, 255, 255}, {40, 170, 70}}, particles = {"\u{2744}\u{FE0F}", "\u{2728}", "\u{1F381}", "\u{26C4}"}},
	{id = "halloween", name = "Halloween", icon = "\u{1F383}", mode = "drift", rate = 2, fx = "flicker",
		desc = "Bats and ghosts drifting past a flickering, haunted rim.",
		colors = {{18, 8, 22}, {36, 14, 40}, {230, 110, 20}, {255, 220, 180}, {0, 0, 0}, {255, 140, 30}},
		rim = {{255, 120, 0}, {120, 30, 160}, {40, 255, 80}}, particles = {"\u{1F987}", "\u{1F383}", "\u{1F47B}", "\u{1F578}\u{FE0F}", "\u{1F987}"}},
	{id = "newyear", name = "New Year", icon = "\u{1F386}", mode = "burst", rate = 1,
		desc = "Black and gold with confetti popping everywhere.",
		colors = {{10, 10, 14}, {26, 24, 34}, {212, 175, 55}, {255, 248, 225}, {0, 0, 0}, {240, 200, 80}},
		rim = {{255, 215, 90}, {255, 255, 255}, {200, 160, 40}}, particles = {"\u{1F389}", "\u{2728}", "\u{1F38A}", "\u{1F942}"}},
	{id = "lunarnewyear", name = "Lunar New Year", icon = "\u{1F9E7}", mode = "rise", rate = 2, fx = "glow",
		desc = "Red and gold with lanterns floating up.",
		colors = {{60, 6, 10}, {110, 14, 20}, {230, 180, 40}, {255, 235, 190}, {0, 0, 0}, {250, 200, 60}},
		rim = {{255, 40, 40}, {255, 210, 60}, {255, 120, 0}}, particles = {"\u{1F3EE}", "\u{1F9E7}", "\u{1F409}", "\u{2728}"}},
	{id = "valentines", name = "Valentine's", icon = "\u{1F498}", mode = "rise", rate = 3, fx = "heartbeat",
		desc = "Hearts floating up while the rim beats like a heart.",
		colors = {{52, 10, 30}, {90, 20, 52}, {240, 90, 150}, {255, 225, 238}, {0, 0, 0}, {255, 120, 170}},
		rim = {{255, 80, 140}, {255, 170, 200}, {200, 40, 90}}, particles = {"\u{1F496}", "\u{1F495}", "\u{1F498}", "\u{1F339}"}},
	{id = "stpatricks", name = "St. Patrick's", icon = "\u{2618}\u{FE0F}", mode = "fall", rate = 3,
		desc = "Lucky clovers, gold coins and a rainbow-gold rim.",
		colors = {{8, 36, 16}, {16, 62, 28}, {60, 180, 80}, {225, 255, 225}, {0, 0, 0}, {80, 220, 100}},
		rim = {{40, 200, 80}, {255, 215, 60}, {140, 255, 140}}, particles = {"\u{2618}\u{FE0F}", "\u{1F340}", "\u{1FA99}", "\u{1F308}"}},
	{id = "easter", name = "Easter", icon = "\u{1F423}", mode = "fall", rate = 3,
		desc = "Soft pastels with eggs, bunnies and blossoms.",
		colors = {{52, 40, 70}, {78, 62, 104}, {170, 140, 230}, {255, 250, 235}, {0, 0, 0}, {180, 230, 200}},
		rim = {{255, 190, 220}, {190, 230, 255}, {255, 245, 170}, {190, 255, 200}}, particles = {"\u{1F95A}", "\u{1F430}", "\u{1F338}", "\u{1F423}"}},
	{id = "fourthofjuly", name = "Fourth of July", icon = "\u{1F387}", mode = "burst", rate = 1.2,
		desc = "Red, white and blue with fireworks bursting.",
		colors = {{10, 16, 46}, {20, 30, 80}, {200, 30, 45}, {255, 255, 255}, {0, 0, 0}, {220, 60, 70}},
		rim = {{230, 40, 50}, {255, 255, 255}, {40, 80, 220}}, particles = {"\u{1F386}", "\u{1F387}", "\u{2B50}", "\u{2728}"}},
	{id = "thanksgiving", name = "Thanksgiving", icon = "\u{1F983}", mode = "fall", rate = 3,
		desc = "Warm autumn colors with leaves tumbling down.",
		colors = {{40, 20, 8}, {70, 38, 16}, {210, 120, 40}, {255, 235, 205}, {0, 0, 0}, {230, 140, 50}},
		rim = {{220, 110, 30}, {180, 40, 20}, {240, 190, 60}}, particles = {"\u{1F342}", "\u{1F341}", "\u{1F983}", "\u{1F967}"}},
	{id = "hanukkah", name = "Hanukkah", icon = "\u{1F54E}", mode = "rise", rate = 2, fx = "candle",
		desc = "Blue and silver with a softly glowing candle-light rim.",
		colors = {{8, 18, 50}, {16, 34, 86}, {90, 140, 230}, {235, 242, 255}, {0, 0, 0}, {170, 190, 220}},
		rim = {{70, 120, 255}, {220, 225, 235}, {140, 180, 255}}, particles = {"\u{2721}\u{FE0F}", "\u{1F54E}", "\u{2728}"}},
	{id = "diwali", name = "Diwali", icon = "\u{1FA94}", mode = "rise", rate = 3, fx = "candle",
		desc = "Festival of lights: glowing lamps and sparkles.",
		colors = {{40, 10, 40}, {72, 20, 64}, {240, 150, 30}, {255, 240, 210}, {0, 0, 0}, {255, 170, 50}},
		rim = {{255, 160, 0}, {220, 40, 160}, {255, 220, 90}}, particles = {"\u{1FA94}", "\u{2728}", "\u{1F387}"}},
	{id = "ocean", group = "vibes", name = "Ocean", icon = "\u{1F30A}", mode = "rise", rate = 2,
		desc = "Deep blue water with bubbles and fish drifting up.",
		colors = {{6, 24, 40}, {10, 44, 70}, {30, 140, 190}, {215, 245, 255}, {0, 0, 0}, {60, 190, 230}},
		rim = {{40, 200, 255}, {20, 90, 200}, {120, 255, 230}}, particles = {"\u{1F41F}", "\u{1F4A7}", "\u{1F41A}", "\u{1F30A}"}},
	{id = "sunset", group = "vibes", name = "Sunset", icon = "\u{1F305}", mode = "drift", rate = 1,
		desc = "Warm pink and orange evening sky.",
		colors = {{40, 14, 30}, {80, 28, 48}, {250, 120, 70}, {255, 232, 214}, {0, 0, 0}, {255, 150, 90}},
		rim = {{255, 120, 60}, {255, 60, 120}, {255, 200, 90}}, particles = {"\u{1F305}", "\u{2728}", "\u{1F54A}\u{FE0F}"}},
	{id = "matrix", group = "vibes", name = "Matrix", icon = "\u{1F4BB}", mode = "fall", rate = 6, fx = "glow",
		desc = "Green code raining down. There is no spoon.",
		colors = {{2, 10, 4}, {6, 22, 10}, {30, 200, 70}, {150, 255, 170}, {0, 0, 0}, {40, 220, 90}},
		rim = {{30, 255, 90}, {0, 120, 40}, {150, 255, 170}}, texts = {"0", "1", "01", "10", "1"}, textFont = "Code"},
	{id = "sakura", group = "vibes", name = "Sakura", icon = "\u{1F338}", mode = "fall", rate = 3,
		desc = "Soft pink cherry blossoms falling.",
		colors = {{50, 26, 40}, {86, 44, 66}, {240, 150, 190}, {255, 236, 244}, {0, 0, 0}, {255, 170, 210}},
		rim = {{255, 170, 210}, {255, 230, 240}, {200, 90, 150}}, particles = {"\u{1F338}", "\u{1F338}", "\u{1F4AE}"}},
	{id = "candy", group = "vibes", name = "Candy", icon = "\u{1F36D}", mode = "fall", rate = 3,
		desc = "Bubblegum colors and falling sweets.",
		colors = {{60, 20, 60}, {100, 36, 96}, {255, 120, 200}, {255, 240, 250}, {0, 0, 0}, {120, 220, 255}},
		rim = {{255, 120, 200}, {120, 220, 255}, {255, 240, 120}}, particles = {"\u{1F36C}", "\u{1F36D}", "\u{1F369}", "\u{1F9C1}"}},
	{id = "lava", group = "vibes", name = "Lava", icon = "\u{1F30B}", mode = "rise", rate = 3, fx = "candle",
		desc = "Molten orange with embers rising.",
		colors = {{30, 6, 4}, {60, 14, 8}, {255, 90, 20}, {255, 225, 200}, {0, 0, 0}, {255, 120, 30}},
		rim = {{255, 60, 0}, {255, 170, 0}, {120, 0, 0}}, particles = {"\u{1F525}", "\u{1F30B}", "\u{2728}"}},
	{id = "arctic", group = "vibes", name = "Arctic", icon = "\u{1F9CA}", mode = "fall", rate = 3,
		desc = "Icy blues, snow and penguins.",
		colors = {{14, 30, 44}, {24, 52, 74}, {140, 210, 240}, {235, 250, 255}, {0, 0, 0}, {170, 225, 250}},
		rim = {{170, 230, 255}, {255, 255, 255}, {90, 170, 230}}, particles = {"\u{1F9CA}", "\u{2744}\u{FE0F}", "\u{1F427}"}},
	{id = "forest", group = "vibes", name = "Forest", icon = "\u{1F332}", mode = "drift", rate = 2,
		desc = "Mossy greens with leaves and butterflies.",
		colors = {{10, 26, 14}, {20, 46, 24}, {90, 170, 80}, {225, 245, 220}, {0, 0, 0}, {120, 200, 100}},
		rim = {{60, 170, 70}, {150, 110, 60}, {180, 230, 120}}, particles = {"\u{1F343}", "\u{1F332}", "\u{1F344}", "\u{1F98B}"}},
	{id = "midnight", group = "vibes", name = "Midnight", icon = "\u{1F319}", mode = "twinkle", rate = 3,
		desc = "Deep night blue with a sleepy moon.",
		colors = {{6, 8, 20}, {12, 16, 36}, {70, 90, 170}, {210, 220, 255}, {0, 0, 0}, {100, 120, 220}},
		rim = {{60, 80, 200}, {200, 210, 255}, {30, 30, 90}}, particles = {"\u{1F319}", "\u{2B50}", "\u{2728}"}},
	{id = "vaporwave", group = "vibes", name = "Vaporwave", icon = "\u{1F334}", mode = "drift", rate = 2,
		desc = "Neon pink and cyan, straight out of 1995.",
		colors = {{30, 10, 50}, {56, 20, 90}, {255, 90, 200}, {255, 230, 255}, {0, 0, 0}, {90, 230, 255}},
		rim = {{255, 90, 200}, {90, 230, 255}, {180, 120, 255}}, particles = {"\u{1F334}", "\u{1F4BF}", "\u{1F4FC}", "\u{1F42C}"}},
	{id = "royal", group = "vibes", name = "Royal Gold", icon = "\u{1F451}", mode = "twinkle", rate = 3, fx = "glow",
		desc = "Black and gold with sparkling crowns and gems.",
		colors = {{28, 20, 6}, {50, 38, 12}, {230, 190, 70}, {255, 246, 215}, {0, 0, 0}, {240, 200, 90}},
		rim = {{255, 215, 90}, {255, 255, 220}, {180, 130, 30}}, particles = {"\u{1F451}", "\u{1F48E}", "\u{2728}"}},
	{id = "toxic", group = "vibes", name = "Toxic", icon = "\u{2622}\u{FE0F}", mode = "rise", rate = 3, fx = "flicker",
		desc = "Radioactive green. Do not touch.",
		colors = {{10, 20, 4}, {22, 40, 8}, {160, 255, 40}, {235, 255, 200}, {0, 0, 0}, {180, 255, 60}},
		rim = {{160, 255, 40}, {40, 60, 10}, {220, 255, 120}}, particles = {"\u{2622}\u{FE0F}", "\u{1F9EA}", "\u{1F49A}"}},
	{id = "doge", group = "memes", name = "Doge", icon = "\u{1F415}", iconImage = "rbxassetid://631727248", watermark = "rbxassetid://631727248", mode = "drift", rate = 1.5,
		desc = "much theme. very script. wow.",
		colors = {{48, 36, 14}, {82, 62, 26}, {230, 180, 70}, {255, 245, 220}, {0, 0, 0}, {240, 190, 80}},
		rim = {{240, 190, 80}, {255, 240, 200}, {160, 110, 40}}, images = {"rbxassetid://631727248", "rbxassetid://157767960"}, texts = {"wow", "such theme", "very script", "much yield", "amaze"}},
	{id = "stonks", group = "memes", name = "Stonks", icon = "\u{1F4C8}", iconImage = "rbxassetid://3362482510", watermark = "rbxassetid://3362482510", mode = "rise", rate = 2,
		desc = "Number go up. Investments only go up.",
		colors = {{6, 14, 40}, {12, 28, 70}, {40, 200, 90}, {220, 255, 230}, {0, 0, 0}, {60, 220, 110}},
		rim = {{40, 220, 90}, {40, 90, 220}, {220, 255, 230}}, images = {"rbxassetid://3362482510"}, particles = {"\u{1F4C8}", "\u{1F4B0}", "\u{1F4B8}"}, texts = {"STONKS"}},
	{id = "sus", group = "memes", name = "Among Us", icon = "\u{1F534}", iconImage = "rbxassetid://6344756217", watermark = "rbxassetid://6502780016", mode = "drift", rate = 1.5,
		desc = "Red is acting kinda sus.",
		colors = {{10, 10, 22}, {20, 20, 40}, {200, 30, 40}, {230, 235, 255}, {0, 0, 0}, {200, 40, 50}},
		rim = {{220, 30, 40}, {60, 210, 230}, {255, 255, 255}}, images = {"rbxassetid://6344756217", "rbxassetid://6696296215", "rbxassetid://6502780016"}, texts = {"sus", "SUS", "emergency meeting"}},
	{id = "nyan", group = "memes", name = "Nyan Cat", icon = "\u{1F308}", iconImage = "rbxassetid://61574940", watermark = "rbxassetid://61574940", mode = "drift", rate = 1.2,
		desc = "Nyan nyan nyan nyan nyan nyan.",
		colors = {{8, 14, 50}, {14, 24, 80}, {255, 120, 200}, {255, 255, 255}, {0, 0, 0}, {255, 150, 220}},
		rim = {{255, 60, 60}, {255, 160, 40}, {255, 240, 60}, {60, 220, 80}, {60, 140, 255}, {160, 80, 255}}, images = {"rbxassetid://61574940"}, particles = {"\u{2B50}", "\u{2728}"}},
	{id = "thisisfine", group = "memes", name = "This Is Fine", icon = "\u{1F525}", iconImage = "rbxassetid://296950923", watermark = "rbxassetid://296950923", mode = "rise", rate = 3, fx = "flicker",
		desc = "Everything is on fire. This is fine.",
		colors = {{40, 18, 6}, {74, 34, 10}, {255, 140, 40}, {255, 236, 200}, {0, 0, 0}, {255, 160, 60}},
		rim = {{255, 120, 20}, {255, 200, 60}, {180, 40, 10}}, images = {"rbxassetid://296950923"}, particles = {"\u{1F525}", "\u{1F525}", "\u{2615}"}, texts = {"this is fine"}},
	{id = "cheems", group = "memes", name = "Cheems", icon = "\u{1F436}", iconImage = "rbxassetid://6950508957", watermark = "rbxassetid://6950508957", mode = "fall", rate = 1.5,
		desc = "Hemlo. Bonk.",
		colors = {{44, 34, 20}, {74, 58, 34}, {220, 170, 90}, {255, 242, 220}, {0, 0, 0}, {230, 180, 100}},
		rim = {{220, 170, 90}, {255, 235, 200}, {140, 100, 50}}, images = {"rbxassetid://6950508957"}, texts = {"bonk", "hemlo", "bork"}},
	{id = "noob", group = "memes", name = "Noob", icon = "\u{1F642}", iconImage = "rbxassetid://458144713", watermark = "rbxassetid://458144713", mode = "drift", rate = 1.5,
		desc = "Classic Roblox. Oof.",
		colors = {{20, 40, 80}, {30, 60, 120}, {240, 210, 40}, {255, 255, 255}, {0, 0, 0}, {110, 190, 60}},
		rim = {{245, 205, 50}, {50, 110, 200}, {110, 190, 60}}, images = {"rbxassetid://458144713", "rbxassetid://1025787149"}, texts = {"oof", "OOF"}},
	{id = "vibecat", group = "memes", name = "Vibe Cat", icon = "\u{1F60E}", iconImage = "rbxassetid://5247118810", watermark = "rbxassetid://5247118810", mode = "rise", rate = 2, fx = "heartbeat",
		desc = "Just vibing. Grumpy Cat does not approve.",
		colors = {{50, 28, 44}, {80, 44, 72}, {255, 160, 210}, {255, 240, 248}, {0, 0, 0}, {255, 180, 220}},
		rim = {{255, 160, 210}, {200, 160, 255}, {255, 240, 250}}, images = {"rbxassetid://5247118810", "rbxassetid://420237037"}, particles = {"\u{1F3B5}", "\u{1F3B6}", "\u{1F60E}"}},
	{id = "moai", group = "memes", name = "Moai", icon = "\u{1F5FF}", iconImage = "rbxassetid://9496106352", watermark = "rbxassetid://9496106352", mode = "rise", rate = 1.2,
		desc = "\u{1F5FF}",
		colors = {{30, 30, 32}, {52, 52, 56}, {150, 150, 140}, {235, 235, 225}, {0, 0, 0}, {170, 170, 160}},
		rim = {{160, 160, 150}, {90, 90, 90}, {220, 220, 210}}, images = {"rbxassetid://9496106352"}, particles = {"\u{1F5FF}", "\u{1F5FF}"}},
	{id = "trollge", group = "memes", name = "Trollge", icon = "\u{1F608}", iconImage = "rbxassetid://6930020327", watermark = "rbxassetid://6930020327", mode = "twinkle", rate = 2, fx = "flicker",
		desc = "Problem?",
		colors = {{4, 4, 4}, {14, 14, 14}, {200, 200, 200}, {255, 255, 255}, {0, 0, 0}, {180, 180, 180}},
		rim = {{255, 255, 255}, {40, 40, 40}, {160, 0, 0}}, images = {"rbxassetid://6930020327"}, texts = {"problem?"}},
	{id = "skull", group = "memes", name = "Skull", icon = "\u{1F480}", iconImage = "rbxassetid://6991349708", watermark = "rbxassetid://6991349708", mode = "fall", rate = 2,
		desc = "I'm dead. \u{1F480}",
		colors = {{12, 10, 10}, {28, 24, 22}, {220, 210, 190}, {245, 240, 230}, {0, 0, 0}, {200, 190, 170}},
		rim = {{235, 225, 205}, {90, 80, 70}, {255, 255, 255}}, images = {"rbxassetid://6991349708"}, particles = {"\u{1F480}", "\u{2620}\u{FE0F}"}},
	{id = "funnyaward", group = "memes", name = "Funny Award", icon = "\u{1F3C6}", iconImage = "rbxassetid://4748311898", watermark = "rbxassetid://4748311898", mode = "burst", rate = 0.8,
		desc = "And the funny award goes to... not you.",
		colors = {{60, 8, 8}, {100, 16, 16}, {240, 190, 40}, {255, 245, 220}, {0, 0, 0}, {250, 200, 60}},
		rim = {{230, 30, 30}, {255, 210, 60}, {255, 255, 255}}, images = {"rbxassetid://4748311898"}, particles = {"\u{1F3C6}"}, texts = {"not you"}},
	{id = "classic", name = "Classic", icon = "\u{2B1B}", desc = "The original grey Infinite Yield colors, no effects.",
		colors = {{36, 36, 37}, {46, 46, 47}, {78, 78, 79}, {255, 255, 255}, {0, 0, 0}, {78, 78, 79}},
		rim = {{120, 120, 125}, {200, 200, 205}, {120, 120, 125}}},
	{id = "custom", name = "Custom Colors", icon = "\u{1F3A8}", desc = "Your own colors, made in the Custom Colors tab."},
}

NeverYieldTheme.cosmicIds = {auto = true, space = true, nebula = true, galaxy = true, void = true, cosmic = true, classic = true}

NeverYieldTheme.groupOf = function(theme)
	return theme.group or (NeverYieldTheme.cosmicIds[theme.id] and "cosmic" or "holidays")
end

NeverYieldTheme.byId = {}
for _, theme in ipairs(NeverYieldTheme.list) do
	NeverYieldTheme.byId[theme.id] = theme
end

NeverYieldTheme.sequence = function(theme, lighten)
	local rim = theme.rim or {{170, 90, 255}, {255, 120, 230}, {110, 200, 255}}
	local keys = {}
	for i = 0, #rim do
		local color = NeverYieldTheme.rgb(rim[(i % #rim) + 1])
		if lighten then
			color = color:Lerp(Color3.new(1, 1, 1), lighten)
		end
		table.insert(keys, ColorSequenceKeypoint.new(i / #rim, color))
	end
	return ColorSequence.new(keys)
end

NeverYieldTheme.candy = function()
	local keys = {}
	for i = 0, 10 do
		table.insert(keys, ColorSequenceKeypoint.new(i / 10, (i % 2 == 0) and Color3.fromRGB(230, 30, 45) or Color3.new(1, 1, 1)))
	end
	return ColorSequence.new(keys)
end

NeverYieldTheme.easterDate = function(y)
	local a, b, c = y % 19, math.floor(y / 100), y % 100
	local d, e = math.floor(b / 4), b % 4
	local f = math.floor((b + 8) / 25)
	local g = math.floor((b - f + 1) / 3)
	local h = (19 * a + b - d - g + 15) % 30
	local i, k = math.floor(c / 4), c % 4
	local l = (32 + 2 * e + 2 * i - h - k) % 7
	local m = math.floor((a + 11 * h + 22 * l) / 451)
	local n = h + l - 7 * m + 114
	return math.floor(n / 31), (n % 31) + 1
end

NeverYieldTheme.holiday = function()
	local now = os.date("*t")
	local md = now.month * 100 + now.day
	local em, ed = NeverYieldTheme.easterDate(now.year)
	local daysToEaster = (os.time({year = now.year, month = em, day = ed, hour = 12}) - os.time({year = now.year, month = now.month, day = now.day, hour = 12})) / 86400
	if md >= 1231 or md <= 102 then return "newyear" end
	if md >= 207 and md <= 214 then return "valentines" end
	if md >= 121 and md <= 220 then return "lunarnewyear" end
	if md >= 310 and md <= 317 then return "stpatricks" end
	if daysToEaster >= 0 and daysToEaster <= 7 then return "easter" end
	if md >= 628 and md <= 704 then return "fourthofjuly" end
	if md >= 1001 and md <= 1031 then return "halloween" end
	if md >= 1101 and md <= 1130 then return "thanksgiving" end
	if md >= 1201 and md <= 1230 then return "christmas" end
	return "space"
end

-- Particle layer inside the main panel
NeverYieldTheme.layer = function()
	if NeverYieldTheme.container and NeverYieldTheme.container.Parent then
		return NeverYieldTheme.container
	end
	local layer = Instance.new("Frame")
	layer.Name = randomString()
	layer.BackgroundTransparency = 1
	layer.Size = UDim2.new(1, 0, 1, 0)
	layer.ClipsDescendants = true
	layer.ZIndex = 10
	layer.Parent = Holder
	NeverYieldTheme.container = layer
	return layer
end

NeverYieldTheme.pool = function(theme)
	if theme.pool then return theme.pool end
	local pool = {}
	for _, v in ipairs(theme.particles or {}) do table.insert(pool, {kind = "emoji", value = v}) end
	for _, v in ipairs(theme.texts or {}) do table.insert(pool, {kind = "text", value = v}) end
	for _, v in ipairs(theme.images or {}) do
		table.insert(pool, {kind = "image", value = v})
		table.insert(pool, {kind = "image", value = v})
	end
	theme.pool = pool
	return pool
end

NeverYieldTheme.fade = function(label, value)
	if label:IsA("ImageLabel") then
		label.ImageTransparency = value
	else
		label.TextTransparency = value
	end
end

NeverYieldTheme.makeParticle = function(theme, parent)
	local entry = WackyState.pick(NeverYieldTheme.pool(theme))
	local label
	if entry.kind == "image" then
		label = Instance.new("ImageLabel")
		local size = math.random(20, 32)
		label.Size = UDim2.new(0, size, 0, size)
		label.Image = entry.value
		label.ScaleType = Enum.ScaleType.Fit
		label.ImageTransparency = 0.15
	else
		label = Instance.new("TextLabel")
		label.TextScaled = true
		label.Text = entry.value
		label.TextColor3 = NeverYieldTheme.rgb(theme.rim[math.random(1, #theme.rim)])
		label.TextTransparency = 0.35
		if entry.kind == "text" then
			local width = math.clamp(#entry.value * 8, 14, 110)
			label.Size = UDim2.new(0, width, 0, 16)
			label.Font = Enum.Font[theme.textFont or "Cartoon"]
			label.TextStrokeTransparency = 0.6
		else
			local size = math.random(12, 20)
			label.Size = UDim2.new(0, size, 0, size)
			label.Font = Enum.Font.GothamBold
		end
	end
	label.Name = randomString()
	label.BackgroundTransparency = 1
	label.AnchorPoint = Vector2.new(0.5, 0.5)
	label.ZIndex = 10
	label.Parent = parent
	return label
end

NeverYieldTheme.animate = function(label, info, goal)
	if label:IsA("ImageLabel") and goal.TextTransparency then
		goal.ImageTransparency = goal.TextTransparency
		goal.TextTransparency = nil
	end
	local tween = TweenService:Create(label, info, goal)
	tween.Completed:Connect(function()
		label:Destroy()
	end)
	tween:Play()
end

NeverYieldTheme.emit = function(theme, layer)
	local mode = theme.mode
	local x = math.random()
	if mode == "burst" then
		local cx, cy = 0.15 + math.random() * 0.7, 0.15 + math.random() * 0.7
		for i = 1, 8 do
			local bit = NeverYieldTheme.makeParticle(theme, layer)
			local angle = (i / 8) * math.pi * 2
			bit.Position = UDim2.new(cx, 0, cy, 0)
			NeverYieldTheme.animate(bit, TweenInfo.new(1.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Position = UDim2.new(cx + math.cos(angle) * 0.25, 0, cy + math.sin(angle) * 0.25, 0),
				TextTransparency = 1,
				Rotation = math.random(-90, 90),
			})
		end
		return
	end
	local label = NeverYieldTheme.makeParticle(theme, layer)
	if mode == "fall" then
		label.Position = UDim2.new(x, 0, 0, -12)
		NeverYieldTheme.animate(label, TweenInfo.new(3 + math.random() * 3, Enum.EasingStyle.Linear), {
			Position = UDim2.new(math.clamp(x + (math.random() - 0.5) * 0.3, 0, 1), 0, 1, 12),
			Rotation = math.random(-180, 180),
		})
	elseif mode == "rise" then
		label.Position = UDim2.new(x, 0, 1, 12)
		NeverYieldTheme.animate(label, TweenInfo.new(3 + math.random() * 3, Enum.EasingStyle.Sine), {
			Position = UDim2.new(math.clamp(x + (math.random() - 0.5) * 0.2, 0, 1), 0, 0, -12),
			TextTransparency = 0.9,
		})
	elseif mode == "drift" then
		local y = math.random()
		label.Position = UDim2.new(0, -12, y, 0)
		NeverYieldTheme.animate(label, TweenInfo.new(2 + math.random() * 2, Enum.EasingStyle.Sine), {
			Position = UDim2.new(1, 12, math.clamp(y + (math.random() - 0.5) * 0.4, 0, 1), 0),
		})
	else
		label.Position = UDim2.new(x, 0, math.random(), 0)
		NeverYieldTheme.fade(label, 1)
		NeverYieldTheme.animate(label, TweenInfo.new(0.8 + math.random(), Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, true), {
			TextTransparency = 0.2,
		})
	end
end

NeverYieldTheme.step = function()
	if Holder.Parent == nil then
		NeverYieldTheme.conn:Disconnect()
		return
	end
	local theme = NeverYieldTheme.active
	if not theme then return end
	local now = tick()
	if #NeverYieldTheme.pool(theme) > 0 and theme.rate and NeverYieldPortal.scale > 0.05 and now - NeverYieldTheme.lastSpawn > 1 / theme.rate then
		NeverYieldTheme.lastSpawn = now
		NeverYieldTheme.emit(theme, NeverYieldTheme.layer())
	end
	local rim = NeverYieldPortal.rim
	if theme.fx == "flicker" then
		rim.Transparency = (math.random() < 0.06) and 0.85 or 0
	elseif theme.fx == "heartbeat" then
		local p = (now * 1.2) % 1
		local beat = math.max(0, 1 - math.abs(p - 0.1) * 12) + math.max(0, 1 - math.abs(p - 0.3) * 12) * 0.7
		rim.Thickness = 2.5 + beat * 3
	elseif theme.fx == "candle" then
		rim.Transparency = math.clamp(0.15 + math.noise(now * 3, 0.5) * 0.4, 0, 0.6)
	elseif theme.fx == "glow" then
		rim.Thickness = 2.5 + (math.sin(now * 2) + 1) * 1.2
	end
end

NeverYieldTheme.apply = function(id, save)
	local themeId = id == "auto" and NeverYieldTheme.holiday() or id
	local theme = NeverYieldTheme.byId[themeId]
	if not theme or not theme.colors then
		return false
	end
	NeverYieldTheme.selected = id
	local c = theme.colors
	updateColors(NeverYieldTheme.rgb(c[1]), shade1)
	updateColors(NeverYieldTheme.rgb(c[2]), shade2)
	updateColors(NeverYieldTheme.rgb(c[3]), shade3)
	updateColors(NeverYieldTheme.rgb(c[4]), text1)
	updateColors(NeverYieldTheme.rgb(c[5]), text2)
	updateColors(NeverYieldTheme.rgb(c[6]), scroll)
	NeverYieldTheme.active = theme
	local seq = NeverYieldTheme.sequence(theme)
	NeverYieldPortal.swirl = function() return seq end
	NeverYieldPortal.rimGradient.Color = theme.candy and NeverYieldTheme.candy() or seq
	NeverYieldPortal.rim.Transparency = 0
	NeverYieldPortal.rim.Thickness = 2.5
	for _, ring in ipairs(NeverYieldPortal.rings) do
		ring.gradient.Color = seq
	end
	for i, spark in ipairs(NeverYieldPortal.sparks) do
		spark.BackgroundColor3 = NeverYieldTheme.rgb(theme.rim[(i % #theme.rim) + 1])
	end
	local tinted = NeverYieldTheme.sequence(theme, 0.55)
	for _, gradient in ipairs(NeverYieldGradients) do
		gradient.Color = tinted
	end
	for _, child in ipairs(NeverYieldTheme.layer():GetChildren()) do
		child:Destroy()
	end
	if theme.watermark then
		local mark = Instance.new("ImageLabel")
		mark.Name = randomString()
		mark.BackgroundTransparency = 1
		mark.AnchorPoint = Vector2.new(1, 1)
		mark.Position = UDim2.new(1, -8, 1, -8)
		mark.Size = UDim2.new(0, 96, 0, 96)
		mark.Image = theme.watermark
		mark.ScaleType = Enum.ScaleType.Fit
		mark.ImageTransparency = 0.82
		mark.ZIndex = 10
		mark.Parent = NeverYieldTheme.layer()
	end
	pcall(NeverYieldPortal.pulse)
	if save then
		pcall(function() writefile("NeverYield_theme.txt", id, true) end)
		pcall(updatesaves)
	end
	if NeverYieldTheme.refreshStudio then
		pcall(NeverYieldTheme.refreshStudio)
	end
	return true, theme
end

-- Custom colors: build the portal rim from your own accent, scrollbar and text colors
NeverYieldTheme.applyCustomRim = function()
	local function rgb(c)
		return {math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5)}
	end
	local theme = {rim = {rgb(currentShade3), rgb(currentScroll or currentShade3), rgb(currentText1:Lerp(currentShade3, 0.5))}}
	local seq = NeverYieldTheme.sequence(theme)
	NeverYieldPortal.swirl = function() return seq end
	NeverYieldPortal.rimGradient.Color = seq
	NeverYieldPortal.rim.Transparency = 0
	NeverYieldPortal.rim.Thickness = 2.5
	for _, ring in ipairs(NeverYieldPortal.rings) do
		ring.gradient.Color = seq
	end
	for i, spark in ipairs(NeverYieldPortal.sparks) do
		spark.BackgroundColor3 = NeverYieldTheme.rgb(theme.rim[(i % #theme.rim) + 1])
	end
	local tinted = NeverYieldTheme.sequence(theme, 0.55)
	for _, gradient in ipairs(NeverYieldGradients) do
		gradient.Color = tinted
	end
	for _, child in ipairs(NeverYieldTheme.layer():GetChildren()) do
		child:Destroy()
	end
end

-- Theme Studio screen
NeverYieldTheme.closeStudio = function()
	local studio = NeverYieldTheme.studio
	for _, conn in ipairs(NeverYieldTheme.dragConns or {}) do
		conn:Disconnect()
	end
	NeverYieldTheme.dragConns = {}
	if not studio then return end
	NeverYieldTheme.studio = nil
	NeverYieldTheme.refreshStudio = nil
	NeverYieldTheme.showPage = nil
	NeverYieldTheme.onCustomPage = false
	if NeverYieldTheme.studioConn then
		NeverYieldTheme.studioConn:Disconnect()
		NeverYieldTheme.studioConn = nil
	end
	local scale = studio:FindFirstChildOfClass("UIScale")
	if scale then
		TweenService:Create(scale, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Scale = 0}):Play()
		TweenService:Create(studio, TweenInfo.new(0.25), {Rotation = 10}):Play()
	end
	local screen = NeverYieldTheme.screen
	NeverYieldTheme.screen = nil
	task.delay(0.3, function()
		pcall(function() studio:Destroy() end)
		if screen then
			pcall(function() screen:Destroy() end)
		end
	end)
end

NeverYieldTheme.openStudio = function(page)
	if NeverYieldTheme.studio and NeverYieldTheme.studio.Parent then
		if page == "custom" and NeverYieldTheme.showPage then
			NeverYieldTheme.showPage(true)
		else
			NeverYieldTheme.closeStudio()
		end
		return
	end
	NeverYieldTheme.closeStudio()
	local function corner(obj, px)
		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(0, px)
		c.Parent = obj
	end
	local function currentTheme()
		local id = NeverYieldTheme.selected == "auto" and NeverYieldTheme.holiday() or NeverYieldTheme.selected
		return NeverYieldTheme.byId[id] or NeverYieldTheme.byId.space
	end

	local studio = Instance.new("Frame")
	studio.Name = randomString()
	studio.AnchorPoint = Vector2.new(0.5, 0.5)
	studio.Position = UDim2.new(0.5, 0, 0.5, 0)
	studio.Size = UDim2.new(0, 570, 0, 400)
	studio.BackgroundColor3 = currentShade1
	studio.BorderSizePixel = 0
	studio.Active = true
	studio.Rotation = 0
	studio.ZIndex = 20
	corner(studio, 16)
	local studioStroke, studioStrokeGradient = NeverYieldPortal.stroke(studio, 2.5, 0)
	local bgGradient = Instance.new("UIGradient")
	bgGradient.Parent = studio
	local scale = Instance.new("UIScale")
	scale.Scale = 0.85
	scale.Parent = studio
	local screen = Instance.new("ScreenGui")
	screen.Name = randomString()
	screen.ResetOnSpawn = false
	screen.IgnoreGuiInset = true
	screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screen.DisplayOrder = 2147483647
	if not pcall(function() screen.Parent = gethui and gethui() or COREGUI end) then
		screen.Parent = Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")
	end
	NeverYieldTheme.screen = screen
	studio.Parent = screen
	NeverYieldTheme.studio = studio

	for i = 1, 40 do
		local star = Instance.new("Frame")
		local size = math.random(1, 3)
		star.Name = "Star"
		star.BorderSizePixel = 0
		star.BackgroundColor3 = Color3.new(1, 1, 1)
		star.BackgroundTransparency = math.random() * 0.5
		star.Size = UDim2.new(0, size, 0, size)
		star.Position = UDim2.new(math.random(), 0, math.random(), 0)
		star.ZIndex = 20
		star.Parent = studio
		TweenService:Create(star, TweenInfo.new(0.6 + math.random() * 1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {BackgroundTransparency = 1}):Play()
	end

	local title = Instance.new("TextLabel")
	title.BackgroundTransparency = 1
	title.Position = UDim2.new(0, 0, 0, 10)
	title.Size = UDim2.new(1, 0, 0, 34)
	title.Font = Enum.Font.FredokaOne
	title.TextSize = 30
	title.Text = "THEME STUDIO"
	title.TextColor3 = Color3.new(1, 1, 1)
	title.ZIndex = 21
	title.Parent = studio
	local titleGradient = Instance.new("UIGradient")
	titleGradient.Parent = title

	local subtitle = Instance.new("TextLabel")
	subtitle.BackgroundTransparency = 1
	subtitle.Position = UDim2.new(0, 0, 0, 44)
	subtitle.Size = UDim2.new(1, 0, 0, 18)
	subtitle.Font = Enum.Font.Gotham
	subtitle.TextSize = 13
	subtitle.Text = "NeverYield  \u{2022}  edited by kas  \u{2022}  pick your vibe"
	subtitle.TextTransparency = 0.25
	subtitle.ZIndex = 21
	subtitle.Parent = studio

	local close = Instance.new("TextButton")
	close.AnchorPoint = Vector2.new(1, 0)
	close.Position = UDim2.new(1, -10, 0, 10)
	close.Size = UDim2.new(0, 28, 0, 28)
	close.Font = Enum.Font.GothamBold
	close.TextSize = 16
	close.Text = "X"
	close.AutoButtonColor = false
	close.BorderSizePixel = 0
	close.ZIndex = 22
	corner(close, 14)
	close.Parent = studio
	close.MouseButton1Click:Connect(NeverYieldTheme.closeStudio)
	close.MouseEnter:Connect(function()
		TweenService:Create(close, TweenInfo.new(0.15), {Rotation = 90}):Play()
	end)
	close.MouseLeave:Connect(function()
		TweenService:Create(close, TweenInfo.new(0.15), {Rotation = 0}):Play()
	end)

	local grid = Instance.new("Frame")
	grid.BackgroundTransparency = 1
	grid.BorderSizePixel = 0
	grid.Position = UDim2.new(0, 14, 0, 108)
	grid.Size = UDim2.new(1, -28, 0, 232)
	grid.ZIndex = 21
	grid.Parent = studio

	local tabs = {}
	local currentTab = "cosmic"
	local showTab
	for k, info in ipairs({{"cosmic", "Cosmic"}, {"vibes", "Vibes"}, {"holidays", "Holidays"}, {"memes", "Memes"}, {"custom", "Custom Colors"}}) do
		local tab = Instance.new("TextButton")
		tab.Position = UDim2.new(0.5, -262 + (k - 1) * 106, 0, 70)
		tab.Size = UDim2.new(0, 100, 0, 28)
		tab.AutoButtonColor = false
		tab.BorderSizePixel = 0
		tab.Font = Enum.Font.GothamBold
		tab.TextSize = 13
		tab.Text = info[2]
		tab.ZIndex = 22
		corner(tab, 14)
		tab.Parent = studio
		tabs[info[1]] = tab
		tab.MouseButton1Click:Connect(function()
			showTab(info[1])
		end)
	end
	local function styleTabs()
		local activeId = NeverYieldTheme.onCustomPage and "custom" or currentTab
		for id, tab in pairs(tabs) do
			local active = id == activeId
			tab.BackgroundColor3 = active and currentShade3 or currentShade2
			tab.BackgroundTransparency = active and 0 or 0.35
			tab.TextColor3 = currentText1
		end
	end

	local footer = Instance.new("TextLabel")
	footer.BackgroundTransparency = 1
	footer.Position = UDim2.new(0, 16, 1, -46)
	footer.Size = UDim2.new(1, -32, 0, 36)
	footer.Font = Enum.Font.Gotham
	footer.TextSize = 13
	footer.TextWrapped = true
	footer.RichText = true
	footer.ZIndex = 21
	footer.Parent = studio

	local function describe(theme, prefix)
		if NeverYieldTheme.onCustomPage then return end
		footer.Text = prefix .. ' <b>' .. theme.icon .. ' ' .. theme.name .. '</b>  \u{2014}  ' .. theme.desc
	end

	local back = Instance.new("TextButton")
	back.Position = UDim2.new(0, 10, 0, 10)
	back.Size = UDim2.new(0, 92, 0, 28)
	back.Font = Enum.Font.GothamBold
	back.TextSize = 12
	back.Text = "< Themes"
	back.AutoButtonColor = false
	back.BorderSizePixel = 0
	back.Visible = false
	back.ZIndex = 22
	corner(back, 14)
	back.Parent = studio

	local customPage = Instance.new("Frame")
	customPage.BackgroundTransparency = 1
	customPage.Position = grid.Position
	customPage.Size = grid.Size
	customPage.Visible = false
	customPage.ZIndex = 21
	customPage.Parent = studio

	local reset = Instance.new("TextButton")
	reset.Position = UDim2.new(0, 4, 0, 104)
	reset.Size = UDim2.new(0, 100, 0, 52)
	reset.AutoButtonColor = false
	reset.BorderSizePixel = 0
	reset.Font = Enum.Font.GothamBold
	reset.TextSize = 12
	reset.TextWrapped = true
	reset.Text = "Reset to Default"
	reset.ZIndex = 22
	corner(reset, 10)
	local resetStroke = Instance.new("UIStroke")
	resetStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	resetStroke.Color = Color3.fromRGB(255, 120, 120)
	resetStroke.Thickness = 1.5
	resetStroke.Transparency = 0.3
	resetStroke.Parent = reset
	reset.Parent = customPage
	local confirmUntil = 0
	reset.MouseButton1Click:Connect(function()
		if tick() < confirmUntil then
			confirmUntil = 0
			reset.Text = "Reset to Default"
			resetStroke.Thickness = 1.5
			NeverYieldTheme.apply("space", true)
			footer.Text = "<b>Reset!</b>  \u{2014}  back to the default Deep Space colors."
		else
			confirmUntil = tick() + 3
			reset.Text = "Click again to confirm"
			resetStroke.Thickness = 3
			task.delay(3, function()
				if tick() >= confirmUntil and reset.Parent then
					reset.Text = "Reset to Default"
					resetStroke.Thickness = 1.5
				end
			end)
		end
	end)

	local slots = {
		{name = "Background", tbl = shade1, get = function() return currentShade1 end},
		{name = "Panels", tbl = shade2, get = function() return currentShade2 end},
		{name = "Accent", tbl = shade3, get = function() return currentShade3 end},
		{name = "Text", tbl = text1, get = function() return currentText1 end},
		{name = "Scrollbar", tbl = scroll, get = function() return currentScroll end},
	}
	local selectedSlot = 1
	local slotButtons = {}
	local function refreshCustom()
		for i, entry in ipairs(slotButtons) do
			entry.button.BackgroundColor3 = currentShade2
			entry.button.TextColor3 = currentText1
			entry.chip.BackgroundColor3 = slots[i].get()
			entry.stroke.Transparency = (i == selectedSlot) and 0 or 1
		end
		back.BackgroundColor3 = currentShade2
		back.TextColor3 = currentText1
		reset.BackgroundColor3 = currentShade2
		reset.TextColor3 = currentText1
	end
	for i, slot in ipairs(slots) do
		local button = Instance.new("TextButton")
		button.Position = UDim2.new(0, 4 + (i - 1) * 108, 0, 0)
		button.Size = UDim2.new(0, 100, 0, 32)
		button.AutoButtonColor = false
		button.BorderSizePixel = 0
		button.Font = Enum.Font.GothamBold
		button.TextSize = 11
		button.Text = slot.name
		button.TextYAlignment = Enum.TextYAlignment.Top
		button.ZIndex = 22
		corner(button, 8)
		local padTop = Instance.new("UIPadding")
		padTop.PaddingTop = UDim.new(0, 5)
		padTop.Parent = button
		local chip = Instance.new("Frame")
		chip.AnchorPoint = Vector2.new(0.5, 1)
		chip.Position = UDim2.new(0.5, 0, 1, -4)
		chip.Size = UDim2.new(1, -16, 0, 8)
		chip.BorderSizePixel = 0
		chip.ZIndex = 23
		corner(chip, 4)
		chip.Parent = button
		local stroke = Instance.new("UIStroke")
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		stroke.Color = Color3.new(1, 1, 1)
		stroke.Thickness = 2
		stroke.Transparency = 1
		stroke.Parent = button
		button.Parent = customPage
		slotButtons[i] = {button = button, chip = chip, stroke = stroke}
		button.MouseButton1Click:Connect(function()
			selectedSlot = i
			refreshCustom()
		end)
	end

	local swatches = Instance.new("Frame")
	swatches.BackgroundTransparency = 1
	swatches.BorderSizePixel = 0
	swatches.Position = UDim2.new(0, 0, 0, 40)
	swatches.Size = UDim2.new(1, 0, 1, -40)
	swatches.ZIndex = 21
	swatches.Parent = customPage
	local palette = {}
	for _, sv in ipairs({{0.35, 1}, {0.65, 1}, {0.85, 0.8}, {0.9, 0.55}, {0.9, 0.33}, {0.85, 0.18}}) do
		for h = 0, 11 do
			table.insert(palette, Color3.fromHSV(h / 12, sv[1], sv[2]))
		end
	end
	for g = 0, 11 do
		table.insert(palette, Color3.fromHSV(0, 0, g / 11))
	end
	for i, color in ipairs(palette) do
		local swatch = Instance.new("TextButton")
		swatch.Position = UDim2.new(0, 116 + ((i - 1) % 12) * 26, 0, 2 + math.floor((i - 1) / 12) * 26)
		swatch.Size = UDim2.new(0, 22, 0, 22)
		swatch.Text = ""
		swatch.AutoButtonColor = false
		swatch.BorderSizePixel = 0
		swatch.BackgroundColor3 = color
		swatch.ZIndex = 22
		corner(swatch, 8)
		local ring = Instance.new("UIStroke")
		ring.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		ring.Color = Color3.new(1, 1, 1)
		ring.Thickness = 1
		ring.Transparency = 0.7
		ring.Parent = swatch
		swatch.Parent = swatches
		swatch.MouseEnter:Connect(function()
			ring.Thickness = 2.5
			ring.Transparency = 0
		end)
		swatch.MouseLeave:Connect(function()
			ring.Thickness = 1
			ring.Transparency = 0.7
		end)
		swatch.MouseButton1Click:Connect(function()
			updateColors(color, slots[selectedSlot].tbl)
			NeverYieldTheme.selected = "custom"
			NeverYieldTheme.active = nil
			pcall(NeverYieldTheme.applyCustomRim)
			pcall(function() writefile("NeverYield_theme.txt", "custom", true) end)
			pcall(updatesaves)
			if NeverYieldTheme.refreshStudio then
				pcall(NeverYieldTheme.refreshStudio)
			end
		end)
	end

	local function showPage(custom)
		NeverYieldTheme.onCustomPage = custom
		grid.Visible = not custom
		customPage.Visible = custom
		back.Visible = false
		if custom then
			footer.Text = "<b>\u{1F3A8} Custom Colors</b>  \u{2014}  pick a part of the GUI, then click a color. Saves automatically. Reset to Default undoes it all."
			refreshCustom()
		else
			describe(currentTheme(), "Now wearing:")
		end
	end
	NeverYieldTheme.showPage = function(custom)
		showTab(custom and "custom" or currentTab)
	end
	back.MouseButton1Click:Connect(function()
		showPage(false)
	end)

	NeverYieldTheme.cards = {}
	local cardIntro = {}
	local shownThemes = {}
	for _, theme in ipairs(NeverYieldTheme.list) do
		if theme.id ~= "custom" then
			table.insert(shownThemes, theme)
		end
	end
	local groupCount = {}
	for i, theme in ipairs(shownThemes) do
		local card = Instance.new("TextButton")
		card.Name = theme.id
		local group = NeverYieldTheme.groupOf(theme)
		groupCount[group] = (groupCount[group] or 0) + 1
		local k = groupCount[group]
		local finalPos = UDim2.new(0, 4 + ((k - 1) % 6) * 90, 0, 2 + math.floor((k - 1) / 6) * 96)
		card.Size = UDim2.new(0, 84, 0, 86)
		card.Position = finalPos + UDim2.new(0, 0, 0, 24)
		table.insert(cardIntro, {card = card, pos = finalPos, group = group})
		card.Text = ""
		card.AutoButtonColor = false
		card.BackgroundColor3 = theme.colors and NeverYieldTheme.rgb(theme.colors[2]) or Color3.fromRGB(40, 30, 60)
		card.BorderSizePixel = 0
		card.ZIndex = 21
		corner(card, 12)
		local cardStroke, cardStrokeGradient = NeverYieldPortal.stroke(card, 1.5, 0.5)
		cardStrokeGradient.Color = theme.candy and NeverYieldTheme.candy() or NeverYieldTheme.sequence(theme)
		local cardGradient = Instance.new("UIGradient")
		cardGradient.Color = NeverYieldTheme.sequence(theme, 0.45)
		cardGradient.Rotation = 90
		cardGradient.Parent = card
		local cardScale = Instance.new("UIScale")
		cardScale.Scale = 1
		cardScale.Parent = card

		local icon
		if theme.iconImage then
			icon = Instance.new("ImageLabel")
			icon.Image = theme.iconImage
			icon.ScaleType = Enum.ScaleType.Fit
			icon.AnchorPoint = Vector2.new(0.5, 0)
			icon.Position = UDim2.new(0.5, 0, 0, 5)
			icon.Size = UDim2.new(0, 40, 0, 40)
			corner(icon, 8)
		else
			icon = Instance.new("TextLabel")
			icon.Position = UDim2.new(0, 0, 0, 6)
			icon.Size = UDim2.new(1, 0, 0, 38)
			icon.TextScaled = true
			icon.Font = Enum.Font.GothamBold
			icon.Text = theme.icon
			icon.TextColor3 = Color3.new(1, 1, 1)
		end
		icon.BackgroundTransparency = 1
		icon.ZIndex = 22
		icon.Parent = card

		local name = Instance.new("TextLabel")
		name.BackgroundTransparency = 1
		name.Position = UDim2.new(0, 4, 0, 48)
		name.Size = UDim2.new(1, -8, 0, 16)
		name.Font = Enum.Font.GothamBold
		name.TextSize = 11
		name.TextTruncate = Enum.TextTruncate.AtEnd
		name.Text = theme.name
		name.TextColor3 = theme.colors and NeverYieldTheme.rgb(theme.colors[4]) or Color3.new(1, 1, 1)
		name.ZIndex = 22
		name.Parent = card

		if theme.colors then
			for d, color in ipairs({theme.colors[1], theme.colors[3], theme.rim[1]}) do
				local dot = Instance.new("Frame")
				dot.AnchorPoint = Vector2.new(0.5, 0)
				dot.Position = UDim2.new(0.5, (d - 2) * 14, 0, 68)
				dot.Size = UDim2.new(0, 10, 0, 10)
				dot.BackgroundColor3 = NeverYieldTheme.rgb(color)
				dot.BorderSizePixel = 0
				dot.ZIndex = 22
				corner(dot, 5)
				local dotStroke = Instance.new("UIStroke")
				dotStroke.Color = Color3.new(1, 1, 1)
				dotStroke.Transparency = 0.6
				dotStroke.Parent = dot
				dot.Parent = card
			end
		end

		local badge = Instance.new("TextLabel")
		badge.AnchorPoint = Vector2.new(1, 0)
		badge.Position = UDim2.new(1, -4, 0, 4)
		badge.Size = UDim2.new(0, 18, 0, 18)
		badge.BackgroundColor3 = Color3.fromRGB(120, 255, 160)
		badge.BorderSizePixel = 0
		badge.Font = Enum.Font.GothamBlack
		badge.TextSize = 12
		badge.Text = ""
		badge.TextColor3 = Color3.new(0, 0, 0)
		badge.ZIndex = 23
		badge.Visible = false
		corner(badge, 9)
		badge.Parent = card
		card.Parent = grid

		NeverYieldTheme.cards[theme.id] = {badge = badge, stroke = cardStroke, gradient = cardStrokeGradient}

		card.MouseEnter:Connect(function()
			TweenService:Create(cardScale, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1.07}):Play()
			TweenService:Create(cardStroke, TweenInfo.new(0.18), {Thickness = 3, Transparency = 0}):Play()
			TweenService:Create(icon, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Rotation = 12}):Play()
			describe(theme, "Preview:")
		end)
		card.MouseLeave:Connect(function()
			local active = NeverYieldTheme.selected == theme.id
			TweenService:Create(cardScale, TweenInfo.new(0.18), {Scale = 1}):Play()
			TweenService:Create(cardStroke, TweenInfo.new(0.18), {Thickness = active and 3 or 1.5, Transparency = active and 0 or 0.5}):Play()
			TweenService:Create(icon, TweenInfo.new(0.2), {Rotation = 0}):Play()
			describe(currentTheme(), "Now wearing:")
		end)
		card.MouseButton1Click:Connect(function()
			cardScale.Scale = 0.85
			TweenService:Create(cardScale, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1.07}):Play()
			NeverYieldTheme.apply(theme.id, true)
		end)
	end

	NeverYieldTheme.refreshStudio = function()
		local theme = currentTheme()
		studio.BackgroundColor3 = currentShade1
		studioStrokeGradient.Color = theme.candy and NeverYieldTheme.candy() or NeverYieldTheme.sequence(theme)
		bgGradient.Color = NeverYieldTheme.sequence(theme, 0.6)
		titleGradient.Color = NeverYieldTheme.sequence(theme, 0.2)
		subtitle.TextColor3 = currentText1
		footer.TextColor3 = currentText1
		close.BackgroundColor3 = currentShade2
		close.TextColor3 = currentText1
		styleTabs()
		for id, card in pairs(NeverYieldTheme.cards) do
			local active = NeverYieldTheme.selected == id
			card.badge.Visible = active
			card.stroke.Thickness = active and 3 or 1.5
			card.stroke.Transparency = active and 0 or 0.5
		end
		describe(theme, "Now wearing:")
		if NeverYieldTheme.onCustomPage then
			refreshCustom()
		end
	end
	NeverYieldTheme.onCustomPage = false
	NeverYieldTheme.refreshStudio()
	title.Active = true
	local dragging, dragStart, startPos = false, nil, nil
	NeverYieldTheme.dragConns = {
		title.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging, dragStart, startPos = true, input.Position, studio.Position
			end
		end),
		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = false
			end
		end),
		UserInputService.InputChanged:Connect(function(input)
			if not dragging or not studio.Parent then return end
			if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
			local delta = input.Position - dragStart
			studio.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end),
	}

	NeverYieldTheme.studioConn = RunService.RenderStepped:Connect(function()
		if not studio.Parent then
			NeverYieldTheme.closeStudio()
			return
		end
		local t = tick()
		studioStrokeGradient.Rotation = (t * 120) % 360
		bgGradient.Rotation = (t * 15) % 360
		titleGradient.Rotation = (t * 60) % 360
		for _, card in pairs(NeverYieldTheme.cards) do
			card.gradient.Rotation = (t * 90) % 360
		end
	end)

	TweenService:Create(scale, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
	TweenService:Create(studio, TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Rotation = 0}):Play()
	showTab = function(id)
		if id == "custom" then
			showPage(true)
		else
			currentTab = id
			for _, entry in ipairs(cardIntro) do
				entry.card.Visible = entry.group == id
			end
			showPage(false)
		end
		styleTabs()
	end
	local startTab = "cosmic"
	local sel = NeverYieldTheme.selected
	if page == "custom" or sel == "custom" then
		startTab = "custom"
	elseif sel ~= "auto" and NeverYieldTheme.byId[sel] then
		startTab = NeverYieldTheme.groupOf(NeverYieldTheme.byId[sel])
	end
	showTab(startTab)
	for i, entry in ipairs(cardIntro) do
		task.delay(0.1 + i * 0.03, function()
			if entry.card.Parent then
				TweenService:Create(entry.card, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = entry.pos}):Play()
			end
		end)
	end
end

addcmd('themes',{'themestudio','themeselect'},function(args, speaker)
	local ok, err = pcall(NeverYieldTheme.openStudio)
	if not ok then
		pcall(NeverYieldTheme.closeStudio)
		notify('Theme Studio', 'Could not open: ' .. tostring(err))
	end
end)

addcmd('themedebug',{'themestudiodebug'},function(args, speaker)
	local studio = NeverYieldTheme.studio
	if not studio or not studio.Parent then
		notify('Theme Debug', 'Theme Studio is not open. Run themes first, then themedebug.', 10)
		return
	end
	local cards, visible = 0, 0
	local first
	for _, d in ipairs(studio:GetDescendants()) do
		if d:IsA("TextButton") and NeverYieldTheme.byId[d.Name] then
			cards = cards + 1
			first = first or d
			if d.Visible and d.AbsoluteSize.X > 1 then
				visible = visible + 1
			end
		end
	end
	local info = 'Screen: ' .. tostring(studio.Parent and studio.Parent.Parent) .. ' | Size: ' .. tostring(studio.AbsoluteSize) .. ' | Cards: ' .. cards .. ' (' .. visible .. ' drawn)'
	if first then
		info = info .. ' | First card: ' .. tostring(first.AbsolutePosition) .. ' ' .. tostring(first.AbsoluteSize) .. ' vis=' .. tostring(first.Visible) .. ' grid vis=' .. tostring(first.Parent.Visible)
	end
	warn('[NeverYield themedebug] ' .. info)
	notify('Theme Debug', info, 20)
end)

addcmd('autotheme',{'holidaytheme'},function(args, speaker)
	NeverYieldTheme.apply("auto", true)
	notify('Theme', 'Auto holiday theme on: ' .. NeverYieldTheme.byId[NeverYieldTheme.holiday()].name)
end)

-- Load the saved theme (defaults to the auto holiday theme)
NeverYieldTheme.conn = RunService.Heartbeat:Connect(NeverYieldTheme.step)
task.spawn(function()
	task.wait()
	local saved = "auto"
	pcall(function()
		if isfile and isfile("NeverYield_theme.txt") then
			local data = readfile("NeverYield_theme.txt")
			if type(data) == "string" and data ~= "" then
				saved = (data:gsub("%s", ""))
			end
		end
	end)
	if saved == "custom" then
		NeverYieldTheme.selected = "custom"
		pcall(NeverYieldTheme.applyCustomRim)
	elseif not NeverYieldTheme.apply(saved, false) then
		NeverYieldTheme.apply("auto", false)
	end
end)
-- ================== END NEVERYIELD THEME STUDIO ==================

-- ==================== WEATHER 2.0 ====================
-- Sound IDs are ProSoundEffects library audio (public domain on Roblox), checked against the public asset API.
WackyState.assets = {
	skies = {},
	-- rbxasset:// textures ship with the Roblox client; leaf (899737088) and heart (249529864) are checked image assets
	particles = {
		snowflake = "rbxassetid://1190797289", flake = "rbxassetid://1190797289", soft = "rbxassetid://242109931",
		petal = "rbxassetid://242109931", leaf = "rbxassetid://899737088", heart = "rbxassetid://249529864",
		rain = "rbxasset://textures/particles/SquareParticle.png", dust = "rbxasset://textures/particles/smoke_main.dds",
		ember = "rbxasset://textures/particles/fire_sparks_main.dds", firefly = "rbxasset://textures/particles/forcefield_glow_main.dds",
		star = "rbxasset://textures/particles/sparkles_main.dds",
	},
	sounds = {
		rain = 9112853287, stormloop = 9120016022,
		thunder1 = 9120021541, thunder2 = 9120019110, thunder3 = 9120020225,
		snowwind = 9114228774, blizzard = 9114228928, sandstorm = 9114057128,
		night = 9112764573, fire = 9112780561, space = 9125515916, meteor = 9120769331,
		birds = 9125485532, fwlaunch = 9125805579, fwboom = 9120018172, fwcrackle = 9114447277,
	},
}
WackyState.weatherVolume = 1
WackyState.weatherSounds = {}

WackyState.sound = function(id, parent, volume, looped, pitch)
	local sound = Instance.new("Sound")
	sound.Name = randomString()
	sound.SoundId = "rbxassetid://" .. tostring(id)
	sound.Volume = volume or 0.5
	sound.Looped = looped or false
	sound.PlaybackSpeed = pitch or 1
	sound.Parent = parent or Services.SoundService
	sound:Play()
	if not looped then
		sound.Ended:Connect(function()
			sound:Destroy()
		end)
		Services.Debris:AddItem(sound, 30)
	end
	return sound
end

-- Swap Lighting/Terrain environment objects locally, keeping the game's originals to put back
WackyState.env = {parked = {}, ours = {}}

WackyState.envContainer = function(class)
	if class == "Clouds" then
		return workspace:FindFirstChildOfClass("Terrain")
	end
	return Lighting
end

WackyState.envSet = function(class, instance)
	local container = WackyState.envContainer(class)
	if not container then
		instance:Destroy()
		return
	end
	if not WackyState.env.parked[class] then
		local parked = {}
		for _, v in ipairs(container:GetChildren()) do
			if v.ClassName == class then
				table.insert(parked, v)
				pcall(function() v.Parent = nil end)
			end
		end
		WackyState.env.parked[class] = parked
	end
	if WackyState.env.ours[class] then
		pcall(function() WackyState.env.ours[class]:Destroy() end)
	end
	WackyState.env.ours[class] = instance
	instance.Parent = container
end

WackyState.envRestore = function(class)
	if WackyState.env.ours[class] then
		pcall(function() WackyState.env.ours[class]:Destroy() end)
		WackyState.env.ours[class] = nil
	end
	local parked = WackyState.env.parked[class]
	if parked then
		local container = WackyState.envContainer(class)
		for _, v in ipairs(parked) do
			pcall(function() v.Parent = container end)
		end
		WackyState.env.parked[class] = nil
	end
end

WackyState.makeSky = function(name)
	local ids = WackyState.assets.skies[name]
	if not ids then return nil end
	local sky = Instance.new("Sky")
	sky.Name = randomString()
	sky.SkyboxBk = ids.bk
	sky.SkyboxDn = ids.dn
	sky.SkyboxFt = ids.ft
	sky.SkyboxLf = ids.lf
	sky.SkyboxRt = ids.rt
	sky.SkyboxUp = ids.up
	sky.StarCount = 3000
	sky.CelestialBodiesShown = ids.celestial ~= false
	return sky
end

WackyState.texture = function(kind)
	return WackyState.assets.particles[kind] or "rbxasset://textures/particles/sparkles_main.dds"
end

WackyState.c3 = function(t)
	return Color3.fromRGB(t[1], t[2], t[3])
end

-- Weather presets
-- emitter.area: "above" (falls from a sheet overhead), "below" (rises), "around" (fills a box around you)
WackyState.weather = {
	snow = {sky = "winter", clock = 13, tint = {235, 240, 255}, sound = {"snowwind", 0.35}, accumulate = 60,
		atmosphere = {density = 0.35, haze = 1.5, color = {220, 230, 245}, decay = {200, 210, 230}},
		clouds = {cover = 0.8, density = 0.6, color = {245, 245, 255}},
		bloom = {intensity = 0.6, size = 24, threshold = 0.85}, saturation = -0.1,
		emitters = {
			{tex = "flake", area = "around", box = {70, 36, 70}, offset = 12, dir = "Bottom", color = {255, 255, 255}, rate = 45, speed = {1.5, 3}, size = {0.32, 0.6}, life = 12, spread = 35, light = 0.15, spin = true, accel = {1.5, -0.5, 0}, wind = 2},
			{tex = "soft", area = "above", color = {255, 255, 255}, rate = 150, speed = {5, 9}, size = {0.14, 0.28}, life = 9, spread = 25, light = 0.2, accel = {2, 0, 0}, wind = 2},
			{tex = "soft", area = "around", box = {260, 70, 260}, offset = 20, dir = "Bottom", color = {235, 242, 255}, rate = 170, speed = {2, 4}, size = {0.13, 0.22}, life = 10, spread = 40, transparency = 0.35, accel = {1, -0.5, 0}, wind = 2},
		}},
	blizzard = {sky = "winter", clock = 13, tint = {230, 238, 255}, shake = 0.15, sound = {"blizzard", 0.8}, accumulate = 25,
		dark = {brightness = 0.8, exposure = -0.2, ambient = {120, 125, 140}, outdoor = {130, 135, 150}},
		atmosphere = {density = 0.6, haze = 3, color = {230, 235, 250}, decay = {210, 220, 240}},
		clouds = {cover = 1, density = 0.9, color = {230, 230, 240}},
		bloom = {intensity = 0.5, size = 24, threshold = 0.85}, saturation = -0.2,
		emitters = {
			{tex = "flake", area = "around", box = {60, 30, 60}, offset = 8, dir = "Bottom", color = {255, 255, 255}, rate = 150, speed = {12, 20}, size = {0.28, 0.5}, life = 4, spread = 40, light = 0.15, spin = true, accel = {40, -10, 10}, wind = 14},
			{tex = "soft", area = "around", box = {140, 50, 140}, offset = 10, dir = "Bottom", color = {255, 255, 255}, rate = 450, speed = {20, 30}, size = {0.15, 0.27}, life = 4, spread = 30, light = 0.2, accel = {45, -10, 12}, wind = 16},
			{tex = "soft", area = "around", box = {260, 70, 260}, offset = 20, dir = "Bottom", color = {230, 238, 252}, rate = 300, speed = {15, 25}, size = {0.13, 0.22}, life = 5, spread = 40, transparency = 0.4, accel = {40, -8, 10}, wind = 16},
		}},
	rain = {sky = "storm", tint = {205, 210, 220}, brightness = -0.05, sound = {"rain", 0.6},
		dark = {brightness = 0.65, exposure = -0.35, ambient = {80, 82, 92}, outdoor = {90, 92, 102}},
		atmosphere = {density = 0.4, haze = 1, color = {150, 155, 165}, decay = {110, 115, 125}},
		clouds = {cover = 0.9, density = 0.8, color = {120, 125, 135}},
		emitters = {{tex = "rain", area = "above", color = {180, 200, 235}, rate = 700, speed = {70, 90}, size = {0.15, 0.2}, life = 1.6, spread = 3, light = 0.05, streak = true}}},
	storm = {sky = "storm", tint = {185, 190, 210}, brightness = -0.15, saturation = -0.3, lightning = true, shake = 0.05, sound = {"stormloop", 0.75}, clock = 17.5,
		dark = {brightness = 0.35, exposure = -0.9, ambient = {40, 42, 52}, outdoor = {45, 48, 58}},
		atmosphere = {density = 0.5, haze = 1.5, color = {110, 115, 130}, decay = {80, 85, 100}},
		clouds = {cover = 1, density = 1, color = {80, 85, 95}},
		emitters = {{tex = "rain", area = "above", color = {170, 190, 230}, rate = 1000, speed = {90, 110}, size = {0.15, 0.2}, life = 1.4, spread = 6, light = 0.05, streak = true, accel = {15, 0, 0}}}},
	sandstorm = {tint = {255, 225, 180}, shake = 0.1, sound = {"sandstorm", 0.7},
		atmosphere = {density = 0.65, haze = 3, color = {230, 190, 130}, decay = {200, 140, 80}},
		emitters = {{tex = "dust", area = "around", color = {225, 180, 110}, rate = 350, speed = {35, 50}, size = {1.5, 3.5}, life = 3, spread = 15, transparency = 0.55, accel = {60, 0, 0}, spin = true}}},
	aurora = {sky = "aurora", clock = 0, tint = {205, 255, 235}, aurora = true, sound = {"space", 0.4},
		emitters = {{tex = "star", area = "around", color = {150, 255, 200}, rate = 25, speed = {0.3, 1}, size = {0.15, 0.3}, life = 12, spread = 180, light = 1}}},
	stars = {sky = "starry", clock = 0, sound = {"night", 0.4},
		emitters = {{tex = "star", area = "around", color = {255, 255, 255}, rate = 150, speed = {0.5, 2}, size = {0.15, 0.3}, life = 10, spread = 180, light = 1}}},
	galaxy = {sky = "space", clock = 0, tint = {225, 205, 255}, sound = {"space", 0.45},
		emitters = {{tex = "star", area = "around", color = {190, 140, 255}, rate = 180, speed = {1, 4}, size = {0.2, 0.4}, life = 10, spread = 180, light = 1}}},
	bloodmoon = {sky = "bloodmoon", clock = 0, tint = {255, 165, 165}, brightness = -0.05, sound = {"fire", 0.3},
		atmosphere = {density = 0.4, haze = 2, color = {130, 25, 25}, decay = {70, 0, 0}},
		emitters = {{tex = "ember", area = "below", color = {255, 60, 30}, rate = 60, speed = {3, 8}, size = {0.2, 0.4}, life = 8, spread = 40, light = 1}}},
	sakura = {sky = "pink", clock = 14, tint = {255, 238, 246}, sound = {"birds", 0.4},
		emitters = {{tex = "petal", area = "above", color = {255, 185, 215}, rate = 120, speed = {3, 6}, size = {0.3, 0.45}, life = 10, spread = 40, spin = true, squash = 0.7, accel = {3, 0, 1}}}},
	autumn = {sky = "sunset", clock = 16.8, tint = {255, 225, 195}, sound = {"birds", 0.35},
		emitters = {{tex = "leaf", area = "above", gradient = {{255, 255, 255}, {255, 190, 160}, {255, 235, 170}}, rate = 80, speed = {3, 6}, size = {0.4, 0.7}, life = 10, spread = 45, spin = true, accel = {4, 0, 2}}}},
	hearts = {sky = "pink", clock = 15, tint = {255, 220, 235}, sound = {"birds", 0.3},
		emitters = {{tex = "heart", area = "below", color = {255, 205, 225}, rate = 50, speed = {3, 6}, size = {0.4, 0.7}, life = 8, spread = 30, light = 0.5}}},
	embers = {sky = "bloodmoon", clock = 20, sound = {"fire", 0.45},
		emitters = {{tex = "ember", area = "below", color = {255, 120, 30}, rate = 120, speed = {4, 10}, size = {0.2, 0.35}, life = 8, spread = 60, light = 1}}},
	fireflies = {sky = "starry", clock = 21, sound = {"night", 0.5},
		emitters = {{tex = "firefly", area = "around", color = {220, 255, 90}, rate = 40, speed = {1, 3}, size = {0.25, 0.4}, life = 10, spread = 180, light = 1}}},
	rainbow = {sky = "day", clock = 12, sound = {"birds", 0.4},
		emitters = {{tex = "star", area = "above", rainbow = true, rate = 200, speed = {6, 12}, size = {0.3, 0.5}, life = 8, spread = 30, light = 1}}},
	meteors = {sky = "space", clock = 0, meteors = true, tint = {230, 215, 255}, sound = {"space", 0.45}},
}

WackyState.makeEmitter = function(spec)
	local emitter = Instance.new("ParticleEmitter")
	emitter.Texture = WackyState.texture(spec.tex)
	emitter.Rate = spec.rate
	emitter.Speed = NumberRange.new(spec.speed[1], spec.speed[2])
	emitter.Lifetime = NumberRange.new(spec.life * 0.8, spec.life)
	emitter.Size = NumberSequence.new(spec.size[1], spec.size[2])
	emitter.LightEmission = spec.light or 0
	emitter.SpreadAngle = Vector2.new(spec.spread, spec.spread)
	emitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.1, spec.transparency or 0),
		NumberSequenceKeypoint.new(0.85, spec.transparency or 0),
		NumberSequenceKeypoint.new(1, 1),
	})
	if spec.rainbow then
		emitter.Color = WackyState.rainbowSequence()
	elseif spec.gradient then
		local keys = {}
		for i, c in ipairs(spec.gradient) do
			table.insert(keys, ColorSequenceKeypoint.new((i - 1) / (#spec.gradient - 1), WackyState.c3(c)))
		end
		emitter.Color = ColorSequence.new(keys)
	else
		emitter.Color = ColorSequence.new(WackyState.c3(spec.color))
	end
	if spec.accel then
		emitter.Acceleration = Vector3.new(spec.accel[1], spec.accel[2], spec.accel[3])
	end
	if spec.spin then
		emitter.Rotation = NumberRange.new(0, 360)
		emitter.RotSpeed = NumberRange.new(-120, 120)
	end
	if spec.squash then
		pcall(function() emitter.Squash = NumberSequence.new(spec.squash) end)
	end
	if spec.streak then
		emitter.Orientation = Enum.ParticleOrientation.VelocityParallel
		emitter.Size = NumberSequence.new(spec.size[2])
		pcall(function() emitter.Squash = NumberSequence.new(-2) end)
	end
	if spec.dir then
		emitter.EmissionDirection = Enum.NormalId[spec.dir]
		if spec.area == "around" then
			pcall(function()
				emitter.Shape = Enum.ParticleEmitterShape.Box
				emitter.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
			end)
		end
	elseif spec.area == "below" then
		emitter.EmissionDirection = Enum.NormalId.Top
	elseif spec.area == "around" then
		emitter.EmissionDirection = Enum.NormalId.Front
		pcall(function()
			emitter.Shape = Enum.ParticleEmitterShape.Box
			emitter.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
		end)
	else
		emitter.EmissionDirection = Enum.NormalId.Bottom
	end
	return emitter
end

WackyState.weatherPart = function(area, box)
	local part = WackyState.track("weather", Instance.new("Part"))
	part.Name = randomString()
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Transparency = 1
	part.Size = box and Vector3.new(box[1], box[2], box[3]) or (area == "around" and Vector3.new(120, 50, 120) or Vector3.new(140, 1, 140))
	part.Parent = workspace
	return part
end

WackyState.lightningStrike = function(speaker)
	local root = getRoot(speaker.Character)
	if not root then return end
	local angle = math.random() * math.pi * 2
	local dist = math.random(40, 120)
	local ground = root.Position + Vector3.new(math.cos(angle) * dist, 0, math.sin(angle) * dist)
	local params = RaycastParams.new()
	params.FilterDescendantsInstances = {speaker.Character}
	params.FilterType = Enum.RaycastFilterType.Exclude
	local hit = workspace:Raycast(ground + Vector3.new(0, 200, 0), Vector3.new(0, -400, 0), params)
	local bottom = hit and hit.Position or (ground - Vector3.new(0, 3, 0))
	local top = bottom + Vector3.new(math.random(-20, 20), 250, math.random(-20, 20))
	local last = top
	for i = 1, 10 do
		local point = top:Lerp(bottom, i / 10)
		if i < 10 then
			point = point + Vector3.new(math.random(-8, 8), 0, math.random(-8, 8))
		end
		local bolt = Instance.new("Part")
		bolt.Name = randomString()
		bolt.Anchored = true
		bolt.CanCollide = false
		bolt.CanQuery = false
		bolt.CanTouch = false
		bolt.Material = Enum.Material.Neon
		bolt.Color = Color3.fromRGB(210, 225, 255)
		bolt.Size = Vector3.new(0.6, 0.6, (point - last).Magnitude)
		bolt.CFrame = CFrame.lookAt((last + point) / 2, point)
		bolt.Parent = workspace
		Services.Debris:AddItem(bolt, 0.18)
		last = point
	end
	local flash = Instance.new("ColorCorrectionEffect")
	flash.Name = randomString()
	flash.Brightness = 0.5
	flash.Parent = Lighting
	TweenService:Create(flash, TweenInfo.new(0.5), {Brightness = 0}):Play()
	Services.Debris:AddItem(flash, 0.6)
	task.delay(math.clamp(dist / 120, 0.2, 1.2), function()
		local id = WackyState.assets.sounds[WackyState.pick({"thunder1", "thunder2", "thunder3"})]
		WackyState.sound(id, nil, math.clamp(1.2 - dist / 200, 0.4, 1) * WackyState.weatherVolume, false, 0.9 + math.random() * 0.2)
	end)
end

WackyState.makeAurora = function()
	local anchor = WackyState.track("weather", Instance.new("Part"))
	anchor.Name = randomString()
	anchor.Anchored = true
	anchor.CanCollide = false
	anchor.CanQuery = false
	anchor.CanTouch = false
	anchor.Transparency = 1
	anchor.Size = Vector3.new(1, 1, 1)
	anchor.Parent = workspace
	local beams = {}
	local palettes = {
		{{80, 255, 170}, {60, 200, 255}}, {{120, 255, 140}, {200, 90, 255}},
		{{60, 255, 200}, {255, 90, 200}}, {{150, 255, 120}, {80, 160, 255}},
	}
	for i, palette in ipairs(palettes) do
		local a0 = Instance.new("Attachment")
		a0.Position = Vector3.new(-450, 220 + i * 18, -120 + i * 60)
		a0.Parent = anchor
		local a1 = Instance.new("Attachment")
		a1.Position = Vector3.new(450, 220 + i * 18, -120 + i * 60)
		a1.Parent = anchor
		local beam = Instance.new("Beam")
		beam.Attachment0 = a0
		beam.Attachment1 = a1
		beam.Width0 = 70
		beam.Width1 = 70
		beam.Segments = 40
		beam.LightEmission = 1
		beam.LightInfluence = 0
		beam.FaceCamera = false
		beam.Color = ColorSequence.new(WackyState.c3(palette[1]), WackyState.c3(palette[2]))
		beam.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.2, 0.55),
			NumberSequenceKeypoint.new(0.8, 0.55), NumberSequenceKeypoint.new(1, 1),
		})
		beam.Parent = anchor
		table.insert(beams, beam)
	end
	return anchor, beams
end

WackyState.launchMeteor = function(speaker)
	local root = getRoot(speaker.Character)
	if not root then return end
	local start = root.Position + Vector3.new(math.random(-250, 250), math.random(180, 260), math.random(-250, 250))
	local finish = start + Vector3.new(math.random(-200, 200), -math.random(150, 220), math.random(-200, 200))
	local meteor = Instance.new("Part")
	meteor.Name = randomString()
	meteor.Shape = Enum.PartType.Ball
	meteor.Size = Vector3.new(3, 3, 3)
	meteor.Anchored = true
	meteor.CanCollide = false
	meteor.CanQuery = false
	meteor.CanTouch = false
	meteor.Material = Enum.Material.Neon
	meteor.Color = Color3.fromRGB(255, 200, 140)
	meteor.Position = start
	local a0 = Instance.new("Attachment")
	a0.Position = Vector3.new(0, 1.2, 0)
	a0.Parent = meteor
	local a1 = Instance.new("Attachment")
	a1.Position = Vector3.new(0, -1.2, 0)
	a1.Parent = meteor
	local trail = Instance.new("Trail")
	trail.Attachment0 = a0
	trail.Attachment1 = a1
	trail.Lifetime = 0.8
	trail.LightEmission = 1
	trail.FaceCamera = true
	trail.Color = ColorSequence.new(Color3.fromRGB(255, 230, 180), Color3.fromRGB(200, 120, 255))
	trail.Transparency = NumberSequence.new(0, 1)
	trail.WidthScale = NumberSequence.new(1, 0)
	trail.Parent = meteor
	meteor.Parent = workspace
	TweenService:Create(meteor, TweenInfo.new(1.6 + math.random(), Enum.EasingStyle.Linear), {Position = finish}):Play()
	Services.Debris:AddItem(meteor, 3)
	if math.random() < 0.3 then
		task.delay(0.8, function()
			WackyState.sound(WackyState.assets.sounds.meteor, nil, 0.25 * WackyState.weatherVolume, false, 0.8 + math.random() * 0.4)
		end)
	end
end

-- Detailed snow: the whole map (floors, roofs, platforms and terrain) turns snowy,
-- plus footprints with crunches, snow on your head and shoulders, frosty
-- breath, frost creeping in at the screen edges and sparkles on the snow.
-- Everything melts away (and every part gets its original look back) when the weather stops.
WackyState.snowTextures = {flake = "rbxassetid://1190797289", soft = "rbxassetid://242109931"}
WackyState.snowWhite = Color3.fromRGB(244, 247, 255)
WackyState.snowTerrainMaterials = {"Grass", "LeafyGrass", "Ground", "Mud", "Sand", "Rock", "Slate", "Basalt", "Limestone", "Sandstone",
	"Pavement", "Asphalt", "Cobblestone", "Concrete", "Brick", "Salt", "Snow", "Glacier"}

WackyState.snowApplyMap = function(entry, level)
	local part = entry.part
	if not part.Parent then return end
	entry.applied = level
	part.Color = entry.color:Lerp(WackyState.snowWhite, math.clamp(level * 1.3, 0, 0.92))
	if entry.union ~= nil and level > 0 then
		part.UsePartColor = true
	end
	if level >= 0.35 then
		if part.Material ~= Enum.Material.Snow then
			part.Material = Enum.Material.Snow
		end
	elseif part.Material ~= entry.material then
		part.Material = entry.material
	end
end

WackyState.snowRestoreAll = function(cover)
	for _, entry in ipairs(cover.mapParts) do
		pcall(function()
			local part = entry.part
			part.Color = entry.color
			part.Material = entry.material
			if entry.union ~= nil then
				part.UsePartColor = entry.union
			end
		end)
	end
	cover.mapParts = {}
	if cover.terrain then
		for mat, color in pairs(cover.terrainColors) do
			pcall(function() cover.terrain:SetMaterialColor(mat, color) end)
		end
		if cover.decoration ~= nil then
			pcall(function() cover.terrain.Decoration = cover.decoration end)
		end
	end
end

WackyState.stopSnowCover = function(instant)
	-- an earlier snow still melting? finish it right now, so new snow never saves half-melted colors
	if WackyState.snowMelting then
		pcall(WackyState.snowMelting.finish)
	end
	WackyState.disconnect("snowcover")
	WackyState.disconnect("snowmapadded")
	local cover = WackyState.snowCover
	WackyState.snowCover = nil
	if not cover then return end
	local done = false
	local function finish()
		if done then return end
		done = true
		if WackyState.snowMelting and WackyState.snowMelting.cover == cover then
			WackyState.snowMelting = nil
		end
		WackyState.snowRestoreAll(cover)
		for _, obj in ipairs(cover.cleanup) do
			pcall(function() obj:Destroy() end)
		end
	end
	if instant then
		finish()
		return
	end
	WackyState.snowMelting = {cover = cover, finish = finish}
	local fade = TweenInfo.new(4, Enum.EasingStyle.Sine)
	for _, footprint in ipairs(cover.prints) do
		pcall(function() TweenService:Create(footprint, fade, {Transparency = 1}):Play() end)
	end
	for _, obj in ipairs(cover.fadeables) do
		pcall(function()
			if obj:IsA("ImageLabel") then
				TweenService:Create(obj, fade, {ImageTransparency = 1}):Play()
			elseif obj:IsA("GuiObject") then
				TweenService:Create(obj, fade, {BackgroundTransparency = 1}):Play()
			else
				TweenService:Create(obj, fade, {Transparency = 1}):Play()
			end
		end)
	end
	-- melt the map back over ~4 seconds, then restore everything exactly
	task.spawn(function()
		local startLevel, started = cover.level, tick()
		local index = 1
		while not done and tick() - started < 4 do
			local level = startLevel * (1 - (tick() - started) / 4)
			local n = #cover.mapParts
			local budgetEnd = os.clock() + 0.002
			for _ = 1, math.min(1500, n) do
				if index > n then index = 1 end
				pcall(WackyState.snowApplyMap, cover.mapParts[index], level)
				index = index + 1
				if os.clock() > budgetEnd then
					break
				end
			end
			if cover.terrain then
				for mat, color in pairs(cover.terrainColors) do
					pcall(function() cover.terrain:SetMaterialColor(mat, color:Lerp(WackyState.snowWhite, math.clamp(level * 1.3, 0, 0.9))) end)
				end
			end
			RunService.Heartbeat:Wait()
		end
		finish()
	end)
end

WackyState.startSnowCover = function(speaker, fullTime)
	WackyState.stopSnowCover(true)
	local folder = Instance.new("Folder")
	folder.Name = randomString()
	folder.Parent = workspace
	local cover = {
		folder = folder, cells = {}, count = 0, start = tick(), fullTime = fullTime, level = 0,
		lastScan = 0, lastGrow = 0, prints = {}, lastPrint = nil, printSide = 1, seed = math.random() * 100,
		cleanup = {folder}, fadeables = {}, char = nil, caps = {}, nextBreath = 0,
		mapParts = {}, mapSet = setmetatable({}, {__mode = "k"}), mapIndex = 1, terrainColors = {},
	}
	WackyState.snowCover = cover
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude

	-- Whole map: find floor-like parts everywhere (in the background, a chunk per frame)
	local skipMaterials = {[Enum.Material.Water] = true, [Enum.Material.Neon] = true, [Enum.Material.Glass] = true, [Enum.Material.ForceField] = true}
	local function isGround(part)
		if part:IsA("Terrain") or part.Transparency >= 0.8 or skipMaterials[part.Material] then return false end
		if part:IsDescendantOf(folder) or part:IsDescendantOf(workspace.CurrentCamera) then return false end
		if part:IsA("MeshPart") and part.TextureID ~= "" then return false end
		local parent = part.Parent
		for _ = 1, 3 do
			if not parent or parent == workspace then break end
			if parent:FindFirstChildOfClass("Humanoid") then return false end
			parent = parent.Parent
		end
		local cf, size = part.CFrame, part.Size
		local ax, ay, az = math.abs(cf.RightVector.Y), math.abs(cf.UpVector.Y), math.abs(cf.LookVector.Y)
		if math.max(ax, ay, az) < 0.8 then return false end
		local thick, w, d
		if ay >= ax and ay >= az then
			thick, w, d = size.Y, size.X, size.Z
		elseif ax >= az then
			thick, w, d = size.X, size.Y, size.Z
		else
			thick, w, d = size.Z, size.X, size.Y
		end
		return math.min(w, d) >= 2.5 and w * d >= 12 and thick <= math.max(6, math.min(w, d) * 0.6)
	end
	local function addMapPart(part)
		if cover.mapSet[part] or #cover.mapParts >= 25000 or not isGround(part) then return end
		cover.mapSet[part] = true
		local union
		if part:IsA("UnionOperation") then
			union = part.UsePartColor
		end
		table.insert(cover.mapParts, {part = part, color = part.Color, material = part.Material, union = union, applied = -1})
	end
	task.spawn(function()
		local all = workspace:GetDescendants()
		for i, inst in ipairs(all) do
			if WackyState.snowCover ~= cover then return end
			if inst:IsA("BasePart") then
				pcall(addMapPart, inst)
			end
			if i % 2000 == 0 then
				task.wait()
			end
		end
	end)
	WackyState.connect("snowmapadded", workspace.DescendantAdded:Connect(function(inst)
		if inst:IsA("BasePart") then
			task.defer(function()
				if WackyState.snowCover == cover then
					pcall(addMapPart, inst)
				end
			end)
		end
	end))

	-- Terrain turns snowy too
	local terrain = workspace:FindFirstChildOfClass("Terrain")
	if terrain then
		cover.terrain = terrain
		for _, name in ipairs(WackyState.snowTerrainMaterials) do
			pcall(function()
				local mat = Enum.Material[name]
				cover.terrainColors[mat] = terrain:GetMaterialColor(mat)
			end)
		end
		pcall(function() cover.decoration = terrain.Decoration end)
	end

	-- Sparkles glinting on the snow surface
	local glintPart = Instance.new("Part")
	glintPart.Name = randomString()
	glintPart.Anchored = true
	glintPart.CanCollide = false
	glintPart.CanQuery = false
	glintPart.CanTouch = false
	glintPart.Transparency = 1
	glintPart.Size = Vector3.new(80, 1, 80)
	glintPart.Parent = folder
	local glints = Instance.new("ParticleEmitter")
	glints.Texture = WackyState.snowTextures.soft
	glints.Rate = 0
	glints.Speed = NumberRange.new(0)
	glints.Lifetime = NumberRange.new(0.25, 0.6)
	glints.LightEmission = 1
	glints.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.5, 0.18), NumberSequenceKeypoint.new(1, 0)})
	glints.Color = ColorSequence.new(Color3.fromRGB(235, 245, 255))
	glints.EmissionDirection = Enum.NormalId.Top
	pcall(function()
		glints.Shape = Enum.ParticleEmitterShape.Box
		glints.ShapeStyle = Enum.ParticleEmitterShapeStyle.Surface
	end)
	glints.Parent = glintPart

	-- Frost creeping in from the screen edges
	local screen = WackyState.overlay()
	local frost = Instance.new("Frame")
	frost.Name = randomString()
	frost.BackgroundTransparency = 1
	frost.Size = UDim2.new(1, 0, 1, 0)
	frost.Parent = screen
	table.insert(cover.cleanup, frost)
	local edges = {}
	for _, e in ipairs({{UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0.16, 0), 90}, {UDim2.new(0, 0, 0.84, 0), UDim2.new(1, 0, 0.16, 0), 270},
		{UDim2.new(0, 0, 0, 0), UDim2.new(0.12, 0, 1, 0), 0}, {UDim2.new(0.88, 0, 0, 0), UDim2.new(0.12, 0, 1, 0), 180}}) do
		local edge = Instance.new("Frame")
		edge.BorderSizePixel = 0
		edge.BackgroundColor3 = Color3.fromRGB(225, 240, 255)
		edge.BackgroundTransparency = 1
		edge.Position = e[1]
		edge.Size = e[2]
		local gradient = Instance.new("UIGradient")
		gradient.Rotation = e[3]
		gradient.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)})
		gradient.Parent = edge
		edge.Parent = frost
		table.insert(edges, edge)
		table.insert(cover.fadeables, edge)
	end
	local crystals = {}
	for i = 1, 18 do
		local crystal = Instance.new("ImageLabel")
		crystal.BackgroundTransparency = 1
		crystal.Image = WackyState.snowTextures.flake
		crystal.ImageTransparency = 1
		crystal.ImageColor3 = Color3.fromRGB(230, 242, 255)
		local size = math.random(40, 110)
		crystal.Size = UDim2.new(0, size, 0, size)
		crystal.AnchorPoint = Vector2.new(0.5, 0.5)
		local corner = i % 4
		local cx = (corner == 0 or corner == 2) and math.random() * 0.12 or 1 - math.random() * 0.12
		local cy = (corner < 2) and math.random() * 0.2 or 1 - math.random() * 0.2
		crystal.Position = UDim2.new(cx, 0, cy, 0)
		crystal.Rotation = math.random(0, 59)
		crystal.Parent = frost
		table.insert(crystals, {label = crystal, delay = math.random()})
		table.insert(cover.fadeables, crystal)
	end

	-- Snow settling on your head and shoulders, plus frosty breath
	local function setupCharacter(char)
		for _, cap in ipairs(cover.caps) do
			pcall(function() cap.part:Destroy() end)
		end
		cover.caps = {}
		cover.breath = nil
		cover.char = char
		if not char then return end
		local head = char:FindFirstChild("Head")
		local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
		local function addCap(parent, offset, width, depth)
			if not parent then return end
			local part = Instance.new("Part")
			part.Name = randomString()
			part.Material = Enum.Material.Snow
			part.Color = Color3.fromRGB(248, 250, 255)
			part.CanCollide = false
			part.CanQuery = false
			part.CanTouch = false
			part.Massless = true
			part.CastShadow = false
			part.Transparency = 1
			part.Size = Vector3.new(width, 0.05, depth)
			local mesh = Instance.new("SpecialMesh")
			mesh.MeshType = Enum.MeshType.Sphere
			mesh.Parent = part
			local weld = Instance.new("Weld")
			weld.Part0 = parent
			weld.Part1 = part
			weld.Parent = part
			part.Parent = folder
			table.insert(cover.caps, {part = part, weld = weld, parent = parent, offset = offset})
			table.insert(cover.fadeables, part)
		end
		if head then
			addCap(head, Vector3.new(0, head.Size.Y / 2, 0), head.Size.X * 0.85, head.Size.Z * 0.85)
			local attachment = Instance.new("Attachment")
			attachment.Name = randomString()
			attachment.Position = Vector3.new(0, -head.Size.Y * 0.15, -head.Size.Z / 2)
			attachment.Parent = head
			table.insert(cover.cleanup, attachment)
			local breath = Instance.new("ParticleEmitter")
			breath.Texture = WackyState.snowTextures.soft
			breath.Rate = 0
			breath.EmissionDirection = Enum.NormalId.Front
			breath.Speed = NumberRange.new(1.5, 3)
			breath.SpreadAngle = Vector2.new(15, 15)
			breath.Lifetime = NumberRange.new(1, 1.6)
			breath.Drag = 2
			breath.Acceleration = Vector3.new(0, 0.6, 0)
			breath.Size = NumberSequence.new(0.25, 1.4)
			breath.Transparency = NumberSequence.new(0.55, 1)
			breath.Color = ColorSequence.new(Color3.fromRGB(240, 246, 255))
			breath.Parent = attachment
			table.insert(cover.cleanup, breath)
			cover.breath = breath
		end
		if torso then
			local w = torso.Size.X
			addCap(torso, Vector3.new(-w * 0.3, torso.Size.Y / 2, 0), w * 0.36, torso.Size.Z * 0.9)
			addCap(torso, Vector3.new(w * 0.3, torso.Size.Y / 2, 0), w * 0.36, torso.Size.Z * 0.9)
		end
	end

	local stepIds = {9125965076, 9125965053}
	WackyState.connect("snowcover", RunService.Heartbeat:Connect(function()
		local now = tick()
		local char = speaker.Character
		local root = getRoot(char)
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if char ~= cover.char then
			setupCharacter(char)
			params.FilterDescendantsInstances = {folder, char}
		end
		-- whole-map snow: update a slice of parts every frame
		local n = #cover.mapParts
		if n > 0 then
			local stage = math.floor(cover.level * 12 + 0.5) / 12
			local budgetEnd = os.clock() + 0.0015
			for _ = 1, math.min(700, n) do
				if cover.mapIndex > n then cover.mapIndex = 1 end
				local entry = cover.mapParts[cover.mapIndex]
				cover.mapIndex = cover.mapIndex + 1
				if entry.applied ~= stage then
					pcall(WackyState.snowApplyMap, entry, stage)
					if os.clock() > budgetEnd then
						break
					end
				end
			end
		end
		if now - cover.lastGrow > 0.4 then
			cover.lastGrow = now
			local level = math.clamp((now - cover.start) / cover.fullTime, 0, 1)
			if level ~= cover.level then
				cover.level = level
				for _, edge in ipairs(edges) do
					edge.BackgroundTransparency = 1 - level * 0.55
				end
				for _, crystal in ipairs(crystals) do
					crystal.label.ImageTransparency = 1 - math.clamp((level - crystal.delay * 0.5) * 1.6, 0, 0.75)
				end
				for _, cap in ipairs(cover.caps) do
					local thick = 0.06 + level * 0.35
					cap.part.Size = Vector3.new(cap.part.Size.X, thick, cap.part.Size.Z)
					cap.part.Transparency = math.max(0, 1 - level * 2.5)
					cap.weld.C0 = CFrame.new(cap.offset + Vector3.new(0, thick * 0.3, 0))
				end
				local terrainStage = math.floor(level * 12 + 0.5) / 12
				if cover.terrain and cover.terrainStage ~= terrainStage then
					cover.terrainStage = terrainStage
					for mat, color in pairs(cover.terrainColors) do
						pcall(function() cover.terrain:SetMaterialColor(mat, color:Lerp(WackyState.snowWhite, math.clamp(terrainStage * 1.3, 0, 0.9))) end)
					end
					if level > 0.3 and cover.decoration then
						pcall(function() cover.terrain.Decoration = false end)
					end
				end
			end
			local clock = Lighting.ClockTime
			glints.Rate = (clock > 7 and clock < 17.5) and (40 * level) or (8 * level)
		end
		if root then
			glintPart.CFrame = CFrame.new(root.Position - Vector3.new(0, (hum and hum.HipHeight or 2) + root.Size.Y / 2 - 0.4, 0))
		end
		if cover.breath and now > cover.nextBreath then
			cover.nextBreath = now + 2.5 + math.random() * 1.5
			cover.breath:Emit(5)
		end
		-- Footprints with a crunch, once the snow has started to settle
		if root and hum and cover.level > 0.15 and hum.FloorMaterial ~= Enum.Material.Air then
			local pos = root.Position
			if not cover.lastPrint or (pos - cover.lastPrint).Magnitude > 2.4 then
				local dir = hum.MoveDirection.Magnitude > 0.1 and hum.MoveDirection or root.CFrame.LookVector
				dir = Vector3.new(dir.X, 0, dir.Z).Unit
				local side = Vector3.new(-dir.Z, 0, dir.X) * 0.55 * cover.printSide
				cover.printSide = -cover.printSide
				cover.lastPrint = pos
				local hit = workspace:Raycast(pos + side, Vector3.new(0, -12, 0), params)
				if hit then
					local footprint = Instance.new("Part")
					footprint.Name = randomString()
					footprint.Anchored = true
					footprint.CanCollide = false
					footprint.CanQuery = false
					footprint.CanTouch = false
					footprint.CastShadow = false
					footprint.Material = Enum.Material.Snow
					footprint.Color = Color3.fromRGB(198, 210, 228)
					footprint.Size = Vector3.new(0.75, 0.04, 1.25)
					local at = hit.Position + hit.Normal * 0.03
					footprint.CFrame = CFrame.lookAt(at, at + dir)
					footprint.Parent = folder
					table.insert(cover.prints, footprint)
					if #cover.prints > 160 then
						pcall(function() table.remove(cover.prints, 1):Destroy() end)
					end
					WackyState.sound(stepIds[math.random(1, #stepIds)], nil, 0.18 * WackyState.weatherVolume, false, 0.9 + math.random() * 0.3)
				end
			end
		end
	end))
end

addcmd('weather',{},function(args, speaker)
	local names = {}
	for k in pairs(WackyState.weather) do
		table.insert(names, k)
	end
	table.sort(names)
	local choice = args[1] and args[1]:lower() or "snow"
	if choice == "random" then
		choice = WackyState.pick(names)
	end
	local preset = WackyState.weather[choice]
	if not preset then
		notify('Weather', 'Unknown weather. Try: ' .. table.concat(names, ', ') .. ', random', 10)
		return
	end
	WackyState.stopWeather(true)
	if preset.clock then
		WackyState.lightClaim("weather", {"ClockTime"})
		Lighting.ClockTime = preset.clock
	end
	if preset.sky then
		local sky = WackyState.makeSky(preset.sky)
		if sky then
			WackyState.envSet("Sky", sky)
		end
	end
	if preset.atmosphere then
		local a = preset.atmosphere
		local atmosphere = Instance.new("Atmosphere")
		atmosphere.Name = randomString()
		atmosphere.Density = a.density
		atmosphere.Haze = a.haze
		atmosphere.Color = WackyState.c3(a.color)
		atmosphere.Decay = WackyState.c3(a.decay)
		atmosphere.Glare = 0
		atmosphere.Offset = 0.1
		WackyState.envSet("Atmosphere", atmosphere)
	end
	if preset.clouds then
		pcall(function()
			local c = preset.clouds
			local clouds = Instance.new("Clouds")
			clouds.Name = randomString()
			clouds.Cover = c.cover
			clouds.Density = c.density
			clouds.Color = WackyState.c3(c.color)
			WackyState.envSet("Clouds", clouds)
		end)
	end
	if preset.tint or preset.brightness then
		local cc = WackyState.track("weather", Instance.new("ColorCorrectionEffect"))
		cc.Name = randomString()
		cc.TintColor = preset.tint and WackyState.c3(preset.tint) or Color3.new(1, 1, 1)
		cc.Brightness = preset.brightness or 0
		cc.Saturation = preset.saturation or 0
		cc.Parent = Lighting
	end
	if preset.bloom then
		local bloom = WackyState.track("weather", Instance.new("BloomEffect"))
		bloom.Name = randomString()
		bloom.Intensity = preset.bloom.intensity
		bloom.Size = preset.bloom.size
		bloom.Threshold = preset.bloom.threshold
		bloom.Parent = Lighting
	end
	if preset.dark then
		local d = preset.dark
		WackyState.lightClaim("weather", {"Brightness", "Ambient", "OutdoorAmbient", "ExposureCompensation"})
		local orig = WackyState.light.orig
		WackyState.weatherDarkTween = TweenService:Create(Lighting, TweenInfo.new(6, Enum.EasingStyle.Sine), {
			Brightness = orig.Brightness * d.brightness,
			Ambient = WackyState.c3(d.ambient),
			OutdoorAmbient = WackyState.c3(d.outdoor),
			ExposureCompensation = orig.ExposureCompensation + d.exposure,
		})
		WackyState.weatherDarkTween:Play()
	end
	if preset.sound then
		local loop = WackyState.sound(WackyState.assets.sounds[preset.sound[1]], nil, 0, true)
		loop:SetAttribute("BaseVolume", preset.sound[2])
		TweenService:Create(loop, TweenInfo.new(2), {Volume = preset.sound[2] * WackyState.weatherVolume}):Play()
		table.insert(WackyState.weatherSounds, loop)
	end
	if preset.accumulate then
		WackyState.startSnowCover(speaker, preset.accumulate)
	end
	local holders = {}
	for _, spec in ipairs(preset.emitters or {}) do
		local part = WackyState.weatherPart(spec.area, spec.box)
		local emitter = WackyState.makeEmitter(spec)
		emitter.Parent = part
		table.insert(holders, {part = part, area = spec.area, offset = spec.offset, emitter = emitter, spec = spec})
	end
	local aurora, beams
	if preset.aurora then
		aurora, beams = WackyState.makeAurora()
	end
	local nextStrike = tick() + 2
	local nextMeteor = 0
	WackyState.connect("weather", RunService.Heartbeat:Connect(function()
		local root = getRoot(speaker.Character)
		if not root then return end
		local pos = root.Position
		local t = tick()
		for i, holder in ipairs(holders) do
			local offset = holder.offset and Vector3.new(0, holder.offset, 0) or (holder.area == "below" and Vector3.new(0, -4, 0) or holder.area == "around" and Vector3.new(0, 10, 0) or Vector3.new(0, 45, 0))
			holder.part.CFrame = CFrame.new(pos + offset)
			local spec = holder.spec
			if spec.wind then
				local base = spec.accel or {0, 0, 0}
				local gust = spec.wind
				holder.emitter.Acceleration = Vector3.new(
					base[1] + math.sin(t * 0.45 + i) * gust + math.noise(t * 0.3, i) * gust,
					base[2],
					base[3] + math.cos(t * 0.33 + i) * gust * 0.6
				)
			end
		end
		if aurora then
			aurora.CFrame = CFrame.new(pos.X, pos.Y, pos.Z)
			for i, beam in ipairs(beams) do
				beam.CurveSize0 = math.sin(t * 0.5 + i) * 120
				beam.CurveSize1 = math.cos(t * 0.4 + i * 1.7) * 120
			end
		end
		if preset.lightning and t > nextStrike then
			nextStrike = t + 2 + math.random() * 5
			task.spawn(WackyState.lightningStrike, speaker)
		end
		if preset.meteors and t > nextMeteor then
			nextMeteor = t + 0.25 + math.random() * 0.5
			task.spawn(WackyState.launchMeteor, speaker)
		end
	end))
	if preset.shake then
		WackyState.bindCam("weathershake", function()
			local cam = workspace.CurrentCamera
			local s = preset.shake
			cam.CFrame = cam.CFrame * CFrame.new((math.random() - 0.5) * s, (math.random() - 0.5) * s, 0)
		end)
	end
	notify('Weather', 'Forecast: ' .. choice .. '! Use unweather to clear the skies.')
end)

WackyState.stopWeather = function(switching)
	for _, sound in ipairs(WackyState.weatherSounds) do
		if switching then
			sound:Destroy()
		else
			TweenService:Create(sound, TweenInfo.new(1.5), {Volume = 0}):Play()
			Services.Debris:AddItem(sound, 1.6)
		end
	end
	WackyState.weatherSounds = {}
	-- stop a darkening that is still fading in, then give the lighting back (instantly when switching)
	if WackyState.weatherDarkTween then
		pcall(function() WackyState.weatherDarkTween:Cancel() end)
		WackyState.weatherDarkTween = nil
	end
	WackyState.lightRelease("weather", (not switching) and 3 or nil)
	WackyState.stopSnowCover(switching)
	WackyState.disconnect("weather")
	WackyState.clear("weather")
	WackyState.unbindCam("weathershake")
	WackyState.envRestore("Sky")
	WackyState.envRestore("Atmosphere")
	WackyState.envRestore("Clouds")
end

addcmd('unweather',{'noweather','clearskies'},function(args, speaker)
	WackyState.stopWeather()
end)

addcmd('weathervolume',{'weathervol'},function(args, speaker)
	WackyState.weatherVolume = math.clamp(WackyState.num(args[1], 1), 0, 3)
	for _, sound in ipairs(WackyState.weatherSounds) do
		sound.Volume = (sound:GetAttribute("BaseVolume") or 0.5) * WackyState.weatherVolume
	end
	notify('Weather', 'Weather sound volume set to ' .. WackyState.weatherVolume)
end)
-- ================== END WEATHER 2.0 ==================

-- ==================== NEVERYIELD UNLOAD ====================
WackyState.classicOffCommands = {
	"unfly", "unvfly", "uncframefly", "unfloat", "unswim", "unnoclip", "unspin", "unfreecam", "noesp", "nochams",
	"unview", "unloopspeed", "unloopjumppower", "unautojump", "unedgejump", "unhatspin", "unfling", "unwalltp",
	"unautoclick", "unstareat", "unautokeypress", "unloopoof", "unloopgoto", "unloopbring", "nospam", "unspasm",
	"untpwalk", "unantivoid", "unantifling", "unloopfullbright", "uninvisibleparts",
}

addcmd('fuckoff',{'unloadny','unloadscript'},function(args, speaker)
	if WackyState.unloading then return end
	WackyState.unloading = true

	-- 1. everything NeverYield added
	for _, name in ipairs(WackyState.undoList) do
		local cmd = findCmd(name)
		if cmd then
			pcall(cmd.FUNC, {}, speaker)
		end
	end
	pcall(WackyState.limbOff)
	pcall(WackyState.stopWeather, true)
	pcall(WackyState.stopSnowCover, true)
	pcall(NeverYieldTheme.closeStudio)
	pcall(WackyState.lightReleaseAll)
	pcall(function() NeverYieldStats.stop() end)
	for key in pairs(WackyState.conns) do
		pcall(WackyState.disconnect, key)
	end
	for key in pairs(WackyState.binds) do
		pcall(WackyState.unbindCam, key)
	end
	for key in pairs(WackyState.objects) do
		pcall(WackyState.clear, key)
	end
	pcall(function() NeverYieldTheme.conn:Disconnect() end)
	pcall(function() NeverYieldPortal.conn:Disconnect() end)
	for _, list in ipairs({NeverYieldPortal.rings or {}, NeverYieldPortal.sparks or {}}) do
		for _, item in ipairs(list) do
			pcall(function() (item.frame or item):Destroy() end)
		end
	end
	pcall(function() WackyState.screen:Destroy() end)

	-- 2. the classic Infinite Yield toggles
	for _, name in ipairs(WackyState.classicOffCommands) do
		local cmd = findCmd(name)
		if cmd then
			pcall(cmd.FUNC, {"nonotify"}, speaker)
		end
	end
	pcall(function()
		local cam = workspace.CurrentCamera
		cam.CameraType = Enum.CameraType.Custom
		local hum = speaker.Character and speaker.Character:FindFirstChildOfClass("Humanoid")
		if hum then
			cam.CameraSubject = hum
		end
	end)

	-- 3. stop reacting to chat, the prefix key, keybinds and teleports
	KeepInfYield = false
	pcall(function() table.clear(binds) end)
	pcall(function() table.clear(cmds) end)

	-- 4. remove the GUI and let the script be executed again later
	pcall(function()
		Services.StarterGui:SetCore("SendNotification", {Title = "NeverYield", Text = "Unloaded. Execute the script again to bring it back.", Duration = 5})
	end)
	pcall(function()
		if PARENT and PARENT:IsA("ScreenGui") and PARENT.Name ~= "RobloxGui" then
			PARENT:Destroy()
		else
			ScaledHolder:Destroy()
		end
	end)
	pcall(function()
		getgenv().IY_LOADED = nil
		getgenv().IY_CUSTOM_LOADED = nil
	end)
end)
-- ================== END NEVERYIELD UNLOAD ==================

-- ==================== THE END ====================
-- A black hole only you can see swallows the map, then you, then server hops you out.
-- Everything here is client-side: the server and other players are not affected.
WackyState.endSounds = {rumble = 9114031727, drone = 9114353261, suck = 9125805781, implode = 9120704346, boom = 9120769331}

addcmd('end',{'theend','blackholeleave'},function(args, speaker)
	if WackyState.ending then return end
	local char = speaker.Character
	local root = getRoot(char)
	if not root then
		notify('END', 'You need a character to end the world.')
		return
	end
	WackyState.ending = true
	local camera = workspace.CurrentCamera
	local folder = Instance.new("Folder")
	folder.Name = randomString()
	folder.Parent = workspace
	pcall(function()
		if PARENT and PARENT:IsA("ScreenGui") and PARENT.Name ~= "RobloxGui" then
			PARENT.Enabled = false
		end
	end)

	local hum = char:FindFirstChildOfClass("Humanoid")

	local look = camera.CFrame.LookVector * Vector3.new(1, 0, 1)
	if look.Magnitude < 0.1 then
		look = root.CFrame.LookVector * Vector3.new(1, 0, 1)
	end
	look = look.Unit
	local center = root.Position + look * 140 + Vector3.new(0, 45, 0)
	local tilt = CFrame.Angles(math.rad(16), 0, math.rad(9))
	local diskUp = tilt.UpVector
	local radius = 2

	local function ball(color, material, transparency)
		local p = Instance.new("Part")
		p.Name = randomString()
		p.Shape = Enum.PartType.Ball
		p.Anchored = true
		p.CanCollide = false
		p.CanQuery = false
		p.CanTouch = false
		p.CastShadow = false
		p.Color = color
		p.Material = material
		p.Transparency = transparency
		p.Size = Vector3.new(1, 1, 1)
		p.Position = center
		p.Parent = folder
		return p
	end
	local core = ball(Color3.new(0, 0, 0), Enum.Material.SmoothPlastic, 0)
	local horizon = ball(Color3.fromRGB(140, 70, 255), Enum.Material.ForceField, 0)
	local glow = ball(Color3.fromRGB(255, 140, 60), Enum.Material.Neon, 0.88)

	-- accretion disk: glowing debris orbiting in a tilted ring
	local disk = {}
	for i = 1, 120 do
		local p = Instance.new("Part")
		p.Name = randomString()
		p.Anchored = true
		p.CanCollide = false
		p.CanQuery = false
		p.CanTouch = false
		p.CastShadow = false
		p.Material = Enum.Material.Neon
		local r = 1.3 + math.random() ^ 1.4 * 2.4
		p.Color = Color3.fromRGB(255, 200, 120):Lerp(Color3.fromRGB(150, 60, 255), math.clamp((r - 1.3) / 2.4, 0, 1))
		p.Parent = folder
		table.insert(disk, {part = p, r = r, a = math.random() * math.pi * 2, h = (math.random() - 0.5) * 0.15, s = 0.5 + math.random()})
	end

	-- matter streaking inward from all around
	local shell = Instance.new("Part")
	shell.Name = randomString()
	shell.Shape = Enum.PartType.Ball
	shell.Anchored = true
	shell.CanCollide = false
	shell.CanQuery = false
	shell.CanTouch = false
	shell.Transparency = 1
	shell.Position = center
	shell.Parent = folder
	local streaks = Instance.new("ParticleEmitter")
	streaks.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	streaks.Rate = 120
	streaks.LightEmission = 1
	streaks.Color = ColorSequence.new(Color3.fromRGB(255, 190, 120), Color3.fromRGB(160, 80, 255))
	streaks.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.2, 0.2), NumberSequenceKeypoint.new(1, 0.6)})
	streaks.Orientation = Enum.ParticleOrientation.VelocityParallel
	pcall(function()
		streaks.Shape = Enum.ParticleEmitterShape.Sphere
		streaks.ShapeInOut = Enum.ParticleEmitterShapeInOut.Inward
		streaks.ShapeStyle = Enum.ParticleEmitterShapeStyle.Surface
	end)
	streaks.Parent = shell

	-- screen mood
	local cc = Instance.new("ColorCorrectionEffect")
	cc.Name = randomString()
	cc.Parent = Lighting
	local bloom = Instance.new("BloomEffect")
	bloom.Name = randomString()
	bloom.Intensity = 0.4
	bloom.Size = 30
	bloom.Threshold = 0.8
	bloom.Parent = Lighting
	local blur = Instance.new("BlurEffect")
	blur.Name = randomString()
	blur.Size = 0
	blur.Parent = Lighting

	local function loop(id, volume)
		local s = WackyState.sound(id, nil, 0, true)
		TweenService:Create(s, TweenInfo.new(4), {Volume = volume}):Play()
		return s
	end
	local rumble = loop(WackyState.endSounds.rumble, 1)
	local drone = loop(WackyState.endSounds.drone, 0.5)

	-- gather the whole map (except player characters), nearest to the hole first
	local playerChars = {}
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr.Character then
			playerChars[plr.Character] = true
		end
	end
	local queue = {}
	local all = workspace:GetDescendants()
	for i, inst in ipairs(all) do
		if inst:IsA("BasePart") and not inst:IsA("Terrain") and not inst:IsDescendantOf(folder) and not inst:IsDescendantOf(camera) then
			local owner, anc = false, inst.Parent
			while anc and anc ~= workspace do
				if playerChars[anc] then
					owner = true
					break
				end
				anc = anc.Parent
			end
			if not owner then
				table.insert(queue, {part = inst, dist = (inst.Position - center).Magnitude})
			end
		end
		if i % 5000 == 0 then
			task.wait()
		end
	end
	table.sort(queue, function(a, b) return a.dist < b.dist end)

	local phase = "swallow"
	local start = tick()
	local swallowTime = 35
	local captured = 0
	local active = {}
	local shake = 0
	local clone, cloneStart, cloneFrom
	local hidden = {}
	local lastHide, diskRadius = 0, nil

	local function hideCharacter(model)
		for _, d in ipairs(model:GetDescendants()) do
			if d:IsA("BasePart") or d:IsA("Decal") then
				pcall(function() d.LocalTransparencyModifier = 1 end)
				table.insert(hidden, d)
			end
		end
	end

	local function capture(entry, now)
		local part = entry.part
		if not part.Parent then return end
		pcall(function()
			part.Anchored = true
			part.CanCollide = false
			part.CanQuery = false
			part.CanTouch = false
		end)
		if #active > 400 then
			pcall(function() part:Destroy() end)
			return
		end
		table.insert(active, {
			part = part, offset = part.Position - center, rot = part.CFrame - part.Position, size = part.Size,
			big = part.Size.Magnitude > 250 or part:IsA("MeshPart") or part:IsA("UnionOperation"), trans = part.Transparency, start = now,
			dur = math.clamp(entry.dist / 160, 1.3, 3.4),
		})
	end

	local baseFov = camera.FieldOfView
	WackyState.bindCam("theend", function()
		local t = tick() - start
		local s = shake
		camera.CFrame = camera.CFrame * CFrame.new((math.random() - 0.5) * s, (math.random() - 0.5) * s, 0) * CFrame.Angles(0, 0, (math.random() - 0.5) * s * 0.02)
		camera.FieldOfView = math.clamp(baseFov + math.min(t, 20) * 1.3, baseFov, 100)
	end)

	local nameLabel = WackyState.bigLabel("THE END IS NEAR", Color3.fromRGB(220, 190, 255))
	TweenService:Create(nameLabel, TweenInfo.new(4), {TextTransparency = 1, TextStrokeTransparency = 1}):Play()
	Services.Debris:AddItem(nameLabel, 4.5)
	task.delay(4, function()
		local run = WackyState.bigLabel("RUN.", Color3.fromRGB(255, 90, 90))
		TweenService:Create(run, TweenInfo.new(2.5), {TextTransparency = 1, TextStrokeTransparency = 1}):Play()
		Services.Debris:AddItem(run, 3)
	end)

	local finished = false
	WackyState.connect("theend", RunService.Heartbeat:Connect(function(dt)
		local now = tick()
		local t = now - start

		-- grow the hole
		if phase == "swallow" then
			radius = 4 + (math.min(t, swallowTime) / swallowTime) ^ 1.5 * 85 + math.max(0, t - swallowTime) * 4
		elseif phase == "player" then
			radius = math.min(radius + dt * 12, 120)
		end
		core.Size = Vector3.new(1, 1, 1) * radius * 2
		horizon.Size = core.Size * 1.12
		glow.Size = core.Size * 1.6
		core.Position, horizon.Position, glow.Position, shell.Position = center, center, center, center
		shell.Size = Vector3.new(1, 1, 1) * radius * 8
		streaks.Speed = NumberRange.new(radius * 2.2, radius * 3)
		streaks.Lifetime = NumberRange.new(1.2, 1.5)
		streaks.Size = NumberSequence.new(math.max(0.3, radius * 0.06), 0)
		streaks.Rate = 60 + radius * 4
		local resizeDisk = math.abs(radius - (diskRadius or -1)) > 0.5
		if resizeDisk then
			diskRadius = radius
		end
		for _, d in ipairs(disk) do
			d.a = d.a + dt * 2.4 / (d.r ^ 1.5) * d.s
			local r = radius * d.r
			if resizeDisk then
				d.part.Size = Vector3.new(1, 1, 1) * math.max(0.4, radius * 0.07 * d.s)
			end
			d.part.CFrame = CFrame.new(center + tilt:VectorToWorldSpace(Vector3.new(math.cos(d.a) * r, d.h * r, math.sin(d.a) * r)))
		end
		local mood = math.clamp(radius / 90, 0, 1)
		cc.TintColor = Color3.new(1, 1, 1):Lerp(Color3.fromRGB(190, 160, 255), mood)
		cc.Saturation = -0.4 * mood
		cc.Contrast = 0.35 * mood
		bloom.Intensity = 0.4 + mood * 1.4
		shake = 0.2 + mood * 2.2

		-- swallow the map, nearest first, faster and faster
		if phase == "swallow" then
			local target = math.floor(#queue * math.clamp(t / swallowTime, 0, 1) ^ 2.2)
			local budget = 90
			while captured < target and budget > 0 do
				captured = captured + 1
				budget = budget - 1
				capture(queue[captured], now)
			end
			if t > swallowTime * 0.6 and not WackyState.endOthersHidden then
				WackyState.endOthersHidden = true
				for _, plr in ipairs(Players:GetPlayers()) do
					if plr ~= speaker and plr.Character then
						hideCharacter(plr.Character)
					end
				end
			end
			if t > swallowTime * 0.75 and not WackyState.endTerrainGone then
				WackyState.endTerrainGone = true
				pcall(function() workspace.Terrain:Clear() end)
			end
			if t >= swallowTime then
				while captured < #queue do
					captured = captured + 1
					capture(queue[captured], now)
				end
			end
			-- the pull on me: I can run, but not forever
			local toHole = center - root.Position
			local d = toHole.Magnitude
			if d < radius * 1.25 + 4 or not root.Parent then
				while captured < #queue do
					captured = captured + 1
					capture(queue[captured], now)
				end
				root.Anchored = true
				phase = "player"
				-- now the real me gets pulled in
				clone = char
				for _, d in ipairs(char:GetDescendants()) do
					if d:IsA("BasePart") then
						pcall(function() d.CanCollide = false end)
					end
				end
				cloneStart = now
				cloneFrom = clone and clone:GetPivot()
				WackyState.sound(WackyState.endSounds.suck, nil, 1)
			else
				local speed = 14 + t * 5
				local grip = math.clamp((t - 1.5) * 0.4, 0, 6)
				if d < radius * 3 then
					grip = grip + 3
				end
				if t > 30 then
					grip = 30
				end
				local desired = toHole.Unit * speed
				local v = root.AssemblyLinearVelocity
				root.AssemblyLinearVelocity = v:Lerp(desired, math.clamp(grip * dt, 0, 1))
				if hum and t > 5 and math.random() < dt * (t - 5) * 0.5 then
					pcall(function() hum:ChangeState(Enum.HumanoidStateType.Freefall) end)
				end
			end
		end

		-- everything captured spirals into the hole
		for i = #active, 1, -1 do
			local a = active[i]
			local p = (now - a.start) / a.dur
			if p >= 1 or not a.part.Parent then
				pcall(function() a.part:Destroy() end)
				table.remove(active, i)
			else
				local e = p * p
				local spin = e * math.pi * 3 * (1 + 80 / (a.offset.Magnitude + 1))
				local rotated = CFrame.fromAxisAngle(diskUp, spin):VectorToWorldSpace(a.offset)
				rotated = rotated - diskUp * rotated:Dot(diskUp) * e
				pcall(function()
					a.part.CFrame = CFrame.new(center + rotated * (1 - e)) * a.rot * CFrame.Angles(e * 5, e * 3, e * 2)
					if a.big then
						a.part.Transparency = math.max(a.trans, e)
					elseif p > 0.5 then
						a.part.Size = a.size * math.max(0.05, 1 - (p - 0.5) * 1.9)
					end
				end)
			end
		end

		-- keep hidden characters hidden (the camera scripts like to reset this)
		if now - lastHide > 0.5 then
			lastHide = now
			for _, d in ipairs(hidden) do
				if d.Parent then
					d.LocalTransparencyModifier = 1
				end
			end
		end

		-- me, spaghettified
		if phase == "player" then
			blur.Size = math.min(24, blur.Size + dt * 6)
			if clone and cloneFrom then
				local p = math.clamp((now - cloneStart) / 4, 0, 1)
				local e = p * p
				local offset = cloneFrom.Position - center
				local spin = e * math.pi * 4
				local rotated = CFrame.fromAxisAngle(diskUp, spin):VectorToWorldSpace(offset) * (1 - e)
				pcall(function()
					clone:PivotTo(CFrame.new(center + rotated) * (cloneFrom - cloneFrom.Position) * CFrame.Angles(e * 8, e * 5, e * 3))
					if math.floor(now * 30) % 2 == 0 then
						clone:ScaleTo(math.max(0.05, 1 - e * 0.95))
					end
				end)
				if p >= 1 then
					hideCharacter(clone)
					clone = nil
				end
			elseif not finished and (#active == 0 or (cloneStart and now - cloneStart > 5)) then
				phase = "collapse"
			end
		end

		-- the hole collapses into a flash, then black
		if phase == "collapse" and not finished then
			finished = true
			WackyState.sound(WackyState.endSounds.implode, nil, 1)
			task.spawn(function()
				local screen = WackyState.overlay()
				local white = Instance.new("Frame")
				white.BorderSizePixel = 0
				white.BackgroundColor3 = Color3.new(1, 1, 1)
				white.BackgroundTransparency = 1
				white.Size = UDim2.new(1, 0, 1, 0)
				white.ZIndex = 50
				white.Parent = screen
				local shrinkStart, from = tick(), radius
				while tick() - shrinkStart < 0.8 do
					radius = from * (1 - (tick() - shrinkStart) / 0.8) ^ 2 + 0.05
					RunService.Heartbeat:Wait()
				end
				WackyState.sound(WackyState.endSounds.boom, nil, 1)
				white.BackgroundTransparency = 0
				for _, d in ipairs(disk) do
					pcall(function() d.part:Destroy() end)
				end
				pcall(function() folder:Destroy() end)
				phase = "done"
				task.wait(0.15)
				local black = Instance.new("Frame")
				black.BorderSizePixel = 0
				black.BackgroundColor3 = Color3.new(0, 0, 0)
				black.Size = UDim2.new(1, 0, 1, 0)
				black.ZIndex = 49
				black.Parent = screen
				TweenService:Create(white, TweenInfo.new(1.5), {BackgroundTransparency = 1}):Play()
				TweenService:Create(rumble, TweenInfo.new(2), {Volume = 0}):Play()
				TweenService:Create(drone, TweenInfo.new(2), {Volume = 0}):Play()
				local title = Instance.new("TextLabel")
				title.BackgroundTransparency = 1
				title.AnchorPoint = Vector2.new(0.5, 0.5)
				title.Position = UDim2.new(0.5, 0, 0.45, 0)
				title.Size = UDim2.new(0.7, 0, 0.14, 0)
				title.Font = Enum.Font.FredokaOne
				title.TextScaled = true
				title.Text = "THE END"
				title.TextColor3 = Color3.new(1, 1, 1)
				title.TextTransparency = 1
				title.ZIndex = 51
				title.Parent = screen
				local sub = Instance.new("TextLabel")
				sub.BackgroundTransparency = 1
				sub.AnchorPoint = Vector2.new(0.5, 0.5)
				sub.Position = UDim2.new(0.5, 0, 0.56, 0)
				sub.Size = UDim2.new(0.6, 0, 0.04, 0)
				sub.Font = Enum.Font.Gotham
				sub.TextScaled = true
				sub.Text = "travelling to a new universe..."
				sub.TextColor3 = Color3.fromRGB(200, 180, 255)
				sub.TextTransparency = 1
				sub.ZIndex = 51
				sub.Parent = screen
				TweenService:Create(title, TweenInfo.new(1.5), {TextTransparency = 0}):Play()
				task.wait(0.8)
				TweenService:Create(sub, TweenInfo.new(1.5), {TextTransparency = 0}):Play()
				task.wait(2)
				WackyState.disconnect("theend")
				WackyState.unbindCam("theend")
				local hop = findCmd("serverhop")
				if hop then
					pcall(hop.FUNC, {}, speaker)
				end
				task.wait(12)
				sub.Text = "no new universe found... rejoining this one"
				local rj = findCmd("rejoin")
				if rj then
					pcall(rj.FUNC, {}, speaker)
				end
				-- still here? teleporting is blocked in this server, so give the screen back
				task.wait(15)
				sub.Text = "couldn't leave this server. the map stays gone until you rejoin."
				task.wait(3)
				for _, obj in ipairs({black, title, sub, white, cc, bloom, blur, rumble, drone}) do
					pcall(function() obj:Destroy() end)
				end
				pcall(function() camera.FieldOfView = baseFov end)
				pcall(function()
					if PARENT and PARENT:IsA("ScreenGui") then
						PARENT.Enabled = true
					end
				end)
				WackyState.ending = false
				WackyState.endOthersHidden = false
				WackyState.endTerrainGone = false
				notify('END', 'Teleport failed, so you are still in this server. Use rejoin (or leave) to get the map back.', 10)
			end)
		end
	end))
end)
-- ================== END THE END ==================

-- ==================== NEVERYIELD STATS ====================
-- Lifetime stats saved in the executor workspace (NeverYield_stats.json), so they carry across every game.
-- Kills come from the game's leaderboard (Kills, KOs, Eliminations...) and from Roblox "creator" damage
-- tags; whichever counted more in a server is used, so one kill is never counted twice.
NeverYieldStats = {file = "NeverYield_stats.json", dirty = false, lastSave = 0, page = 1, chatMode = "mine", watched = setmetatable({}, {__mode = "k"})}
NeverYieldStats.tagNames = {"creator", "Creator", "killer", "Killer", "KillerTag", "LastHit", "lastHit", "LastHitBy", "LastDamager", "LastAttacker", "Attacker", "DamagedBy"}
NeverYieldStats.tabs = {{"overview", "Overview"}, {"combat", "Combat"}, {"games", "Games"}, {"chat", "Chat"}, {"people", "People"}, {"commands", "Commands"}}
NeverYieldStats.streakNames = {[3] = "Killing spree", [5] = "Rampage", [10] = "Unstoppable", [15] = "Godlike", [20] = "Legendary", [30] = "NEVERYIELD"}

NeverYieldStats.blank = function()
	return {
		version = 1, created = os.time(),
		totals = {playtime = 0, sessions = 0, distance = 0, jumps = 0, deaths = 0, kills = 0, npcKills = 0, messages = 0,
			words = 0, commands = 0, bestStreak = 0, longestLife = 0, playersMet = 0, deathsByPlayers = 0},
		games = {}, commands = {}, players = {},
		chat = {mine = {}, all = {}},
		settings = {logOthers = true},
	}
end

NeverYieldStats.load = function()
	local data
	pcall(function()
		if isfile and isfile(NeverYieldStats.file) then
			local raw = readfile(NeverYieldStats.file)
			local ok, decoded = pcall(function() return HttpService:JSONDecode(raw) end)
			if ok and type(decoded) == "table" then
				data = decoded
			elseif type(raw) == "string" and raw ~= "" then
				-- keep a copy of a damaged file instead of silently losing it
				writefile("NeverYield_stats_broken.json", raw, true)
			end
		end
	end)
	local blank = NeverYieldStats.blank()
	data = data or blank
	for key, value in pairs(blank) do
		if type(data[key]) ~= type(value) then
			data[key] = value
		end
	end
	for key, value in pairs(blank.totals) do
		if type(data.totals[key]) ~= "number" then
			data.totals[key] = value
		end
	end
	if type(data.chat.mine) ~= "table" then data.chat.mine = {} end
	if type(data.chat.all) ~= "table" then data.chat.all = {} end
	if data.settings.logOthers == nil then data.settings.logOthers = true end
	NeverYieldStats.data = data
end

NeverYieldStats.trimList = function(list, max)
	local n = #list
	local extra = n - max
	if extra > 0 then
		table.move(list, extra + 1, n, 1)
		for i = n - extra + 1, n do
			list[i] = nil
		end
	end
end

NeverYieldStats.trim = function()
	local data = NeverYieldStats.data
	NeverYieldStats.trimList(data.chat.mine, 5000)
	NeverYieldStats.trimList(data.chat.all, 3000)
	local ids = {}
	for id in pairs(data.players) do
		table.insert(ids, id)
	end
	if #ids > 3000 then
		table.sort(ids, function(a, b) return (data.players[a].time or 0) > (data.players[b].time or 0) end)
		for i = 2501, #ids do
			data.players[ids[i]] = nil
		end
	end
end

NeverYieldStats.save = function()
	if not NeverYieldStats.data then return false end
	pcall(NeverYieldStats.tick)
	pcall(NeverYieldStats.trim)
	local ok, encoded = pcall(function() return HttpService:JSONEncode(NeverYieldStats.data) end)
	if ok and encoded then
		writefile(NeverYieldStats.file, encoded, true)
		NeverYieldStats.dirty = false
		NeverYieldStats.lastSave = os.clock()
		return true
	end
	return false
end

NeverYieldStats.game = function()
	local data = NeverYieldStats.data
	local key = tostring(game.PlaceId)
	local entry = data.games[key]
	if type(entry) ~= "table" then
		entry = {name = "Place " .. key, playtime = 0, visits = 0, kills = 0, deaths = 0, npcKills = 0, messages = 0, first = os.time(), last = os.time()}
		data.games[key] = entry
	end
	return entry
end

NeverYieldStats.player = function(plr)
	local data = NeverYieldStats.data
	local key = tostring(plr.UserId)
	local p = data.players[key]
	if type(p) ~= "table" then
		p = {name = plr.Name, display = plr.DisplayName, time = 0, games = 0, first = os.time(), last = os.time(), iKilled = 0, killedMe = 0, messages = 0}
		data.players[key] = p
		data.totals.playersMet = data.totals.playersMet + 1
	end
	p.name, p.display = plr.Name, plr.DisplayName
	return p
end

-- playtime, time spent with each player, servers shared
NeverYieldStats.tick = function()
	local s = NeverYieldStats.session
	local now = os.clock()
	local dt = now - (s.lastTick or now)
	s.lastTick = now
	if dt <= 0 or dt > 120 then return end
	local data = NeverYieldStats.data
	data.totals.playtime = data.totals.playtime + dt
	s.playtime = s.playtime + dt
	local g = NeverYieldStats.game()
	g.playtime = g.playtime + dt
	g.last = os.time()
	local lp = Players.LocalPlayer
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= lp then
			local p = NeverYieldStats.player(plr)
			p.time = (p.time or 0) + dt
			p.last = os.time()
			if not s.seen[plr.UserId] then
				s.seen[plr.UserId] = true
				p.games = (p.games or 0) + 1
			end
		end
	end
	NeverYieldStats.dirty = true
end

-- Combat
NeverYieldStats.resolve = function(value)
	if typeof(value) == "Instance" then
		if value:IsA("Player") then return value end
		if value:IsA("Model") then return Players:GetPlayerFromCharacter(value) end
	elseif type(value) == "string" then
		local plr = Players:FindFirstChild(value)
		if plr and plr:IsA("Player") then return plr end
		local id = tonumber(value)
		if id then return Players:GetPlayerByUserId(id) end
	elseif type(value) == "number" then
		return Players:GetPlayerByUserId(value)
	end
	return nil
end

-- who gets the credit when this humanoid dies (the usual Roblox "creator" tag and similar ones)
NeverYieldStats.tagOwner = function(model, hum)
	for _, holder in ipairs({hum, model}) do
		if holder then
			for _, name in ipairs(NeverYieldStats.tagNames) do
				local tag = holder:FindFirstChild(name)
				if tag and tag:IsA("ValueBase") then
					local ok, plr = pcall(function() return NeverYieldStats.resolve(tag.Value) end)
					if ok and plr then return plr end
				end
				local ok, plr = pcall(function() return NeverYieldStats.resolve(holder:GetAttribute(name)) end)
				if ok and plr then return plr end
			end
		end
	end
	return nil
end

NeverYieldStats.boardBest = function(kind)
	local best = 0
	for _, entry in pairs(NeverYieldStats.session.board[kind]) do
		if entry.gained > best then
			best = entry.gained
		end
	end
	return best
end

-- turn this server's tag + leaderboard counts into lifetime kills/deaths without double counting
NeverYieldStats.settle = function()
	local s, data = NeverYieldStats.session, NeverYieldStats.data
	local g = NeverYieldStats.game()
	local kills = math.max(s.tagKills, NeverYieldStats.boardBest("kills"))
	local newKills = kills - s.countedKills
	if newKills > 0 then
		s.countedKills = kills
		data.totals.kills = data.totals.kills + newKills
		g.kills = (g.kills or 0) + newKills
		local before = s.streak
		s.streak = s.streak + newKills
		if s.streak > data.totals.bestStreak then
			data.totals.bestStreak = s.streak
		end
		for count, name in pairs(NeverYieldStats.streakNames) do
			if before < count and s.streak >= count then
				notify('Killstreak', name .. '! ' .. s.streak .. ' kills in a row.')
			end
		end
		NeverYieldStats.dirty = true
	end
	local deaths = math.max(s.myDeaths, NeverYieldStats.boardBest("deaths"))
	local newDeaths = deaths - s.countedDeaths
	if newDeaths > 0 then
		s.countedDeaths = deaths
		data.totals.deaths = data.totals.deaths + newDeaths
		g.deaths = (g.deaths or 0) + newDeaths
		s.streak = 0
		NeverYieldStats.dirty = true
	end
end

NeverYieldStats.addTagKill = function(victim)
	local s = NeverYieldStats.session
	s.tagKills = s.tagKills + 1
	local p = NeverYieldStats.player(victim)
	p.iKilled = (p.iKilled or 0) + 1
	NeverYieldStats.settle()
end

NeverYieldStats.addNpcKill = function()
	local data, s = NeverYieldStats.data, NeverYieldStats.session
	data.totals.npcKills = data.totals.npcKills + 1
	local g = NeverYieldStats.game()
	g.npcKills = (g.npcKills or 0) + 1
	s.npcKills = s.npcKills + 1
	NeverYieldStats.dirty = true
end

NeverYieldStats.addMyDeath = function(killer)
	local data, s = NeverYieldStats.data, NeverYieldStats.session
	s.myDeaths = s.myDeaths + 1
	local life = os.clock() - (s.spawnTime or os.clock())
	if life > data.totals.longestLife then
		data.totals.longestLife = life
	end
	if killer and killer ~= Players.LocalPlayer then
		local p = NeverYieldStats.player(killer)
		p.killedMe = (p.killedMe or 0) + 1
		data.totals.deathsByPlayers = data.totals.deathsByPlayers + 1
		s.lastKiller = killer.DisplayName .. " (@" .. killer.Name .. ")"
	end
	NeverYieldStats.settle()
end

NeverYieldStats.watchHumanoid = function(hum)
	if NeverYieldStats.watched[hum] then return end
	NeverYieldStats.watched[hum] = true
	local owner = NeverYieldStats
	hum.Died:Connect(function()
		if owner.stopped or NeverYieldStats ~= owner then return end
		local model = hum.Parent
		local lp = Players.LocalPlayer
		local plr = model and Players:GetPlayerFromCharacter(model)
		if plr == lp then return end
		if NeverYieldStats.tagOwner(model, hum) ~= lp then return end
		if plr then
			NeverYieldStats.addTagKill(plr)
		else
			NeverYieldStats.addNpcKill()
		end
	end)
end

NeverYieldStats.watchMe = function(char)
	local s = NeverYieldStats.session
	s.spawnTime = os.clock()
	local hum = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid", 10)
	if not hum then return end
	local owner = NeverYieldStats
	hum.Died:Connect(function()
		if owner.stopped or NeverYieldStats ~= owner then return end
		NeverYieldStats.addMyDeath(NeverYieldStats.tagOwner(char, hum))
	end)
	hum.StateChanged:Connect(function(_, new)
		if owner.stopped or NeverYieldStats ~= owner or new ~= Enum.HumanoidStateType.Jumping then return end
		local data = NeverYieldStats.data
		data.totals.jumps = data.totals.jumps + 1
		s.jumps = s.jumps + 1
		NeverYieldStats.dirty = true
	end)
end

NeverYieldStats.statKind = function(name)
	local n = name:lower():gsub("[%s_%-%.]", "")
	if n:find("skill") or n:find("streak") or n:find("assist") then return nil end
	if n == "ko" or n == "kos" or n:find("kill") or n:find("knockout") or n:find("elim") or n:find("frag") or n:find("takedown") then
		return "kills"
	end
	if n == "wo" or n == "wos" or n:find("death") or n:find("wipeout") or n:find("died") then
		return "deaths"
	end
	return nil
end

-- the game's own leaderboard (leaderstats). Only small jumps count, so saved totals loading in
-- (e.g. Kills going 0 -> 523 when your data loads) are not counted as kills.
NeverYieldStats.watchBoard = function()
	local lp = Players.LocalPlayer
	local s = NeverYieldStats.session
	local function hook(stat)
		if not (stat:IsA("IntValue") or stat:IsA("NumberValue")) then return end
		local kind = NeverYieldStats.statKind(stat.Name)
		if not kind or s.board[kind][stat] then return end
		local entry = {last = stat.Value, gained = 0, hooked = os.clock()}
		s.board[kind][stat] = entry
		local owner = NeverYieldStats
		stat.Changed:Connect(function(value)
			if owner.stopped or NeverYieldStats ~= owner or type(value) ~= "number" then return end
			local gain = value - entry.last
			entry.last = value
			if gain > 0 and gain <= 3 and os.clock() - entry.hooked > 10 then
				entry.gained = entry.gained + gain
				NeverYieldStats.settle()
			end
		end)
	end
	local function hookFolder(folder)
		for _, stat in ipairs(folder:GetChildren()) do
			hook(stat)
		end
		WackyState.connect("statsBoardAdded", folder.ChildAdded:Connect(hook))
	end
	local folder = lp:FindFirstChild("leaderstats")
	if folder then
		hookFolder(folder)
	end
	WackyState.connect("statsBoard", lp.ChildAdded:Connect(function(child)
		if child.Name == "leaderstats" then
			hookFolder(child)
		end
	end))
end

-- Chat
NeverYieldStats.logChat = function(plr, text)
	if NeverYieldStats.stopped or type(text) ~= "string" or text == "" then return end
	local data, s = NeverYieldStats.data, NeverYieldStats.session
	text = text:gsub("&lt;", "<"):gsub("&gt;", ">"):gsub("&quot;", '"'):gsub("&apos;", "'"):gsub("&amp;", "&")
	text = text:sub(1, 300)
	local now = os.time()
	if plr == Players.LocalPlayer then
		local _, words = text:gsub("%S+", "")
		data.totals.messages = data.totals.messages + 1
		data.totals.words = data.totals.words + words
		local g = NeverYieldStats.game()
		g.messages = (g.messages or 0) + 1
		s.messages = s.messages + 1
		table.insert(data.chat.mine, {t = now, p = game.PlaceId, m = text})
		if #data.chat.mine > 5200 then NeverYieldStats.trimList(data.chat.mine, 5000) end
	else
		if plr then
			local p = NeverYieldStats.player(plr)
			p.messages = (p.messages or 0) + 1
		end
		if data.settings.logOthers then
			table.insert(data.chat.all, {t = now, p = game.PlaceId, u = plr and plr.Name or "?", d = plr and plr.DisplayName or "?", m = text})
			if #data.chat.all > 3200 then NeverYieldStats.trimList(data.chat.all, 3000) end
		end
	end
	NeverYieldStats.dirty = true
end

NeverYieldStats.hookChat = function()
	local TextChatService = game:GetService("TextChatService")
	local newChat = false
	pcall(function() newChat = TextChatService.ChatVersion == Enum.ChatVersion.TextChatService end)
	if newChat then
		local seen, seenCount = {}, 0
		WackyState.connect("statsChat", TextChatService.MessageReceived:Connect(function(message)
			local source = message.TextSource
			if not source then return end
			local id = message.MessageId
			if id and id ~= "" then
				if seen[id] then return end
				seen[id] = true
				seenCount = seenCount + 1
				if seenCount > 1000 then
					seen, seenCount = {}, 0
				end
			end
			NeverYieldStats.logChat(Players:GetPlayerByUserId(source.UserId), message.Text)
		end))
	else
		local function hookPlayer(plr)
			WackyState.connect("statsChat" .. plr.UserId, plr.Chatted:Connect(function(text)
				NeverYieldStats.logChat(plr, text)
			end))
		end
		for _, plr in ipairs(Players:GetPlayers()) do
			hookPlayer(plr)
		end
		WackyState.connect("statsChatJoin", Players.PlayerAdded:Connect(hookPlayer))
	end
end

-- Commands you type (chat or command bar) are counted; commands started by other commands are not
NeverYieldStats.countCommands = function(cmdStr)
	local data = NeverYieldStats.data
	if not data or type(cmdStr) ~= "string" then return end
	for part in cmdStr:gmatch("[^\\]+") do
		part = part:gsub("^%s*inf%^", ""):gsub("^%s*[%d%.]+%^", ""):gsub("^%s*[%d%.]+%^", "")
		local name = part:match("^%s*!?(%S+)")
		local cmd = name and findCmd(name)
		if cmd and cmd.NAME then
			local key = tostring(cmd.NAME):lower()
			data.commands[key] = (data.commands[key] or 0) + 1
			data.totals.commands = data.totals.commands + 1
			NeverYieldStats.session.commands = NeverYieldStats.session.commands + 1
			NeverYieldStats.dirty = true
		end
	end
end

-- Formatting
NeverYieldStats.time = function(sec)
	sec = math.floor(sec or 0)
	local d, h, m = math.floor(sec / 86400), math.floor(sec % 86400 / 3600), math.floor(sec % 3600 / 60)
	if d > 0 then return string.format("%dd %dh %dm", d, h, m) end
	if h > 0 then return string.format("%dh %dm", h, m) end
	if m > 0 then return string.format("%dm %ds", m, sec % 60) end
	return sec .. "s"
end

NeverYieldStats.num = function(n)
	local text = tostring(math.floor(n or 0))
	local formatted = text:reverse():gsub("(%d%d%d)", "%1,"):reverse()
	return (formatted:gsub("^,", ""))
end

NeverYieldStats.kd = function(kills, deaths)
	if deaths > 0 then
		return string.format("%.2f", kills / deaths)
	end
	return tostring(math.floor(kills))
end

NeverYieldStats.dist = function(studs)
	local meters = math.floor((studs or 0) * 0.28)
	if meters >= 1000 then
		return string.format("%.2f km", meters / 1000)
	end
	return meters .. " m"
end

NeverYieldStats.when = function(t)
	return os.date("%m/%d %H:%M", t or 0)
end

-- Rows for each tab of the Stats panel: {left text, right text}; no right text = full-width line
NeverYieldStats.lines = function(tab)
	local data, s = NeverYieldStats.data, NeverYieldStats.session
	local t, out = data.totals, {}
	local fmt = NeverYieldStats
	local function add(key, value)
		table.insert(out, {key, value})
	end
	if tab == "overview" then
		local games = 0
		for _ in pairs(data.games) do games = games + 1 end
		add("Tracking since", os.date("%b %d, %Y", data.created))
		add("Total playtime", fmt.time(t.playtime))
		add("This session", fmt.time(s.playtime) .. " in " .. tostring(NeverYieldStats.game().name))
		add("Servers joined", fmt.num(t.sessions))
		add("Different games", fmt.num(games))
		add("Kills / Deaths", fmt.num(t.kills) .. " / " .. fmt.num(t.deaths) .. "  (K/D " .. fmt.kd(t.kills, t.deaths) .. ")")
		add("NPC kills", fmt.num(t.npcKills))
		add("Best killstreak", fmt.num(t.bestStreak))
		add("Messages sent", fmt.num(t.messages) .. " (" .. fmt.num(t.words) .. " words)")
		add("Commands used", fmt.num(t.commands))
		add("Distance travelled", fmt.dist(t.distance))
		add("Jumps", fmt.num(t.jumps))
		add("Players met", fmt.num(t.playersMet))
	elseif tab == "combat" then
		local mostKilled, nemesis
		for _, p in pairs(data.players) do
			if type(p) == "table" then
				if (p.iKilled or 0) > 0 and (not mostKilled or p.iKilled > mostKilled.iKilled) then mostKilled = p end
				if (p.killedMe or 0) > 0 and (not nemesis or p.killedMe > nemesis.killedMe) then nemesis = p end
			end
		end
		add("This server", s.countedKills .. " kills / " .. s.countedDeaths .. " deaths  (streak " .. s.streak .. ")")
		add("All-time kills", fmt.num(t.kills))
		add("All-time deaths", fmt.num(t.deaths))
		add("K/D ratio", fmt.kd(t.kills, t.deaths))
		add("NPC kills", fmt.num(t.npcKills))
		add("Best killstreak", fmt.num(t.bestStreak))
		add("Longest life", fmt.time(t.longestLife))
		add("Current life", fmt.time(os.clock() - (s.spawnTime or os.clock())))
		add("Killed by players", fmt.num(t.deathsByPlayers))
		add("Last killed by", s.lastKiller or "-")
		add("Most killed", mostKilled and ((mostKilled.display or mostKilled.name or "?") .. " (" .. mostKilled.iKilled .. "x)") or "-")
		add("Nemesis", nemesis and ((nemesis.display or nemesis.name or "?") .. " (" .. nemesis.killedMe .. "x)") or "-")
		add("Kills counted from", next(s.board.kills) and "leaderboard + damage tags" or "damage tags")
	elseif tab == "games" then
		local list = {}
		for _, g in pairs(data.games) do
			if type(g) == "table" then table.insert(list, g) end
		end
		table.sort(list, function(a, b) return (a.playtime or 0) > (b.playtime or 0) end)
		for i, g in ipairs(list) do
			add(i .. ". " .. tostring(g.name or "?"), fmt.time(g.playtime) .. " | " .. (g.visits or 0) .. " visits | " .. (g.kills or 0) .. "K " .. (g.deaths or 0) .. "D")
		end
	elseif tab == "chat" then
		local list = NeverYieldStats.chatMode == "all" and data.chat.all or data.chat.mine
		local filter = NeverYieldStats.filter and NeverYieldStats.filter:lower()
		for i = #list, 1, -1 do
			local m = list[i]
			if type(m) == "table" and type(m.m) == "string" then
				local who = m.u and ((m.d or m.u) .. ": ") or ""
				if not filter or m.m:lower():find(filter, 1, true) or who:lower():find(filter, 1, true) then
					add(fmt.when(m.t) .. "  " .. who .. m.m, nil)
				end
			end
		end
		if #out == 0 then
			add(filter and ('No messages match "' .. filter .. '".') or "No messages saved yet.", nil)
		end
	elseif tab == "people" then
		local list = {}
		for _, p in pairs(data.players) do
			if type(p) == "table" then table.insert(list, p) end
		end
		table.sort(list, function(a, b) return (a.time or 0) > (b.time or 0) end)
		for i, p in ipairs(list) do
			add(i .. ". " .. tostring(p.display or p.name or "?") .. " (@" .. tostring(p.name or "?") .. ")",
				fmt.time(p.time) .. " | " .. (p.games or 0) .. " servers | K " .. (p.iKilled or 0) .. " / D " .. (p.killedMe or 0))
		end
		if #out == 0 then add("Nobody yet.", nil) end
	elseif tab == "commands" then
		local list = {}
		for name, count in pairs(data.commands) do
			if type(count) == "number" then table.insert(list, {name, count}) end
		end
		table.sort(list, function(a, b) return a[2] > b[2] end)
		for i, c in ipairs(list) do
			add(i .. ". " .. tostring(c[1]), fmt.num(c[2]) .. " times")
		end
		if #out == 0 then add("No commands used yet (commands you type are counted).", nil) end
	end
	return out
end

-- Stats panel (own ScreenGui, plain Frames like the Theme Studio)
NeverYieldStats.close = function()
	WackyState.disconnect("statsPanel")
	for _, conn in ipairs(NeverYieldStats.dragConns or {}) do
		pcall(function() conn:Disconnect() end)
	end
	NeverYieldStats.dragConns = {}
	if NeverYieldStats.screen then
		pcall(function() NeverYieldStats.screen:Destroy() end)
	end
	NeverYieldStats.screen, NeverYieldStats.panel, NeverYieldStats.render = nil, nil, nil
end

NeverYieldStats.show = function(tab)
	NeverYieldStats.tab = tab or NeverYieldStats.tab or "overview"
	if NeverYieldStats.render then
		pcall(NeverYieldStats.render)
	end
end

NeverYieldStats.open = function(tab, filter)
	if NeverYieldStats.panel and NeverYieldStats.panel.Parent then
		if tab or filter then
			NeverYieldStats.filter = filter
			NeverYieldStats.show(tab)
		else
			NeverYieldStats.close()
		end
		return
	end
	NeverYieldStats.close()
	NeverYieldStats.filter = filter
	pcall(NeverYieldStats.tick)

	local screen = Instance.new("ScreenGui")
	screen.Name = randomString()
	screen.ResetOnSpawn = false
	screen.IgnoreGuiInset = true
	screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screen.DisplayOrder = 2147483646
	if not pcall(function() screen.Parent = gethui and gethui() or COREGUI end) then
		screen.Parent = Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")
	end
	NeverYieldStats.screen = screen

	local panel = Instance.new("Frame")
	panel.Name = randomString()
	panel.AnchorPoint = Vector2.new(0.5, 0.5)
	panel.Position = UDim2.new(0.5, 0, 0.5, 0)
	panel.Size = UDim2.new(0, 580, 0, 420)
	panel.BackgroundColor3 = currentShade1
	panel.BorderSizePixel = 0
	panel.Active = true
	panel.ZIndex = 20
	NeverYieldPortal.corner(panel, UDim.new(0, 16))
	local _, strokeGradient = NeverYieldPortal.stroke(panel, 2.5, 0)
	local scale = Instance.new("UIScale")
	scale.Scale = 0.85
	scale.Parent = panel
	panel.Parent = screen
	NeverYieldStats.panel = panel

	local function label(props)
		local l = Instance.new("TextLabel")
		l.BackgroundTransparency = 1
		l.BorderSizePixel = 0
		l.Font = Enum.Font.Gotham
		l.TextSize = 13
		l.TextColor3 = currentText1
		l.ZIndex = 21
		for k, v in pairs(props) do
			l[k] = v
		end
		l.Parent = panel
		return l
	end
	local function button(text, pos, size)
		local b = Instance.new("TextButton")
		b.Position = pos
		b.Size = size
		b.AutoButtonColor = false
		b.BorderSizePixel = 0
		b.Font = Enum.Font.GothamBold
		b.TextSize = 13
		b.Text = text
		b.TextColor3 = currentText1
		b.BackgroundColor3 = currentShade2
		b.ZIndex = 22
		NeverYieldPortal.corner(b, UDim.new(0, 12))
		b.Parent = panel
		return b
	end

	local title = label({Position = UDim2.new(0, 0, 0, 10), Size = UDim2.new(1, 0, 0, 34), Font = Enum.Font.FredokaOne, TextSize = 30, Text = "NEVERYIELD STATS", TextColor3 = Color3.new(1, 1, 1), Active = true})
	local titleGradient = Instance.new("UIGradient")
	titleGradient.Color = NeverYieldPortal.swirl()
	titleGradient.Parent = title
	local subtitle = label({Position = UDim2.new(0, 0, 0, 44), Size = UDim2.new(1, 0, 0, 18), TextTransparency = 0.25})
	local close = button("X", UDim2.new(1, -38, 0, 10), UDim2.new(0, 28, 0, 28))
	close.MouseButton1Click:Connect(NeverYieldStats.close)

	local tabButtons = {}
	for i, info in ipairs(NeverYieldStats.tabs) do
		local b = button(info[2], UDim2.new(0, 14 + (i - 1) * 93, 0, 70), UDim2.new(0, 87, 0, 26))
		tabButtons[info[1]] = b
		b.MouseButton1Click:Connect(function()
			NeverYieldStats.filter = nil
			NeverYieldStats.page = 1
			NeverYieldStats.show(info[1])
		end)
	end

	local rows = {}
	for i = 1, 13 do
		local y = 104 + (i - 1) * 20
		local key = label({Position = UDim2.new(0, 22, 0, y), Size = UDim2.new(0.55, -22, 0, 20), TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd})
		local value = label({Position = UDim2.new(0.55, 0, 0, y), Size = UDim2.new(0.45, -22, 0, 20), TextXAlignment = Enum.TextXAlignment.Right, TextTruncate = Enum.TextTruncate.AtEnd, Font = Enum.Font.GothamBold})
		rows[i] = {key = key, value = value}
	end

	local prev = button("<", UDim2.new(0, 14, 1, -40), UDim2.new(0, 30, 0, 26))
	local pageLabel = label({Position = UDim2.new(0, 46, 1, -40), Size = UDim2.new(0, 72, 0, 26), Text = "1 / 1"})
	local nextPage = button(">", UDim2.new(0, 120, 1, -40), UDim2.new(0, 30, 0, 26))
	local modeButton = button("Mine", UDim2.new(1, -244, 1, -40), UDim2.new(0, 110, 0, 26))
	local saveButton = button("Save now", UDim2.new(1, -124, 1, -40), UDim2.new(0, 110, 0, 26))

	NeverYieldStats.render = function()
		local tab = NeverYieldStats.tab or "overview"
		local lines = NeverYieldStats.lines(tab)
		local pages = math.max(1, math.ceil(#lines / #rows))
		NeverYieldStats.page = math.clamp(NeverYieldStats.page or 1, 1, pages)
		local first = (NeverYieldStats.page - 1) * #rows
		local valueColor = currentShade3:Lerp(Color3.new(1, 1, 1), 0.55)
		for i, row in ipairs(rows) do
			local line = lines[first + i]
			row.key.Text = line and line[1] or ""
			row.value.Text = line and line[2] or ""
			row.key.Size = (line and line[2] == nil) and UDim2.new(1, -44, 0, 20) or UDim2.new(0.55, -22, 0, 20)
			row.key.TextColor3 = currentText1
			row.value.TextColor3 = valueColor
		end
		pageLabel.Text = NeverYieldStats.page .. " / " .. pages
		prev.Visible, nextPage.Visible, pageLabel.Visible = pages > 1, pages > 1, pages > 1
		modeButton.Visible = tab == "chat"
		modeButton.Text = NeverYieldStats.chatMode == "all" and "Everyone" or "Mine"
		for id, b in pairs(tabButtons) do
			local active = id == tab
			b.BackgroundColor3 = active and currentShade3 or currentShade2
			b.BackgroundTransparency = active and 0 or 0.3
		end
		if tab == "chat" and NeverYieldStats.filter then
			subtitle.Text = 'search: "' .. NeverYieldStats.filter .. '"'
		else
			subtitle.Text = "every game, every server  |  saved on your PC"
		end
	end

	prev.MouseButton1Click:Connect(function()
		NeverYieldStats.page = (NeverYieldStats.page or 1) - 1
		NeverYieldStats.show()
	end)
	nextPage.MouseButton1Click:Connect(function()
		NeverYieldStats.page = (NeverYieldStats.page or 1) + 1
		NeverYieldStats.show()
	end)
	modeButton.MouseButton1Click:Connect(function()
		NeverYieldStats.chatMode = NeverYieldStats.chatMode == "all" and "mine" or "all"
		NeverYieldStats.page = 1
		NeverYieldStats.show()
	end)
	saveButton.MouseButton1Click:Connect(function()
		saveButton.Text = NeverYieldStats.save() and "Saved!" or "Save failed"
		task.delay(1.5, function()
			if saveButton.Parent then saveButton.Text = "Save now" end
		end)
	end)

	local dragging, dragStart, startPos = false, nil, nil
	NeverYieldStats.dragConns = {
		title.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging, dragStart, startPos = true, input.Position, panel.Position
			end
		end),
		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = false
			end
		end),
		UserInputService.InputChanged:Connect(function(input)
			if not dragging or not panel.Parent then return end
			if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
			local delta = input.Position - dragStart
			panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end),
	}

	WackyState.connect("statsPanel", RunService.RenderStepped:Connect(function()
		if not panel.Parent then
			NeverYieldStats.close()
			return
		end
		local t = tick()
		strokeGradient.Rotation = (t * 120) % 360
		titleGradient.Rotation = (t * 60) % 360
	end))

	TweenService:Create(scale, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
	NeverYieldStats.show(tab or NeverYieldStats.tab or "overview")
end

NeverYieldStats.stop = function()
	if NeverYieldStats.stopped then return end
	pcall(NeverYieldStats.save)
	NeverYieldStats.stopped = true
	pcall(NeverYieldStats.close)
end

NeverYieldStats.start = function()
	NeverYieldStats.session = {tagKills = 0, myDeaths = 0, countedKills = 0, countedDeaths = 0, streak = 0, npcKills = 0,
		messages = 0, jumps = 0, distance = 0, playtime = 0, commands = 0, board = {kills = {}, deaths = {}}, seen = {},
		spawnTime = os.clock(), lastTick = os.clock()}
	NeverYieldStats.load()
	local data, s = NeverYieldStats.data, NeverYieldStats.session
	data.totals.sessions = data.totals.sessions + 1
	local g = NeverYieldStats.game()
	g.visits = (g.visits or 0) + 1
	task.spawn(function()
		pcall(function()
			local info = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
			if info and info.Name then
				NeverYieldStats.game().name = info.Name
			end
		end)
	end)

	if not NeverYieldStats.execWrapped then
		NeverYieldStats.execWrapped = true
		local originalExecCmd = execCmd
		execCmd = function(cmdStr, speaker, store, ...)
			if store and speaker == Players.LocalPlayer and not NeverYieldStats.stopped then
				pcall(NeverYieldStats.countCommands, cmdStr)
			end
			return originalExecCmd(cmdStr, speaker, store, ...)
		end
	end

	local lp = Players.LocalPlayer
	if lp.Character then
		task.spawn(NeverYieldStats.watchMe, lp.Character)
	end
	WackyState.connect("statsSpawn", lp.CharacterAdded:Connect(function(char)
		NeverYieldStats.watchMe(char)
	end))
	WackyState.connect("statsHumanoids", workspace.DescendantAdded:Connect(function(inst)
		if inst:IsA("Humanoid") then
			NeverYieldStats.watchHumanoid(inst)
		end
	end))
	task.spawn(function()
		for i, inst in ipairs(workspace:GetDescendants()) do
			if inst:IsA("Humanoid") then
				NeverYieldStats.watchHumanoid(inst)
			end
			if i % 3000 == 0 then
				task.wait()
			end
		end
	end)
	pcall(NeverYieldStats.watchBoard)
	pcall(NeverYieldStats.hookChat)

	local lastPos
	WackyState.connect("statsMove", RunService.Heartbeat:Connect(function()
		if NeverYieldStats.stopped then return end
		local root = getRoot(lp.Character)
		if not root then
			lastPos = nil
			return
		end
		local pos = root.Position
		if lastPos then
			local step = ((pos - lastPos) * Vector3.new(1, 0, 1)).Magnitude
			-- ignore teleports (more than 8 studs in one frame)
			if step > 0.05 and step < 8 then
				data.totals.distance = data.totals.distance + step
				s.distance = s.distance + step
			end
		end
		lastPos = pos
	end))

	WackyState.connect("statsTeleport", lp.OnTeleport:Connect(function(state)
		if state == Enum.TeleportState.Started then
			pcall(NeverYieldStats.save)
		end
	end))

	local owner = NeverYieldStats
	task.spawn(function()
		while not owner.stopped and NeverYieldStats == owner do
			task.wait(5)
			if owner.stopped or NeverYieldStats ~= owner then break end
			pcall(NeverYieldStats.tick)
			if NeverYieldStats.dirty and os.clock() - NeverYieldStats.lastSave > 60 then
				pcall(NeverYieldStats.save)
			end
			if NeverYieldStats.render then
				pcall(NeverYieldStats.render)
			end
		end
	end)
	pcall(NeverYieldStats.save)
end

addcmd('stats',{'mystats','nystats'},function(args, speaker)
	local tab = args[1] and args[1]:lower()
	local valid = false
	for _, info in ipairs(NeverYieldStats.tabs) do
		if info[1] == tab then valid = true end
	end
	NeverYieldStats.page = 1
	local ok, err = pcall(NeverYieldStats.open, valid and tab or nil)
	if not ok then
		pcall(NeverYieldStats.close)
		notify('Stats', 'Could not open: ' .. tostring(err))
	end
end)

addcmd('killcount',{'kd'},function(args, speaker)
	local t, s = NeverYieldStats.data.totals, NeverYieldStats.session
	notify('Kills', 'This server: ' .. s.countedKills .. ' kills, ' .. s.countedDeaths .. ' deaths (streak ' .. s.streak .. '). All time: '
		.. NeverYieldStats.num(t.kills) .. ' kills, ' .. NeverYieldStats.num(t.deaths) .. ' deaths, K/D ' .. NeverYieldStats.kd(t.kills, t.deaths)
		.. ', best streak ' .. t.bestStreak .. '.', 10)
end)

addcmd('mychats',{'chatsearch'},function(args, speaker)
	local filter = getstring(1, args)
	NeverYieldStats.page = 1
	local ok, err = pcall(NeverYieldStats.open, "chat", filter ~= "" and filter or nil)
	if not ok then
		pcall(NeverYieldStats.close)
		notify('Stats', 'Could not open: ' .. tostring(err))
	end
end)

addcmd('chatlogging',{'logchat'},function(args, speaker)
	local settings = NeverYieldStats.data.settings
	local choice = args[1] and args[1]:lower()
	if choice == "on" then
		settings.logOthers = true
	elseif choice == "off" then
		settings.logOthers = false
	else
		settings.logOthers = not settings.logOthers
	end
	NeverYieldStats.dirty = true
	notify('Chat Logging', settings.logOthers and 'Saving everyone\'s messages too (yours are always saved).' or 'Only saving your own messages now.')
end)

addcmd('statsexport',{'copystats'},function(args, speaker)
	pcall(NeverYieldStats.tick)
	local lines = {"NeverYield stats (" .. os.date("%Y-%m-%d") .. ")"}
	for _, tab in ipairs({"overview", "combat"}) do
		for _, line in ipairs(NeverYieldStats.lines(tab)) do
			table.insert(lines, line[1] .. ": " .. (line[2] or ""))
		end
	end
	table.insert(lines, "Top games:")
	for i, line in ipairs(NeverYieldStats.lines("games")) do
		if i > 5 then break end
		table.insert(lines, "  " .. line[1] .. " - " .. (line[2] or ""))
	end
	toClipboard(table.concat(lines, "\n"))
end)

addcmd('statssave',{},function(args, speaker)
	notify('Stats', NeverYieldStats.save() and 'Saved to NeverYield_stats.json in your executor workspace.' or 'Could not save (your executor needs writefile).')
end)

addcmd('statsreset',{},function(args, speaker)
	if not args[1] or args[1]:lower() ~= "confirm" then
		notify('Stats', 'This wipes all your stats. Type statsreset confirm to do it (a backup file is kept).', 8)
		return
	end
	pcall(function()
		writefile("NeverYield_stats_backup_" .. os.date("%Y%m%d_%H%M%S") .. ".json", HttpService:JSONEncode(NeverYieldStats.data), true)
	end)
	NeverYieldStats.data = NeverYieldStats.blank()
	NeverYieldStats.data.totals.sessions = 1
	NeverYieldStats.game().visits = 1
	NeverYieldStats.save()
	if NeverYieldStats.render then
		pcall(NeverYieldStats.render)
	end
	notify('Stats', 'Stats reset. The old ones were backed up in your workspace folder.')
end)

pcall(NeverYieldStats.start)
-- ================== END NEVERYIELD STATS ==================

addcmd('removecmd',{'deletecmd'},function(args, speaker)
	removecmd(args[1])
end)

addcmd("debug", {}, function(args, speaker)
    _G.IY_DEBUG = parseBoolean(args[1], true)
    return _G.IY_DEBUG and "Enabled" or "Disabled"
end)

if IsOnMobile then
	local QuickCapture = Instance.new("TextButton")
	local UICorner = Instance.new("UICorner")
	QuickCapture.Name = randomString()
	QuickCapture.Parent = PARENT
	QuickCapture.BackgroundColor3 = Color3.fromRGB(32, 18, 64)
	QuickCapture.BackgroundTransparency = 0.14
	QuickCapture.Position = UDim2.new(0.489, 0, 0, 0)
	QuickCapture.Size = UDim2.new(0, 32, 0, 33)
	QuickCapture.Font = Enum.Font.SourceSansBold
	QuickCapture.Text = "IY"
	QuickCapture.TextColor3 = Color3.fromRGB(255, 255, 255)
	QuickCapture.TextSize = 20
	QuickCapture.TextWrapped = true
	QuickCapture.ZIndex = 10
	QuickCapture.Draggable = true
	UICorner.Name = randomString()
	UICorner.CornerRadius = UDim.new(0.5, 0)
	UICorner.Parent = QuickCapture
	QuickCapture.MouseButton1Click:Connect(function()
		Cmdbar:CaptureFocus()
		maximizeHolder()
	end)
	table.insert(shade1, QuickCapture)
	table.insert(text1, QuickCapture)
end

pcall(function() Scale.Scale = math.max(Holder.AbsoluteSize.X / 1920, guiScale) end)
Scale.Parent = ScaledHolder
ScaledHolder.Size = UDim2.fromScale(1 / Scale.Scale, 1 / Scale.Scale)
Scale:GetPropertyChangedSignal("Scale"):Connect(function()
	ScaledHolder.Size = UDim2.fromScale(1 / Scale.Scale, 1 / Scale.Scale)
	for _, v in ScaledHolder:GetDescendants() do
		if v:IsA("GuiObject") and v.Visible then
			v.Visible = false
			v.Visible = true
		end
	end
end)

updateColors(currentShade1,shade1)
updateColors(currentShade2,shade2)
updateColors(currentShade3,shade3)
updateColors(currentText1,text1)
updateColors(currentText2,text2)
updateColors(currentScroll,scroll)

if PluginsTable ~= nil or PluginsTable ~= {} then
	FindPlugins(PluginsTable)
end

-- Events
eventEditor.RegisterEvent("OnExecute")
eventEditor.RegisterEvent("OnSpawn",{
	{Type="Player",Name="Player Filter ($1)"}
})
eventEditor.RegisterEvent("OnDied",{
	{Type="Player",Name="Player Filter ($1)"}
})
eventEditor.RegisterEvent("OnDamage",{
	{Type="Player",Name="Player Filter ($1)"},
	{Type="Number",Name="Below Health ($2)"}
})
eventEditor.RegisterEvent("OnKilled",{
	{Type="Player",Name="Victim Player ($1)"},
	{Type="Player",Name="Killer Player ($2)",Default = 1}
})
eventEditor.RegisterEvent("OnJoin",{
	{Type="Player",Name="Player Filter ($1)",Default = 1}
})
eventEditor.RegisterEvent("OnLeave",{
	{Type="Player",Name="Player Filter ($1)",Default = 1}
})
eventEditor.RegisterEvent("OnChatted",{
	{Type="Player",Name="Player Filter ($1)",Default = 1},
	{Type="String",Name="Message Filter ($2)"}
})

function hookCharEvents(plr, instant)
	task.spawn(function()
		local char = plr.Character
		if not char then return end

		local humanoid = char:WaitForChild("Humanoid", 10)
		if not humanoid or not humanoid:IsA("Humanoid") then return end

		local oldHealth = humanoid.Health
		humanoid.HealthChanged:Connect(function(health)
			local change = math.abs(oldHealth - health)
			if oldHealth > health then
				eventEditor.FireEvent("OnDamage", plr.Name, tonumber(health))
			end
			oldHealth = health
		end)

		humanoid.Died:Connect(function()
			eventEditor.FireEvent("OnDied", plr.Name)

			local killedBy = humanoid:FindFirstChild("creator")
			if killedBy and killedBy:IsA("ObjectValue") and killedBy.Value and killedBy.Value.Parent then
				eventEditor.FireEvent("OnKilled", plr.Name, killedBy.Name)
			end
		end)
	end)
end

Players.PlayerAdded:Connect(function(plr)
	eventEditor.FireEvent("OnJoin",plr.Name)
	if isLegacyChat then plr.Chatted:Connect(function(msg) eventEditor.FireEvent("OnChatted",tostring(plr),msg) end) end
	plr.CharacterAdded:Connect(function() eventEditor.FireEvent("OnSpawn",tostring(plr)) hookCharEvents(plr) end)
	JoinLog(plr)
	if isLegacyChat then ChatLog(plr) end
	if ESPenabled then
		repeat wait(1) until plr.Character and getRoot(plr.Character)
		ESP(plr)
	end
	if CHMSenabled then
		repeat wait(1) until plr.Character and getRoot(plr.Character)
		CHMS(plr)
	end
end)

if not isLegacyChat then
	TextChatService.MessageReceived:Connect(function(textChatMessage)
		if textChatMessage.TextSource and textChatMessage.Status ~= Enum.TextChatMessageStatus.InvalidTextChannelPermissions then
			local player = Players:GetPlayerByUserId(textChatMessage.TextSource.UserId)
			if not player then return end

            local message = textChatMessage.Text
            pcall(function() if textChatMessage.WasRewritten == true then message = "(rephrased) " .. textChatMessage.RewrittenText end end)

			if logsEnabled == true then
				CreateLabel(player.Name, message)
			end
			if player.UserId == Players.LocalPlayer.UserId then
				do_exec(message, Players.LocalPlayer)
			end
			eventEditor.FireEvent("OnChatted", player.Name, message)
			sendChatWebhook(player, message)
		end
	end)
end

for _, plr in pairs(Players:GetPlayers()) do
	pcall(function()
		plr.CharacterAdded:Connect(function() eventEditor.FireEvent("OnSpawn", tostring(plr)) hookCharEvents(plr) end)
		hookCharEvents(plr)
	end)
end

if spawnCmds and #spawnCmds > 0 then
	for i,v in pairs(spawnCmds) do
		eventEditor.AddCmd("OnSpawn",{v.COMMAND or "",{0},v.DELAY or 0})
	end
	updatesaves()
end

if loadedEventData then eventEditor.LoadData(loadedEventData) end
eventEditor.Refresh()

eventEditor.FireEvent("OnExecute")

if aliases and #aliases > 0 then
	local cmdMap = {}
	for i,v in pairs(cmds) do
		cmdMap[v.NAME:lower()] = v
		for _,alias in pairs(v.ALIAS) do
			cmdMap[alias:lower()] = v
		end
	end
	for i = 1, #aliases do
		local cmd = string.lower(aliases[i].CMD)
		local alias = string.lower(aliases[i].ALIAS)
		if cmdMap[cmd] then
			customAlias[alias] = cmdMap[cmd]
		end
	end
	refreshaliases()
end

IYMouse.Move:Connect(checkTT)

CaptureService.CaptureBegan:Connect(function()
	PARENT.Enabled = false
end)

CaptureService.CaptureEnded:Connect(function()
	task.delay(0.1, function()
		PARENT.Enabled = true
	end)
end)

task.spawn(function()
	local success, latestVersionInfo = pcall(function() 
		local versionJson = game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/version")
		return HttpService:JSONDecode(versionJson)
	end)

	if success then
		if currentVersion ~= latestVersionInfo.Version then
			notify("Outdated", "Get the new version at infyiff.github.io")
		end

		if latestVersionInfo.Announcement and latestVersionInfo.Announcement ~= "" then
			local AnnGUI = Instance.new("Frame")
			local background = Instance.new("Frame")
			local TextBox = Instance.new("TextLabel")
			local shadow = Instance.new("Frame")
			local PopupText = Instance.new("TextLabel")
			local Exit = Instance.new("TextButton")
			local ExitImage = Instance.new("ImageLabel")

			AnnGUI.Name = randomString()
			AnnGUI.Parent = ScaledHolder
			AnnGUI.Active = true
			AnnGUI.BackgroundTransparency = 1
			AnnGUI.Position = UDim2.new(0.5, -180, 0, -500)
			AnnGUI.Size = UDim2.new(0, 360, 0, 20)
			AnnGUI.ZIndex = 10

			background.Name = "background"
			background.Parent = AnnGUI
			background.Active = true
			background.BackgroundColor3 = currentShade1
			background.BorderSizePixel = 0
			background.Position = UDim2.new(0, 0, 0, 20)
			background.Size = UDim2.new(0, 360, 0, 150)
			background.ZIndex = 10

			TextBox.Parent = background
			TextBox.BackgroundTransparency = 1
			TextBox.Position = UDim2.new(0, 5, 0, 5)
			TextBox.Size = UDim2.new(0, 350, 0, 140)
			TextBox.Font = Enum.Font.SourceSans
			TextBox.TextSize = 18
			TextBox.TextWrapped = true
			TextBox.Text = latestVersionInfo.Announcement
			TextBox.TextColor3 = currentText1
			TextBox.TextXAlignment = Enum.TextXAlignment.Left
			TextBox.TextYAlignment = Enum.TextYAlignment.Top
			TextBox.ZIndex = 10

			shadow.Name = "shadow"
			shadow.Parent = AnnGUI
			shadow.BackgroundColor3 = currentShade2
			shadow.BorderSizePixel = 0
			shadow.Size = UDim2.new(0, 360, 0, 20)
			shadow.ZIndex = 10

			PopupText.Name = "PopupText"
			PopupText.Parent = shadow
			PopupText.BackgroundTransparency = 1
			PopupText.Size = UDim2.new(1, 0, 0.95, 0)
			PopupText.ZIndex = 10
			PopupText.Font = Enum.Font.SourceSans
			PopupText.TextSize = 14
			PopupText.Text = "Server Announcement"
			PopupText.TextColor3 = currentText1
			PopupText.TextWrapped = true

			Exit.Name = "Exit"
			Exit.Parent = shadow
			Exit.BackgroundTransparency = 1
			Exit.Position = UDim2.new(1, -20, 0, 0)
			Exit.Size = UDim2.new(0, 20, 0, 20)
			Exit.Text = ""
			Exit.ZIndex = 10

			ExitImage.Parent = Exit
			ExitImage.BackgroundColor3 = Color3.new(1, 1, 1)
			ExitImage.BackgroundTransparency = 1
			ExitImage.Position = UDim2.new(0, 5, 0, 5)
			ExitImage.Size = UDim2.new(0, 10, 0, 10)
			ExitImage.Image = getcustomasset("infiniteyield/assets/close.png")
			ExitImage.ZIndex = 10

			task.wait(1)
			AnnGUI:TweenPosition(UDim2.new(0.5, -180, 0, 150), "InOut", "Quart", 0.5, true, nil)

			Exit.MouseButton1Click:Connect(function()
				AnnGUI:TweenPosition(UDim2.new(0.5, -180, 0, -500), "InOut", "Quart", 0.5, true, nil)
				task.wait(0.6)
				AnnGUI:Destroy()
			end)
		end
	end
end)

NeverYieldPortal.maximize = maximizeHolder
maximizeHolder = function(...)
	pcall(NeverYieldPortal.pulse)
	return NeverYieldPortal.maximize(...)
end

task.spawn(function()
    task.wait()
    NeverYieldPortal.open()
    pcall(function()
        Credits:TweenPosition(UDim2.new(0, 0, 0.9, 0), "Out", "Quart", 0.2)
        Logo:TweenSizeAndPosition(UDim2.new(0, 175, 0, 175), UDim2.new(0, 37, 0, 45), "Out", "Quart", 0.3)
        task.wait(1)
        local OutInfo = TweenInfo.new(1.6809, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0)
        TweenService:Create(Logo, OutInfo, {ImageTransparency = 1}):Play()
        TweenService:Create(IntroBackground, OutInfo, {BackgroundTransparency = 1}):Play()
        Credits:TweenPosition(UDim2.new(0, 0, 0.9, 30), "Out", "Quart", 0.2)
        task.wait(0.2)
    end)
    Logo:Destroy()
    Credits:Destroy()
    IntroBackground:Destroy()
    minimizeHolder()
end)
