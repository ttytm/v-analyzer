module psi

pub fn create_element(node AstNode, containing_file &PsiFile) PsiElement {
	base_node := new_psi_node(containing_file, node)
	var := node_to_var_definition(node, containing_file, base_node)
	if !isnil(var) {
		return var
	}

	match node.type_name {
		.module_clause {
			return ModuleClause{base_node}
		}
		.identifier {
			return Identifier{base_node}
		}
		.plain_type {
			return PlainType{base_node}
		}
		.selector_expression {
			return SelectorExpression{base_node}
		}
		.for_statement {
			return ForStatement{base_node}
		}
		.call_expression {
			return CallExpression{base_node}
		}
		.argument {
			return Argument{base_node}
		}
		.index_expression {
			return IndexExpression{base_node}
		}
		.reference_expression {
			return ReferenceExpression{base_node}
		}
		.type_reference_expression {
			return TypeReferenceExpression{base_node}
		}
		.type_declaration {
			return TypeAliasDeclaration{base_node}
		}
		.type_initializer {
			return TypeInitializer{base_node}
		}
		.field_name {
			return FieldName{base_node}
		}
		.function_declaration {
			return FunctionOrMethodDeclaration{base_node}
		}
		.receiver {
			return Receiver{base_node}
		}
		.struct_declaration {
			return StructDeclaration{base_node}
		}
		.interface_declaration {
			return InterfaceDeclaration{base_node}
		}
		.interface_method_definition {
			return InterfaceMethodDeclaration{base_node}
		}
		.enum_declaration {
			return EnumDeclaration{base_node}
		}
		.struct_field_declaration {
			return FieldDeclaration{base_node}
		}
		.struct_field_scope {
			return StructFieldScope{base_node}
		}
		.enum_field_definition {
			return EnumFieldDeclaration{base_node}
		}
		.const_declaration {
			return ConstantDeclaration{base_node}
		}
		.const_definition {
			return ConstantDefinition{base_node}
		}
		.var_declaration {
			return VarDeclaration{base_node}
		}
		.block {
			return Block{base_node}
		}
		.mutable_expression {
			return MutExpression{base_node}
		}
		.signature {
			return Signature{base_node}
		}
		.parameter_list {
			return ParameterList{base_node}
		}
		.parameter_declaration {
			return ParameterDeclaration{base_node}
		}
		.literal {
			return Literal{base_node}
		}
		.line_comment {
			return LineComment{base_node}
		}
		.block_comment {
			return BlockComment{base_node}
		}
		.mutability_modifiers {
			return MutabilityModifiers{base_node}
		}
		.visibility_modifiers {
			return VisibilityModifiers{base_node}
		}
		.attributes {
			return Attributes{base_node}
		}
		.attribute {
			return Attribute{base_node}
		}
		.attribute_expression {
			return AttributeExpression{base_node}
		}
		.value_attribute {
			return ValueAttribute{base_node}
		}
		.range {
			return Range{base_node}
		}
		.interpreted_string_literal {
			return StringLiteral{base_node}
		}
		.unsafe_expression {
			return UnsafeExpression{base_node}
		}
		.array_creation {
			return ArrayCreation{
				PsiElementImpl: base_node
			}
		}
		.fixed_array_creation {
			return ArrayCreation{
				PsiElementImpl: base_node
				is_fixed: true
			}
		}
		.map_init_expression {
			return MapInitExpression{base_node}
		}
		.map_keyed_element {
			return MapKeyedElement{base_node}
		}
		.function_literal {
			return FunctionLiteral{base_node}
		}
		.if_expression {
			return IfExpression{base_node}
		}
		.compile_time_if_expression {
			return CompileTimeIfExpression{base_node}
		}
		.match_expression {
			return MatchExpression{base_node}
		}
		.import_spec {
			return ImportSpec{base_node}
		}
		.qualified_type {
			return QualifiedType{base_node}
		}
		.import_list {
			return ImportList{base_node}
		}
		.import_declaration {
			return ImportDeclaration{base_node}
		}
		.import_path {
			return ImportPath{base_node}
		}
		.import_name {
			return ImportName{base_node}
		}
		.import_alias {
			return ImportAlias{base_node}
		}
		.global_var_definition {
			return GlobalVarDefinition{base_node}
		}
		.keyed_element {
			return KeyedElement{base_node}
		}
		.generic_parameters {
			return GenericParameters{base_node}
		}
		.generic_parameter {
			return GenericParameter{base_node}
		}
		.slice_expression {
			return SliceExpression{base_node}
		}
		.embedded_definition {
			return EmbeddedDefinition{base_node}
		}
		.or_block_expression {
			return OrBlockExpression{base_node}
		}
		.option_propagation_expression {
			return OptionPropagationExpression{base_node}
		}
		.result_propagation_expression {
			return ResultPropagationExpression{base_node}
		}
		.type_parameters {
			return GenericTypeArguments{base_node}
		}
		.unary_expression {
			return UnaryExpression{base_node}
		}
		.binary_expression {
			return BinaryExpression{base_node}
		}
		.source_file {
			return SourceFile{base_node}
		}
		.static_method_declaration {
			return StaticMethodDeclaration{base_node}
		}
		.static_receiver {
			return StaticReceiver{base_node}
		}
		else {}
	}

	return base_node
}

@[inline]
pub fn node_to_var_definition(node AstNode, containing_file &PsiFile, base_node ?PsiElementImpl) &VarDefinition {
	if node.type_name == .var_definition {
		return &VarDefinition{
			PsiElementImpl: base_node or { new_psi_node(containing_file, node) }
		}
	}

	if node.type_name == .reference_expression {
		parent := node.parent() or { return unsafe { nil } }
		if parent.type_name != .expression_list && parent.type_name != .mutable_expression {
			return unsafe { nil }
		}

		grand := parent.parent() or { return unsafe { nil } }

		if grand.type_name == .var_declaration {
			var_list := grand.child_by_field_name('var_list') or { return unsafe { nil } }
			if var_list.is_parent_of(node) {
				return &VarDefinition{
					PsiElementImpl: base_node or { new_psi_node(containing_file, node) }
				}
			}
		}
		if grand_grand := grand.parent() {
			if grand_grand.type_name == .var_declaration && parent.type_name == .mutable_expression {
				return &VarDefinition{
					PsiElementImpl: base_node or { new_psi_node(containing_file, node) }
				}
			}
		}
	}

	return unsafe { nil }
}
