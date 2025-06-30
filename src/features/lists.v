module features

import shared { HTMLRenderer, Node, Registry }
import parser { Parser }
import lexer { Token }

struct ListNode {
	type  ListType
	start u8
mut:
	items []ListItemNode
}

enum ListType {
	ordered
	dash
	star
	plus
}

pub fn (l ListNode) to_str(indent int) string {
	mut out := '${' '.repeat(indent)}List(type=${l.type})\n'
	for item in l.items {
		out += item.to_str(indent + 2)
	}
	return out
}

struct ListItemNode {
	content []Node
}

pub fn (li ListItemNode) to_str(indent int) string {
	mut out := '${' '.repeat(indent)}ListItem\n'
	for child in li.content {
		out += child.to_str(indent + 2)
	}
	return out
}

pub struct ListFeature {}

pub fn (f ListFeature) node_name() string {
	return 'ListNode'
}

pub fn (f ListFeature) paragraph_stop_condition(tokens []Token, position int) ?bool {
	return is_list_item(tokens, position)
}

pub fn (f ListFeature) parse_block(tokens []Token, position int, reg &Registry) ?(Node, int) {
	if !is_list_item(tokens, position) {
		return none
	}

	open := tokens[position]
	ordered := open.kind == .text
	offset := if ordered { 1 } else { 0 }

	mut list := ListNode{
		items: []
		start: if ordered { open.lit.u8() } else { 0 }
		type:  match open.kind {
			.text { .ordered }
			.dash { .dash }
			.star { .star }
			.plus { .plus }
			else { .dash }
		}
	}

	mut i := position
	for i < tokens.len && is_compatible_list_item(tokens, i, open) { // for each list item
		first_line_content, first_increment := gather_line(tokens, i)
		i += first_increment

		mut item_content := first_line_content[2 + offset..].clone().clone()

		// Minimum indentation to be considered as the content
		min_indent := open.lit.len + 1 + offset

		for i < tokens.len && ((tokens[i].kind == .indent && tokens[i].level >= min_indent)
			|| (i + 1 < tokens.len && tokens[i].kind == .newline && tokens[i + 1].kind != .newline)) { // for each line inside the current list item
			// A list item is ended by a under-indented line or by two consecutive newlines

			mut line_content, increment := gather_line(tokens, i)
			if tokens[i].kind == .indent {
				new_indent_level := line_content[0].level - 2
				if new_indent_level <= 0 {
					line_content.delete(0)
				} else {
					line_content[0] = Token{
						kind:  .indent
						level: new_indent_level
					}
				}
			}

			item_content << line_content
			i += increment
		}

		parsed := Parser.new(reg).parse(item_content)

		// Uncomment not to use a paragraph if no other non-inline blocks in list-item
		// if parsed.len == 1 && parsed[0] is Paragraph {
		// 	list.items << ListItemNode{(parsed[0] as Paragraph).content}
		// } else {
		// 	list.items << ListItemNode{parsed}
		// }
		list.items << ListItemNode{parsed}
	}

	return list, i - position
}

pub fn (f ListFeature) parse_inline(tokens []Token, position int, reg &Registry) ?(Node, int) {
	return none
}

pub fn (f ListFeature) render(node Node, r HTMLRenderer) string {
	list := node as ListNode
	tag := if list.type == .ordered { 'ol' } else { 'ul' }

	arguments := match true {
		list.type == .ordered && list.start != 1 { ' start="${list.start}"' }
		list.type == .dash { ' class="list-dash"' }
		list.type == .star { ' class="list-star"' }
		list.type == .plus { ' class="list-plus"' }
		else { '' }
	}

	mut out := '<${tag}${arguments}>\n'
	for item in list.items {
		out += '<li>'
		for child in item.content {
			out += r.render_node(child)
		}
		out += '</li>\n'
	}
	out += '</${tag}>'
	return out
}

// Utils

fn is_list_item(tokens []Token, position int) bool {
	// List should begin at the start of a line
	if position > 0 && tokens[position - 1].kind != .newline {
		return false
	}

	is_ul := position + 2 < tokens.len && tokens[position].kind in [.dash, .plus, .star]
		&& tokens[position + 1].kind == .space
	is_ol := position + 3 < tokens.len && tokens[position].kind == .text
		&& tokens[position + 1].kind == .dot && tokens[position + 2].kind == .space
		&& tokens[position].lit.is_int() && tokens[position].lit.int() >= 0
	return is_ul || is_ol
}

fn is_compatible_list_item(tokens []Token, position int, open Token) bool {
	return position < tokens.len && tokens[position].kind == open.kind && if open.kind == .text {
		position + 2 < tokens.len && tokens[position + 1].kind == .dot && tokens[position + 2].kind == .space
	} else {
		position + 1 < tokens.len && tokens[position + 1].kind == .space
	}
}

fn gather_line(tokens []Token, position int) ([]Token, int) {
	mut i := position
	for i < tokens.len && tokens[i].kind != .newline {
		i++
	}
	return tokens[position..i + 1], i + 1 - position
}
