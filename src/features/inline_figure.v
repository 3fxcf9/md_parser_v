module features

import parser { Parser }
import shared { HTMLRenderer, Node, Registry }
import lexer { Token }

struct FigureNode {
	float   string
	caption ?[]Node
	content []Node
}

pub fn (n FigureNode) to_str(indent int) string {
	mut out := '${' '.repeat(indent)}Figure(${n.float})\n'
	for inl in n.content {
		out += inl.to_str(indent + 2)
	}
	return out
}

pub struct FigureFeature {}

pub fn (f FigureFeature) node_name() string {
	return 'FigureNode'
}

pub fn (f FigureFeature) paragraph_stop_condition(tokens []Token, position int) ?bool {
	return none
}

// No block handling
pub fn (f FigureFeature) parse_block(tokens []Token, position int, reg &Registry) ?(Node, int) {
	return none
}

pub fn (f FigureFeature) parse_inline(tokens []Token, position int, reg &Registry) ?(Node, int) {
	if position + 1 >= tokens.len {
		return none
	}

	if tokens[position].kind != .slash || tokens[position + 1].kind != .slash {
		return none
	}

	// Contents
	mut float := 'left'
	mut fig_content := []Node{}

	mut j := position + 2
	for j + 1 < tokens.len {
		if j + 1 < tokens.len && tokens[j].kind == .space
			&& tokens[j + 1].kind in [.langle, .rangle] {
			if tokens[j + 1].kind == .rangle {
				float = 'right'
			}
			fig_content_tokens := tokens[position + 2..j]
			p := Parser.new(reg)
			fig_content = p.parse_inlines(fig_content_tokens)
			break
		}
		j++
	}

	if j + 1 >= tokens.len {
		return none
	}

	// Caption (start at < or >)
	mut caption := ?[]Node(none)

	after_float_marker := j + 2

	mut i := after_float_marker
	for i + 1 < tokens.len {
		if i + 1 < tokens.len && tokens[i].kind == .slash && tokens[i + 1].kind == .slash {
			// If no caption
			if i <= after_float_marker + 1 {
				break
			}

			// Parse the caption as inline nodes
			caption_tokens := tokens[after_float_marker + 1..i]
			p := Parser.new(reg)
			caption = p.parse_inlines(caption_tokens)
			break
		}
		i++
	}

	return FigureNode{
		content: fig_content
		caption: caption
		float:   float
	}, i + 2 - position
}

pub fn (f FigureFeature) render(node Node, renderer HTMLRenderer) string {
	figure_node := node as FigureNode
	mut html := '<figure class="float-${figure_node.float}">'

	for child in figure_node.content {
		html += renderer.render_node(child as Node)
	}

	// Caption
	if caption := figure_node.caption {
		mut caption_html := ''
		for child in caption {
			caption_html += renderer.render_node(child as Node)
		}
		html += '<figcaption>${caption_html}</figcaption>'
	}

	html += '</figure>'
	return html
}
