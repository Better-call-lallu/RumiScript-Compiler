# RumiScript 🚀

RumiScript is a custom, lightweight programming language built using **Flex** and **Bison** with a **C/C++** backend execution engine.

## Features
- **Custom Identity**: `.rumi` file extension.
- **Dynamic Printing**: Variadic `say()` function for strings and math.
- **Unique Loop**: `repeat (N)` block for fixed iterations without counters.
- **Native Math**: Built-in AST support for `max`, `min`, `pow`, and `abs`.
- **Control Flow**: `when` / `otherwise` logic blocks.

## How to Compile & Run
1. Ensure `flex`, `bison`, and `gcc` are installed.
2. Run `make` in the terminal to build the compiler.
3. Execute a script: `./rumiscript script.rumi`