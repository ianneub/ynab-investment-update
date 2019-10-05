require 'httparty'
require 'json'
require 'bigdecimal'
require 'time'
require 'pry'

require_relative 'lib/ynab'
require_relative 'lib/coin_market_cap'

$stdout.sync = true
$stderr.sync = true

ynab = Ynab::Client.new(ENV['YNAB_API_KEY'], ENV['YNAB_BUDGET_ID'], ENV['YNAB_ACCOUNT_ID'])
coin = CoinMarketCap::Client.new

portfolio = Hash.new
portfolio['BTC'] = BigDecimal.new('9.24787508')
portfolio['XRP'] = BigDecimal.new('6978')
portfolio['ETH'] = BigDecimal.new('5.96235401')
portfolio['BCH'] = BigDecimal.new('3.74861132')
portfolio['MIOTA'] = BigDecimal.new('292.407586')
portfolio['LTC'] = BigDecimal.new('3.995526830')
portfolio['GNT'] = BigDecimal.new('500')
portfolio['DGB'] = BigDecimal.new('3834')
portfolio['DOGE'] = BigDecimal.new('15034.93572965')

# get current time
now = Time.now
this_month = Time.new(now.year, now.month, 1)
puts "Starting run now: #{now} this_month: #{this_month} ..."

# current balance in ynab
balance = BigDecimal.new(ynab.account['balance']) / 1000
puts "Previous YNAB balance: #{balance.round(2).to_s('F')}"

# get quotes from coinmarketcap
quotes = {}
coin.quotes.each do |quote|
	quotes[quote['symbol']] = BigDecimal.new(quote['price_usd'])
end

# calculate portfolio value
value = BigDecimal.new(0.0, 2)
portfolio.each do |symbol, qty|
	raise "Cannot find quote for #{symbol}" unless quotes.include?(symbol)
	value += quotes[symbol] * qty
end
puts "Portfolio value: #{value.round(2).to_s('F')}"


binding.pry
