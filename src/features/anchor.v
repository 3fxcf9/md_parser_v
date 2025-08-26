module features

import shared { HTMLRenderer, Node, Registry }
import lexer { Token }

struct AnchorNode {
	id string
}

pub fn (m AnchorNode) to_str(indent int) string {
	return '${' '.repeat(indent)}Anchor(${m.id})\n'
}

pub struct AnchorFeature {}

pub fn (f AnchorFeature) node_name() string {
	return 'AnchorNode'
}

pub fn (f AnchorFeature) paragraph_stop_condition(tokens []Token, position int) ?bool {
	return scan_anchor(tokens, position) != none
}

pub fn (f AnchorFeature) parse_block(tokens []Token, position int, reg &Registry) ?(Node, int) {
	if content, consumed := scan_anchor(tokens, position) {
		return AnchorNode{
			id: content.trim_space()
		}, consumed
	} else {
		return none
	}
}

pub fn (f AnchorFeature) parse_inline(tokens []Token, position int, reg &Registry) ?(Node, int) {
	return none
}

fn scan_anchor(tokens []Token, position int) ?(string, int) {
	// Check for opening ::
	if position + 1 >= tokens.len {
		return none
	}
	if tokens[position].kind != .colon || tokens[position + 1].kind != .colon {
		return none
	}

	// Look ahead for closing marks
	for i := position + 2; i + 1 < tokens.len; i++ {
		if tokens[i].kind == .colon && tokens[i + 1].kind == .colon {
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

pub fn (f AnchorFeature) render(node Node, renderer HTMLRenderer) string {
	return '<span class="anchor" id="${(node as AnchorNode).id}"></span>'
}
