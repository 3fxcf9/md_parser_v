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
((footnote))
{{sidenote}}  -> https://scripter.co/sidenotes-using-only-css/ for style inspiration

`inline code`

```lang
code block
```

$inline math$ OK

$$
display math OK
$$

\[
display math
\]

## Lists

- dash

* dot

+ star

> vartriangleright

-> rightarrow

~ auto (> then \* then + then -)

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
