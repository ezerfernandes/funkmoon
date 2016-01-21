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
```

### partition
Partitions 'list' in two tables according to 'predicate'.
```lua
local pares, impares = partition({1, 3, 2, 7, 4, 9}, function(n) return n % 2 == 0 end)
-- pares = {2, 4}; impares = {1, 3, 7, 9}
```

### takeWhile
Takes longest prefix of elements of 'list' that satisfy 'predicate'.
```lua
```

### dropWhile
Drops longest prefix of elements of 'list' that satisfy 'predicate'.
```lua
```

### exists
Tests whether 'predicate' holds for some of the elements of 'list'.
```lua
```

### forall
Tests whether 'predicate' holds for all elements of 'list'.
```lua
```

### corresponds 
Tests whether every element of 'list' relates to the corresponding element of 'otherList' by satisfying a test predicate.
```lua
```

### fill
Creates a table with 'value' repeated 'n' times.
```lua
```

### distinct
Builds a new list from this 'list' with no duplicate elements.
```lua
```

### groupBy
Gets the elements and keys from 'list' and partitions them by the result of the function fn(key, element), returning a new table where fn(key, element) are the keys and the values are tables with the keys and values.
```lua
```

### partial
Returns a new function with partial application of the given arguments.
```lua
```

### isEmpty
Teste whether 'list' is empty.
```lua
```

### max
```lua
```

### min
```lua
```

### zip 
Returns a new table formed from 'list' and 'otherList' by combining corresponding elements in pairs.
```lua
```

### unzip
Converts this 'list' of pairs into two tables of the first and second half of each pair.
```lua
```

### slice
Returns a new table with the elements of 'list' from 'from' to 'to'.
```lua
```

### reverse
Returns a new table with the elements of 'list' reversed.
```lua
```

### distinct
Returns a new table with all dinstinct elements of 'list'.
```lua
```
