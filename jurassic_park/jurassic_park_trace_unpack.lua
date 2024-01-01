local file = io.open("jp_unpack1.txt", "w")

function onWriteExt(address, s, v)
    local value73 = memory.readbyte(0x73)
    local value74 = memory.readbyte(0x74)
    local value75 = memory.readbyte(0x75)
    local value6F = memory.readbyte(0x6F)
    local value70 = memory.readbyte(0x70)
    file:write(string.format("                 %02X --- 73: %02X, 74: %02X, 75: %02X, 6F: %02X, 70: %02X\n", address, value73, value74, value75, value6F, value70))
end

function onRead(address, s, v)
    local value73 = memory.readbyte(0x73)
    local value74 = memory.readbyte(0x74)
    local value75 = memory.readbyte(0x75)
    local value6F = memory.readbyte(0x6F)
    local value70 = memory.readbyte(0x70)
    file:write(string.format("READ  %04X <- %02X    --- 73: %02X, 74: %02X, 75: %02X, 6F: %02X, 70: %02X\n", address, v, value73, value74, value75, value6F, value70))
end

function onWrite(address, s, v)
    local value73 = memory.readbyte(0x73)
    local value74 = memory.readbyte(0x74)
    local value75 = memory.readbyte(0x75)
    local value6F = memory.readbyte(0x6F)
    local value70 = memory.readbyte(0x70)
    file:write(string.format("   WRITE %04X -> %02X --- 73: %02X, 74: %02X, 75: %02X, 6F: %02X, 70: %02X\n", address, v, value73, value74, value75, value6F, value70))
end

memory.registerread(0x9D94, 0xA4B1 - 0x9D94 + 1, onRead)
memory.registerwrite(0x60C8, 0x72CB - 0x60C8 + 1, onWrite)

memory.registerwrite(0x6F, 1, onWriteExt)
memory.registerwrite(0x70, 1, onWriteExt)
memory.registerwrite(0x73, 1, onWriteExt)
memory.registerwrite(0x74, 1, onWriteExt)
memory.registerwrite(0x75, 1, onWriteExt)

function onExit()
    if file then
        file:close()
    end
end

emu.registerexit(onExit)

local logFile = io.open("jp_unpack1.txt", "w")

local function readMemoryValue(address)
    return memory.readbyte(address)
end

local function logMemoryOperation(operation, address, value)
    local values = {
        readMemoryValue(0x73),
        readMemoryValue(0x74),
        readMemoryValue(0x75),
        readMemoryValue(0x6F),
        readMemoryValue(0x70)
    }

    logFile:write(string.format("%s %04X %s %02X --- 73: %02X, 74: %02X, 75: %02X, 6F: %02X, 70: %02X\n",
                                operation, address, operation == "WRITE" and "->" or "<-", value,
                                unpack(values)))
end

local function onMemoryRead(address, size, value)
    logMemoryOperation("READ", address, value)
end

local function onMemoryWrite(address, size, value)
    logMemoryOperation("   WRITE", address, value)
end

local function onExtendedWrite(address, size, value)
    logMemoryOperation("   ", address, value)
end

local readRangeStart, readRangeEnd = 0x9D94, 0xA4B1
local writeRangeStart, writeRangeEnd = 0x60C8, 0x72CB

memory.registerread(readRangeStart, readRangeEnd - readRangeStart + 1, onMemoryRead)
memory.registerwrite(writeRangeStart, writeRangeEnd - writeRangeStart + 1, onMemoryWrite)

local extendedWriteAddresses = {0x6F, 0x70, 0x73, 0x74, 0x75}
for _, address in ipairs(extendedWriteAddresses) do
    memory.registerwrite(address, 1, onExtendedWrite)
end

emu.registerexit(function()
    if logFile then
        logFile:close()
    end
end)
