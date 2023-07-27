local ParentFrameName = "SUFUnitplayer" -- Name of the frame to which TotemFrame should be anchored.
local ParentAnchorPosition = "BOTTOMRIGHT"; -- Anchor position of ParentFrame where TotemFrame should be anchored.
local TotemFrameAnchorPosition = "TOPRIGHT"; -- Anchor position of TotemFrame to ParentFrame.
local UseSquareMask = true; -- Use square mask for totem icons.
local XOffset = 7; -- Horizontal offset of TotemFrame from ParentFrame.
local YOffset = 0; -- Vertical offset of TotemFrame from ParentFrame.

-- Create a frame to serve as the new parent for TotemFrame
local IntermediateTotemFrame = CreateFrame("Frame", "IntermediateTotemFrame");
IntermediateTotemFrame:SetSize(100, 100);
IntermediateTotemFrame:SetPoint("CENTER");

-- Function to modify the totem button on load
local function ModifyTotemButton(self)
	-- Hide the border
	self.Border:Hide()

	-- Get atlas information for square mask
	local squareMaskAtlas = C_Texture.GetAtlasInfo("SquareMask")
	local left, right, top, bottom = squareMaskAtlas.leftTexCoord, squareMaskAtlas.rightTexCoord, squareMaskAtlas.topTexCoord, squareMaskAtlas.bottomTexCoord

	-- Set icon texture and coordinates
	self.Icon.TextureMask:SetTexture(squareMaskAtlas.file or squareMaskAtlas.filename)
	self.Icon.TextureMask:SetTexCoord(left, right, top, bottom)

	-- Set swipe texture and coordinates
	local lowTexCoords = { x = left, y = top }
	local highTexCoords = { x = right, y = bottom }
	self.Icon.Cooldown:SetSwipeTexture(squareMaskAtlas.file or squareMaskAtlas.filename)
	self.Icon.Cooldown:SetTexCoordRange(lowTexCoords, highTexCoords)
end

-- Function to re-parent TotemFrame to ParentFrame and adjust position
local function ReparentFrame(self)
	local ParentFrame = _G[ParentFrameName]
	self:SetParent(ParentFrame)
	self:ClearAllPoints()
	self:SetPoint(TotemFrameAnchorPosition, ParentFrame, ParentAnchorPosition, XOffset, YOffset)
end

-- Function to re-parent TotemFrame
local function SetLoadPosition()
	local function checkParentFrameExists()
		if _G[ParentFrameName] then
			ReparentFrame(TotemFrame)
			IntermediateTotemFrame:SetParent(nil)  -- "Destroy" the frame
			IntermediateTotemFrame = nil  -- Let the garbage collector reclaim its memory
		else
			C_Timer.After(1, checkParentFrameExists)
		end
	end
	checkParentFrameExists()
end

-- Function to be called on PLAYER_LOGIN event
local function OnPlayerLogin(self, event)
	-- Re-parent TotemFrame
	SetLoadPosition()

	-- Hook OnShow script to re-parent TotemFrame
	TotemFrame:HookScript("OnShow", ReparentFrame)

	-- Unregister PLAYER_LOGIN event
	self:UnregisterEvent(event)
end

-- Set the parent of TotemFrame to the intermediate frame
TotemFrame:SetParent(IntermediateTotemFrame)

if (UseSquareMask) then
	-- Hook the OnLoad function to modify totem buttons
	hooksecurefunc(TotemButtonMixin, "OnLoad", ModifyTotemButton);
	-- Modify existing totem buttons
	for button in TotemFrame.totemPool:EnumerateActive() do
		ModifyTotemButton(button);
	end
end

-- Register PLAYER_LOGIN event and set OnEvent script
IntermediateTotemFrame:RegisterEvent("PLAYER_LOGIN")
IntermediateTotemFrame:SetScript("OnEvent", OnPlayerLogin)
