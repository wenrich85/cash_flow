defmodule CashFlow.Impl.Accounts do
  defstruct ~w[operating_expense operating_threshold business_profit profit_threshold taxes owners_comp investment_holding expenses]a

  def new do
    %__MODULE__{
      operating_expense: 0,
      operating_threshold: 0,
      business_profit: 0,
      profit_threshold: 0,
      taxes: 0,
      owners_comp: 0,
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

  def make_deposit(accounts, amount \\ 0) do
    {sales_tax, deposit } = split_sales_taxes(amount)
    struct!(accounts, %{operating_expense: accounts.operating_expense + deposit, taxes: accounts.taxes+ sales_tax})
  end

  def simulate_month(accounts, revenue) do
    make_deposit(accounts, revenue)
    |> pay_owner()
    |> pay_owners_taxes()
    |> pay_expenses()
    |> check_threshold()
    |> check_profit_threshold()

  end

  def add_expense(accounts, expense) do
    struct!(accounts, expenses: [expense | accounts.expenses ])
  end

  def pay_expenses(%{expenses: expenses}=accounts) do
    expense_total =
      expenses
      |> Enum.filter(fn exp -> exp.type != "Owner's Salary" end)
      |> Enum.reduce( 0, fn x, acc -> x.amount + acc end)
    struct!(accounts, %{operating_expense: accounts.operating_expense - expense_total})
  end

  defp pay_owners_taxes(accounts) do
    taxes_due = Enum.filter(accounts.expenses, fn exp -> exp.type == "Owner's Salary" end)
    |> Enum.reduce(0, fn pay, acc -> acc + pay.amount * 0.2 end)
    struct!(accounts, operating_expense: accounts.operating_expense - taxes_due, taxes: accounts.taxes + taxes_due)
  end

  @spec pay_owner(
          atom
          | %{
              :__struct__ => atom,
              :expenses => any,
              :operating_expense => number,
              :owners_comp => number,
              optional(atom) => any
            }
        ) :: struct
  def pay_owner(accounts) do
    owners_salary = Enum.filter(accounts.expenses, fn exp -> exp.type == "Owner's Salary" end)
    |> Enum.reduce(0, fn expense, acc -> acc + expense.amount end)
    struct!(accounts, operating_expense: accounts.operating_expense - owners_salary, owners_comp: accounts.owners_comp + owners_salary)
  end

  def check_thresholds(accounts) do
    accounts
    |> check_threshold()
    |> check_profit_threshold()
  end

  defp check_threshold(%{operating_expense: operating_expense, operating_threshold: threshold}=accounts) when operating_expense > threshold and threshold > 0 do
    difference = operating_expense - threshold
    struct!(accounts, %{operating_expense: threshold, business_profit: accounts.business_profit + difference/2, taxes: accounts.taxes + difference/2})
  end

  defp check_threshold(%{}=accounts) do
    accounts
  end

  defp set_profit_threshold(%{} = accounts ) do
    struct!(accounts, profit_threshold: accounts.operating_threshold * 6 )
  end

  defp check_profit_threshold(%{business_profit: business_profit, profit_threshold: profit_threshold } = accounts) when business_profit > profit_threshold and profit_threshold > 0 do
    difference = business_profit - profit_threshold
    struct!(accounts, %{business_profit: profit_threshold, investment_holding: accounts.investment_holding + difference})
  end

  defp check_profit_threshold(accounts) do
    accounts
  end

  defp split_sales_taxes(deposit) do
    taxes = deposit * 0.06
    {taxes, deposit-taxes}
  end


end
