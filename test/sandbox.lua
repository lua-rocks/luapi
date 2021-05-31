local block = [[
Extract lines started with tags > or <

line 1
>line 2
line 3
> line 4
line 5
< line 6
< line 7
line > 8
line < 9
line <10>

I need to extract lines 2, 4, 6 and 7
]]

for tag, line in block:gmatch('\n([><])%s?(%C+)') do
  print(tag, line)
end
