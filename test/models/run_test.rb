
require "test_helper"

class RunTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(
      username: "runner",
      email: "runner@example.com"
    )

    @game = Game.create!(name: "Factorio")

    @category = @game.categories.create!(name: "Any%")

    @moderator = GameModerator.create!(user: @user, game: @game)
  end

  test "verifying a submitted run marks it as verified when no other exists" do
    run = Run.create!(
      user: @user,
      category: @category,
      time_ms: 200_000,
      status: :submitted,
      position: 0,
      video_url: "https://example.com/run"
    )

    run.verify!(@user)

    assert run.verified?
  end

  test "verifying a faster run obsoletes the slower verified run" do
    slower_run = Run.create!(
      user: @user,
      category: @category,
      time_ms: 200_000,
      status: :submitted,
      position: 0,
      video_url: "https://example.com/slow"
    )

    faster_run = Run.create!(
      user: @user,
      category: @category,
      time_ms: 150_000,
      status: :submitted,
      position: 0,
      video_url: "https://example.com/fast"
    )

    slower_run.verify!(@user)
    faster_run.verify!(@user)

    assert slower_run.reload.obsoleted?
    assert faster_run.reload.verified?
  end

  test "verifying a slower run does not replace a faster verified run" do
    faster_run = Run.create!(
      user: @user,
      category: @category,
      time_ms: 150_000,
      status: :submitted,
      position: 0,
      video_url: "https://example.com/fast"
    )

    slower_run = Run.create!(
      user: @user,
      category: @category,
      time_ms: 200_000,
      status: :submitted,
      position: 0,
      video_url: "https://example.com/slow"
    )

    faster_run.verify!(@user)
    slower_run.verify!(@user)

    assert faster_run.reload.verified?
    assert slower_run.reload.obsoleted?
  end
  
  test "leaderboard positions are recalculated after verification" do
    slower = Run.create!(
      user: @user,
      category: @category,
      time_ms: 200_000,
      status: :submitted,
      position: 0,
      video_url: "https://example.com/slow"
    )

    faster = Run.create!(
      user: @user,
      category: @category,
      time_ms: 150_000,
      status: :submitted,
      position: 0,
      video_url: "https://example.com/fast"
    )

    slower.verify!(@user)
    faster.verify!(@user)

    assert_equal 1, faster.reload.position
    assert_equal 0, slower.reload.position
  end

  
  test "only a moderator can verify a run" do
    runner = User.create!(username: "runner", email: "runner@example.com")
    moderator = User.create!(username: "mod", email: "mod@example.com")

    game = Game.create!(name: "Factorio")
    category = game.categories.create!(name: "Any%")

    GameModerator.create!(user: moderator, game: game)

    run = Run.create!(
      user: runner,
      category: category,
      time_ms: 150_000,
      status: :submitted,
      position: 0,
      video_url: "https://example.com/run"
    )

    assert_raises(RuntimeError) do
      run.verify!(runner)
    end

    assert_nothing_raised do
      run.verify!(moderator)
    end
  end

  test "leaderboard_for returns only verified runs ordered by position" do
    slower = Run.create!(
      user: @user,
      category: @category,
      time_ms: 200_000,
      status: :submitted,
      position: 0,
      video_url: "slow"
    )

    faster = Run.create!(
      user: @user,
      category: @category,
      time_ms: 150_000,
      status: :submitted,
      position: 0,
      video_url: "fast"
    )

    slower.verify!(@user)
    faster.verify!(@user)

    leaderboard = Run.leaderboard_for(@category)

    assert_equal [faster], leaderboard
  end
  
end