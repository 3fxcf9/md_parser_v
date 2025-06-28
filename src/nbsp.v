struct NbspNode {}

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
		return NbspNode{}, 1
	}

	return none
}

pub fn (f NbspFeature) render(node Node, renderer HTMLRenderer) string {
	return '&nbsp;'
}
