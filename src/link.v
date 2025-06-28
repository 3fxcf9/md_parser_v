struct LinkNode {
	href    string
	content []InlineNode
}

pub fn (b LinkNode) to_str(indent int) string {
	mut out := '${' '.repeat(indent)}Link\n'
	for inl in b.content {
		out += inl.to_str(indent + 2)
	}
	return out
}

struct LinkFeature {}

pub fn (f LinkFeature) node_name() string {
	return 'LinkNode'
}

pub fn (f LinkFeature) paragraph_stop_condition(tokens []Token, position int) ?bool {
	return none
}

pub fn (f LinkFeature) parse_block(tokens []Token, position int, reg &Registry) ?(Node, int) {
	return none
}

pub fn (f LinkFeature) parse_inline(tokens []Token, position int, reg &Registry) ?(InlineNode, int) {
	if position >= tokens.len || tokens[position].kind != .lbracket {
		return none
	}

	// Find the closing ] for label
	mut label_end := -1
	for i := position + 1; i < tokens.len; i++ {
		if tokens[i].kind == .rbracket {
			label_end = i
			break
		}
	}
	if label_end == -1 || label_end + 1 >= tokens.len {
		return none
	}

	// Next token must be (
	if tokens[label_end + 1].kind != .lparen {
		return none
	}

	// Find closing )
	mut url_end := -1
	for i := label_end + 2; i < tokens.len; i++ {
		if tokens[i].kind == .rparen {
			url_end = i
			break
		}
	}
	if url_end == -1 {
		return none
	}

	// Extract label tokens and parse inline content
	label_tokens := tokens[position + 1..label_end]
	parser := Parser.new(reg)
	label_nodes := parser.parse_inlines(label_tokens)

	// Extract URL
	mut url := ''
	for t in tokens[label_end + 2..url_end] {
		if t.kind == .text {
			url += t.lit
		}
	}

	return LinkNode{
		href:    url
		content: label_nodes
	}, url_end + 1 - position
}

pub fn (f LinkFeature) render(node Node, renderer HTMLRenderer) string {
	link_node := node as LinkNode
	mut result := ''
	for child in link_node.content {
		result += renderer.render_node(child as Node)
	}
	return '<a href="${link_node.href}">${result}</a>'
}
