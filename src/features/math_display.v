module features

import shared { HTMLRenderer, Node, Registry }
import lexer { Token }

struct MathDisplayNode {
	content string
}

pub fn (m MathDisplayNode) to_str(indent int) string {
	return '${' '.repeat(indent)}DisplayMath(${m.content})\n'
}

pub struct MathDisplayFeature {}

pub fn (f MathDisplayFeature) node_name() string {
	return 'MathDisplayNode'
}

pub fn (f MathDisplayFeature) paragraph_stop_condition(tokens []Token, position int) ?bool {
	return scan_math_block(tokens, position) != none
}

pub fn (f MathDisplayFeature) parse_block(tokens []Token, position int, reg &Registry) ?(Node, int) {
	if content, consumed := scan_math_block(tokens, position) {
		return MathDisplayNode{
			content: content.trim_space().trim_indent()
		}, consumed
	} else {
		return none
	}
}

// No inline handling
pub fn (f MathDisplayFeature) parse_inline(tokens []Token, position int, reg &Registry) ?(Node, int) {
	return none
}

pub fn (f MathDisplayFeature) render(node Node, renderer HTMLRenderer) string {
	return '<code class="math-display">${(node as MathDisplayNode).content}</code>'
}

fn scan_math_block(tokens []Token, position int) ?(string, int) {
	mut start := position

	// Check for opening $$
	if start + 1 >= tokens.len {
		return none
	}
	if tokens[start].kind != .dollar || tokens[start + 1].kind != .dollar {
		return none
	}

	// Look ahead for closing marks
	for i := position + 2; i < tokens.len; i++ {
		if tokens[i].kind == .dollar && tokens[i + 1].kind == .dollar {
			inner_tokens := tokens[position + 2..i]
			mut text := ''
			for t in inner_tokens {
				text += t.lit
			}
			return text, i + 2 - position
		}
	}

	return none
}
