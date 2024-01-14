class OctopusEnergyBill

	GetBillDayQUERY = OctopusClient::Client.parse <<~'GRAPHQL'
		query(
			$accountNumber: String!
			$fromDatetime: DateTime
			$toDatetime: DateTime
		) {
			account(accountNumber: $accountNumber) {
				properties {
					electricitySupplyPoints {
						agreements {
							validFrom
						}
						halfHourlyReadings(
							fromDatetime: $fromDatetime
							toDatetime: $toDatetime
						) {
							startAt
							endAt
							value
							costEstimate
							consumptionStep
							consumptionRateBand
						}
					}
				}
			}
		}
  GRAPHQL


	GetBillMonthQUERY = OctopusClient::Client.parse <<~'GRAPHQL'
		query ($accountNumber: String!) {
			account(accountNumber: $accountNumber) {
				properties {
					electricitySupplyPoints {
						agreements {
							validFrom
						}
						intervalReadings {
							endAt
							startAt
							value
							costEstimate
						}
					}
				}
			}
		}
  GRAPHQL

  def notify_yesterday
    result = OctopusClient::Client.query(GetBillDayQUERY, variables: {
      accountNumber: ENV['OCTOPUS_ACCOUNT_NUMBER'],
      fromDatetime: Date.yesterday.beginning_of_day.iso8601,
      toDatetime: Date.yesterday.end_of_day.iso8601
      })


		electricity_supply_points = get_electricity_supply_points(result)
    half_hourly_readings = electricity_supply_points.first["halfHourlyReadings"]
    @kwh = half_hourly_readings.pluck("value").map(&:to_f).sum.round(2)
    @cost = half_hourly_readings.pluck("costEstimate").map(&:to_f).sum.round(1)
    text = "#{Date.yesterday.strftime('%Y年%m月%d日')}は#{@kwh}kWh消費して#{@cost}円かかったよ"

		LineBotClient.new.client.broadcast(message)
  end

	def notify_last_month
    result = OctopusClient::Client.query(GetBillMonthQUERY, variables: {
      accountNumber: ENV['OCTOPUS_ACCOUNT_NUMBER'],
      })

		electricity_supply_points = get_electricity_supply_points(result)
		monthly_readings = electricity_supply_points.first["intervalReadings"]

    @kwh = monthly_readings.last["value"].to_f.round(1)
    @cost = monthly_readings.last["costEstimate"].to_f.round(0)
    text = "#{Date.today.last_month.strftime('%Y年%m月')}は#{@kwh}kWh消費して#{@cost}円かかったよ"

		send_message(text)
	end

	private

	def get_electricity_supply_points(result_data)
		properties = result_data.original_hash.dig("data", "account", "properties")
		electricity_supply_points = properties.first["electricitySupplyPoints"]
	end

	def send_message(text)
		message = {
      type: 'text',
      text: text
    }

		LineBotClient.new.client.broadcast(message)
	end
end
