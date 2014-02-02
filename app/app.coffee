settings = require(__dirname + '/functions/config')
_ = require('underscore')
request = require('superagent')
exec = require('child_process').exec

express = require('express')
app = express()

fs = require('fs')
redis = require('redis')
client = redis.createClient()

client.select(settings.get("redis-database"), (err)->
	if err then console.log err
	)


getTasks = (cb)->
	client.lrange("tasks", 0, -1, (err,result)->
		if err then console.log err
		cb result
		)
	

addTask = (task, cb)->
	client.rpush("tasks", task.name, (err,result)->
		if err
			cb err
		else
			cb 200)

deleteTask = (task, cb)->
	client.lrem("tasks", 0, task.name, (err, result)->
		if err
			cb err
		else
			cb 200)


app.use(express.bodyParser())

app.get('/task', (req,res)->
	getTasks((escape)->
		res.send escape
		)
	)

app.post('/task', (req,res)->
    addTask(req.body,(escape)->
    	res.send escape)
    )

app.delete('/task', (req,res)->
	deleteTask(req.body, (escape)->
		res.send escape)
	)
















app.use(express.static(__dirname + '/public'));

port = settings.get("port")
app.listen(port)
console.log('Listening on port ' + port)