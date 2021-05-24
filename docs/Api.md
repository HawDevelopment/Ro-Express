
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

`App:METHOD(path: string, callback: (Request, Response) -> ())`

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

`App:Listen(name: string | number)`

Builds and Connects the current tree under ReplicatedStorage.

``` lua
local express = require(path.to.express)

local app = express.App()

app:get("/Method 1", function(req, res)
    
end)

app:Listen("Tree")
```

### `App:use`

`App:use(path: string, inst: Router | (Request, Response) -> ())`

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

`App:Destroy()`

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

`Request:param(index: string | number, default: any?)`

Returns the first arguments in the Body with given index, if none is found it returns the default param.

``` lua
local express = require(path.to.express)

local app = express.App()

app:get("/Method 1", function(req, res)
    pring(req:param("Player")) -- Prints the callers name
end)
```

## Response