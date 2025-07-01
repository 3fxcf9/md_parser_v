module features

import lexer { Token }
import parser { Parser }
import shared { HTMLRenderer, Node, Registry }

// TODO: Nesting

const possible_env = ['thm', 'cor', 'lemma', 'def', 'rem', 'eg', 'exercise', 'fold', 'quote']
const nested_minimum_indent = 4

struct EnvironmentNode {
	env_name string
	title    ?string
	content  []Node
}

pub struct EnvironmentFeature {}

pub fn (f EnvironmentFeature) node_name() string {
	return 'EnvironmentNode'
}

pub fn (n EnvironmentNode) to_str(indent int) string {
	mut out := '${' '.repeat(indent)}Environment(${n.env_name}'
	if t := n.title {
		out += ' - ${t}'
	}
	out += ')\n'
	for node in n.content {
		out += node.to_str(indent + 2)
	}
	return out
}

pub fn (f EnvironmentFeature) paragraph_stop_condition(tokens []Token, position int) ?bool {
	return scan_environment_block(tokens, position) != none
}

pub fn (f EnvironmentFeature) parse_block(tokens []Token, position int, reg &Registry) ?(Node, int) {
	if env_name, title, normalized_tokens, consumed := scan_environment_block(tokens,
		position)
	{
		inner_nodes := Parser.new(reg).parse(normalized_tokens)

		return EnvironmentNode{
			env_name: env_name
			title:    title
			content:  inner_nodes
		}, consumed
	} else {
		return none
	}
}

fn scan_environment_block(tokens []Token, position int) ?(string, ?string, []Token, int) {
	if position + 2 >= tokens.len {
		return none
	}

	if tokens[position].kind != .percent || tokens[position + 1].kind != .text
		|| tokens[position + 1].lit !in possible_env {
		return none
	}

	env_name := tokens[position + 1].lit

	mut start := position + 2 // after env_name

	// Skip space if any (if title supplied)
	if tokens[start].kind == .space {
		start++
	}

	// Extract optional title: everything until newline
	mut title_tokens := []Token{}
	for start < tokens.len && tokens[start].kind != .newline {
		title_tokens << tokens[start]
		start++
	}
	title := if title_tokens.len > 0 {
		title_tokens.map(it.lit).join('')
	} else {
		none
	}

	mut end := start

	for end < tokens.len {
		// Skip fenced code blocks (``` ... ```)
		if is_fence_start(tokens, end) {
			end = skip_fence_block(tokens, end) or { break }
			continue
		}

		// Detect closing %
		if tokens[end].kind == .newline && end + 1 < tokens.len && tokens[end + 1].kind == .percent
			&& (end + 2 == tokens.len || tokens[end + 2].kind == .newline) {
			break
		}

		end++
	}

	// end = newline before %

	// If we broke before closing %, consume nothing
	if end + 1 >= tokens.len {
		return none
	}

	// end = newline before closing %

	if start == end {
		return env_name, title, []Token{}, end - position + 3
	} else {
		// Extract inner block content
		inner_tokens := tokens[start + 1..end]

		mut normalized_tokens := []Token{}
		mut i := 0

		for i < inner_tokens.len {
			// Collect tokens of a full line (until newline or end)
			mut line := []Token{}
			for i < inner_tokens.len && inner_tokens[i].kind != .newline {
				line << inner_tokens[i]
				i++
			}
			if i < inner_tokens.len && inner_tokens[i].kind == .newline {
				line << inner_tokens[i]
				i++
			}

			// Skip blank lines
			if line.len == 1 && line[0].kind == .newline {
				normalized_tokens << line[0]
				continue
			}

			// Check first token is indent
			if line.len == 0 || line[0].kind != .indent {
				return none // invalid line: expected indent
			}

			orig_indent := line[0].level
			if orig_indent < nested_minimum_indent {
				return none // not indented enough
			}

			new_indent := orig_indent - nested_minimum_indent
			if new_indent > 0 {
				normalized_tokens << Token{
					kind:  .indent
					level: new_indent
				}
			}
			// Copy rest of the line (excluding original indent)
			normalized_tokens << line[1..]
		}

		return env_name, title, normalized_tokens, end - position + 3
	}
}

pub fn (f EnvironmentFeature) parse_inline(tokens []Token, position int, reg &Registry) ?(Node, int) {
	return none
}

pub fn (f EnvironmentFeature) render(node Node, renderer HTMLRenderer) string {
	env := node as EnvironmentNode
	mut html := ''

	if env.env_name == 'fold' {
		html += '<details>'
		if t := env.title {
			html += '<summary>${t}</summary>'
		}
	} else {
		html += '<div class="environment environment-${env.env_name}">'
		if t := env.title {
			if env.env_name in ['thm', 'cor', 'lemma', 'def'] {
				html += '<div class="environment-title">${t}</div>'
			}
		}
	}

	for n in env.content {
		html += renderer.render_node(n)
	}

	if env.env_name == 'fold' {
		html += '</details>'
	} else {
		html += '</div>'
	}
	return html
}

// Utils
fn is_environment_start(tokens []Token, position int) bool {
	return position + 1 < tokens.len && tokens[position].kind == .percent
		&& tokens[position + 1].kind == .text && tokens[position + 1].lit in possible_env
}

fn is_fence_start(tokens []Token, pos int) bool {
	return pos + 2 < tokens.len && tokens[pos].kind == .backtick
		&& tokens[pos + 1].kind == .backtick && tokens[pos + 2].kind == .backtick
}

fn skip_fence_block(tokens []Token, start int) ?int {
	mut pos := start + 3 // skip ```
	for pos + 2 < tokens.len {
		if tokens[pos].kind == .backtick && tokens[pos + 1].kind == .backtick
			&& tokens[pos + 2].kind == .backtick {
			return pos + 3 // position after closing ```
		}
		pos++
	}
	return none // unterminated block
}
