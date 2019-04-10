local Start = {}

Start.START_ON_DOCK = false
Start.CLEAN_ON_UNLOAD = true

Start.scriptName = "OriginalStart"

Start.defaultConfig = {
    START_ON_DOCK = false,
    CLEAN_ON_UNLOAD = true
}

if DataManager ~= nil then
    Start.config = DataManager.loadConfiguration(Start.scriptName, Start.defaultConfig)
    Start.START_ON_DOCK = Start.config.START_ON_DOCK
    Start.CLEAN_ON_UNLOAD = Start.config.CLEAN_ON_UNLOAD
end

Start.OFFICE = "Seyda Neen, Census and Excise Office"

Start.deliveredCaiusPackage = nil

--enable the census office
contentFixer.ValidateCellChange = function(pid)
    return true
end

--disable the standard way of disabling chargen elements, to allow to enable ergala and chargen boat
contentFixer.FixCell = function(pid)
    return
end


function Start.teleportToSpawn(pid)
    local player = Players[pid]

    local location = nil

    if not Start.START_ON_DOCK then
        location = {
            cell = "Imperial Prison Ship",
            regionName = "bitter coast region",
            posX = 61,
            posY = -136.5,
            posZ = -104.25,
            rotX = 0,
            rotZ = -0.5
        }
    else
        location = {
            cell = "-2, -9",
            regionName = "bitter coast region",
            posX = -8861.18,
            posY = -73120.13,
            posZ = 92.26,
            rotX = 0,
            rotZ = -0.97
        }
    end

    tes3mp.SetCell(pid, location.cell)

    tes3mp.SetRot(
        pid,
        location.rotX,
        location.rotZ
    )

    tes3mp.SetPos(
        pid,
        location.posX,
        location.posY,
        location.posZ
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
    --enable some parts of the chargen sequence
    runConsole(pid, "set CharGenState to 10", false)

    --skip jiub's question about player's name
    runConsole(pid, "set \"chargen name\".state to 20", false)
    --make the boat guard walk as normal
    runConsole(pid, "set \"chargen boat guard 2\".state to 5", false)
    
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

    Start.teleportToSpawn(pid)

    Start.fixCharGen(pid)

    --ДАЛЬШЕ ВЫ НЕ ПРОЙДЕТЕ ПОКА НЕ ПОЛУЧИТЕ БУМАГИ https://youtu.be/ppSPsvO19dU
    Start.AddItem(pid, "CharGen StatsSheet")
end

customEventHooks.registerValidator("OnPlayerEndCharGen", Start.OnPlayerEndCharGenV)
customEventHooks.registerHandler("OnPlayerEndCharGen", Start.OnPlayerEndCharGen)

Start.CellFixData = {}
-- Delete the chargen scroll as we already gave it to the player
Start.CellFixData["Seyda Neen, Census and Excise Office"] = { 172859 }

if Start.START_ON_DOCK then
    -- Delete the chargen boat and associated guards and objects
    Start.CellFixData["-1, -9"] = { 268178, 297457, 297459, 297460, 299125 }
    Start.CellFixData["-2, -9"] = { 172848, 172850, 289104, 297461, 397559 }
    Start.CellFixData["-2, -10"] = { 297463, 297464, 297465, 297466 }
end

function Start.OnCellLoad(eventStatus, pid, cellDescription)
    if Start.CellFixData[cellDescription]~= nil then 
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
        --unlock the census door
        local uniqueIndex = "119513-0"

        local cellData = LoadedCells[cellDescription].data
        
        if cellData.objectData[uniqueIndex] ~= nil then
            cellData.objectData[uniqueIndex].lockLevel = 0
        else
            cellData.objectData[uniqueIndex] = {
                lockLevel = 0,
                refId = "ex_nord_door_01"
            }
        end

        LoadedCells[cellDescription]:LoadObjectsLocked(pid, cellData.objectData, {uniqueIndex})
    end
end

customEventHooks.registerHandler("OnCellLoad", Start.OnCellLoad)


function Start.OnPlayerFinishLogin(eventStatus, pid)
    Start.fixLogin(pid)
end

customEventHooks.registerHandler("OnPlayerFinishLogin", Start.OnPlayerFinishLogin)

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

function Start.OnCellUnload(eventStatus, pid, cellDescription)
    Start.cleanDockCell(pid, cellDescription)
end

customEventHooks.registerValidator("OnCellUnload", Start.cleanChargenCollision)


return Start