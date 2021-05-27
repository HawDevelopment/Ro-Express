## Example Code

### Server - Client

Since Ro-Express is all about networking this shouldnt come as a suprise. But it can be hard to grasp for newcomers when starting out with the Module.
Heres some code that makes two methods, one to update money and a second to get money.

#### Server

``` lua
local express = require(path.to.express)

local app: App = express.App.new()

local Money = {}

app:get("/GetMoney", function(req: Request, res: Response)
	-- Response Status will defualt to 200, so we dont have to call it.
	res:send(Money[req.Player] or 0)
end)

app:post("/SetMoney", function(req: Request, res: Response)
	assert(req.Body, "Need a valid amount of Money to set!")
	Money[req.Player] = req.Body

	res:send("We set the Money!")
end)

app:Listen("MoneyTree")
```

#### Client
``` lua
local express = require(path.to.express)

local Return = express.Request.new("MoneyTree://GetMoney", "Get").Body

express.Request.new("MoneyTree://SetMoney", "Post", Return + 10)

print(express.Request.new("MoneyTree://GetMoney", "Get").Body) -- Prints 10
```

### Auth

