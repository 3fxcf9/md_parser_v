module main

import os
import lexer { tokenize }
import parser { Parser }
import shared { HTMLRenderer }

fn print_usage_and_exit() {
	eprintln('Usage: parser [--debug] <file.md>')
	exit(1)
}

fn main() {
	mut debug := false
	mut filename := ''

	// Parse CLI args
	for arg in os.args[1..] {
		if arg == '--debug' {
			debug = true
		} else if filename == '' {
			filename = arg
		} else {
			eprintln('Unknown argument: ${arg}')
			print_usage_and_exit()
		}
	}

	if filename == '' {
		print_usage_and_exit()
	}

	if !os.exists(filename) {
		eprintln('File not found: ${filename}')
		return
	}

	input := os.read_file(filename) or {
		eprintln('Failed to read file: ${filename}')
		return
	}

	registry := build_registry()

	mut parse := Parser.new(registry)
	mut render := HTMLRenderer.new(registry)

	tokens := tokenize(input)
	document := parse.parse(tokens)
	output := render.render_document(document)

	if debug {
		println('\x1b[1;97mIN:\x1b[0m')
		println(input)
		println('\n\n\x1b[1;97mTokens:\x1b[0m')

		for t in tokens {
			print(t)
		}

		println('\n\n\x1b[1;97mAST:\x1b[0m')
		for n in document {
			println(n.to_str(0))
		}

		println('\n\n\x1b[1;97mOUT:\x1b[0m')
	}

	println(output)
}

fn md_to_html(md string) string {
	registry := build_registry()

	mut parse := Parser.new(registry)
	mut render := HTMLRenderer.new(registry)

	tokens := tokenize(md)
	document := parse.parse(tokens)
	return render.render_document(document)
}
