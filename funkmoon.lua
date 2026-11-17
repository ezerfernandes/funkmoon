-- Functional tools for Lua 0.13.0
-- Public type information uses LuaCATS annotations and has no runtime cost.

---@alias funkmoon.Orderable number|string
---@alias funkmoon.TableKey string|number|boolean|table|function|thread|userdata|lightuserdata
---@alias funkmoon.GroupEntry<T> [integer, T]

---@class funkmoon.FunctionalTable<T>: { [integer]: T }
---@field map fun<U>(self: funkmoon.FunctionalTable<T>, fn: fun(value: T): U): funkmoon.FunctionalTable<U>
---@field flatMap fun<U>(self: funkmoon.FunctionalTable<T>, fn: fun(value: T): U[]): funkmoon.FunctionalTable<U>
---@field flatten fun<U>(self: funkmoon.FunctionalTable<U[]>): funkmoon.FunctionalTable<U>
---@field flattenDeep fun(self: funkmoon.FunctionalTable<T>): funkmoon.FunctionalTable<any>
---@field filter fun(self: funkmoon.FunctionalTable<T>, predicate: fun(value: T): boolean): funkmoon.FunctionalTable<T>
---@field filterNot fun(self: funkmoon.FunctionalTable<T>, predicate: fun(value: T): boolean): funkmoon.FunctionalTable<T>
---@field find fun(self: funkmoon.FunctionalTable<T>, predicate: fun(value: T): boolean): funkmoon.FunctionalTable<T>
---@field findValue fun(self: funkmoon.FunctionalTable<T>, predicate: fun(value: T): boolean): T?, integer?
---@field arrayPart fun(self: funkmoon.FunctionalTable<T>): funkmoon.FunctionalTable<T>
---@field partition fun(self: funkmoon.FunctionalTable<T>, predicate: fun(value: T): boolean): funkmoon.FunctionalTable<T>, funkmoon.FunctionalTable<T>
---@field takeWhile fun(self: funkmoon.FunctionalTable<T>, predicate: fun(value: T): boolean): funkmoon.FunctionalTable<T>
---@field dropWhile fun(self: funkmoon.FunctionalTable<T>, predicate: fun(value: T): boolean): funkmoon.FunctionalTable<T>
---@field foldLeft fun<A>(self: funkmoon.FunctionalTable<T>, startValue: A): fun(fn: fun(acc: A, value: T): A): A
---@field foldRight fun<A>(self: funkmoon.FunctionalTable<T>, startValue: A): fun(fn: fun(acc: A, value: T): A): A
---@field reduce fun(self: funkmoon.FunctionalTable<T>, fn: fun(acc: T, value: T): T): T?
---@field any fun(self: funkmoon.FunctionalTable<T>, predicate: fun(value: T): boolean): boolean
---@field all fun(self: funkmoon.FunctionalTable<T>, predicate: fun(value: T): boolean): boolean
---@field corresponds fun<U>(self: funkmoon.FunctionalTable<T>, other: U[]): fun(predicate: fun(a: T, b: U): boolean): boolean
---@field distinct fun(self: funkmoon.FunctionalTable<T>): funkmoon.FunctionalTable<T>
---@field groupBy fun(self: funkmoon.FunctionalTable<T>, fn: fun(index: integer, value: T): funkmoon.TableKey): table<funkmoon.TableKey, funkmoon.GroupEntry<T>[]>
---@field isEmpty fun(self: funkmoon.FunctionalTable<T>): boolean
---@field max fun(self: funkmoon.FunctionalTable<number>|funkmoon.FunctionalTable<string>): funkmoon.FunctionalTable<number>|funkmoon.FunctionalTable<string>
---@field min fun(self: funkmoon.FunctionalTable<number>|funkmoon.FunctionalTable<string>): funkmoon.FunctionalTable<number>|funkmoon.FunctionalTable<string>
---@field take fun(self: funkmoon.FunctionalTable<T>, count: integer): funkmoon.FunctionalTable<T>
---@field drop fun(self: funkmoon.FunctionalTable<T>, count: integer): funkmoon.FunctionalTable<T>
---@field count fun(self: funkmoon.FunctionalTable<T>, predicate?: fun(value: T): boolean): integer
---@field each fun(self: funkmoon.FunctionalTable<T>, fn: fun(value: T, index: integer)): funkmoon.FunctionalTable<T>
---@field sum fun(self: funkmoon.FunctionalTable<number>): number
---@field concat fun(self: funkmoon.FunctionalTable<T>, ...: T[]): funkmoon.FunctionalTable<T>
---@field head fun(self: funkmoon.FunctionalTable<T>): T?
---@field last fun(self: funkmoon.FunctionalTable<T>): T?
---@field slice fun(self: funkmoon.FunctionalTable<T>, from: integer, to: integer): funkmoon.FunctionalTable<T>
---@field reverse fun(self: funkmoon.FunctionalTable<T>): funkmoon.FunctionalTable<T>
---@field zip fun<U>(self: funkmoon.FunctionalTable<T>, other: U[]): funkmoon.FunctionalTable<[T, U]>
---@field unzip fun(self: funkmoon.FunctionalTable<any>): any[], any[]
---@field apply fun(self: funkmoon.FunctionalTable<any>, fn: fun(...: any): any): any
---@field ifEmpty fun<U>(self: funkmoon.FunctionalTable<T>, fallback: U | fun(): U): funkmoon.FunctionalTable<T> | U

local funkmoon = {}
local unpack = table.unpack
local pack = table.pack

---@class funkmoon.PackedArguments
---@field [integer] any
---@field n? integer

local function packedLength(values)
    if values.n ~= nil then
        return values.n
    end
    return #values
end

local function appendPacked(target, values)
    local current = target.n
    local count = packedLength(values)
    for i = 1, count do
        target[current + i] = values[i]
    end
    target.n = current + count
end

---@generic T, U
---@param list T[] Dense, one-based sequence.
---@param fn fun(value: T): U
---@return funkmoon.FunctionalTable<U>
function funkmoon.map(list, fn)
    local mapped = {}
    for index, elem in ipairs(list) do
        mapped[index] = fn(elem)
    end
    return funkmoon.FunctionalTable(mapped)
end

---@generic T, U
---@param list T[]
---@param fn fun(value: T): U[]
---@return funkmoon.FunctionalTable<U>
function funkmoon.flatMap(list, fn)
    local flattened = {}
    for _, elem in ipairs(list) do
        local mapped = fn(elem)
        if type(mapped) == "table" then
            for _, value in ipairs(mapped) do
                table.insert(flattened, value)
            end
        else
            table.insert(flattened, mapped)
        end
    end
    return funkmoon.FunctionalTable(flattened)
end

---@generic T
---@param list T[][]
---@return funkmoon.FunctionalTable<T>
function funkmoon.flatten(list)
    local flattened = {}
    for _, values in ipairs(list) do
        if type(values) == "table" then
            for _, value in ipairs(values) do
                table.insert(flattened, value)
            end
        else
            table.insert(flattened, values)
        end
    end
    return funkmoon.FunctionalTable(flattened)
end

local function flattenDeepInto(target, values, active)
    if active[values] then
        error("cannot flatten a cyclic table", 2)
    end
    active[values] = true
    for _, value in ipairs(values) do
        if type(value) == "table" then
            flattenDeepInto(target, value, active)
        else
            table.insert(target, value)
        end
    end
    active[values] = nil
end

---@param list table
---@return funkmoon.FunctionalTable<any>
function funkmoon.flattenDeep(list)
    local flattened = {}
    flattenDeepInto(flattened, list, {})
    return funkmoon.FunctionalTable(flattened)
end

---@generic T
---@param list T[]
---@param predicate fun(value: T): boolean
---@return funkmoon.FunctionalTable<T>
function funkmoon.filter(list, predicate)
    local filtered = {}
    for _, elem in ipairs(list) do
        if predicate(elem) then
            table.insert(filtered, elem)
        end
    end
    return funkmoon.FunctionalTable(filtered)
end

---@generic T
---@param list T[]
---@param predicate fun(value: T): boolean
---@return funkmoon.FunctionalTable<T>
function funkmoon.filterNot(list, predicate)
    return funkmoon.filter(list, function(value)
        return not predicate(value)
    end)
end

---@generic T
---@param list T[]
---@param predicate fun(value: T): boolean
---@return funkmoon.FunctionalTable<T> result One-entry table keyed by the original sequence index, or empty.
function funkmoon.find(list, predicate)
    for index, elem in ipairs(list) do
        if predicate(elem) then
            return funkmoon.FunctionalTable({ [index] = elem })
        end
    end
    return funkmoon.FunctionalTable({})
end

---@generic T
---@param list T[]
---@param predicate fun(value: T): boolean
---@return T? value
---@return integer? index
function funkmoon.findValue(list, predicate)
    for index, elem in ipairs(list) do
        if predicate(elem) then
            return elem, index
        end
    end
    return nil, nil
end

---@generic T
---@param list T[]
---@return funkmoon.FunctionalTable<T>
function funkmoon.arrayPart(list)
    local result = {}
    for index, elem in ipairs(list) do
        result[index] = elem
    end
    return funkmoon.FunctionalTable(result)
end

---@generic T
---@param list T[]
---@param predicate fun(value: T): boolean
---@return funkmoon.FunctionalTable<T> matching
---@return funkmoon.FunctionalTable<T> nonMatching
function funkmoon.partition(list, predicate)
    local matching = {}
    local nonMatching = {}
    for _, elem in ipairs(list) do
        if predicate(elem) then
            table.insert(matching, elem)
        else
            table.insert(nonMatching, elem)
        end
    end
    return funkmoon.FunctionalTable(matching), funkmoon.FunctionalTable(nonMatching)
end

---@generic T
---@param list T[]
---@param predicate fun(value: T): boolean
---@return funkmoon.FunctionalTable<T>
function funkmoon.takeWhile(list, predicate)
    local result = {}
    for _, elem in ipairs(list) do
        if not predicate(elem) then
            break
        end
        table.insert(result, elem)
    end
    return funkmoon.FunctionalTable(result)
end

---@generic T
---@param list T[]
---@param predicate fun(value: T): boolean
---@return funkmoon.FunctionalTable<T>
function funkmoon.dropWhile(list, predicate)
    local result = {}
    local dropping = true
    for _, elem in ipairs(list) do
        if dropping and predicate(elem) then
            -- Still removing the matching prefix.
        else
            dropping = false
            table.insert(result, elem)
        end
    end
    return funkmoon.FunctionalTable(result)
end

---@generic T, A
---@param list T[]
---@param startValue A
---@param reverse boolean
---@return fun(fn: fun(acc: A, value: T): A): A
local function fold(list, startValue, reverse)
    return function(fn)
        local accumulator = startValue
        if reverse then
            for index = #list, 1, -1 do
                accumulator = fn(accumulator, list[index])
            end
        else
            for index = 1, #list do
                accumulator = fn(accumulator, list[index])
            end
        end
        return accumulator
    end
end

---@generic T, A
---@param list T[]
---@param startValue A
---@return fun(fn: fun(acc: A, value: T): A): A
function funkmoon.foldLeft(list, startValue)
    return fold(list, startValue, false)
end

---@generic T, A
---@param list T[]
---@param startValue A
---@return fun(fn: fun(acc: A, value: T): A): A
function funkmoon.foldRight(list, startValue)
    return fold(list, startValue, true)
end

---@generic T
---@param list T[]
---@param fn fun(acc: T, value: T): T
---@return T? result Nil when the sequence is empty.
function funkmoon.reduce(list, fn)
    local length = #list
    if length == 0 then
        return nil
    end
    local accumulator = list[1]
    for index = 2, length do
        accumulator = fn(accumulator, list[index])
    end
    return accumulator
end

---@generic T
---@param list T[]
---@param predicate fun(value: T): boolean
---@return boolean
function funkmoon.any(list, predicate)
    for _, elem in ipairs(list) do
        if predicate(elem) then
            return true
        end
    end
    return false
end

---@generic T
---@param list T[]
---@param predicate fun(value: T): boolean
---@return boolean
function funkmoon.all(list, predicate)
    for _, elem in ipairs(list) do
        if not predicate(elem) then
            return false
        end
    end
    return true
end

---@generic T, U
---@param list T[]
---@param otherList U[]
---@return fun(predicate: fun(a: T, b: U): boolean): boolean
function funkmoon.corresponds(list, otherList)
    return function(predicate)
        if #list ~= #otherList then
            return false
        end
        for index = 1, #list do
            if not predicate(list[index], otherList[index]) then
                return false
            end
        end
        return true
    end
end

---@generic T
---@param list T[]
---@return funkmoon.FunctionalTable<T>
function funkmoon.distinct(list)
    local seen = {}
    local sawNaN = false
    local result = {}
    for _, elem in ipairs(list) do
        if type(elem) == "number" and elem ~= elem then
            if not sawNaN then
                table.insert(result, elem)
                sawNaN = true
            end
        elseif not seen[elem] then
            seen[elem] = true
            table.insert(result, elem)
        end
    end
    return funkmoon.FunctionalTable(result)
end

---@generic T, K : funkmoon.TableKey
---@param list T[]
---@param fn fun(index: integer, value: T): K
---@return table<K, funkmoon.GroupEntry<T>[]>
function funkmoon.groupBy(list, fn)
    local grouped = {}
    for index, elem in ipairs(list) do
        local key = fn(index, elem)
        if key == nil or (type(key) == "number" and key ~= key) then
            error("groupBy key function must not return nil or NaN", 2)
        end
        if grouped[key] == nil then
            grouped[key] = {}
        end
        table.insert(grouped[key], { index, elem })
    end
    return grouped
end

---@param fn fun(...: any): any
---@param ... any
---@return fun(...: any): any
function funkmoon.partial(fn, ...)
    local definedArgs = pack(...)
    return function(...)
        local callArgs = pack(...)
        local allArgs = { n = 0 }
        appendPacked(allArgs, definedArgs)
        appendPacked(allArgs, callArgs)
        return fn(unpack(allArgs, 1, allArgs.n))
    end
end

---@param fn fun(...: any): any
---@param ... any
---@return fun(...: any): any
function funkmoon.partialLast(fn, ...)
    local definedArgs = pack(...)
    return function(...)
        local callArgs = pack(...)
        local allArgs = { n = 0 }
        appendPacked(allArgs, callArgs)
        appendPacked(allArgs, definedArgs)
        return fn(unpack(allArgs, 1, allArgs.n))
    end
end

---@param value table
---@return boolean
function funkmoon.isEmpty(value)
    return next(value) == nil
end

local function compareExtreme(list, isBetter)
    local length = #list
    if length == 0 then
        return funkmoon.FunctionalTable({})
    end
    local selected = list[1]
    local selectedType = type(selected)
    if selectedType ~= "number" and selectedType ~= "string" then
        error("max/min values must all be numbers or all be strings", 2)
    end
    for index = 2, length do
        local elem = list[index]
        if type(elem) ~= selectedType then
            error("max/min values must all be numbers or all be strings", 2)
        end
        if isBetter(elem, selected) then
            selected = elem
        end
    end
    return funkmoon.FunctionalTable({ selected })
end

---@generic T : number | string
---@param list T[]
---@return funkmoon.FunctionalTable<T> Empty or containing the greatest element.
function funkmoon.max(list)
    return compareExtreme(list, function(value, selected)
        return value > selected
    end)
end

---@generic T : number | string
---@param list T[]
---@return funkmoon.FunctionalTable<T> Empty or containing the smallest element.
function funkmoon.min(list)
    return compareExtreme(list, function(value, selected)
        return value < selected
    end)
end

---@generic T
---@param list T[]
---@return T? first
function funkmoon.head(list)
    return list[1]
end

---@generic T
---@param list T[]
---@return T? last
function funkmoon.last(list)
    return list[#list]
end

---@generic T
---@param list T[]
---@param count integer
---@return funkmoon.FunctionalTable<T>
function funkmoon.take(list, count)
    local result = {}
    local limit = math.min(#list, math.max(0, math.floor(count)))
    for index = 1, limit do
        result[index] = list[index]
    end
    return funkmoon.FunctionalTable(result)
end

---@generic T
---@param list T[]
---@param count integer
---@return funkmoon.FunctionalTable<T>
function funkmoon.drop(list, count)
    local result = {}
    local first = math.min(#list + 1, math.max(1, math.floor(count) + 1))
    for index = first, #list do
        table.insert(result, list[index])
    end
    return funkmoon.FunctionalTable(result)
end

---@generic T
---@param list T[]
---@param predicate? fun(value: T): boolean
---@return integer
function funkmoon.count(list, predicate)
    local result = 0
    for _, elem in ipairs(list) do
        if predicate == nil or predicate(elem) then
            result = result + 1
        end
    end
    return result
end

---@generic T
---@param list T[]
---@param fn fun(value: T, index: integer)
---@return funkmoon.FunctionalTable<T>
function funkmoon.each(list, fn)
    for index, elem in ipairs(list) do
        fn(elem, index)
    end
    return funkmoon.FunctionalTable(list)
end

---@param list number[]
---@return number
function funkmoon.sum(list)
    local total = 0
    for _, value in ipairs(list) do
        total = total + value
    end
    return total
end

---@generic T
---@param ... T[]
---@return funkmoon.FunctionalTable<T>
function funkmoon.concat(...)
    local result = {}
    local listCount = select("#", ...)
    for listIndex = 1, listCount do
        local list = select(listIndex, ...)
        for _, elem in ipairs(list) do
            table.insert(result, elem)
        end
    end
    return funkmoon.FunctionalTable(result)
end

---@generic T, U
---@param list T[]
---@param otherList U[]
---@return funkmoon.FunctionalTable<[T, U]>
function funkmoon.zip(list, otherList)
    local zipped = {}
    local length = math.min(#list, #otherList)
    for index = 1, length do
        zipped[index] = { list[index], otherList[index] }
    end
    return funkmoon.FunctionalTable(zipped)
end

---@generic T, U
---@param list [T, U][]
---@return T[] firstValues
---@return U[] secondValues
function funkmoon.unzip(list)
    local firstValues = {}
    local secondValues = {}
    for _, pair in ipairs(list) do
        table.insert(firstValues, pair[1])
        table.insert(secondValues, pair[2])
    end
    return firstValues, secondValues
end

---@generic T
---@param list T[]
---@param from integer
---@param to integer
---@return funkmoon.FunctionalTable<T>
function funkmoon.slice(list, from, to)
    local result = {}
    local first = math.max(1, math.floor(from))
    local lastIndex = math.min(#list, math.floor(to))
    for index = first, lastIndex do
        table.insert(result, list[index])
    end
    return funkmoon.FunctionalTable(result)
end

---@generic T
---@param list T[]
---@return funkmoon.FunctionalTable<T>
function funkmoon.reverse(list)
    local result = {}
    for index = #list, 1, -1 do
        table.insert(result, list[index])
    end
    return funkmoon.FunctionalTable(result)
end

---@param args funkmoon.PackedArguments Packed argument array; set `args.n` to preserve trailing or interior nil values.
---@param fn fun(...: any): any
---@return any ...
function funkmoon.apply(args, fn)
    local count = packedLength(args)
    return fn(unpack(args, 1, count))
end

---@generic T, U
---@param list T[]
---@param fallback U | fun(): U
---@return T[] | funkmoon.FunctionalTable<T> | U
function funkmoon.ifEmpty(list, fallback)
    if not funkmoon.isEmpty(list) then
        return list
    end
    if type(fallback) == "function" then
        return fallback()
    end
    return fallback
end

---@generic T
---@param value T
---@return T
function funkmoon.identity(value)
    return value
end

---@generic T
---@param value T
---@return fun(): T
function funkmoon.constant(value)
    return function()
        return value
    end
end

---@overload fun<T>(): fun(value: T): T
---@overload fun<A, B>(fn: fun(value: A): B): fun(value: A): B
---@overload fun<A, B, C>(f: fun(value: B): C, g: fun(value: A): B): fun(value: A): C
---@overload fun<A, B, C, D>(f: fun(value: C): D, g: fun(value: B): C, h: fun(value: A): B): fun(value: A): D
---@overload fun<A, B, C, D, E>(f: fun(value: D): E, g: fun(value: C): D, h: fun(value: B): C, i: fun(value: A): B): fun(value: A): E
---@overload fun<A, B, C, D, E, F>(f: fun(value: E): F, g: fun(value: D): E, h: fun(value: C): D, i: fun(value: B): C, j: fun(value: A): B): fun(value: A): F
---@param ... fun(...: any): any Functions applied from right to left.
---@return fun(...: any): any
function funkmoon.compose(...)
    local functions = pack(...)
    return function(...)
        if functions.n == 0 then
            return ...
        end
        local result = pack(functions[functions.n](...))
        for index = functions.n - 1, 1, -1 do
            result = pack(functions[index](result[1]))
        end
        return unpack(result, 1, result.n)
    end
end

---@overload fun<T>(value: T): T
---@overload fun<T, U>(value: T, fn: fun(value: T): U): U
---@overload fun<T, U, V>(value: T, first: fun(value: T): U, second: fun(value: U): V): V
---@overload fun<T, U, V, W>(value: T, first: fun(value: T): U, second: fun(value: U): V, third: fun(value: V): W): W
---@overload fun<T, U, V, W, X>(value: T, first: fun(value: T): U, second: fun(value: U): V, third: fun(value: V): W, fourth: fun(value: W): X): X
---@overload fun<T, U, V, W, X, Y>(value: T, first: fun(value: T): U, second: fun(value: U): V, third: fun(value: V): W, fourth: fun(value: W): X, fifth: fun(value: X): Y): Y
---@param value any
---@param ... fun(...: any): any Functions applied from left to right.
---@return any
function funkmoon.pipe(value, ...)
    local functions = pack(...)
    local result = value
    for index = 1, functions.n do
        result = functions[index](result)
    end
    return result
end

---@generic T
---@param effect fun(value: T)
---@return fun(value: T): T
function funkmoon.tap(effect)
    return function(value)
        effect(value)
        return value
    end
end

---@generic T
---@param iterator fun(): T?
---@param fn fun(value: T): any
---@return fun(): any
function funkmoon.imap(iterator, fn)
    return function()
        local value = iterator()
        if value == nil then
            return nil
        end
        return fn(value)
    end
end

---@generic T
---@param iterator fun(): T?
---@param predicate fun(value: T): boolean
---@return fun(): T?
function funkmoon.ifilter(iterator, predicate)
    return function()
        while true do
            local value = iterator()
            if value == nil then
                return nil
            end
            if predicate(value) then
                return value
            end
        end
    end
end

---@generic T
---@param iterator fun(): T?
---@param count integer
---@return fun(): T?
function funkmoon.itake(iterator, count)
    local remaining = math.max(0, math.floor(count))
    return function()
        if remaining == 0 then
            return nil
        end
        remaining = remaining - 1
        return iterator()
    end
end

---@generic T, U
---@param left fun(): T?
---@param right fun(): U?
---@return fun(): [T, U]?
function funkmoon.izip(left, right)
    return function()
        local first = left()
        if first == nil then
            return nil
        end
        local second = right()
        if second == nil then
            return nil
        end
        return { first, second }
    end
end

local funkMetaTable = {
    map = funkmoon.map,
    flatMap = funkmoon.flatMap,
    flatten = funkmoon.flatten,
    flattenDeep = funkmoon.flattenDeep,
    filter = funkmoon.filter,
    filterNot = funkmoon.filterNot,
    find = funkmoon.find,
    findValue = funkmoon.findValue,
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
    head = funkmoon.head,
    last = funkmoon.last,
    take = funkmoon.take,
    drop = funkmoon.drop,
    count = funkmoon.count,
    each = funkmoon.each,
    sum = funkmoon.sum,
    concat = function(list, ...)
        return funkmoon.concat(list, ...)
    end,
    slice = funkmoon.slice,
    reverse = funkmoon.reverse,
    zip = funkmoon.zip,
    unzip = funkmoon.unzip,
    apply = funkmoon.apply,
    isEmpty = funkmoon.isEmpty,
    any = funkmoon.any,
    all = funkmoon.all,
    ifEmpty = funkmoon.ifEmpty,
}

---@generic T
---@param list T[]
---@return funkmoon.FunctionalTable<T>
function funkmoon.FunctionalTable(list)
    setmetatable(list, { __index = funkMetaTable })
    return list
end

---@param elemTable table
---@return any[]
function funkmoon.Listify(elemTable)
    local list = {}
    for key, elem in pairs(elemTable) do
        if type(key) == "number" then
            table.insert(list, elem)
        else
            table.insert(list, { key, elem })
        end
    end
    return list
end

---@generic T
---@param count integer
---@return fun(value: T): fun(): T?
function funkmoon.ifill(count)
    return function(value)
        local remaining = math.max(0, math.floor(count))
        return function()
            if remaining == 0 then
                return nil
            end
            remaining = remaining - 1
            return value
        end
    end
end

---@generic T
---@param count integer
---@return fun(value: T): funkmoon.FunctionalTable<T>
function funkmoon.fill(count)
    return function(value)
        local result = {}
        local length = math.max(0, math.floor(count))
        for index = 1, length do
            result[index] = value
        end
        return funkmoon.FunctionalTable(result)
    end
end

local function checkRangeParams(from, to, step)
    assert(from <= to, "'from' must be smaller than or equal to 'to'.")
    assert(step > 0, "'step' must be positive.")
end

---@param from number
---@param to number
---@param step? number
---@return fun(): number?
function funkmoon.irange(from, to, step)
    if step == nil then
        step = 1
    end
    checkRangeParams(from, to, step)
    local current = from
    return function()
        if current > to then
            return nil
        end
        local result = current
        current = current + step
        return result
    end
end

---@param from number
---@param to number
---@param step? number
---@return number[]
function funkmoon.range(from, to, step)
    local result = {}
    for value in funkmoon.irange(from, to, step) do
        table.insert(result, value)
    end
    return result
end

---@param fn fun(...: any): any
---@param ... any Initial state passed to the transition function.
---@return fun(): any
function funkmoon.stream(fn, ...)
    local values = pack(...)
    return function()
        local nextValues = pack(fn(unpack(values, 1, values.n)))
        if nextValues.n == 1 and type(nextValues[1]) == "table" then
            local nextState = nextValues[1]
            local stateLength = nextState.n or #nextState
            values = { n = stateLength }
            for index = 1, stateLength do
                values[index] = nextState[index]
            end
        else
            values = nextValues
        end
        return unpack(values, 1, values.n)
    end
end

---@generic T
---@param count integer
---@param fn fun(): T?
---@return fun(): T?
function funkmoon.itimes(count, fn)
    local remaining = math.max(0, math.floor(count))
    return function()
        if remaining == 0 then
            return nil
        end
        remaining = remaining - 1
        return fn()
    end
end

return funkmoon
