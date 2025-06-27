// TODO: Simplify similar features

struct HighlightNode {
	content []InlineNode
}

struct HighlightFeature {}

pub fn (f HighlightFeature) node_name() string {
	return 'HighlightNode'
}

pub fn (f HighlightFeature) paragraph_stop_condition(tokens []Token, position int) ?bool {
	return none
}

// No block handling
pub fn (f HighlightFeature) parse_block(tokens []Token, position int, reg &Registry) ?(Node, int) {
	return none
}

pub fn (f HighlightFeature) parse_inline(tokens []Token, position int, reg &Registry) ?(InlineNode, int) {
	if position + 2 >= tokens.len {
		return none
	}

	if tokens[position].kind != .equal || tokens[position + 1].kind != .equal {
		return none
	}

	// Look ahead for closing marks
	for i := position + 2; i < tokens.len - 1; i++ {
		if tokens[i].kind == .equal && tokens[i + 1].kind == .equal {
			inner_tokens := tokens[position + 2..i]
			parser := Parser.new(reg)
			content := parser.parse_inlines(inner_tokens)
			return HighlightNode{
				content: content
			}, i + 2 - position
		}
	}

	return none
}

pub fn (f HighlightFeature) render(node Node, renderer HTMLRenderer) string {
	bold_node := node as HighlightNode
	mut result := ''
	for child in bold_node.content {
		result += renderer.render_node(child as Node)
	}
	return '<mark>${result}</mark>'
}
