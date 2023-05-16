module psi

pub struct StubbedElementType {
	name       string
	debug_name string
}

fn (s &StubbedElementType) external_id() string {
	return 'vlang.${s.debug_name}'
}

pub fn (s &StubbedElementType) index_stub(stub &StubBase, mut sink IndexSink) {
	if stub.stub_type == .function_declaration {
		name := stub.name()
		sink.occurrence(StubIndexKey.functions, name)
	}

	if stub.stub_type == .struct_declaration {
		name := stub.name()
		sink.occurrence(StubIndexKey.structs, name)
	}

	if stub.stub_type == .constant_declaration {
		name := stub.name()
		sink.occurrence(StubIndexKey.constants, name)
	}

	if stub.stub_type == .type_alias_declaration {
		name := stub.name()
		if name == 'u32' {
			println(1)
		}
		sink.occurrence(StubIndexKey.type_aliases, name)
	}
}

pub fn (s &StubbedElementType) create_psi(stub &StubBase) ?PsiElement {
	stub_type := stub.stub_type()
	if stub_type == .function_declaration {
		return FunctionOrMethodDeclaration{
			PsiElementImpl: new_psi_node_from_stub(stub.id, stub.stub_list)
		}
	}
	if stub_type == .signature {
		return Signature{
			PsiElementImpl: new_psi_node_from_stub(stub.id, stub.stub_list)
		}
	}
	if stub_type == .struct_declaration {
		return StructDeclaration{
			PsiElementImpl: new_psi_node_from_stub(stub.id, stub.stub_list)
		}
	}
	if stub_type == .field_declaration {
		return FieldDeclaration{
			PsiElementImpl: new_psi_node_from_stub(stub.id, stub.stub_list)
		}
	}
	if stub_type == .constant_declaration {
		return ConstantDefinition{
			PsiElementImpl: new_psi_node_from_stub(stub.id, stub.stub_list)
		}
	}
	if stub_type == .type_alias_declaration {
		return TypeAliasDeclaration{
			PsiElementImpl: new_psi_node_from_stub(stub.id, stub.stub_list)
		}
	}
	if stub_type == .plain_type {
		return PlainType{
			PsiElementImpl: new_psi_node_from_stub(stub.id, stub.stub_list)
		}
	}
	return new_psi_node_from_stub(stub.id, stub.stub_list)
}

pub fn (s &StubbedElementType) create_stub(psi PsiElement, parent_stub &StubElement) ?&StubBase {
	if psi is FunctionOrMethodDeclaration {
		text_range := if identifier := psi.identifier() {
			identifier.text_range()
		} else {
			psi.text_range()
		}
		comment := psi.doc_comment()
		return new_stub_base_with_comment(parent_stub, .function_declaration, psi.name(),
			psi.get_text(), comment, text_range)
	}

	if psi is Signature {
		return new_stub_base(parent_stub, .signature, '', psi.get_text(), psi.text_range())
	}

	if psi is StructDeclaration {
		text_range := if identifier := psi.identifier() {
			identifier.text_range()
		} else {
			psi.text_range()
		}
		comment := psi.doc_comment()
		return new_stub_base_with_comment(parent_stub, .struct_declaration, psi.name(),
			psi.get_text(), comment, text_range)
	}

	if psi is FieldDeclaration {
		text_range := if identifier := psi.identifier() {
			identifier.text_range()
		} else {
			psi.text_range()
		}
		comment := psi.doc_comment()
		return new_stub_base_with_comment(parent_stub, .field_declaration, psi.name(),
			psi.get_text(), comment, text_range)
	}

	if psi is ConstantDefinition {
		text_range := if identifier := psi.identifier() {
			identifier.text_range()
		} else {
			psi.text_range()
		}
		comment := psi.doc_comment()
		return new_stub_base_with_comment(parent_stub, .constant_declaration, psi.name(),
			psi.get_text(), comment, text_range)
	}

	if psi is TypeAliasDeclaration {
		text_range := if identifier := psi.identifier() {
			identifier.text_range()
		} else {
			psi.text_range()
		}
		comment := psi.doc_comment()
		return new_stub_base_with_comment(parent_stub, .type_alias_declaration, psi.name(),
			psi.get_text(), comment, text_range)
	}

	if psi is PlainType {
		return new_stub_base(parent_stub, .plain_type, '', psi.get_text(), psi.text_range())
	}

	return none
}

pub fn (s &StubbedElementType) serialize(stub StubElement, mut stream StubOutputStream) {
	stub_type := stub.stub_type()
	if stub_type == .function_declaration {
		stream.write_u8(u8(stub_type))
		stream.write_name(stub.name())
	}

	if stub_type == .struct_declaration {
		stream.write_u8(u8(stub_type))
		stream.write_name(stub.name())
	}

	if stub_type == .field_declaration {
		stream.write_u8(u8(stub_type))
		stream.write_name(stub.name())
	}

	if stub_type == .constant_declaration {
		stream.write_u8(u8(stub_type))
		stream.write_name(stub.name())
	}

	if stub_type == .plain_type {
		stream.write_u8(u8(stub_type))
		stream.write_name(stub.name())
	}
}

pub fn (s &StubbedElementType) deserialize(stream StubInputStream, parent_stub &StubElement) ?&StubElement {
	stub_type := unsafe { StubType(stream.read_u8()) }
	match stub_type {
		.root {}
		.function_declaration {
			return new_stub_base(parent_stub, .function_declaration, stream.read_name(),
				stream.read_name(), TextRange{})
		}
		.constant_declaration {
			return new_stub_base(parent_stub, .constant_declaration, stream.read_name(),
				stream.read_name(), TextRange{})
		}
		.struct_declaration {
			return new_stub_base(parent_stub, .struct_declaration, stream.read_name(),
				stream.read_name(), TextRange{})
		}
		.field_declaration {
			return new_stub_base(parent_stub, .field_declaration, stream.read_name(),
				stream.read_name(), TextRange{})
		}
		.plain_type {
			return new_stub_base(parent_stub, .plain_type, stream.read_name(), stream.read_name(),
				TextRange{})
		}
		.signature {}
		.type_alias_declaration {}
	}

	return none
}
