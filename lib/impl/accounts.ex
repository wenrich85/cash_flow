defmodule CashFlow.Impl.Accounts do
  defstruct ~w[operating_expense operating_threshold business_profit profit_threshold taxes owners_comp investment_holding owners_salary expenses]a

  def new do
    %__MODULE__{
      operating_expense: 0,
      operating_threshold: 0,
      business_profit: 0,
      profit_threshold: 0,
      taxes: 0,
      owners_comp: 0,
      owners_salary: 16000,
      investment_holding: 0,
      expenses: []
    }
  end

  def new(%{} = accounts) do
    struct!(%__MODULE__{}, accounts)
  end

  def set_expense_threshold(accounts, threshold) do
    struct!(accounts, %{operating_threshold: threshold})
    |> set_profit_threshold()
  end

  def make_deposit(accounts, amount) do
    struct!(accounts, %{operating_expense: accounts.operating_expense + amount})
  end

  def simulate_month(accounts, revenue, expenses) do
    make_deposit(accounts, revenue)
    |> pay_owners_taxes()
    |> pay_expenses( expenses)
    |> check_threshold()
    |> check_profit_threshold()

  end

  def add_expense(accounts, expense) do
    struct!(accounts, expenses: [expense | accounts.expenses ])
  end

  defp pay_expenses(%{operating_expense: operating_expense}=accounts, expenses) when expenses < operating_expense do
    struct!(accounts, %{operating_expense: accounts.operating_expense - expenses})
  end

  defp pay_owners_taxes(accounts) do
    taxes_due = Enum.filter(accounts.expenses, fn exp -> exp.type == "Owner's Salary" end)
    |> Enum.reduce(0, fn pay, acc -> acc + pay.amount * 0.2 end)
    struct!(accounts, operating_expense: accounts.operating_expense - taxes_due, taxes: accounts.taxes + taxes_due)
  end

  defp pay_owner(accounts) do
    struct!(accounts, operating_expense: accounts.operating_expense - accounts.owners_salary, owners_comp: accounts.owners_comp + accounts.owners_salary)
  end

  defp check_threshold(%{operating_expense: operating_expense, operating_threshold: threshold}=accounts) when operating_expense > threshold do
    difference = operating_expense - threshold
    struct!(accounts, %{operating_expense: threshold, business_profit: accounts.business_profit + difference/2, taxes: accounts.taxes + difference/2})
  end

  defp check_threshold(%{}=accounts) do
    accounts
  end

  defp set_profit_threshold(%{} = accounts ) do
    struct!(accounts, profit_threshold: accounts.operating_threshold * 6 )
  end

  defp check_profit_threshold(%{business_profit: business_profit, profit_threshold: profit_threshold } = accounts) when business_profit > profit_threshold do
    difference = business_profit - profit_threshold
    struct!(accounts, %{business_profit: profit_threshold, investment_holding: accounts.investment_holding + difference})
  end

  defp check_profit_threshold(accounts) do
    accounts
  end
end
