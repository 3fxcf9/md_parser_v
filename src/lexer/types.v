module lexer

pub struct Token {
pub:
	kind  TokenKind
	lit   string
	level u8 // For .indent
}

pub enum TokenKind {
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
	caret
	colon
	backtick
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
		.caret {
			'${red}[^]${reset}'
		}
		.colon {
			'${blue}[:]${reset}'
		}
		.backtick {
			'${blue}[`]${reset}'
		}
		else {
			'${red}[DELIM:${t.lit}]${reset}'
		}
	}
}
