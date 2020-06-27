defmodule HappyTrucker.TestHelper do

  def make_ctx(user) do
    HappyTrucker.Params.make_ctx(%{current_user: user})
  end
end
