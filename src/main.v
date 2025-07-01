import os
import lexer { tokenize }
import parser { Parser }
import features { BoldFeature, CodeBlockFeature, CodeInlineFeature, EnvironmentFeature, Feature, HRuleFeature, HeadingFeature, HighlightFeature, ItalicFeature, LinkFeature, ListFeature, MathDisplayFeature, MathInlineFeature, NbspFeature, SidenoteFeature, StrikethroughFeature, UnderlineFeature }
import shared { HTMLRenderer, Registry }

struct Config {
	features []Feature
}

fn main() {
	mut f := []Feature{}

	// BEGIN ENABLED FEATURES
	f << HeadingFeature{}
	f << BoldFeature{}
	f << ItalicFeature{}
	f << UnderlineFeature{}
	f << HighlightFeature{}
	f << StrikethroughFeature{}
	f << LinkFeature{}
	f << MathDisplayFeature{}
	f << MathInlineFeature{}
	f << CodeInlineFeature{}
	f << CodeBlockFeature{}
	f << NbspFeature{}
	f << SidenoteFeature{}
	f << HRuleFeature{}
	f << ListFeature{}
	f << EnvironmentFeature{}
	// END ENABLED FEATURES

	cfg := Config{
		features: f
	}

	mut registry := Registry.new()

	// Register parsers and renderer
	for feat in cfg.features {
		feat.init(mut registry)
	}

	mut parse := Parser.new(registry)
	mut render := HTMLRenderer.new(registry)

	input := os.read_file(os.args[1] or { 'test.md' }) or { panic('Missing file') }
	println('\x1b[1;97mIN:\x1b[0m')
	println(input)

	println('\n\n\x1b[1;97mTokens:\x1b[0m')
	tokens := tokenize(input)
	for t in tokens {
		print(t)
	}

	println('\n\n\x1b[1;97mAST:\x1b[0m')
	document := parse.parse(tokens)
	for n in document {
		println(n.to_str(0))
	}

	println('\n\n\x1b[1;97mOUT:\x1b[0m')
	output := render.render_document(document)

	println(output)
}
