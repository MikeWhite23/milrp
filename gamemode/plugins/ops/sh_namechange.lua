if SERVER then
	util.AddNetworkString("mrpOpsNamechange")
	util.AddNetworkString("mrpOpsDoNamechange")

	net.Receive("mrpOpsDoNamechange", function(len, ply)
		if not ply.NameChangeForced then
			return
		end

		local charName = net.ReadString()

		local canUse, output = mrp.CanUseName(charName)

		if not canUse then
			ply:Kick("Inappropriate roleplay name.")
			return
		end

		ply:SetSyncVar(SYNC_RPNAME, output, true)
		ply:Notify("You have changed your name to "..output..".")

		ply.NameChangeForced = nil
	end)
else
	local nameChangeText = "You have been forced to change your name by a game moderator as it was deemed inappropriate.\nPlease change your name below to something more sutable.\nEXAMPLE: John Doe"
	net.Receive("mrpOpsNamechange", function()
		local panel = vgui.Create("DFrame")
		panel:SetSize(500, 170)
		panel:SetTitle("mrp")
		panel:Center()
		panel:ShowCloseButton(false)
		panel:MakePopup()

		local notice = vgui.Create("DLabel", panel)
		notice:SetPos(5, 30)
		notice:SetText(nameChangeText)
		notice:SizeToContents()

		local newName = vgui.Create("DLabel", panel)
		newName:SetPos(15, 85)
		newName:SetText("New name:")
		newName:SetFont("mrp-Font18-Shadow")
		newName:SizeToContents()

		local entry = vgui.Create("DTextEntry", panel)
		entry:SetPos(15, 105)
		entry:SetSize(470, 20)

		local done = vgui.Create("DButton", panel)
		done:SetPos(15, 135)
		done:SetSize(80, 25)
		done:SetText("Done")

		function done:DoClick()
			local clear, rejectReason = mrp.CanUseName(entry:GetValue())

			if not clear then
				Derma_Message(rejectReason, "mrp", "OK")
			else
				net.Start("mrpOpsDoNamechange")
				net.WriteString(entry:GetValue())
				net.SendToServer()

				panel:Remove()
			end
		end
	end)
end

local changeNameCommand =  {
	description = "Force changes the specified players name.",
	requiresArg = true,
	adminOnly = true,
	onRun = function(ply, arg, rawText)
        local name = arg[1]
		local plyTarget = mrp:FindPlayer(name)

		if plyTarget then
			net.Start("mrpOpsNamechange")
			net.Send(plyTarget)

			plyTarget.NameChangeForced = true
			ply:Notify(plyTarget:Name().." has been forced name-changed.")
		else
			return ply:Notify("Could not find player: "..tostring(name))
		end
	end
}

mrp.RegisterChatCommand("/forcenamechange", changeNameCommand)