module shared

pub interface Node {
	to_str(indent int) string
}

pub struct Paragraph {
pub:
	content []Node
}

pub fn (n Paragraph) to_str(indent int) string {
	mut out := '${' '.repeat(indent)}Paragraph\n'
	for inl in n.content {
		out += inl.to_str(indent + 2)
	}
	return out
}

pub struct TextNode {
pub:
	text string
}

pub fn (t TextNode) to_str(indent int) string {
	return '${' '.repeat(indent)}Text("${t.text}")\n'
}
