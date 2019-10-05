require 'httparty'

module Ynab
	class Client
		include HTTParty

		DATE_FORMAT = '%Y-%m-%d'

		attr_accessor :budget_id, :account_id, :payee_id

		# debug_output $stderr
		base_uri 'https://api.youneedabudget.com/v1'
		headers "Content-Type" => "application/json"

		def initialize(key:, budget:, account:, payee:)
			self.class.headers "Authorization" => "Bearer #{key}"
			self.budget_id = budget
			self.account_id = account
			self.payee_id = payee
		end

		def transactions(since:nil)
			query = since.nil? ? {} : {since_date: since.strftime(DATE_FORMAT)}
			self.class.get("/budgets/#{budget_id}/accounts/#{account_id}/transactions", query: query).parsed_response['data']['transactions']
		end

		def update_transaction(transaction_id, date:, amount:)
			data = {
				account_id: account_id,
				date: date.strftime(DATE_FORMAT),
				amount: amount,
				payee_id: payee_id,
			}
			puts "Updating tx id: #{transaction_id} with data: #{data.to_json} ..."
			res = self.class.put("/budgets/#{budget_id}/transactions/#{transaction_id}", body: {transaction: data}.to_json)
			# puts "YNAB_API Update response: #{res.code} - #{res.body}"
			if res.code == 200
				res.parsed_response['data']['transaction']
			else
				raise "There was an error updating transaction ##{transaction_id}. #{res.code} #{res.body}"
			end
		end

		def account
			res = self.class.get("/budgets/#{budget_id}/accounts/#{account_id}")
			# puts "YNAB_API account reponse: #{res.body}"
			res.parsed_response['data']['account']
		end

		def create_transaction(date:, amount:)
			data = {
				account_id: account_id,
				date: date.strftime(DATE_FORMAT),
				amount: amount,
				payee_id: payee_id,
				approved: true,
			}
			puts "Creating tx with data: #{data.to_json} ..."
			res = self.class.post("/budgets/#{budget_id}/transactions", body: {transaction: data}.to_json)
			
			if res.code == 201
				res.parsed_response['data']['transaction']
			else
				raise "There was an error creating transaction. #{res.code} #{res.body}"
			end
		end # create_transaction

		def balance
			out = BigDecimal(account['balance']) / 1000
			puts "Previous YNAB balance: #{out.round(2).to_s('F')}"
			out
		end

		def set_account_value(value)
			# get current time
			now = Time.now
			this_month = Time.new(now.year, now.month, 1)
			puts "Starting set_account_value now: #{now} this_month: #{this_month} ..."

			# find a current tx or create a new one
			txs = transactions(since: this_month)

			case txs.count
			when 0
				# create a new tx
				amount = (value - balance).round(2) * 1000
				
				create_transaction(date: now, amount: amount.to_i)
			when 1
				# update existing tx
				tx = txs.first
				tx_amount = BigDecimal(tx['amount']) / 1000
				amount = ((value - balance + tx_amount).round(2) * 1000).to_i
				date = now
				
				update_transaction(tx['id'], amount: amount, date: date) unless (tx_amount * 1000) == amount
			else
				raise "There are too many transactions in YNAB for this month."
			end
		end # set_account_value

	end
end
