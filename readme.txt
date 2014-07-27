readme.txt

Async download of stock or dividend quotes from yahoo finance.

----------------------------------
Example of usage in coffeescript:

YahooQuotes = require 'yahoo_quotes'

yq = new YahooQuotes("ibm", "2012-12-01", "2012-12-31", "prices")

yq.on 'error', (err) -> throw err

yq.on 'data', (yahoo_rec_list) -> 
  for q in yahoo_rec_list
    console.log("%s,%s", q.iso_date, q.close_price)


----------------------------
In the above example, yahoo_rec_list is an array of objects. Each object
has the following fields: iso_date, open_price, high_price, low_price, 
close_price, volume, and adj_close.

When used to fetch dividends, each object will have two fields: iso_date and dividend.


The arguments to YahooQuotes are: ticker, iso_start_date, iso_end_date, result_type.

The result_type field defaults to 'prices', which stands for daily price quotes. 
Other valid values are: weekly_prices, monthly_prices, and dividends.
