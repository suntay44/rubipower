class SystemSetting < ApplicationRecord
  validates :key, presence: true, uniqueness: true
  validates :value, presence: true

  # Class methods for easy access to settings
  def self.get(key, default_value = nil)
    setting = find_by(key: key)
    setting ? setting.value : default_value
  end

  def self.set(key, value, description = nil)
    setting = find_or_initialize_by(key: key)
    setting.value = value
    setting.description = description if description
    setting.save!
    setting
  end

  def self.get_int(key, default_value = 0)
    get(key, default_value).to_i
  end

  def self.get_float(key, default_value = 0.0)
    get(key, default_value).to_f
  end

  def self.get_bool(key, default_value = false)
    value = get(key, default_value)
    value.to_s.downcase.in?([ "true", "1", "yes", "on" ])
  end
end
