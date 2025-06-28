interface Node {
	to_str(indent int) string
}

struct Paragraph {
	content []InlineNode
}

pub fn (n Paragraph) to_str(indent int) string {
	mut out := '${' '.repeat(indent)}Paragraph\n'
	for inl in n.content {
		out += inl.to_str(indent + 2)
	}
	return out
}

interface InlineNode {
	to_str(indent int) string
}

struct TextNode {
	text string
}

pub fn (t TextNode) to_str(indent int) string {
	return '${' '.repeat(indent)}Text("${t.text}")\n'
}
