module lexer

pub fn tokenize(input string) []Token {
	mut tokens := []Token{}
	mut current_text := ''

	rune_to_token_kind := {
		`\n`: TokenKind.newline
		` `:  TokenKind.space
		`.`:  TokenKind.dot
		`*`:  TokenKind.star
		`+`:  TokenKind.plus
		`=`:  TokenKind.equal
		`-`:  TokenKind.dash
		`_`:  TokenKind.underscore
		`$`:  TokenKind.dollar
		`#`:  TokenKind.hash
		`%`:  TokenKind.percent
		`~`:  TokenKind.tilde
		`^`:  TokenKind.caret
		`:`:  TokenKind.colon
		`\``: TokenKind.backtick
		`(`:  TokenKind.lparen
		`)`:  TokenKind.rparen
		`[`:  TokenKind.lbracket
		`]`:  TokenKind.rbracket
		`{`:  TokenKind.lcurly
		`}`:  TokenKind.rcurly
	}

	mut current_indentation_level := 0

	for ch in input.runes() {
		if current_indentation_level >= 0 && ch == ` ` {
			current_indentation_level++
			continue
		} else if current_indentation_level > 0 {
			tokens << Token{
				kind:  .indent
				lit:   ' '.repeat(current_indentation_level)
				level: u8(current_indentation_level)
			}
			current_indentation_level = -1
		} else {
			current_indentation_level = -1
		}

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

			// Reset indentation if newline
			if current_token == .newline {
				current_indentation_level = 0
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
