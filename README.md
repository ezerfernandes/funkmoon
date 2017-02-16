# funkmoon - Functional Tools for Lua

It's a collection of functions that can be used to manipulate tables in a functional style, similar to Scala. You can also use it as methods to simulate a pipeline style.

## Ways of using it
### Using as standalone functions
```lua
local funkmoon = require "funkmoon"

local list = {1, 2, -3, 4}

-- Returns only even numbers.
local even = funkmoon.filter(list, function(n) return n % 2 == 0 end)
```

### Using functions as methods
This is the preferred way if you want to use several functions as a pipeline, simulating what you can do in functional languages as Scala, for example.

```lua
local funkmoon = require "funkmoon"

-- Returns the sum of the squares of even numbers.
local list = funkmoon.FunctionalTable({1, 2, -3, 4, 9, 8})

local sumOfSquaresEvenNumbers = list
        :filter(function(n) return n % 2 == 0 end)
        :map(function(n) return n*n end)
        :reduce(function(a, b) return a + b end)
```

FunctionalTable adds a metatable that allows to call the functions as methods and use this development style.

## Examples
### map
Builds a new table by applying 'fn' to all elements of 'list' and using the elements of the resulting tables.
```lua
local list = {3, 5, 8}
local squares = funkmoon.map(list, function(n) return n*n end)
-- Result: {9, 25, 64}
```

### flatMap
Builds a new table by applying 'fn' to all elements of 'list' and using the elements of the resulting tables.
```lua
local values = {0, 5, 10}
local mapped = funkmoon.flatMap(values, function(x) return {x-1, x, x+1} end)
-- Result: {-1, 0, 1, 4, 5, 6, 9, 10, 11}
```

### filter
Selects all elements of 'list' which satisfy 'predicate'.
```lua
local list = {1, 4, 6, 3, 7}
local oddNumbers = funkmoon.filter(list, function(n) return n % 2 == 1 end)
-- Result: {1, 3, 7}
```

### filterNot
Selects all elements of 'list' which don't satisfy 'predicate'.
```lua
local values = {1, 2, 3, 4}
local filtered = funkmoon.filterNot(values, function(n) return n % 2 == 0 end)
-- Result: {2, 4}
```

### foldLeft
Applies a binary function (fn) to startValue and all elements of 'list', going left to right.
```lua
local list = {1, 2, 3, 4, 5}
local sum = funkmoon.foldLeft(list, 0)(function(acc, n) return acc + n end)
-- Result: 16
```

### foldRight
Applies a binary function (fn) to startValue and all elements of 'list', going right to left.
```lua
```

### reduce
Reduces the elements of 'list' using the binary operator 'fn'.
```lua
local values = {1, 2, 3, 4, 5}
local result = reduce(values, function(acc, n) return acc * n end)
-- result: 120
```

### find
Finds the first element of 'list' satisfying a predicate, if any.
```lua
local values = {1, 5, 8, 3, 9, 4, 6}
local result = funkmoon.find(values, function(n) return n % 2 == 0 end)
-- result: { [3] = 8 }
```

### arrayPart
Returns the array-like part of list (1 to n).
```lua
local mixedTable = { foo = 3, 2 = "hello", bar = "world", 1 = 42 }
local result = funkmoon.arrayPart(mixedTable)
-- result: {42, "hello"}
```

### partition
Partitions 'list' in two tables according to 'predicate'.
```lua
local evens, odds = partition({1, 3, 2, 7, 4, 9}, function(n) return n % 2 == 0 end)
-- evens = {2, 4}; odds = {1, 3, 7, 9}
```

### takeWhile
Takes longest prefix of elements of 'list' that satisfy 'predicate'.
```lua
local testList = {1, 2, 3, 4, 0, 2, 5}
local result = funkmoon.takeWhile(testList, function(n) return n < 4 end)
-- result: {1, 2, 3}
```

### dropWhile
Drops longest prefix of elements of 'list' that satisfy 'predicate'.
```lua
local testList = {1, 2, 3, 4, 0, 2, 5}
local result = funkmoon.takeWhile(testList, function(n) return n < 4 end)
-- result: {4, 0, 2, 5}
```

### any
Tests whether 'predicate' holds for some of the elements of 'list'.
```lua
local values = {1, 2, 7, 0}
local result = funkmoon.any(values, function(n) return n > 5 end)
-- result: true
```

### all
Tests whether 'predicate' holds for all elements of 'list'.
```lua
local values = {1, 2, 7, 0}
local result = funkmoon.all(values, function(n) return n > 5 end)
-- result: false
```

### corresponds
Tests whether every element of 'list' relates to the corresponding element of 'otherList' by satisfying a test predicate.
```lua
local aList = {1, 2, 3}
local anotherList = {2, 4, 6}
local result = funkmoon.corresponds(aList, anotherList)(function(a, b) return 2*a == b end)
-- result: true
```

### fill
Creates a table with 'value' repeated 'n' times.
```lua
local result = funkmoon.fill(3)("hello!")
-- result: {"hello!", "hello!", "hello!"}
```

### distinct
Builds a new list from this 'list' with no duplicate elements.
```lua
local list = {1, 2, 2, 3, 1, 2, 5}
local result = funkmoon.distinct(list)
-- result: {1, 2, 3, 5}
```

### groupBy
Gets the elements and keys from 'list' and partitions them by the result of the function fn(key, element), returning a new table where fn(key, element) are the keys and the values are tables with the keys and values.
```lua
```

### partial
Returns a new function with partial application of the given arguments.
```lua
local function sum(a, b)
        return a + b
end

local increment = funkmoon.partial(sum, 1)

local result = increment(4)
-- result: 5
```

### apply
Applies a function using list as an argument
```lua
local values = {0, 9, -4}

-- sum the three values
local result = funkmoon.apply(values, function(a, b, c) return a+b+c end)
```

### isEmpty
Test whether 'list' is empty.
```lua
local result = funkmoon.isEmpty({}) -- result: true
result = funkmoon.isEmpty({2, 3}) -- result: false
```

### max
Returns a functional table with the greatest element of a table. 
```lua
-- result: 9
local result = funkmoon.max({-3, 2, 9, 4})

-- square of the greatest number
local result = funkmoon.FunctionalTable(values)
        :max()
        :apply(function (n) return n * n end)
```

### min
Returns a functional table with the smallest element of a table. 
```lua
-- result: -3
local result = funkmoon.min({-3, 2, 9, 4})

-- checks if the smallest number is positive.
local result = funkmoon.FunctionalTable(values)
        :min()
        :forall(function(n) return n > 0 end)
```

### zip
Returns a new table formed from 'list' and 'otherList' by combining corresponding elements in pairs.
```lua
local x = {1, 2}
local y = {"blue", "green"}
local result = funkmoon.zip(x, y)
-- result: { {1, "blue"}, {2, "green"} }
```

### unzip
Converts this 'list' of pairs into two tables of the first and second half of each pair.
```lua
local list = { {5, 'a'}, {8, 'b'} }
local numbers, letters = funkmoon.unzip(list)
-- numbers = {5, 8}; letters = {'a', 'b'}
```

### slice
Returns a new table with the elements of 'list' from 'from' to 'to'.
```lua
local list = {5, 21, 8, 2, 9, 11}
local result = funkmoon.slice(list, 3, 5)
-- result: {8, 2, 9}
```

### reverse
Returns a new table with the elements of 'list' reversed.
```lua
local list = {5, 2, 4, 1}
local result = funkmoon.reverse(list)
-- result: {1, 4, 2, 5}
```

### range
```lua
local result = funkmoon.range(1, 5, 2)
-- result: {1, 3, 5}
```

### irange
```lua
for i in funkmoon.irange(1, 4, 2) do
    print(i)
end
--[[
printed:
1
3
]]
```

### fill
Creates a table with 'value' repeated 'n' times.
```lua
local result = funkmoon.fill(3)("hello!")
-- result: {"hello!", "hello!", "hello!"}
```

### ifill
[explanation]
```lua

```

### stream
[explanation]
```lua
```

### itimes
[explanation]
```lua
```
