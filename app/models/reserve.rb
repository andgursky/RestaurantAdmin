class Reserve < ApplicationRecord
  belongs_to :user
  belongs_to :restaurant

  TIME_REGEXP = /(?<hours>\d{2}):(?<minutes>\d{2})/i
  NON_VALIDATABLE_ATTRS = ["id", "created_at", "updated_at"]
  VALIDATABLE_ATTRS = Reserve.attribute_names.reject do |attr|
   NON_VALIDATABLE_ATTRS.include?(attr)
  end

  validates_presence_of VALIDATABLE_ATTRS
  #validates :time_start, :time_end, format:
  #  { with: TIME_REGEXP, message: "Time format 'hh:mm' only!" }
  after_validation :validate_time_overlap, :validate_table_exist,
    :validate_reserve_valid_interval

  private

  def validate_time_overlap
    # check for reservation time overlaping
    unless start_grater_end?(self.time_start, self.time_end)
      res = Reserve.where(str_sql_find_overlap)
      unless res.empty?
        errors.add(:reserve, 'Reservation time overlap error!')
      end
    end
  end

  def validate_reserve_valid_interval
    # check for valid reservation interval (30 min)
    h_start, m_start = split_time_str(self.time_start)
    h_end, m_end     = split_time_str(self.time_end)

    h_end += 24 unless h_end >= h_start

    if (((h_end - h_start) * 60 + m_end - m_start) % 30) != 0
      errors.add(:reserve, 'Reserve interval should be multiple by 30 (min)!')
    end
  end

  def validate_work_time_overflow
    # start/end time of reserve shouldn't be less/grater then restaurant
    # work hours
    rest_start_work = Restaurant.where(id:self.restaurant_id).first.time_open
    rest_end_work   = Restaurant.where(id:self.restaurant_id).first.time_close

    h_rest_start, m_rest_start = split_time_str(rest_start_work)
    h_rest_end, m_rest_end     = split_time_str(rest_end_work)
    h_start, m_start = split_time_str(self.time_start)
    h_end, m_end     = split_time_str(self.time_end)

    h_start += 24 if h_rest_start > h_start && h_start < h_rest_end
    h_rest_end += 24 if h_rest_end < h_rest_start
    h_end += 24 if h_end < h_start

    if h_end > h_rest_end || h_start < h_rest_start
      errors.add(:reserve, "Restaurant doesn't work in desired time interval!")
      return true
    else
      self.time_start = "%.2i:%.2i" % [h_start, m_start]
      self.time_end   = "%.2i:%.2i" % [h_end, m_end]
    end

    false
  end

  def validate_table_exist
    # table number shouldn't be grater then tables count in this restaurant
    # and shouldn't be less or equal zero
    tables_count = Restaurant.where(id:self.restaurant_id).first.tables_count

    unless tables_count >= self.table_number && self.table_number > 0
      errors.add(:reserve, "Table #{self.table_number} doesn't exist in this"+
                " restaurant!")
    end
  end

  def split_time_str(time)
    time.split(':').map(&:to_i)
  end

  def start_grater_end?(time_start, time_end)
    h_start, m_start = split_time_str(time_start)
    h_end, m_end = split_time_str(time_end)

    if validate_work_time_overflow
      errors.add(:reserve, "Start time should be less then end time!")
      return true
    end

    false
  end

  def str_sql_find_overlap
    unless self.id
      fmt = "user_id=%i AND restaurant_id=%i AND table_number=%i AND "+
            "time_end>\'%s\' AND time_start<\'%s\'"
      str = fmt % [self.user_id, self.restaurant_id, self.table_number,
                   self.time_start, self.time_end]
    else
      fmt = "user_id=%i AND restaurant_id=%i AND table_number=%i AND "+
            "time_end>\'%s\' AND time_start<\'%s\' AND id<>%i"
      str = fmt % [self.user_id, self.restaurant_id, self.table_number,
                   self.time_start, self.time_end, self.id]
    end
  end

end
