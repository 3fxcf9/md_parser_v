module features

import shared { HTMLRenderer, Node, Registry }
import parser { Parser }
import lexer { Token }

struct HeadingNode {
	level   u8
	content []Node
}

pub fn (b HeadingNode) to_str(indent int) string {
	mut out := '${' '.repeat(indent)}Heading\n'
	for inl in b.content {
		out += inl.to_str(indent + 2)
	}
	return out
}

pub struct HeadingFeature {}

pub fn (f HeadingFeature) node_name() string {
	return 'HeadingNode'
}

pub fn (f HeadingFeature) paragraph_stop_condition(tokens []Token, position int) ?bool {
	return scan_heading_block(tokens, position) != none
}

pub fn (f HeadingFeature) parse_block(tokens []Token, position int, reg &Registry) ?(Node, int) {
	if inner_tokens, level, consumed := scan_heading_block(tokens, position) {
		p := Parser.new(reg)
		content := p.parse_inlines(inner_tokens)
		return HeadingNode{
			level:   level
			content: content
		}, consumed
	} else {
		return none
	}
}

// No inline handling
pub fn (f HeadingFeature) parse_inline(tokens []Token, position int, reg &Registry) ?(Node, int) {
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

fn scan_heading_block(tokens []Token, position int) ?([]Token, u8, int) {
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
	for i := content_start; i < tokens.len; i++ {
		if tokens[i].kind == .newline {
			inner_tokens := tokens[content_start..i]
			return inner_tokens, level, i - position
		}
	}

	inner_tokens := tokens[content_start..]
	return inner_tokens, level, tokens.len - position
}
