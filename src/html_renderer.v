struct HTMLRenderer {
	registry &Registry
}

pub fn HTMLRenderer.new(registry Registry) HTMLRenderer {
	return HTMLRenderer{&registry}
}

// Entry point: render the whole document tree
pub fn (r HTMLRenderer) render_document(doc Node) string {
	if doc is Document {
		mut out := ''
		for child in doc.children {
			out += r.render_node(child)
		}
		return out
	}
	return r.render_node(doc)
}

// Render a single block node
pub fn (r HTMLRenderer) render_node(node Node) string {
	type_name := node.type_name()

	// if node is TextNode {
	// 	return node.text
	// }

	if renderer := r.registry.renderers[type_name] {
		return renderer(node, r)
	}
	return ''
}
