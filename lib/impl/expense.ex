defmodule CashFlow.Impl.Expense do
  defstruct ~w[type amount recurring]a


  def new do
    %__MODULE__{
      type: "unknown",
      amount: 0,
      recurring: false
    }
  end

  def new %{type: type, amount: amount, recurring: recurring} do
    %__MODULE__{
      type: type,
      amount: amount,
      recurring: recurring
    }
  end

  def calculate_total_expenses(expenses) do
    Enum.reduce(expenses, 0, fn ex, acc -> ex.amount + acc end)
  end

end
