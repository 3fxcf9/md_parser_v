pub struct Token {
	kind  TokenKind
	lit   string
	level u8 // For .indent
}

enum TokenKind {
	text
	newline
	space
	dot
	star
	plus
	equal
	dash
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
	indent
}

const reset = '\x1b[0m'
const gray = '\x1b[90m'
const green = '\x1b[32m'
const yellow = '\x1b[33m'
const blue = '\x1b[34m'
const cyan = '\x1b[36m'
const magenta = '\x1b[35m'
const red = '\x1b[31m'
const bold_white = '\x1b[1;97m'

pub fn (t Token) str() string {
	return match t.kind {
		.newline {
			'${gray}⏎\n${reset}'
		}
		.text {
			'${bold_white}[TEXT:${t.lit}]${reset}'
		}
		.indent {
			'${cyan}[INDENT:${t.level}]${reset}'
		}
		.space {
			'${gray}[SPACE]${reset}'
		}
		.dot {
			'${yellow}[.]${reset}'
		}
		.star {
			'${green}[*]${reset}'
		}
		.plus {
			'${green}[+]${reset}'
		}
		.equal {
			'${yellow}[=]${reset}'
		}
		.dash {
			'${green}[-]${reset}'
		}
		.underscore {
			'${magenta}[UNDERSCORE]${reset}'
		}
		.dollar {
			'${green}[\\$]${reset}'
		}
		.hash {
			'${blue}[#]${reset}'
		}
		.percent {
			'${cyan}[%]${reset}'
		}
		.tilde {
			'${red}[~]${reset}'
		}
		.colon {
			'${blue}[:]\${reset}'
		}
		else {
			'${red}[DELIM:${t.lit}]${reset}'
		}
	}
}

fn tokenize(input string) []Token {
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
		`:`:  TokenKind.colon
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
