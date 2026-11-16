# funkmoon

Typed functional tools for Lua: eager sequence operations, lazy iterators, and
small function-composition helpers. `funkmoon` keeps Lua's tables and functions
at the center, with a standalone API and optional method chaining.

The primary target is Lua 5.5.1, the current stable Lua release. Declared
runtime support covers Lua 5.2 through 5.5. The library has no runtime
dependencies.

## Install

After a release is published to LuaRocks, install it with:

```sh
luarocks install funkmoon
```

To install from a source checkout that contains the rockspec, run this from the
repository root:

```sh
luarocks make
```

Then load it as usual:

```lua
local funkmoon = require "funkmoon"
```

## Types in your editor

The library uses LuaCATS annotations understood by [Lua Language Server
(LuaLS)](https://luals.github.io/). Generic annotations help LuaLS infer input
and output types through operations such as `map` and chained sequence calls.
The generic method signatures require LuaLS 3.17.0 or later.
They are comments for editors and static analysis: Lua remains dynamically
typed, and the annotations do not add runtime checks or require a type-checking
package.

```lua
local funkmoon = require "funkmoon"

---@type { name: string, score: number }[]
local players = {
    { name = "Ada", score = 18 },
    { name = "Lin", score = 22 },
}

local names = funkmoon.map(players, function(player)
    return player.name
end) -- LuaLS infers string[]
```

Configure your editor for Lua 5.5 when available. You can use the annotations
without LuaLS; they have no effect when the program runs.

## Sequence contract

Sequence functions operate on **dense, one-based arrays**: indices run from `1`
through `#items` with no holes. They visit values in ascending index order.
Sparse arrays and dictionary keys are outside this contract; use ordinary Lua
table operations for map-like data.

Transformations create a new sequence unless described otherwise. The
`FunctionalTable` constructor adds method access to a table. It does not copy
the input table. Methods that return a sequence can be chained; reductions and
other scalar helpers return their documented value.

## Usage

Call helpers as standalone functions:

```lua
local values = { 1, 2, 3, 4, 5 }
local evenSquares = funkmoon.map(
    funkmoon.filter(values, function(value) return value % 2 == 0 end),
    function(value) return value * value end
)
-- { 4, 16 }
```

Or wrap a sequence to use colon-method pipelines:

```lua
local total = funkmoon.FunctionalTable({ 1, 2, 3, 4, 5 })
    :filter(function(value) return value % 2 == 0 end)
    :map(function(value) return value * value end)
    :reduce(function(accumulator, value) return accumulator + value end)
-- 20
```

## Eager sequence helpers

All functions below can be called as `funkmoon.name(...)`. Sequence-preserving
helpers are also available as methods on a `FunctionalTable`.

| Helper | Behavior |
| --- | --- |
| `map(items, fn)` | Transform each value into a new sequence. |
| `flatMap(items, fn)` | Transform each value into a sequence, then concatenate those results. |
| `filter(items, predicate)` | Keep values for which the predicate is true. |
| `filterNot(items, predicate)` | Keep values for which the predicate is false. |
| `flatten(items)` | Flatten one level of nested sequences. |
| `flattenDeep(items)` | Recursively flatten nested sequences; cyclic tables raise an error. |
| `take(items, n)` / `drop(items, n)` | Keep the first `n` values, or skip them. |
| `takeWhile(items, predicate)` / `dropWhile(items, predicate)` | Keep, or skip, the longest matching prefix. |
| `partition(items, predicate)` | Return two `FunctionalTable`s: matching values, then the rest. |
| `distinct(items)` | Remove duplicates while keeping the first occurrence order. |
| `concat(items, ...)` | Concatenate dense sequences into a `FunctionalTable`. |
| `reverse(items)` | Return a new sequence in reverse order. |
| `slice(items, first, last)` | Copy the inclusive index range `first` through `last`. |
| `zip(left, right)` | Pair corresponding values; stop at the shorter input. |
| `unzip(pairs)` | Return two ordinary sequences from a sequence of pairs. |
| `arrayPart(table)` | Copy the array portion of a table into a `FunctionalTable`. |

Example with an index-aware side effect:

```lua
funkmoon.each({ "red", "green" }, function(color, index)
    print(index, color)
end)
```

`each(items, fn)` calls `fn(value, index)` once per value and returns a
`FunctionalTable` wrapping the same input table, so it can continue a pipeline.
Callbacks may perform side effects; the helper itself does not change values.

## Queries and reductions

| Helper | Behavior |
| --- | --- |
| `head(items)` / `last(items)` | Return the first or last value, or `nil` for an empty sequence. |
| `isEmpty(items)` | Return whether a table has no entries. |
| `count(items, predicate?)` | Count all values, or only values accepted by the optional predicate. The predicate receives the value. |
| `findValue(items, predicate)` | Return the first matching value and its index; return `nil, nil` if none matches. |
| `find(items, predicate)` | Legacy form: return an empty `FunctionalTable`, or a one-entry `FunctionalTable` keyed by the matching original index. |
| `any(items, predicate)` / `all(items, predicate)` | Check whether some, or every, value matches. |
| `corresponds(left, right)(predicate)` | Compare equal-length sequences pairwise using a curried predicate. |
| `groupBy(items, keyFn)` | Group into a table keyed by `keyFn(index, value)`; each group contains `{ index, value }` pairs. Keys must not be `nil` or NaN. |
| `foldLeft(items, initial)(fn)` | Fold from left to right, calling `fn(accumulator, value)`. |
| `foldRight(items, initial)(fn)` | Fold from right to left, still calling `fn(accumulator, value)` for compatibility. |
| `reduce(items, fn)` | Reduce values with `fn(accumulator, value)` and no explicit initial value. |
| `sum(numbers)` | Add numeric values; an empty sequence sums to `0`. |
| `max(items)` / `min(items)` | For sequences of all numbers or all strings, return an empty `FunctionalTable`, or one containing the greatest or least value. |
| `ifEmpty(items, fallback)` | Return `items` when nonempty; otherwise return the fallback value or the result of a zero-argument fallback function. |

The two `find` forms are intentionally different:

```lua
local values = { 3, 8, 5 }

local legacy = funkmoon.find(values, function(value) return value > 6 end)
-- FunctionalTable with key 2 and value 8

local value, index = funkmoon.findValue(values, function(n) return n > 6 end)
-- 8, 2
```

`foldRight` visits values from the final index down to the first. Its callback
argument order remains `(accumulator, value)`; for example, folding `{1, 2, 3}`
from `""` with `function(acc, value) return acc .. value end` produces `"321"`.

## Function helpers

| Helper | Behavior |
| --- | --- |
| `identity(value)` | Return `value` unchanged. |
| `constant(value)` | Return a zero-argument function that always returns `value`. |
| `compose(f, g, ...)` | Compose right to left; the rightmost function receives the initial arguments. With no functions, return the identity behavior. |
| `pipe(value, f, g, ...)` | Pass a value through functions left to right. With no functions, return the input value. |
| `tap(effect)` | Return a function that calls `effect(value)` and then returns the same value. |
| `partial(fn, ...)` | Bind leading arguments and return a function for the remaining arguments. |
| `partialLast(fn, ...)` | Bind trailing arguments and return a function for the preceding arguments. |
| `apply(arguments, fn)` | Call `fn` with the sequence values as its arguments; set `arguments.n` to preserve nil positions. |

```lua
local packed = table.pack("first", nil, "third")
local count, second = funkmoon.apply(packed, function(first, middle, last)
    return select("#", first, middle, last), middle
end)
-- 3, nil
```

```lua
local asLoudText = funkmoon.compose(string.upper, tostring)
print(asLoudText("Lua")) -- "LUA"

local value = funkmoon.pipe(" Lua ", string.lower, funkmoon.tap(print))
-- prints and returns " lua "
```

`compose(f, g)` computes `f(g(value))`. `pipe(value, f, g)` computes
`g(f(value))`. Each stage passes its first returned value to the next stage.
LuaLS preserves types for compositions of up to five functions; longer chains
still run normally but may fall back to `any` in the editor.
`partial`, `partialLast`, `apply`, and `stream` retain explicit nil positions
when their argument table or varargs provide an element count.

## Lazy iterators

The `imap`, `ifilter`, `itake`, and `izip` combinators take iterator functions
that yield one value at a time. A `nil` result signals that iteration has
ended, as in Lua's generic `for` loop. These helpers do not materialize the
full result sequence. `irange` and `ifill` generate values, while `itimes` and
`stream` repeatedly call callbacks to produce them.

| Helper | Behavior |
| --- | --- |
| `imap(iterator, fn)` | Lazily transform each yielded value. `fn` receives the value. |
| `ifilter(iterator, predicate)` | Lazily skip values until one matches. |
| `itake(iterator, n)` | Yield at most `n` values. |
| `izip(left, right)` | Yield `{ leftValue, rightValue }` pairs; end when either iterator ends. |
| `irange(first, last, step?)` | Iterate an inclusive numeric range; default step is `1`. |
| `ifill(n)(value)` | Yield the value `n` times. |
| `itimes(n, fn)` | Call `fn` up to `n` times and yield its return values. |
| `stream(step, ...)` | Repeatedly pass the current state values to `step` and yield its returned state values. |

```lua
local doubled = funkmoon.imap(
    funkmoon.irange(1, 5),
    function(value) return value * 2 end
)

for value in doubled do
    print(value) -- 2, 4, 6, 8, 10
end
```

## Construction and conversion

| Helper | Behavior |
| --- | --- |
| `FunctionalTable(items)` | Wrap a sequence with chainable methods; the original table is retained. |
| `fill(n)(value)` | Create a `FunctionalTable` containing `value` repeated `n` times. |
| `range(first, last, step?)` | Create an inclusive numeric sequence; default step is `1`. |
| `Listify(table)` | Convert array values and keyed entries into a list; keyed entries become `{ key, value }` pairs. |

`range` and `irange` require `first <= last` and a positive step. `fill` and
`ifill` use the curried form shown above: provide the length first, then the
repeated value.

## Contributing

Contributions are welcome. Keep sequence operations compatible with Lua 5.2
through 5.5, preserve the public `require "funkmoon"` entry point, and document any
new public helper in this README. LuaCATS annotations should describe the
runtime behavior without adding runtime dependencies.

## Releasing

Update the module and rockspec versions together, create a matching `vX.Y.Z`
source tag, then submit the rockspec to LuaRocks. The current rockspec points
at `v0.13.0`; that tag should be created as part of the release.

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE).
