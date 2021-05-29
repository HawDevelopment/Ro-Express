# Ro-Express

Expressjs like Networking module that makes it easier to write and organise code.

Read the [documentation](https://hawdevelopment.github.io/Ro-Express/) for more info.

---

Ro-Express allows you to register methods to a path, and then attaching middleware to paths. It helps clear up complex structures to nice trees of remotes. When requesting data you get a status back to easily check what when right and wrong.

``` lua
local express = require(game:GetService("ReplicatedStorage").express)

local app = express()

-- Registering a GET method
app:get("/GetHugs", function(request, response)
    
    local name = request.Player.Name
    if name == "Sleitnick" or name == "Elttob" then
        response:status(200):send("Hugs 🤗")
    end
end)

-- Attaching middleware to the GET method
app:use("/GetHugs", function(request, response)
    
    local name = request.Player.Name
    if name == "HawDevelopment" then
        response:status(401):send("Not Authorized!")
    end
end)

app:Listen("Hugs")
``` 

When Requesting data it will return a nice table with all your needs.

``` lua
local express = require(game:GetService("ReplicatedStorage").express)

local Return = express.Request("Hugs://GetHugs", "GET")

-- (If you are cool)
print(Return) -> {
    Succes = true,
    Status = 200,
    Body = "Hugs 🤗"
}
```