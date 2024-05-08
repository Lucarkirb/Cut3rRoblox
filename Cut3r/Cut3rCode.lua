--WARNING: THIS CODE DOES NOT HAVE ITS DEPENDANTCIES, WHICH ARE SUPER IMPORTANT FOR THE CODE TO FUNCTION!!!
--WE RECCOMMEND USING THE .RBXM VERSION OR THE MODULE FOUND IN THE DEMO PLACE FILE
--THIS CODE IS ONLY MENT FOR VIEWING.

local Cut = {}
--[[welcome to Cut3r
		
		This is offical release 3.
		Visit devfourm/github for code usage.
        

]]

local Settings = {
	--toggles
	OverrideLimits = false,
	--Limits
	IterationLimit = 100,
}



--internal 

local function resize(part:BasePart,increment)
	part.Size += Vector3.new(math.abs(increment),0,0)
	part.CFrame *= CFrame.new(increment/2,0, 0)
end

local function internalCSGSlice(Part,newSlicer,Extension,UCFO,offset)

	if UCFO then
		
		newSlicer.CFrame = Part.CFrame:ToWorldSpace(offset)
		
	else
		newSlicer.CFrame = offset
	end
	local Tags = game:GetService("CollectionService"):GetTags(Part)
	local NegateThing : Part = newSlicer:Clone()
	NegateThing.Parent = workspace
	NegateThing.CFrame = newSlicer.CFrame
	NegateThing.Size = Vector3.new(0.05,Extension,Extension)
	resize(NegateThing,Extension)
	NegateThing:ClearAllChildren()
	NegateThing.Material = Part.Material
	NegateThing.Transparency = 1
	local newPart_Right:UnionOperation = Part:SubtractAsync({NegateThing})
	if newPart_Right then
		
		newPart_Right.UsePartColor = true
		newPart_Right.Parent = Part.Parent
		newPart_Right.Anchored = false
		local PartInternals = Part:GetChildren()
		for i,Child in pairs(PartInternals) do
			Child.Parent = newPart_Right
		end
		newPart_Right.Name = Part.Name.."_1"
		
		NegateThing:Destroy()

	else
		warn("Cut3r Failure: Slice() negate was unsuccessfull")
		NegateThing:Destroy()
		return
	end
	--side2
	local NegateThing : Part = newSlicer:Clone()
	NegateThing.Parent = workspace
	NegateThing.CFrame = newSlicer.CFrame
	NegateThing.Size = Vector3.new(0.05,Extension,Extension)
	resize(NegateThing,0-Extension)
	NegateThing:ClearAllChildren()
	NegateThing.Material = Part.Material
	NegateThing.Transparency = 1
	local newPart_Left:UnionOperation = Part:SubtractAsync({NegateThing})
	if newPart_Left then
		
		newPart_Left.UsePartColor = true
		newPart_Left.Parent = Part.Parent
		newPart_Left.Anchored = false
		local PartInternals = Part:GetChildren()
		for i,Child in pairs(PartInternals) do
			Child.Parent = newPart_Left
		end
		newPart_Left.Name = Part.Name.."_2"

		NegateThing:Destroy()
		Part:Destroy()
		
		
		
		for i,tag in Tags do
			game:GetService("CollectionService"):AddTag(newPart_Left,tag)
			game:GetService("CollectionService"):AddTag(newPart_Right,tag)
		end
		return newPart_Left,newPart_Right
	else
		warn("Cut3r Failure: Slice() negate was unsuccessfull")
		newPart_Right:Destroy()
		NegateThing:Destroy()
		return
	end
end

local function internalSliceTableShatter(Parts,UseCFrameOffset:boolean,Extension:number)
	local newSlicer = script.Slicer:Clone()



	if typeof(Parts) == "table" then
		local returnChildren = {}
		for i,Part:Part in Parts do
			
			local p1,p2 = internalCSGSlice(Part,newSlicer,Extension,UseCFrameOffset,CFrame.fromEulerAngles(math.rad(math.random(0,360)),math.rad(math.random(0,360)),math.rad(math.random(0,360))))
			returnChildren[#returnChildren + 1] = p1
			returnChildren[#returnChildren + 1] = p2

		end
		return returnChildren

	else
		warn("Cut3r Failure: Slice(Parts,UseCFrameOffset,CFrameOffset,Extension) <Part> needs to be a Part or a Model/Folder. Meshparts are not supported by roblox's CSG.")
	end
end

-- the fun stuff, Functions

function Cut:Slice(Parts,UseCFrameOffset:boolean,CFrameOffset:CFrame,Extension:number)
	local newSlicer = script.Slicer:Clone()




	if Parts:IsA("BasePart") then
		local Part = Parts
		if Part:IsA("Part") or Part:IsA("UnionOperation") then


			return internalCSGSlice(Part,newSlicer,Extension,UseCFrameOffset,CFrameOffset)


		end
	elseif Parts:IsA("Model") or Parts:IsA("Folder") then
		local children = Parts:GetChildren()
		local returnChildren = {}
		for i,Part in children do

			returnChildren[i] = internalCSGSlice(Part,newSlicer,Extension,UseCFrameOffset,CFrameOffset)

		end
		return returnChildren

	
	else
		warn("Cut3r Failure: Slice(Parts,UseCFrameOffset,CFrameOffset,Extension) <Part> needs to be a Part or a Model/Folder. Meshparts are not supported by roblox's CSG.")
	end
end

function Cut:SliceTable(Parts,UseCFrameOffset:boolean,CFrameOffset:CFrame,Extension:number)
	local newSlicer = script.Slicer:Clone()



	if typeof(Parts) == "table" then
		local returnChildren = {}
		for i,Part in Parts do
			
			local p1,p2 = internalCSGSlice(Part,newSlicer,Extension,UseCFrameOffset,CFrameOffset)
			returnChildren[#returnChildren + 1] = p1
			returnChildren[#returnChildren + 1] = p2

		end
		return returnChildren

	else
		warn("Cut3r Failure: Slice(Parts,UseCFrameOffset,CFrameOffset,Extension) <Part> needs to be a Part or a Model/Folder. Meshparts are not supported by roblox's CSG.")
	end
end

function Cut:Shatter(Parts:Instance,UseCFrameOffset:boolean,CFrameOffset:CFrame,Extension:number,ExtraIterations:number)
	local newSlicer = script.Slicer:Clone()
	local P1,P2

	if Parts:IsA("BasePart") then
		if ExtraIterations <= Settings.IterationLimit then
			local Part = Parts
			if Part:IsA("Part") or Part:IsA("UnionOperation") then
				P1,P2 = internalCSGSlice(Part,newSlicer,Extension,UseCFrameOffset,CFrame.fromEulerAngles(math.rad(math.random(0,360)),math.rad(math.random(0,360)),math.rad(math.random(0,360))) + CFrameOffset.Position)
				if P1 and P2 then
					local sparts = {P1,P2}


					for i = 0, ExtraIterations  do
						

						
						sparts = internalSliceTableShatter(sparts,true,Extension)

					end
					return sparts
				end
			end
		else
			warn("Cut3r Failure: Shatter(Parts,UseCFrameOffset,CFrameOffset,Extension,ExtraIterations) <ExtraIterations> cannot be the limit of "..tostring(Settings.IterationLimit)..". You can turn this off in the module.")
		end
		
	else
		warn("Cut3r Failure: Shatter(Parts,UseCFrameOffset,CFrameOffset,Extension,ExtraIterations) <Part> needs to be a Part. Meshparts are not supported by roblox's CSG.")

	end

	
	
end

return Cut
