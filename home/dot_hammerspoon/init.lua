-- Hammerspoon configuration for DROO's dotfiles
-- Customized for development workflow and productivity

-- Load required modules
local hs = require("hs")
local hotkey = require("hs.hotkey")
local window = require("hs.window")
local screen = require("hs.screen")
local grid = require("hs.grid")
local alert = require("hs.alert")
local fnutils = require("hs.fnutils")
local keycodes = require("hs.keycodes")
local application = require("hs.application")

-- Configure grid
grid.setGrid('12x12')
grid.setMargins({0, 0})

-- Set up hotkey mods
local hyper = {"cmd", "alt", "ctrl", "shift"}
local cmd_alt = {"cmd", "alt"}
local cmd_shift = {"cmd", "shift"}

-- Window management functions
local function moveWindowToScreen(direction)
    local win = window.focusedWindow()
    if win then
        local currentScreen = win:screen()
        local screens = screen.allScreens()
        local currentIndex = fnutils.indexOf(screens, currentScreen)
        local targetIndex = nil

        if direction == "left" then
            targetIndex = currentIndex - 1
            if targetIndex < 1 then targetIndex = #screens end
        elseif direction == "right" then
            targetIndex = currentIndex + 1
            if targetIndex > #screens then targetIndex = 1 end
        end

        if targetIndex then
            win:moveToScreen(screens[targetIndex])
            alert.show("Moved window to screen " .. targetIndex)
        end
    end
end

-- Grid positioning functions
local function snapToGrid(x, y, w, h)
    local win = window.focusedWindow()
    if win then
        grid.set(win, hs.geometry.rect(x, y, w, h))
    end
end

-- Development-specific window layouts
local function setupDevLayout()
    local win = window.focusedWindow()
    if win then
        -- Left: Terminal/Editor (8/12 width)
        -- Right: Browser/Docs (4/12 width)
        grid.set(win, hs.geometry.rect(0, 0, 8, 12))
        alert.show("Dev Layout: Terminal/Editor")
    end
end

local function setupFullScreenLayout()
    local win = window.focusedWindow()
    if win then
        grid.set(win, hs.geometry.rect(0, 0, 12, 12))
        alert.show("Full Screen")
    end
end

local function setupSplitLayout()
    local win = window.focusedWindow()
    if win then
        -- Left half
        grid.set(win, hs.geometry.rect(0, 0, 6, 12))
        alert.show("Split Layout: Left Half")
    end
end

-- Application launcher functions
local function launchOrFocus(appName)
    local app = application.get(appName)
    if app then
        if app:isFrontmost() then
            app:hide()
        else
            app:activate()
        end
    else
        application.launchOrFocus(appName)
    end
end

-- Development tools launcher
local function launchDevTools()
    local devApps = {
        "kitty",
        "Cursor",
        "Neovim",
        "Zed",
        "Brave Browser",
        "Firefox Developer Edition",
    }

    for _, appName in ipairs(devApps) do
        local app = application.get(appName)
        if app then
            app:activate()
            break
        end
    end
end

-- Quick terminal access
local function quickTerminal()
    local term = application.get("kitty")
    if term then
        term:activate()
    else
        application.launchOrFocus("iTerm2")
    end
end

-- Quick code editor access
local function quickEditor()
    local editor = application.get("Zed") or application.get("Cursor")
    if editor then
        editor:activate()
    else
        application.launchOrFocus("Neovim")
    end
end

-- Quick Zed access
local function quickZed()
    local zed = application.get("Zed")
    if zed then
        zed:activate()
    else
        application.launchOrFocus("Zed")
    end
end

-- Browser management
local function cycleBrowsers()
    local browsers = {"Brave Browser", "Firefox Developer Edition", "Ladybird"}
    local currentApp = application.frontmostApplication()
    local currentIndex = fnutils.indexOf(browsers, currentApp:name())

    local nextIndex = 1
    if currentIndex then
        nextIndex = currentIndex + 1
        if nextIndex > #browsers then nextIndex = 1 end
    end

    launchOrFocus(browsers[nextIndex])
end

-- System utilities
local function toggleWiFi()
    local wifi = hs.wifi.interfaceDetails()
    if wifi then
        hs.wifi.setPower(false)
        alert.show("WiFi: OFF")
    else
        hs.wifi.setPower(true)
        alert.show("WiFi: ON")
    end
end

local function toggleBluetooth()
    local bt = hs.bluetooth.state()
    if bt == "PoweredOn" then
        hs.bluetooth.power(false)
        alert.show("Bluetooth: OFF")
    else
        hs.bluetooth.power(true)
        alert.show("Bluetooth: ON")
    end
end

-- Clipboard management
local clipboardHistory = {}
local maxClipboardHistory = 10

local function saveToClipboardHistory()
    local content = hs.pasteboard.getContents()
    if content and content ~= "" then
        table.insert(clipboardHistory, 1, content)
        if #clipboardHistory > maxClipboardHistory then
            table.remove(clipboardHistory)
        end
    end
end

local function showClipboardHistory()
    if #clipboardHistory > 0 then
        local choices = {}
        for i, content in ipairs(clipboardHistory) do
            local preview = string.sub(content, 1, 50)
            if #content > 50 then preview = preview .. "..." end
            table.insert(choices, {text = preview, subText = content})
        end

        local chooser = hs.chooser.new(function(choice)
            if choice then
                hs.pasteboard.setContents(choice.subText)
                alert.show("Copied to clipboard")
            end
        end)
        chooser:choices(choices)
        chooser:show()
    end
end

-- Monitor clipboard changes
hs.timer.doEvery(1, saveToClipboardHistory)

-- Hotkey bindings
-- Window management
hotkey.bind(hyper, "h", function() moveWindowToScreen("left") end)
hotkey.bind(hyper, "l", function() moveWindowToScreen("right") end)
hotkey.bind(hyper, "j", function() window.focusedWindow():focusWindowWest() end)
hotkey.bind(hyper, "k", function() window.focusedWindow():focusWindowEast() end)

-- Grid positioning
hotkey.bind(cmd_alt, "1", function() snapToGrid(0, 0, 6, 12) end)   -- Left half
hotkey.bind(cmd_alt, "2", function() snapToGrid(6, 0, 6, 12) end)   -- Right half
hotkey.bind(cmd_alt, "3", function() snapToGrid(0, 0, 8, 12) end)   -- Left 2/3
hotkey.bind(cmd_alt, "4", function() snapToGrid(8, 0, 4, 12) end)   -- Right 1/3
hotkey.bind(cmd_alt, "5", function() snapToGrid(0, 0, 4, 12) end)   -- Left 1/3
hotkey.bind(cmd_alt, "6", function() snapToGrid(4, 0, 8, 12) end)   -- Right 2/3

-- Layout presets
hotkey.bind(cmd_alt, "d", setupDevLayout)
hotkey.bind(cmd_alt, "f", setupFullScreenLayout)
hotkey.bind(cmd_alt, "s", setupSplitLayout)

-- Application launchers
hotkey.bind(cmd_alt, "t", quickTerminal)
hotkey.bind(cmd_alt, "e", quickEditor)
hotkey.bind(cmd_alt, "z", quickZed)
hotkey.bind(cmd_alt, "b", cycleBrowsers)
hotkey.bind(cmd_alt, "a", launchDevTools)

-- System utilities
hotkey.bind(cmd_alt, "w", toggleWiFi)
hotkey.bind(cmd_alt, "b", toggleBluetooth)

-- Clipboard management
hotkey.bind(cmd_alt, "v", showClipboardHistory)

-- Quick app switching
hotkey.bind(cmd_alt, "1", function() launchOrFocus("Cursor") end)
hotkey.bind(cmd_alt, "2", function() launchOrFocus("kitty") end)
hotkey.bind(cmd_alt, "3", function() launchOrFocus("Brave Browser") end)
hotkey.bind(cmd_alt, "4", function() launchOrFocus("Firefox Developer Edition") end)
hotkey.bind(cmd_alt, "5", function() launchOrFocus("Neovim") end)

-- Development-specific shortcuts
hotkey.bind(cmd_alt, "d", function() launchOrFocus("Docker") end)
hotkey.bind(cmd_alt, "o", function() launchOrFocus("OrbStack") end)
hotkey.bind(cmd_alt, "p", function() launchOrFocus("Postman") end)

-- Utility functions
local function reloadConfig()
    hs.reload()
    alert.show("Hammerspoon config reloaded")
end

hotkey.bind(cmd_alt, "r", reloadConfig)

-- Auto-reload on file changes
hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()

-- Status indicator
local statusMenu = hs.menubar.new()
statusMenu:setTitle("🔨")
statusMenu:setMenu({
    {title = "Reload Config", fn = reloadConfig},
    {title = "-"},
    {title = "Dev Layout", fn = setupDevLayout},
    {title = "Full Screen", fn = setupFullScreenLayout},
    {title = "Split Layout", fn = setupSplitLayout},
    {title = "-"},
    {title = "Terminal", fn = quickTerminal},
    {title = "Editor", fn = quickEditor},
    {title = "Browsers", fn = cycleBrowsers},
    {title = "-"},
    {title = "Clipboard History", fn = showClipboardHistory},
    {title = "-"},
    {title = "Quit", fn = function() hs.quit() end}
})

-- Welcome message
alert.show("Hammerspoon loaded! 🔨", 2)

-- Print available shortcuts
print("=== Hammerspoon Shortcuts ===")
print("Window Management:")
print("  Cmd+Alt+Ctrl+Shift + h/l: Move window between screens")
print("  Cmd+Alt+Ctrl+Shift + j/k: Focus window left/right")
print("")
print("Grid Positioning:")
print("  Cmd+Alt + 1-6: Snap to grid positions")
print("  Cmd+Alt + d: Development layout")
print("  Cmd+Alt + f: Full screen")
print("  Cmd+Alt + s: Split layout")
print("")
print("Application Launchers:")
print("  Cmd+Alt + t: Terminal")
print("  Cmd+Alt + e: Code Editor")
print("  Cmd+Alt + z: Zed Editor")
print("  Cmd+Alt + b: Cycle browsers")
print("  Cmd+Alt + a: Launch dev tools")
print("")
print("System:")
print("  Cmd+Alt + w: Toggle WiFi")
print("  Cmd+Alt + v: Clipboard history")
print("  Cmd+Alt + r: Reload config")
print("=============================")
