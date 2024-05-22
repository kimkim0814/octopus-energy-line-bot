require 'rails_helper'

RSpec.describe OctopusEnergyBill, type: :service do
  let(:octopus_energy_bill) { OctopusEnergyBill.new }
  let(:mock_result) { instance_double("GraphQL::Client::Response") }

  describe '#notify_yesterday' do
    let(:mock_electricity_supply_points) { [{"halfHourlyReadings" => [{"value" => "1.0", "costEstimate" => "2.0"}]}] }

    before do
      allow(OctopusClient::Client).to receive(:query).and_return(mock_result)
      allow(octopus_energy_bill).to receive(:get_electricity_supply_points).and_return(mock_electricity_supply_points)
      allow(octopus_energy_bill).to receive(:send_message)
    end

    it 'queries the OctopusClient with correct parameters' do
      octopus_energy_bill.notify_yesterday
      expect(OctopusClient::Client).to have_received(:query).with(
        OctopusEnergyBill::GetBillDayQUERY,
        variables: {
          accountNumber: ENV['OCTOPUS_ACCOUNT_NUMBER'],
          fromDatetime: Date.yesterday.beginning_of_day.iso8601,
          toDatetime: Date.yesterday.end_of_day.iso8601
        }
      )
    end

    it 'sends a message with the correct text' do
      octopus_energy_bill.notify_yesterday
      expect(octopus_energy_bill).to have_received(:send_message).with("#{Date.yesterday.strftime('%Y年%m月%d日')}は1.0kWh消費して2.0円かかったよ")
    end
  end

  describe '#notify_last_month' do
    let(:mock_electricity_supply_points) { [{"intervalReadings" => [{"value" => "139.0", "costEstimate" => "3500.8"}]}] }

    before do
      allow(OctopusClient::Client).to receive(:query).and_return(mock_result)
      allow(octopus_energy_bill).to receive(:get_electricity_supply_points).and_return(mock_electricity_supply_points)
      allow(octopus_energy_bill).to receive(:send_message)
    end

    it 'queries the OctopusClient with correct parameters' do
      octopus_energy_bill.notify_last_month
      expect(OctopusClient::Client).to have_received(:query).with(
        OctopusEnergyBill::GetBillMonthQUERY,
        variables: { accountNumber: ENV['OCTOPUS_ACCOUNT_NUMBER'] }
      )
    end

    it 'sends a message with the correct text' do
      octopus_energy_bill.notify_last_month
      expect(octopus_energy_bill).to have_received(:send_message).with("#{Date.today.last_month.strftime('%Y年%m月')}は139.0kWh消費して3501円かかったよ")
    end
  end
end
