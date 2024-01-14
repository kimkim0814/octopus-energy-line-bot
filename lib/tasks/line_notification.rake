namespace :line_notification do
  desc "Send billing notification"
  task send_billing_notification_yesterday: :environment do
    OctopusEnergyBill.new.notify_yesterday
  end

  desc "Send billing notification"
  task send_billing_notification_last_month: :environment do
    OctopusEnergyBill.new.notify_last_month
  end
end
