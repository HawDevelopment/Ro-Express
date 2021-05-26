
## Basics

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

Apps or "Trees" can be made on the server and client.
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
Now when the client makes a GET request to Method 1 it we get its name!

### Making a Request

Using the Request class you can make request to paths and trees.


When making a Request you will need:


* The URL, with tree name and path. So something like `Tree://Method 1`.
* The method. (GET, POST, DELETE, )
* Arguments.

``` lua
-- Server
local express = require(game:GetService("ReplicatedStorage").express)

local app = express.App.new()

app:get("/Method 1", function(req, res)
    
    res:status(200):send("Hello World!")
end)

app:Listen("Tree")
-- Client
local express = require(game:GetService("ReplicatedStorage").express)

local Return = express.Request("Tree://Method 1", "GET")

print(Return.Body) -> "Hello World!"
print(Return.Succes) -> true
print(Return.Status) -> 200
```



## Middleware

Middleware is a function, that get called before the method attached to the path does.
A Middleware function can also change or skip the current request.

``` lua
local express = require(game:GetService("ReplicatedStorage").express)

local app = express.App.new()

-- create our method
app:get("/Method 1", function(req, res)
    
    local Player = req:param("Player") or args[1] 
    
    res:status(200):send(Player.Name or "")
end)

-- This middleware will first be called and then the function for the method
app:use("/Method 1", function(req, res)
    
    res:send("Hello World!")
    
    -- this locks the current response or "skips" it as its called.
    res:done() 
end)

app:Listen("Tree")
```
When we call any Method it will always return "Hello World!".

### Execution Model

When requesting Ro-Express Execution Model looks like this:

* Call any parent middleware.
* Call path middleware.
* Call the ALL method for that path. (If exists)
* Call the path's method functions.
