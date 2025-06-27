interface Node {
}

struct Document {
	children []Node
}

struct Paragraph {
	content []InlineNode
}

interface InlineNode {
}

struct TextNode {
	text string
}
