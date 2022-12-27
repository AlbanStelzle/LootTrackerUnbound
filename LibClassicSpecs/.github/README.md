# LibClassicSpecs [![Actions Status](https://github.com/tstirrat/LibClassicSpecs/workflows/CI/badge.svg)](https://github.com/tstirrat/LibClassicSpecs/actions) [![Coverage Status](https://coveralls.io/repos/github/tstirrat/LibClassicSpecs/badge.svg?branch=master)](https://coveralls.io/github/tstirrat/LibClassicSpecs?branch=master)

Restores the retail specialization methods in Classic

Where possible this uses the same global spec ids as in retail.

## Usage

```lua
local LibClassicSpecs = LibStub("LibClassicSpecs")

local MAX_TALENT_TIERS                = _G.MAX_TALENT_TIERS or LibClassicSpecs.MAX_TALENT_TIERS
local NUM_TALENT_COLUMNS              = _G.NUM_TALENT_COLUMNS or LibClassicSpecs.NUM_TALENT_COLUMNS

local GetNumClasses                   = _G.GetNumClasses or LibClassicSpecs.GetNumClasses
local GetClassInfo                    = _G.GetClassInfo or LibClassicSpecs.GetClassInfo
local GetNumSpecializationsForClassID = _G.GetNumSpecializationsForClassID or LibClassicSpecs.GetNumSpecializationsForClassID

local GetActiveSpecGroup              = _G.GetActiveSpecGroup or LibClassicSpecs.GetActiveSpecGroup

local GetSpecialization               = _G.GetSpecialization or LibClassicSpecs.GetSpecialization
local GetSpecializationInfo           = _G.GetSpecializationInfo or LibClassicSpecs.GetSpecializationInfo
local GetSpecializationInfoForClassID = _G.GetSpecializationInfoForClassID or LibClassicSpecs.GetSpecializationInfoForClassID

local GetSpecializationRole           = _G.GetSpecializationRole or LibClassicSpecs.GetSpecializationRole
local GetSpecializationRoleByID       = _G.GetSpecializationRoleByID or LibClassicSpecs.GetSpecializationRoleByID


-- Useful constants/enums
local Role = LibClassicSpecs.Role
local Class = LibClassicSpecs.Class
local Stat = LibClassicSpecs.Stat

Class.Warrior.ID -- 1
Class.Warrior.name -- "WARRIOR"
Class.Warrior.Arms -- 71 (same as in retail)
Stat.Agility  -- 2
Role.Damager  -- "DAMAGER"

GetSpecializationInfoForClassID(Class.Warrior.ID, 1) -- 71 (Warrior.Arms), "Arms"
```

### GetNumClasses

There are 9 classes in classic, but they are NOT the first 9 ids. Druids are
class ID 11 even in classic.

Therefore `GetNumClasses()` returns all retail classes (12), this is essential
for the case where your addon tries to iterate classes. It should receive usable
class ids:

```lua
for classId = 1, GetNumClasses() do
  local specId, specName = GetSpecializationInfoForClassID(classId, 1)

  local displayName, internalName == GetClassInfo(classId)

  if (UnitClass("player") == classId) then
    print("You are playing a", displayName)
    -- You are playing a Warrior
  end

  print("Class", internalName, "has spec", specName, "with id", specId)
  -- Class WARRIOR has spec Arms with id 71
end
```

## Contributing

### Repo setup

```sh
.bin/init.sh
```

### Running tests

```sh
.bin/test.sh
```
