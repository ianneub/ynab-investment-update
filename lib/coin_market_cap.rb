require 'httparty'

module CoinMarketCap
	class Client
		include HTTParty

		base_uri 'https://pro-api.coinmarketcap.com/v1'
		# debug_output $stderr
		headers 'Content-Type' => 'application/json'
		headers 'X-CMC_PRO_API_KEY' => ENV['COINMARKETCAP_KEY']

		def quotes(symbols:'BTC,XRP,ETH,BCH,MIOTA,LTC,GLM,DGB,DOGE')
			self.class.get('/cryptocurrency/quotes/latest', query: { symbol: symbols }).parsed_response
		end
	end
end
