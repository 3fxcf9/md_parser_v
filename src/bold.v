struct BoldNode {
	content []InlineNode
}

struct BoldFeature {}

pub fn (f BoldFeature) init(mut registry Registry) {
	registry.register_inline_parser(f.parse_inline)
	registry.register_renderer('BoldNode', f.render)
}

// No block handling
pub fn (f BoldFeature) parse_block(tokens []Token, position int, reg &Registry) ?(Node, int) {
	return none
}

pub fn (f BoldFeature) parse_inline(tokens []Token, position int, reg &Registry) ?(InlineNode, int) {
	if position + 2 >= tokens.len {
		return none
	}

	open := tokens[position]
	if !(open.kind == .star || open.kind == .underscore) {
		return none
	}

	// Check for two consecutive opening marks (e.g., ** or __)
	if tokens[position + 1].kind != open.kind {
		return none
	}

	// Look ahead for closing marks
	for i := position + 2; i < tokens.len - 1; i++ {
		if tokens[i].kind == open.kind && tokens[i + 1].kind == open.kind {
			inner_tokens := tokens[position + 2..i]
			parser := Parser.new(reg)
			content := parser.parse_inlines(inner_tokens)
			return BoldNode{
				content: content
			}, i + 2 - position
		}
	}

	return none
}

pub fn (f BoldFeature) render(node Node, renderer HTMLRenderer) string {
	bold_node := node as BoldNode
	mut result := ''
	for child in bold_node.content {
		result += renderer.render_node(child as Node)
	}
	return '<strong>${result}</strong>'
}
