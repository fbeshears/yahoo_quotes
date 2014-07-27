
async = require "async"

YahooQuotes             = require '../lib/yahoo_quotes'

ticker = 'ibm'

async.series {

  price_quotes:  (callback) ->
    #should default to daily prices
    #yq = new YahooQuotes(ticker,"2012-12-01", "2012-12-31")
    yq = new YahooQuotes(ticker,"2012-12-01", "2012-12-31", "prices")
    yq.on 'error', (err) -> callback err
    yq.on 'data', (yahoo_rec_list) -> callback null, yahoo_rec_list

    return


  dividends:  (callback) ->
    yq = new YahooQuotes(ticker,"2012-12-01", "2013-12-01", "dividends")
    yq.on 'error', (err) -> callback err
    yq.on 'data', (yahoo_rec_list) -> callback null, yahoo_rec_list

    return

  }
  , (err, results) ->
      throw err if err

      console.log "#{ticker} price quotes for one  month"
      for q in results.price_quotes
        console.log("%s,%s", q.iso_date, q.close_price)

      console.log "\n\n#{ticker} dividends for for one year"
      for q in results.dividends
        console.log("%s,%s", q.iso_date,  q.dividend)


      return

