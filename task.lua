box.cfg{}

box.once('schema', function()
	box.schema.create_space('task')
	box.space.hosts:create_index('primary', { type = 'hash',
    	parts = {1, 'str'} })
end)


local function insertKV(req)
	--POST
	local key = req:body('key')
	local val = req:body('value')
 	if not key or not val then
    return {
      status = 400,
      body = json.encode({message = 'Incorrect body'})
    }end
	if box.get{key} then
		return {
			status = 409,
      		body = json.encode({message = 'Key already exists'})
		}end

	box.insert{key,val}
  end

local function insertV(req)
	--PUT
	local key = req:body('key')
	local val = req:body('value')
 	if not val or not key then
		--not Key isn't need in task but it's more correct to verify it
    return {
      status = 400,
      body = json.encode({message = 'Incorrect body'})
    } end
	if not box.get{key} then
		return {
			status = 404,
      		body = json.encode({message = 'No key'})
		}end

	box.update{key,val}
  end

local function geter(req)
	--GET
	local key = req:body('key')
	local val = req:body('value')
 	--if not val  or not key then
    --return {
     -- status = 400,
     -- body = json.encode({message = 'Incorrect body'})
    --} end
	if not box.get{key} then
		return {
			status = 404,
      		body = json.encode({message = 'No key'})
		}end

	box.get{key}
  end

local function deleter(req)
	--DELETE
	local key = req:body('key')
	if not box.get{key} then
		return {
			status = 404,
      		body = json.encode({message = 'No key'})
		}end

	box.delete(key)
  end


local httpd = require('http.server')
local server = httpd.new('127.0.0.1', 8080)
server:route({ path = '/objects', method = 'POST' }, insertKV)
server:route({ path = '/objects', method = 'PUT' },insertV )
server:route({ path = '/objects', method = 'GET' }, geter)
server:route({ path = '/objects', method = 'DELETE' }, deleter)

server:start()
