# funkmoon - Functional Tools for Lua

It's a collection of functions that can be used to manipulate tables in a functional style, similar to Scala. You can also use it as methods to simulate a pipeline style.

## Ways of using
### Using a standalone function
'''
require "funkmoon"

local list = {1, 2, -3, 4}

-- Returns only even numbers.
local even = filter(list, function(n) return n % 2 == 0 end)
'''

### Using functions as methods
This is the preferred way if you want to use several functions as a pipeline, simulating what you can do in functional languages as Scala, for example.

'''
require "funkmoon"

-- Returns the sum of the squares of even numbers.
local list = FunctionalTable({1, 2, -3, 4, 9, 8})

local sumOfSquaresEvenNumbers = list:filter(function(n) return n % 2 == 0 end):map(function(n) return n*n end):reduce(function(a, b) return a + b end)
'''

## Examples

### Map a 

