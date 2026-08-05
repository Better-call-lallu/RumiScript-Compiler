# RumiScript Compiler

A fully functional, tree-walking interpreted programming language built from scratch using **Flex** (Lexical Analyzer) and **Bison** (Parser Generator) with a custom **C backend**.

**Author:** Humayra Akther Khan Rumi 

## 🚀 Features

RumiScript is optimized for mathematical and logical processing, featuring dynamic I/O, control flow, and a C-style syntax structure.

*   **Variables:** Dynamic assignment with unified floating-point architecture (`set x = 10;`).
*   **Input / Output:** Runtime user input via `scan(x)` and formatted output via `print("Text", x)`.
*   **Arithmetic:** Standard operations (`+`, `-`, `*`, `/`) with native zero-division handling and unary minus support.
*   **Math Library:** Built-in evaluation for `abs()`, `pow()`, `max()`, and `min()`.
*   **Control Flow:** Fully featured conditional branching (`if / else`) with relational operators (`>`, `<`, `==`, `!=`, `>=`, `<=`).
*   **Loops:** Supports both fixed iteration (`repeat (5) { ... }`) and dynamic C-style looping (`for (set i=1; i<=10; set i=i+1) { ... }`).

## 🛠️ How It Works Under the Hood

RumiScript executes via a three-step pipeline:
1.  **Scanner (`lexer.l`):** Reads raw code using Regular Expressions to generate structural Tokens.
2.  **Parser (`parser.y`):** Applies Backus-Naur Form (BNF) grammar rules to arrange tokens into an Abstract Syntax Tree (AST).
3.  **Execution Engine (`ast.h` & C):** A recursive tree-walking interpreter that dynamically manages a Linked-List Symbol Table for memory allocation and evaluates the AST nodes on the fly.

## 💻 Installation & Usage

**1. Clone the repository and navigate to the directory:**
```bash
git clone [https://github.com/YourUsername/RumiScript-Compiler.git](https://github.com/YourUsername/RumiScript-Compiler.git)
cd RumiScript-Compiler