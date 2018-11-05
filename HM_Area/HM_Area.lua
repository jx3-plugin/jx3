--
-- ����������������������Ż��ط�Χ��������ʾ
--

HM_Area = {
	bQichang = true,			-- ��ʾ��������
	bJiguan = true,			-- ��ʾ���Ż���
	bYinyu = true,				-- ��ʾ��������
	bShowName = true,	-- ��ʾͷ������
	bBigTaiji = true,			-- 11 ����̫��
	nAlpha = 40,				-- ��ʾЧ���Ĳ�͸���ȣ�Խ��ԽŨ��
	nMaxNum = 10,			-- ��໭����Χ�ĸ���
	tColor = {},
	tHide2 = {
		[2] = {
			[15959] = true,	-- Ĭ�ϲ���ʾ���ѵķ���
			[44766] = true,	-- ����ʾ���ѵĻ���
		},
		[3] = {
			[15959] = true,	-- Ĭ�ϲ���ʾ���˵ķ���
			[44765] = true,	-- ����ʾ���˵������ả
			[44766] = true,	-- ����ʾ���˵Ļ���
		},
		[4] = {
			[0] = true,			-- Ĭ�ϲ���ʾ�κ������˵�����������
		},
	},
}
HM.RegisterCustomData("HM_Area")

---------------------------------------------------------------------
-- ���غ����ͱ���
---------------------------------------------------------------------
local _HM_Area = {
	nMinDelay = 500,	-- �����ͷźͳ��ֵ���Сʱ���λ����
	nMaxDelay = 1400,	-- �����ͷźͳ��ֵ����ʱ���λ����
	szIniFile = "interface\\HM\\HM_Area\\HM_Area.ini",
	tList = {},					-- ��ʾ��¼
	tCast = {},				-- �ͷż�¼
}

-- default color
_HM_Area.tDefaultColor = {
	{ 0, 255, 0 },		-- 1 �̣��Ŷӣ��Լ�
	{ 255, 0, 0 },		-- 2 �죺����
	{ 255, 255, 0 },	-- 3 �ƣ�����
	{ 0, 255, 255 },	-- 4 �ࣺͻ���ѷ�
	{ 255, 0, 255 },	-- 5 �ۣ�ͻ���з�
	{ 255, 128, 0}, 	-- 6 �ȣ��з�����
}

-- relations
_HM_Area.tRelation = { _L["Own"], _L["Team"], _L["Enemy"], _L["Others"] }

-- skill list
_HM_Area.tSkill = {
	{
		dwID = 6911,				-- ���� ID �� 371
		dwTemplateID = 4982,	-- ģ�� ID
		nLeft = 8,						-- ������ʱ�䣬��λ����
		tOther = { [371] = 4982 },
	}, {
		dwID = 358,
		dwTemplateID = 4976,
		nLeft = 24,
	}, {
		dwID = 357,
		dwTemplateID = 3080,
		nLeft = 24,
	}, {
		dwID = 359,
		dwTemplateID = 4977,
		nLeft = 24,
	}, {
		dwID = 360,
		dwTemplateID = 4978,
		nLeft = 8,
	}, {
		dwID = 361,
		dwTemplateID = 4979,
		nLeft = 24,
	}, {
		dwID = 362,
		dwTemplateID = 4980,
		nLeft = 24,
	}, {
		dwID = 363,
		dwTemplateID = 4981,
		nLeft = 24,
	}, {
	}, {
		dwID = 3103,
		dwTemplateID = 15959,
		nLeft = 30,
	}, {
		dwID = 3108,
		dwTemplateID = 15994,
		nLeft = 16,
	}, {
		dwID = 3107,
		dwTemplateID = 15999,
		nLeft = 30,
	}, {
		dwID = 3111,
		dwTemplateID = 16000,
		nLeft = 60,
	}, {
		dwID = 3370,
		dwTemplateID = 16177,
		tOther = { [3368] = 16175, [3369] = 16176 },
		nLeft = 10,
	}, {
	}, {
		dwID = 14073,	-- Ц������
		dwTemplateID = 44734,
		nLeft = 8,
		tOther = { [14222] = 44734 },
	}, {
		dwID = 14074,	-- ��������
		dwTemplateID = 44764,
		nLeft = 8,
		tOther = { [14223] = 44764 },
	}, {
		dwID = 14075,	-- �����ả
		dwTemplateID = 44765,
		nLeft = 8,
		tOther = { [14224] = 44765 },
	}, {
		dwID = 14154,	-- ޒ�����
		dwTemplateID = 44766,
		nLeft = 8,
		tOther = { [14225] = 44766 },
	}, {
		dwID = 16454,	-- ��������
		dwTemplateID = 53233,
		nLeft = 4,
	}, {
		dwID = 16455,	-- ���Ӻ���
		dwTemplateID = 53803,
		nLeft = 4,
	}
}

-- sysmsg
_HM_Area.Sysmsg = function(szMsg) HM.Sysmsg(szMsg, _L["HM_Area"]) end

-- debug
_HM_Area.Debug = function(szMsg) HM.Debug2(szMsg, _L["HM_Area"]) end

-- get relation by caster
_HM_Area.GetRelation = function(dwCaster, tar)
	if dwCaster ~= 0 or (tar and tar.dwID ~= 0) then
		local myID = GetClientPlayer().dwID
		if myID == dwCaster then
			return 1
		elseif IsEnemy(myID, dwCaster) or (tar and IsEnemy(myID, tar.dwID)) then
			return 3
		elseif HM.IsParty(dwCaster) then
			return 2
		end
	end
	return 4
end

-- get template id by skill
_HM_Area.GetTemplateID = function(dwID)
	for _, v in ipairs(_HM_Area.tSkill) do
		if v.dwID == dwID then
			return v.dwTemplateID
		elseif v.tOther then
			for kk, vv in pairs(v.tOther) do
				if kk == dwID then
					return vv
				end
			end
		end
	end
end

-- get template name
_HM_Area.GetTemplateName = function(dwTemplateID)
	for _, v in ipairs(_HM_Area.tSkill) do
		if v.dwTemplateID == dwTemplateID then
			return HM.GetSkillName(v.dwID)
		end
		if v.tOther then
			for kk, vv in pairs(v.tOther) do
				if vv == dwTemplateID then
					return HM.GetSkillName(kk)
				end
			end
		end
	end
end

-- check hide for template
_HM_Area.CheckTemplateID = function(dwTemplateID)
	if HM.IsDunegon() then
		return false
	end
	if dwTemplateID == 16175 or dwTemplateID == 16176 then
		dwTemplateID = 16177
	end
	if dwTemplateID == 16177 or dwTemplateID == 15959
		or dwTemplateID == 15994 or dwTemplateID == 15999 or dwTemplateID == 16000
	then
		return HM_Area.bJiguan
	elseif dwTemplateID == 44734 or dwTemplateID == 44764
		or dwTemplateID == 44765 or dwTemplateID == 44766
	then
		return HM_Area.bYinyu
	else
		for _, v in ipairs(_HM_Area.tSkill) do
			if v.dwTemplateID == dwTemplateID then
				return HM_Area.bQichang
			end
		end
		return false
	end
end

-- get total left time by template
_HM_Area.GetTotalLeft = function(dwTemplateID)
	if dwTemplateID == 16175 or dwTemplateID == 16176 then
		return 120
	end
	for _, v in ipairs(_HM_Area.tSkill) do
		if v.dwTemplateID == dwTemplateID then
			return v.nLeft
		end
	end
	return 0
end

-- get radius by template
_HM_Area.GetAreaRadius = function(dwTemplateID)
	if dwTemplateID == 4982 then			-- ��ɽ��
		return 256
	elseif dwTemplateID == 15959 then	-- ����
		return 2240
	elseif dwTemplateID == 15994 then	-- �������
		return 384
	elseif dwTemplateID == 16174 then	-- ���ص���
		return 0
	elseif dwTemplateID == 16000 then	-- ����ɱ��
		return 384
	elseif dwTemplateID == 16177 then	-- ��ɲ
		return 640
	elseif dwTemplateID == 16176 then	-- ����
		return 1600
	elseif dwTemplateID == 16175 then	-- ����
		return 1600
	elseif dwTemplateID == 44734 or dwTemplateID == 44765 then
		-- Ц������/�����ả
		return 960
	elseif dwTemplateID == 53233 or dwTemplateID == 53803 then	-- �Ե���ǽ
		return 0
	end
	-- ��׷����/ޒ�����Ҳ�� 10��
	return 640
end

-- check hide by relation, template ...
_HM_Area.GetHide = function(nRelation, dwTemplateID, bSelf)
	dwTemplateID = dwTemplateID or 0
	if dwTemplateID == 16175 or dwTemplateID == 16176 then
		dwTemplateID = 16177
	end
	local hide = HM_Area.tHide2[nRelation]
	if hide and ((not bSelf and hide[0]) or hide[dwTemplateID]) then
		return true
	end
	return false
end

-- set to hide
_HM_Area.SetHide = function(nRelation, dwTemplateID, bHide)
	dwTemplateID = dwTemplateID or 0
	if dwTemplateID == 16175 or dwTemplateID == 16176 then
		dwTemplateID = 16177
	end
	if not HM_Area.tHide2[nRelation] then
		HM_Area.tHide2[nRelation] = {}
	end
	HM_Area.tHide2[nRelation][dwTemplateID] = bHide
end

-- get color, return (r, g, b)
_HM_Area.GetColor = function(nRelation, dwTemplateID)
	local color, default = HM_Area.tColor[nRelation], _HM_Area.tDefaultColor
	if dwTemplateID == 16175 or dwTemplateID == 16176 then
		dwTemplateID = 16177
	end
	if not color or not color[dwTemplateID] then
		if nRelation == 1 or nRelation == 2 then
			if dwTemplateID == 4976  or dwTemplateID == 16177
				or dwTemplateID == 15959 or dwTemplateID == 15994
				or dwTemplateID == 15999 or dwTemplateID == 16000
			then
				return default[4]
			else
				return default[1]
			end
		elseif nRelation == 3 then
			if dwTemplateID == 4976  or dwTemplateID == 16177
				or dwTemplateID == 15959 or dwTemplateID == 15994
				or dwTemplateID == 15999 or dwTemplateID == 16000
			then
				return default[5]
			elseif dwTemplateID == 44764 then
				return default[6]
			else
				return default[2]
			end
		else
			return default[3]
		end
	else
		return color[dwTemplateID]
	end
end

-- set color
_HM_Area.SetColor = function(nRelation, dwTemplateID, r, g, b)
	if dwTemplateID == 16175 or dwTemplateID == 16176 then
		dwTemplateID = 16177
	end
	if not HM_Area.tColor[nRelation] then
		HM_Area.tColor[nRelation] = {}
	end
	HM_Area.tColor[nRelation][dwTemplateID] = { r, g, b }
	_HM_Area.bUpdateArea = true
end

-------------------------------------
-- ����Χ���
-------------------------------------
-- show name
_HM_Area.ShowName = function(tar)
	local data = _HM_Area.tList[tar.dwID]
	if not data then return end
	local r, g, b = unpack(_HM_Area.GetColor(_HM_Area.GetRelation(data.dwCaster, tar), tar.dwTemplateID))
	local szText = tar.szName
	if data.dwCaster ~= 0 then
		local player = GetPlayer(data.dwCaster)
		if player then
			data.szName = data.szName or _HM_Area.GetTemplateName(tar.dwTemplateID) or szText
			szText = player.szName .. _L["-"] .. data.szName
		end
		if data.nLeft > 0 and data.dwTime ~= 0 then
			szText = szText .. _L["-"] .. math.ceil((data.nLeft + data.dwTime - GetTime())/1000)
		end
	end
	_HM_Area.pLabel:AppendCharacterID(tar.dwID, true, r, g, b, 200, 0, 40, szText, 0, 1)
end

-- draw circle (TriangleStrip)
_HM_Area.DrawCircle = function(sha, tar, col, nRadius, nAlpha, nThick)
	-- setting
	sha:SetTriangleFan(GEOMETRY_TYPE.TRIANGLE)
	sha:SetD3DPT(D3DPT.TRIANGLESTRIP)
	sha:ClearTriangleFanPoint()
	sha:Show()
	local r, g, b = unpack(col)
	-- points
	nRadius = nRadius or 640
	nThick = nThick or math.ceil(6 * nRadius / 640)
	local dwMaxRad = math.pi + math.pi
	local dwStepRad = dwMaxRad / (nRadius / 16)
	local dwCurRad = 0 - dwStepRad
	repeat
		local tRad = {}
		tRad[1] = { nRadius, dwCurRad }
		tRad[2] = { nRadius - nThick, dwCurRad }
		for _, v in ipairs(tRad) do
			local nX = tar.nX + math.ceil(math.cos(v[2]) * v[1])
			local nY = tar.nY + math.ceil(math.sin(v[2]) * v[1])
			sha:AppendTriangleFan3DPoint(nX, nY, tar.nZ, r, g, b, nAlpha)
		end
		dwCurRad = dwCurRad + dwStepRad
	until dwMaxRad <= dwCurRad
end

-- draw shape (1 shadow)
_HM_Area.DrawCake = function(sha, tar, col, nRadius, nAlpha)
	-- setting
	sha:SetTriangleFan(GEOMETRY_TYPE.TRIANGLE)
	sha:SetD3DPT(D3DPT.TRIANGLEFAN)
	sha:ClearTriangleFanPoint()
	sha:Show()
	local r, g, b = unpack(col)
	-- points
	sha:AppendTriangleFan3DPoint(tar.nX, tar.nY, tar.nZ, r, g, b, 0)
	nRadius = nRadius or 640
	local dwMaxRad = math.pi + math.pi
	local dwStepRad = dwMaxRad / (nRadius / 16)
	local dwCurRad = 0 - dwStepRad
	repeat
		dwCurRad = dwCurRad + dwStepRad
		if dwCurRad > dwMaxRad then
			dwCurRad = dwMaxRad
		end
		local nX = tar.nX + math.ceil(math.cos(dwCurRad) * nRadius)
		local nY = tar.nY + math.ceil(math.sin(dwCurRad) * nRadius)
		sha:AppendTriangleFan3DPoint(nX, nY, tar.nZ, r, g, b, nAlpha)
	until dwMaxRad <= dwCurRad
end

-- draw area (draw shape only for far objects)
_HM_Area.DrawArea = function(tar)
	local data = _HM_Area.tList[tar.dwID]
	if not data then return end
	local nAlpha, nRadius = HM_Area.nAlpha, _HM_Area.GetAreaRadius(tar.dwTemplateID)
	if nRadius == 0 then
		return
	end
	local color =  _HM_Area.GetColor(_HM_Area.GetRelation(data.dwCaster, tar), tar.dwTemplateID)
	local nDistance = HM.GetDistance(tar)
	if tar.dwTemplateID == 4982 then
		nAlpha = math.ceil(nAlpha * 2)
	elseif tar.dwTemplateID == 44764 then
		nAlpha = math.ceil(nAlpha * 1.8)
	elseif tar.dwTemplateID == 4976 and HM_Area.bBigTaiji then
		nRadius = nRadius + 64
	end
	-- ���� +5 ��
	if tar.dwTemplateID == 4976 and tar.dwEmployer == UI_GetClientPlayerID()
		and GetClientPlayer().GetSkillLevel(14835) ~= 0
	then
		nRadius = nRadius + 320
	end
	-- draw cake & circle
	data.shape = data.shape or _HM_Area.pDraw:New()
	if nRadius >= 256 and nDistance < 35 then
		if data.shape.nType ~= 1 or _HM_Area.bUpdateArea then
			data.shape.nType = 1
			_HM_Area.DrawCake(data.shape, tar, color, nRadius, nAlpha / 3)
		else
			data.shape:Show()
		end
		data.circle = data.circle or _HM_Area.pDraw:New()
		if data.circle.nType ~= 1 or _HM_Area.bUpdateArea then
			data.circle.nType = 1
			_HM_Area.DrawCircle(data.circle, tar, color, nRadius, nAlpha * 1.4)
		else
			data.circle:Show()
		end
	else
		if data.circle then
			data.circle:Hide()
		end
		if data.shape.nType ~= 2 or _HM_Area.bUpdateArea then
			data.shape.nType = 2
			_HM_Area.DrawCake(data.shape, tar, color, nRadius, nAlpha)
		else
			data.shape:Show()
		end
	end
end

-- skill select
_HM_Area.GetSkillMenu = function()
	local m0 = {}
	for nRel, szRel in ipairs(_HM_Area.tRelation) do
		local m1 = { szOption = szRel, bCheck = true, }
		m1.bChecked = not _HM_Area.GetHide(nRel)
		m1.fnAction = function(data, bCheck) _HM_Area.SetHide(nRel, nil, not bCheck) end
		for _, v in ipairs(_HM_Area.tSkill) do
			local m2 = nil
			if not v.dwID then
				m2 = { bDevide = true, }
			else
				m2 = { szOption = HM.GetSkillName((v.dwID == 3370 and 3109) or v.dwID), bCheck = true, bColorTable = true, bNotChangeSelfColor = false, }
				m2.bChecked = not _HM_Area.GetHide(nRel, v.dwTemplateID, true)
				m2.rgb = _HM_Area.GetColor(nRel, v.dwTemplateID)
				m2.fnAction = function(data, bCheck) _HM_Area.SetHide(nRel, v.dwTemplateID, not bCheck) end
				m2.fnChangeColor = function(data, r, g, b) _HM_Area.SetColor(nRel, v.dwTemplateID, r, g, b) end
			end
			table.insert(m1, m2)
		end
		table.insert(m0, m1)
	end
	return m0
end

-- add to list
_HM_Area.AddToList = function(tar, dwCaster, dwTime, szEvent)
	local nLeft = _HM_Area.GetTotalLeft(tar.dwTemplateID) * 1000
	_HM_Area.tList[tar.dwID] = { dwCaster = dwCaster, dwTime = dwTime,  nLeft = nLeft, szEvent = szEvent }
end

-- remove record
_HM_Area.RemoveFromList = function(dwID)
	local data = _HM_Area.tList[dwID]
	if data.shape then
		data.shape.nType = nil
		_HM_Area.pDraw:Free(data.shape)
	end
	if data.circle then
		data.circle.nType = nil
		_HM_Area.pDraw:Free(data.circle)
	end
	_HM_Area.tList[dwID] = nil
end

-------------------------------------
-- �¼�������
-------------------------------------
-- skill cast log
_HM_Area.OnSkillCast = function(dwCaster, dwSkillID, dwLevel, szEvent)
	local player = GetPlayer(dwCaster)
	local dwTemplateID = _HM_Area.GetTemplateID(dwSkillID)
	if player and dwTemplateID and _HM_Area.CheckTemplateID(dwTemplateID) then
		table.insert(_HM_Area.tCast, { dwTemplateID = dwTemplateID, dwCaster = dwCaster, dwTime = GetTime(), szEvent = szEvent })
		_HM_Area.Debug("[" .. player.szName .. "] cast [" .. HM.GetSkillName(dwSkillID, dwLevel) .. "#" .. szEvent .. "]")
	end
end

-- npc enter
_HM_Area.OnNpcEnter = function()
	local tar = GetNpc(arg0)
	if not tar or _HM_Area.tList[arg0] or not _HM_Area.CheckTemplateID(tar.dwTemplateID) then
		return
	end
	_HM_Area.Debug("[" .. tar.szName .. "] enter scene")
	-- caster
	local f, dwCaster, dwTime, szEvent = nil, 0, 0, ""
	for k, v in ipairs(_HM_Area.tCast) do
		if v.dwTemplateID == tar.dwTemplateID then
			local nTime = GetTime() - v.dwTime
			_HM_Area.Debug("checking [" .. tar.szName .. "], delay [" .. nTime .. "]")
			if nTime < 3000 and tar.dwEmployer == v.dwCaster then
				f = k
				break
			elseif not f and nTime > _HM_Area.nMinDelay and nTime < _HM_Area.nMaxDelay then
				f = k
			end
		end
	end
	if f ~= nil then
		local v = _HM_Area.tCast[f]
		dwCaster, dwTime, szEvent = v.dwCaster, v.dwTime, v.szEvent
		table.remove(_HM_Area.tCast, f)
		_HM_Area.Debug("matched [" .. tar.szName .. "] casted by [#" .. dwCaster .. "]")
	end
	-- purge
	if dwCaster == 0 then
		local nTime = GetTime()
		for k, v in ipairs(_HM_Area.tCast) do
			if (nTime - v.dwTime) > 3000 then
				table.remove(_HM_Area.tCast, k)
			end
		end
		-- new version
		if tar.dwEmployer and tar.dwEmployer ~= 0 then
			dwCaster = tar.dwEmployer
		end
	end
	-- check hide (force to record my target)
	local _, tarID = GetClientPlayer().GetTarget()
	if (tarID == 0 or tarID ~= dwCaster)
		and _HM_Area.GetHide(_HM_Area.GetRelation(dwCaster, tar), tar.dwTemplateID)
	then
		return _HM_Area.Debug("ignore hidden [" .. tar.szName .. "]")
	end
	_HM_Area.AddToList(tar, dwCaster, dwTime, szEvent)
end

-------------------------------------
-- ���ں���
-------------------------------------
-- create
function HM_Area.OnFrameCreate()
	-- label shadow
	_HM_Area.pLabel = this:Lookup("", "Shadow_Label")
	_HM_Area.pLabel:SetTriangleFan(GEOMETRY_TYPE.TEXT)
	-- draw pool
	local hnd = this:Lookup("", "Handle_Draw")
	local xml = "<shadow>w=1 h=1 lockshowhide=1</shadow>"
	_HM_Area.pDraw = HM.HandlePool(hnd, xml)
	-- events
	this:RegisterEvent("SYS_MSG")
	this:RegisterEvent("NPC_ENTER_SCENE")
	this:RegisterEvent("DO_SKILL_CAST")
end

-- breathe
function HM_Area.OnFrameBreathe()
	local nCount, nTime = 0, GetTime()
	_HM_Area.pLabel:ClearTriangleFanPoint()
	for k, v in pairs(_HM_Area.tList) do
		local tar = GetNpc(k)
		local nLeft = v.nLeft + v.dwTime - nTime
		if not tar and (nLeft < 0 or v.dwTime == 0) then
			_HM_Area.RemoveFromList(k)
		else
			if not tar or nCount >= HM_Area.nMaxNum
				or not _HM_Area.CheckTemplateID(tar.dwTemplateID)
				or _HM_Area.GetHide(_HM_Area.GetRelation(v.dwCaster, tar), tar.dwTemplateID)
			then
				if v.shape then v.shape:Hide() end
				if v.circle then v.circle:Hide() end
			else
				nCount = nCount + 1
				_HM_Area.DrawArea(tar)
				if HM_Area.bShowName then
					_HM_Area.ShowName(tar)
				end
			end
		end
	end
	_HM_Area.bUpdateArea = false
end

-- event
function HM_Area.OnEvent(event)
	if event == "SYS_MSG" then
		if arg0 == "UI_OME_SKILL_HIT_LOG" and arg3 == SKILL_EFFECT_TYPE.SKILL then
			_HM_Area.OnSkillCast(arg1, arg4, arg5, arg0)
		elseif arg0 == "UI_OME_SKILL_EFFECT_LOG" and arg4 == SKILL_EFFECT_TYPE.SKILL then
			_HM_Area.OnSkillCast(arg1, arg5, arg6, arg0)
		end
	elseif event == "NPC_ENTER_SCENE" then
		_HM_Area.OnNpcEnter()
	elseif event == "DO_SKILL_CAST" then
		_HM_Area.OnSkillCast(arg0, arg1, arg2, event)
	end
end

-------------------------------------
-- ���ý���
-------------------------------------
_HM_Area.PS = {}

-- init
_HM_Area.PS.OnPanelActive = function(frame)
	local ui = HM.UI(frame)
	local bCopy = HM.IsDunegon()
	-- feature
	ui:Append("Text", { txt = _L["Options"], font = 27 })
	ui:Append("WndCheckBox", { txt = _L["Display gas field range of CY"], x = 10, y = 28, checked = HM_Area.bQichang, enable = not bCopy })
	:Click(function(bChecked)
		HM_Area.bQichang = bChecked
		ui:Fetch("Check_Big"):Enable(bChecked)
	end)
	local nX = ui:Append("WndCheckBox", { txt = _L["Display organ/trap range of TM"], x = 10, y = 56, checked = HM_Area.bJiguan, enable = not bCopy })
	:Click(function(bChecked)
		HM_Area.bJiguan = bChecked
	end):Pos_()
	ui:Append("WndCheckBox", { txt = _L["Show the head name"], x = nX + 10, y = 56, checked = HM_Area.bShowName })
	:Click(function(bChecked)
		HM_Area.bShowName = bChecked
	end)
	ui:Append("WndCheckBox", { txt = _L["Display sound range of CG"], x = nX + 10, y = 28, checked = HM_Area.bYinyu, enable = not bCopy })
	:Click(function(bChecked)
		HM_Area.bYinyu = bChecked
	end)
	ui:Append("WndCheckBox", "Check_Big", { txt = _L["Always display 11 feet range of SHENGTAIJI"], x = 10, y = 84, checked = HM_Area.bBigTaiji })
	:Enable(HM_Area.bQichang):Click(function(bChecked)
		HM_Area.bBigTaiji = bChecked
		_HM_Area.bUpdateArea = true
	end)
	ui:Append("WndComboBox", { txt = _L["Select range type"], x = 12, y = 114 }):Menu(_HM_Area.GetSkillMenu)
	-- others
	ui:Append("Text", { txt = _L["Others"], font = 27, x = 0, y = 150 })
	nX = ui:Append("Text", { txt = _L["Maximum display number of ranges"], x = 10, y = 178 }):Pos_()
	ui:Append("WndTrackBar", { x = nX + 5, y = 180, txt = "" })
	:Range(0, 20, 20):Value(HM_Area.nMaxNum):Change(function(nVal) HM_Area.nMaxNum = nVal end)
	nX = ui:Append("Text", { txt = _L["Display transparency of ranges "], x = 10, y = 206 }):Pos_()
	ui:Append("WndTrackBar", { x = nX + 5, y = 208 })
	:Range(0, 100, 50):Value(100 - math.floor(HM_Area.nAlpha/2)):Change(function(nVal)
		HM_Area.nAlpha = 200 - nVal - nVal
		_HM_Area.bUpdateArea = true
	end)
	-- tips
	ui:Append("Text", { txt = _L["Tips"], x = 0, y = 242, font = 27 })
	ui:Append("Text", { txt = _L["Vesting is based on skill cast time, may incorrect when lots of players"], x = 10, y = 270 })
end

-- conflict
_HM_Area.PS.OnConflictCheck = function()
end

---------------------------------------------------------------------
-- ע���¼�����ʼ��
---------------------------------------------------------------------
-- add to HM panel
HM.RegisterPanel(_L["Gas/Organ range"], 613, nil, _HM_Area.PS)

-- open hidden window
local frame = Station.Lookup("Lowest/HM_Area")
if frame then Wnd.CloseWindow(frame) end
Wnd.OpenWindow(_HM_Area.szIniFile, "HM_Area")
