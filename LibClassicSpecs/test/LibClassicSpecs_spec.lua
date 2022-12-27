_G.strmatch = string.match
require("Lib/LibStub/LibStub")

require("LibClassicSpecs")

insulate("LibClassicSpecs", function()
  local lib
  local Role
  local Class

  before_each(function()
    lib = LibStub("LibClassicSpecs")
    Role = lib.Role
    Class = lib.Class
  end)

  describe("GetActiveSpecGroup", function()
    it("always returns 1", function()
      assert.are.equal(1, lib.GetActiveSpecGroup())
    end)
  end)  -- GetActiveSpecGroup

  describe("GetNumClasses", function()
    it("always returns 12", function()
      assert.are.equal(12, lib.GetNumClasses())
    end)
  end)  -- GetNumClasses

  describe("GetClassInfo", function()
    it("returns the info for given class id", function()
      local engName, name, id = lib.GetClassInfo(Class.Priest.ID)
      assert.are.equal(5, id)
      assert.are.equal("PRIEST", name)
      assert.are.equal("Priest", engName)
    end)

    it("returns nil for invalid class id", function()
      assert.is_nil(lib.GetClassInfo(-1))
      assert.is_nil(lib.GetClassInfo(0))
      assert.is_nil(lib.GetClassInfo(13))
    end)
  end)  -- GetClassInfo

  describe("GetNumSpecializationsForClassID", function()
    it("returns 3 for most classes", function()
      assert.are.equal(3, lib.GetNumSpecializationsForClassID(Class.Warrior.ID))
      assert.are.equal(3, lib.GetNumSpecializationsForClassID(Class.Priest.ID))
      assert.are.equal(3, lib.GetNumSpecializationsForClassID(Class.Paladin.ID))
      assert.are.equal(3, lib.GetNumSpecializationsForClassID(Class.Mage.ID))
      assert.are.equal(3, lib.GetNumSpecializationsForClassID(Class.Warlock.ID))
      assert.are.equal(3, lib.GetNumSpecializationsForClassID(Class.Hunter.ID))
      assert.are.equal(3, lib.GetNumSpecializationsForClassID(Class.Shaman.ID))
    end)

    it("returns 4 for Druid", function()
      assert.are.equal(4, lib.GetNumSpecializationsForClassID(Class.Druid.ID))
    end)

    it("returns 2 for Demon Hunter", function()
      assert.are.equal(2, lib.GetNumSpecializationsForClassID(Class.DH.ID))
    end)

    it("returns nil for invalid class id", function()
      assert.is_nil(lib.GetNumSpecializationsForClassID(14))
      assert.is_nil(lib.GetNumSpecializationsForClassID(0))
      assert.is_nil(lib.GetNumSpecializationsForClassID(-1))
    end)
  end)  -- GetNumSpecializationsForClassID

  describe("GetSpecialization", function()
    local TALENTS_17_34_0 = {17, 34, 0}
    before_each(function()
      _G.UnitClass = function() return "", Class.Warrior.ID, Class.Warrior.ID end
      _G.GetNumTalentTabs = function() return 3 end

      _G.GetNumTalents = function() return 17 end

      _G.GetTalentTabInfo = function(tabIndex, talentIndex)
        local spent = TALENTS_17_34_0[tabIndex] or 0
        return nil, nil, spent, nil
      end
    end)

    it("returns the tabIndex for the tab with most spent talent points", function()
      assert.are.equal(2, lib.GetSpecialization())
    end)

    it("returns nil for isInspect", function()
      assert.is_nil(lib.GetSpecialization(true))
    end)

    it("returns nil for isPet", function()
      assert.is_nil(lib.GetSpecialization(nil, true))
    end)

    describe("for druids", function()
      before_each(function()
        _G.UnitClass = function() return "", Class.Druid.name, Class.Druid.ID end

        local FERAL = {14, 32, 5}
        _G.GetTalentTabInfo = function(tabIndex, talentIndex)
          local spent = FERAL[tabIndex] or 0
          return nil, nil, spent, nil
        end

        _G.GetTalentInfo = function(tabIndex, talentIndex)
          return nil, nil, nil, nil, 0
        end
      end)

      it("returns Guardian index (3) if certain talent points are selected", function()
        _G.GetTalentInfo = function(tabIndex, talentIndex)
          return nil, nil, nil, nil, 5
        end
        assert.are.equal(3, lib.GetSpecialization())
      end)

      it("returns Feral index (2) if certain talent points are not selected", function()
        assert.are.equal(2, lib.GetSpecialization())
      end)

      it("returns Resto index (4) if Resto has more points", function()
        local RESTO = {12, 0, 39}
        _G.GetTalentTabInfo = function(tabIndex, talentIndex)
          local spent = RESTO[tabIndex] or 0
          return nil, nil, spent, nil
        end
        assert.are.equal(4, lib.GetSpecialization())
      end)

      it("returns Balance index (1) if Balance has more points", function()
        local BALANCE = {37, 0, 14}
        _G.GetTalentTabInfo = function(tabIndex, talentIndex)
          local spent = BALANCE[tabIndex] or 0
          return nil, nil, spent, nil
        end
        assert.are.equal(1, lib.GetSpecialization())
      end)
    end)  -- for druids
  end)  -- GetSpecialization

  describe("GetInspectSpecialization", function()
    it("ralways returns nil", function()
      assert.is_nil(lib.GetInspectSpecialization("party1"))
      assert.is_nil(lib.GetInspectSpecialization("target"))
    end)
  end)  -- GetInspectSpecialization

  describe("GetSpecializationRole", function()
    before_each(function()
      _G.UnitClass = function()
        return "", Class.Warrior.name, Class.Warrior.ID
      end
    end)

    it("returns a role for each specIndex for the current class", function()
      assert.are.equal(Role.Damager, lib.GetSpecializationRole(1))  -- Warrior.Arms
      assert.are.equal(Role.Damager, lib.GetSpecializationRole(2))  -- Warrior.Fury
      assert.are.equal(Role.Tank, lib.GetSpecializationRole(3))  -- Warrior.Prot
    end)

    it("returns nil for isInspect", function()
      assert.is_nil(lib.GetSpecializationRole(1, true))
    end)

    it("returns nil for isPet", function()
      assert.is_nil(lib.GetSpecializationRole(1, false, true))
    end)
  end)  -- GetSpecializationRole

  describe("GetSpecializationInfoForClassID", function()
    before_each(function()
      _G.UnitClass = function()
        return "", Class.Warrior.name, Class.Warrior.ID
      end
    end)

    it("returns nil on invalid classId", function()
      assert.is_nil(lib.GetSpecializationInfoForClassID(0))
      assert.is_nil(lib.GetSpecializationInfoForClassID(12))
      assert.is_nil(lib.GetSpecializationInfoForClassID(-1))
    end)

    it("returns nil on invalid specIndex", function()
      assert.is_nil(lib.GetSpecializationInfoForClassID(Class.Warrior.ID, 0))
      assert.is_nil(lib.GetSpecializationInfoForClassID(Class.Warrior.ID, 5))
      assert.is_nil(lib.GetSpecializationInfoForClassID(Class.Warrior.ID, -1))
    end)

    it("returns spec info for a valid class/spec", function()
      local ID, name, description, icon, role, isRecommended, isAllowed = lib.GetSpecializationInfoForClassID(Class.Warrior.ID, 1)
      assert.are.equal(Class.Warrior.Arms, ID)
      assert.are.equal("Arms", name)
      assert.are.equal(Role.Damager, role)

      ID, name, description, icon, role, isRecommended, isAllowed = lib.GetSpecializationInfoForClassID(Class.Priest.ID, 1)
      assert.are.equal(Class.Priest.Disc, ID)
      assert.are.equal("Discipline", name)
      assert.are.equal(Role.Healer, role)
    end)

    it("returns isAllowed == true for the current class", function()
      local isAllowed = select(7, lib.GetSpecializationInfoForClassID(Class.Warrior.ID, 1))
      assert.True(isAllowed)
    end)

    it("returns isAllowed == false for the any other class", function()
      local isAllowed = select(7, lib.GetSpecializationInfoForClassID(Class.Priest.ID, 1))
      assert.False(isAllowed)
    end)
  end)  -- GetSpecializationInfoForClassID

  describe("GetSpecializationInfo", function()
    before_each(function()
      _G.UnitClass = function()
        return "", Class.Warrior.name, Class.Warrior.ID
      end
    end)

    it("returns nil on isInspect", function()
      assert.is_nil(lib.GetSpecializationInfo(1, true))
    end)

    it("returns nil on isPet", function()
      assert.is_nil(lib.GetSpecializationInfo(1, false, true))
    end)

    it("returns nil on invalid specIndex", function()
      assert.is_nil(lib.GetSpecializationInfo(5))
      assert.is_nil(lib.GetSpecializationInfo(0))
      assert.is_nil(lib.GetSpecializationInfo(-1))
    end)

    it("returns spec info for the current class's specIndex", function()
      local ID, name, description, icon, bg, role, primaryStat = lib.GetSpecializationInfo(1)
      assert.are.equal(Class.Warrior.Arms, ID)
      assert.are.equal("Arms", name)
      assert.are.equal(Role.Damager, role)
      assert.are.equal(lib.Stat.Strength, primaryStat)

      ID, name, description, icon, bg, role, primaryStat = lib.GetSpecializationInfo(3)
      assert.are.equal(Class.Warrior.Prot, ID)
      assert.are.equal("Protection", name)
      assert.are.equal(Role.Tank, role)
      assert.are.equal(lib.Stat.Strength, primaryStat)
    end)
  end)  -- GetSpecializationInfo

  describe("GetSpecializationRoleByID", function()
    it("returns a role for each class spec", function()
      assert.are.equal(Role.Damager, lib.GetSpecializationRoleByID(Class.Warrior.Arms))
      assert.are.equal(Role.Damager, lib.GetSpecializationRoleByID(Class.Warrior.Fury))
      assert.are.equal(Role.Tank, lib.GetSpecializationRoleByID(Class.Warrior.Prot))

      assert.are.equal(Role.Healer, lib.GetSpecializationRoleByID(Class.Paladin.Holy))
      assert.are.equal(Role.Tank, lib.GetSpecializationRoleByID(Class.Paladin.Prot))
      assert.are.equal(Role.Damager, lib.GetSpecializationRoleByID(Class.Paladin.Ret))

      assert.are.equal(Role.Damager, lib.GetSpecializationRoleByID(Class.Hunter.BM))
      assert.are.equal(Role.Damager, lib.GetSpecializationRoleByID(Class.Hunter.MM))
      assert.are.equal(Role.Damager, lib.GetSpecializationRoleByID(Class.Hunter.SV))

      assert.are.equal(Role.Damager, lib.GetSpecializationRoleByID(Class.Rogue.Combat))
      assert.are.equal(Role.Damager, lib.GetSpecializationRoleByID(Class.Rogue.Assasin))
      assert.are.equal(Role.Damager, lib.GetSpecializationRoleByID(Class.Rogue.Sub))

      assert.are.equal(Role.Healer, lib.GetSpecializationRoleByID(Class.Priest.Disc))
      assert.are.equal(Role.Healer, lib.GetSpecializationRoleByID(Class.Priest.Holy))
      assert.are.equal(Role.Damager, lib.GetSpecializationRoleByID(Class.Priest.Shadow))

      assert.are.equal(Role.Damager, lib.GetSpecializationRoleByID(Class.Shaman.Ele))
      assert.are.equal(Role.Damager, lib.GetSpecializationRoleByID(Class.Shaman.Enh))
      assert.are.equal(Role.Healer, lib.GetSpecializationRoleByID(Class.Shaman.Resto))

      assert.are.equal(Role.Damager, lib.GetSpecializationRoleByID(Class.Mage.Arcane))
      assert.are.equal(Role.Damager, lib.GetSpecializationRoleByID(Class.Mage.Fire))
      assert.are.equal(Role.Damager, lib.GetSpecializationRoleByID(Class.Mage.Frost))

      assert.are.equal(Role.Damager, lib.GetSpecializationRoleByID(Class.Warlock.Affl))
      assert.are.equal(Role.Damager, lib.GetSpecializationRoleByID(Class.Warlock.Demo))
      assert.are.equal(Role.Damager, lib.GetSpecializationRoleByID(Class.Warlock.Destro))

      assert.are.equal(Role.Damager, lib.GetSpecializationRoleByID(Class.Druid.Balance))
      assert.are.equal(Role.Damager, lib.GetSpecializationRoleByID(Class.Druid.Feral))
      assert.are.equal(Role.Healer, lib.GetSpecializationRoleByID(Class.Druid.Resto))
      assert.are.equal(Role.Tank, lib.GetSpecializationRoleByID(Class.Druid.Guardian))
    end)

    it("returns nil for an invalid specId", function()
      assert.are.equal(nil, lib.GetSpecializationRoleByID(0))
      assert.are.equal(nil, lib.GetSpecializationRoleByID(nil))
      assert.are.equal(nil, lib.GetSpecializationRoleByID(-1))
      assert.are.equal(nil, lib.GetSpecializationRoleByID(1))
    end)
  end)  -- GetSpecializationRoleByID

end)
