module providers

import analyzer.psi
import lserver.completion
import lsp

const compile_time_constant = {
	'FN':        'The name of the current function'
	'METHOD':    'The name of the current method'
	'MOD':       'The name of the current module'
	'STRUCT':    'The name of the current struct'
	'FILE':      'The absolute path:the current file'
	'LINE':      'The line number of the current line (as a string)'
	'FILE_LINE': 'The relative path and line number of the current line (like @FILE:@LINE)'
	'COLUMN':    'The column number of the current line (as a string)'
	'VEXE':      'The absolute path:the V compiler executable'
	'VEXEROOT':  "The absolute path:the V compiler executable's root directory"
	'VHASH':     "The V compiler's git hash"
	'VMOD_FILE': 'The content:the nearest v.mod file'
	'VMODROOT':  "The absolute path:the nearest v.mod file's directory"
}

pub struct CompileTimeConstantCompletionProvider {}

fn (_ &CompileTimeConstantCompletionProvider) is_available(context psi.PsiElement) bool {
	parent := context.parent() or { return false }
	if parent.node.type_name != .reference_expression {
		return false
	}
	grand := parent.parent() or { return false }
	return grand !is psi.ValueAttribute
}

fn (mut _ CompileTimeConstantCompletionProvider) add_completion(ctx completion.CompletionContext, mut result completion.CompletionResultSet) {
	for constant, description in providers.compile_time_constant {
		result.add_element(lsp.CompletionItem{
			label: '@${constant}'
			kind: .constant
			detail: description
			insert_text: constant
		})
	}
}
