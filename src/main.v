module md_parser

import os
import lexer { tokenize }
import parser { Parser }
import shared { HTMLRenderer }
import json

fn print_usage_and_exit() {
	eprintln('Usage: parser [--debug] <file.md>')
	exit(1)
}

pub fn parse_metadata(file []string) map[string]string {
	mut metadata := map[string]string{}

	for line in file {
		if !line.starts_with(':') {
			continue
		}

		key := line.all_before(' ')[1..]
		value := line.all_after_first(' ')

		metadata[key] = value
	}

	return metadata
}

fn main() {
	mut debug := false
	mut print_metadata := false
	mut filename := ''

	// Parse CLI args
	for arg in os.args[1..] {
		if arg == '--debug' {
			debug = true
		} else if arg == '--print-metadata' {
			print_metadata = true
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

	if print_metadata {
		metadata := parse_metadata(input.split_into_lines())
		println(json.encode(metadata))
	}

	registry := build_registry()

	mut parse := Parser.new(registry)
	mut render := HTMLRenderer.new(registry)

	if debug {
		println('\x1b[1;97mIN:\x1b[0m')
		println(input)
	}

	tokens := tokenize(input)

	if debug {
		println('\n\n\x1b[1;97mTokens:\x1b[0m')

		for t in tokens {
			print(t)
		}
	}

	document := parse.parse(tokens)

	if debug {
		println('\n\n\x1b[1;97mAST:\x1b[0m')
		for n in document {
			println(n.to_str(0))
		}
	}

	output := render.render_document(document)

	if debug {
		println('\n\n\x1b[1;97mOUT:\x1b[0m')
	}

	println(output)
}

pub fn md_to_html(md string) (map[string]string, string) {
	metadata := parse_metadata(md.split_into_lines())

	registry := build_registry()

	mut parse := Parser.new(registry)
	mut render := HTMLRenderer.new(registry)

	tokens := tokenize(md)
	document := parse.parse(tokens)
	return metadata, render.render_document(document)
}
