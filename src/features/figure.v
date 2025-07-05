module features

import shared { HTMLRenderer, Node, Node, Registry }
import lexer { Token }
import os { abs_path, execute_opt }

// Syntax: @[drawing.svg]

struct FigureNode {
	content string
}

pub fn (b FigureNode) to_str(indent int) string {
	return '${' '.repeat(indent)}Figure\n'
}

pub struct FigureFeature {}

pub fn (f FigureFeature) node_name() string {
	return 'FigureNode'
}

pub fn (f FigureFeature) paragraph_stop_condition(tokens []Token, position int) ?bool {
	return none
}

pub fn (f FigureFeature) parse_block(tokens []Token, position int, reg &Registry) ?(Node, int) {
	return none
}

pub fn (f FigureFeature) parse_inline(tokens []Token, position int, reg &Registry) ?(Node, int) {
	if position + 1 >= tokens.len || tokens[position].kind != .at
		|| tokens[position + 1].kind != .lbracket {
		return none
	}

	// Find the closing ] for label
	mut filename_end := -1
	for i := position + 2; i < tokens.len; i++ {
		if tokens[i].kind == .rbracket {
			filename_end = i
			break
		}
	}
	if filename_end == -1 {
		return none
	}

	// Extract label tokens and parse inline content
	filename_tokens := tokens[position + 2..filename_end]

	mut filename := ''
	for t in filename_tokens {
		filename += t.lit
	}

	filename = abs_path(filename)

	if !os.exists(filename) {
		return none
	}

	if optimized_svg := execute_opt('scour --quiet --strip-xml-prolog --enable-comment-stripping -i ${filename}') {
		return FigureNode{
			content: optimized_svg.output
		}, filename_end + 1 - position
	}
	return none
}

pub fn (f FigureFeature) render(node Node, renderer HTMLRenderer) string {
	figure_node := node as FigureNode
	return figure_node.content
}
