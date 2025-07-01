# Markup demo

## Basic formatting

This is a paragraph with **bold**, _italic_, ++underlined++, ==highlighted==, and ~~strikethrough~~ text.

There is also `inline code` as well as

```
code blocks
```

together with some maths, inline $x=1$ and display

$$
\forall f\in\L(E),\; \dim E = \rg f + \dim\ker f
$$

## Lists

You can create lists as you would in markdown

- here is a first item

  * here is a nested item

    with another paragraph

  * a second nested item with a definition

    %def Definition
        Here is a definition
    %

- back to level one

+ a list can only contain one bullet type


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


Environments can be nested

%thm Level 1
    %fold Level 2
        Each level must be indented by 4 spaces
    %
%
