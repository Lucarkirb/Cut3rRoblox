--Code is made by ROBLOX.
--Its part of the CSG tools example place.
--This module may get replaced by my own solution in the future. 

local ConstraintsModule = {}


ConstraintsModule.substitutePart = function(constraintsTable, partToSubstitute, partToSubstituteWith)
	for _, item in pairs(constraintsTable) do
		if (item.Attachment) then
			if item.ConstraintParent == partToSubstitute then
				item.ConstraintParent = partToSubstituteWith
			end
			if item.AttachmentParent==partToSubstitute then
				item.AttachmentParent=partToSubstituteWith
			end
		elseif (item.NoCollisionConstraint) then
			if item.NoCollisisonPart0 == partToSubstitute then
				item.NoCollisisonPart0 = partToSubstituteWith
			end
			if item.NoCollisisonPart1 == partToSubstitute then
				item.NoCollisisonPart1 = partToSubstituteWith
			end
			if item.NoCollisisonParent == partToSubstitute then 
				item.NoCollisisonParent = partToSubstituteWith
			end
		elseif (item.WeldConstraint) then
			if item.WeldConstraintParent ~= nil then
				if item.WeldConstraintPart0 == partToSubstitute then
					item.WeldConstraintPart0 = partToSubstituteWith
				end
				if item.WeldConstraintPart1 == partToSubstitute then
					item.WeldConstraintPart1 = partToSubstituteWith
				end
				if item.WeldConstraintParent == partToSubstitute then
					item.WeldConstraintParent = partToSubstituteWith
				end
			end
		end
	end
end

ConstraintsModule.preserveConstraints = function(constraintsTable)
	local weldConstraintVisited = {}
	for _, item in pairs(constraintsTable) do
		if (item.Attachment) then
			item.Constraint.Parent = item.ConstraintParent
			item.Attachment.Parent = item.AttachmentParent
		elseif (item.NoCollisionConstraint) then
			local newNoCollisison = Instance.new("NoCollisionConstraint")
			newNoCollisison.Part0 = item.NoCollisisonPart0
			newNoCollisison.Part1 = item.NoCollisisonPart1
			newNoCollisison.Parent = item.NoCollisisonParent
		elseif (item.WeldConstraint) then
			if item.WeldConstraintParent == nil then
				item.WeldConstraint.Parent = nil
			else
				local newWeldConstraint
				if weldConstraintVisited[item.WeldConstraint] == true then
					newWeldConstraint = Instance.new("WeldConstraint")
				else
					newWeldConstraint = item.WeldConstraint
					weldConstraintVisited[item.WeldConstraint] = true
				end
				newWeldConstraint.Part0 = item.WeldConstraintPart0
				newWeldConstraint.Part1 = item.WeldConstraintPart1
				newWeldConstraint.Parent = item.WeldConstraintParent
			end
		end
	end
end

ConstraintsModule.dropConstraints = function(constraintsTable)
	for _, item in pairs(constraintsTable) do
		if (item.Attachment) then
			if item.ConstraintParent == nil then
				item.Constraint.Parent = nil
			end
			if item.AttachmentParent == nil then
				item.Attachment.Parent = nil
			end
		elseif (item.WeldConstraint) then
			if item.WeldConstraintParent == nil then
				item.WeldConstraint.Parent = nil
			end
		end
	end
end

return ConstraintsModule
