struct MathDisplayNode {
	content string
}

struct MathDisplayFeature {}

pub fn (f MathDisplayFeature) node_name() string {
	return 'MathDisplayNode'
}

pub fn (f MathDisplayFeature) paragraph_stop_condition(tokens []Token, position int) ?bool {
	return position + 1 < tokens.len && tokens[position].kind == .dollar
		&& tokens[position + 1].kind == .dollar
}

pub fn (f MathDisplayFeature) parse_block(tokens []Token, position int, reg &Registry) ?(Node, int) {
	mut start := position

	// Skip any leading spaces
	for start < tokens.len && tokens[start].kind == .space {
		start++
	}

	// Check for opening $$
	if start + 1 >= tokens.len {
		return none
	}
	if tokens[start].kind != .dollar || tokens[start + 1].kind != .dollar {
		return none
	}

	// Look ahead for closing marks
	for i := position + 2; i < tokens.len; i++ {
		if tokens[i].kind == .dollar && tokens[i + 1].kind == .dollar {
			inner_tokens := tokens[position + 2..i]
			mut text := ''
			for t in inner_tokens {
				text += t.lit
			}
			return MathDisplayNode{
				content: text.trim_space().trim_indent()
			}, i + 2 - position
		}
	}

	return none
}

// No inline handling
pub fn (f MathDisplayFeature) parse_inline(tokens []Token, position int, reg &Registry) ?(InlineNode, int) {
	return none
}

pub fn (f MathDisplayFeature) render(node Node, renderer HTMLRenderer) string {
	return '<div class="math-display">${(node as MathDisplayNode).content}</div>'
}
