local players = {}
local text_font = "default"
local max_text_width = 400 -- in pixels

local margin = 5
local oneLineHeight = dxGetFontHeight(1, text_font)

local enabled = false

function bindPD()
  bindKey ( "lalt", "down", showNearbyPlayerDescriptions )
  bindKey ( "lalt", "up", RemovePD )
  bindKey ( "ralt", "down", toggleNearbyPlayerDescriptions )
end
addEventHandler ( "onClientResourceStart", resourceRoot, bindPD )

function toggleNearbyPlayerDescriptions()
	if enabled then
		RemovePD()
	else
		showNearbyPlayerDescriptions()
	end
end

function RemovePD( key, keyState )
	if enabled then
		enabled = false
        players = {}
		removeEventHandler ( "onClientRender", getRootElement(), showPlayerNote )
	end
end

local function wrapText(itemValue)
	local text = { "" }

	local splitItems = split(tostring(itemValue), ' ')
	for _, word in ipairs(splitItems) do
		local last_line = text[#text]
		if dxGetTextWidth(last_line .. word, 1, text_font) < max_text_width then
			if #last_line == 0 then
				text[#text] = word
			else
				text[#text] = last_line .. " " .. word
			end
		else
			table.insert(text, word)
		end
	end
	return text
end

function showNearbyPlayerDescriptions()
    if getElementData(localPlayer, "enableOverlayDescription") == "0" or getElementData(localPlayer, "enableOverlayDescriptionNote") == "0" then
        return
    end
	if not enabled then
		enabled = true
		for index, nearbyPlayer in ipairs( exports.global:getNearbyElements(getLocalPlayer(), "player") ) do
			if isElement(nearbyPlayer) then
                if getElementData(nearbyPlayer, "loggedin") == 1 then
                    if not exports.global:isStaffOnDuty(nearbyPlayer) then
                        local age = getElementData(nearbyPlayer, "age")
                        local race = getElementData(nearbyPlayer, "race")
                        local height = getElementData(nearbyPlayer, "height")
                        local gender = getElementData(nearbyPlayer, "gender")
                        local ageName = ""

                        if gender == 0 then
                            if race == 0 then
                                race = "černý"
                            elseif race == 1 then
                                race = "bílý"
                            elseif race == 2 then
                                race = "žlutý"
                            end
                            gender = "muž"
                            ageName = "letý"
                        else
                            if race == 0 then
                                race = "černá"
                            elseif race == 1 then
                                race = "bílá"
                            elseif race == 2 then
                                race = "žlutá"
                            end
                            gender = "žena"
                            ageName = "letá"
                        end

                        desc = "Přibližně "..age - 2 .." až "..age + 2 .." "..ageName.." "..race.. " "..gender.." o přibližné výšce "..height - 5 .." až "..height + 5 .." cm."
                        players[nearbyPlayer] = wrapText(desc)
                    end
                end
			end
		end
		addEventHandler("onClientRender", getRootElement(), showPlayerNote)
	end
end

function showPlayerNote()
	for theObject, note_text in pairs(players) do
		if not isElement(theObject) then
			players[theObject] = nil
		else
			local x,y,z = getElementPosition(theObject)
			local cx, cy, cz = getCameraMatrix()
			if getDistanceBetweenPoints3D(cx,cy,cz,x,y,z) <= 15 then
				local px,py = getScreenFromWorldPosition(x,y,z+0.2,0.05)
				if px and isLineOfSightClear(cx, cy, cz, x, y, z, false, false, false, true, true, false, false) then

					local lines = #note_text
					local toBeShowed = table.concat(note_text, "\n")
					local fontHeight = oneLineHeight * lines
					local fontWidth = dxGetTextWidth(toBeShowed, 1, text_font)
					px = px-(fontWidth/2)

					dxDrawRectangle(px- margin, py- margin, fontWidth+(margin *2), fontHeight+(margin *2), tocolor(0, 0, 0, 50))
					dxDrawRectangleBorder(px- margin, py- margin, fontWidth+(margin *2), fontHeight+(margin *2), 1, tocolor(197, 95, 19, 155), true)
					dxDrawText(toBeShowed, px, py, px + fontWidth, (py + fontHeight), tocolor(255, 255, 255, 255), 1, text_font, "left")
				end
			end
		end
	end
end
function dxDrawRectangleBorder(x, y, width, height, borderWidth, color, out, postGUI)
	if out then
		--[[Left]]	dxDrawRectangle(x - borderWidth, y, borderWidth, height, color, postGUI)
		--[[Right]]	dxDrawRectangle(x + width, y, borderWidth, height, color, postGUI)
		--[[Top]]	dxDrawRectangle(x - borderWidth, y - borderWidth, width + (borderWidth * 2), borderWidth, color, postGUI)
		--[[Botm]]	dxDrawRectangle(x - borderWidth, y + height, width + (borderWidth * 2), borderWidth, color, postGUI)
	else
		local halfW = width / 2
		local halfH = height / 2
		--[[Left]]	dxDrawRectangle(x, y, math.clip(0, borderWidth, halfW), height, color, postGUI)
		--[[Right]]	dxDrawRectangle(x + width - math.clip(0, borderWidth, halfW), y, math.clip(0, borderWidth, halfW), height, color, postGUI)
		--[[Top]]	dxDrawRectangle(x + math.clip(0, borderWidth, halfW), y, width - (math.clip(0, borderWidth, halfW) * 2), math.clip(0, borderWidth, halfH), color, postGUI)
		--[[Botm]]	dxDrawRectangle(x + math.clip(0, borderWidth, halfW), y + height - math.clip(0, borderWidth, halfH), width - (math.clip(0, borderWidth, halfW) * 2), math.clip(0, borderWidth, halfH), color, postGUI)
	end
end
