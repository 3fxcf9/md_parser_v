# Heading (can contain ++_formatting_++) OK

## Basic syntax

paragraph OK

**bold** or __bold__ OK
*italic* or _italic_ OK
++underline++ OK
==highlighted== OK
~~strikethrough~~ OK

...~... nbsp OK
...~:.. nnbsp OK

[link](url) OK
{{footnote}}
((sidenote))  -> https://scripter.co/sidenotes-using-only-css/ for style inspiration

`inline code` OK

```lang
code block OK
```

$inline math$ OK

$$
display math OK
$$

\[
display math
\]

## Lists

- dash OK
  + nested OK

* dot OK

+ star OK

> vartriangleright

-> rightarrow

~ auto (> then \* then + then -)


### Edge-cases

- a first list

+ second list (incompatible bullets)

7. ordered list starting at 7

1. No matter what goes next


2. Two empty lines ends the list


## Hline

=== filled hline
--- dashed hline
... dotted hline
^^^ sawtooth hline

## Environments

### Syntax

%name params

%

### Example

%thm Caractérisation du rang par extraction de matrice inversible
...
%

### Standard environments

- thm [name]
- cor [name]
- lemma [name]
- rem
- eg
- exo (trouver equivalent en anglais)
- fold
- conceal / block <level/categ>

%env
text

    %env
    text

        %env
        text
            %env
            text
            %
        %
    %

%

%env
text
%%env
text
%%%env
text
%%%%env
text
%%%%
%%%
%%
%
