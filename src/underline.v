// TODO: Simplify similar features

struct UnderlineNode {
	content []InlineNode
}

struct UnderlineFeature {}

pub fn (f UnderlineFeature) node_name() string {
	return 'UnderlineNode'
}

pub fn (f UnderlineFeature) paragraph_stop_condition(tokens []Token, position int) ?bool {
	return none
}

// No block handling
pub fn (f UnderlineFeature) parse_block(tokens []Token, position int, reg &Registry) ?(Node, int) {
	return none
}

pub fn (f UnderlineFeature) parse_inline(tokens []Token, position int, reg &Registry) ?(InlineNode, int) {
	if position + 2 >= tokens.len {
		return none
	}

	if tokens[position].kind != .plus || tokens[position + 1].kind != .plus {
		return none
	}

	// Look ahead for closing marks
	for i := position + 2; i < tokens.len - 1; i++ {
		if tokens[i].kind == .plus && tokens[i + 1].kind == .plus {
			inner_tokens := tokens[position + 2..i]
			parser := Parser.new(reg)
			content := parser.parse_inlines(inner_tokens)
			return UnderlineNode{
				content: content
			}, i + 2 - position
		}
	}

	return none
}

pub fn (f UnderlineFeature) render(node Node, renderer HTMLRenderer) string {
	bold_node := node as UnderlineNode
	mut result := ''
	for child in bold_node.content {
		result += renderer.render_node(child as Node)
	}
	return '<u>${result}</u>'
}
