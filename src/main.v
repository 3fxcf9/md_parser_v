import os

fn main() {
	input := os.read_file(os.args[1] or { 'test.md' }) or { panic('Missing file') }

	tokens := tokenize(input)
	dump(tokens)
}
