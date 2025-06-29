module features

import shared { HTMLRenderer, Node, Registry }
import lexer { Token }

pub interface Feature {
	node_name() string
	paragraph_stop_condition([]Token, int) ?bool
	parse_block([]Token, int, &Registry) ?(Node, int)
	parse_inline([]Token, int, &Registry) ?(Node, int)
	render(node Node, renderer HTMLRenderer) string
}

pub fn (f Feature) init(mut registry Registry) {
	registry.paragraph_stop_conditions << f.paragraph_stop_condition
	registry.block_parsers << f.parse_block
	registry.inline_parsers << f.parse_inline
	registry.renderers[f.node_name()] = f.render
}
