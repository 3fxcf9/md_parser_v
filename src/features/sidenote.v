module features

import shared { HTMLRenderer, Node, Registry }
import parser { Parser }
import lexer { Token }

struct SidenoteNode {
	content []Node
}

pub fn (b SidenoteNode) to_str(indent int) string {
	mut out := '${' '.repeat(indent)}Bold\n'
	for inl in b.content {
		out += inl.to_str(indent + 2)
	}
	return out
}

pub struct SidenoteFeature {}

pub fn (f SidenoteFeature) node_name() string {
	return 'SidenoteNode'
}

pub fn (f SidenoteFeature) paragraph_stop_condition(tokens []Token, position int) ?bool {
	return none
}

// No block handling
pub fn (f SidenoteFeature) parse_block(tokens []Token, position int, reg &Registry) ?(Node, int) {
	return none
}

pub fn (f SidenoteFeature) parse_inline(tokens []Token, position int, reg &Registry) ?(Node, int) {
	if position + 1 >= tokens.len {
		return none
	}

	if !(tokens[position].kind == .lparen && tokens[position + 1].kind == .lparen) {
		return none
	}

	// Look ahead for closing marks
	for i := position + 2; i < tokens.len - 1; i++ {
		if tokens[i].kind == .rparen && tokens[i + 1].kind == .rparen {
			inner_tokens := tokens[position + 2..i]
			p := Parser.new(reg)
			content := p.parse_inlines(inner_tokens)
			return SidenoteNode{
				content: content
			}, i + 2 - position
		}
	}

	return none
}

pub fn (f SidenoteFeature) render(node Node, renderer HTMLRenderer) string {
	sidenode_node := node as SidenoteNode
	mut result := ''
	for child in sidenode_node.content {
		result += renderer.render_node(child as Node)
	}
	return '<span class="sidenote-number"><small class="sidenote">${result}</small></span>'
}
