require 'rexml/document'

class CurrencyConverter
  def initialize(xml_path)
    xml = REXML::Document.new File.new xml_path
    rates = []
    xml.elements.each '//rates/rate' do |rate|
      rates << {
        :from => rate.elements['from'].text,
        :to   => rate.elements['to'].text,
        :rate => rate.elements['conversion'].text.to_f
      }
    end

    @currencies = (rates.map { |rate| rate[:from] }) + (rates.map { |rate| rate[:to] })
    @currencies.sort!
    @currencies.uniq!

    @conversion_table = Array.new(@currencies.size) do |i|
      Array.new(@currencies.size) do |j|
        {
          :cost => i == j ? 0 : 999,
          :via  => nil,
          :rate => i == j ? 1.0 : nil
        }
      end
    end

    rates.each do |rate|
      i = @currencies.index rate[:from]
      j = @currencies.index rate[:to]
      @conversion_table[i][j][:cost] = 1
      @conversion_table[i][j][:rate] = rate[:rate]
    end

    @currencies.size.times do |k|
      @currencies.size.times do |i|
        @currencies.size.times do |j|
          k_cost = @conversion_table[i][k][:cost] + @conversion_table[k][j][:cost]
          if k_cost < @conversion_table[i][j][:cost]
            @conversion_table[i][j][:cost] = k_cost
            @conversion_table[i][j][:via ] = k
          end
        end
      end
    end
  end

  def convert(amount, from, to)
    bankers_rounding (amount * find_rate(from, to))
  end

  private

  def find_path from, to
    i = @currencies.index from
    j = @currencies.index to

    via = @conversion_table[i][j][:via]
    cost = @conversion_table[i][j][:cost]
    if cost < 999 && via == nil
      [@conversion_table[i][j][:rate]]
    else
      find_path(from, @currencies[via]) + find_path(@currencies[via], to)
    end
  end

  def find_rate from, to
    path = find_path from, to
    path.inject(1.0, &:*)
  end

  def bankers_rounding f
    f_int = f.to_i
    f_dec = f - f_int
    if f_dec == 0.5
      f += f_int.even? ? -0.001 : 0.001
    end
    f.round(2)
  end
end

class TransactionsParser
  def initialize csv_path
    @csv_path = csv_path
  end

  def parse
    File.open @csv_path do |f|
      f.gets
      while s = f.gets
        store, sku, amount = s.split(",")
        amount, currency = amount.split(" ")
        amount = amount.to_f
        yield({
          :store    => store,
          :sku      => sku,
          :amount   => amount,
          :currency => currency
        })
      end
    end
  end
end

class Problem1
  def initialize rates_path, transactions_path
    @converter = CurrencyConverter.new rates_path
    @parser = TransactionsParser.new transactions_path
  end

  def solution
    total = 0
    @parser.parse do |transaction|
      sku = transaction[:sku]
      if sku == 'DM1182'
        amount   = transaction[:amount]
        currency = transaction[:currency]
        total += (@converter.convert(amount, currency, 'USD') * 100.0).round.to_i
      end
    end
    total.to_f / 100.0
  end
end
