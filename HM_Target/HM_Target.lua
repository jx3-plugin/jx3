--
-- ���������Ŀ����ʾ��ǿ�������ߡ�����ָʾ��������
--

HM_Target = {
	bEnable = true,				-- �Ƿ���ǿ��ʾĿ��
	bEnableTTarget = false,	-- �Ƿ���ǿ��ʾĿ���Ŀ��
	bEnableLM = true,			-- �Ƿ���ǿѪ������
	bConnect2 = false,				-- ����Ŀ��׷����
	bTTConnect = false,		-- ��ʾĿ����Ŀ���Ŀ��������
	bConnFoot = false,			-- ��ʾ�ڽ��ϣ�Ĭ��ͷ�ϣ�
	nConnWidth = 1,				-- �����߿��
	nConnAlpha = 100,			-- �����߲�͸����
	tConnColor = { 255, 0, 0 },	-- ��ɫ
	bEnableChannel = true,		-- ��ʾ��������
	bEnableBreak = true,			-- ͻ���ɴ�϶���������� NPC��
	bAdjustBar = true,				-- ���ƶ���λ��
	bDirection = true,				-- ����Ŀ�귽��ָʾ
	bDirDist = true,					-- ��ʾĿ�����
	bDirText = true,					-- ��ʾĿ��״̬����
	bDirBuff = true,					-- ��ʾĿ�������BUFF
	bDirLarge = true,					-- ������ʾָ��ͼ��
	tDirAnchor = {},					-- Ŀ��ָ���λ��
	bAdjustBuff = false,				-- ����Ŀ�� BUFF �Ŵ�
	nSizeBuff = 35,					-- Ŀ�� BUFF �³ߴ�
	nSizeTTBuff = 30,				-- Ŀ���Ŀ�� BUFF ��С
}
HM.RegisterCustomData("HM_Target")

---------------------------------------------------------------------
-- ���غ����ͱ���
---------------------------------------------------------------------
local _HM_Target = {
	bChange = false,
	bChangeTTarget = false,
	szIniFile = "interface\\HM\\HM_Target\\HM_Target.ini",
	tChannel = {},	-- �������ܼ�¼
}

-- equal
_HM_Target.AboutEqual = function(dw1, dw2)
	return math.abs(dw1 - dw2) < 3
end

-- get channel data
_HM_Target.GetSkillChannelState = function(dwID)
	local rec = _HM_Target.tChannel[dwID]
	if rec then
		local nFrame = GetLogicFrameCount() - rec[2]
		if nFrame < rec[3] then
			local fP = 1 - nFrame / rec[3]
			return rec[1], fP, rec[4]
		end
	end
end

-- connect line settting menu
_HM_Target.GetConnMenu = function()
	local m0 = {
		{
			szOption = _L["Set connected line color"],
			bColorTable = true, bNotChangeSelfColor = false, rgb = HM_Target.tConnColor,
			fnChangeColor = function(data, r, g, b)
				HM_Target.tConnColor = { r, g, b }
				_HM_Target.OnUpdateConnLine()
			end
		},
	}
	local m1 = { szOption = _L["Set connected line width"], }
	for i = 1, 5 do
		local m2 = { szOption = tostring(i), bCheck = true, bMCheck = true }
		m2.bChecked = HM_Target.nConnWidth == i
		m2.fnAction = function()
			HM_Target.nConnWidth = i
			_HM_Target.OnUpdateConnLine()
		end
		table.insert(m1, m2)
	end
	table.insert(m0, m1)
	m1 = { szOption = _L["Connected line opacity"], }
	for i = 60, 200, 20 do
		local m2 = { szOption = tostring(i / 2), bCheck = true, bMCheck = true }
		m2.bChecked = HM_Target.nConnAlpha == i
		m2.fnAction = function()
			HM_Target.nConnAlpha = i
			_HM_Target.OnUpdateConnLine()
		end
		table.insert(m1, m2)
	end
	table.insert(m0, m1)
	return m0
end

-- enhance target panel
_HM_Target.UpdateName = function(frame, bRestore)
	local tar = GetTargetHandle(frame.dwType, frame.dwID)
	if not tar then
		return
	end
	local text = frame:Lookup("", "Text_Target")
	local szName = HM.GetTargetName(tar)
	if HM_About.CheckNameEx(szName)
		and not HM.IsParty(frame.dwID)
		and not HM_About.CheckNameEx(GetClientPlayer().szName)
	then
		local n = math.ceil(GetLogicFrameCount() / 480) % 4
		if n == 1 then
			szName = _L["Who am I ^o^"]
		elseif n == 2 then
			szName = _L["Not tell you @_@"]
		elseif n == 3 then
			szName = _L["FAKE - "] .. GetClientPlayer().szName
		else
			szName = _L["OUTER GUEST ~_~"]
		end
	elseif not bRestore then
		szName = string.format("%.1f", HM.GetDistance(tar)) .. _L["-"] .. szName
		if frame.dwType == TARGET.PLAYER then
			local mnt = tar.GetKungfuMount()
			if mnt then
				szName = szName .. _L["-"] .. string.sub(HM.GetSkillName(mnt.dwSkillID, mnt.dwLevel), 1, 4)
			end
		elseif frame.dwType == TARGET.NPC and tar.dwDropTargetPlayerID then
			if tar.dwDropTargetPlayerID == 0 then
				szName = szName .. _L["-"] .. "NEW"
			else
				local drp = GetPlayer(tar.dwDropTargetPlayerID)
				if drp then
					szName = szName .. _L["-"] .. drp.szName
				end
			end
		end
	end
	text:SetFontColor(GetForceFontColor(frame.dwID, GetClientPlayer().dwID))
	text:SetText(szName)
end

-- adjust buff pos
_HM_Target.AdjustBuffPos = function(frame, delta)
	local tName = { "Handle_Buff", "Handle_Debuff" }
	local hTotal = frame:Lookup("", "")
	for k, v in ipairs(tName) do
		local h = hTotal:Lookup(v)
		if h then
			local nX, nY = h:GetRelPos()
			if h.nRelPosY then
				h.nRelPosY = h.nRelPosY + delta
			end
			h:SetRelPos(nX, nY + delta)
		end
	end
	hTotal:FormatAllItemPos()
end

-- update action
_HM_Target.UpdateAction = function(frame)
	local tar = GetTargetHandle(frame.dwType, frame.dwID)
	local handle = frame:Lookup("", "Handle_Bar")
	local text = handle:Lookup("Text_Name")
	-- FIXME: Target.bShowActionBar
	if not tar then
		return handle:Hide()
	end
	-- check broken
	local _, dwID, _, _ = tar.GetSkillPrepareState()
	if dwID ~= 0 then
		text:SetFontColor(255, 255, 255)
		if HM_Target.bEnableBreak and not HM.CanBrokenSkill(dwID) then
			text:SetFontColor(180, 180, 180)
		end
	end
	-- check channel
	if HM_Target.bEnableChannel and frame.dwType == TARGET.PLAYER and tar.GetOTActionState() == 2 then
		local szSkill, fP, dwID = _HM_Target.GetSkillChannelState(tar.dwID)
		if szSkill then
			handle:SetAlpha(255)
			handle:Show()
			handle:Lookup("Image_Progress"):Show()
			handle:Lookup("Image_FlashS"):Hide()
			handle:Lookup("Image_FlashF"):Hide()
			text:SetText(szSkill)
			text:SetFontColor(255, 255, 255)
			if HM_Target.bEnableBreak and not HM.CanBrokenSkill(dwID) then
				text:SetFontColor(180, 180, 180)
			end
			handle:Lookup("Image_Progress"):SetPercentage(fP)
			-- FIXME��ACTION_STATE.FADE  = 5
			handle.nActionState = 5
		end
	end
	-- adjust pos
	if HM_Target.bAdjustBar then
		if not handle.nOrigX then
			handle.nOrigX, handle.nOrigY = handle:GetRelPos()
		end
		if not frame.bAdjustBar ~= not handle:IsVisible() then
			local _, nH = handle:GetSize()
			frame.bAdjustBar = handle:IsVisible()
			if frame.bAdjustBar then
				local hBuff = frame:Lookup("", "Handle_Buff")
				if hBuff then
					handle:SetRelPos(hBuff:GetRelPos())
				end
				_HM_Target.AdjustBuffPos(frame, nH)
			else
				_HM_Target.AdjustBuffPos(frame, 0 - nH)
			end
		end
	elseif handle.nOrigX then
		local _, nH = handle:GetSize()
		handle:SetRelPos(handle.nOrigX, handle.nOrigY)
		handle.nOrigX = nil
		if handle:IsVisible() then
			_HM_Target.AdjustBuffPos(frame, 0 - nH)
		end
	end
end

-- refresh buff size
_HM_Target.RefreshBuff = function(bTTarget)
	if bTTarget == nil or bTTarget == false then
		local frame = Station.Lookup("Normal/Target")
		if frame then
			frame.bBuffSizeAdjusted = false
			if frame.dwBuffMgrID then
				local nSize = HM_Target.bAdjustBuff and HM_Target.nSizeBuff or 20
				_HM_Target.InitBuffPos(frame, nSize)
				_HM_Target.InitBuffSize(frame.dwBuffMgrID, nSize)
				frame.bBuffSizeAdjusted = true
			end
		end
	end
	if bTTarget == nil or bTTarget == true then
		local frame = Station.Lookup("Normal/TargetTarget")
		if frame then
			frame.bBuffSizeAdjusted = false
			if frame.dwMgrID then
				local nSize = HM_Target.bAdjustBuff and HM_Target.nSizeTTBuff or 20
				_HM_Target.InitBuffPos(frame, nSize)
				_HM_Target.InitBuffSize(frame.dwMgrID, nSize)
				frame.bBuffSizeAdjusted = true
			end
		end
	end
end

-- adjust buff position
_HM_Target.InitBuffPos = function(frame, nSize)
	local nY, tName = nil, { "Buff", "TextBuff", "Debuff", "TextDebuff" }
	for _, v in ipairs(tName) do
		local h = frame:Lookup("", "Handle_" .. v)
		if h then
			if not nY then
				_, nY = h:GetRelPos()
				if h.nRelPosY then
					nY = h.nRelPosY
				end
			else
				local nX, _ = h:GetRelPos()
				if h.nRelPosX then
					nX = h.nRelPosX
					h.nRelPosY = nY
				end
				h:SetRelPos(nX, nY)
				if v == "Debuff" then
					local h2 = frame:Lookup("", "Image_DebuffBG")
					if h2 then
						h2:SetRelPos(nX, nY)
						h2.nRelPosY = nY
					end
				end
			end
			if v == "Buff" or v == "Debuff" then
				nY = nY + nSize + 5
				if v == "Debuff" then
					frame:Lookup("", "Handle_Bar"):SetRelY(nY)
				end
				h:SetH(nSize + 5)
			else
				h:SetH(20)
				nY = nY + 20
			end
		end
	end
	frame:Lookup("", ""):FormatAllItemPos()
	frame.bIsEnemy = IsEnemy(GetClientPlayer().dwID, frame.dwID)
end

-- get buff left time
_HM_Target.GetBuffTime = function(nEnd)
	local nLeft = nEnd - GetLogicFrameCount()
	local szTime, nFont = "", 162
	local nH, nM, nS = GetTimeToHourMinuteSecond(nLeft, true)
	if nH >= 1 then
		if nH <= 99 then
			if nM >= 1 or nS >= 1 then
				nH = nH + 1
			end
			szTime = nH .. " "
		end
	elseif nM >= 1 then
		if nS >= 1 then
			nM = nM + 1
		end
		szTime = nM .. "'"
	elseif nS >= 0 then
		szTime = nS .. "''"
		nFont = 163
	end
	return szTime, nFont, nLeft
end

-- update buff size
_HM_Target.InitBuffSize = function(dwMgrID, nSize)
	local info = BuffMgr.GetInfo(dwMgrID)
	if not info then
		return
	end
	local boxtexts = {}
	for i, boxtext in ipairs(info.boxtexts) do
		boxtexts[i] = boxtext:gsub("w=%d+", "w=" .. nSize):gsub("h=%d+", "h=" .. nSize)
	end
	BuffMgr.Modify(dwMgrID, {boxtexts = boxtexts})
end

-- get simple num
_HM_Target.GetSimpleNum = function(n)
	if n < 100000 then
		return tostring(n)
	elseif n < 1000000 then
		return _L("%.1fw", n / 10000)
	elseif n < 100000000 then
		return _L("%dw", n / 10000)
	else
		return _L("%db", n / 100000000)
	end
end

-- get state string
_HM_Target.GetStateString = function(nCur, nMax, bTTarget)
	local szText = _HM_Target.GetSimpleNum(nMax)
	if not bTTarget then
		szText = _HM_Target.GetSimpleNum(nCur) .. "/" .. szText
	end
	if nCur >= nMax or nMax <= 1 then
		return szText .. "(100%)"
	elseif nCur == 0 then
		return szText .. "(0%)"
	else
		return szText .. string.format("(%.1f%%)", nCur * 100 / nMax)
	end
end

-- update life/mana
_HM_Target.UpdateLM = function(frame, bTTarget)
	local tar = GetTargetHandle(frame.dwType, frame.dwID)
	if not tar or not frame:IsVisible() then
		return
	end
	-- health
	local hTextHealth = frame:Lookup("", "Text_Health")
	hTextHealth:SetText(_HM_Target.GetStateString(tar.nCurrentLife, tar.nMaxLife, bTTarget))
	hTextHealth:Show()
	-- check mana/rage/energy
	local hMana, hTextMana = frame:Lookup("", "Image_Mana"), frame:Lookup("", "Text_Mana")
	local fM, sM, nM = nil, "", 87
	-- hightman.20151026: removed in latest version
	--[[
	if frame.dwType == TARGET.PLAYER and frame.dwMountType then
		if frame.dwMountType == 10 and tar.nMaxEnergy > 0 then	-- TM
			fM = tar.nCurrentEnergy / tar.nMaxEnergy
			sM = _HM_Target.GetStateString(tar.nCurrentEnergy, tar.nMaxEnergy, bTTarget)
		elseif frame.dwMountType == 6 and tar.nMaxRage > 0 then	-- CJ
			fM = tar.nCurrentRage / tar.nMaxRage
			sM = _HM_Target.GetStateString(tar.nCurrentRage, tar.nMaxRage, bTTarget)
		elseif frame.dwMountType == 18 then	-- CangYun
			if HM.HasBuff(8299, nil, tar) then
				nM = 84
				fM = tar.nCurrentEnergy / math.max(tar.nMaxEnergy, 1)
				sM = _HM_Target.GetStateString(tar.nCurrentEnergy, tar.nMaxEnergy, bTTarget)
			else
				nM = 86
				fM = tar.nCurrentRage / math.max(tar.nMaxRage, 1)
				sM = _HM_Target.GetStateString(tar.nCurrentRage, tar.nMaxRage, bTTarget)
			end
		elseif frame.dwMountType == 8 then	-- MJ
			-- ���������ĸ��϶������ĸ����գ�86���£�84
			if tar.nSunPowerValue == 1 then
				fM, nM = 1, 86
			elseif tar.nMoonPowerValue == 1 then
				fM, nM = 1, 84
			else
				local fS = tar.nCurrentSunEnergy / tar.nMaxSunEnergy
				fM = tar.nCurrentMoonEnergy / tar.nMaxMoonEnergy
				if fM > fS then
					nM = 84
				else
					fM, nM = fS, 86
				end
			end
			sM = string.format("%d%%", fM * 100)
		end
	end
	--]]
	-- update mana image
	if fM ~= nil then
		hMana:SetFrame(nM)
		hMana:SetPercentage(fM)
		hMana:Show()
		local hFBg, hTarBg = frame:Lookup("", "Handle_FBg"), frame:Lookup("", "Handle_TarBg")
		if hFBg and hTarBg then
			hFBg:Hide()
			hTarBg:Show()
		end
		for _, v in ipairs({ "FBgC", "FBgCR", "FBgCRR", "FBgR", "FBgL", "TarBgF" }) do
			local h = frame:Lookup("", "Image_" .. v)
			if h then h:Hide() end
		end
		for _, v in ipairs({ "TarBgC", "TarBgCR", "TarBgCRR", "TarBgR", "TarBgL", "TarBg" }) do
			local h = frame:Lookup("", "Image_" .. v)
			if h then h:Show() end
		end
	else
		hMana:SetFrame(37)
		if hMana:IsVisible() then
			sM = _HM_Target.GetStateString(tar.nCurrentMana, tar.nMaxMana, bTTarget)
		end
	end
	-- update mana text
	hTextMana:SetText(sM)
	hTextMana:Show()
end

-------------------------------------
-- �����������¼�����
-------------------------------------
-- update target action
_HM_Target.AddBreathe = function(frame, bTTarget)
	-- check frame
	if not frame or not frame:IsVisible() then
		if frame then
			frame.dwID2 = nil
		end
		_HM_Target.nBuffBreathe = 0
		return
	end
	-- refresh event hook
	if not frame.bEventInit then
		local h = _HM_Target.frame
		for _, v in ipairs({ "BUFF_UPDATE", "NPC_STATE_UPDATE", "PLAYER_STATE_UPDATE" }) do
			h:UnRegisterEvent(v)
			h:RegisterEvent(v)
		end
		frame.bEventInit = true
	end
	local nFrame = GetLogicFrameCount()
	-- update name
	if (nFrame % 2) == 0 then
		if bTTarget then
			if HM_Target.bEnableTTarget then
				_HM_Target.UpdateName(frame)
				if HM_Target.bEnableLM then
					_HM_Target.UpdateLM(frame, true)
				end
			elseif _HM_Target.bChangeTTarget then
				_HM_Target.UpdateName(frame, true)
				_HM_Target.bChangeTTarget = nil
			end
		else
			if HM_Target.bEnable then
				_HM_Target.UpdateName(frame)
				if HM_Target.bEnableLM then
					_HM_Target.UpdateLM(frame)
				end
			elseif _HM_Target.bChange then
				_HM_Target.UpdateName(frame, true)
				_HM_Target.bChange = nil
			end
		end
	end
	-- update buff size
	if not frame.bBuffSizeAdjusted then
		_HM_Target.RefreshBuff(bTTarget)
	end
	-- update action(channel)
	_HM_Target.UpdateAction(frame)
end

-- skill cast log (channel)
_HM_Target.OnSkillCast = function(dwCaster, dwID, dwLevel, szEvent)
	if not HM_Target.bEnableChannel then
		return
	end
	local nChannel = HM.GetChannelSkillFrame(dwID)
	if nChannel then
		local nFrame = GetLogicFrameCount()
		local szSkill = HM.GetSkillName(dwID, dwLevel)
		if szSkill ~= "" then
			-- purge
			for k, v in pairs(_HM_Target.tChannel) do
				local bDel = (nFrame - v[2]) > v[3]
				if not bDel then
					local p = GetPlayer(k)
					bDel = p ~= nil and p.GetOTActionState() ~= 2
				end
				if bDel then
					_HM_Target.tChannel[k] = nil
				end
			end
			-- save & debug
			if szEvent == "DO_SKILL_CAST" or not _HM_Target.tChannel[dwCaster] then
				_HM_Target.tChannel[dwCaster] = { szSkill, nFrame, nChannel, dwID }
				HM.Debug2("[#" .. dwCaster .. "] cast channel skill [" .. szSkill .. "#" .. szEvent .. "]")
			end
		end
	end
end

-- buff update
-- arg0��dwPlayerID��arg1��bDelete��arg2��nIndex��arg3��bCanCancel
-- arg4��dwBuffID��arg5��nStackNum��arg6��nEndFrame��arg7��bInit
-- arg8��nLevel��arg9��dwSkillSrcID, arg10��bIsValid, arg11��nLeftFrame
_HM_Target.OnBuffUpdate = function()
	for _, v in ipairs({ "Target", "TargetTarget" }) do
		local frame = Station.Lookup("Normal/" .. v)
		if frame and frame:IsVisible() and arg0 == frame.dwID then
			frame.bBuffUpdate = true
			if v == "Target" and not arg1 and not arg7 then
				local szType = (arg3 and "Buff") or "Debuff"
				local hL = frame:Lookup("", "Handle_Text" .. szType)
				if hL then
					for i = 0, 1 do
						local hI = hL:Lookup(i)
						if hI then
							if hT then
								hT:SetFontScheme(163)
								break
							end
						end
					end
				end
			end
		end
	end
end

-- state update/Life & mana
_HM_Target.OnUpdateLM = function()
	if not HM_Target.bEnableLM then
		return
	end
	if HM_Target.bEnable then
		local frame = Station.Lookup("Normal/Target")
		if frame and frame:IsVisible() and arg0 == frame.dwID then
			_HM_Target.UpdateLM(frame)
		end
	end
	if HM_Target.bEnableTTarget then
		local frame = Station.Lookup("Normal/TargetTarget")
		if frame and frame:IsVisible() and arg0 == frame.dwID then
			_HM_Target.UpdateLM(frame, true)
		end
	end
end

---------------------------------------------------------------------
-- ���ں���
---------------------------------------------------------------------
-- draw connect
_HM_Target.OnUpdateConnLine = function()
	local me = GetClientPlayer()
	if not me then return end
	local tar = GetTargetHandle(me.GetTarget())
	local bTop = not HM_Target.bConnFoot
	local r, g, b = unpack(HM_Target.tConnColor)
	local a = HM_Target.nConnAlpha
	-- me <-> tar
	local sha = _HM_Target.hConnect
	if HM_Target.bConnect2 and tar then
		sha:SetTriangleFan(GEOMETRY_TYPE.LINE, HM_Target.nConnWidth * 3)
		sha:ClearTriangleFanPoint()
		sha:AppendCharacterID(me.dwID, bTop, r, g, b, a)
		sha:AppendCharacterID(tar.dwID, bTop, r, g, b, a * 0.3)
		sha:Show()
	else
		sha:Hide()
	end
	-- ttar <-> tar
	local sha = _HM_Target.hTTConnect
	sha:Hide()
	if HM_Target.bTTConnect and tar then
		local ttar = GetTargetHandle(tar.GetTarget())
		if ttar and ttar.dwID ~= tar.dwID and (not HM_Target.bConnect2 or ttar.dwID ~= me.dwID) then
			sha:SetTriangleFan(GEOMETRY_TYPE.LINE, HM_Target.nConnWidth * 3)
			sha:ClearTriangleFanPoint()
			sha:AppendCharacterID(tar.dwID, bTop, r, g, b, a)
			sha:AppendCharacterID(ttar.dwID, bTop, r, g, b, a * 0.3)
			sha:Show()
		end
	end
end

-- create
function HM_Target.OnFrameCreate()
	_HM_Target.hConnect = this:Lookup("", "Shadow_Connect")
	_HM_Target.hTTConnect = this:Lookup("", "Shadow_TTConnect")
	this:RegisterEvent("SYS_MSG")
	this:RegisterEvent("DO_SKILL_CAST")
	this:RegisterEvent("TARGET_CHANGE")
	this:RegisterEvent("PLAYER_ENTER_SCENE")
end

-- event
function HM_Target.OnEvent(event)
	if event == "SYS_MSG" then
		if arg0 == "UI_OME_SKILL_HIT_LOG" and arg3 == SKILL_EFFECT_TYPE.SKILL then
			_HM_Target.OnSkillCast(arg1, arg4, arg5, arg0)
		elseif arg0 == "UI_OME_SKILL_EFFECT_LOG" and arg4 == SKILL_EFFECT_TYPE.SKILL then
			_HM_Target.OnSkillCast(arg1, arg5, arg6, arg0)
		end
	elseif event == "DO_SKILL_CAST" then
		_HM_Target.OnSkillCast(arg0, arg1, arg2, event)
	elseif event == "BUFF_UPDATE" then
		_HM_Target.OnBuffUpdate()
	elseif event == "NPC_STATE_UPDATE" or event == "PLAYER_STATE_UPDATE" then
		_HM_Target.OnUpdateLM()
	elseif event == "TARGET_CHANGE" then
		_HM_Target.OnUpdateConnLine()
	elseif event == "PLAYER_ENTER_SCENE" and arg0 == GetClientPlayer().dwID then
		_HM_Target.OnUpdateConnLine()
	end
end

-- update dir (open/close)
_HM_Target.UpdateDir = function()
	local frame = Station.Lookup("Normal/HM_TargetDir")
	if not HM_Target.bDirection then
		if frame then
			Wnd.CloseWindow(frame)
		end
	elseif not frame then
		frame = Wnd.OpenWindow("interface\\HM\\HM_Target\\HM_TargetDir.ini", "HM_TargetDir")
		HM_TargetDir.AdjustSize()
	end
end

---------------------------------------------------------------------
-- Ŀ�귽��ָʾ (HM_TargetDir)
---------------------------------------------------------------------
HM_TargetDir = {}

-- adjust size
HM_TargetDir.AdjustSize = function()
	local handle = Station.Lookup("Normal/HM_TargetDir"):Lookup("", "")
	if HM_Target.bDirLarge then
		handle:Lookup("Image_Force"):SetSize(42, 42)
		handle:Lookup("Box_Buff"):SetSize(42, 42)
		handle:Lookup("Text_State"):SetRelPos(0, 34)
		handle:Lookup("Image_Force"):SetRelPos(59, 59)
		handle:Lookup("Box_Buff"):SetRelPos(59, 59)
		handle:Lookup("Text_Distance"):SetRelPos(0, 101)
		handle:Lookup("Text_State"):SetFontScheme(199)
		handle:Lookup("Text_Distance"):SetFontScheme(188)
	else
		handle:Lookup("Image_Force"):SetSize(30, 30)
		handle:Lookup("Box_Buff"):SetSize(30, 30)
		handle:Lookup("Text_State"):SetRelPos(0, 40)
		handle:Lookup("Image_Force"):SetRelPos(65, 65)
		handle:Lookup("Box_Buff"):SetRelPos(65, 65)
		handle:Lookup("Text_Distance"):SetRelPos(0, 95)
		handle:Lookup("Text_State"):SetFontScheme(159)
		handle:Lookup("Text_Distance"):SetFontScheme(16)
	end
	handle:FormatAllItemPos()
end

-- anchor
HM_TargetDir.UpdateAnchor = function(frame)
	local a = HM_Target.tDirAnchor
	if IsEmpty(a) then
		local nW, nH = Station.GetClientSize()
		frame:SetAbsPos(math.ceil(nW/2) + 40, math.ceil(nH/2) - 40)
	else
		frame:SetPoint(a.s, 0, 0, a.r, a.x, a.y)
	end
	frame:CorrectPos()
end

-- set to head
HM_TargetDir.SetHeadImage = function(hImg, tar)
	if hImg.dwID ~= tar.dwID then
		hImg.dwID = tar.dwID
		if IsPlayer(tar.dwID) then
			local mnt = tar.GetKungfuMount()
			if mnt and mnt.dwSkillID ~= 0 then
				hImg:FromIconID(Table_GetSkillIconID(mnt.dwSkillID, 1))
			else
				if not mnt then
					local dwType, dwID = GetClientPlayer().GetTarget()
					HM.SetTarget(TARGET.PLAYER, tar.dwID)
					HM.SetTarget(dwType, dwID)
				end
				hImg:FromUITex(GetForceImage(tar.dwForceID))
				hImg.dwID = nil
			end
		else
			local szPath = NPC_GetProtrait(tar.dwModelID)
			if not szPath or not IsFileExist(szPath) then
				szPath = NPC_GetHeadImageFile(tar.dwModelID)
			end
			if not szPath or not IsFileExist(szPath) then
				hImg:FromUITex(GetNpcHeadImage(tar.dwID))
			else
				hImg:FromTextureFile(szPath)
			end
		end
	end
end

-- get state/icon (return: icon, szState, bufID, buffLevel, buff.nEndFrame)
HM_TargetDir.GetState = function(tar, bBuff)
	if tar.nMoveState == MOVE_STATE.ON_SIT then
		return 533, g_tStrings.tPlayerMoveState[tar.nMoveState]
	elseif tar.nMoveState == MOVE_STATE.ON_DEATH then
		return 2215, g_tStrings.tPlayerMoveState[tar.nMoveState]
	elseif tar.nMoveState == MOVE_STATE.ON_KNOCKED_DOWN then
		return 2027, g_tStrings.tPlayerMoveState[tar.nMoveState]
	elseif tar.nMoveState == MOVE_STATE.ON_DASH then
		return 2030, g_tStrings.tPlayerMoveState[tar.nMoveState]
	elseif tar.nMoveState == MOVE_STATE.ON_SKILL_MOVE_DST then
		return 1487, _L["Move"]
	else
		local szText, dwIcon, buff
		-- check buff
		if HM_TargetMon and bBuff then
			local nFrame = GetLogicFrameCount()
			local szType, nType
			local tAll = HM.GetAllBuff(tar)
			for _, v in ipairs(tAll) do
				if v.nEndFrame > nFrame then
					local _szType, _nType = HM_TargetMon.GetBuffExType(v.dwID, v.nLevel)
					if _szType and (not nType or _nType < nType) then
						szType, nType = _szType, _nType
						buff = v
					end
				end
			end
			if buff then
				szText, dwIcon = HM.GetBuffName(buff.dwID, buff.nLevel)
				if szType ~= _L["Others"] and szType ~= _L["Orange-weapon"] then
					szText = string.gsub(szType, "%d+$", "")
				end
			end
		end
		-- check other movestate
		if tar.nMoveState == MOVE_STATE.ON_HALT and szText ~= _L["Halt"] then
			return 2019, g_tStrings.tPlayerMoveState[tar.nMoveState]
		elseif tar.nMoveState == MOVE_STATE.ON_FREEZE and szText ~= _L["Freeze"] then
			return 2038, g_tStrings.tPlayerMoveState[tar.nMoveState]
		elseif tar.nMoveState == MOVE_STATE.ON_ENTRAP and szText ~= _L["Entrap"] then
			return 2020, _L["Entrap"]
		end
		-- check speed
		if buff then
			return dwIcon, szText, buff
		elseif IsPlayer(tar.dwID) and tar.nRunSpeed < 20 then
			return 348, _L["Slower"]
		end
	end
end

-- get status icon & text
HM_TargetDir.UpdateState = function(frame, tar)
	local dwIcon, szText
	local hImage, hBox = frame:Lookup("", "Image_Force"), frame:Lookup("", "Box_Buff")
	-- get state
	local dwIcon, szText, buff = HM_TargetDir.GetState(tar, HM_Target.bDirBuff)
	if not buff then
		hBox.dwID = nil
		hBox:SetOverText(0, "")
		hBox:SetOverText(1, "")
	else
		hBox.dwID, hBox.nLevel = buff.dwID, buff.nLevel
		if buff.nStackNum > 1 then
			hBox:SetOverText(0, buff.nStackNum)
		else
			hBox:SetOverText(0, "")
		end
		local nSec = (buff.nEndFrame - GetLogicFrameCount()) / GLOBAL.GAME_FPS
		if nSec < 3 then
			hBox:SetOverText(1, string.format("%.1f\"", nSec))
		elseif nSec < 3600 then
			hBox:SetOverText(1, string.format("%d\"", nSec))
		else
			hBox:SetOverText(1, "")
		end
		hBox.dwOwner = tar.dwID
	end
	-- update image
	if not dwIcon then
		hBox:Hide()
		if tar.nMoveState == MOVE_STATE.ON_AUTO_FLY then
			hImage.dwID = nil
			hImage:FromUITex("ui\\Image\\UICommon\\CommonPanel4.UITex", 73)
		else
			HM_TargetDir.SetHeadImage(hImage, tar)
		end
		hImage:Show()
	else
		hImage:Hide()
		hBox:SetObjectIcon(dwIcon)
		hBox:Show()
		if HM_TargetMon then
			if HM_TargetMon.bBoxEvent2 then
				hBox:RegisterEvent(768)
			else
				hBox:ClearEvent()
			end
		end
	end
	-- update state
	if not szText or not HM_Target.bDirText then
		szText = ""
	end
	frame:Lookup("", "Text_State"):SetText(szText)
end

-- create
HM_TargetDir.OnFrameCreate = function()
	this:RegisterEvent("ON_ENTER_CUSTOM_UI_MODE")
	this:RegisterEvent("ON_LEAVE_CUSTOM_UI_MODE")
	this:RegisterEvent("UI_SCALED")
	HM_TargetDir.UpdateAnchor(this)
	UpdateCustomModeWindow(this, _L["HM target direction"])
	-- update box
	local box = this:Lookup("", "Box_Buff")
	box:SetOverTextFontScheme(0, 15)
	box:SetOverTextFontScheme(1, 16)
	box:SetOverTextPosition(1, ITEM_POSITION.LEFT_TOP)
	box:SetObject(UI_OBJECT_NOT_NEED_KNOWN, 0)
	box.OnItemMouseEnter = function()
		this:SetObjectMouseOver(1)
		if this.dwID then
			local x, y = this:GetAbsPos()
			local w, h = this:GetSize()
			OutputBuffTip(this.dwOwner, this.dwID, this.nLevel, 1, false, 0, { x, y, w, h })
		end
	end
	box.OnItemMouseLeave = function()
		this:SetObjectMouseOver(0)
		HideTip()
	end
end

-- breathe
HM_TargetDir.OnFrameBreathe = function()
	local me = GetClientPlayer()
	if not me then return end
	local tar = GetTargetHandle(me.GetTarget())
	if not tar or tar.dwID == me.dwID then
		HM_TargetDir.dwLastID = nil
		return this:Lookup("", ""):Hide()
	end
	-- update dir image
	local hImage = this:Lookup("", "Image_Dir")
	if tar.dwID == me.dwID then
		hImage:Hide()
	else
		hImage:Show()
		if HM_TargetDir.dwLastID ~= tar.dwID then
			local nFrame = 5
			if me.IsInParty() and HM.IsParty(tar.dwID) then
				nFrame = 6
			elseif IsEnemy(me.dwID, tar.dwID) then
				nFrame = 4
			elseif IsAlly(me.dwID, tar.dwID) then
				nFrame = 7
			end
			hImage:SetFrame(nFrame)
			HM_TargetDir.dwLastID = tar.dwID
		end
		if tar.nX == me.nX then
			hImage:SetRotate(0)
		else
			local dwRad1 = math.atan((tar.nY - me.nY) / (tar.nX - me.nX))
			if dwRad1 < 0 then
				dwRad1 = dwRad1 + math.pi
			end
			if tar.nY < me.nY then
				dwRad1 = math.pi + dwRad1
			end
			local dwRad2 = me.nFaceDirection / 128 * math.pi
			hImage:SetRotate(1.5 * math.pi + dwRad2 - dwRad1)
		end
	end
	-- update distance
	local hDist = this:Lookup("", "Text_Distance")
	if HM_Target.bDirDist then
		local dwDis = HM.GetDistance(tar)
		if dwDis > 100 then
			hDist:SetText(_L("%d feet", dwDis))
		else
			hDist:SetText(_L("%.1f feet", dwDis))
		end
		hDist:Show()
	else
		hDist:Hide()
	end
	-- update state
	HM_TargetDir.UpdateState(this, tar)
	-- show
	this:Lookup("", ""):Show()
end

-- drag
HM_TargetDir.OnFrameDragEnd = function()
	this:CorrectPos()
	HM_Target.tDirAnchor = GetFrameAnchor(this)
end

-- event
HM_TargetDir.OnEvent = function(event)
	if event == "ON_ENTER_CUSTOM_UI_MODE" or event == "ON_LEAVE_CUSTOM_UI_MODE" then
		UpdateCustomModeWindow(this)
	elseif event == "UI_SCALED" then
		HM_TargetDir.UpdateAnchor(this)
	end
end

---------------------------------------------------------------------
-- ���ý���
---------------------------------------------------------------------
_HM_Target.PS = {}

-- init panel
_HM_Target.PS.OnPanelActive = function(frame)
	local ui, nX = HM.UI(frame), 0
	-- target
	ui:Append("Text", { txt = _L["Target enhancement"], font = 27 })
	nX = ui:Append("WndCheckBox", { x = 10, y = 28, checked = HM_Target.bEnable })
	:Text(_L["Enable enh (distance/kungfu)"]):Click(function(bChecked)
		HM_Target.bEnable = bChecked
		_HM_Target.bChange = true
	end):Pos_()
	nX = ui:Append("WndCheckBox", { x = nX + 5, y = 28, checked = HM_Target.bEnableTTarget })
	:Text(_L["Enable target target"]):Click(function(bChecked)
		HM_Target.bEnableTTarget = bChecked
		_HM_Target.bChangeTTarget = true
	end):Pos_()
	ui:Append("WndCheckBox", { x = nX + 5, y = 28, checked = HM_Target.bEnableLM })
	:Text(_L["HP/MP"]):Click(function(bChecked)
		HM_Target.bEnableLM= bChecked
	end)
	-- buff size
	local nX2 = nX
	nX = ui:Append("WndCheckBox", { x = 10, y = 56, checked = HM_Target.bAdjustBuff })
	:Text(_L["Adjust buff size"]):Click(function(bChecked)
		HM_Target.bAdjustBuff = bChecked
		ui:Fetch("Combo_Size1"):Enable(bChecked)
		ui:Fetch("Combo_Size2"):Enable(bChecked)
		-- ui:Fetch("Check_Spark"):Enable(bChecked)
		_HM_Target.RefreshBuff()
	end):Pos_()
	nX = ui:Append("WndComboBox", "Combo_Size1", { x = nX, y = 56, w = 60, h = 25 })
	:Enable(HM_Target.bAdjustBuff):Text(tostring(HM_Target.nSizeBuff)):Menu(function()
		local m0 = {}
		for i = 20, 60, 5 do
			table.insert(m0, { szOption = tostring(i), fnAction = function()
				HM_Target.nSizeBuff = i
				ui:Fetch("Combo_Size1"):Text(tostring(i))
				_HM_Target.RefreshBuff()
			end })
		end
		return m0
	end):Pos_()
	nX = ui:Append("Text", { x = nX + 10, y = 54, txt = _L["Target of target"] }):Pos_()
	nX = ui:Append("WndComboBox", "Combo_Size2", { x = nX, y = 56, w = 60, h = 25 })
	:Enable(HM_Target.bAdjustBuff):Text(tostring(HM_Target.nSizeTTBuff)):Menu(function()
		local m0 = {}
		for i = 20, 60, 5 do
			table.insert(m0, { szOption = tostring(i), fnAction = function()
				HM_Target.nSizeTTBuff = i
				ui:Fetch("Combo_Size2"):Text(tostring(i))
				_HM_Target.RefreshBuff()
			end })
		end
		return m0
	end):Pos_()
	-- line
	ui:Append("Text", { txt = _L["Target connect line"], x = 0, y = 92, font = 27 })
	nX = ui:Append("WndCheckBox", { x = 10, y = 120, checked = HM_Target.bConnect2 })
	:Text(_L["Draw line from target to you"]):Click(function(bChecked)
		HM_Target.bConnect2 = bChecked
		_HM_Target.OnUpdateConnLine()
		ui:Fetch("Combo_Conn"):Enable(bChecked)
		ui:Fetch("Check_Foot"):Enable(bChecked)
	end):Pos_()
	ui:Append("WndCheckBox", { x = nX + 20, y = 120, checked = HM_Target.bTTConnect })
	:Text(_L["Draw line from target to target target"]):Click(function(bChecked)
		HM_Target.bTTConnect = bChecked
		_HM_Target.OnUpdateConnLine()
	end)
	ui:Append("WndComboBox", "Combo_Conn", { x = 14, y = 150, txt = _L["Line setting"] })
	:Menu(_HM_Target.GetConnMenu)
	ui:Append("WndCheckBox", "Check_Foot", { x = nX + 20, y = 150, checked = HM_Target.bConnFoot })
	:Text(_L["Show line on foot"]):Click(function(bChecked)
		HM_Target.bConnFoot = bChecked
		_HM_Target.OnUpdateConnLine()
	end)
	-- action bar
	ui:Append("Text", { txt = _L["Prepared skill enhancement"], x = 0, y = 186, font = 27 })
	ui:Append("WndCheckBox", { x = 10, y = 214, checked = HM_Target.bEnableChannel })
	:Text(_L["Show channel skill of target/target target"]):Click(function(bChecked)
		HM_Target.bEnableChannel = bChecked
	end)
	ui:Append("WndCheckBox", { x = 10, y = 242, checked = HM_Target.bEnableBreak })
	:Text(_L["Show non-broken as gray text"]):Click(function(bChecked)
		HM_Target.bEnableBreak = bChecked
	end)
	ui:Append("WndCheckBox", { x = nX + 30, y = 242, checked = HM_Target.bAdjustBar })
	:Text(_L["Adjust preparing bar to above of buff"]):Click(function(bChecked)
		HM_Target.bAdjustBar = bChecked
	end)
	-- target dir
	ui:Append("Text", { txt = _L["Target direction (adjust position by SHIFT-U)"], x = 0, y = 284, font = 27 })
	nX = ui:Append("WndCheckBox", { x = 10, y = 312, checked = HM_Target.bDirection })
	:Text(_L["Show direction"]):Click(function(bChecked)
		HM_Target.bDirection = bChecked
		ui:Fetch("Check_DirDist"):Enable(bChecked)
		ui:Fetch("Check_DirText"):Enable(bChecked)
		ui:Fetch("Check_DirBuff"):Enable(bChecked)
		ui:Fetch("Check_DirLarge"):Enable(bChecked)
		_HM_Target.UpdateDir()
	end):Pos_()
	nX = ui:Append("WndCheckBox", "Check_DirText", { x = nX + 10, y = 312, checked = HM_Target.bDirText })
	:Text(_L["Status"]):Enable(HM_Target.bDirection):Click(function(bChecked)
		HM_Target.bDirText = bChecked
	end):Pos_()
	nX = ui:Append("WndCheckBox", "Check_DirDist", { x = nX + 10, y = 312, checked = HM_Target.bDirDist })
	:Text(_L["Distance"]):Enable(HM_Target.bDirection):Click(function(bChecked)
		HM_Target.bDirDist = bChecked
	end):Pos_()
	nX = ui:Append("WndCheckBox", "Check_DirBuff", { x = nX + 10, y = 312, checked = HM_Target.bDirBuff })
	:Text("BUFF"):Enable(HM_Target.bDirection and HM_TargetMon ~= nil):Click(function(bChecked)
		HM_Target.bDirBuff = bChecked
	end):Pos_()
	ui:Append("WndCheckBox", "Check_DirLarge", { x = nX + 10, y = 312, checked = HM_Target.bDirLarge })
	:Text(_L["Larger icon"]):Enable(HM_Target.bDirection):Click(function(bChecked)
		HM_Target.bDirLarge = bChecked
		HM_TargetDir.AdjustSize()
	end)
end

-- check conflict
_HM_Target.PS.OnConflictCheck = function()
	-- copatiable with box
	if TargetLine and HM_Target.bConnect2 then
		TargetLine.btargetline = false
	end
	if TargetEx then
		if HM_Target.bAdjustBar then
			TargetEx.UpdateAction = function() end
		end
		if HM_Target.bAdjustBuff then
			TargetEx.bAdjustTargetBuff = false
			TargetEx.bAdjustTTargetBuff = false
		end
		if HM_Target.bEnable or HM_Target.bEnableTTarget then
			TargetEx.UpdateName = function() end
		end
		TargetEx.OnManaUpdate = function() end
		if HM_Target.bDirection and TargetMark then
			TargetMark.bOn = false
		end
	end
end

---------------------------------------------------------------------
-- ע���¼�����ʼ��
---------------------------------------------------------------------
HM.BreatheCall("HM_Target", function()
	_HM_Target.AddBreathe(Station.Lookup("Normal/Target"))
	_HM_Target.AddBreathe(Station.Lookup("Normal/TargetTarget"), true)
end)
HM.RegisterEvent("PLAYER_ENTER_GAME", function()
	_HM_Target.UpdateDir()
	-- show bufftime of 374
	local buff = Table_GetBuff(374, 1)
	if buff then
		buff.bShowTime = 1
	end
end)

-- add to HM panel
HM.RegisterPanel(_L["Target enhancement"], 303, _L["Target"], _HM_Target.PS)

-- open target window
local frame = Station.Lookup("Lowest/HM_Target")
if frame then Wnd.CloseWindow(frame) end
_HM_Target.frame = Wnd.OpenWindow(_HM_Target.szIniFile, "HM_Target")

-- public api
HM_Target.GetSkillChannelState = _HM_Target.GetSkillChannelState
