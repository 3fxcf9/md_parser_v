module parser

import shared { Node, Paragraph, Registry, TextNode }
import lexer { Token }

pub struct Parser {
	reg &Registry
}

pub fn Parser.new(reg &Registry) Parser {
	return Parser{reg}
}

pub fn (p Parser) parse(tokens []Token) []Node {
	mut children := []Node{}
	mut i := 0

	for i < tokens.len {
		mut matched := false
		for block_fn in p.reg.block_parsers {
			node, consumed := block_fn(tokens, i, p.reg) or { continue }
			children << node
			i += consumed
			matched = true
			break
		}

		if !matched {
			// fallback: create a paragraph
			start := i
			advance: for i < tokens.len {
				for condition in p.reg.paragraph_stop_conditions {
					if condition(tokens, i) or { false } {
						break advance
					}
				}
				i++
			}

			if start != i {
				line_tokens := tokens[start..i]

				if !line_tokens.map(it.lit).join('').is_blank() {
					inline_nodes := p.parse_inlines(line_tokens)
					children << Paragraph{
						content: inline_nodes
					}
				}
			}

			if i < tokens.len && tokens[i].kind == .newline {
				i++ // skip newline
			}
		}

		// Skip enmpty lines
		for i < tokens.len && tokens[i].kind == .newline {
			i++
		}
	}

	return children
}

pub fn (p Parser) parse_inlines(tokens []Token) []Node {
	mut result := []Node{}
	mut i := 0

	for i < tokens.len {
		mut matched := false
		for inline_fn in p.reg.inline_parsers {
			node, consumed := inline_fn(tokens, i, p.reg) or { continue }
			result << node
			i += consumed
			matched = true
			break
		}

		// fallback: accumulate as text
		if !matched {
			// Avoid adding newlines into the ast
			if tokens[i].kind == .newline {
				result << TextNode{
					text: ' '
				}
			} else {
				result << TextNode{
					text: tokens[i].lit
				}
			}
			i++
		}
	}

	return result
}
