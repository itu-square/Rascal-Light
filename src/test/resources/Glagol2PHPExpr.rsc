module Glagol2PHP

/*
Based on https://github.com/BulgariaPHP/glagol-dsl
*/

/*
======================
Glagol Abstract Syntax
======================
*/

data Unsuppported = unsupported();

data Expression
    = integer(int intValue)
    | string(str strValue)
    | boolean(bool boolValue)
    | \list(list[Expression] values)
    | arrayAccess(Expression variable, Expression arrayIndexKey)
    | \map(map[Expression key, Expression \value])
    | variable(str name)
    | \bracket(Expression expr)
    | product(Expression lhs, Expression rhs)
    | remainder(Expression lhs, Expression rhs)
    | division(Expression lhs, Expression rhs)
    | addition(Expression lhs, Expression rhs)
    | subtraction(Expression lhs, Expression rhs)
    | greaterThanOrEq(Expression lhs, Expression rhs)
    | lessThanOrEq(Expression lhs, Expression rhs)
    | lessThan(Expression lhs, Expression rhs)
    | greaterThan(Expression lhs, Expression rhs)
    | equals(Expression lhs, Expression rhs)
    | nonEquals(Expression lhs, Expression rhs)
    | and(Expression lhs, Expression rhs)
    | or(Expression lhs, Expression rhs)
    | negative(Expression expr)
    | positive(Expression expr)
    | ternary(Expression condition, Expression ifThen, Expression \else)
    | new(str artifact, list[Expression] args)
    | get(Type t)
    | invoke(str methodName, list[Expression] args)
    | invoke2(Expression prev, str methodName, list[Expression] args)
    | fieldAccess(str field)
    | fieldAccess2(Expression prev, str field)
    | emptyExpr()
    | this()
    ;

data Type
    = integer2()
    | string2()
    | voidValue()
    | boolean2()
    | list2(Type \type)
    | map2(Type key, Type v)
    | artifact(str name)
    | repository(str name)
    | selfie()
    ;

/*
======================
PHP Abstract Syntax
======================
*/

public data PhpOptionExpr = phpSomeExpr(PhpExpr expr) | phpNoExpr();

public data PhpOptionName = phpSomeName(PhpName name) | phpNoName();

public data PhpOptionElse = phpSomeElse(PhpElse e) | phpNoElse();

public data PhpActualParameter
    = phpActualParameter(PhpExpr expr, bool byRef)
    | phpActualParameter2(PhpExpr expr, bool byRef, bool isVariadic);

public data PhpConst = phpConst(str name, PhpExpr constValue);

public data PhpArrayElement = phpArrayElement(PhpOptionExpr key, PhpExpr val, bool byRef);

public data PhpName = phpName(str name);

public data PhpNameOrExpr = phpName2(PhpName name) | phpExpr(PhpExpr expr);

public data PhpCastType = phpIntCast() | phpBoolCast() | phpStringCast() | phpArrayCast() | phpObjectCast() | phpUnsetCast();

public data PhpClosureUse = phpClosureUse(PhpExpr varName, bool byRef);

public data PhpIncludeType = phpInclude() | phpIncludeOnce() | phpRequire() | phpRequireOnce();

public data PhpExpr
    = phpArray(list[PhpArrayElement] items)
    | phpFetchArrayDim(PhpExpr var, PhpOptionExpr dim)
    | phpFetchClassConst(PhpNameOrExpr className, str constantName)
    | phpAssign(PhpExpr assignTo, PhpExpr assignExpr)
    | phpAssignWOp(PhpExpr assignTo, PhpExpr assignExpr, PhpOp operation)
    | phpListAssign(list[PhpOptionExpr] assignsTo, PhpExpr assignExpr)
    | phpRefAssign(PhpExpr assignTo, PhpExpr assignExpr)
    | phpBinaryOperation(PhpExpr left, PhpExpr right, PhpOp operation)
    | phpUnaryOperation(PhpExpr operand, PhpOp operation)
    | phpNew(PhpNameOrExpr className, list[PhpActualParameter] parameters)
    | phpCast(PhpCastType castType, PhpExpr expr)
    | phpClone(PhpExpr expr)
    | phpClosure(list[PhpStmt] statements, list[PhpParam] params, list[PhpClosureUse] closureUses, bool byRef, bool static)
    | phpFetchConst(PhpName name)
    | phpEmpty(PhpExpr expr)
    | phpSuppress(PhpExpr expr)
    | phpEval(PhpExpr expr)
    | phpExit(PhpOptionExpr exitExpr)
    | phpCall(PhpNameOrExpr funName, list[PhpActualParameter] parameters)
    | phpMethodCall(PhpExpr target, PhpNameOrExpr methodName, list[PhpActualParameter] parameters)
    | phpStaticCall(PhpNameOrExpr staticTarget, PhpNameOrExpr methodName, list[PhpActualParameter] parameters)
    | phpIncludeExpr(PhpExpr expr, PhpIncludeType includeType)
    | phpInstanceOf(PhpExpr expr, PhpNameOrExpr toCompare)
    | phpIsSet(list[PhpExpr] exprs)
    | phpPrint(PhpExpr expr)
    | phpPropertyFetch(PhpExpr target, PhpNameOrExpr propertyName)
    | phpShellExec(list[PhpExpr] parts)
    | phpTernary(PhpExpr cond, PhpOptionExpr ifBranch, PhpExpr elseBranch)
    | phpStaticPropertyFetch(PhpNameOrExpr className, PhpNameOrExpr propertyName)
    | phpScalar(PhpScalar scalarVal)
    | phpVar(PhpNameOrExpr varName)
    | phpYield(PhpOptionExpr keyExpr, PhpOptionExpr valueExpr)
    | phpListExpr(list[PhpOptionExpr] listExprs)
    | phpBracket(PhpOptionExpr bracketExpr)
    ;

public data PhpOp = phpBitwiseAnd() | phpBitwiseOr() | phpBitwiseXor() | phpConcat() | phpDiv()
               | phpMinus() | phpMod() | phpMul() | phpPlus() | phpRightShift() | phpLeftShift()
               | phpBooleanAnd() | phpBooleanOr() | phpBooleanNot() | phpBitwiseNot()
               | phpGt() | phpGeq() | phpLogicalAnd() | phpLogicalOr() | phpLogicalXor()
               | phpNotEqual() | phpNotIdentical() | phpPostDec() | phpPreDec() | phpPostInc()
               | phpPreInc() | phpLt() | phpLeq() | phpUnaryPlus() | phpUnaryMinus()
               | phpEqual() | phpIdentical() ;

public data PhpParam
    = phpParam(str paramName, PhpOptionExpr paramDefault, PhpOptionName paramType, bool byRef, bool isVariadic)
    ;

public data PhpScalar
    = phpClassConstant()
    | phpDirConstant()
    | phpFileConstant()
    | phpFuncConstant()
    | phpLineConstant()
    | phpMethodConstant()
    | phpNamespaceConstant()
    | phpTraitConstant()
    | phpNull()
    | phpInteger(int intVal)
    | phpString(str strVal)
    | phpBoolean(bool boolVal)
    | phpEncapsed(list[PhpExpr] parts)
    | phpEncapsedStringPart(str strVal)
    ;

public data PhpStmt
    = phpBreak(PhpOptionExpr breakExpr)
    | phpClassDef(PhpClassDef classDef)
    | phpConsts(list[PhpConst] consts)
    | phpContinue(PhpOptionExpr continueExpr)
    | phpDeclare(list[PhpDeclaration] decls, list[PhpStmt] body)
    | phpDo(PhpExpr cond, list[PhpStmt] body)
    | phpEcho(list[PhpExpr] exprs)
    | phpExprstmt(PhpExpr expr)
    | phpFor(list[PhpExpr] inits, list[PhpExpr] conds, list[PhpExpr] exprs, list[PhpStmt] body)
    | phpForeach(PhpExpr arrayExpr, PhpOptionExpr keyvar, bool byRef, PhpExpr asVar, list[PhpStmt] body)
    | phpFunction(str name, bool byRef, list[PhpParam] params, list[PhpStmt] body, PhpOptionName returnType)
    | phpGlobal(list[PhpExpr] exprs)
    | phpGoto(str label)
    | phpHaltCompiler(str remainingText)
    | phpIf(PhpExpr cond, list[PhpStmt] body, list[PhpElseIf] elseIfs, PhpOptionElse elseClause)
    | phpInlineHTML(str htmlText)
    | phpInterfaceDef(PhpInterfaceDef interfaceDef)
    | phpTraitDef(PhpTraitDef traitDef)
    | phpLabel(str labelName)
    | phpNamespace(PhpOptionName nsName, list[PhpStmt] body)
    | phpNamespaceHeader(PhpName namespaceName)
    | phpReturn(PhpOptionExpr returnExpr)
    | phpStaticVars(list[PhpStaticVar] vars)
    | phpSwitch(PhpExpr cond, list[PhpCase] cases)
    | phpThrow(PhpExpr expr)
    | phpTryCatch(list[PhpStmt] body, list[PhpCatch] catches)
    | phpTryCatchFinally(list[PhpStmt] body, list[PhpCatch] catches, list[PhpStmt] finallyBody)
    | phpUnset(list[PhpExpr] unsetVars)
    | phpUseExpr(set[PhpUse] uses)
    | phpWhile(PhpExpr cond, list[PhpStmt] body)
    | phpEmptyStmt()
    | phpBlock(list[PhpStmt] body)
    | phpNewLine()
    ;

public data PhpDeclaration = phpDeclaration(str key, PhpExpr val);

public data PhpCatch = phpCatch(PhpName xtype, str varName, list[PhpStmt] body);

public data PhpCase = phpCase(PhpOptionExpr cond, list[PhpStmt] body);

public data PhpElseIf = phpElseIf(PhpExpr cond, list[PhpStmt] body);

public data PhpElse = phpElse(list[PhpStmt] body);

public data PhpUse = phpUse(PhpName importName, PhpOptionName asName);

public data PhpClassItem
    = phpPropertyCI(set[PhpModifier] modifiers, list[PhpProperty] prop)
    | phpConstCI(list[PhpConst] consts)
    | phpMethod(str name, set[PhpModifier] modifiers, bool byRef, list[PhpParam] params, list[PhpStmt] body, PhpOptionName returnType)
    | phpTraitUse(list[PhpName] traits, list[PhpAdaptation] adaptations)
    ;

public data PhpAdaptation
    = phpTraitAlias(PhpOptionName traitName, str methName, set[PhpModifier] newModifiers, PhpOptionName newName)
    | phpTraitPrecedence(PhpOptionName traitName, str methName, set[PhpName] insteadOf)
    ;

public data PhpProperty = phpProperty(str propertyName, PhpOptionExpr defaultValue);

public data PhpModifier = phpPublic() | phpPrivate() | phpProtected() | phpStatic() | phpAbstract() | phpFinal();

public data PhpClassDef = phpClass(str className,
                             set[PhpModifier] modifiers,
                             PhpOptionName extends,
                             list[PhpName] implements,
                             list[PhpClassItem] members);

public data PhpInterfaceDef = phpInterface(str interfaceName,
                                    list[PhpName] extends,
                                    list[PhpClassItem] members);

public data PhpTraitDef = phpTrait(str traitName, list[PhpClassItem] members);

public data PhpStaticVar = phpStaticVar(str name, PhpOptionExpr defaultValue);

public data PhpScript = phpScript(list[PhpStmt] body) | phpErrscript(str err);

public data PhpAnnotation
    = phpAnnotation(str key)
    | phpAnnotation(str key, PhpAnnotation v)
    | phpAnnotationVal(map[str k, PhpAnnotation v])
    | phpAnnotationVal(str string)
    | phpAnnotationVal(int integer)
    | phpAnnotationVal(bool boolean)
    | phpAnnotationVal(list[PhpAnnotation] items)
    | phpAnnotationVal(PhpAnnotation v)
;

/*
===========================================
Glagol to PHP Transformation --- Expressions
===========================================
*/

// Changed because of lack of string abstractions of built-in library functions
public str toLowerCaseFirstChar(str text) = text;

PhpExpr toPhpExpr(Expression expr) {
	switch(expr) {

		// literals
		case integer(int i): return phpScalar(phpInteger(i));
		case string(str s): return phpScalar(phpString(s));
		case boolean(bool b): return phpScalar(phpBoolean(b));

		// arrays
		case \list(list[Expression] items): {
		 list[PhpArrayElement] phpItems = [];
		 for (i <- items)
		 	phpItems = phpItems + [phpArrayElement(phpNoExpr(), toPhpExpr(i), false)];
		 return phpNew(phpName2(phpName("Vector")),
		            [phpActualParameter(phpArray(phpItems), false)]);
		 }

		case arrayAccess(Expression variable, Expression arrayIndexKey):
			return phpFetchArrayDim(toPhpExpr(variable), phpSomeExpr(toPhpExpr(arrayIndexKey)));
		case \map(map[Expression key, Expression \value] m): {
			list[PhpActualParameter] elements = [];
			for (k <- m)
				elements = elements +
							[phpActualParameter(phpNew(phpName2(phpName("Pair")),
					        	[phpActualParameter(toPhpExpr(k), false),
					        		phpActualParameter(toPhpExpr(m[k]), false)]), false)];
		    return phpStaticCall(phpName2(phpName("MapFactory")), phpName2(phpName("createFromPairs")), elements);
		}

		case get(artifact(str name)):
			return phpPropertyFetch(phpVar(phpName2(phpName("this"))), phpName2(phpName("_" + toLowerCaseFirstChar(name))));

		case variable(str name):
			return phpVar(phpName2(phpName(name)));

		case ternary(Expression condition, Expression ifThen, Expression \else):
			return phpTernary(toPhpExpr(condition), phpSomeExpr(toPhpExpr(ifThen)), toPhpExpr(\else));

		case new(str artifact, list[Expression] args): {
			list[PhpActualParameter] phpParams = [];
			for (arg <- args)
				phpParams = phpParams + [phpActualParameter(toPhpExpr(arg), false)];
			phpNew(phpName2(phpName(artifact)), phpParams);
		}

		// Binary operations
		case equals(Expression l, Expression r):
			return phpBinaryOperation(toPhpExpr(l), toPhpExpr(r), phpIdentical());
		case greaterThan(Expression l, Expression r):
			return phpBinaryOperation(toPhpExpr(l), toPhpExpr(r), phpGt());
		case product(Expression lhs, Expression rhs):
			return phpBinaryOperation(toPhpExpr(lhs), toPhpExpr(rhs), phpMul());
		case remainder(Expression lhs, Expression rhs):
			return phpBinaryOperation(toPhpExpr(lhs), toPhpExpr(rhs), phpMod());
		case division(Expression lhs, Expression rhs):
			return  phpBinaryOperation(toPhpExpr(lhs), toPhpExpr(rhs), phpDiv());
		case addition(Expression lhs, Expression rhs):
			return phpBinaryOperation(toPhpExpr(lhs), toPhpExpr(rhs), phpPlus());
		case subtraction(Expression lhs, Expression rhs):
			return phpBinaryOperation(toPhpExpr(lhs), toPhpExpr(rhs), phpMinus());
		case \bracket(Expression e):
			return phpBracket(phpSomeExpr(toPhpExpr(e)));
		case greaterThanOrEq(Expression lhs, Expression rhs):
			return phpBinaryOperation(toPhpExpr(lhs), toPhpExpr(rhs), phpGeq());
		case lessThanOrEq(Expression lhs, Expression rhs):
			return  phpBinaryOperation(toPhpExpr(lhs), toPhpExpr(rhs), phpLeq());
		case lessThan(Expression lhs, Expression rhs):
			return phpBinaryOperation(toPhpExpr(lhs), toPhpExpr(rhs), phpLt());
		case greaterThan(Expression lhs, Expression rhs):
			return phpBinaryOperation(toPhpExpr(lhs), toPhpExpr(rhs), phpGt());
		case equals(Expression lhs, Expression rhs):
			return phpBinaryOperation(toPhpExpr(lhs), toPhpExpr(rhs), phpIdentical());
		case nonEquals(Expression lhs, Expression rhs):
			return phpBinaryOperation(toPhpExpr(lhs), toPhpExpr(rhs), phpNotIdentical());
		case and(Expression lhs, Expression rhs):
			return phpBinaryOperation(toPhpExpr(lhs), toPhpExpr(rhs), phpLogicalAnd());
		case or(Expression lhs, Expression rhs):
			return phpBinaryOperation(toPhpExpr(lhs), toPhpExpr(rhs), phpLogicalOr());


		// Unary operations
		case negative(Expression e):
			return phpUnaryOperation(toPhpExpr(e), phpUnaryMinus());
		case positive(Expression e):
			return phpUnaryOperation(toPhpExpr(e), phpUnaryPlus());

		case invoke(str methodName, list[Expression] args): {
			list[PhpActualParameter] phpParams = [];
			for (arg <- args)
				phpParams = phpParams + [phpActualParameter(toPhpExpr(arg), false)];
			return phpMethodCall(phpVar(phpName2(phpName("this"))), phpName2(phpName(methodName)), phpParams);
		}

		case invoke2(Expression prev, str methodName, list[Expression] args): {
			list[PhpActualParameter] phpParams = [];
			for (arg <- args)
				phpParams = phpParams +  [phpActualParameter(toPhpExpr(arg), false)];

   			return phpMethodCall(toPhpExpr(prev), phpName2(phpName(methodName)), phpParams);
		}


		// Property fetch
		case fieldAccess(str name):
			return phpPropertyFetch(phpVar(phpName2(phpName("this"))), phpName2(phpName(name)));

		case fieldAccess2(Expression prev, str name):
			return phpPropertyFetch(toPhpExpr(prev), phpName2(phpName(name)));

		case this():
			return phpVar(phpName2(phpName("this")));

        case _: throw unsupported();
	};
}

