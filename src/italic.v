struct ItalicNode {
	content []InlineNode
}

pub fn (n ItalicNode) to_str(indent int) string {
	mut out := '${' '.repeat(indent)}Italic\n'
	for inl in n.content {
		out += inl.to_str(indent + 2)
	}
	return out
}

struct ItalicFeature {}

pub fn (f ItalicFeature) node_name() string {
	return 'ItalicNode'
}

pub fn (f ItalicFeature) paragraph_stop_condition(tokens []Token, position int) ?bool {
	return none
}

// No block handling
pub fn (f ItalicFeature) parse_block(tokens []Token, position int, reg &Registry) ?(Node, int) {
	return none
}

pub fn (f ItalicFeature) parse_inline(tokens []Token, position int, reg &Registry) ?(InlineNode, int) {
	if position + 1 >= tokens.len {
		return none
	}

	open := tokens[position]
	if !(open.kind == .star || open.kind == .underscore) {
		return none
	}

	// Look ahead for closing marks
	for i := position + 1; i < tokens.len; i++ {
		if tokens[i].kind == open.kind {
			inner_tokens := tokens[position + 1..i]
			parser := Parser.new(reg)
			content := parser.parse_inlines(inner_tokens)
			return ItalicNode{
				content: content
			}, i + 1 - position
		}
	}

	return none
}

pub fn (f ItalicFeature) render(node Node, renderer HTMLRenderer) string {
	italic_node := node as ItalicNode
	mut result := ''
	for child in italic_node.content {
		result += renderer.render_node(child as Node)
	}
	return '<em>${result}</em>'
}
