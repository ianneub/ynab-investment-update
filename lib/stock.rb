require 'nokogiri'
require 'bigdecimal'

module Stock
	class Client
		include HTTParty

		def fund(symbol)
			puts "Looking for symbol #{symbol} ..."
			doc = Nokogiri::HTML(self.class.get("https://www.marketwatch.com/investing/fund/#{symbol.downcase}").body)
			
			# check for afterhours number
			after_hours = doc.css('.status--after')
			price = if after_hours.length > 0
				doc.css('.intraday__close td')[0].text.gsub('$','')
			else
				doc.css('.intraday__price > .value').text
			end

			date = Date.parse(doc.css('.timestamp__time > bg-quote').text)
			
			puts "Found price for #{symbol}: #{price}"
			{price: BigDecimal(price), date: date}
		end
	end
end
