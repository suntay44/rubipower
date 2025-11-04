class MakePurchaseRequestOptionalInItems < ActiveRecord::Migration[8.0]
  def change
    change_column_null :items, :purchase_request_id, true
  end
end
