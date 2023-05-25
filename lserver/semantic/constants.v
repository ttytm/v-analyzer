module semantic

pub const (
	semantic_types     = [
		'namespace',
		'type',
		'class',
		'enum',
		'interface',
		'struct',
		'typeParameter',
		'parameter',
		'variable',
		'property',
		'enumMember',
		'event',
		'function',
		'method',
		'macro',
		'keyword',
		'modifier',
		'comment',
		'string',
		'number',
		'regexp',
		'operator',
		'decorator',
	]
	semantic_modifiers = [
		'declaration',
		'definition',
		'readonly',
		'static',
		'deprecated',
		'abstract',
		'async',
		'modification',
		'documentation',
		'defaultLibrary',
		'mutable',
	]
)
