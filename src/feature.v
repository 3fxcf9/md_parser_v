pub interface Feature {
	init(mut registry Registry)
	parse_block([]Token, int, &Registry) ?(Node, int)
	parse_inline([]Token, int, &Registry) ?(InlineNode, int)
	render(Node, HTMLRenderer) string
}

@[heap]
pub struct Registry {
mut:
	block_parsers  []BlockParser
	inline_parsers []InlineParser
	renderers      map[string]fn (Node, HTMLRenderer) string
}

pub fn Registry.new() Registry {
	return Registry{}
}

pub fn (mut r Registry) register_block_parser(p BlockParser) {
	r.block_parsers << p
}

pub fn (mut r Registry) register_inline_parser(p InlineParser) {
	r.inline_parsers << p
}

pub fn (mut r Registry) register_renderer(type_name string, f fn (Node, HTMLRenderer) string) {
	r.renderers[type_name] = f
}
