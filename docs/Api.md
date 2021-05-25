
## App

The app is the way you register Methods and create Middleware, it also builds the finale tree of Remotes.

An app can be made like this:

``` lua
local express = require(path.to.express)

local app1 = express.App()

-- Or

local app2 = express.App.new()
```

### `Get, Post, Delete, Put`

`App:METHOD(path: string, callback: (Request, Response) -> ()): void`

Registers a callback with a type to the specified path.

``` lua
local express = require(path.to.express)

local app = express.App()

app:get("/Method 1", function(req, res)
    
end)

app:post("/Method 2", function(req, res)
    
end)

app:delete("/Method 3", function(req, res)
    
end)

app:put("/Method 4", function(req, res)
    
end)
```

### `App:Listen`

`App:Listen(name: string | number): Instance`

Builds and Connects the current tree under ReplicatedStorage.
Returns the top Instance of the Remote tree.

``` lua
local express = require(path.to.express)

local app = express.App()

app:get("/Method 1", function(req, res)
    
end)

app:Listen("Tree")
```

### `App:use`

`App:use(path: string, inst: Router | (Request, Response) -> ()): void`

Uses the given Middleware, and connects underlying instances to it.
When the Method is called, any Middleware attached to it will be called first. For more information look [here](./Getting_Started/#middleware).

``` lua
local express = require(path.to.express)

local app = express.App()

app:get("/Method 1", function(req, res)
    
end)

app:use("/Method 1", function(req, res)

end)
```

### `App:Destroy`

`App:Destroy(): void`

Destroys the app, and the remote tree if built.

``` lua
local express = require(path.to.express)

local app = express.App()

app:get("/Method 1", function(req, res)
    
end)

app:Listen("Tree")

app:Destroy()
```

!!! warning
    Expect it not to clean everything up, as im still working on new features.

## Request

### `Request.Body`

`Request.Body: {[any]: any}`

All the args given from the caller.

``` lua
local express = require(path.to.express)

local app = express.App()

app:get("/Method 1", function(req, res)
    print(req.Body) -- Prints all the arguments given
end)
```

### `Request.Method`

`Request.Method: string`

The request Method, eg. GET, POST, DELETE, and PUT.

``` lua
local express = require(path.to.express)

local app = express.App()

app:get("/Method 1", function(req, res)
    pring(req.Method) -> "GET"
end)
```

### `Request.Path`

`Request.Path: string`

``` lua
local express = require(path.to.express)

local app = express.App()

app:get("/Method 1", function(req, res)
    pring(req.Path) -> "/Method 1"
end)
```

### `Request:param`

`Request:param(index: string | number, default: any?): any`

Returns the first arguments in the Body with given index, if none is found it returns the default param.

``` lua
local express = require(path.to.express)

local app = express.App()

app:get("/Method 1", function(req, res)
    pring(req:param("Player")) -- Prints the callers name
end)
```

## Response

### `Response.Locals`

`Response.Locals: {[any]: any}`

Serves as a way to share variables between Middleware.

``` lua
local express = require(path.to.express)

local app = express.App()

app:get("/Method 1", function(req, res)
    pring(res.Locals[1]) -> "Hello World"
end)

app:use("/Method 1", function(req, res)
    res.Locals[1] = "Hello World"
end)
```

!!! warning
    Locals can be changed by any Middlware

### `Response:send`

`Response:send(...any): Response`

Sets the Response value to the given arguments.
Can be chained.

``` lua
local express = require(path.to.express)

local app = express.App()

app:get("/Method 1", function(req, res)
    -- The caller will get "Hello World" back
    res:send("Hello World")
end)
```

!!! warning
    `Response:send` can be called from any Middleware

### `Response:status`

`Response:status(status: number): Response`

Sets the status of the Response to the given number.
Can be chained.

``` lua
local express = require(path.to.express)

local app = express.App()

app:get("/Method 1", function(req, res)
    -- The caller will get the status 200 back
    res:status(200)
end)
```

!!! warning
    `Response:status` can be called from any Middleware

### `Response:done`

`Response:done(): Response`

Locks the Response so any changes will not happen.
Can be chained.

``` lua
local express = require(path.to.express)

local app = express.App()

app:get("/Method 1", function(req, res)
    -- The caller will get the status 200 back
    res:status(200):send("Hello World")
    
    res:done()
    
    -- It will still return "Hello World" with status 200
    res:send("Foo Bar Baz")
end)
```

!!! warning
    `Response:done` can be called from any Middleware