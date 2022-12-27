TOCNAME, LTU = ...
LootTrackerUnbound = {}
L = setmetatable({}, {__index = function(_, k) return LTU.L[k] end})
LootTrackerUnbound.LootTrackerUnbound_LootsDB = {}
LootTrackerUnbound.LootTrackerUnbound_SessionHistory = {}
LootTrackerUnbound.LootTrackerUnboundDB = {}