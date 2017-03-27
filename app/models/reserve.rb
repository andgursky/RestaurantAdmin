class Reserve < ApplicationRecord
  belongs_to :user
  belongs_to :restaurant

  #time_regexp = /(?<hours>\d{2}):(?<minuts>\d{2})/i
  #validates :time_start, :time_end, format: { with: time_regexp,                                            message: "Time format 'hh:mm' only!" }
  NON_VALIDATABLE_ATTRS = ["id", "created_at", "updated_at"]
  VALIDATABLE_ATTRS = Reserve.attribute_names.reject do |attr|
   NON_VALIDATABLE_ATTRS.include?(attr)
  end

  validates_presence_of VALIDATABLE_ATTRS
  after_validation :validate_time_overlap, :validate_reserve_valid_interval,
    :validate_work_time_overflow, :validate_table_exist
  # we need to validate inserting data to reserve
  # - time start/end

  private

  def validate_time_overlap
    # check for reservation time overlaping
  binding.pry
    res = Reserve.where("user_id=? AND restaurant_id=? AND table_number=? AND"+
                        " time_end>? AND time_start<?", self.user_id,
                        self.restaurant_id, self.table_number, self.time_start,
                        self.time_end)
    unless res.empty?
      errors.add(:reserve, 'Reservation time overlap error!')
    end
  end

  def validate_reserve_valid_interval
    # check for valid reservation interval (30 min)
  binding.pry
    h_start, m_start = split_time_str(self.time_start)
    h_end, m_end     = split_time_str(self.time_end)


    h_end += 24 unless h_end >= h_start

    if ((h_end - h_start) * 60 + m_end - m_start) % 30
      errors.add(:reserve, 'Reserve interval should be multiple by 30 (min)!')
    end
  end

  def validate_work_time_overflow
    # start/end time of reserve shouldn't be less/grater then restaurant
    # work hours
  binding.pry
    rest_start_work = Restaurant.where(id:self.restaurant_id).first.time_open
    rest_end_work   = Restaurant.where(id:self.restaurant_id).first.time_close

    h_rest_start, m_rest_start = split_time_str(rest_start_work)
    h_rest_end, m_rest_end     = split_time_str(rest_end_work)
    h_start, m_start = split_time_str(self.time_start)
    h_end, m_end     = split_time_str(self.time_end)

    h_rest_end += 24 unless h_rest_end >= h_rest_start
    h_end += 24 unless h_end >= h_start

    if h_end > h_rest_end || h_start < h_rest_start
      errors.add(:reserve, "Restaurant doesn't work in desired time interval?")
    end
  end

  def validate_table_exist
    # table number shouldn't be grater then tables count in this restaurant
    # and shouldn't be less or equal zero
  binding.pry
    tables_count = Restaurant.where(id:self.restaurant_id).first.tables_count

    unless tables_count >= self.table_number && self.table_number > 0
      errors.add(:reserve, "Table #{self.table_number} doesn't exist in this"+
                " restaurant!")
    end
  end

  def split_time_str(time)
    time.split(':').map(&:to_i)
  end
end
