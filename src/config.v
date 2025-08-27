module md_parser

// module main
import features { AnchorFeature, BoldFeature, CodeBlockFeature, CodeInlineFeature, CompactListFeature, CompactListFeature, EnvironmentFeature, Feature, HRuleFeature, HeadingFeature, HighlightFeature, ImageFeature, InternalReferenceFeature, ItalicFeature, LinkFeature, ListFeature, MathDisplayFeature, MathInlineFeature, NbspFeature, SidenoteFeature, StrikethroughFeature, UnderlineFeature }
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
	f << InternalReferenceFeature{} // IMPORTANT: Place before link (conflicting syntax)
	f << LinkFeature{}
	f << AnchorFeature{}
	// f << FigureFeature{}
	f << ImageFeature{}
	f << MathDisplayFeature{}
	f << MathInlineFeature{}
	f << CodeInlineFeature{}
	f << CodeBlockFeature{}
	f << SidenoteFeature{}
	f << HRuleFeature{}
	f << CompactListFeature{} // IMPORTANT: Place before nbsp AND list (conflicting syntax)
	f << ListFeature{}
	f << NbspFeature{}
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
