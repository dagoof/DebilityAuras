local frame,events=CreateFrame('FRAME'),{}
local currentBuffs,iconSize={},nil
SLASH_DEBA1='/deba'

function SlashCmdList.DEBA(msg)
	local f={add='ADD_BUFF', remove='REMOVE_BUFF'}
	if not f[msg] then
		print('Currently watched buffs are')
		for buff,_ in pairs(DebilityAurasBuffs) do
			print(buff)
		end
		print('Use "/deba add" or "/deba remove" to edit your buffs being watched')
	else
		StaticPopup_Show(f[msg])
	end
end

local function drawFrame(buff)
	local texPath,stacks=select(3,UnitBuff('Player', buff))
	local f=CreateFrame('FRAME', buff..'frame', UIParent)

	f:SetPoint('CENTER', random(-iconSize,iconSize), random(-iconSize,iconSize)); f:SetWidth(iconSize); f:SetHeight(iconSize)
	local fs=f:CreateFontString(buff,'ARTWORK','GameFontNormalLarge'); fs:SetFont('Fonts\\ARIALN.TTF', iconSize/8, 'OUTLINE'); fs:SetText(stacks>1 and buff..' x'..stacks or buff); fs:SetAllPoints(f)
	local t=f:CreateTexture(nil, 'BACKGROUND'); t:SetTexture(texPath); t:SetAllPoints(f); t:SetAlpha(.4)
	f.texture=t; f:Show()
	return f
end

function events:UNIT_AURA(...)
	if ...=='player' then for buff,_ in pairs(DebilityAurasBuffs) do
		if not currentBuffs[buff] and UnitBuff('Player', buff) then
			currentBuffs[buff]=drawFrame(buff)
		elseif currentBuffs[buff] and not UnitBuff('Player', buff) then
			currentBuffs[buff]:Hide()
			currentBuffs[buff]:SetParent(nil)
			currentBuffs[buff]=nil
		end
	end end
end

function events:ADDON_LOADED(...)
	if ...=='DebilityAuras' then
		print('Use /deba to access DebilityAuras buff options')
		if not DebilityAurasBuffs then
			DebilityAurasBuffs={}
		end
	end
	iconSize=floor(GetScreenHeight()/6)
end

StaticPopupDialogs['ADD_BUFF']={
	text='Enter the exact name of the buff to watch for.',
	button1='Confirm',
	button2='Cancel',
	timeout=0,
	whileDead=true,
	hideOnEscape=true,
	hasEditBox=true,
	OnAccept=function(self, data, data2)
		DebilityAurasBuffs[self.editBox:GetText()]=true
	end,
}

StaticPopupDialogs['REMOVE_BUFF']={
	text='Enter the exact name of the buff to stop watching.',
	button1='Confirm',
	button2='Cancel',
	timeout=0,
	whileDead=true,
	hideOnEscape=true,
	hasEditBox=true,
	OnAccept=function(self, data, data2)
		DebilityAurasBuffs[self.editBox:GetText()]=nil
	end,
}

frame:SetScript('OnEvent', function(self, event, ...)
	events[event](self, ...)
end)

for k,_ in pairs(events) do
	frame:RegisterEvent(k)
end
