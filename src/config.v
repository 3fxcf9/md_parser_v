module main

import features { BoldFeature, CodeBlockFeature, CodeInlineFeature, EnvironmentFeature, Feature, HRuleFeature, HeadingFeature, HighlightFeature, ItalicFeature, LinkFeature, ListFeature, MathDisplayFeature, MathInlineFeature, NbspFeature, SidenoteFeature, StrikethroughFeature, UnderlineFeature }
import shared { Registry }

struct Config {
	features []Feature
}

fn build_registry() Registry {
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

	return registry
}
