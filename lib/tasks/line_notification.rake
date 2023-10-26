namespace :line_notification do
  desc "Send billing notification"
  task send_billing_notification: :environment do
    OctopusEnergyBill.new.notify
  end
end
