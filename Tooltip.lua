local match = string.match
local strsplit = strsplit
local quantity = 1
local shift = ""
local didThisRecipe = false
local function isSoulbound()
	return false
end

local function GameTooltip_OnTooltipSetItem(tooltip)
	local tooltipName, link = tooltip:GetItem()
	if not link then return; end
	if didThisRecipe then 
		didThisRecipe = false 
		return
	end
	local itemString = match(link, "item[%-?%d:]+")
	local _, itemId = strsplit(":", itemString)
	if itemId == "0" and TradeSkillFrame ~= nil and TradeSkillFrame:IsVisible() then
		if (GetMouseFocus():GetName()) == "TradeSkillSkillIcon" then
			itemId = GetTradeSkillItemLink(TradeSkillFrame.selectedSkill):match("item:(%d+):") or nil
		else
			for i = 1, 8 do
				if (GetMouseFocus():GetName()) == "TradeSkillReagent"..i then
					itemId = GetTradeSkillReagentItemLink(TradeSkillFrame.selectedSkill, i):match("item:(%d+):") or nil
					break
				end
			end
		end
	end
	if itemId == "" and CraftFrame:IsVisible() then
		for i = 1, 8 do
			if (GetMouseFocus():GetName()) == "CraftReagent"..i then
				itemId = GetCraftReagentItemLink(GetCraftSelectionIndex(), i):match("item:(%d+):") or nil
				break
			end
		end
	end
	local hitorical = ""
	
	local ah, data, vendorBuy, vendorSell, bank, totalAuctions

	if itemId and not isSoulbound(tooltip, itemId) then
		if itemId == 31 then
			if EnchantingMatsIds[itemName] then
				itemId = EnchantingMatsIds[itemName]
			end
		end
		if IsShiftKeyDown() then
			banknum = GetItemCount(itemId, true) - GetItemCount(itemId, false)
			quantity = GetItemCount(itemId, false)
			if banknum ~= 0 then
				bank = "("..banknum..")"
			else
				bank = ""
			end
			shift = "x"..quantity.." "..Color(bank, 'gray')
			quantity = quantity + banknum
		else
			quantity = 1
			shift = ""
		end
		if ASItemList[tonumber(itemId)] then
			ah = AsFormatPrice(AsGetPrice(itemId), quantity)
			ah = Color(ah, 'white')
			ah = ah:gsub("copper", Color('c','orange'))
			ah = ah:gsub("gold", Color('g','gold'))
			ah = ah:gsub("silver", Color('s','gray'))
			ah = Color(shift, 'white')..ah
			data = AsHowLongSinceLastScan(tonumber(itemId))
			data = Color(data, 'gray')
		end
		if AsVendorList[tonumber(itemId)] then
			vendorBuy = AsFormatPrice(AsVendorList[tonumber(itemId)]["price"], quantity)
			vendorBuy = Color(vendorBuy, 'white')
			vendorBuy = vendorBuy:gsub("copper", Color('c','orange'))
			vendorBuy = vendorBuy:gsub("gold", Color('g','gold'))
			vendorBuy = vendorBuy:gsub("silver", Color('s','gray'))
			vendorBuy = Color(shift, 'white')..vendorBuy
		end
		vendorSell = select(11, GetItemInfo(itemId))
    	if vendorSell ~= 0 then
    		vendorSell = AsFormatPrice(vendorSell, quantity)
    		vendorSell = Color(vendorSell, 'white')
    		vendorSell = vendorSell:gsub("copper", Color('c','orange'))
			vendorSell = vendorSell:gsub("gold", Color('g','gold'))
			vendorSell = vendorSell:gsub("silver", Color('s','gray'))
			vendorSell = Color(shift, 'white')..vendorSell
		end
		if ASItemList[tonumber(itemId)] or AsVendorList[tonumber(itemId)] or vendorSell ~= 0 and not didThisRecipe then
			totalAuctions = ""
			if ASItemList[tonumber(itemId)] and ASItemList[tonumber(itemId)]["quantity"] ~= nil then
				totalAuctions = " ("..ASItemList[tonumber(itemId)]["quantity"]..")"
			end
			tooltip:AddLine(" ") --blank line
			if ah ~= 0 then 
				tooltip:AddDoubleLine("Auction house", ah)
				if IsShiftKeyDown() then
					tooltip:AddDoubleLine("Last scan", data)
				end
				
			end
			if AsVendorList[tonumber(itemId)] then 
				tooltip:AddDoubleLine("Vendor buy", vendorBuy)
			end
			if vendorSell ~= 0 then 
				tooltip:AddDoubleLine("Vendor sell", vendorSell) 
			end
		end
		if string.match(tooltipName, "Recipe") then
			didThisRecipe = true
		end
	end
end

GameTooltip:HookScript("OnTooltipSetItem", GameTooltip_OnTooltipSetItem)
ItemRefTooltip:HookScript("OnTooltipSetItem", GameTooltip_OnTooltipSetItem)