--[[--
Autorotate par l'Atelier — suit l'orientation Android (interrupteur système).

@module koplugin.autorotate
--]]--

local Device = require("device")

if not Device:isAndroid() then
    return { disabled = true }
end

local Dispatcher = require("dispatcher")
local WidgetContainer = require("ui/widget/container/widgetcontainer")
local android = require("android")
local ffi = require("ffi")
local C = ffi.C
local _ = require("gettext")

local SETTING_KEY = "autorotate_enabled"

local Autorotate = WidgetContainer:extend{
    name = "autorotate",
    is_doc_only = false,
}

function Autorotate:isEnabled()
    return G_reader_settings:isTrue(SETTING_KEY)
end

function Autorotate:setEnabled(enabled)
    G_reader_settings:saveSetting(SETTING_KEY, enabled)
    if enabled then
        self:enable()
    else
        self:disable()
    end
end

function Autorotate:enable()
    android.orientation.set(C.ASCREEN_ORIENTATION_USER)
end

function Autorotate:disable()
    local mode = Device.screen:getRotationMode()
    Device.screen:setRotationMode(mode)
end

function Autorotate:toggle()
    self:setEnabled(not self:isEnabled())
end

function Autorotate:onDispatcherRegisterActions()
    Dispatcher:registerAction("autorotate_toggle", {
        category = "none",
        event = "AutorotateToggle",
        title = _("Autorotate (Atelier)"),
        general = true,
    })
end

function Autorotate:init()
    self:onDispatcherRegisterActions()
    self.ui.menu:registerToMainMenu(self)
    if self:isEnabled() then
        self:enable()
    end
end

function Autorotate:addToMainMenu(menu_items)
    menu_items.autorotate = {
        text = _("Autorotate par l'Atelier"),
        sorting_hint = "more_tools",
        checked_func = function()
            return self:isEnabled()
        end,
        callback = function()
            self:toggle()
        end,
    }
end

function Autorotate:onAutorotateToggle()
    self:toggle()
    return true
end

function Autorotate:onResume()
    if self:isEnabled() then
        self:enable()
    end
    return false
end

return Autorotate
