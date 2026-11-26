local keybinds = CreateFrame("Frame", "WoWControllerKeybinds")
keybinds:RegisterEvent("PLAYER_LOGIN")
keybinds:RegisterEvent("PLAYER_LOGOUT")
keybinds:SetScript("OnEvent", function()
  if event == "PLAYER_LOGIN" then
    -- save previous keybinds
    keybinds.previous_bindings = GetCurrentBindingSet()

    -- overwrite keybindings on login
    -- SetBinding("m", "TOGGLEWORLDMAP")                 -- Window (TabKey)
    -- SetBinding("c", "WOWCONTROL1")                    -- Trackpad-Up: Inventory + Character
    -- SetBinding("l", "WOWCONTROL2")                    -- Trackpad-Right: QuestLog
    -- SetBinding("n", "WOWCONTROL3")                    -- Trackpad-Down: Talents & Social
    -- SetBinding("p", "WOWCONTROL4")                    -- Trackpad-Left: Spellbook
    -- SetBinding("MOUSEWHEELDOWN", "TARGETPREVIOUSENEMY") -- L1
    -- SetBinding("MOUSEWHEELUP", "TARGETNEARESTENEMY")    -- R1
    SetBinding("1", "ACTIONBUTTON1")                    -- Y
    SetBinding("2", "ACTIONBUTTON2")                    -- X
    SetBinding("3", "ACTIONBUTTON3")                    -- B
    SetBinding("4", "ACTIONBUTTON4")                    -- Right-Stick click
    -- -- Jump                                             -- A
    SetBinding("UP", "ACTIONBUTTON5")                    -- Arrow-Up
    SetBinding("6", "ACTIONBUTTON6")                   -- Arrow-Right
    SetBinding("RIGHT", "ACTIONBUTTON7")                   -- Arrow-Down
    SetBinding("DOWN", "ACTIONBUTTON8")                   -- Arrow-Down
    SetBinding("LEFT", "ACTIONBUTTON9")                   -- Left-Stick-click
    SaveBindings(GetCurrentBindingSet())

    -- notify the player for keybind changes
    DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00WoW|cffffffffController: Initialized Keybinds")
  elseif event == "PLAYER_LOGOUT" and keybinds.previous_bindings then
    SaveBindings(keybinds.previous_bindings)
    DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00WoW|cffffffffController: Old Keybinds Restored")
  end
end)

-- save to main frame
WoWController.keybinds = keybinds
