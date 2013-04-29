--[[
--
-- Copyright (c) 2013 Wilson Kazuo Mizutani
--
-- This software is provided 'as-is', without any express or implied
-- warranty. In no event will the authors be held liable for any damages
-- arising from the use of this software.
--
-- Permission is granted to anyone to use this software for any purpose,
-- including commercial applications, and to alter it and redistribute it
-- freely, subject to the following restrictions:
--
--    1. The origin of this software must not be misrepresented; you must not
--       claim that you wrote the original software. If you use this software
--       in a product, an acknowledgment in the product documentation would be
--       appreciated but is not required.
--
--    2. Altered source versions must be plainly marked as such, and must not be
--       misrepresented as being the original software.
--
--    3. This notice may not be removed or altered from any source
--       distribution.
--
--]]

--- LUX's functional programming module.
-- Some functional programming tools lay around here.
module ("lux.functional", package.seeall) do

  --- Binds a function's first parameter to the given argument.
  -- @param f   The function being binded.
  -- @param arg The bound argument.
  -- @return A function that, upon being called, does the same as f, but
  --         requires only the arguments beyond the first one.
  function bindfirst (f, arg)
    local up = arg
    return function (...)
      return f(up, ...)
    end
  end

  --- Binds a function to the given (left-most) arguments.
  -- The arguments must be passed in the apropriate order, according to the
  -- function's specification.
  -- @param f     The function being binded.
  -- @param arg1  The first bound argument.
  -- @param ...   The remaining bound arguments, in order.
  -- @return A function that, upon being called, does the same as f, but
  --         requires only the remaining right-most arguments that were not
  --         binded with it.
  function bindleft (f, arg1, ...)
    if select('#', ...) == 0 then
      return bindfirst(f, arg1)
    else
      return bindleft(bindfirst(f, arg1), ...)
    end
  end

  --- Creates a <code>n</code>-chained function based on <code>f</code>.
  -- <p>
  --  Chained functions receive their arguments in consecutive calls. For
  --  instance, if <code>f</code> was the usual <code>print</code> and
  --  <code>n</code> was 1, you would use the resulting function like this:
  -- </p>
  -- <p><code>
  -- local result = chain(print,1)
  -- </code></p>
  -- <p><code>
  -- result (arg1) (arg2, arg3, ...)
  -- </code></p>
  -- <p>
  --  And if <code>n</code> was 2, then the call would be:
  -- </p>
  -- <p><code>
  -- result (arg1) (arg2) (arg3, arg4, ...)
  -- </code></p>
  -- <p>
  --  And so on.
  -- </p>
  -- @param f The function being chained.
  -- @param n The size of the chain.
  -- @return An <code>n</code>-chained function version of <code>f</code>.
  function chain (f, n)
    n = n or 1
    return function (...)
      local first, second = ...
      if n >= 1 and not second then
        if first then
          return chain(bindleft(f, first), n-1)
        else
          return chain(f, n)
        end
      else
        return f(...)
      end
    end
  end

end

