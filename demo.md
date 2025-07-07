# Markup demo

## Basic formatting

This is a paragraph with **bold**, _italic_, ++underlined++, ==highlighted==, and ~~strikethrough~~ text. This paragraph also contains inline figures.

%rfig Right-aligned figure
    @[static/drawing.svg]
%

Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.

You can include a block figure~:

%fig The caption
    @[static/drawing.svg]
%

There is also `inline code` as well as

```
code blocks
```

together with some maths, inline $x=1$ and display ((using $\KaTeX$, see [katex.org](katex.org) ))

$$
\tag{$\star$}\forall f\in\L(E),\; \dim E = \rg f + \dim\ker f
$$

## Lists

You can create lists as you would in markdown

- here is a first item

  - here is a nested item

    with another paragraph

  - a second nested item with a quote

    %quote Me developping this software, 2025
        I wanted to put a quote here, but I couldn't find the perfect one. If you're more inspired than I am, feel free to submit a PR.
    %

- back to level one

* a list can only contain one bullet type

## Hrules

There are several content spacer styles

===

---

^^^

## Environments

%thm Theorem

    ```
    %thm Theorem
        ...
    %

    ```

%

%cor Corollary

    ```
    %cor Corollary
        ...
    %

    ```

%

%lemma Lemma

    ```
    %lemma Lemma
        ...
    %

    ```

%

%def Definition

    ```
    %def Definition
        ...
    %

    ```

%

%rem

    ```
    %rem
        ...
    %

    ```

%

%eg

    ```
    %eg
        ...
    %

    ```

%

%exercise

    ```
    %exercise
        ...
    %

    ```

%

Environments can be nested

%thm Level 1
    %fold Level 2
        Each level must be indented by 4 spaces
    %
%

%thm Theorem name
    Here is some text
%

%proof
    Here is the proof of the theorem
%
