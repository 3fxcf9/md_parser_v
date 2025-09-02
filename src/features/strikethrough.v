module features

import shared { HTMLRenderer, Node, Registry }
import parser { Parser }
import lexer { Token }

// TODO: Simplify similar features

struct StrikethroughNode {
	content []Node
}

pub fn (n StrikethroughNode) to_str(indent int) string {
	mut out := '${' '.repeat(indent)}Strikethrough\n'
	for inl in n.content {
		out += inl.to_str(indent + 2)
	}
	return out
}

pub struct StrikethroughFeature {}

pub fn (f StrikethroughFeature) node_name() string {
	return 'StrikethroughNode'
}

pub fn (f StrikethroughFeature) paragraph_stop_condition(tokens []Token, position int) ?bool {
	return none
}

// No block handling
pub fn (f StrikethroughFeature) parse_block(tokens []Token, position int, reg &Registry) ?(Node, int) {
	return none
}

pub fn (f StrikethroughFeature) parse_inline(tokens []Token, position int, reg &Registry) ?(Node, int) {
	if position + 2 >= tokens.len {
		return none
	}

	if tokens[position].kind != .tilde || tokens[position + 1].kind != .tilde {
		return none
	}

	// Look ahead for closing marks
	for i := position + 2; i < tokens.len - 1; i++ {
		if tokens[i].kind == .tilde && tokens[i + 1].kind == .tilde {
			inner_tokens := tokens[position + 2..i]
			p := Parser.new(reg)
			content := p.parse_inlines(inner_tokens)
			return StrikethroughNode{
				content: content
			}, i + 2 - position
		}
	}

	return none
}

pub fn (f StrikethroughFeature) render(node Node, renderer HTMLRenderer) string {
	strikethrough_node := node as StrikethroughNode
	mut result := ''
	for child in strikethrough_node.content {
		result += renderer.render_node(child as Node)
	}
	return '<s>${result}</s>'
}
