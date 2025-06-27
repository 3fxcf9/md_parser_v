struct Parser {
	block_parsers  []BlockParser
	inline_parsers []InlineParser
	reg            &Registry
}

type BlockParser = fn ([]Token, int, &Registry) ?(Node, int)

type InlineParser = fn ([]Token, int, &Registry) ?(InlineNode, int)

pub fn Parser.new(reg &Registry) Parser {
	return Parser{reg.block_parsers, reg.inline_parsers, reg}
}

pub fn (p Parser) parse(tokens []Token) Node {
	mut children := []Node{}
	mut i := 0

	for i < tokens.len {
		mut matched := false
		for block_fn in p.block_parsers {
			node, consumed := block_fn(tokens, i, p.reg) or { continue }
			children << node
			i += consumed
			matched = true
			break
		}

		if !matched {
			// fallback: gather text until newline
			start := i
			for i < tokens.len && tokens[i].kind != .newline {
				i++
			}
			line_tokens := tokens[start..i]
			inline_nodes := p.parse_inlines(line_tokens)
			children << Paragraph{
				content: inline_nodes
			} // TODO: Better paragraph end condition
			if i < tokens.len && tokens[i].kind == .newline {
				i++ // skip newline
			}
		}
	}

	return Document{
		children: children
	}
}

pub fn (p Parser) parse_inlines(tokens []Token) []InlineNode {
	mut result := []InlineNode{}
	mut i := 0

	for i < tokens.len {
		mut matched := false
		for inline_fn in p.inline_parsers {
			node, consumed := inline_fn(tokens, i, p.reg) or { continue }
			result << node
			i += consumed
			matched = true
			break
		}
		if !matched {
			// fallback: accumulate as text
			result << TextNode{
				text: tokens[i].lit
			}
			i++
		}
	}

	return result

	// mut text := ''
	// for t in tokens {
	// 	text += t.lit
	// }
	// return [TextNode{text}]
}
