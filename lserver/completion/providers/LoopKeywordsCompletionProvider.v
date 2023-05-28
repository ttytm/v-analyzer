module providers

import lserver.completion
import lsp

pub struct LoopKeywordsCompletionProvider {}

fn (k &LoopKeywordsCompletionProvider) is_available(ctx &completion.CompletionContext) bool {
	return ctx.inside_loop
}

fn (mut k LoopKeywordsCompletionProvider) add_completion(ctx &completion.CompletionContext, mut result completion.CompletionResultSet) {
	result.add_element(lsp.CompletionItem{
		label: 'break'
		kind: .keyword
		insert_text: 'break'
	})
	result.add_element(lsp.CompletionItem{
		label: 'continue'
		kind: .keyword
		insert_text: 'continue'
	})
}
