class Run < ApplicationRecord
  belongs_to :user
  belongs_to :category

  
  enum :status, {
    submitted: 0,
    verified: 1,
    rejected: 2,
    deleted: 3,
    obsoleted: 4
  }


  def verify!(acting_user)
    unless submitted?
      raise "Run is not in submitted state"
    end

    game = category.game

    unless acting_user.moderated_games.include?(game)
      raise "User is not a moderator for this game"
    end

    Run.transaction do
      existing = Run
        .where(user_id: user_id, category_id: category_id)
        .verified
        .where.not(id: id)
        .first

      if existing
        faster, slower = [self, existing].sort_by(&:time_ms)

        slower.update!(status: :obsoleted, position: 0)
        faster.update!(status: :verified)
      else
        update!(status: :verified)
      end

      recalculate_positions!
    end
  end

  private
  def recalculate_positions!
    verified_runs = Run
      .where(category_id: category_id, status: :verified)
      .order(:time_ms)

    verified_runs.each_with_index do |run, index|
      run.update_column(:position, index + 1)
    end
  end

end
