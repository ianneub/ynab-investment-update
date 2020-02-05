require 'nokogiri'
require 'bigdecimal'

module Stock
	class Client
		include HTTParty

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
