require 'httparty'
require 'json'
require 'bigdecimal'
require 'time'

require_relative 'lib/ynab'
require_relative 'lib/coin_market_cap'
require_relative 'lib/stock'

$stdout.sync = true
$stderr.sync = true

#########################################
# handle crypto
#########################################
ynab = Ynab::Client.new(key: ENV['YNAB_API_KEY'], budget: ENV['YNAB_BUDGET_ID'], account: ENV['YNAB_ACCOUNT_ID'], payee: ENV['YNAB_PAYEE_ID'])
coin = CoinMarketCap::Client.new

portfolio = {}
ENV['CRYPTOS'].split(';').each do |string|
  ticker, amount = string.split(':')
  portfolio[ticker] = BigDecimal(amount)
end

# get quotes from coinmarketcap
quotes = {}
coin.quotes['data'].each do |symbol, quote|
  quotes[symbol] = BigDecimal(quote['quote']['USD']['price'].to_s)
end

# calculate portfolio value
value = BigDecimal(0.0, 2)
portfolio.each do |symbol, qty|
  raise "Cannot find quote for #{symbol}" unless quotes.include?(symbol)

  value += quotes[symbol] * qty
end
puts "Portfolio value: #{value.round(2).to_s('F')}"

ynab.set_account_value(value)

#########################################
# handle stocks
#########################################
stock = Stock::Client.new
ynab = Ynab::Client.new(key: ENV['YNAB_API_KEY'], budget: ENV['YNAB_BUDGET_ID'], account: ENV['YNAB_STOCK_ACCOUNT_ID'], payee: ENV['YNAB_PAYEE_ID'])

portfolio = {}
ENV['STOCKS'].split(';').each do |string|
  ticker, amount = string.split(':')
  portfolio[ticker] = BigDecimal(amount)
end

# calculate portfolio value
value = BigDecimal(0.0, 2)
portfolio.each do |symbol, qty|
  value += if symbol == 'CASH'
             qty
           else
             stock.fund(symbol)[:price] * qty
           end
end
puts "Portfolio value: #{value.round(2).to_s('F')}"
ynab.set_account_value(value)

puts 'Done.'
