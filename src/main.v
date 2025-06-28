import os

struct Config {
	features []Feature
}

fn main() {
	mut features := []Feature{}

	// BEGIN ENABLED FEATURES
	features << HeadingFeature{}
	features << BoldFeature{}
	features << ItalicFeature{}
	features << UnderlineFeature{}
	features << HighlightFeature{}
	features << StrikethroughFeature{}
	features << LinkFeature{}
	features << MathDisplayFeature{}
	features << MathInlineFeature{}
	features << CodeInlineFeature{}
	features << NbspFeature{}
	features << ListFeature{}
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

	input := os.read_file(os.args[1] or { 'test.md' }) or { panic('Missing file') }

	tokens := tokenize(input)
	// for t in tokens {
	// 	print(t)
	// }
	document := parse.parse(tokens)
	// for n in document {
	// 	println(n.to_str(0))
	// }
	output := render.render_document(document)

	println(output)
}
