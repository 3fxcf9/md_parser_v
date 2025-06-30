module features

import shared { HTMLRenderer, Node, Registry }
import parser { Parser }
import lexer { Token }

struct FootnoteNode {
	content []Node
}

pub fn (b FootnoteNode) to_str(indent int) string {
	mut out := '${' '.repeat(indent)}Bold\n'
	for inl in b.content {
		out += inl.to_str(indent + 2)
	}
	return out
}

pub struct FootnoteFeature {}

pub fn (f FootnoteFeature) node_name() string {
	return 'FootnoteNode'
}

pub fn (f FootnoteFeature) paragraph_stop_condition(tokens []Token, position int) ?bool {
	return none
}

// No block handling
pub fn (f FootnoteFeature) parse_block(tokens []Token, position int, reg &Registry) ?(Node, int) {
	return none
}

pub fn (f FootnoteFeature) parse_inline(tokens []Token, position int, reg &Registry) ?(Node, int) {
	if position + 1 >= tokens.len {
		return none
	}

	if !(tokens[position].kind == .lcurly && tokens[position + 1].kind == .lcurly) {
		return none
	}

	// Look ahead for closing marks
	for i := position + 2; i < tokens.len - 1; i++ {
		if tokens[i].kind == .rcurly && tokens[i + 1].kind == .rcurly {
			inner_tokens := tokens[position + 2..i]
			p := Parser.new(reg)
			content := p.parse_inlines(inner_tokens)
			return FootnoteNode{
				content: content
			}, i + 2 - position
		}
	}

	return none
}

// Handled as a sidenote for now
// TODO: Footnote rendering
pub fn (f FootnoteFeature) render(node Node, renderer HTMLRenderer) string {
	sidenode_node := node as FootnoteNode
	mut result := ''
	for child in sidenode_node.content {
		result += renderer.render_node(child as Node)
	}
	return '<span class="sidenote-number"><small class="sidenote">${result}</small></span>'
}
