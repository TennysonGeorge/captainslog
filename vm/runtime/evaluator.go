package runtime

import (
	"errors"
	"fmt"

	"github.com/minond/captainslog/vm/lang"
	"github.com/minond/captainslog/vm/lang/parser"
)

func Eval(code string, env *Environment) ([]lang.Value, *Environment, error) {
	exprs, err := parser.Parse(code)
	if err != nil {
		return nil, env, err
	}

	var values []lang.Value
	for _, expr := range exprs {
		val, newEnv, err := eval(expr, env)
		env = newEnv
		if err != nil {
			return nil, env, err
		}
		values = append(values, val)
	}

	return values, env, nil
}

func eval(expr lang.Expr, env *Environment) (lang.Value, *Environment, error) {
	switch e := expr.(type) {
	case *lang.String:
		return e, env, nil
	case *lang.Boolean:
		return e, env, nil
	case *lang.Number:
		return e, env, nil
	case *lang.Identifier:
		val, err := env.Get(e.Label())
		return val, env, err
	case *lang.Sexpr:
		if e.Size() == 0 {
			return nil, env, errors.New("missing procedure expression")
		}

		return app(e, env)
	}

	return nil, env, errors.New("unable to handle expression")
}

func evalAll(exprs []lang.Expr, env *Environment) ([]lang.Value, *Environment, error) {
	vals := make([]lang.Value, len(exprs))
	for i, expr := range exprs {
		val, newEnv, err := eval(expr, env)
		env = newEnv
		if err != nil {
			return nil, env, err
		}

		vals[i] = val
	}

	return vals, env, nil
}

func app(expr *lang.Sexpr, env *Environment) (lang.Value, *Environment, error) {
	val, newEnv, err := eval(expr.Head(), env)
	env = newEnv
	if err != nil {
		return nil, env, err
	}

	fn, ok := val.(Applicable)
	if !ok {
		return nil, env, fmt.Errorf("not a procedure: %v", val)
	}

	return fn.Apply(expr.Tail(), env)
}
