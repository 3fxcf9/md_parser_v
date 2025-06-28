struct NbspNode {
	narrow bool
}

struct NbspFeature {}

pub fn (f NbspFeature) node_name() string {
	return 'NbspNode'
}

pub fn (f NbspFeature) paragraph_stop_condition(tokens []Token, position int) ?bool {
	return none
}

// No block handling
pub fn (f NbspFeature) parse_block(tokens []Token, position int, reg &Registry) ?(Node, int) {
	return none
}

pub fn (f NbspFeature) parse_inline(tokens []Token, position int, reg &Registry) ?(InlineNode, int) {
	if tokens[position].kind == .tilde {
		return NbspNode{position + 1 < tokens.len && tokens[position + 1].kind == .colon}, 1
	}

	return none
}

pub fn (f NbspFeature) render(node Node, renderer HTMLRenderer) string {
	if (node as NbspNode).narrow {
		return '&#8239;'
	}
	return '&nbsp;'
}
