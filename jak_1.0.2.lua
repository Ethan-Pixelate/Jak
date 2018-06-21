
io.close()
function ReadAll(file)
    local f = assert(io.input(file, "r"))
    local content = f:read("*a")
    return content
end


print("Enter file to run:")
io.flush()
local input = io.read()
print("Running file: " .. input .. "\n\n")
local code = ReadAll(input)
input = nil
--[[
  ==QUICK REFERENCE==
  
  display
    <text>
    
    prints text in the console
    
  setInstance
    <name of instance>
    <value>
    
    creates a variable or sets it
    
  destroyInstance
    <instance>
    
      destroys instance, only recommended for temporary instances
    
  screen
    <amount of lines>
    <...>
    
    prints multiple line of text in the console
    
  incInstance
    <instance>
    <amount>
    
    increments the instance if it is a number
  
  decInstance
    <instance>
    <amount>
    
    decrements the instance if it is a number
    
  concactInstance
    <instance>
    <string 1>
    <string 2>
    
    sets the instance to the concactenation of string 1 and 2
    
  substringInstance
    <instance>
    <string>
    <from>
    <to>
    
    sets the instance to the substring of the string from "from" to "to"
  
  goto
    <line>
    
    skips to a line of code (can go backwards)
    
  fermata
  
    small delay, equivilent to wait() in lua
    
  delay
    <seconds>
    
    delays the code in seconds
  
  subtractInstance
    <instance>
    <value 1>
    <value 2>
    
    sets the instance to value 1 - value 2, created because decInstance can only decrement
    
  multiplyInstance
    <instance>
    <value 1>
    <value 2>
    
    sets the instance to value 1 * value 2
    
  divInstance
    <instance>
    <value 1>
    <value 2>
    
    sets the instance to value 1 / value 2
    
  sqrtInstance
    <instance>
    <value>
    
    sets the instance to the square root of value
    
  powerInstance
    <instance>
    <value 1>
    <value 2>
    
    sets instance to value 1 ^ value 2
    
  lerpInstance
    <instance>
    <a>
    <b>
    <t>
    
    sets instance to the lerp of t between a and b
    
  logInstance
    <instance>
    <value>
    
    sets instance to the log of value
    
  sinInstance
    <instance>
    <value>
    
    sets instance to the sine of value
    
  cosInstance
    <instance>
    <value>
    
    sets instance to the cosine of value
    
  tanInstance
    <instance>
    <value>
    
    sets instance to the tangent of value
    
  close
  
    stops the code
  
  negateInstance
    <instance>
    <value>
    
    negates the instance
    
  absInstance
    <instance>
    <value>
    
    sets instance to the absoloute value of value
    
  floorInstance
    <instance>
    <value>
    
    sets instance to the floor of value
    
  ceilInstance
    <instance>
    <value>
    
    sets instance to the ceiling of value
  
  gotomark
    <a>
    
    if a with ":"s surrounding it then the interpereter skips to the line that :a: is on
  random
    <instance>
    <min>
    <max>
    
    sets instance to a random value between min and max
  
  ranseed
    <seed>
    
    sets the psuedorandom algorithim's seed
--]]

--=================================================================================================================

--interpereter written by Ethan Pixelate

local instances = {
  pi = math.pi,
  huge = math.huge,
  version = 1.0
}
local lines = {}
local check = 1
local running = true

function wait(seconds)
  local s
  if seconds then
    s = seconds
  else
    s = 0.015
  end
  local current = os.time()
  while os.time() - current < s do end
end

function TokenizeValue(value)
  local finalvalue = ""
  if string.sub(tostring(value), 1, 1) == "~" then
    finalvalue = instances[string.sub(tostring(value), 2, string.len(value))]
    if tonumber(finalvalue) ~= nil then
      return tonumber(finalvalue)
    end
    return finalvalue
  else
    if tonumber(value) ~= nil then
      return tonumber(value)
    end
    return value
  end
end

function TokenizeValueComparison(v1, v2, operator)
  local a,b = TokenizeValue(v1),TokenizeValue(v2)
  if operator == "=" then
    if a == b then return true else return false end
  end
  if operator == ">" then
    if a > b then return true else return false end
  end
  if operator == "<" then
    if a < b then return true else return false end
  end
  if operator == ">=" then
    if a >= b then return true else return false end
  end
  if operator == "<=" then
    if a <= b then return true else return false end
  end
  if operator == "not=" then
    if a ~= b then return true else return false end
  end
  error("unknown operator: " .. operator)
end

function TokenizeBoolComparison(a, b, operator)
  local newa
  local newb
  if a == "true" then
    newa = true
  end 
  if a == "false" then
    newa = false
  end 
  if b == "true" then
    newb = true
  end 
  if b == "false" then
    newb = false
  end 
  
  if operator == "not" then
    return not newb
  end 
  if operator == "and" then
    if newa and newb then return true else return false end
  end
  if operator == "or" then
    if newa or newb then return true else return false end
  end
end

function TokenizeFullCondition(t)
  local arg = t
  local latest = true
  for i=1,#arg,1 do
    if arg[i] == ">" or arg[i] == "<" or arg[i] == "=" or arg[i] == "not=" or arg[i] == "<=" or arg[i] == ">=" then
      local tokenization = TokenizeValueComparison(TokenizeValue(arg[i-1]), TokenizeValue(arg[i+1]), arg[i])
      latest = latest and tokenization
      table.remove(arg, i)
      table.remove(arg, i)
      table.remove(arg, i-1)
      table.insert(arg, i-1, tokenization)
    end
    if (arg[i] == "and" or arg[i] == "or" or arg[i] == "not") and type(arg[i-1]) == "boolean" and type(arg[i+1]) == "boolean" then
      latest = latest and TokenizeBoolComparison(arg[i-1], arg[i+1], arg[i])
    end
  end
  return latest
end

function StringToTable(s)
  local t = {}
  local current = ""
  for i=1,string.len(s),1 do
    if string.sub(s,i,i) == "\n" or string.sub(s,i,i) == "|" then
      table.insert(t, current)
      current = ""
    else
      current = current .. string.sub(s,i,i)
    end
  end
  return t
end

code = StringToTable(code)
while running do
  if code[check] == "gotomark" then
    check = check + 1
    for i=1,#code,1 do
      if ":"..code[i]..":" == code[check] and i ~= check then
        check = i
      end
    end
  end
  if code[check] == "fermata" then
    wait()
  end
  if code[check] == "delay" then
    wait(TokenizeValue(code[check+1]))
    check = check + 1
  end
  if code[check] == "newInstance" then
    instances[code[check+1]] = TokenizeValue(code[check+2])
    check = check + 2
  end
  if code[check] == "newInstance" then
    math.randomseed(TokenizeValue(code[check+1]))
    check = check + 1
  end
  if code[check] == "display" then
    check = check + 1
    print(TokenizeValue(code[check]))
  end
  if code[check] == "screen" then
    check = check + 1
    local LinesToRun = TokenizeValue(code[check])
    for i=1,LinesToRun,1 do
      check = check + 1
      print(TokenizeValue(code[check]))
    end
  end
  if code[check] == "incInstance" then
    instances[code[check+1]] = instances[code[check+1]] + TokenizeValue(code[check+2])
    check = check + 2
  end
  if code[check] == "destroyInstance" then
    instances[code[check+1]] = nil
    check = check + 1
  end
  if code[check] == "decInstance" then
    instances[code[check+1]] = instances[code[check+1]] - TokenizeValue(code[check+2])
    check = check + 2
  end
  if code[check] == "substringInstance" then
    instances[code[check+1]] = string.sub(instances[code[check+2]],instances[code[check+3]],instances[code[check+4]])
    check = check + 4
  end
  if code[check] == "subtractInstance" then
    instances[code[check+1]] = TokenizeValue(code[check+2]) - TokenizeValue(code[check+3])
    check = check + 3
  end
  if code[check] == "multiplyInstance" then
    instances[code[check+1]] = TokenizeValue(code[check+2]) * TokenizeValue(code[check+3])
    check = check + 3
  end
  if code[check] == "divInstance" then
    instances[code[check+1]] = TokenizeValue(code[check+2]) / TokenizeValue(code[check+3])
    check = check + 3
  end
  if code[check] == "concactInstance" then
    instances[code[check+1]] = TokenizeValue(code[check+2]) .. TokenizeValue(code[check+3])
    check = check + 3
  end
  if code[check] == "sqrtInstance" then
    instances[code[check+1]] = math.sqrt(TokenizeValue(code[check+2]))
    check = check + 2
  end
  if code[check] == "sinInstance" then
    instances[code[check+1]] = math.sin(TokenizeValue(code[check+2]))
    check = check + 2
  end
  if code[check] == "cosInstance" then
    instances[code[check+1]] = math.cos(TokenizeValue(code[check+2]))
    check = check + 2
  end
  if code[check] == "tanInstance" then
    instances[code[check+1]] = math.tan(TokenizeValue(code[check+2]))
    check = check + 2
  end
  if code[check] == "powerInstance" then
    instances[code[check+1]] = TokenizeValue(code[check+2])^TokenizeValue(code[check+3])
    check = check + 3
  end
  if code[check] == "lerpInstance" then
    instances[code[check+1]] = (1-TokenizeValue(code[check+4])) * TokenizeValue(code[check+2]) + TokenizeValue(code[check+4]) * TokenizeValue(code[check+3])
    check = check + 4
  end
  if code[check] == "negateInstance" then
    instances[code[check+1]] = 0-TokenizeValue(code[check+2])
    check = check + 2
  end
  if code[check] == "absInstance" then
    instances[code[check+1]] = math.abs(TokenizeValue(code[check+2]))
    check = check + 2
  end
  if code[check] == "floorInstance" then
    instances[code[check+1]] = math.floor(TokenizeValue(code[check+2]))
    check = check + 2
  end
  if code[check] == "ceilInstance" then
    instances[code[check+1]] = math.ceil(TokenizeValue(code[check+2]))
    check = check + 2
  end
  if code[check] == "random" then
    instances[code[check+1]] = math.random(TokenizeValue(code[check+2]), TokenizeValue(code[check+3]))
    check = check + 3
  end
  if code[check] == "goto" then
    check = TokenizeValue(code[check+1])-1
  end
  if code[check] == "is" then
    local fullcondition = {}
    check = check + 1
    while code[check] ~= "?" do
      table.insert(fullcondition, code[check])
      check = check + 1
    end
    if TokenizeFullCondition(fullcondition) then
      check = TokenizeValue(code[check+1])
    else
      check = check + 1
      if code[check+1] == "else" then
        check = TokenizeValue(code[check+2])
      end
    end
  end
  if code[check] == "close" then
    running = false
  end
  check = check + 1
end