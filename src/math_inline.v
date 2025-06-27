struct MathInlineNode {
	content string
}

struct MathInlineFeature {}

pub fn (f MathInlineFeature) node_name() string {
	return 'MathInlineNode'
}

pub fn (f MathInlineFeature) paragraph_stop_condition(tokens []Token, position int) ?bool {
	return none
}

// No block handling
pub fn (f MathInlineFeature) parse_block(tokens []Token, position int, reg &Registry) ?(Node, int) {
	return none
}

pub fn (f MathInlineFeature) parse_inline(tokens []Token, position int, reg &Registry) ?(InlineNode, int) {
	if position + 1 >= tokens.len {
		return none
	}

	if !(tokens[position].kind == .dollar) {
		return none
	}

	// Look ahead for closing marks
	for i := position + 1; i < tokens.len; i++ {
		if tokens[i].kind == .dollar {
			inner_tokens := tokens[position + 1..i]
			mut text := ''
			for t in inner_tokens {
				text += t.lit
			}
			return MathInlineNode{
				content: text
			}, i + 1 - position
		}
	}

	return none
}

pub fn (f MathInlineFeature) render(node Node, renderer HTMLRenderer) string {
	return '<inline-math>${(node as MathInlineNode).content}</inline-math>'
}
