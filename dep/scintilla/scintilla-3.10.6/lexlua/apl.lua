-- Copyright 2015-2019 David B. Lamkins <david@lamkins.net>. See License.txt.
-- APL LPeg lexer.

local lexer = require('lexer')
local token, word_match = lexer.token, lexer.word_match
local P, R, S = lpeg.P, lpeg.R, lpeg.S

local lex = lexer.new('apl')

-- Whitespace.
lex:add_rule('whitespace', token(lexer.WHITESPACE, lexer.space^1))

-- Comments.
lex:add_rule('comment', token(lexer.COMMENT, (P('⍝') + '#') *
                                             lexer.nonnewline^0))

-- Strings.
local sq_str = lexer.delimited_range("'", false, true)
local dq_str = lexer.delimited_range('"')
lex:add_rule('string', token(lexer.STRING, sq_str + dq_str))

-- Numbers.
local dig = R('09')
local rad = P('.')
local exp = S('eE')
local img = S('jJ')
local sgn = P('¯')^-1
local float = sgn * (dig^0 * rad * dig^1 + dig^1 * rad * dig^0 + dig^1) *
              (exp * sgn *dig^1)^-1
lex:add_rule('number', token(lexer.NUMBER, float * img * float + float))

-- Keywords.
lex:add_rule('keyword', token(lexer.KEYWORD, P('⍞') + 'χ' + '⍺' + '⍶' + '⍵' +
                                             '⍹' + '⎕' * R('AZ', 'az')^0))

-- Names.
local n1l = R('AZ', 'az')
local n1b = P('_') + '∆' + '⍙'
local n2l = n1l + R('09')
local n2b = n1b + '¯'
local n1 = n1l + n1b
local n2 = n2l + n2b
local name = n1 * n2^0

-- Labels.
lex:add_rule('label', token(lexer.LABEL, name * ':'))

-- Variables.
lex:add_rule('variable', token(lexer.VARIABLE, name))

-- Special.
lex:add_rule('special', token(lexer.TYPE, S('{}[]();') + '←' + '→' + '◊'))

-- Nabla.
lex:add_rule('nabla', token(lexer.PREPROCESSOR, P('∇') + '⍫'))

return lex
