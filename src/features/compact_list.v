module features

import shared { HTMLRenderer, Node, Registry }
import parser { Parser }
import lexer { Token }

struct CompactListNode {
	type  CompactListType
	start u8
mut:
	items []CompactListItemNode
}

enum CompactListType {
	ordered
	unordered
}

pub fn (l CompactListNode) to_str(indent int) string {
	mut out := '${' '.repeat(indent)}CompactList(type=${l.type})\n'
	for item in l.items {
		out += item.to_str(indent + 2)
	}
	return out
}

struct CompactListItemNode {
	content []Node
}

pub fn (li CompactListItemNode) to_str(indent int) string {
	mut out := '${' '.repeat(indent)}CompactListItem\n'
	for child in li.content {
		out += child.to_str(indent + 2)
	}
	return out
}

pub struct CompactListFeature {}

pub fn (f CompactListFeature) node_name() string {
	return 'CompactListNode'
}

pub fn (f CompactListFeature) paragraph_stop_condition(tokens []Token, position int) ?bool {
	return is_compact_list_item(tokens, position)
}

pub fn (f CompactListFeature) parse_block(tokens []Token, position int, reg &Registry) ?(Node, int) {
	if !is_compact_list_item(tokens, position) {
		return none
	}

	open := tokens[position]
	ordered := open.kind == .text
	offset := if ordered { 1 } else { 0 }

	mut list := CompactListNode{
		items: []CompactListItemNode{}
		start: if ordered { open.lit.u8() } else { 0 }
		type:  if ordered { .ordered } else { .unordered }
	}

	mut line_end_index := position
	for line_end_index < tokens.len && tokens[line_end_index].kind != .newline {
		line_end_index++
	}

	ul_li_begin := fn [tokens, position] (pos int) bool {
		return pos + 3 < tokens.len && tokens[pos].kind == .space && tokens[pos + 1].kind == .space
			&& tokens[pos + 2].kind == .tilde && tokens[pos + 3].kind == .space
	}
	ol_li_begin := fn [tokens, position] (pos int) bool {
		return pos + 4 < tokens.len && tokens[pos].kind == .space && tokens[pos + 1].kind == .space
			&& tokens[pos + 2].kind == .text && tokens[pos + 3].kind == .dot
			&& tokens[pos + 4].kind == .space && tokens[pos + 2].lit.is_int()
			&& tokens[pos + 2].lit.int() >= 0
	}
	item_begin := if ordered { ol_li_begin } else { ul_li_begin }

	mut i := position + 2 + offset
	mut current_li_tokens := []Token{}
	for i < line_end_index {
		if item_begin(i) {
			list.items << CompactListItemNode{
				content: Parser.new(reg).parse_inlines(current_li_tokens)
			}
			current_li_tokens.clear()
			i += 2 + 2 + offset // spaces + bullet + offset
		} else {
			current_li_tokens << tokens[i]
			i++
		}
	}

	if current_li_tokens.len > 0 {
		list.items << CompactListItemNode{
			content: Parser.new(reg).parse_inlines(current_li_tokens)
		}
	}

	return list, line_end_index - position + 1
}

pub fn (f CompactListFeature) parse_inline(tokens []Token, position int, reg &Registry) ?(Node, int) {
	return none
}

pub fn (f CompactListFeature) render(node Node, r HTMLRenderer) string {
	list := node as CompactListNode
	tag := if list.type == .ordered { 'ol' } else { 'ul' }

	arguments := match true {
		list.type == .ordered && list.start != 1 { ' class="compact-list" start="${list.start}"' }
		else { ' class="compact-list"' }
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

fn is_compact_list_item(tokens []Token, position int) bool {
	// Should begin at the start of a line
	if position > 0 && tokens[position - 1].kind != .newline {
		return false
	}

	ul_li_begin := fn [tokens, position] (pos int) bool {
		precond := pos == position || (pos - position >= 2 && tokens[pos - 2].kind == .space
			&& tokens[pos - 1].kind == .space)
		return pos + 2 < tokens.len && tokens[pos].kind == .tilde && tokens[pos + 1].kind == .space
			&& precond
	}
	ol_li_begin := fn [tokens, position] (pos int) bool {
		precond := pos == position || (pos - position >= 2 && tokens[pos - 2].kind == .space
			&& tokens[pos - 1].kind == .space)
		return pos + 3 < tokens.len && tokens[pos].kind == .text && tokens[pos + 1].kind == .dot
			&& tokens[pos + 2].kind == .space && tokens[pos].lit.is_int()
			&& tokens[pos].lit.int() >= 0 && precond
	}

	mut line_length := 0
	for (position + line_length) < tokens.len && tokens[position + line_length].kind != .newline {
		line_length++
	}

	ul_li_count := []int{len: line_length, init: index + position}.count(ul_li_begin(it))
	ol_li_count := []int{len: line_length, init: index + position}.count(ol_li_begin(it))

	// return ul_li_count >= 2 || ol_li_count >= 2
	return ul_li_count >= 1 || ol_li_count >= 2
}
