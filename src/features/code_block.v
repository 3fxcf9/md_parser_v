module features

import shared { HTMLRenderer, Node, Registry }
import lexer { Token }

struct CodeBlockNode {
	content string
	lang    ?string
}

pub fn (m CodeBlockNode) to_str(indent int) string {
	return '${' '.repeat(indent)}CodeBlock(${m.content})\n'
}

pub struct CodeBlockFeature {}

pub fn (f CodeBlockFeature) node_name() string {
	return 'CodeBlockNode'
}

pub fn (f CodeBlockFeature) paragraph_stop_condition(tokens []Token, position int) ?bool {
	return position + 2 < tokens.len && tokens[position].kind == .backtick
		&& tokens[position + 1].kind == .backtick && tokens[position + 1].kind == .backtick
}

pub fn (f CodeBlockFeature) parse_block(tokens []Token, position int, reg &Registry) ?(Node, int) {
	// Check for opening ```
	if position + 2 >= tokens.len {
		return none
	}
	if tokens[position].kind != .backtick || tokens[position + 1].kind != .backtick
		|| tokens[position + 2].kind != .backtick {
		return none
	}

	mut start := position
	mut lang := if position + 3 < tokens.len && tokens[position + 3].kind == .text {
		start++
		tokens[position + 3].lit
	} else {
		none
	}

	// Look ahead for closing marks
	for i := start + 3; i < tokens.len; i++ {
		if tokens[i].kind == .backtick && tokens[i + 1].kind == .backtick
			&& tokens[i + 2].kind == .backtick {
			inner_tokens := tokens[start + 3..i]
			mut text := ''
			for t in inner_tokens {
				text += t.lit
			}
			return CodeBlockNode{
				content: text.trim_space().trim_indent()
				lang:    lang
			}, i + 3 - position
		}
	}

	return none
}

// No inline handling
pub fn (f CodeBlockFeature) parse_inline(tokens []Token, position int, reg &Registry) ?(Node, int) {
	return none
}

pub fn (f CodeBlockFeature) render(node Node, renderer HTMLRenderer) string {
	code_block_node := node as CodeBlockNode
	lang_class := if lang := code_block_node.lang { ' class="language-${lang}"' } else { '' }
	return '<pre><code${lang_class}>${code_block_node.content}</code></pre>'
}
