require 'rails_helper'

RSpec.describe Record, type: :model do
  it '作成成功' do
    user = create(:user)
    job = create(:warrior)
    record = user.records.build(job_id: job.id)
    expect(record.valid?).to eq true
  end

  it 'user_idがない場合に失敗' do
    job = create(:warrior)
    record = job.records.build(user_id: nil)
    expect(record.valid?).to eq false
  end

  it 'job_idがない場合に失敗' do
    user = create(:user)
    record = user.records.build(job_id: nil)
    expect(record.valid?).to eq false
  end

  it 'user_idとjob_idの組み合わせが一意でない場合に失敗' do
    user = create(:user)
    job = create(:warrior)
    record1 = user.records.create(job_id: job.id)
    record2 = user.records.build(job_id: job.id)
    expect(record2.valid?).to eq false
  end

  it '必要累積経験値とレベルが一致しているかどうか' do
    100.times do |i|
      next if i==0
      exp = (12 * ((1 - 1.5 ** (i - 1)) / (1 - 1.5))).round
      level = ((Math.log(1 - (exp / 12.0) * (1 - 1.5)) / Math.log(1.5)) + 1).round
      expect(level).to eq i
    end
  end

  # 1~99までのレベルアップについて確認する
  it 'レベルアップに必要な経験値(javascriptで算出)が正しいかどうか' do
    # レベルアップに必要な経験値(JavaScriptで算出)
    EX_REQUIRED_TO_LEVEL_UP = [
      12,
      18,
      27,
      41,
      61,
      91,
      137,
      205,
      308,
      461,
      692,
      1038,
      1557,
      2335,
      3503,
      5255,
      7882,
      11823,
      17735,
      26602,
      39903,
      59855,
      89782,
      134673,
      202009,
      303014,
      454521,
      681782,
      1022672,
      1534008,
      2301013,
      3451519,
      5177279,
      7765918,
      11648877,
      17473315,
      26209973,
      39314959,
      58972439,
      88458659,
      132687988,
      199031982,
      298547973,
      447821959,
      671732938,
      1007599408,
      1511399112,
      2267098667,
      3400648001,
      5100972002,
      7651458003,
      11477187004,
      17215780506,
      25823670759,
      38735506138,
      58103259207,
      87154888811,
      130732333216,
      196098499824,
      294147749735,
      441221624603,
      661832436905,
      992748655357,
      1489122983036,
      2233684474554,
      3350526711831,
      5025790067746,
      7538685101619,
      11308027652428,
      16962041478642,
      25443062217963,
      38164593326945,
      57246889990417,
      85870334985625,
      128805502478438,
      193208253717657,
      289812380576485,
      434718570864728,
      652077856297092,
      978116784445637,
      1467175176668456,
      2200762765002683,
      3301144147504025,
      4951716221256038,
      7427574331884057,
      11141361497826084,
      16712042246739126,
      25068063370108692,
      37602095055163040,
      56403142582744560,
      84604713874116830,
      126907070811175250,
      190360606216762880,
      285540909325144320,
      428311363987716500,
      642467045981574700,
      963700568972362000,
      1445550853458543000,
      2168326280187814700,
    ]
    EX_REQUIRED_TO_LEVEL_UP.freeze

    99.times do |i|
      next if i==0
      exp = (12 * ((1 - 1.5 ** (i - 1)) / (1 - 1.5))).round
      exp += EX_REQUIRED_TO_LEVEL_UP[i].to_i
      level = ((Math.log(1 - (exp / 12.0) * (1 - 1.5)) / Math.log(1.5)) + 1).round
      expect(level).to eq i+1
    end
  end
end
