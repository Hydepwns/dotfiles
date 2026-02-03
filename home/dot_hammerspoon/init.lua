-- DROO's Hammerspoon Config
-- Window management, app launching, and productivity tools
-- =============================================================================

local hotkey = require("hs.hotkey")
local window = require("hs.window")
local screen = require("hs.screen")
local grid = require("hs.grid")
local alert = require("hs.alert")
local application = require("hs.application")
local caffeinate = require("hs.caffeinate")
local pasteboard = require("hs.pasteboard")
local chooser = require("hs.chooser")
local timer = require("hs.timer")

-- =============================================================================
-- Configuration
-- =============================================================================

-- Grid setup
grid.setGrid("12x12")
grid.setMargins({ 0, 0 })

-- Hotkey modifiers
local hyper = { "cmd", "alt", "ctrl", "shift" }
local meh = { "cmd", "alt", "ctrl" }
local super = { "cmd", "alt" }

-- Alert styling (Synthwave84 inspired)
alert.defaultStyle.strokeColor = { white = 0, alpha = 0 }
alert.defaultStyle.fillColor = { hex = "#262335", alpha = 0.95 }
alert.defaultStyle.textColor = { hex = "#ff7edb" }
alert.defaultStyle.textFont = "Monaspace Neon"
alert.defaultStyle.textSize = 18
alert.defaultStyle.radius = 8
alert.defaultStyle.fadeInDuration = 0.1
alert.defaultStyle.fadeOutDuration = 0.1

-- =============================================================================
-- Window Management
-- =============================================================================

-- Snap window to grid position
local function snapTo(x, y, w, h)
    local win = window.focusedWindow()
    if win then
        grid.set(win, hs.geometry.rect(x, y, w, h))
    end
end

-- Common layouts
local layouts = {
    left_half = function() snapTo(0, 0, 6, 12) end,
    right_half = function() snapTo(6, 0, 6, 12) end,
    left_third = function() snapTo(0, 0, 4, 12) end,
    center_third = function() snapTo(4, 0, 4, 12) end,
    right_third = function() snapTo(8, 0, 4, 12) end,
    left_two_thirds = function() snapTo(0, 0, 8, 12) end,
    right_two_thirds = function() snapTo(4, 0, 8, 12) end,
    top_half = function() snapTo(0, 0, 12, 6) end,
    bottom_half = function() snapTo(0, 6, 12, 6) end,
    full = function() snapTo(0, 0, 12, 12) end,
    center = function() snapTo(2, 1, 8, 10) end,
    -- Quadrants
    top_left = function() snapTo(0, 0, 6, 6) end,
    top_right = function() snapTo(6, 0, 6, 6) end,
    bottom_left = function() snapTo(0, 6, 6, 6) end,
    bottom_right = function() snapTo(6, 6, 6, 6) end,
}

-- Move window to next/prev screen
local function moveToScreen(direction)
    local win = window.focusedWindow()
    if not win then return end

    local screens = screen.allScreens()
    local currentScreen = win:screen()
    local currentIndex = hs.fnutils.indexOf(screens, currentScreen) or 1

    local targetIndex
    if direction == "next" then
        targetIndex = currentIndex + 1
        if targetIndex > #screens then targetIndex = 1 end
    else
        targetIndex = currentIndex - 1
        if targetIndex < 1 then targetIndex = #screens end
    end

    win:moveToScreen(screens[targetIndex])
    alert.show("Screen " .. targetIndex)
end

-- =============================================================================
-- Window Keybindings
-- =============================================================================

-- Halves (super + arrows)
hotkey.bind(super, "left", layouts.left_half)
hotkey.bind(super, "right", layouts.right_half)
hotkey.bind(super, "up", layouts.full)
hotkey.bind(super, "down", layouts.center)

-- Thirds (super + 1-3)
hotkey.bind(super, "1", layouts.left_third)
hotkey.bind(super, "2", layouts.center_third)
hotkey.bind(super, "3", layouts.right_third)

-- Two-thirds (super + 4-5)
hotkey.bind(super, "4", layouts.left_two_thirds)
hotkey.bind(super, "5", layouts.right_two_thirds)

-- Quadrants (meh + arrows)
hotkey.bind(meh, "left", layouts.top_left)
hotkey.bind(meh, "right", layouts.top_right)
hotkey.bind(meh, "up", layouts.bottom_left)
hotkey.bind(meh, "down", layouts.bottom_right)

-- Move between screens (hyper + h/l)
hotkey.bind(hyper, "h", function() moveToScreen("prev") end)
hotkey.bind(hyper, "l", function() moveToScreen("next") end)

-- =============================================================================
-- Application Launching
-- =============================================================================

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

-- App shortcuts (super + letter)
hotkey.bind(super, "t", function() launchOrFocus("Ghostty") end)
hotkey.bind(super, "e", function() launchOrFocus("Zed") end)
hotkey.bind(super, "b", function() launchOrFocus("Brave Browser") end)
hotkey.bind(super, "f", function() launchOrFocus("Firefox") end)
hotkey.bind(super, "d", function() launchOrFocus("Discord") end)
hotkey.bind(super, "s", function() launchOrFocus("Slack") end)
hotkey.bind(super, "m", function() launchOrFocus("Messages") end)
hotkey.bind(super, "n", function() launchOrFocus("Notes") end)

-- =============================================================================
-- Application Chooser
-- =============================================================================

local appChooser = nil

local function showAppChooser()
    local apps = {
        { text = "Ghostty", subText = "Terminal", app = "Ghostty" },
        { text = "Zed", subText = "Editor", app = "Zed" },
        { text = "Neovim", subText = "Editor", app = "Neovim" },
        { text = "Brave", subText = "Browser", app = "Brave Browser" },
        { text = "Firefox", subText = "Browser", app = "Firefox" },
        { text = "Discord", subText = "Chat", app = "Discord" },
        { text = "Slack", subText = "Chat", app = "Slack" },
        { text = "1Password", subText = "Secrets", app = "1Password" },
        { text = "Docker", subText = "Containers", app = "Docker" },
        { text = "OrbStack", subText = "Containers", app = "OrbStack" },
    }

    appChooser = chooser.new(function(choice)
        if choice then
            launchOrFocus(choice.app)
        end
    end)

    appChooser:choices(apps)
    appChooser:searchSubText(true)
    appChooser:show()
end

hotkey.bind(super, "space", showAppChooser)

-- =============================================================================
-- Clipboard History
-- =============================================================================

local clipHistory = {}
local maxClipHistory = 20

local function saveClip()
    local content = pasteboard.getContents()
    if content and content ~= "" then
        -- Avoid duplicates
        for i, v in ipairs(clipHistory) do
            if v == content then
                table.remove(clipHistory, i)
                break
            end
        end
        table.insert(clipHistory, 1, content)
        if #clipHistory > maxClipHistory then
            table.remove(clipHistory)
        end
    end
end

local function showClipHistory()
    if #clipHistory == 0 then
        alert.show("Clipboard empty")
        return
    end

    local choices = {}
    for i, content in ipairs(clipHistory) do
        local preview = string.gsub(content, "\n", " ")
        preview = string.sub(preview, 1, 60)
        if #content > 60 then preview = preview .. "..." end
        table.insert(choices, { text = preview, full = content })
    end

    local clipChooser = chooser.new(function(choice)
        if choice then
            pasteboard.setContents(choice.full)
            alert.show("Copied")
        end
    end)

    clipChooser:choices(choices)
    clipChooser:show()
end

timer.doEvery(1, saveClip)
hotkey.bind(super, "v", showClipHistory)

-- =============================================================================
-- Quick Actions
-- =============================================================================

-- Lock screen
hotkey.bind(hyper, "q", function()
    caffeinate.lockScreen()
end)

-- Toggle dark mode
hotkey.bind(hyper, "d", function()
    hs.osascript.applescript([[
        tell application "System Events"
            tell appearance preferences
                set dark mode to not dark mode
            end tell
        end tell
    ]])
    alert.show("Dark mode toggled")
end)

-- Caffeinate (prevent sleep)
local caffeine = nil
hotkey.bind(hyper, "c", function()
    if caffeine then
        caffeine:stop()
        caffeine = nil
        alert.show("Sleep enabled")
    else
        caffeine = caffeinate.set("displayIdle", true, true)
        alert.show("Caffeinated")
    end
end)

-- =============================================================================
-- Window Hints
-- =============================================================================

hotkey.bind(super, "w", function()
    hs.hints.windowHints()
end)

-- =============================================================================
-- Reload Config
-- =============================================================================

hotkey.bind(hyper, "r", function()
    hs.reload()
end)

hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", function()
    hs.reload()
end):start()

-- =============================================================================
-- Menu Bar
-- =============================================================================

local menu = hs.menubar.new()
menu:setTitle("HS")
menu:setMenu({
    { title = "Windows", disabled = true },
    { title = "  Left Half", fn = layouts.left_half },
    { title = "  Right Half", fn = layouts.right_half },
    { title = "  Full Screen", fn = layouts.full },
    { title = "  Center", fn = layouts.center },
    { title = "-" },
    { title = "Apps", disabled = true },
    { title = "  Ghostty", fn = function() launchOrFocus("Ghostty") end },
    { title = "  Zed", fn = function() launchOrFocus("Zed") end },
    { title = "  Browser", fn = function() launchOrFocus("Brave Browser") end },
    { title = "-" },
    { title = "Tools", disabled = true },
    { title = "  Clipboard History", fn = showClipHistory },
    { title = "  Lock Screen", fn = function() caffeinate.lockScreen() end },
    { title = "-" },
    { title = "Reload", fn = function() hs.reload() end },
})

-- =============================================================================
-- Startup
-- =============================================================================

alert.show("Hammerspoon loaded", 1)

print([[
=== Hammerspoon Shortcuts ===
Window Management:
  Cmd+Alt + arrows    : Halves/Full/Center
  Cmd+Alt + 1-5       : Thirds
  Cmd+Alt+Ctrl + arr  : Quadrants
  Hyper + h/l         : Move to screen

Apps:
  Cmd+Alt + t         : Ghostty
  Cmd+Alt + e         : Zed
  Cmd+Alt + b         : Brave
  Cmd+Alt + space     : App chooser

Utilities:
  Cmd+Alt + v         : Clipboard history
  Cmd+Alt + w         : Window hints
  Hyper + q           : Lock screen
  Hyper + c           : Caffeinate
  Hyper + d           : Toggle dark mode
  Hyper + r           : Reload config
=============================
]])
