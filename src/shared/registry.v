module shared

import lexer {Token}

@[heap]
pub struct Registry {
pub mut:
	paragraph_stop_conditions []ParagraphStopCondition
	block_parsers             []FeatureParser
	inline_parsers            []FeatureParser
	renderers                 map[string]fn (Node, HTMLRenderer) string
}

pub type ParagraphStopCondition = fn ([]Token, int) ?bool

pub type FeatureParser = fn ([]Token, int, &Registry) ?(Node, int)

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
