module providers

import lserver.completion
import lsp

const attributes = [
	'params',
	'noinit',
	'required',
	'skip',
	'assert_continues',
	'unsafe',
	'manualfree',
	'heap',
	'nonnull',
	'primary',
	'inline',
	'direct_array_access',
	'live',
	'flag',
	'noinline',
	'noreturn',
	'typedef',
	'console',
	'keep_args_alive',
	'omitempty',
]

const attributes_with_colon = [
	'sql',
	'table',
	'deprecated',
	'deprecated_after',
	'export',
	'callconv',
]

pub struct AttributesCompletionProvider {}

fn (k &AttributesCompletionProvider) is_available(ctx &completion.CompletionContext) bool {
	return ctx.is_attribute
}

fn (mut k AttributesCompletionProvider) add_completion(ctx &completion.CompletionContext, mut result completion.CompletionResultSet) {
	for attribute in providers.attributes {
		result.add_element(lsp.CompletionItem{
			label: attribute
			kind: .struct_
			insert_text: attribute
		})
	}

	for attribute in providers.attributes_with_colon {
		result.add_element(lsp.CompletionItem{
			label: "${attribute}: 'value'"
			kind: .struct_
			insert_text: "${attribute}: '$1'$1"
			insert_text_format: .snippet
		})
	}
}
