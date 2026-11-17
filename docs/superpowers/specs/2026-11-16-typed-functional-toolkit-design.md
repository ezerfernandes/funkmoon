# Typed Functional Toolkit Design

## Goal

Make `funkmoon` a dependable, easy-to-adopt functional utility library for modern Lua. Preserve the existing `require "funkmoon"` entry point and established API names while adding editor-visible generic types, fixing collection edge cases, and filling common gaps in eager and lazy pipelines.

## Runtime and type contract

- Lua 5.5.1 is the primary documented runtime, as it is the latest stable Lua release.
- Declare runtime compatibility for Lua 5.2 through 5.5. The implementation uses `table.unpack` and `table.pack`, which sets a practical lower bound of 5.2.
- Keep the runtime dependency-free and write executable code as ordinary Lua.
- Use LuaCATS annotations understood by Lua Language Server (LuaLS) for generic signatures and editor type checking. Lua itself remains dynamically typed; annotations do not add runtime checks.
- Require LuaLS 3.17.0 or later for generic method fields and composition overload inference.
- Keep the module path and old standalone and colon-method call forms stable.

## Collection semantics

- Sequence functions consume dense, one-based Lua arrays in ascending index order. Sparse arrays have no portable length or traversal order, so they are outside the sequence contract.
- Transforming functions return fresh sequence tables. Existing result shapes are retained where practical; new helpers use conventional scalar or sequence results.
- Keep existing callback argument lists stable, except `groupBy` continues to receive `(index, value)` and new `each` receives `(value, index)`.
- Make `filter`, `filterNot`, `takeWhile`, and `dropWhile` traverse in defined ascending sequence order. Preserve their established predicate behavior; make `distinct` retain first-occurrence order and call the `groupBy` key function exactly once per element.
- Reject `nil` and NaN `groupBy` keys with a clear error, and detect cycles in `flattenDeep` rather than recursing indefinitely.
- Type `max` and `min` for numbers and strings, which Lua can compare without custom metatables.
- Keep `find`'s legacy one-entry FunctionalTable result and add a conventional value-oriented helper for callers who want a scalar result.
- Preserve `foldRight` callback argument order for compatibility and document it accurately.
- Capture explicit vararg counts in `partial`, `partialLast`, `apply`, and `stream` so `nil` arguments and multiple return values survive.

## API additions

Add common eager sequence helpers (`head`, `last`, `take`, `drop`, `count`, `each`, `sum`, and `concat`), a value-oriented `findValue`, and function composition helpers (`identity`, `constant`, `compose`, `pipe`, and `tap`). Add lazy iterator counterparts for map, filter, take, and zip so callers can avoid materializing large sequences. LuaLS overloads preserve types through up to five composition stages. All public helpers are available as standalone functions; sequence-preserving helpers are also available through `FunctionalTable` methods.

## Packaging and documentation

- Add a LuaRocks rockspec for the current module and declare the supported Lua range.
- Rewrite the README around installation, typed usage, the sequence contract, complete API examples, and contributing/release guidance.
- Track runtime/type-check coverage in the bead plan so the supported-version promise can be verified as the project gains CI.

## Acceptance

The repository exposes the documented generic API from the existing module, keeps Lua 5.2 through 5.5 syntax/runtime compatibility, installs as a LuaRocks package, fixes the listed deterministic and nil-arity defects, and has accurate examples for Lua 5.5.1 users. Type annotations are usable by LuaLS without introducing a runtime or typing-tool dependency.
