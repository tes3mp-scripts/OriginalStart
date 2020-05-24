local Start = {}

Start.scriptName = "OriginalStart"

Start.defaultConfig = {
    START_ON_DOCK = false,
    CLEAN_ON_UNLOAD = true,
    CHANGE_CONFIG_SPAWN = true
}

Start.defaultData = {
    chargenPlayers = {}
}

Start.config = DataManager.loadConfiguration(Start.scriptName, Start.defaultConfig)
Start.data = DataManager.loadData(Start.scriptName, Start.defaultData)

Start.EXIT_DOOR = "119659-0"

Start.CHARGEN_CELLS = {
    ["Imperial Prison Ship"] = true,
    ["-2, -9"] = true,
    ["Seyda Neen, Census and Excise Office"] = true
}

Start.OFFICE = "Seyda Neen, Census and Excise Office"

Start.OFFICE_DOORS = {
    ["ex_nord_door_01"] = "119513-0",
    ["chargen_door_hall"] = "172860-0"
}

Start.deliveredCaiusPackage = nil

--enable the census office
contentFixer.ValidateCellChange = function(pid)
    return true
end

--disable the standard way of disabling chargen elements, to allow to enable ergala and chargen boat
contentFixer.FixCell = function(pid)
    return
end

local spawnLocation = nil

if not Start.config.START_ON_DOCK then
    spawnLocation = {
        cell = "Imperial Prison Ship",
        regionName = "bitter coast region",
        posX = 61,
        posY = -136.5,
        posZ = -104.25,
        rotX = 0,
        rotZ = -0.5
    }
else
    spawnLocation = {
        cell = "-2, -9",
        regionName = "bitter coast region",
        posX = -8861.18,
        posY = -73120.13,
        posZ = 92.26,
        rotX = 0,
        rotZ = -0.97
    }
end

if Start.config.CHANGE_CONFIG_SPAWN then
    config.defaultSpawnCell = spawnLocation.cell
    config.defaultSpawnPos = {
        spawnLocation.posX,
        spawnLocation.posY,
        spawnLocation.posZ
    }
    config.defaultSpawnRot = {
        spawnLocation.rotX,
        spawnLocation.rotZ
    }
end

function Start.getPlayerName(pid)
    return string.lower(Players[pid].accountName)
end

function Start.isPlayerChargen(pid)
    return Start.data.chargenPlayers[Start.getPlayerName(pid)] ~= nil
end

function Start.teleportToSpawn(pid)
    local player = Players[pid]

    player.data.location = spawnLocation
    player:Save()

    tes3mp.SetCell(pid, spawnLocation.cell)

    tes3mp.SetRot(
        pid,
        spawnLocation.rotX,
        spawnLocation.rotZ
    )

    tes3mp.SetPos(
        pid,
        spawnLocation.posX,
        spawnLocation.posY,
        spawnLocation.posZ
    )

    tes3mp.SendCell(pid)
    tes3mp.SendPos(pid)
end

function Start.AddItem(pid, refId)
    local player = Players[pid]
    local item = {
        refId = refId,
        count = 1,
        charge = -1,
        enchantmentCharge = -1,
        soul = "" 
    }
    player:LoadItemChanges({item}, enumerations.inventory.ADD)
end

local runConsole = logicHandler.RunConsoleCommandOnPlayer

function Start.fixCharGen(pid)
    Start.data.chargenPlayers[Start.getPlayerName(pid)] = true
    --enable some parts of the chargen sequence
    runConsole(pid, "set CharGenState to 10", false)

    --skip jiub's question about player's name
    runConsole(pid, "set \"chargen name\".state to 20", false)
    --make the boat guard walk as normal
    runConsole(pid, "set \"chargen boat guard 2\".state to 0", false)
    
    --disable most speech and movement for the dock guard
    runConsole(pid, "set \"chargen dock guard\".state to -1", false)

    --disable ergala chargen
    runConsole(pid, "set \"chargen class\".state to -1", false)
    --allow to enter captain's room without the engraved ring
    runConsole(pid, "set \"chargen door captain\".done to 1", false)
    --allow to leave the building without the package
    runConsole(pid, "set \"CharGen Exit Door\".done to 1", false)
end

function Start.fixLogin(pid)
    Start.data.chargenPlayers[Start.getPlayerName(pid)] = nil
    --disable most of the obtrusive chargen logic
    runConsole(pid, "set CharGenState to -1", false)

    --no speech from saint jiub
    runConsole(pid, "set \"chargen name\".state to -1", false)
    --boat guard walks to the hatch
    runConsole(pid, "set \"chargen boat guard 2\".state to 40", false)
    --no speech from the woman inside the boat
    runConsole(pid, "set \"chargen boat guard 3\".state to 1", false)
    --no message when leaving through the boat hatch
    runConsole(pid, "set \"chargen_shipdoor\".done to 1", false)

    --no speech from the redguard on the boat
    runConsole(pid, "set \"chargen boat guard 1\".state to 10", false)
    --disable most speech and movement for the dock guard
    runConsole(pid, "set \"chargen dock guard\".state to -1", false)

    --disable ergala chargen
    runConsole(pid, "set \"chargen class\".state to -1", false)
    --no message when picking up the stat sheet
    runConsole(pid, "set \"chargen statssheet\".state to 20", false)
    --no speech from the guard at the door
    runConsole(pid, "set \"chargen door guard\".done to 1", false)
    --no message when taking the chargen dagger
    runConsole(pid, "set \"chargen dagger\".done to 1", false)
    --no message when sleeping on the bed in the census cellar
    runConsole(pid, "set \"CharGen_Bed\".done to 1", false)
    --no message after leaving main census building
    runConsole(pid, "set \"CharGen Exit Door\".done to 1", false)

    --no message about having a map
    runConsole(pid, "set \"chargen barrel fatigue\".done to 1", false)
    --no message about engraved ring
    runConsole(pid, "set \"ring_keley\".state to 30", false)
    --allow to enter captain's room without the engraved ring
    runConsole(pid, "set \"chargen door captain\".done to 1", false)

    --no message about Gravius
    runConsole(pid, "set \"CharGen Captain\".state to -1", false)
    --allow to leave the building without the package
    runConsole(pid, "set \"CharGen Captain\".done to 1", false)

    --no message about having a journal
    runConsole(pid, "set \"chargendoorjournal\".done to 1", false)
end


function Start.OnPlayerEndCharGenV(eventStatus, pid)
    if WorldInstance.data.customVariables == nil then
        WorldInstance.data.customVariables = {}
    end
    Start.deliveredCaiusPackage = WorldInstance.data.customVariables.deliveredCaiusPackage
    --disable the message about starting area being broken
    WorldInstance.data.customVariables.deliveredCaiusPackage = true
end

function Start.OnPlayerEndCharGen(eventStatus, pid)
    --return to the previous value
    WorldInstance.data.customVariables.deliveredCaiusPackage = Start.deliveredCaiusPackage

    if not Start.config.CHANGE_CONFIG_SPAWN then
        Start.teleportToSpawn(pid)
    end

    Start.fixCharGen(pid)

    --ДАЛЬШЕ ВЫ НЕ ПРОЙДЕТЕ ПОКА НЕ ПОЛУЧИТЕ БУМАГИ https://youtu.be/ppSPsvO19dU
    Start.AddItem(pid, "CharGen StatsSheet")
end

customEventHooks.registerValidator("OnPlayerEndCharGen", Start.OnPlayerEndCharGenV)
customEventHooks.registerHandler("OnPlayerEndCharGen", Start.OnPlayerEndCharGen)

function Start.OnPlayerFinishLogin(eventStatus, pid)
    if Start.isPlayerChargen(pid) then
        Start.fixCharGen(pid)
    else
        Start.fixLogin(pid)
    end
end
customEventHooks.registerHandler("OnPlayerFinishLogin", Start.OnPlayerFinishLogin)


Start.CellFixData = {}
-- Delete the chargen scroll as we already gave it to the player
Start.CellFixData[Start.OFFICE] = { 172859 }

if Start.config.START_ON_DOCK then
    -- Delete the chargen boat and associated guards and objects
    Start.CellFixData["-1, -9"] = { 268178, 297457, 297459, 297460, 299125 }
    Start.CellFixData["-2, -9"] = { 172848, 172850, 289104, 297461, 397559 }
    Start.CellFixData["-2, -10"] = { 297463, 297464, 297465, 297466 }
end

function Start.OnCellLoad(eventStatus, pid, cellDescription)
    if Start.CellFixData[cellDescription] ~= nil then 
        tes3mp.ClearObjectList()
        tes3mp.SetObjectListPid(pid)
        tes3mp.SetObjectListCell(cellDescription)

        for arrayIndex, refNum in pairs(Start.CellFixData[cellDescription]) do
            tes3mp.SetObjectRefNum(refNum)
            tes3mp.SetObjectMpNum(0)
            tes3mp.SetObjectRefId("")
            tes3mp.AddObject()
        end

        tes3mp.SendObjectDelete()
    end

    if cellDescription == Start.OFFICE then
        --unlock the census office doors
        local cellData = LoadedCells[cellDescription].data
        local updatedUniqueIndexes = {}

        local updated = false

        for refId, uniqueIndex in pairs(Start.OFFICE_DOORS) do
            if cellData.objectData[uniqueIndex] ~= nil then
                if cellData.objectData[uniqueIndex].lockLevel ~= 0 then
                    cellData.objectData[uniqueIndex].lockLevel = 0
                    updated = true
                end
            else
                cellData.objectData[uniqueIndex] = {
                    lockLevel = 0,
                    refId = refId
                }
                updated = true
            end
        end

        if updated or Start.isPlayerChargen(pid)  then
            LoadedCells[cellDescription]:LoadObjectsLocked(pid, cellData.objectData, Start.OFFICE_DOORS)
        end
    end
end
customEventHooks.registerHandler("OnCellLoad", Start.OnCellLoad)

function Start.OnPlayerCellChange(eventStatus, pid)
    if Start.isPlayerChargen(pid) then
        local cellDescription = tes3mp.GetCell(pid)

        --player has left the chargen area
        if Start.CHARGEN_CELLS[cellDescription] == nil then
            Start.fixLogin(pid)
        end
    end
end
customEventHooks.registerHandler("OnPlayerCellChange", Start.OnPlayerCellChange)


function Start.cleanDockCell(pid, cellDescription)
    --clean up garbage objects spawned during character creation
    if cellDescription == "-2, -9" then
        local targetRefId = "chargencollision - extra"
        local cellDescription = "-2, -9"
        local cellData = LoadedCells[cellDescription].data

        for uniqueIndex, data in pairs(cellData) do
            if data.refId == targetRefId then
                cellData[uniqueIndex] = nil
            end
        end
    end
end
if Start.config.CLEAN_ON_UNLOAD then
    customEventHooks.registerValidator("OnCellUnload", function(eventStatus, pid, cellDescription)
        Start.cleanDockCell(pid, cellDescription)
    end)
end

function Start.OnServerExit(eventStatus)
    DataManager.saveData(Start.scriptName, Start.data)
end
customEventHooks.registerHandler("OnServerExit", Start.OnServerExit)

function Start.OnObjectActivate(eventStatus, pid, cellDescription, objects, players)
    if not eventStatus.validCustomHandlers then
        return
    end
    if Start.isPlayerChargen(pid) then
        for _, obj in pairs(objects) do
            if obj.uniqueIndex == Start.EXIT_DOOR then
                Start.fixLogin(pid)
                break
            end
        end
    end
end
customEventHooks.registerHandler("OnObjectActivate", Start.OnObjectActivate)

return Start