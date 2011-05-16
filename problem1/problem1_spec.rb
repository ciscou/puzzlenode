require File.join(File.dirname(File.expand_path(__FILE__)), 'problem1')

describe CurrencyConverter do
  before(:all) do
    @converter = CurrencyConverter.new 'SAMPLE_RATES.xml'
  end

  it "should do nothing for the same currencies" do
    @converter.convert(12.34, 'USD', 'USD').should == 12.34
  end

  it "should do direct conversions" do
    @converter.convert(12.34, 'USD', 'CAD').should == 12.23
  end

  it "should do non direct conversions" do
    @converter.convert(12.34, 'AUD', 'USD').should == 12.55
  end
end

describe TransactionsParser do
  before(:all) do
    @parser = TransactionsParser.new 'SAMPLE_TRANS.csv'
  end

  it "should read all the transactions in the file" do
    transactions = 0
    @parser.parse do |transaction|
      transactions += 1
    end
    transactions.should == 5
  end
end

describe Problem1 do
  it "should return 134.22 for the sample files" do
    @problem1 = Problem1.new 'SAMPLE_RATES.xml', 'SAMPLE_TRANS.csv'
    @problem1.solution.should == 134.22
  end

  it "should return 59482.47 for the problem files" do
    @problem1 = Problem1.new 'RATES.xml', 'TRANS.csv'
    @problem1.solution.should == 59482.47
  end
end
