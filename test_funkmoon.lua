funkmoon = require "funkmoon"

local values = {3, 6, 0, -5, 4, 8}

function test_map()
    local expected = {9, 36, 0, 25, 16, 64}
    local mapped = funkmoon.map(values, function(n) return n * n end)
    for i, elem in pairs(mapped) do
        assert(expected[i] == elem, "test_map failed.")
    end
end

function test_flatMap()
    local expected = {0, 1, 2, 1, 2, 3, 2, 3, 4}
    local mapped = funkmoon.flatMap({1, 2, 3}, function(x) return {x-1, x, x+1} end)
    for i, elem in pairs(expected) do
        assert(elem == expected[i], "test_flatMap failed.")
    end
end

function test_filter()
    local expected = {6, 0, 4, 8}
    local filtered = funkmoon.filter(values, function(n) return n % 2 == 0 end)
    for i, elem in pairs(filtered) do
        assert(expected[i] == elem, "test_filter failed.")
    end
end

function test_filterNot()
    local expected = {3, -5}
    local filtered = funkmoon.filterNot(values, function(n) return n % 2 == 0 end)
    for i, elem in pairs(filtered) do
        assert(expected[i] == elem, "test_filter failed.")
    end
end

function test_find()
    local expected = { [2] = 6 }
    local got = funkmoon.find(values, function(n) return n % 2 == 0 end)
    for i, elem in pairs(got) do
        assert(elem == expected[i])
    end
end

function test_foldLeft()
    local expected = 16
    local folded = funkmoon.foldLeft(values, 0)(function(acc, n) return acc + n end)
    assert(expected == folded, "test_foldLeft failed.")
end

function test_foldRight()
    local expected = 98
    local folded = funkmoon.foldRight(values, 100)(function(acc, n) return n - acc end)
    assert(expected == folded, "test_foldRight failed.")
end

function test_reduce()
    local expected = 16
    local reduced = funkmoon.reduce(values, function(acc, n) return acc + n end,
                           "test_reduce failed.")
    assert(expected == reduced)
end


function test_exists()
    assert(funkmoon.exists(values, function(n) return n > 5 end) == true,
           "test_exists failed.")
end

function test_forall()
    assert(funkmoon.forall(values, function(n) return n > 5 end) == false)
end

function test_fill()
    local testList = funkmoon.fill(5)("hello!")
    for _, elem in pairs(testList) do
        assert(elem == "hello!", "test_fill failed.")
    end
end

function test_distinct()
    local testList = {1, 2, 3, 1, 2, 5}
    local expected = {1, 2, 3, 5}
    local got = funkmoon.distinct(testList)
    for i, elem in pairs(got) do
        assert(elem == expected[i], "test_distinct failed.")
    end
end

function test_functional_table()
    local testList = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11}
    local got = funkmoon.FunctionalTable(testList)
                    :filter(function(n) return n % 2 == 0 end)
                    :map(function(n) return n / 2 end)
                    :foldLeft(0)(function(acc, n) return acc + n end)
    assert(got == 15, "test_functional_table failed.")
end

function test_group_by()
    local testList = {1, 5, 3, 9, 2, 5}
    local agrupado = funkmoon.groupBy(testList, function(k, v) return k % 2 end)
    for i, lista in pairs(agrupado) do
        for k, v in pairs(lista) do
            print(i, k, v[1], v[2])
        end
    end
end

function test_partial()
    local function division(a, b) return a / b end
    local fraction = funkmoon.partial(division, 1)
    assert(fraction(4), 0.25)
end

function test_takeWhile()
    local testList = {1, 2, 3, 4, 0, 2, 5}
    local result = funkmoon.takeWhile(testList, function(n) return n < 4 end)
    for _, value in pairs(result) do
        print(value)
    end
end

function test_dropWhile()
    local testList = {1, 2, 2, 4, 6, 2, 1}
    local expected = {6, 2, 1}
    local got = funkmoon.dropWhile(testList, function(n) return n < 5 end)
    for i, elem in pairs(got) do
        assert(elem == expected[i])
    end
end

function test_Listify()
    local testList = {1, 2, hello="world", 3}
    local got = funkmoon.Listify(testList)
    print(got[1], got[2], got[3], got[4][1], got[4][2])
end

function test_isEmpty()
    assert(funkmoon.isEmpty({}) == true)
    assert(funkmoon.isEmpty({1}) == false)
end

function test_max()
    --for i, elem in pairs(max({1, 2, 3, 2, 1})) do print(i, elem) end
end

function test_zip()
    local x = {1, 2, 3, 4, 5}
    local y = {"blue", "green"}
    local z = funkmoon.zip(x, y)
    local expected = { {1, "blue"}, {2, "green"} }
    for i, elem in pairs(z) do
        assert(elem[1] == expected[i][1])
        assert(elem[2] == expected[i][2])
    end
end

function test_corresponds()
    assert(funkmoon.corresponds({1, 2, 3}, {2, 4, 6})(function(a, b) return b == 2*a end) == true)
    assert(funkmoon.corresponds({1, 2}, {1, 2, 3})(function(a, b) return a == b end) == false)
    assert(funkmoon.corresponds({1, 2, 3}, {1, 2})(function(a, b) return a == b end) == false)
end

function test_unzip()
    local numbers, letters = funkmoon.unzip({{5, 'a'}, {8, 'b'}})
    assert(numbers[1] == 5)
    assert(numbers[2] == 8)
    assert(letters[1] == 'a')
    assert(letters[2] == 'b')
end

function test_partition()
    local test = funkmoon.FunctionalTable({1, 2, 4, -2, 9})
    local maior, menor = test:partition(function(n) return n > 2 end)
    assert(maior:reduce(function(a, b) return a + b end) == 13)
    assert(menor:reduce(function(a, b) return a + b end) == 1)
end

function test_stream()
    local expected = {1, 2, 3, 5, 8}
    local function fib(a, b)
        return { b, a+b }
    end
    local i = 1
    for x, y in funkmoon.stream(fib, 1, 1) do
        if i > 5 then
            break
        end
        assert(x == expected[i])
        i = i + 1
    end
end

function test_itimes()
    local expected = {1, 2, 3, 5, 8}
    local function fib(a, b)
        return { b, a+b }
    end
    local i = 1
    for x, y in funkmoon.itimes(5, funkmoon.stream(fib, 1, 1)) do
        assert(x == expected[i])
        i = i + 1
    end
end

function test_irange()
    local expected = {1, 3}
    local j = 1
    for i in funkmoon.irange(1, 4, 2) do
        assert(expected[j] == i)
        j = j + 1
    end
end

function test_range()
    local expected = {1, 3}
    local got = funkmoon.range(1, 4, 2)
    for i, elem in pairs(got) do
        assert(expected[i] == elem)
    end
end

function test_ifill()
    local timesExpected = 3
    local timesGot = 0
    for n in funkmoon.ifill(3)("hello") do
        assert(n == "hello")
        timesGot = timesGot + 1
    end
    assert(timesGot == timesExpected)
end

test_ifill()
test_range()
test_irange()
test_stream()
test_itimes()
test_map()
test_flatMap()
test_partition()
test_corresponds()
test_zip()
test_unzip()
test_max()
test_takeWhile()
test_group_by()
test_filter()
test_filterNot()
test_find()
test_foldLeft()
test_foldRight()
test_reduce()
test_exists()
test_forall()
test_fill()
--test_distinct()
test_functional_table()
test_partial()
test_Listify()
test_isEmpty()
test_dropWhile()
