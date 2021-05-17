local express = require(game:GetService("ReplicatedStorage").express)
local App = express.App

return function()
	describe("App.new", function()
		it("should return a valid app", function()
			local app = App.new()
			expect(app).to.be.a("table")
		end)

		it("should have all the components of an app", function()
			local app = App.new()
			expect(app._methods).to.be.a("table")
			expect(app._newitem.Classname).to.be.equal("Signal")
			app:Destroy()
		end)
	end)

	describe("App:Listen", function()
		it("should return a folder", function()
			local app = App.new()
			expect(typeof(app:Listen("ShouldReturnInstance"))).to.be.equal("Instance")

			app = App.new()
			expect(app:Listen("ShouldReturnFolder"):IsA("Folder")).to.be.ok()
			app:Destroy()
		end)

		it("should make a tree of remotes", function()
			local app = App.new()

			app:get("/Test1", function()
				print("Hello World!")
			end)

			app:get("/Test2", function()
				print("Foo Bar Baz")
			end)

			app:get("/Test3", function()
				print("Why do I even try?")
			end)

			app:Listen("ShouldMakeTree")
			expect(#app._root:GetDescendants() > 2).to.be.ok()
			app:Destroy()
		end)
	end)

	describe("App:Method", function()
		local app = App.new()

		it("should handle a get request", function()
			expect(function()
				app:get("/", function()
					print("Hello World!")
				end)
			end).never.to.be.throw()
		end)

		it("should throw when given wrong arguments", function()
			expect(function()
				app:get(nil, 10)
			end).to.be.throw()
		end)

		it("should build succesfuly", function()
			expect(function()
				app:Listen("ShouldBuild")
			end).never.to.be.throw()
		end)

		app:Destroy()
	end)

	describe("App:use", function()
		it("should build with out problems", function()
			local app = App.new()

			expect(function()
				app:get("/Test", function()
					print("Hello World!")
				end)

				app:use("/Test", function()
					print("Middleware!")
				end)

				app:Listen("AppUseShouldNotError")
				app:Destroy()
			end).to.never.be.throw()
		end)

		it("should have all the components necesary", function()
			local app = App.new()

			app:get("/Test", function()
				print("Hello World!")
			end)

			local router = app:use("/Test", function()
				print("Middleware!")
			end)

			expect(router).to.be.an("table")
			expect(router._path).to.be.an("string")
			expect(router._router).to.be.an("function")
		end)
	end)
end
