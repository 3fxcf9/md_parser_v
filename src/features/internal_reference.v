
module features

import shared { HTMLRenderer, Node, Node, Registry }
import lexer { Token }

struct InternalReferenceNode {
	id string
}

pub fn (b InternalReferenceNode) to_str(indent int) string {
	return '${' '.repeat(indent)}InternalReference(${b.id})\n'
}

pub struct InternalReferenceFeature {}

pub fn (f InternalReferenceFeature) node_name() string {
	return 'InternalReferenceNode'
}

pub fn (f InternalReferenceFeature) paragraph_stop_condition(tokens []Token, position int) ?bool {
	return none
}

pub fn (f InternalReferenceFeature) parse_block(tokens []Token, position int, reg &Registry) ?(Node, int) {
	return none
}

pub fn (f InternalReferenceFeature) parse_inline(tokens []Token, position int, reg &Registry) ?(Node, int) {
	if position >= tokens.len || tokens[position].kind != .lbracket {
		return none
	}

	// Find the closing ] for label
	mut id_end := -1
	for i := position + 1; i < tokens.len; i++ {
		if tokens[i].kind == .rbracket {
			id_end = i
			break
		}
	}
	if id_end == -1 || id_end + 1 >= tokens.len {
		return none
	}

	mut id := ''
	for t in tokens[position + 1..id_end] {
		id += t.lit
	}

	return InternalReferenceNode{
		id: id
	}, id_end + 1 - position
}

pub fn (f InternalReferenceFeature) render(node Node, renderer HTMLRenderer) string {
	link_node := node as InternalReferenceNode
	return '<a href="#${link_node.id}">${link_node.id}</a>' // TODO: Generate reference label (see TODO.md)
}
