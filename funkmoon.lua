-- Functional tools for Lua v0.01

local funkmoon = {}

function funkmoon.map(list, fn)
    -- Builds a new list by applying 'fn' to each element of 'list'
    local mapped = {}
    for index, elem in pairs(list) do
        mapped[index] = fn(elem)
    end
    return funkmoon.FunctionalTable(mapped)
end

function funkmoon.flatMap(list, fn)
    --[[
    Builds a new table by applying 'fn' to all elements of 'list'
    and using the elements of the resulting tables.
    ]]--
    local mapped = funkmoon.map(list, fn)
    local flattened = {}
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
    return funkmoon.FunctionalTable(flattened)
end

local function _isArrayIndex(i, maxn)
    return type(i) == "number" and i > 0 and i <= maxn
end

function funkmoon.filter(list, predicate)
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
    return funkmoon.FunctionalTable(filtered)
end

function funkmoon.filterNot(list, predicate)
    -- Selects all elements of 'list' which don't satisfy 'predicate'.
    return funkmoon.filter(list, function(n) return not predicate(n) end)
end

function funkmoon.find(list, predicate)
    -- Finds the first element of 'list' satisfying a predicate, if any.
    for i, elem in pairs(list) do
        if predicate(elem) then
            return funkmoon.FunctionalTable({ [i] = elem })
        end
    end
    return funkmoon.FunctionalTable({})
end

function funkmoon.arrayPart(list)
    -- Returns the array-like part of list (1 to n).
    local newList = {}
    for i, elem in ipairs(list) do
        newList[i] = elem
    end
    return funkmoon.FunctionalTable(newList)
end

-- TODO: Use the logic of filter here.
function funkmoon.partition(list, predicate)
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
    return funkmoon.FunctionalTable(trueList), funkmoon.FunctionalTable(falseList)
end

function funkmoon.takeWhile(list, predicate)
    -- Takes longest prefix of elements of 'list' that satisfy 'predicate'.
    local newList = funkmoon.FunctionalTable({})
    for i, elem in pairs(list) do
        if predicate(elem) == true then
            newList[i] = elem
        else
            return newList
        end
    end
    return newList
end

function funkmoon.dropWhile(list, predicate)
    -- Drops longest prefix of elements of 'list' that satisfy 'predicate'.
    local satisfiesPredicate = true
    local newList = funkmoon.FunctionalTable({})
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

function funkmoon.foldLeft(list, startValue)
    --[[
    Usage: foldLeft(list, firstValue)(fn)
    Applies a binary function (fn) to startValue and all elements of 'list',
    going left to right.

    'fn' must be of the form fn(acc, e), where acc is the accumulated value
    and e is an element of the list.
    ]]--
    return _fold(list, startValue, true)
end

function funkmoon.foldRight(list, startValue)
    --[[
    Usage: foldRight(list, firstValue)(fn)
    Applies a binary function (fn) to startValue and all elements of 'list',
    going right to left.

    'fn' must be of the form fn(acc, e), where acc is the accumulated value
    and e is an element of the list.
    ]]--
    return _fold(list, startValue, false)
end

function funkmoon.reduce(list, fn)
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

function funkmoon.exists(list, predicate)
    -- Tests whether 'predicate' holds for some of the elements of 'list'.
    local acc = false
    for _, elem in pairs(list) do
        acc = acc or predicate(elem)
    end
    return acc
end

function funkmoon.forall(list, predicate)
    -- Tests whether 'predicate' holds for all elements of 'list'.
    local acc = true
    for _, elem in pairs(list) do
        acc = acc and predicate(elem)
    end
    return acc
end

function funkmoon.corresponds(list, otherList)
    --[[
    Usage: corresponds(list, otherList)(predicate) -> returns a boolean.

    Tests whether every element of 'list' relates to the corresponding element
    of 'otherList' by satisfying a test predicate.

    list -> a table
    otherList -> another table

    predicate(a, b) -> a function that gets the ith element of list and
    otherList and compares them, returning true or false.
    ]]
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

function funkmoon.fill(n)
    --[[
    Usage: fill(times)(value)
    Creates a table with 'value' repeated 'n' times.
    ]]--
    local function newFunction(value)
        local newList = funkmoon.FunctionalTable({})
        for i = 1, n do
            table.insert(newList, value)
        end
        return newList
    end
    return newFunction
end

function funkmoon.distinct(list)
    -- Builds a new list from this 'list' with no duplicate elements.
    local tempTable = {}
    local newList = funkmoon.FunctionalTable({})
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

function funkmoon.groupBy(list, fn)
    --[[
    Gets the elements and keys from 'list' and partitions them by the result of
    the function fn(key, element), returning a new table where fn(key, element)
    are the keys and the values are tables with the keys and values.
    ]]
    local newTable = funkmoon.FunctionalTable({})
    for i, elem in pairs(list) do
        if newTable[fn(i, elem)] == nil then
            newTable[fn(i, elem)] = {}
        end
        table.insert(newTable[fn(i, elem)], {i, elem})
    end
    return newTable
end

function funkmoon.partial(fn, ...)
    -- Returns a new function with partial application of the given arguments.
    local defArgs = arg
    local function newFunction(...)
        return fn(unpack(defArgs), unpack(arg))
    end
    return newFunction
end

function funkmoon.isEmpty(list)
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

function funkmoon.max(list)
    -- TODO: Documentar
    return _compare_maxmin(list, -math.huge, function(n, t) return n > t end)
end

function funkmoon.min(list)
    -- TODO: Documentar
    return _compare_maxmin(list, math.huge, function(n, t) return n < t end)
end

function funkmoon.zip(list, otherList)
    --[[
    Returns a new table formed from 'list' and 'otherList'
    by combining corresponding elements in pairs.
    ]]
    local zippedList = funkmoon.FunctionalTable({})
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

function funkmoon.unzip(list)
    --[[
    Converts this 'list' of pairs into two tables of the first
    and second half of each pair.
    ]]
    local zip1 = {}
    local zip2 = {}
    for _, elem in pairs(list) do
        table.insert(zip1, elem[1])
        table.insert(zip2, elem[2])
    end
    return zip1, zip2
end

function funkmoon.slice(list, from, to)
    -- Returns a new table with the elements of 'list' from 'from' to 'to'.
    local newList = funkmoon.FunctionalTable({})
    for i = from, to do
        table.insert(newList, list[i])
    end
    return newList
end

function funkmoon.reverse(list)
    -- Returns a new table with the elements of 'list' reversed.
    local newList = funkmoon.FunctionalTable({})
    local length = table.maxn(list)
    for i = length, 1, -1 do
        table.insert(newList, list[i])
    end
    return newList
end

function funkmoon.distinct(list)
    -- Returns a new table with all dinstinct elements of 'list'.
    local newList = funkmoon.FunctionalTable({})
    local newListElems = {}
    for _, elem in list do
        newListElems[elem] = true
    end
    for elem, _ in newListElems do
        table.insert(newList, elem)
    end
    return newList
end

local funkMetaTable  = {
    map = funkmoon.map,
    flatMap = funkmoon.flatMap,
    filter = funkmoon.filter,
    filterNot = funkmoon.filterNot,
    find = funkmoon.find,
    arrayPart = funkmoon.arrayPart,
    partition = funkmoon.partition,
    foldLeft = funkmoon.foldLeft,
    foldRight = funkmoon.foldRight,
    reduce = funkmoon.reduce,
    exists = funkmoon.exists,
    forall = funkmoon.forall,
    corresponds = funkmoon.corresponds,
    distinct = funkmoon.distinct,
    groupBy = funkmoon.groupBy,
    takeWhile = funkmoon.takeWhile,
    dropWhile = funkmoon.dropWhile,
    isEmpty = funkmoon.isEmpty,
    max = funkmoon.max,
    min = funkmoon.min,
    zip = funkmoon.zip,
    unzip = funkmoon.unzip,
    slice = funkmoon.slice,
    reverse = funkmoon.reverse,
    distinct = funkmoon.distinct
    }

function funkmoon.FunctionalTable(list)
    setmetatable(list, { __index = funkMetaTable })
    return list
end

function funkmoon.Listify(elemTable)
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

function funkmoon.stream(fn, ...)
    local values = arg
    local function iterator()
        values = fn(unpack(values))
        return unpack(values)
    end
    return iterator
end

function funkmoon.itimes(t, fn)
    local i = 0
    local function iterator()
        if i < t then
            i = i + 1
            return fn()
        else
            return nil
        end
    end
    return iterator
end

return funkmoon
