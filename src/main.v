import os

fn main() {
	mut features := []Feature{}
	features << BoldFeature{}
	features << ItalicFeature{}
	cfg := Config{
		features: features
	}

	mut registry := Registry.new()

	// Register parsers and renderer
	for feat in cfg.features {
		feat.init(mut registry)
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

	mut parse := Parser.new(registry)
	mut render := HTMLRenderer.new(registry)

	input := os.read_file(os.args[1] or { 'test.md' }) or { panic('Missing file') }

	tokens := tokenize(input)
	dump(tokens)
	document := parse.parse(tokens)
	dump(document)
	output := render.render_document(document)

	println(output)
}
