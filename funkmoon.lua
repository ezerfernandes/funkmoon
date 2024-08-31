-- Functional tools for Lua v0.12

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

function funkmoon.filter(list, predicate)
    -- Selects all elements of 'list' which satisfy 'predicate'.
    local filtered = {}
    for i, elem in pairs(list) do
        if predicate(elem) then
            table.insert(filtered, elem)
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
        if not predicate(elem) then
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
        endI = #list
    else
        order = -1
        startI = #list
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

function funkmoon.any(list, predicate)
    -- Tests whether 'predicate' holds for some of the elements of 'list'.
    local acc = false
    for _, elem in pairs(list) do
        acc = acc or predicate(elem)
    end
    return acc
end

function funkmoon.all(list, predicate)
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
    local function match(predicate)
        if #list ~= #otherList then
            return false
        end
        for i = 1, #list do
            if not predicate(list[i], otherList[i]) then
                return false
            end
        end
        return true
    end
    return match
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
    local defArgs = {...}
    local function newFunction(...)
        local newArgs = {...}
        return fn(table.unpack(defArgs), table.unpack(newArgs))
    end
    return newFunction
end

function funkmoon.partialLast(fn, ...)
    --[[
    Returns a new function with partial application of the last arguments of the
    function fn.
    ]]
    local defArgs = {...}
    local function newFunction(...)
        local newArgs = {...}
        return fn(table.unpack(newArgs), table.unpack(defArgs))
    end
    return newFunction
end

function funkmoon.isEmpty(list)
    -- Teste whether 'list' is empty.
    local next = next
    return next(list) == nil
end

local function compare_maxmin(list, comparisonFunction)
    if funkmoon.isEmpty(list) then
        return funkmoon.FunctionalTable({})
    end
    local selectedValue = list[1]
    for i, elem in pairs(list) do
        if comparisonFunction(elem, selectedValue) then
            selectedValue = elem
        end
    end
    return funkmoon.FunctionalTable({ selectedValue })
end

function funkmoon.max(list)
    -- Returns a table with one value, the greatest element from list
    return compare_maxmin(list, function(n, t) return n > t end)
end

function funkmoon.min(list)
    -- Returns a table with one value, the smallest element from list
    return compare_maxmin(list, function(n, t) return n < t end)
end

function funkmoon.zip(list, otherList)
    --[[
    Returns a new table formed from 'list' and 'otherList'
    by combining corresponding elements in pairs.
    ]]
    local zippedList = funkmoon.FunctionalTable({})
    local maxn_list = #list
    local maxn_otherlist = #otherList
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
    local length = #list
    for i = length, 1, -1 do
        table.insert(newList, list[i])
    end
    return newList
end

function funkmoon.apply(list, fn)
    -- Applies fn using list as arguments.
    return fn(table.unpack(list))
end

function funkmoon.ifEmpty(list, obj)
    -- If empty, executes fn and returns its return; if not, returns list.
    if not funkmoon.isEmpty(list) then
        return list
    end
    if type(obj) == "function" then
        return obj()
    else
        return obj
    end
end

local funkMetaTable  = {
    -- return functional table
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
    corresponds = funkmoon.corresponds,
    distinct = funkmoon.distinct,
    groupBy = funkmoon.groupBy,
    takeWhile = funkmoon.takeWhile,
    dropWhile = funkmoon.dropWhile,
    max = funkmoon.max,
    min = funkmoon.min,
    slice = funkmoon.slice,
    reverse = funkmoon.reverse,
    zip = funkmoon.zip,
    -- don't return a FunctionalTable
    unzip = funkmoon.unzip,
    apply = funkmoon.apply,
    isEmpty = funkmoon.isEmpty,
    any = funkmoon.any,
    all = funkmoon.all,
    ifEmpty = funkmoon.ifEmpty,
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

function funkmoon.ifill(n)
    --[[
    Usage: ifill(times)(value)
    ]]--
    local function newFunction(value)
        local i = 0
        local function fillIterator()
            if i < n then
                i = i + 1
                return value
            else
                return nil
            end
        end
        return fillIterator
    end
    return newFunction
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

local function _check_range_params(from, to, step)
    assert(from <= to, "'from' must be smaller or equal to 'to'.")
    assert(step > 0, "'step' must be positive.")
end

function funkmoon.irange(from, to, step)
    if (step == nil) then
        step = 1
    end
    _check_range_params(from, to, step)
    local i = from

    return function()
        local ret = i
        i = i + step
        if ret <= to then
            return ret
        else
            return nil
        end
    end
end

function funkmoon.range(from, to, step)
    if (step == nil) then
        step = 1
    end
    _check_range_params(from, to, step)
    local i = from
    local newTable = {}
    while i <= to do
        table.insert(newTable, i)
        i = i + step
    end
    return newTable
end

function funkmoon.stream(fn, ...)
    local values = {...}
    local function iterator()
        values = fn(table.unpack(values))
        return table.unpack(values)
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
