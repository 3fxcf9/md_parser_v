struct HeadingNode {
	level   u8
	content []InlineNode
}

struct HeadingFeature {}

pub fn (f HeadingFeature) node_name() string {
	return 'HeadingNode'
}

pub fn (f HeadingFeature) paragraph_stop_condition(tokens []Token, position int) ?bool {
	return none
}

pub fn (f HeadingFeature) parse_block(tokens []Token, position int, reg &Registry) ?(Node, int) {
	mut level := u8(0)
	for position + level < tokens.len && tokens[position + level].kind == .hash {
		level++
	}

	if level == 0 || level > 6 {
		return none
	}

	if tokens[position + level].kind != .space {
		return none
	}

	content_start := position + level + 1
	for i := content_start; i < tokens.len - 1; i++ {
		if tokens[i].kind == .newline {
			inner_tokens := tokens[content_start..i]
			parser := Parser.new(reg)
			content := parser.parse_inlines(inner_tokens)
			return HeadingNode{
				level:   level
				content: content
			}, i - position
		}
	}

	return none
}

// No inline handling
pub fn (f HeadingFeature) parse_inline(tokens []Token, position int, reg &Registry) ?(InlineNode, int) {
	return none
}

pub fn (f HeadingFeature) render(node Node, renderer HTMLRenderer) string {
	heading_node := node as HeadingNode
	mut result := ''
	for child in heading_node.content {
		result += renderer.render_node(child as Node)
	}
	return '<h${heading_node.level}>${result}</h${heading_node.level}>'
}
