module DesugarOberon

/*
 *  Based on https://github.com/cwi-swat/oberon0/blob/7bed47c2098c7335a6b47c3bed1329795211b53f/src/lang/oberon0/l2/desugar/Desugar.rsc
 */

data Module = 
	\mod(Ident name, Declarations decls, list[Statement] body, Ident endName)
	;

data Declarations 
	= decls(list[ConstDecl] consts, list[TypeDecl] types, list[VarDecl] vars)
	;

data ConstDecl 
	= constDecl(Ident name, Expression \value)
	;
	
data TypeDecl 
	= typeDecl(Ident name, Type \type)
	;
	
data VarDecl 
	= varDecl(list[Ident] names, Type \type)
	;

data Type 
	= user(Ident name)
	;

data MaybeExpression
    = nothing()
    | just(Expression e)
    ;

data Statement 
	= assign(Ident var, Expression exp)
	| ifThen(Expression condition, list[Statement] body, list[ElseIf] elseIfs, list[Statement] elsePart)
	| whileDo(Expression condition, list[Statement] body)
	| skip()
	| forDo(Ident name, Expression from, Expression to, MaybeExpression by, list[Statement] body)
	| caseOf(Expression exp, list[Case] cases, list[Statement] elsePart)
	| begin(list[Statement] body)
	;

data Expression 
	= nat(int val)
	| \trueE()
	| \falseE()
	| lookup(Ident var)
	| neg(Expression exp)
	| pos(Expression exp)
	| not(Expression exp)
	| mul(Expression lhs, Expression rhs)
	| div(Expression lhs, Expression rhs)
	| amp(Expression lhs, Expression rhs)
	| add(Expression lhs, Expression rhs)
	| sub(Expression lhs, Expression rhs)
	| or(Expression lhs, Expression rhs)
	| eq(Expression lhs, Expression rhs)
	| neq(Expression lhs, Expression rhs)
	| lt(Expression lhs, Expression rhs)
	| gt(Expression lhs, Expression rhs)
	| leq(Expression lhs, Expression rhs)
	| geq(Expression lhs, Expression rhs)
	;

data Ident 
	= id(str name)
;


data Case
	= guard(Expression guard, list[Statement] body)
;

data ElseIf = elseif(Expression condition, list[Statement] body);

public Module desugar(Module \mod) {
	\mod.body = flattenBegin(case2ifs(for2while((\mod.body))));
	return \mod;
}

Statement cases2if(Expression e, list[Case] cs, list[Statement] es) {
	switch (cs) {
      case [c, *cs2]: {
			list[ElseIf] eis = [];
			for (c2 <- cs2)
			   eis = eis + [elseif(eq(e, c2.guard), c.body)];
			return ifThen(eq(e, c.guard), c.body, eis, es);
		}
	};
}

public list[Statement] case2ifs(list[Statement] stats) {
	return visit (stats) {
		case caseOf(e, [], es) => begin(es)
		case caseOf(e, cs, es) => cases2if(e, cs, es)
	}
}

public list[Statement] for2while(list[Statement] stats) {
	return visit (stats) {
		case forDo(n, f, t, just(by), b) =>
			begin([assign(n, f), whileDo(geq(lookup(n), t),
					b + [assign(n, add(lookup(n), by))])])
		case forDo(n, f, t, nothing(), b) =>
			begin([assign(n, f), whileDo(geq(lookup(n), t),
					b + [assign(n, add(lookup(n), nat(1)))])])
	}
}

public list[Statement] flattenBegin(list[Statement] stats) {
	return innermost visit (stats) {
		case [*Statement s1, begin(b), *Statement s2] => s1 + b + s2
	}
}