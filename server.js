var _mysql = require('mysql');

var HOST = "192.241.251.59";
var PORT = 3306;
var MYSQL_USER = "pnp_user";
var MYSQL_PASS = "telegram312";
var DATABASE = "telegram_db";
var TABLE = 'news';

var http = require('http');
var url = require('url');
var querystring = require('querystring');
var swig  = require('swig');

function accept(req, res) {

  res.writeHead(200, {
    'Content-Type': 'text/html',
    'Cache-Control': 'no-cache'
  });
  
  get_data(res);

}

http.createServer(accept).listen(8181);

function get_data(res) {
	var mysql = _mysql.createConnection({
	    host: HOST,
	    user: MYSQL_USER,
	    password: MYSQL_PASS,
	});
	mysql.query('use ' + DATABASE);

	var query = 'select news_url, news_predicted, news_real, news_date from news where news_date > "' + get_days_ago(1) + ' 00:00"  order by news_url, news_predicted desc'

	mysql.query(query,
	function(err, result, fields) {
	    if (err) throw err;
	    else {

	    	var result_array = [];


	        for (var i in result) {
	            var value = result[i];
	            if (value.news_url.length > 45)
	            	value["link"] = value.news_url.substr(0, 45) + "...";
	            else
	            	value["link"] = value.news_url;

	            result_array.push(value);
	        }
	    }
	    
	    var text = swig.renderFile('templates/template.html', {
		  data: result_array
		});
		res.write(text);
		
		res.end();

	});

}

function get_days_ago(days) {
	var today = new Date();
	today.setDate(today.getDate() - days);
	var dd = today.getDate();
	var mm = today.getMonth()+1; //January is 0!
	var yyyy = today.getFullYear();

	if(dd<10) {
	    dd='0'+dd
	} 

	if(mm<10) {
	    mm='0'+mm
	} 

	today = yyyy+"-"+mm+'-'+dd;

	return today;
}
