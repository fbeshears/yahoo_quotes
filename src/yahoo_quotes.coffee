#yahoo_quotes.coffee

http = require 'http'
EventEmitter = require('events').EventEmitter

ISODateParser = require('iso_date_parser')



class PriceQuote
	constructor: (row) ->
		[@iso_date, open_price, high_price, low_price, close_price, volume, adj_close] = row
		@open_price 	= Number open_price
		@high_price 	= Number high_price
		@low_price 		= Number low_price
		@close_price 	= Number close_price
		@volume 			= Number volume
		@adj_close 		= Number adj_close		




class DividendQuote
	constructor: (row) ->
			[@iso_date, dividend] = row
			@dividend 	= Number dividend

	



class YahooQuotes extends EventEmitter


	constructor: (ticker, iso_start_date, iso_end_date, result_type='prices') ->
		###
		Get historical prices or dividends for the given ticker symbol.
		Returns a nested list of either prices or dividends depending on result_type.
		###	

		start_date 	= new ISODateParser(iso_start_date)
		end_date 		= new ISODateParser(iso_end_date)


		switch result_type
			when "prices"
				result_type_symbol = 'd'
			when 'weekly_prices'
				result_type_symbol = 'w'
			when "monthly_prices"
				result_type_symbol = 'm'
			when 'dividends'
				result_type_symbol = 'v'
			else
				throw new Error("cannot understand result_type #{result_type}")

		d = end_date.get_zero_based_month().toString()
		e = end_date.day.toString()
		f = end_date.year.toString()
		g = result_type_symbol
		a = start_date.get_zero_based_month().toString()
		b = start_date.day.toString()
		c = start_date.year.toString()

		hostname = "ichart.yahoo.com"
		url 	= "http://ichart.yahoo.com/"
		url_path		= "/table.csv?s=#{ticker}&"
		url_path		+= "d=#{d}&"
		url_path		+= "e=#{e}&"
		url_path		+= "f=#{f}&"
		url_path		+= "g=#{g}&"		
		url_path		+= "a=#{a}&"
		url_path		+= "b=#{b}&"
		url_path		+= "c=#{c}&"
		url_path		+= "ignore=.csv"

		options = {
			hostname
			port: 80
			path: url_path
			method: 'GET'
		}

		self = @
		data = ""
		request = http.get options, (res) ->
			res.on "data", (chunk) -> data += chunk
			res.on "error", (err) -> self.emit('error', err)
			res.on "end", -> 
				constructor = if result_type == "dividends" then DividendQuote else PriceQuote

				yahoo_rec_list = self.get_rec_list(ticker, data, constructor)

				if not yahoo_rec_list? or yahoo_rec_list.length == 0
					self.emit('data', [])

				else if result_type == 'dividends' and not self.valid_dividend_quote(yahoo_rec_list[0])
					self.emit('data', [])

				else if result_type != 'dividends' and not self.valid_price_quote(yahoo_rec_list[0])
					self.emit('data', [])

				else
					self.emit("data", yahoo_rec_list) 
			

	valid_price_quote: (quote) ->
		return false if not quote.iso_date
		date_array = quote.iso_date.split("-")
		return false if date_array.length != 3

		return false if not quote.volume
		return false if not isNumber(quote.volume)

		return true

	valid_dividend_quote: (quote) ->
		return false if not quote.iso_date
		date_array = quote.iso_date.split("-")
		return false if date_array.length != 3

		return false if not quote.dividend
		return false if not isNumber(quote.dividend)

		return true

	get_rec_list: (ticker, data, constructor) ->
		rec_list = []
		for csv_line in data.split("\n").slice(1)
			#trim whitespace
			csv_line.replace(/^\s+|\s+$/g,'')
			if csv_line != ''
				row = csv_line.split(",")
				r = new constructor(row)
				rec_list.push(r)

		rec_list.sort (a, b) -> 
			return  1 if a.iso_date > b.iso_date
			return -1 if a.iso_date < b.iso_date
			return 0

		return rec_list



isNumber = (n) ->
	return !isNaN(parseFloat(n)) and isFinite(n)


module.exports = YahooQuotes