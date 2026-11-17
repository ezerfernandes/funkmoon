local funkmoon = require "funkmoon"

---@type number[]
local numbers = { 1, 2, 3, 4 }

---@param value number
---@return string
local function stringifyNumber(value)
    return tostring(value)
end

---@type funkmoon.FunctionalTable<string>
local labels = funkmoon.FunctionalTable(numbers):map(stringifyNumber)

---@type funkmoon.FunctionalTable<number>
local positiveNumbers = funkmoon.FunctionalTable(numbers)
    :filter(function(value)
        return value > 0
    end)

---@type number
local total = positiveNumbers
    :map(function(value)
        return value * 2
    end)
    :foldLeft(0)(function(accumulator, value)
        return accumulator + value
    end)

---@type funkmoon.FunctionalTable<number>
local largestNumber = funkmoon.max(numbers)

---@type funkmoon.FunctionalTable<string>
local smallestWord = funkmoon.min({ "pear", "apple", "orange" })

---@param value string
---@return number
local function stringLength(value)
    return #value
end

---@param value number
---@return number
local function increment(value)
    return value + 1
end

---@param value number
---@return string
local function numberToString(value)
    return tostring(value)
end

---@type fun(value: string): string
local composed = funkmoon.compose(numberToString, stringLength)

---@type string
local composedResult = composed("Lua")

---@type string
local pipedResult = funkmoon.pipe("Lua", stringLength, increment, numberToString)

-- Keep the inferred values live in the fixture so the assignments above stay checked.
assert(labels[1] == "1")
assert(total == 20)
assert(largestNumber[1] == 4)
assert(smallestWord[1] == "apple")
assert(composedResult == "3")
assert(pipedResult == "4")
