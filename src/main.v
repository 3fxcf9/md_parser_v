import os

struct Config {
	features []Feature
}

fn main() {
	mut features := []Feature{}

	// BEGIN ENABLED FEATURES
	features << BoldFeature{}
	features << ItalicFeature{}
	features << MathDisplayFeature{}
	features << MathInlineFeature{}
	features << UnderlineFeature{}
	features << HighlightFeature{}
	features << StrikethroughFeature{}
	features << NbspFeature{}
	// END ENABLED FEATURES

	cfg := Config{
		features: features
	}

	mut registry := Registry.new()

	// Register parsers and renderer
	for feat in cfg.features {
		feat.init(mut registry)
	}

	mut parse := Parser.new(registry)
	mut render := HTMLRenderer.new(registry)

	input := os.read_file(os.args[1] or { 'syntax.md' }) or { panic('Missing file') }

	tokens := tokenize(input)
	// dump(tokens)
	document := parse.parse(tokens)
	// dump(document)
	output := render.render_document(document)

	println(output)
}
