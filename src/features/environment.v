module features

import lexer { Token }
import parser { Parser }
import shared { HTMLRenderer, Node, Registry }

// TODO: Nesting

const possible_env = ['thm', 'cor', 'lemma', 'def', 'rem', 'eg', 'exercise', 'fold', 'quote']

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
	return is_environment_start(tokens, position)
	// return none
}

pub fn (f EnvironmentFeature) parse_block(tokens []Token, position int, reg &Registry) ?(Node, int) {
	if !is_environment_start(tokens, position) {
		return none
	}

	env_name := tokens[position + 1].lit

	if position + 2 >= tokens.len {
		return none
	}
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

	// If we broke before closing %, consume nothing
	if end + 2 >= tokens.len {
		return none
	}

	// end = newline before closing %

	if start == end {
		return EnvironmentNode{
			env_name: env_name
			title:    title
			content:  []
		}, end - position + 3
	} else {
		// Extract inner block content
		inner_tokens := tokens[start + 1..end]
		inner_nodes := Parser.new(reg).parse(inner_tokens)

		dump(inner_tokens)

		return EnvironmentNode{
			env_name: env_name
			title:    title
			content:  inner_nodes
		}, end - position + 3
	}
}

pub fn (f EnvironmentFeature) parse_inline(tokens []Token, position int, reg &Registry) ?(Node, int) {
	return none
}

pub fn (f EnvironmentFeature) render(node Node, renderer HTMLRenderer) string {
	env := node as EnvironmentNode
	mut html := '<div class="environment environment-${env.env_name}">'
	if t := env.title {
		if env.env_name in ['thm', 'cor', 'lemma', 'def'] {
			html += '<div class="environment-title">${t}</div>'
		}
	}
	html += '<div class="environment-content">'
	for n in env.content {
		html += renderer.render_node(n)
	}
	html += '</div></div>'
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
