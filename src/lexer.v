pub struct Token {
	kind TokenKind
	lit  string
}

enum TokenKind {
	text
	newline
	space
	star
	equal
	plus
	underscore
	dollar
	hash
	percent
	tilde
	colon
	lparen
	rparen
	lbracket
	rbracket
	lcurly
	rcurly
}

fn tokenize(input string) []Token {
	mut tokens := []Token{}
	mut current_text := ''

	rune_to_token_kind := {
		`\n`: TokenKind.newline
		` `:  TokenKind.space
		`*`:  TokenKind.star
		`+`:  TokenKind.plus
		`=`:  TokenKind.equal
		`_`:  TokenKind.underscore
		`$`:  TokenKind.dollar
		`#`:  TokenKind.hash
		`%`:  TokenKind.percent
		`~`:  TokenKind.tilde
		`:`:  TokenKind.colon
		`(`:  TokenKind.lparen
		`)`:  TokenKind.rparen
		`[`:  TokenKind.lbracket
		`]`:  TokenKind.rbracket
		`{`:  TokenKind.lcurly
		`}`:  TokenKind.rcurly
	}

	for ch in input.runes() {
		if current_token := rune_to_token_kind[ch] {
			// Push current text
			if current_text.len > 0 {
				tokens << Token{
					kind: .text
					lit:  current_text
				}
				current_text = ''
			}

			// Add token
			tokens << Token{
				kind: current_token
				lit:  ch.str()
			}
		} else {
			current_text += ch.str()
		}
	}

	// Push remaining text
	if current_text.len > 0 {
		tokens << Token{
			kind: .text
			lit:  current_text
		}
	}

	return tokens
}
