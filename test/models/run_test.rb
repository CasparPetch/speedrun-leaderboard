
require "test_helper"

class RunTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(
      username: "runner",
      email: "runner@example.com"
    )

    @game = Game.create!(name: "Factorio")

    @category = @game.categories.create!(name: "Any%")
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

    run.verify!

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

    slower_run.verify!
    faster_run.verify!

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

    faster_run.verify!
    slower_run.verify!

    assert faster_run.reload.verified?
    assert slower_run.reload.obsoleted?
  end
end
