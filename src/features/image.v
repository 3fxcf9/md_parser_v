module features

import shared { HTMLRenderer, Node, Node, Registry }
import lexer { Token }
import os { abs_path, execute_opt }

// Syntax: @[file.ext]
// Include svg graphics directly into the rendered html if able to locate them

struct ImageNode {
	path    ?string
	content string
}

pub fn (b ImageNode) to_str(indent int) string {
	return '${' '.repeat(indent)}Image(${b.path or { 'svg' }})\n'
}

pub struct ImageFeature {}

pub fn (f ImageFeature) node_name() string {
	return 'ImageNode'
}

pub fn (f ImageFeature) paragraph_stop_condition(tokens []Token, position int) ?bool {
	return none
}

pub fn (f ImageFeature) parse_block(tokens []Token, position int, reg &Registry) ?(Node, int) {
	return none
}

pub fn (f ImageFeature) parse_inline(tokens []Token, position int, reg &Registry) ?(Node, int) {
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

	if os.file_ext(filename) == '.svg' && os.exists(filename) {
		if optimized_svg := execute_opt('scour --quiet --strip-xml-prolog --enable-comment-stripping -i ${abs_path(filename)}') {
			// if svg := os.read_file(filename) {
			return ImageNode{
				path:    none
				content: optimized_svg.output
				// content: svg
			}, filename_end + 1 - position
		}
	} else {
		return ImageNode{
			path:    filename
			content: ''
		}, filename_end + 1 - position
	}
	return none
}

pub fn (f ImageFeature) render(node Node, renderer HTMLRenderer) string {
	image_node := node as ImageNode
	if path := image_node.path {
		return '<img src="${path}"/>'
	}
	return image_node.content
}
