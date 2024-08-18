--WARNING: THIS CODE DOES NOT HAVE ITS DEPENDANTCIES, WHICH ARE SUPER IMPORTANT FOR THE CODE TO FUNCTION!!!
--WE RECCOMMEND USING THE .RBXM VERSION OR THE MODULE FOUND IN THE DEMO PLACE FILE
--THIS CODE IS ONLY MENT FOR VIEWING.

local Cut = {}
--[[welcome to Cut3r
		This is offical release 4.
		Visit devfourm/github for code usage.
]]

local Settings = {
	--toggles
	OverrideLimits = false,
	--Limits
	IterationLimit = 100,
}

--internal 

--services
local GeoService = game:GetService("GeometryService")
local ConstraintSolver = require(script.Constraints) -- Code by Roblox themselves.

local function resize(part:BasePart,increment)
	part.Size += Vector3.new(math.abs(increment),0,0)
	part.CFrame *= CFrame.new(increment/2,0, 0)
end

local options = { --Settings for the Unions, for internalCSGSlice to work, keep split apart true
	RenderFidelity=Enum.RenderFidelity.Automatic,
	CollisionFidelity=Enum.CollisionFidelity.Default,
	SplitApart=true,

}

local constraintOptions = { -- Settings for contstraint preservation
	tolerance = 0.1,
	weldConstraintPreserve = Enum.WeldConstraintPreserve.All
}

local function joinTables(table1,table2)
	local final = {}
	for _,item in table1 do
		table.insert(final,item)
	end
	
	for _,item in table2 do
		table.insert(final,item)
	end
	
	return final
end

local function internalCSGSlice(Part:BasePart,newSlicer,Extension,UCFO,offset)
	
	if UCFO then
		
		newSlicer.CFrame = Part.ExtentsCFrame:ToWorldSpace(offset)
	else
		newSlicer.CFrame = offset
	end
	local Tags = game:GetService("CollectionService"):GetTags(Part)
	local NegateThing : Part = newSlicer:Clone()
	NegateThing.Parent = workspace
	NegateThing.CFrame = newSlicer.CFrame
	NegateThing.Size = Vector3.new(0.05,Extension,Extension)
	NegateThing:ClearAllChildren()
	NegateThing.Material = Part.Material
	NegateThing.Color = Part.Color
	NegateThing.Transparency = 1
	local Results = {}
	
	local status,err = pcall(function()
		Results = GeoService:subtractAsync(Part,{NegateThing},options)
		NegateThing:Destroy()
	end)
	
	if Results and status then
		local recommendedTable = GeoService:CalculateConstraintsToPreserve(Part, Results, constraintOptions)
		ConstraintSolver.preserveConstraints(recommendedTable)
		for i,Item in Results do
			Item.Anchored = false
			for _,tag in Tags do
				game:GetService("CollectionService"):AddTag(Item,tag)
			end
			Item.Parent = workspace
			
		end
		Part:Destroy()
		
		return Results
	else
		warn("Cut3r Failure: CSG operation failed: "..err)
		return false
		
	end
	
	
end

local function internalSliceTableShatter(Parts,UseCFrameOffset:boolean,Extension:number)
	local newSlicer = script.Slicer:Clone()
	local sparts = Parts
	if typeof(Parts) == "table" then
		local returnChildren = {}
		for i,Part:Part in Parts do
			returnChildren = joinTables(returnChildren,internalCSGSlice(Part,newSlicer,Extension,UseCFrameOffset,CFrame.fromEulerAngles(math.rad(math.random(0,360)),math.rad(math.random(0,360)),math.rad(math.random(0,360)))))
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
	local Results
	
	if Parts:IsA("BasePart") then
		if ExtraIterations <= Settings.IterationLimit then
			local Part = Parts
			local sparts = {}
			Results = internalCSGSlice(Part,newSlicer,Extension,UseCFrameOffset,CFrame.fromEulerAngles(math.rad(math.random(0,360)),math.rad(math.random(0,360)),math.rad(math.random(0,360))) + CFrameOffset.Position)
			if Results then
				sparts = Results
				for i = 0, ExtraIterations  do
					sparts = internalSliceTableShatter(sparts,true,Extension)
					print(sparts)
				end
				return sparts
			end
		else
			warn("Cut3r Failure: Shatter(Parts,UseCFrameOffset,CFrameOffset,Extension,ExtraIterations) <ExtraIterations> cannot be the limit of "..tostring(Settings.IterationLimit)..". You can turn this off in the module.")
		end
		
	else
		warn("Cut3r Failure: Shatter(Parts,UseCFrameOffset,CFrameOffset,Extension,ExtraIterations) <Part> needs to be a Part. Meshparts are not supported by roblox's CSG.")

	end

	
	
end

return Cut
