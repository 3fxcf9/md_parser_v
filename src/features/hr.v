module features

import lexer { Token }
import shared { HTMLRenderer, Node, Registry }

pub enum HRuleKind {
	solid
	dashed
	sawteeth
}

pub struct HRuleNode {
	kind HRuleKind
}

pub struct HRuleFeature {}

pub fn (f HRuleFeature) node_name() string {
	return 'HRuleNode'
}

pub fn (n HRuleNode) to_str(indent int) string {
	return '${' '.repeat(indent)}HR(${n.kind})\n'
}

pub fn (f HRuleFeature) paragraph_stop_condition(tokens []Token, position int) ?bool {
	// Stop paragraph if we're on a potential hrule
	return is_hrule_line_count(tokens, position) or { 0 } > 3 // at least 3 + newline
}

pub fn (f HRuleFeature) parse_block(tokens []Token, position int, reg &Registry) ?(Node, int) {
	if count := is_hrule_line_count(tokens, position) {
		kind := match tokens[position].kind {
			.equal { HRuleKind.solid }
			.dash { HRuleKind.dashed }
			.caret { HRuleKind.sawteeth }
			else { return none }
		}

		return HRuleNode{
			kind: kind
		}, count
	}
	return none
}

pub fn (f HRuleFeature) parse_inline(tokens []Token, position int, reg &Registry) ?(Node, int) {
	return none
}

pub fn (f HRuleFeature) render(node Node, renderer HTMLRenderer) string {
	match (node as HRuleNode).kind {
		.solid { return '<hr class="style-solid">' }
		.dashed { return '<hr class="style-dashed">' }
		.sawteeth { return '<hr class="style-sawteeth">' }
	}
}

// Utils
fn is_hrule_line_count(tokens []Token, position int) ?int {
	if position + 2 >= tokens.len {
		return none
	}

	mut i := position

	kind := tokens[i].kind
	if kind !in [.dash, .equal, .caret] {
		return none
	}

	mut count := 0
	for i < tokens.len && tokens[i].kind == kind {
		count++
		i++
	}

	if i >= tokens.len || tokens[i].kind != .newline {
		return none
	}
	return count // How many chars to consume
}
