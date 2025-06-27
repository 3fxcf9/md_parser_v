# Heading

## Basic syntax

paragraph OK

**bold** or __bold__ OK
*italic* or _italic_ OK
++underline++ OK
==highlighted== OK
~~strikethrough~~

~ nbsp OK
~: nnbsp

[link](url)
((footnote))
{{sidenote}}

`inline code`

```lang
code block
```

$inline math$

$$
display math OK
$$

\[
display math OK
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

