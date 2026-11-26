local _G = _G or getfenv(0)

local resizes = {
  MainMenuBar, MainMenuExpBar, MainMenuBarMaxLevelBar,
  ReputationWatchBar, ReputationWatchStatusBar,
}

local frames = {
  BonusActionBarTexture0, BonusActionBarTexture1,
  ShapeshiftBarLeft, ShapeshiftBarMiddle, ShapeshiftBarRight,
  MainMenuMaxLevelBar2, MainMenuMaxLevelBar3,
}

local textures = {
  MainMenuBarTexture0, MainMenuBarTexture1,
  MainMenuXPBarTexture2, MainMenuXPBarTexture3,
  ReputationWatchBarTexture2, ReputationWatchBarTexture3,
  ReputationXPBarTexture2, ReputationXPBarTexture3,
  SlidingActionBarTexture0, SlidingActionBarTexture1,
}

local normtextures = {
  ShapeshiftButton1, ShapeshiftButton2,
  ShapeshiftButton3, ShapeshiftButton4,
  ShapeshiftButton5, ShapeshiftButton6,
}

-- general function to hide textures and frames
local function hide(frame, texture)
  if not frame then return end

  if texture and texture == 1 and frame.SetTexture then
    frame:SetTexture("")
  elseif texture and texture == 2 and frame.SetNormalTexture then
    frame:SetNormalTexture("")
  else
    frame:ClearAllPoints()
    frame.Show = function() return end
    frame:Hide()
  end
end

-- reduce actionbar size
for id, frame in pairs(resizes) do frame:SetWidth(488) end

  -- hide reduced frames
for id, frame in pairs(frames) do hide(frame) end

-- clear reduced textures
for id, frame in pairs(textures) do hide(frame, 1) end

-- clear some button textures
for id, frame in pairs(normtextures) do hide(frame, 2) end

-- create a jump button
ActionButtonJmp = CreateFrame("CheckButton", "ActionButtonJmp", MainMenuBarArtFrame, "ActionButtonTemplate")

-- raise the default mouseover tooltip (~189px) vertical
local tooltip_default_anchor = GameTooltip_SetDefaultAnchor
function GameTooltip_SetDefaultAnchor(tooltip, parent)
  tooltip_default_anchor(tooltip, parent)
  tooltip:ClearAllPoints()
  tooltip:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT",
    -CONTAINER_OFFSET_X - 13,
    CONTAINER_OFFSET_Y + 189)
end

local ui = CreateFrame("Frame", "WoWControllerUI", UIParent)
ui:RegisterEvent("PLAYER_ENTERING_WORLD")
ui:SetScript("OnEvent", function()
  -- update ui when frame positions get managed
  ui.manage_positions_hook = UIParent_ManageFramePositions
  UIParent_ManageFramePositions = ui.manage_positions
  ui:UnregisterAllEvents()
end)

ui:SetScript("OnUpdate", function()
  -- update ui once the first frame is shown
  UIParent_ManageFramePositions()
  ui.chat_layout_normal()
  this:Hide()
end)

local actionhide = CreateFrame("Frame", "WoWControllerActionHide", BonusActionBarFrame)
actionhide.buttons = {}

actionhide:SetScript("OnShow", function()
  for button, bonus in pairs(this.buttons) do
    if button:GetID() ~= 0 then
      button:EnableMouse(bonus)
      button:SetAlpha(bonus)
    end
  end
end)

actionhide:SetScript("OnHide", function()
  for button, bonus in pairs(this.buttons) do
    if button:GetID() ~= 0 then
      button:EnableMouse(bonus == 0 and 1 or 0)
      button:SetAlpha(bonus == 0 and 1 or 0)
    end
  end
end)

ui.manage_button = function(self, frame, pos, x, y, image, bonus)
  if frame and tonumber(frame) then
    self:manage_button(_G["ActionButton" .. frame], pos, x, y, image)
    self:manage_button(_G["BonusActionButton" .. frame], pos, x, y, image, true)
    return
  end

  if pos == "DISABLED" then
    frame.Show = function() return end
    frame:ClearAllPoints()
    frame:Hide()
    return
  end

  -- add button to actionhide registry
  actionhide.buttons[frame] = bonus and 1 or 0

  -- set button scale and set position
  local scale = image == "" and 1 or 1.2
  local revscale = scale == 1 and 1.2 or 1
  frame:SetScale(scale)
  frame:ClearAllPoints()
  frame:SetPoint("CENTER", UIParent, pos, x*revscale, y*revscale)

  -- hide keybind text
  _G[frame:GetName().."HotKey"]:Hide()

  -- add keybind icon
  if not frame.keybind_icon then
    frame.keybind_icon = CreateFrame("Frame", nil, frame)
    frame.keybind_icon:SetFrameLevel(255)
    frame.keybind_icon:SetAllPoints(frame)

    frame.keybind_icon.tex = frame.keybind_icon:CreateTexture(nil, "OVERLAY")
    frame.keybind_icon.tex:SetTexture(image)
    frame.keybind_icon.tex:SetPoint("TOPRIGHT", frame.keybind_icon, "TOPRIGHT", 0, 0)
    frame.keybind_icon.tex:SetWidth(16)
    frame.keybind_icon.tex:SetHeight(16)

    -- handle out of range as desaturation of keybind and icon
    _G[frame:GetName().."HotKey"].SetVertexColor = function(self, r, g, b, a)
      if r == 1.0 and g == 0.1 and b == 0.1 then
        _G[frame:GetName().."Icon"]:SetDesaturated(true)
        frame.keybind_icon.tex:SetDesaturated(true)
      else
        _G[frame:GetName().."Icon"]:SetDesaturated(false)
        frame.keybind_icon.tex:SetDesaturated(false)
      end
    end
  end
end

ui.manage_jump_button = function(self, frame)
  local icon = _G[frame:GetName().."Icon"]
  local name = _G[frame:GetName().."Name"]

  icon:Show()
  icon:SetTexture("Interface\\Icons\\inv_gizmo_rocketboot_01")
  icon.SetTexture = function() return end
  icon.Hide = function() return end

  name:SetPoint("BOTTOM", 0, 5)
  name:SetText("Jump")
  name.SetText = function() return end

  frame:Show()
  frame.Hide = function() return end
  frame.GetID = function() return 0 end
end

local buttonmap = {
   -- dummy jump button
   { ActionButtonJmp, "BOTTOMRIGHT", -220,  45, "Interface\\AddOns\\WoWController\\img\\a" },

   -- right controls
   { 1, "BOTTOMRIGHT", -220, 135, "Interface\\AddOns\\WoWController\\img\\y" },
   { 2, "BOTTOMRIGHT", -265,  90, "Interface\\AddOns\\WoWController\\img\\x" },
   { 3, "BOTTOMRIGHT", -175,  90, "Interface\\AddOns\\WoWController\\img\\b" },
   { 4, "BOTTOMRIGHT", -220,  90, "" },

   -- left controls
   { 5, "BOTTOMLEFT",  220, 135, "Interface\\AddOns\\WoWController\\img\\up" },
   { 6, "BOTTOMLEFT",  220,  90, "" },

   -- This is my personal preference where the last 3 buttons of an actionbar
   -- are usually mapped and mandatory skills for me. If you want to continue
   -- the line, change this to 7,8,9 and change the disabled ones to 10,11,12.
   -- also make sure to update the keybinds.lua accordingly.
   { 7, "BOTTOMLEFT", 265,  90, "Interface\\AddOns\\WoWController\\img\\right" },
   { 8, "BOTTOMLEFT", 220,  45, "Interface\\AddOns\\WoWController\\img\\down" },
   { 9, "BOTTOMLEFT", 175,  90, "Interface\\AddOns\\WoWController\\img\\left" },

   -- disabled
   { 10, "DISABLED" },
   { 11, "DISABLED" },
   { 12, "DISABLED" },
}

-- snapshot a frame's current anchors/scale/size
ui.chat_save_position = function(frame)
  local saved = { points = {}, scale = frame:GetScale(), width = frame:GetWidth(), height = frame:GetHeight() }
  local n = frame:GetNumPoints()
  for i = 1, n do
    local point, relativeTo, relativePoint, x, y = frame:GetPoint(i)
    table.insert(saved.points, { point = point, relativeTo = relativeTo or "UIParent", relativePoint = relativePoint or point, x = x or 0, y = y or 0 })
  end
  return saved
end

-- restore a snapshot made by ui.chat_save_position
ui.chat_restore_position = function(frame, saved)
  if not saved then return end
  frame:ClearAllPoints()
  for i = 1, table.getn(saved.points) do
    local p = saved.points[i]
    frame:SetPoint(p.point, p.relativeTo, p.relativePoint, p.x, p.y)
  end
  if saved.scale then frame:SetScale(saved.scale) end
  if saved.width then frame:SetWidth(saved.width) end
  if saved.height then frame:SetHeight(saved.height) end
end

-- chat window layout: 5cm inset from the right edge, above the right action buttons
ui.chat_layout_normal = function()
  ChatFrameEditBox:ClearAllPoints()
  ChatFrameEditBox:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -189, 426)
  ChatFrameEditBox:SetWidth(300)
  ChatFrameEditBox:SetScale(1)

  if ChatFrame1.oskSavedPos then
    -- restore the position it had just before maximizing
    ui.chat_restore_position(ChatFrame1, ChatFrame1.oskSavedPos)
    ChatFrame1.oskSavedPos = nil
  elseif not ChatFrame1.oskNormalApplied then
    ChatFrame1:SetScale(1)
    ChatFrame1:ClearAllPoints()
    ChatFrame1:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -189, 246)
    ChatFrame1:SetWidth(300)
    ChatFrame1:SetHeight(180)
  end
  ChatFrame1.oskNormalApplied = 1

  if WoWControllerKeyboard then WoWControllerKeyboard:Hide() end
end

-- chat window layout: enlarged for the on-screen keyboard
ui.chat_layout_zoom = function()
  ui.chat_save_layers()
  if not ChatFrame1.oskSavedPos then
    ChatFrame1.oskSavedPos = ui.chat_save_position(ChatFrame1)
  end
  ChatFrame1.oskNormalApplied = nil
  ChatFrameEditBox:ClearAllPoints()
  ChatFrameEditBox:SetPoint("TOP", UIParent, "TOP", 0, -10)
  ChatFrameEditBox:SetWidth(300)
  ChatFrameEditBox:SetScale(2)

  ChatFrame1:SetScale(2)
  ChatFrame1:ClearAllPoints()
  ChatFrame1:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0, 0)
  ChatFrame1:SetPoint("BOTTOMRIGHT", UIParent, "RIGHT", 0, -14)

  if WoWControllerKeyboard then
    WoWControllerKeyboard:Show()
    WoWControllerKeyboard:SetFrameLevel(50)
    WoWControllerKeyboard:Raise()
  end
end

-- remember the default draw order so the zoom can be undone
ui.chat_save_layers = function()
  if ChatFrame1.oskStrata then return end

  ChatFrame1.oskStrata = ChatFrame1:GetFrameStrata()
  ChatFrame1.oskLevel = ChatFrame1:GetFrameLevel()
  ChatFrame1Tab.oskStrata = ChatFrame1Tab:GetFrameStrata()
  ChatFrame1Tab.oskLevel = ChatFrame1Tab:GetFrameLevel()
  ChatFrameEditBox.oskStrata = ChatFrameEditBox:GetFrameStrata()
  ChatFrameEditBox.oskLevel = ChatFrameEditBox:GetFrameLevel()
  ChatFrame1.oskHelper.oskStrata = ChatFrame1.oskHelper:GetFrameStrata()
  ChatFrame1.oskHelper.oskLevel = ChatFrame1.oskHelper:GetFrameLevel()
end

-- lift the chat above the normal UI while the keyboard is open
ui.chat_raise = function()
  -- FULLSCREEN is above DIALOG/HIGH/MEDIUM/BACKGROUND, tooltips stay on top
  ChatFrame1:SetFrameStrata("FULLSCREEN")
  ChatFrame1:SetFrameLevel(20)
  ChatFrame1:Raise()

  ChatFrame1Tab:SetFrameStrata("FULLSCREEN")
  ChatFrame1Tab:SetFrameLevel(ChatFrame1:GetFrameLevel() + 1)

  ChatFrameEditBox:SetFrameStrata("FULLSCREEN")
  ChatFrameEditBox:SetFrameLevel(ChatFrame1:GetFrameLevel() + 2)
  ChatFrameEditBox:Raise()

  ChatFrame1.oskHelper:SetFrameStrata("FULLSCREEN")
  ChatFrame1.oskHelper:SetFrameLevel(ChatFrame1:GetFrameLevel() - 1)
end

ui.chat_restore_layers = function()
  if not ChatFrame1.oskStrata then return end

  ChatFrame1:SetFrameStrata(ChatFrame1.oskStrata)
  ChatFrame1:SetFrameLevel(ChatFrame1.oskLevel)
  ChatFrame1Tab:SetFrameStrata(ChatFrame1Tab.oskStrata)
  ChatFrame1Tab:SetFrameLevel(ChatFrame1Tab.oskLevel)
  ChatFrameEditBox:SetFrameStrata(ChatFrameEditBox.oskStrata)
  ChatFrameEditBox:SetFrameLevel(ChatFrameEditBox.oskLevel)
  ChatFrame1.oskHelper:SetFrameStrata(ChatFrame1.oskHelper.oskStrata)
  ChatFrame1.oskHelper:SetFrameLevel(ChatFrame1.oskHelper.oskLevel)
end

-- click anywhere on the chat window to toggle the on-screen keyboard
ChatFrame1.oskHelper = CreateFrame("Button", nil, UIParent)
ChatFrame1.oskHelper:SetFrameStrata("BACKGROUND")
ChatFrame1.oskHelper:SetAllPoints(ChatFrame1)
ChatFrame1.oskHelper:SetScript("OnClick", function()
  if not ChatFrameEditBox:IsVisible() then
    ChatFrameEditBox:Show()
    ChatFrameEditBox:Raise()
  else
    ChatFrameEditBox:Hide()
  end
end)

ChatFrame1.oskHelper:SetScript("OnUpdate", function()
  if ChatFrameEditBox:IsVisible() and this.state ~= 1 then
    ui.chat_save_layers()
    ui.chat_layout_zoom()

    FCF_SetWindowColor(ChatFrame1, 0,0,0)
    FCF_SetWindowAlpha(ChatFrame1, .5)

    ui.chat_raise()
    this.state = 1
  elseif not ChatFrameEditBox:IsVisible() and this.state ~= 0 then
    ui.chat_restore_layers()
    ui.chat_layout_normal()

    FCF_SetWindowColor(ChatFrame1, 0,0,0)
    FCF_SetWindowAlpha(ChatFrame1, 0)

    this.state = 0
  end
end)

-- on-screen keyboard shown when chat is zoomed/fullscreen
local kb = CreateFrame("Frame", "WoWControllerKeyboard", UIParent)
kb:SetFrameStrata("FULLSCREEN")
kb:SetWidth(640)
kb:SetHeight(248)
kb:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, -66)
kb:EnableKeyboard(true)
kb:Hide()
kb.keys = {}
kb.selected = 1
kb.columns = 10
kb.controller_mode = true

kb.highlight = CreateFrame("Frame", nil, kb)
kb.highlight:SetFrameLevel(60)
kb.highlight:SetBackdrop({ edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 8, insets = { left = 0, right = 0, top = 0, bottom = 0 } })
kb.highlight:SetBackdropBorderColor(1, 1, 0, 1)
kb.highlight:Hide()

local function kb_editbox()
  local eb = ChatFrameEditBox or ChatFrame1EditBox
  if eb then eb:Show() end
  return eb
end

local function kb_refocus(eb)
  if not eb then return end
  if kb.controller_mode then eb:ClearFocus() else eb:SetFocus() end
end

local function key_insert(text)
  local eb = kb_editbox()
  if not eb then return end
  if eb.Insert then
    eb:Insert(text)
  else
    eb:SetText(eb:GetText() .. text)
  end
  kb_refocus(eb)
end

local function key_backspace()
  local eb = kb_editbox()
  if not eb then return end
  eb:SetText(string.sub(eb:GetText() or "", 1, -2))
  kb_refocus(eb)
end

local function key_enter()
  local eb = ChatFrameEditBox or ChatFrame1EditBox
  if not eb then return end
  if ChatEdit_SendText then ChatEdit_SendText(eb, 1) end
  eb:SetText("")
  eb:ClearFocus()
  eb:Hide()
  if WoWControllerKeyboard then WoWControllerKeyboard:Hide() end
  if kb.highlight then kb.highlight:Hide() end
  if ui.chat_restore_layers then ui.chat_restore_layers() end
  if ui.chat_layout_normal then ui.chat_layout_normal() end
end

local function make_key(text, w, h, x, y, onclick)
  local b = CreateFrame("Button", nil, kb, "UIPanelButtonTemplate")
  b:SetWidth(w)
  b:SetHeight(h)
  b:SetPoint("TOPLEFT", kb, "TOPLEFT", x, y)
  b:SetText(text)
  local action = onclick or function() key_insert(text) end
  b.osk_action = action
  b:SetScript("OnClick", action)
  table.insert(kb.keys, b)
  return b
end

local kb_rows = {
  {"z","x","c","v","b","n","m",",",".","/"},
  {"a","s","d","f","g","h","j","k","l",";"},
  {"q","w","e","r","t","y","u","i","o","p"},
  {"1","2","3","4","5","6","7","8","9","0"},
}

local keyW, keyH, pad = 60, 44, 4
for r = 1, table.getn(kb_rows) do
  local row = kb_rows[r]
  for c = 1, table.getn(row) do
    local k = row[c]
    local x = pad + (c - 1) * (keyW + pad)
    local y = pad + (r - 1) * (keyH + pad)
    make_key(k, keyW, keyH, x, y, function() key_insert(k) end)
  end
end

local bottomY = pad + table.getn(kb_rows) * (keyH + pad)
make_key("Space", 200, keyH, pad, bottomY, function() key_insert(" ") end)
make_key("Backspace", 150, keyH, pad + 200 + pad, bottomY, key_backspace)
make_key("Enter", 150, keyH, pad + 200 + pad + 150 + pad, bottomY, key_enter)

local modeY = bottomY + keyH + pad
make_key("say", 150, keyH, pad, modeY, function() key_insert("/say ") end)
make_key("group", 150, keyH, pad + 150 + pad, modeY, function() key_insert("/group ") end)
make_key("raid", 150, keyH, pad + (150 + pad) * 2, modeY, function() key_insert("/raid ") end)
make_key("guild", 150, keyH, pad + (150 + pad) * 3, modeY, function() key_insert("/guild ") end)
make_key("Close", 150, keyH, pad, modeY + keyH + pad, function() ui.osk_cancel() end)
kb:SetHeight(modeY + keyH * 2 + pad * 3)

ui.osk_update_highlight = function()
  local b = kb.keys[kb.selected]
  if not b then kb.highlight:Hide() return end
  kb.highlight:ClearAllPoints()
  kb.highlight:SetAllPoints(b)
  kb.highlight:SetFrameLevel(60)
  kb.highlight:Show()
end

ui.osk_move = function(dx, dy)
  local n = table.getn(kb.keys)
  if n == 0 then return end
  if dx == 1 then
    kb.selected = kb.selected + 1
    if kb.selected > n then kb.selected = 1 end
  elseif dx == -1 then
    kb.selected = kb.selected - 1
    if kb.selected < 1 then kb.selected = n end
  elseif dy == 1 then
    kb.selected = kb.selected - kb.columns
    if kb.selected < 1 then kb.selected = 1 end
  elseif dy == -1 then
    kb.selected = kb.selected + kb.columns
    if kb.selected > n then kb.selected = n end
  end
  ui.osk_update_highlight()
end

ui.osk_pick = function()
  local b = kb.keys[kb.selected]
  if not b or not b.osk_action then return end
  b.osk_action()
  local eb = ChatFrameEditBox or ChatFrame1EditBox
  if kb.controller_mode and eb then eb:ClearFocus() end
  ui.osk_update_highlight()
end

ui.osk_cancel = function()
  local eb = ChatFrameEditBox or ChatFrame1EditBox
  if eb then eb:ClearFocus(); eb:Hide() end
  if WoWControllerKeyboard then WoWControllerKeyboard:Hide() end
  if kb.highlight then kb.highlight:Hide() end
  if ui.chat_restore_layers then ui.chat_restore_layers() end
  if ui.chat_layout_normal then ui.chat_layout_normal() end
end

kb:SetScript("OnShow", function()
  kb.selected = 1
  local eb = ChatFrameEditBox or ChatFrame1EditBox
  if eb then eb:ClearFocus() end
  if ui.osk_update_highlight then ui.osk_update_highlight() end
end)

kb:SetScript("OnKeyDown", function()
  if not WoWControllerKeyboard:IsVisible() then return end
  local key = arg1
  if key == "LEFT" or key == "a" then ui.osk_move(-1, 0)
  elseif key == "RIGHT" or key == "d" then ui.osk_move(1, 0)
  elseif key == "DOWN" or key == "w" then ui.osk_move(0, 1)
  elseif key == "UP" or key == "s" then ui.osk_move(0, -1)
  elseif key == "SPACE" then ui.osk_pick()
  elseif key == "2" then key_insert(" ")
  elseif key == "1" then key_backspace()
  elseif key == "ESCAPE" or key == "3" then ui.osk_cancel()
  end
end)

ui.manage_positions = function(a1, a2, a3)
  -- run original function first
  ui.manage_positions_hook(a1, a2, a3)

  -- reapply the chat layout after Blizzard repositions the frames
  if ChatFrame1.oskHelper.state == 1 then
    ui.chat_layout_zoom()
  else
    ui.chat_layout_normal()
  end

  -- move and skin all buttons
  for id, button in pairs(buttonmap) do
    ui:manage_button(unpack(button))
  end

  -- skin jump button
  ui:manage_jump_button(ActionButtonJmp)

  -- move pet action bar
  local anchor = MainMenuBarArtFrame
  anchor = MultiBarBottomLeft:IsVisible() and MultiBarBottomLeft or anchor
  anchor = MultiBarBottomRight:IsVisible() and MultiBarBottomRight or anchor
  anchor = ShapeshiftBarFrame:IsVisible() and ShapeshiftBarFrame or anchor
  PetActionBarFrame:ClearAllPoints()
  PetActionBarFrame:SetPoint("BOTTOM", anchor, "TOP", 0, 3)

  -- move shapeshift bar
  local anchor = MainMenuBarArtFrame
  anchor = MultiBarBottomLeft:IsVisible() and MultiBarBottomLeft or anchor
  anchor = MultiBarBottomRight:IsVisible() and MultiBarBottomRight or anchor
  ShapeshiftBarFrame:ClearAllPoints()
  ShapeshiftBarFrame:SetPoint("BOTTOMLEFT", anchor, "TOPLEFT", 15, -5)

  -- move normal action bars
  MultiBarBottomLeft:ClearAllPoints()
  MultiBarBottomLeft:SetPoint("BOTTOM", MainMenuBar, "TOP", 0, 20)

  MultiBarBottomRight:ClearAllPoints()
  MultiBarBottomRight:SetPoint("BOTTOM", MultiBarBottomLeft, "TOP", 0, 5)

  -- experience bar
  MainMenuXPBarTexture0:SetPoint("LEFT", MainMenuExpBar, "LEFT")
  MainMenuXPBarTexture1:SetPoint("RIGHT", MainMenuExpBar, "RIGHT")

  -- reputation bar
  ReputationWatchBar:SetPoint("BOTTOM", MainMenuExpBar, "TOP", 0, 0)
  ReputationWatchBarTexture0:SetPoint("LEFT", ReputationWatchBar, "LEFT")
  ReputationWatchBarTexture1:SetPoint("RIGHT", ReputationWatchBar, "RIGHT")

  -- move elements for reduced actionbar size
  MainMenuMaxLevelBar0:SetPoint("LEFT", MainMenuBarArtFrame, "LEFT")
  MainMenuBarTexture2:SetPoint("LEFT", MainMenuBarArtFrame, "LEFT")
  MainMenuBarTexture3:SetPoint("RIGHT", MainMenuBarArtFrame, "RIGHT")

  ActionBarDownButton:SetPoint("BOTTOMLEFT", MainMenuBarArtFrame, "BOTTOMLEFT", -5, -5)
  ActionBarUpButton:SetPoint("TOPLEFT", MainMenuBarArtFrame, "TOPLEFT", -5, -5)
  MainMenuBarPageNumber:SetPoint("LEFT", MainMenuBarArtFrame, "LEFT", 25, -5)
  CharacterMicroButton:SetPoint("LEFT", MainMenuBarArtFrame, "LEFT", 38, 0)

  MainMenuBarLeftEndCap:SetPoint("RIGHT", MainMenuBarArtFrame, "LEFT", 30, 0)
  MainMenuBarRightEndCap:SetPoint("LEFT", MainMenuBarArtFrame, "RIGHT", -30, 0)

  -- move pfQuest arrow if existing
  if pfQuest and pfQuest.route and pfQuest.route.arrow then
    pfQuest.route.arrow:SetPoint("CENTER", 0, -120)
  end
end

-- save to main frame
WoWController.ui = ui
