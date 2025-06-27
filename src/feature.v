pub interface Feature {
	// init(mut registry Registry)
	node_name() string
	paragraph_stop_condition([]Token, int) ?bool
	parse_block([]Token, int, &Registry) ?(Node, int)
	parse_inline([]Token, int, &Registry) ?(InlineNode, int)
	render(Node, HTMLRenderer) string
}

pub fn (f Feature) init(mut registry Registry) {
	registry.register_paragraph_stop_condition(f.paragraph_stop_condition)
	registry.register_block_parser(f.parse_block)
	registry.register_inline_parser(f.parse_inline)
	registry.register_renderer(f.node_name(), f.render)
}

@[heap]
pub struct Registry {
mut:
	paragraph_stop_conditions []ParagraphStopCondition
	block_parsers             []BlockParser
	inline_parsers            []InlineParser
	renderers                 map[string]fn (Node, HTMLRenderer) string
}

type ParagraphStopCondition = fn ([]Token, int) ?bool

type BlockParser = fn ([]Token, int, &Registry) ?(Node, int)

type InlineParser = fn ([]Token, int, &Registry) ?(InlineNode, int)

pub fn Registry.new() Registry {
	mut registry := Registry{}

	// Add default paragraph stop condition
	registry.paragraph_stop_conditions << fn (tokens []Token, position int) ?bool {
		return position + 1 < tokens.len && tokens[position].kind == .newline
			&& tokens[position + 1].kind == .newline
	}

	// Add paragraph and text renderers
	registry.renderers['Paragraph'] = fn (node Node, renderer HTMLRenderer) string {
		paragraph := node as Paragraph
		mut result := ''
		for child in paragraph.content {
			result += renderer.render_node(child as Node)
		}
		return '<p>${result}</p>'
	}
	registry.renderers['TextNode'] = fn (node Node, renderer HTMLRenderer) string {
		return (node as TextNode).text
	}
	return registry
}

pub fn (mut r Registry) register_paragraph_stop_condition(p ParagraphStopCondition) {
	r.paragraph_stop_conditions << p
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
