require_relative '../bin/json2csv.rb'

describe 'Json2csv instance methods' do
  before do
    @ins = Json2csv.new
  end

  it 'init the class' do
    expect(@ins.branches).to be_empty
  end

  it 'load data' do
    expect { @ins.load_data }.not_to raise_error
  end

  it 'find branches' do
    @ins.load_data
    @ins.send(:find_branches, @ins.data.first)
    expect(@ins.branches).not_to be_empty
  end

  it 'every branch found is differente from one another' do
    @ins.load_data
    @ins.send(:find_branches, @ins.data.first)
    expect(@ins.branches.count).to eq(@ins.branches.uniq.count)
  end
end

describe 'Json2csv class methods' do
  it 'find value on a hash from array of keys' do
    hash = { aa: { bb: 42 }, cc: 12 }
    expect(Json2csv.extract_value(hash, [:aa, 'bb'])).to eq(42)
  end
end
