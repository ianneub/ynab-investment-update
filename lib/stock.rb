require 'nokogiri'
require 'bigdecimal'

module Stock
  class Client
    include HTTParty

    headers({
      'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 11_2_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.72 Safari/537.36'
    })

    def fund(symbol)
      puts "Looking for symbol #{symbol} ..."
      data = self.class.get("https://query1.finance.yahoo.com/v8/finance/chart/#{symbol.upcase}?region=US&lang=en-US&includePrePost=false&interval=1d&range=1mo&corsDomain=finance.yahoo.com&.tsrc=finance").parsed_response

      price = data['chart']['result'].first['meta']['regularMarketPrice']

      date = Time.at(data['chart']['result'].first['meta']['regularMarketTime'])

      puts "Found price for #{symbol}: #{price}"
      {price: BigDecimal(price.to_s), date: date}
    end
  end
end
