module documentation

import analyzer.psi
import strings

pub struct Provider {
mut:
	sb strings.Builder = strings.new_builder(100)
}

pub fn (mut p Provider) documentation(element psi.PsiElement) ?string {
	if element is psi.ModuleClause {
		p.module_documentation(element)?
		return p.sb.str()
	}

	if element is psi.FunctionOrMethodDeclaration {
		p.function_documentation(element)?
		return p.sb.str()
	}

	if element is psi.StructDeclaration {
		p.struct_documentation(element)?
		return p.sb.str()
	}

	if element is psi.VarDefinition {
		p.variable_documentation(element)?
		return p.sb.str()
	}

	if element is psi.ParameterDeclaration {
		p.parameter_documentation(element)?
		return p.sb.str()
	}

	if element is psi.Receiver {
		p.receiver_documentation(element)?
		return p.sb.str()
	}

	if element is psi.FieldDeclaration {
		p.field_documentation(element)?
		return p.sb.str()
	}

	return none
}

fn (mut p Provider) module_documentation(element psi.ModuleClause) ? {
	p.sb.write_string('```v\n')
	p.sb.write_string('module ')
	p.sb.write_string(element.name())
	p.sb.write_string('\n')
	p.sb.write_string('```')
}

fn (mut p Provider) function_documentation(element psi.FunctionOrMethodDeclaration) ? {
	signature := element.signature()?
	p.sb.write_string('```v\n')
	p.sb.write_string('fn ')
	p.sb.write_string(element.name())
	p.write_signature(signature)
	p.sb.write_string('\n')
	p.sb.write_string('```')
	p.write_separator()
	p.sb.write_string(element.doc_comment())
}

fn (mut p Provider) struct_documentation(element psi.StructDeclaration) ? {
	p.sb.write_string('```v\n')
	p.sb.write_string('struct ')
	p.sb.write_string(element.name())
	p.sb.write_string('\n')
	p.sb.write_string('```')
	p.write_separator()
	p.sb.write_string(element.doc_comment())
}

fn (mut p Provider) variable_documentation(element psi.VarDefinition) ? {
	p.sb.write_string('```v\n')
	p.sb.write_string(element.name())
	p.sb.write_string(' ')
	p.sb.write_string(element.get_type().readable_name())
	p.sb.write_string('\n')
	p.sb.write_string('```')
}

fn (mut p Provider) parameter_documentation(element psi.ParameterDeclaration) ? {
	p.sb.write_string('```v\n')
	p.sb.write_string(element.name())
	p.sb.write_string(' ')
	p.sb.write_string(element.get_type().readable_name())
	p.sb.write_string('\n')
	p.sb.write_string('```')
}

fn (mut p Provider) field_documentation(element psi.FieldDeclaration) ? {
	p.sb.write_string('```v\n')

	if owner := element.owner() {
		if owner is psi.PsiNamedElement {
			p.sb.write_string(owner.name())
			p.sb.write_string('.')
		}
	}

	p.sb.write_string(element.name())
	p.sb.write_string(' ')
	p.sb.write_string(element.get_type().readable_name())
	p.sb.write_string('\n')
	p.sb.write_string('```')
}

fn (mut p Provider) receiver_documentation(element psi.Receiver) ? {
	p.sb.write_string('```v\n')
	p.sb.write_string('receiver ')
	p.sb.write_string(element.name())
	p.sb.write_string(' ')
	p.sb.write_string(element.get_type().readable_name())
	p.sb.write_string('\n')
	p.sb.write_string('```')
}

fn (mut p Provider) write_separator() {
	p.sb.write_string('\n\n')
}

fn (mut p Provider) write_signature(signature psi.Signature) {
	p.sb.write_string(signature.get_text())
}
