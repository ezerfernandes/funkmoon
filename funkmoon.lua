-- Functional tools for Lua v0.01

function map(list, fn)
    -- Builds a new list by applying 'fn' to each element of 'list'
    local mapped = FunctionalTable({})
    for index, elem in pairs(list) do
        mapped[index] = fn(elem)
    end
    return mapped
end

function flatMap(list, fn)
    --[[
    Builds a new table by applying 'fn' to all elements of 'list'
    and using the elements of the resulting tables.
    ]]--
    local mapped = map(list, fn)
    local flattened = FunctionalTable({})
    local function flatten(list)
        for _, elem in pairs(list) do
            if type(elem) ~= "table" then
                table.insert(flattened, elem)
            else
                flatten(elem)
            end
        end
    end
    flatten(mapped)
    return flattened
end

local function _isArrayIndex(i, maxn)
    return type(i) == "number" and i > 0 and i <= maxn
end

function filter(list, predicate)
    -- Selects all elements of 'list' which satisfy 'predicate'.
    local filtered = {}
    local n = #list
    for i, elem in pairs(list) do
        if predicate(elem) then
            if _isArrayIndex(i, n) then
                table.insert(filtered, elem)
            else
                filtered[i] = elem
            end
        end
    end
    return FunctionalTable(filtered)
end

function filterNot(list, predicate)
    -- Selects all elements of 'list' which don't satisfy 'predicate'.
    return filter(list, function(n) return not predicate(n) end)
end

function find(list, predicate)
    -- Finds the first element of 'list' satisfying a predicate, if any.
    for i, elem in pairs(list) do
        if predicate(elem) then
            return FunctionalTable({ [i] = elem })
        end
    end
    return FunctionalTable({})
end

function arrayPart(list)
    -- Returns the array-like part of list (1 to n).
    local newList = FunctionalTable({})
    for i, elem in ipairs(list) do
        newList[i] = elem
    end
    return newList
end

-- TODO: Use the logic of filter here.
function partition(list, predicate)
    -- Partitions 'list' in two tables according to 'predicate'.
    local trueList = {}
    local falseList = {}
    for _, elem in pairs(list) do
        if predicate(elem) then
            table.insert(trueList, elem)
        else
            table.insert(falseList, elem)
        end
    end
    return FunctionalTable(trueList), FunctionalTable(falseList)
end

function takeWhile(list, predicate)
    -- Takes longest prefix of elements of 'list' that satisfy 'predicate'.
    local newList = FunctionalTable({})
    for i, elem in pairs(list) do
        if predicate(elem) == true then
            newList[i] = elem
        else
            return newList
        end
    end
    return newList
end

function dropWhile(list, predicate)
    -- Drops longest prefix of elements of 'list' that satisfy 'predicate'.
    local satisfiesPredicate = true
    local newList = FunctionalTable({})
    for _, elem in pairs(list) do
        if predicate(elem) ~= true then
            satisfiesPredicate = false
        end
        if not satisfiesPredicate then
            table.insert(newList, elem)
        end
    end
    return newList
end

local function _fold(list, startValue, foldLeft)
    local startI, endI, order
    if foldLeft == true then
        order = 1
        startI = 1
        endI = table.maxn(list)
    else
        order = -1
        startI = table.maxn(list)
        endI = 1
    end
    local function reduceList(fn)
        local accumulator = startValue
        for i = startI, endI, order do
            accumulator = fn(accumulator, list[i])
        end
        return accumulator
    end
    return reduceList
end

function foldLeft(list, startValue)
    --[[
    Usage: foldLeft(list, firstValue)(fn)
    Applies a binary function (fn) to startValue and all elements of 'list',
    going left to right.

    'fn' must be of the form fn(acc, e), where acc is the accumulated value
    and e is an element of the list.
    ]]--
    return _fold(list, startValue, true)
end

function foldRight(list, startValue)
    --[[
    Usage: foldRight(list, firstValue)(fn)
    Applies a binary function (fn) to startValue and all elements of 'list',
    going right to left.

    'fn' must be of the form fn(acc, e), where acc is the accumulated value
    and e is an element of the list.
    ]]--
    return _fold(list, startValue, false)
end

function reduce(list, fn)
    -- Reduces the elements of 'list' using the binary operator 'fn'.
    local firstValue = list[1]
    local newList = {}
    for i, elem in pairs(list) do
        if i ~= 1 then
            newList[i] = elem
        end
    end
    local accumulator = firstValue
    for i, elem in pairs(newList) do
        accumulator = fn(accumulator, elem)
    end
    return accumulator
end

function exists(list, predicate)
    -- Tests whether 'predicate' holds for some of the elements of 'list'.
    local acc = false
    for _, elem in pairs(list) do
        acc = acc or predicate(elem)
    end
    return acc
end

function forall(list, predicate)
    -- Tests whether 'predicate' holds for all elements of 'list'.
    local acc = true
    for _, elem in pairs(list) do
        acc = acc and predicate(elem)
    end
    return acc
end

function corresponds(list, otherList)
    local function match(comparison)
        if table.maxn(list) ~= table.maxn(otherList) then
            return false
        end
        for i = 1, table.maxn(list) do
            if comparison(list[i], otherList[i]) ~= true then
                return false
            end
        end
        return true
    end
    return match
end

function fill(n)
    --[[
    Usage: fill(times)(value)
    Creates a table with 'value' repeated 'n' times.
    ]]--
    local function newFunction(value)
        local newList = FunctionalTable({})
        for i = 1, n do
            table.insert(newList, value)
        end
        return newList
    end
    return newFunction
end

function distinct(list)
    -- Builds a new list from this 'list' with no duplicate elements.
    local tempTable = {}
    local newList = FunctionalTable({})
    for _, elem in pairs(list) do
        tempTable[elem] = true
    end
    for elem, elemExists in pairs(tempTable) do
        if elemExists then
            table.insert(newList, elem)
        end
    end
    return newList
end

function groupBy(list, fn)
    local newTable = FunctionalTable({})
    for i, elem in pairs(list) do
        if newTable[fn(i, elem)] == nil then
            newTable[fn(i, elem)] = {}
        end
        table.insert(newTable[fn(i, elem)], {i, elem})
    end
    return newTable
end

function partial(fn, ...)
    -- Returns a new function with partial application of the given arguments.
    local defArgs = arg
    local function newFunction(...)
        return fn(unpack(defArgs), unpack(arg))
    end
    return newFunction
end

function isEmpty(list)
    -- Teste whether 'list' is empty.
    for _, _ in pairs(list) do
        return false
    end
    return true
end

local function _compare_maxmin(list, initialValue, comparisonFunction)
    local selectedValue = initialValue
    for i, elem in pairs(list) do
        if comparisonFunction(elem, selectedValue) then
            selectedValue = elem
        end
    end
    if comparisonFunction(selectedValue, initialValue) then
        return selectedValue
    else
        return nil
    end
end

function max(list)
    return _compare_maxmin(list, -math.huge, function(n, t) return n > t end)
end

function min(list)
    return _compare_maxmin(list, math.huge, function(n, t) return n < t end)
end

function zip(list, otherList)
    local zippedList = FunctionalTable({})
    local maxn_list = table.maxn(list)
    local maxn_otherlist = table.maxn(otherList)
    local minMaxI
    if maxn_list < maxn_otherlist then
        minMaxI = maxn_list
    else
        minMaxI = maxn_otherlist
    end
    for i = 1, minMaxI do
        zippedList[i] = { list[i], otherList[i] }
    end
    return zippedList
end

function unzip(list)
    local zip1 = {}
    local zip2 = {}
    for _, elem in pairs(list) do
        table.insert(zip1, elem[1])
        table.insert(zip2, elem[2])
    end
    return zip1, zip2
end

function slice(list, from, to)
    local newList = FunctionalTable({})
    for i = from, to do
        table.insert(newList, list[i])
    end
    return newList
end

function reverse(list)
    local newList = FunctionalTable({})
    local length = table.maxn(list)
    for i = length, 1, -1 do
        table.insert(newList, list[i])
    end
    return newList
end

function distinct(list)
    local newList = FunctionalTable({})
    local newListElems = {}
    for _, elem in list do
        newListElems[elem] = true
    end
    for elem, _ in newListElems do
        table.insert(newList, elem)
    end
    return newList
end

local functionalTools  = {
    map = map,
    flatMap = flatMap,
    filter = filter,
    filterNot = filterNot,
    find = find,
    arrayPart = arrayPart,
    partition = partition,
    foldLeft = foldLeft,
    foldRight = foldRight,
    reduce = reduce,
    exists = exists,
    forall = forall,
    corresponds = corresponds,
    distinct = distinct,
    groupBy = groupBy,
    takeWhile = takeWhile,
    dropWhile = dropWhile,
    isEmpty = isEmpty,
    max = max,
    min = min,
    zip = zip,
    unzip = unzip,
    slice = slice,
    reverse = reverse,
    distinct = distinct
    }

function FunctionalTable(list)
    setmetatable(list, { __index = functionalTools })
    return list
end

function Listify(elemTable)
    local list = {}
    for i, elem in pairs(elemTable) do
        if type(i) == "number" then
            table.insert(list, elem)
        else
            table.insert(list, {i, elem})
        end
    end
    return list
end
