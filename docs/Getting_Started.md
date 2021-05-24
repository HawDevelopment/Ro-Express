
# Getting Started

Ro-Express syntax is based on [express-js](https://expressjs.com). In Ro-Express all Instances in a tree, has at least one Htpp method attached to it. This makes it easy to categorise Remotes.

Heres what a normal Ro-Express tree:

Tree


* Method 1 (GET)
    * Method 2 (DELETE)
* Method 3 (POST)

We can make something like that with this code:

``` lua
local express = require(game:GetService("ReplicatedStorage").express)

local app = express.App.new()

app:get("/Method 1", function(req, res)

end)

app:delete("/Method 2", function(req, res)

end)

app:post("/Method 2", function(req, res)

end)

app:Listen("Tree")
```

Now when any request to the Remotes is made, it will call its coresponding function.s
## Request and Response

You can use Request to get all the incoming data from the caller, and use Response to specify the response data.

``` lua
local express = require(game:GetService("ReplicatedStorage").express)

local app = express.App.new()

app:get("/Method 1", function(req, res)
    
    local args = req.Body -- the incoming data (a table)
    local method = req.Method -- the call type (GET, POST, DELETE etc.)
    local path = req.Path -- the call path (/Method 1)
    
    -- you can use :Param to get things from the body
    local Player = req:param("Player") or args[1] 
    
    -- using response we can send data back.
    -- You should always send a status!
    res:status(200):send(Player.Name or "")
end)

app:Listen("Tree")
```
Now when the client makes a request to Method 1 it we get its name!

## Middleware

Middleware is a function, that get called before the method attached to the path does.
A Middleware function can also change or skip the current request.

``` lua
local express = require(game:GetService("ReplicatedStorage").express)

local app = express.App.new()

app:get("/Method 1", function(req, res)
    
    local Player = req:param("Player") or args[1] 
    
    res:status(200):send(Player.Name or "")
end)

-- This middleware will be called for all underlying methods
app:use("/", function(req, res)
    
    req.Body["Hello"] = "World!"
    
    -- this locks the current response or "skips" it as its called.
    res:send("Hello World!")
    res:done() 
end)

app:Listen("Tree")
```
When we call any Method it will always return "Hello World!".