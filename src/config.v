struct Config {
	features []Feature
}

pub fn Config.new() Config {
	mut feats := []Feature{}
	feats << BoldFeature{}
	return Config{
		features: feats
	}
}
