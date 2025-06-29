module features

import shared { HTMLRenderer, Node, Registry }
import lexer { Token }

struct CodeInlineNode {
	content string
}

pub fn (m CodeInlineNode) to_str(indent int) string {
	return '${' '.repeat(indent)}InlineCode(${m.content})\n'
}

pub struct CodeInlineFeature {}

pub fn (f CodeInlineFeature) node_name() string {
	return 'CodeInlineNode'
}

pub fn (f CodeInlineFeature) paragraph_stop_condition(tokens []Token, position int) ?bool {
	return none
}

// No block handling
pub fn (f CodeInlineFeature) parse_block(tokens []Token, position int, reg &Registry) ?(Node, int) {
	return none
}

pub fn (f CodeInlineFeature) parse_inline(tokens []Token, position int, reg &Registry) ?(Node, int) {
	if position + 2 >= tokens.len {
		return none
	}

	if tokens[position].kind != .backtick || tokens[position + 1].kind != .backtick
		|| tokens[position + 2].kind != .backtick {
		return none
	}

	// Look ahead for closing marks
	for i := position + 3; i < tokens.len; i++ {
		if i + 2 < tokens.len && tokens[i].kind == .backtick && tokens[i].kind == .backtick
			&& tokens[i + 1].kind == .backtick && tokens[i + 2].kind == .backtick {
			inner_tokens := tokens[position + 3..i]
			mut text := ''
			for t in inner_tokens {
				text += t.lit
			}
			return CodeInlineNode{
				content: text
			}, i + 3 - position
		}
	}

	return none
}

pub fn (f CodeInlineFeature) render(node Node, renderer HTMLRenderer) string {
	return '<code>${(node as CodeInlineNode).content}</code>'
}
